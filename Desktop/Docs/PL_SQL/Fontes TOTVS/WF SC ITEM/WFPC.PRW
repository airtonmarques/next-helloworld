#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc}'WorkFlow AprovaÃ§Ã£o de SolicitaÃ§Ãµes de Compras'
''
@author Ovio Consultoria	
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return '' 
/*/
User Function WFSZ( cEmp , cFil )

	Private cThread		:= AllTrim(Str(ThreadID()))

	If !LockByName("WFSZ"+cEmp , .F., .F. )
		Conout("["+cThread+"] - JOB workflow esta em execucao. Aguardando execucao anterior finalizar")
		Return
	EndIf

	Conout("["+cThread+"] - WorkFlow Alcadas de Compras - Inicio:" + Time() )
	Conout("["+cThread+"] -Empresa: " + cEmp + " Filial: "+cFil )

	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,Nil,Nil,"COM")

	Begin Sequence

		U_PC( { cEmp , cFil , 1 } )  	// 1 - ENVIO PC PARA APROVADORES
		U_PC( { cEmp , cFil , 3 } )  	// 3 - ENVIO PC ITENS APROVADOS PARA SOLICITANTE
		U_PC( { cEmp , cFil , 4 } )  	// 4 - ENVIO PC ITENS REPROVADOS PARA SOLICITANTE

		UnLockByName("WFSZ"+cEmp,.F.,.F. )

	End Sequence

	RpcClearEnv()

Return

/*/{Protheus.doc}''
''
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
User Function PC( aParam )

	If aParam == Nil .OR. VALTYPE(aParam) == "U"
		U_CONSOLE("Parametros nao recebidos => SC()")
		RETURN
	EndIf

	DBSelectArea("SM0")
	DBSetOrder(1)
	DBSeek( aParam[1] + aParam[2]  )

	U_CONSOLE('SC() /' + aParam[1] )

	WHILE !SM0->(EOF()) .AND. Alltrim(SM0->M0_CODIGO) == Alltrim(aParam[1])
		cFilAnt := Alltrim(SM0->M0_CODFIL)
		U_CONSOLE('SC() /' + aParam[1] + Alltrim(SM0->M0_CODFIL) )
		Conout("["+cThread+"] - JOB workflow esta em execucao. Empresa: "+cEmpAnt+" Filial: "+cFilAnt)
		U_WFPC( aParam[3] )
		SM0->(DBSkip())
	END

RETURN


/*/{Protheus.doc}''
''
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	
User Function WFPC(_nOpc, oProcess)
	Local nInd := 1
	Local _lProcesso := .F.
	Local aFiles := {}

	DO 	CASE
	CASE _nOpc == 1

		U_CONSOLE("1 - Prepara as solicitacoes a serem enviados para aprovacao")
		U_CONSOLE("1 - EmpFil:" + cEmpAnt + cFilAnt)

		_cQuery := ""
		_cQuery += " SELECT"
		_cQuery += " DISTINCT CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL,CR_GRUPO,CR_USER, CR_APROV, CR_DTLIMIT, CR_HRLIMIT "
		_cQuery += " FROM " + RetSqlName("SCR") + " SCR"
		_cQuery += " WHERE SCR.D_E_L_E_T_ <> '*'"
		_cQuery += " AND CR_FILIAL = '" + cFilAnt + "'"
		_cQuery += " AND CR_TIPO = 'SC'"
		_cQuery += " AND CR_STATUS = '02'"  						// Em aprovacao
		_cQuery += " AND CR_DTLIMIT  <= '" + DTOS(MSDATE()) + "'"	// Data Limite
		_cQuery += " AND CR_WF = ' '"
		_cQuery += " ORDER BY"
		_cQuery += " CR_FILIAL,"
		_cQuery += " CR_NUM,"
		_cQuery += " CR_NIVEL,"
		_cQuery += " CR_USER"

		If Select("TMP")>0
			dbSelectArea("TMP")
			dbCloseArea()
		Endif

		TcQuery _cQuery New Alias "TMP"

		dbGotop()
		While !TMP->(Eof())

			IF !EMPTY(TMP->CR_DTLIMIT)
				IF TMP->CR_DTLIMIT == DTOS(MSDATE())
					IF TMP->CR_HRLIMIT  >  LEFT(TIME(),5)
						TMP->(DBSkip())
						LOOP
					ENDIF
				ENDIF
			ENDIF

			DBSelectArea("SC1")
			DBSetOrder(1)
			DBSeek( TMP->CR_FILIAL + PADR(ALLTRIM(TMP->CR_NUM),6) )


			Conout("["+cThread+"] - JOB workflow esta em execucao. Enviando e-mail para aprovação, SC: "+SC1->C1_FILIAL+" - "+SC1->C1_NUM)

			_aWF := EnviaSC(TMP->CR_FILIAL, TMP->CR_NUM, TMP->CR_USER , TMP->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER) , TMP->CR_GRUPO , STOD(TMP->CR_DTLIMIT), TMP->CR_HRLIMIT, _nOpc)

			DBSelectarea("SCR")
			DBSetOrder(2)
			IF DBSeek(TMP->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER))
				While SCR->(!Eof()) .And. TMP->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER) == SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER)
					Reclock("SCR",.F.)
					SCR->CR_WF			:= IIF(EMPTY(_aWF[1])," ","1")  	// Status 1 - envio para aprovadores / branco-nao houve envio
					SCR->CR_WFID		:= _aWF[1]		// Rastreabilidade
					SCR->CR_DTLIMIT		:= _aWF[2]		// Data Limite
					SCR->CR_HRLIMIT		:= _aWF[3]		// Hora Limite
					MSUnlock()
					SCR->(dbskip())
				End
			ENDIF

			_lProcesso := .T.

			TMP->(DBSkip())
		End

		If Select("TMP")>0
			dbSelectArea("TMP")
			dbCloseArea()
		Endif

	CASE _nOPC	== 2

		U_CONSOLE("2 - Processa O RETORNO DO EMAIL")
		U_CONSOLE("2 - EmpFil:" + cEmpAnt + cFilAnt)
		U_CONSOLE("2 - Semaforo Vermelho" )

		nWFPC2 		:= U_Semaforo("WFPC2")
		cNumSC		:= alltrim(oProcess:oHtml:RetByName("C1_NUM"))
		cFilAnt		:= alltrim(oProcess:oHtml:RetByName("CFILANT"))
		cChaveSCR	:= alltrim(oProcess:oHtml:RetByName("CHAVE"))
		cObs     	:= alltrim(oProcess:oHtml:RetByName("OBS"))
		cWFID     	:= alltrim(oProcess:oHtml:RetByName("WFID"))
		cTo   		:= SUBS( alltrim(oProcess:cRetFrom), AT('<',alltrim(oProcess:cRetFrom)) + 1 , LEN(alltrim(oProcess:cRetFrom))-AT('<',alltrim(oProcess:cRetFrom))-1 )

		oProcess:Finish()


		cObs := NoAcento(DecodeUtf8(cObs))

		U_CONSOLE("2 - cFilAnt :" + cFilAnt)
		U_CONSOLE("2 - Chave   :" + cChaveSCR)
		U_CONSOLE("2 - Obs     :" + cObs)
		U_CONSOLE("2 - WFId    :" + cWFID)
		U_CONSOLE("2 - cTo     :" + cTo)

		lContinua := .T.

		aItens :={}
		aItens := oProcess:oHtml:aListTables[2][1][2]

		DBSelectArea("SCR")
		DBSetOrder(2)
		if DBSeek(cChaveSCR)
			While SCR->(!Eof()) .And.  SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER)==cChaveSCR

				if ALLTRIM(SCR->CR_WFID) <> ALLTRIM(cWFID)
					U_CONSOLE("2 - Processo nao encontrado :" + cWFID + " Processo atual :" + SCR->CR_WFID)
					U_CONSOLE("2 - Semaforo Verde" )
					U_Semaforo(nWFPC2)
					lContinua := .F.
				Else
					If !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS$"03#04#05"
						U_CONSOLE("2.1 - Processo respondido anteriormente :" + cWFID)
						U_CONSOLE("2.1 - Semaforo Verde" )

						cSubject    := Alltrim(SM0->M0_NOME)+" - AVISO - Solicitação de Compra No. " + Substr(cChaveSCR,5,6) +" respondido anteriormente"
						_cEmail		:= UsrRetMail(Substr(cChaveSCR,55,6))

						aMsg := {}

						aaDD(aMsg, "Sr. Aprovador,")
						aaDD(aMsg, "<br></br>")
						AADD(aMsg, 'A Solicitação de Compra No.: ' + Substr(cChaveSCR,5,6) + ' foi anteriormente '+SCR->CR_OBS)
						aaDD(aMsg, "<br></br>")
						aaDD(aMsg, "<br></br>")

						cBody := '<html>'
						cBody += '<head>'
						cBody += '</head>'
						cBody += '<meta http-equiv="Content-Type" content="text/html;charset=windows-1252"/>'
						cBody += '<body>'
						cBody += '<div style="color:#003486;"><big><span'
						cBody += ' class="610203920-12022004"><img alt="logo" src="https://allcare.com.br/blog/wp-content/uploads/2020/11/logo-allcare-1.png"</span></big></div>'
						cBody += '<hr>'
						cBody += '<div><font color="#003486" face="Verdana"'
						cBody += ' size="3"><span class="216593018-10022004"><br>'
						For nInd := 1 TO Len(aMsg)
							cBody += '<DIV><FONT face=Verdana color=#000080 size=3><SPAN class=216593018-10022004>' + aMsg[nInd] + '</SPAN></FONT></DIV><p>'
						Next
						cBody += '<p></p>'
						cBody += '<FONT face=Arial size=1>Workflow - Serviço de Envio de Mensagens</FONT><br>'
						cBody += '</body>'
						cBody += '</html>'


						OvEnvMail(cBody,_cEmail,cSubject,aFiles)

						U_Semaforo(nWFPC2)
						lContinua := .F.
					Else
						dbSelectArea("DBM")
						dbSetOrder(1) //DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USER+DBM_USEROR
						if dbSeek( SCR->CR_FILIAL + SCR->CR_TIPO + SCR->CR_NUM +SCR->CR_GRUPO + SCR->CR_ITGRP + SCR->CR_USER )
							While DBM->(!Eof()) .And. SCR->CR_FILIAL  + SCR->CR_TIPO  + SCR->CR_NUM  + SCR->CR_GRUPO  + SCR->CR_ITGRP  + SCR->CR_USER==;
									DBM->DBM_FILIAL + DBM->DBM_TIPO + DBM->DBM_NUM + DBM->DBM_GRUPO + DBM->DBM_ITGRP + DBM->DBM_USER

								if aScan( aItens , Alltrim(DBM->DBM_ITEM)+"ON" ) > 0

									dbSelectArea("SC1")
									dbSetOrder(1)
									If DbSeek( xFilial("SC1") + Substr(Alltrim(SCR->CR_NUM),1,6) + DBM->DBM_ITEM )
										Reclock("SC1",.F.)
										SC1->C1_APROV := "R"
										SC1->C1_WF    := "2"
										MsUnLock()
									Endif

									Reclock("SCR",.F.)
									SCR->CR_OBS    := NoAcento(Alltrim(cObs))
									SCR->CR_WF     := "2"
									SCR->CR_STATUS := "04"
									MsUnlock()

									Reclock("DBM",.F.)
									DBM->DBM_APROV :="3"
									MsUnLock()
								Else
									dbSelectArea("SC1")
									dbSetOrder(1)
									If DbSeek( xFilial("SC1") + Substr(Alltrim(SCR->CR_NUM),1,6) + DBM->DBM_ITEM )
										Reclock("SC1",.F.)
										SC1->C1_APROV := "L"
										SC1->C1_WF    := "2"
										MsUnLock()
									Endif

									Reclock("SCR",.F.)
									SCR->CR_OBS    := NoAcento( Alltrim(cObs) )
									SCR->CR_WF     := "2"
									SCR->CR_STATUS := "03"
									MsUnlock()

									Reclock("DBM",.F.)
									DBM->DBM_APROV :="1"
									MsUnLock()
								Endif
								DBM->(dbSkip())
							End
						EndIf
					Endif
				Endif
				SCR->(dbSkip())
			End
		Endif

		if !lContinua
			Return
		Endif

		U_CONSOLE("2 - Semaforo Verde" )
		U_Semaforo(nWFPC2)


	CASE _nOpc == 3

		U_CONSOLE("3 - Envia resposta de solicitacao APROVADA para o comprador")
		U_CONSOLE("3 - EmpFil:" + cEmpAnt + cFilAnt)

		_cQuery := ""
		_cQuery += " SELECT"
		_cQuery += " DISTINCT CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL,CR_GRUPO,CR_USER, CR_APROV, CR_DTLIMIT, CR_HRLIMIT "
		_cQuery += " FROM " + RetSqlName("SCR") + " SCR"
		_cQuery += " INNER JOIN "+RetSqlName("SC1")+" SC1 ON SC1.C1_FILIAL=SCR.CR_FILIAL AND SC1.C1_NUM=SUBSTRING(CR_NUM,1,6) AND SC1.C1_APROV='L' AND SC1.C1_XFOLOW=' ' AND SC1.D_E_L_E_T_=' ' "
		_cQuery += " WHERE SCR.D_E_L_E_T_ <> '*'"
		_cQuery += " AND CR_FILIAL = '" + cFilAnt + "'"
		_cQuery += " AND CR_TIPO = 'SC'"
		_cQuery += " AND CR_WF = '2'"
		_cQuery += " ORDER BY"
		_cQuery += " CR_FILIAL,"
		_cQuery += " CR_NUM,"
		_cQuery += " CR_NIVEL,"
		_cQuery += " CR_USER"

		If Select("TMP")>0
			dbSelectArea("TMP")
			dbCloseArea()
		Endif

		_cQuery := ChangeQuery(_cQuery)

		TcQuery _cQuery New Alias "TMP"

		TMP->(dbGotop())
		While !TMP->(Eof())

			_cNum := Padr( Alltrim(TMP->CR_NUM) , TamSx3("CR_NUM")[1] )

			DBSelectArea("SC1")
			DBSetOrder(1)
			DBSeek( TMP->CR_FILIAL + PADR(ALLTRIM(TMP->CR_NUM),6) )

			Conout("["+cThread+"] - JOB workflow esta em execucao. Enviando e-mail para o solicitante, aprovação SC: "+SC1->C1_FILIAL+" - "+SC1->C1_NUM)

			_aWF := EnviaSC(TMP->CR_FILIAL, PADR(TMP->CR_NUM,TamSX3("CR_NUM")[1]) , SC1->C1_USER , TMP->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER) , TMP->CR_GRUPO , CtoD('  /  /  ') ,'     ',_nOpc)

			TMP->(DBSkip())
			_lProcesso := .T.
		END

		If Select("TMP")>0
			dbSelectArea("TMP")
			dbCloseArea()
		Endif

	CASE _nOpc == 4

		U_CONSOLE("4 - Envia resposta de solicitacao rejeitada para o comprador")
		U_CONSOLE("5 - EmpFil:" + cEmpAnt + cFilAnt)

		_cQuery := ""
		_cQuery += " SELECT"
		_cQuery += " DISTINCT CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL,CR_GRUPO,CR_USER, CR_APROV, CR_DTLIMIT, CR_HRLIMIT "
		_cQuery += " FROM " + RetSqlName("SCR") + " SCR"
		_cQuery += " INNER JOIN "+RetSqlName("SC1")+" SC1 ON SC1.C1_FILIAL=SCR.CR_FILIAL AND SC1.C1_NUM=SUBSTRING(CR_NUM,1,6) AND SC1.C1_APROV='R' AND SC1.C1_XFOLOW=' ' AND SC1.D_E_L_E_T_=' ' "
		_cQuery += " WHERE SCR.D_E_L_E_T_ <> '*'"
		_cQuery += " AND CR_FILIAL = '" + cFilAnt + "'"
		_cQuery += " AND CR_TIPO = 'SC'"
		_cQuery += " AND CR_WF = '2'"
		_cQuery += " ORDER BY"
		_cQuery += " CR_FILIAL,"
		_cQuery += " CR_NUM,"
		_cQuery += " CR_NIVEL,"
		_cQuery += " CR_USER"

		If Select("TMP")>0
			dbSelectArea("TMP")
			dbCloseArea()
		Endif

		_cQuery := ChangeQuery(_cQuery)

		TcQuery _cQuery New Alias "TMP"

		TMP->(dbGotop())
		While !TMP->(Eof())

			_cNum := Padr( Alltrim(TMP->CR_NUM) , TamSx3("CR_NUM")[1] )

			DBSelectArea("SC1")
			DBSetOrder(1)
			DBSeek( TMP->CR_FILIAL + PADR(ALLTRIM(TMP->CR_NUM),6) )

			Conout("["+cThread+"] - JOB workflow esta em execucao. Enviando e-mail para o solicitante, rejeição SC: "+SC1->C1_FILIAL+" - "+SC1->C1_NUM)

			_aWF := EnviaSC(TMP->CR_FILIAL, PADR(TMP->CR_NUM,TamSX3("CR_NUM")[1]) , SC1->C1_USER , TMP->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER) , TMP->CR_GRUPO , CtoD('  /  /  ') ,'     ',_nOpc)

			TMP->(DBSkip())
			_lProcesso := .T.
		END

		If Select("TMP")>0
			dbSelectArea("TMP")
			dbCloseArea()
		Endif

	CASE _nOpc	== 5

		U_CONSOLE("5 - Acao TimeOut")

		TimeOut()
	END CASE

	IF 	_lProcesso
		U_CONSOLE(" Mensagem processada " )
	ELSE
		U_CONSOLE(" Nao houve processamento")
	ENDIF

RETURN

/*/{Protheus.doc}''
''
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
Static Function EnviaSC(_cFilial,_cNum, _cUser, _cChave, _CRGrupo , _dDTLimit, _cHRLimit, _nOpc )
	Local nAprovs	:= 1
	Local nInd := 1
	Local aCustos  :={}
	Local aFiles   := {}

	Private aMsg   := {}

	_cHttp		:= GetNewPar("MV_WFDHTTP", "http://187.94.58.177:80/workflow")

	_nDD   	  	:= GetNewPar("MV_WFTODD", 0)		// TimeOut - Dias
	_dDataLib	:= IIF( !EMPTY(_dDTLimit), _dDTLimit, MSDATE() )
	_cHoraLib	:= IIF( !EMPTY(_cHRLimit), _cHRLimit, LEFT(TIME(),5) )
	_cTimeOut	:= GetNewPar("MV_WFTOPC","24:00")		// WF-Workflow TO-TimeOut PC-Pedido de Compras
	_nTimeOut  	:= (_nDD * 24) + VAL(LEFT(_cTimeOut,2)) + (VAL(RIGHT(_cTimeOut,2))/60)

	_cTo		:= IIF(_nOpc == 1, _cUser , UsrRetMail(_cUser))
	_cEmail		:= UsrRetMail(_cUser)

	_aTimeOut	:= U_GetTimeOut(_nTimeOut,_dDATALIB,_cHoraLib)

	_lError := .F.
	if Empty(_cTo)

		aMsg := {}
		cTitle  := "Administrador do Workflow : NOTIFICACAO"
		aADD(aMsg , REPLICATE('*',80) )
		aADD(aMsg , Dtoc(MSDate()) + " - " + Time() + ' * Ocorreu um ERRO no envio da mensagem :' )
		aADD(aMsg , "SC No: " + _cNum + " Filial : " + _cFilial + " Usuario : " + UsrRetName(_cUser) )
		aADD(aMsg , "Campo EMAIL do cadastro de usuario NAO PREENCHIDO" )
		aADD(aMsg , REPLICATE('*',80) )

		_lError := .T.
	Endif

	IF _lError
		cBody := '<html>'
		cBody += '<head>'
		cBody += '</head>'
		cBody += '<meta http-equiv="Content-Type" content="text/html;charset=windows-1252"/>'
		cBody += '<body>'
		cBody += '<div style="color:#003486;"><big><span'
		cBody += ' class="610203920-12022004"><img alt="logo" src="https://allcare.com.br/blog/wp-content/uploads/2020/11/logo-allcare-1.png"</span></big></div>'
		cBody += '<hr>'
		cBody += '<div><font color="#003486" face="Verdana"'
		cBody += ' size="3"><span class="216593018-10022004"><br>'
		For nInd := 1 TO Len(aMsg)
			cBody += '<DIV><FONT face=Verdana color=#000080 size=3><SPAN class=216593018-10022004>' + aMsg[nInd] + '</SPAN></FONT></DIV><p>'
		Next
		cBody += '<p></p>'
		cBody += '<FONT face=Arial size=1>Workflow - Serviço de Envio de Mensagens</FONT><br>'
		cBody += '</body>'
		cBody += '</html>'

		OvEnvMail( cBody , cTo , cTitle , {} )

		_aReturn := {}
		AADD(_aReturn, "")
		AADD(_aReturn, _aTimeOut[1])
		AADD(_aReturn, _aTimeOut[2])

		RETURN _aReturn
	ENDIF

	_cChaveSCR	:= _cFilial + TMP->CR_TIPO + _cNum
	_cNum 		:= PADR(ALLTRIM(_cNum),6)

	DBSelectArea("SCR")
	DBSetOrder(2)
	DBSeek(_cChave)

	DBSelectArea("SM0")
	DBSetOrder(1)
	DBSeek(cEmpAnt+cFilAnt)

	DBSelectArea("SC1")
	DBSetOrder(1)
	DBSeek(_cFilial+_cNum)

	DBSelectArea("SA2")
	DBSetOrder(1)
	DBSeek(xFilial("SA2")+SC1->C1_FORNECE+SC1->C1_LOJA)

	DBSelectArea("SE4")
	DBSetOrder(1)
	DBSeek(xFilial("SE4")+SC1->C1_CONDPAG)

	DBSelectArea("SAL")
	DBSetOrder(3)
	DBSeek(xFilial("SAL")+SCR->CR_GRUPO+SCR->CR_APROV)

	// REFAZ O TIMEOUT CONFORME REGRA NO CADASTRO DE GRUPO DE APROVADORES
	_nDD   	  	:= GetNewPar("MV_WFTODD", 0)		// TimeOut - Dias
	_cTimeOut	:= GetNewPar("MV_WFTOPC","24:00")
	_dDataLib	:= IIF( !EMPTY(_dDTLimit), _dDTLimit, MSDATE() )
	_cHoraLib	:= IIF( !EMPTY(_cHRLimit), _cHRLimit, LEFT(TIME(),5) )
	_nTimeOut  	:= (_nDD * 24) + VAL(LEFT(_cTimeOut,2)) + (VAL(RIGHT(_cTimeOut,2))/60)
	_aTimeOut	:= U_GetTimeOut(_nTimeOut,_dDATALIB,_cHoraLib)

	DO CASE
	CASE _nOpc == 1		// Envio de email para aprovacao

		oProcess := TWFProcess():New( "000001", "Envio Aprovacao SC :" + _cFilial + "/" +  TRIM(_cNum) )
		oProcess:NewTask( "Envio SC para Aprovacao: "+_cFilial + _cNum, "\WORKFLOW\HTML\SCAPROV_SZ.HTM" )
		oProcess:cSubject := "Aprovação da Solicitação de Compra " + _cFilial + "/" +  _cNum
		oProcess:bReturn  := "U_WFPC(2)"
		//oProcess:bTimeOut 	:= { { "U_WFPC(5)", _nDD, nHH, nMM } }
		//oProcess:attachfile(cAttachFile)

	CASE _nOpc == 3		// Envio de email Aprovacao para solicitante
		oProcess := TWFProcess():New( "000003", "Envio p/comprador SC Aprovada : " + _cFilial + "/" +  TRIM(_cNum) )
		oProcess:NewTask( "Envio SC Aprovada : "+_cFilial + _cNum, "\WORKFLOW\HTML\SCRESP_SZ.HTM" )
		oProcess:cSubject := "Solicitação de Compra Aprovada " + _cFilial + "/" +  _cNum
		_cResposta := " A P R O V A D O "

	CASE _nOpc == 4		// Envio de email Reprovado para solicitante
		oProcess := TWFProcess():New( "000004", "Envio p/comprador SC Reprovada : " + _cFilial + "/" +  TRIM(_cNum) )
		oProcess:NewTask( "Envio SC reprovada : "+_cFilial + _cNum, "\WORKFLOW\HTML\SCRESP_SZ.HTM" )
		oProcess:cSubject := "Solicitação de Compra Reprovada " + _cFilial + "/" +  _cNum
		_cResposta := "<font color='#FF0000'>R E P R O V A D O </font>"

	ENDCASE

	oProcess:cTo := ''
	oProcess:UserSiga := _cUser
	oProcess:NewVersion(.T.)

	oHtml := oProcess:oHTML

	IF _nOpc == 1
		// Hidden Fields
		oHtml:ValByName( "OBS"		   , "" )
		oHtml:ValByName( "CR_USER"		, UsrFullName(_cUser))
		oHtml:ValByName( "CHAVE"	   , _cChave)
		oHtml:ValByName( "CFILANT"	   , _cFilial)
		oHtml:ValByName( "WFID"		   , oProcess:fProcessId)
	ENDIF

	IF _nOpc == 3 .OR. _nOpc == 4
		oHtml:ValByName( "mensagem" ,  AllTrim(EnCodeUtf8(SCR->CR_OBS)) )
	ENDIF

	oHtml:ValByName( "C1_NUM"		, SC1->C1_NUM )
	oHtml:ValByName( "CEMPANT"		, SM0->M0_NOME )
	oHtml:ValByName( "C1_FILIAL"	, SM0->M0_FILIAL )
	oHtml:ValByName( "C1_EMISSAO"	, DTOC(SC1->C1_EMISSAO) )
	oHtml:ValByName( "C1_USER"		, UsrFullName(SC1->C1_USER))
	oHtml:ValByName( "A2_NOME"		, "[" + SA2->A2_COD + "-" + SA2->A2_LOJA + "]" + SA2->A2_NOME)

	asc1:={}
	cMailsRM := ""

	While !SC1->(EOF()) .AND. SC1->C1_FILIAL == _cFilial .AND. SC1->C1_NUM == _cNum

		If !Empty(SC1->C1_CC) .And. SC1->C1_RATEIO<>"1"
			dbSelectArea("DBL")
			dbSetOrder(1)
			If dbSeek( xFilial("DBL") + _CRGrupo )

				While DBL->(!Eof()) .And. Alltrim(DBL->DBL_GRUPO)==Alltrim(_CRGrupo)

					If Alltrim(SC1->C1_CC)==Alltrim(DBL->DBL_CC)
						If ( (_nOpc==1 .And. SC1->C1_APROV=="B") .Or. (_nOpc==4 .And. SC1->C1_APROV=="R") .Or. (_nOpc==3 .And. SC1->C1_APROV=="L")  )

							dbSelectArea("CTT")
							dbSetOrder(1)
							dbSeek( xFilial("CTT") + SC1->C1_CC )

							//cMailsRM += Alltrim(CTT->CTT_XMAIL)+";"

							AAdd( (oHtml:ValByName( "t.1"    )), SC1->C1_ITEM)
							AAdd( (oHtml:ValByName( "t.2"    )), SC1->C1_PRODUTO + " - " +Alltrim( SC1->C1_DESCRI )  )
							AAdd( (oHtml:ValByName( "t.3"    )), TRANSFORM(SC1->C1_QUANT,'@E 9,999,999.99'))
							AAdd( (oHtml:ValByName( "t.4"    )), SC1->C1_UM)
							AAdd( (oHtml:ValByName( "t.5"    )), Alltrim(SC1->C1_CC)       )
							AAdd( (oHtml:ValByName( "t.6"    )), Alltrim(CTT->CTT_DESC01)  )
							AAdd( (oHtml:ValByName( "t.7"    )), Alltrim(SC1->C1_OBS)      )
							AAdd( (oHtml:ValByName( "t.8"    )), DTOC(SC1->C1_DATPRF)      )
							AAdd( (oHtml:ValByName( "t.9"    )), TRANSFORM(SC1->C1_VUNIT , "@E 9,999,999.99" ) )

							if  (_nOpc==1 .And. SC1->C1_APROV=="B")
								AAdd( (oHtml:ValByName( "t.10"   )), SC1->C1_ITEM )
							endif

							aAdd(asc1,{;
								SC1->C1_ITEM,;
								SC1->C1_PRODUTO + " - " +  Alltrim( SC1->C1_DESCRI ),;
								TRANSFORM(SC1->C1_QUANT,'@E 9,999,999.99'),;
								SC1->C1_UM,;
								Alltrim(SC1->C1_CC),;
								Alltrim(CTT->CTT_DESC01),;
								Alltrim(SC1->C1_OBS),;
								DTOC(SC1->C1_DATPRF),;
								TRANSFORM(SC1->C1_VUNIT , "@E 9,999,999.99" )})
						Endif

						Reclock("SC1",.F.)
						SC1->C1_WF      := Alltrim(Str(_nOpc))
						If (_nOpc==4 .And. SC1->C1_APROV=="R") .Or. (_nOpc==3 .And. SC1->C1_APROV=="L")
							SC1->C1_XFOLOW  := "S"
						Endif
						MsUnlock()

						If aScan(aCustos,Alltrim(SC1->C1_CC))==0
							aAdd(aCustos,Alltrim(SC1->C1_CC))
						Endif


					Endif
					DBL->(dbSkip())
				End
			Endif

		Elseif Empty(SC1->C1_CC) .And. SC1->C1_RATEIO=="1"

			dbSelectArea("SCX")
			dbSetOrder(1)
			If dbSeek( SC1->C1_FILIAL + SC1->C1_NUM + SC1->C1_ITEM )

				While SCX->(!Eof()) .And. SCX->(CX_FILIAL+CX_SOLICIT+CX_ITEMSOL)==SC1->(C1_FILIAL+C1_NUM+C1_ITEM)

					dbSelectArea("DBL")
					dbSetOrder(1)
					If dbSeek( xFilial("DBL") + _CRGrupo )
						While DBL->(!Eof()) .And. Alltrim(DBL->DBL_GRUPO)==Alltrim(_CRGrupo)

							If Alltrim(SCX->CX_CC)==Alltrim(DBL->DBL_CC)
								If ( (_nOpc==1 .And. SC1->C1_APROV=="B") .Or. (_nOpc==4 .And. SC1->C1_APROV=="R") .Or. (_nOpc==3 .And. SC1->C1_APROV=="L")  )

									dbSelectArea("CTT")
									dbSetOrder(1)
									dbSeek( xFilial("CTT") + SCX->CX_CC )

									cMailsRM += Alltrim(CTT->CTT_XMAIL)+";"

									AAdd( (oHtml:ValByName( "t.1"    )), SC1->C1_ITEM)
									AAdd( (oHtml:ValByName( "t.2"    )), SC1->C1_PRODUTO + " - " +Alltrim( SC1->C1_DESCRI )  )
									AAdd( (oHtml:ValByName( "t.3"    )), TRANSFORM(SC1->C1_QUANT,'@E 9,999,999.99'))
									AAdd( (oHtml:ValByName( "t.4"    )), SC1->C1_UM)
									AAdd( (oHtml:ValByName( "t.5"    )), Alltrim(SCX->CX_CC)       )
									AAdd( (oHtml:ValByName( "t.6"    )), Alltrim(CTT->CTT_DESC01)  )
									AAdd( (oHtml:ValByName( "t.7"    )), Alltrim(SC1->C1_OBS)      )
									AAdd( (oHtml:ValByName( "t.8"    )), DTOC(SC1->C1_DATPRF)      )
									AAdd( (oHtml:ValByName( "t.9"    )), TRANSFORM(SC1->C1_VUNIT , "@E 9,999,999.99" ) )

									if  (_nOpc==1 .And. SC1->C1_APROV=="B")
										AAdd( (oHtml:ValByName( "t.10"   )), SC1->C1_ITEM )
									endif

									aAdd(asc1,{;
										SC1->C1_ITEM,;
										SC1->C1_PRODUTO + " - " +  Alltrim( SC1->C1_DESCRI ),;
										TRANSFORM(SC1->C1_QUANT,'@E 9,999,999.99'),;
										SC1->C1_UM,;
										Alltrim(SCX->CX_CC),;
										Alltrim(CTT->CTT_DESC01),;
										Alltrim(SC1->C1_OBS),;
										DTOC(SC1->C1_DATPRF),;
										TRANSFORM(SC1->C1_VUNIT , "@E 9,999,999.99" )})

								Endif

								Reclock("SC1",.F.)
								SC1->C1_WF := Alltrim(Str(_nOpc))
								If (_nOpc==4 .And. SC1->C1_APROV=="R") .Or. (_nOpc==3 .And. SC1->C1_APROV=="L")
									SC1->C1_XFOLOW  := "S"
								Endif
								MsUnlock()

								If aScan(aCustos,Alltrim(SCX->CX_CC))==0
									aAdd(aCustos,Alltrim(SCX->CX_CC))
								Endif
							Endif
							DBL->(dbSkip())
						End
					Endif
					SCX->(dbSkip())
				End
			Endif
		Endif
		SC1->(dbSkip())
	End

	if _nOpc==1
		aAprovs := {}
		DBSelectarea("SCR")
		DBSetOrder(2)
		If DBSeek(_cChaveSCR)
			While !SCR->(EOF()) .AND. SCR->(CR_FILIAL+CR_TIPO+CR_NUM) == _cChaveSCR

				lCusto := .F.

				dbSelectArea("DBL")
				dbSetOrder(1)
				If dbSeek( xFilial("DBL") + SCR->CR_GRUPO )
					While DBL->(!Eof()) .And. Alltrim(DBL->DBL_GRUPO)==Alltrim(SCR->CR_GRUPO)
						If aScan(aCustos,Alltrim(DBL->DBL_CC)) > 0
							lCusto := .T.
						Endif
						DBL->(dbSkip())
					End
				Endif
				if lCusto
					If aScan(aAprovs,{ |x| Alltrim(x[1])==Alltrim(SCR->CR_USER) } )==0
						aAdd(aAprovs , { Alltrim(SCR->CR_USER),SCR->CR_STATUS,SCR->CR_USERLIB,SCR->CR_DATALIB,SCR->CR_OBS })
					Endif
				Endif
				SCR->(DBSkip())
			End
		Endif

		For nAprovs := 1 To Len(aAprovs)
			cSituaca := ""
			Do Case
			Case aAprovs[nAprovs][2] == "01"
				cSituaca := "Aguardando"
			Case aAprovs[nAprovs][2] == "02"
				cSituaca := "Em Aprovacao"
			Case aAprovs[nAprovs][2] == "03"
				cSituaca := Iif(_nOpc == 3,"Aprovado","Reprovado")
			Case aAprovs[nAprovs][2] == "04"
				cSituaca := "Bloqueado"
			Case SCR->CR_STATUS == "05"
				cSituaca := Iif(_nOpc == 3,"Nivel Liberado","Nivel Bloqueado")
			EndCase

			_cT4 := UsrRetName(aAprovs[nAprovs][3])
			_cT6 := Alltrim(EncodeUtf8(aAprovs[nAprovs][5]))

			AAdd( (oHtml:ValByName( "ta.2"    )), Alltrim( UsrFullName(aAprovs[nAprovs][1]) )  )
			AAdd( (oHtml:ValByName( "ta.3"    )), cSituaca    )
			AAdd( (oHtml:ValByName( "ta.4"    )), IIF(EMPTY(_cT4),"", _cT4))
			AAdd( (oHtml:ValByName( "ta.5"    )), DTOC(aAprovs[nAprovs][4]))
			AAdd( (oHtml:ValByName( "ta.6"    )), IIF(EMPTY(_cT6),"", _cT6))
		Next
	Endif



	_aReturn := {}
	AADD(_aReturn, oProcess:fProcessId)
	AADD(_aReturn, _aTimeOut[3])
	AADD(_aReturn, _aTimeOut[4])
	oHtml:ValByName( "data_hora" , DTOC(MSDATE()) + " as " + LEFT(TIME(),5) )
	oProcess:nEncodeMime := 0

	DO CASE
	CASE _nOpc == 1
		cProcess := oProcess:Start("\workflow\wfsc\")

		cSubject    := Alltrim(SM0->M0_NOME)+" - Aprovar a Solicitação de Compra No. " + _cNum

		aMsg := {}
		aaDD(aMsg, "Sr. Aprovador,")
		aaDD(aMsg, "<br></br>")
		AADD(aMsg, 'A <a href="' + _cHttp + '/wfsc/'  + alltrim(cProcess) + '.htm"> Solicitação de Compra No.: ' + _cNum + '</a> da filial: ' + Alltrim(SM0->M0_FILIAL) + ' aguarda seu parecer.')
		aaDD(aMsg, "<br></br>")
		aaDD(aMsg, "<br></br>")

		cBody := '<html>'
		cBody += '<meta http-equiv="Content-Type" content="text/html;charset=windows-1252"/>'
		cBody += '<head>'
		cBody += '</head>'
		cBody += '<body>'
		cBody += '<div style="color:#003486;"><big><span'
		cBody += ' class="610203920-12022004"><img alt="logo" src="https://allcare.com.br/blog/wp-content/uploads/2020/11/logo-allcare-1.png"</span></big></div>'
		cBody += '<hr>'
		cBody += '<div><font color="#003486" face="Verdana"'
		cBody += ' size="3"><span class="216593018-10022004"><br>'
		For nInd := 1 TO Len(aMsg)
			cBody += '<DIV><FONT face=Verdana color=#000080 size=3><SPAN class=216593018-10022004>' + aMsg[nInd] + '</SPAN></FONT></DIV><p>'
		Next
		cBody += '<p></p>'
		cBody += '<FONT face=Arial size=1>Workflow - Serviço de Envio de Mensagens</FONT><br>'
		cBody += '</body>'
		cBody += '</html>'

		OvEnvMail(cBody,_cEmail,cSubject,aFiles)

	CASE _nOpc == 3
		cProcess := oProcess:Start("\workflow\wfsc\")

		cSubject    := Alltrim(SM0->M0_NOME)+" - Solicitação de Compra No. " + _cNum + " aprovada."

		aMsg := {}
		aaDD(aMsg, "Sr. Solicitante,")
		aaDD(aMsg, "<br></br>")
		AADD(aMsg, 'A <a href="' + _cHttp + '/wfsc/'  + alltrim(cProcess) + '.htm"> Solicitação de Compra No.: ' + _cNum + '</a> da filial: ' + Alltrim(SM0->M0_FILIAL) + ' foi aprovada.')
		aaDD(aMsg, "<br></br>")
		aaDD(aMsg, "<br></br>")

		cBody := '<html>'
		cBody += '<meta http-equiv="Content-Type" content="text/html;charset=windows-1252"/>'
		cBody += '<head>'
		cBody += '</head>'
		cBody += '<body>'
		cBody += '<div style="color:#003486;"><big><span'
		cBody += ' class="610203920-12022004"><img alt="logo" src="https://allcare.com.br/blog/wp-content/uploads/2020/11/logo-allcare-1.png"</span></big></div>'
		cBody += '<hr>'
		cBody += '<div><font color="#003486" face="Verdana"'
		cBody += ' size="3"><span class="216593018-10022004"><br>'
		For nInd := 1 TO Len(aMsg)
			cBody += '<DIV><FONT face=Verdana color=#000080 size=3><SPAN class=216593018-10022004>' + aMsg[nInd] + '</SPAN></FONT></DIV><p>'
		Next
		cBody += '<p></p>'
		cBody += '<FONT face=Arial size=1>Workflow - Serviço de Envio de Mensagens</FONT><br>'
		cBody += '</body>'
		cBody += '</html>

		OvEnvMail(cBody,_cEmail,cSubject,aFiles)

	CASE _nOpc == 4
		cProcess := oProcess:Start("\workflow\wfsc\")

		cSubject    := Alltrim(SM0->M0_NOME)+" - Solicitação de Compra No. " + _cNum + " reprovada."

		aMsg := {}
		aaDD(aMsg, "Sr. Solicitante,")
		aaDD(aMsg, "<br></br>")
		AADD(aMsg, 'A <a href="' + _cHttp + '/wfsc/'  + alltrim(cProcess) + '.htm"> Solicitação de Compra No.: ' + _cNum + '</a> da filial: ' + Alltrim(SM0->M0_FILIAL) + ' foi reprovada.')
		aaDD(aMsg, "<br></br>")
		aaDD(aMsg, "<br></br>")

		cBody := '<html>'
		cBody += '<meta http-equiv="Content-Type" content="text/html;charset=windows-1252"/>'
		cBody += '<head>'
		cBody += '</head>'
		cBody += '<body>'
		cBody += '<div style="color:#003486;"><big><span'
		cBody += ' class="610203920-12022004"><img alt="logo" src="https://allcare.com.br/blog/wp-content/uploads/2020/11/logo-allcare-1.png"</span></big></div>'
		cBody += '<hr>'
		cBody += '<div><font color="#003486" face="Verdana"'
		cBody += ' size="3"><span class="216593018-10022004"><br>'
		For nInd := 1 TO Len(aMsg)
			cBody += '<DIV><FONT face=Verdana color=#000080 size=3><SPAN class=216593018-10022004>' + aMsg[nInd] + '</SPAN></FONT></DIV><p>'
		Next
		cBody += '<p></p>'
		cBody += '<FONT face=Arial size=1>Workflow - Serviço de Envio de Mensagens</FONT><br>'
		cBody += '</body>'
		cBody += '</html>

		OvEnvMail(cBody,_cEmail,cSubject,aFiles)

	OTHERWISE

		oProcess:Start()

	END CASE

Return _aReturn

/*/{Protheus.doc}'TimeOut'
'Gravar timeout das solicitaï¿½ï¿½es nï¿½o aprovadas enviando e-mail de notificaï¿½ï¿½o'
@author Ovio COnsultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/

Static Function TimeOut()
	Local _cQuery
	Local nInd

	_cQuery := ""
	_cQuery += " SELECT DISTINCT "
	_cQuery += " C1_USER, "
	_cQuery += " C1_FILIAL, "
	_cQuery += " C1_NUM, "
	_cQuery += " C1_FORNECE, "
	_cQuery += " C1_LOJA, "
	_cQuery += " C1_EMISSAO,"
	_cQuery += " C1_APROV,"
	_cQuery += " CR_FILIAL, "
	_cQuery += " CR_TIPO,"
	_cQuery += " CR_NUM,"
	_cQuery += " CR_NIVEL,"
	_cQuery += " CR_USER,"
	_cQuery += " CR_APROV,"
	_cQuery += " CR_TOTAL,"
	_cQuery += " CR_DTLIMIT,"
	_cQuery += " CR_HRLIMIT"
	_cQuery += " FROM " + RetSqlName("SCR") + " SCR"
	_cQuery += " JOIN " + RetSqlName("SC1") + " SC1 ON (C1_FILIAL = '" + xFilial('SC1') + "' AND C1_NUM = LEFT(CR_NUM,6) AND C1_APROV = 'B' AND SC1.D_E_L_E_T_ = ' ' )"
	_cQuery += " WHERE SCR.D_E_L_E_T_ = ' '"
	_cQuery += " AND CR_STATUS 	= '02'"
	_cQuery += " AND CR_TIPO 	= 'SC'"
	_cQuery += " AND CR_DTLIMIT  <= '" + DTOS(MSDATE()) + "'"
	_cQuery += " AND CR_WF 	= '1'"
	_cQuery += " AND CR_WFID <> ' '"
	_cQuery += " ORDER BY"
	_cQuery += " C1_USER,"
	_cQuery += " CR_DTLIMIT,"
	_cQuery += " CR_HRLIMIT"

	If Select("TMP")>0
		dbSelectArea("TMP")
		dbCloseArea()
	Endif

	TcQuery _cQuery New Alias "TMP"

	TMP->(dbGotop())

	IF !TMP->(Eof())
		_cUser		:= ""
		_cTimeOut	:= GetNewPar("MV_WFTOPC","24:00")

		While !TMP->(Eof())

			IF TMP->CR_DTLIMIT == DTOS(MSDATE())
				IF TMP->CR_HRLIMIT  >  LEFT(TIME(),5)
					TMP->(DBSkip())
					LOOP
				ENDIF
			ENDIF

			IF _cUser <> TMP->C1_USER
				_cUser 		:= TMP->C1_USER
				_aReg	 	:= {}
			ENDIF

			_nDD   	  	:= GetNewPar("MV_WFTODD", 0)		// TimeOut - Dias
			_cTimeOut	:= _cTimeOut
			_nTimeOut  	:= (_nDD * 24) + VAL(LEFT(_cTimeOut,2)) + (VAL(RIGHT(_cTimeOut,2))/60)
			_aTimeOut	:= U_GetTimeOut(_nTimeOut, StoD(TMP->CR_DTLIMIT),TMP->CR_HRLIMIT)

			DBSelectArea("SCR")
			DBSetOrder(2)
			DBSeek(TMP->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER))
			IF FOUND()
				RECLOCK("SCR",.F.)
				SCR->CR_DTLIMIT	:= _aTimeOut[1]
				SCR->CR_HRLIMIT	:= _aTimeOut[2]
				MSUNLOCK()
			ENDIF

			AADD( _aReg, {;
				TMP->C1_FILIAL + "-" +TMP->C1_NUM, ;
				DTOC(STOD(TMP->C1_EMISSAO)), ;
				TMP->C1_FORNECE, ;
				DTOC(STOD(TMP->CR_DTLIMIT)) + '-' + TMP->CR_HRLIMIT, ;
				TMP->CR_NIVEL, ;
				UsrRetName(TMP->CR_USER),;
				UsrRetMail(TMP->CR_USER)})

			cTo		:= UsrRetMail(TMP->CR_USER)

			cTitle	:= "TimeOut Solicitação de Compra No." + TMP->C1_FILIAL+"-"+TMP->C1_NUM

			aMsg := {}
			aaDD(aMsg, Dtoc(MSDate()) + " - " + Time() + " * Notificado o usuario solicitante " + UsrRetName(_cUser))
			aaDD(aMsg, " que a aprovacao desta solicitação de compra excedeu o tempo as " +DTOC(STOD(TMP->CR_DTLIMIT)) + '-' + TMP->CR_HRLIMIT + ".")

			cBody := '<html>'
			cBody += '<head>'
			cBody += '<meta http-equiv="Content-Type" content="text/html;charset=windows-1252"/>'
			cBody += '</head>'
			cBody += '<body>'
			cBody += '<div style="color:#003486;"><big><span'
			cBody += ' class="610203920-12022004"><img alt="logo" src="https://allcare.com.br/blog/wp-content/uploads/2020/11/logo-allcare-1.png"</span></big></div>'
			cBody += '<hr>'
			cBody += '<div><font color="#003486" face="Verdana"'
			cBody += ' size="3"><span class="216593018-10022004"><br>'
			For nInd := 1 TO Len(aMsg)
				cBody += '<DIV><FONT face=Verdana color=#000080 size=3><SPAN class=216593018-10022004>' + aMsg[nInd] + '</SPAN></FONT></DIV><p>'
			Next
			cBody += '<p></p>'
			cBody += '<FONT face=Arial size=1>Workflow - Serviço de Envio de Mensagens</FONT><br>'
			cBody += '</body>'
			cBody += '</html>'

			OvEnvMail(cBody,cTo,cTitle,aFiles)

			dbSelectArea("TMP")
			DBSkip()

			IF (TMP->(EOF()) .OR. _cUser <> TMP->C1_USER) .AND. !EMPTY(_cUser)
				TO_Notif(_cUser, _aReg)
			ENDIF
		END
	EndIf
	If Select("TMP")>0
		dbSelectArea("TMP")
		dbCloseArea()
	Endif
RETURN

/*/{Protheus.doc}'TO_Notif'
'Enviar Notificaï¿½ï¿½es '
@author Ovio COnsultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/		
Static Function TO_Notif(_cUser, _aReg)
	Local _nInd := 1
	Local aFiles := {}
	_cTo:= UsrRetMail(_cUser)

	if Empty(_cTo)

		cTitle  := "Administrador do Workflow : NOTIFICACAO"
		cBody	:= REPLICATE('*',80)
		cBody	+= Dtoc(MSDate()) + " - " + Time() + ' * Ocorreu um ERRO no envio da mensagem :'
		cBody	+= "Timeout SC - Usuario : " + UsrRetName(_cUser)
		cBody	+= "Campo EMAIL do cadastro de usuario NAO PREENCHIDO"
		cBody	+= REPLICATE('*',80)

		U_Console("TimeOutPC() - " + CHR(10) + CHR(13) + cBody)

		OvEnvMail(cBody,_cTo,cTitle,aFiles)

		RETURN
	Endif

	oProcess := TWFProcess():New( "000005", "SC-Timeout Solicitacao de Compra / " + _cUser )

	oProcess:NewTask( "Timeout de resposta SC Cod.User :"+_cUser, "\WORKFLOW\HTML\SCNotif_SZ.HTM" )
	oProcess:cSubject := OemToAnsi("Timeout Solicitação de Compra")
	oProcess:cTo := _cTo
	oProcess:UserSiga := _cUser
	oProcess:NewVersion(.T.)

	oHtml := oProcess:oHTML

	oHtml:ValByName( "USER"  	, UsrRetName(_cUser))
	oHtml:ValByName( "DATA_HORA", DTOC(MSDATE()) + ' - ' + LEFT(TIME(),5) )

	For _nInd := 1 TO Len(_aReg)

		cEmail	 := "  --  NAO INFORMADO -- "
		IF !EMPTY(_aReg[_nInd][7])
			cEmail := "<A href='mailto:" + _aReg[_nInd][7] + "'>" + _aReg[_nInd][7] + "</A>"
		ENDIF

		AAdd( (oHtml:ValByName( "t.1"    )), _aReg[_nInd][1])
		AAdd( (oHtml:ValByName( "t.2"    )), _aReg[_nInd][2])
		AAdd( (oHtml:ValByName( "t.3"    )), _aReg[_nInd][3])
		AAdd( (oHtml:ValByName( "t.4"    )), _aReg[_nInd][4])
		AAdd( (oHtml:ValByName( "t.5"    )), _aReg[_nInd][5])
		AAdd( (oHtml:ValByName( "t.6"    )), _aReg[_nInd][6])
		AAdd( (oHtml:ValByName( "t.7"    )), cEmail)

	Next

	oProcess:nEncodeMime := 0
	oProcess:Start()

Return


/*/{Protheus.doc} XMLCHKDIR
Importaï¿½ï¿½o de XML NFE
@author Lojas Economicas
@since 13/04/2010
@version V.01
@type function
/*/

Static Function OvEnvMail(cHtml,cMailsRM,cSubject,aAnexos)
	Local nI			:= 1
	Local lResult    	:= .T.
	Local cError     	:= ""
	Local cTo      		:= ""
	Local lAuth    		:= GetMv("OV_RELAUTH",,.T.)
	Local cMailConta	:= Alltrim(GetMv("OV_RELACNT",,"wfecoprotheus@gmail.com"))
	Local cMailServer	:= Alltrim(GetMv("OV_RELSERV",,"smtp.gmail.com:587"))
	Local cMailSenha 	:= Alltrim(GetMv("OV_RELPSW",,"Protheus@2020"))
	Local cFileSrv      := "\pedidos"
	Local cAnexos		:= ""

	Default aAnexos     := {}

	cTo	:= RTrim(cMailsRM)

	If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha)

		CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lResult

		If lResult
			If lAuth
				lResult := MailAuth(cMailConta,cMailSenha)
			EndIf
			If lResult
				If Len(aAnexos)>0
					cAnexos:=''
					For nI:=1 to Len(aAnexos)
						CpyT2S( aAnexos[nI][1] , cFileSrv , .F. )
						cAnexos += If(!Empty(cAnexos),",","")+aAnexos[nI][2]
					Next
				Endif

				SEND MAIL  				;
					FROM       cMailConta	;
					TO		   cTo			;
					SUBJECT	   cSubject		;
					BODY	   cHtml		;
					ATTACHMENT cAnexos      ;
					RESULT	   lResult
				If !lResult
					GET MAIL ERROR cError
					cError := cError+".Falha no Envio do e-mail, entrar em contato com TI"
					Conout(cError)
				EndIf
			Else
				GET MAIL ERROR cError
				cError := cError+".Falha no Envio do e-mail, entrar em contato com TI"
				Conout(cError)
			Endif
		Else
			GET MAIL ERROR cError
			cError := cError+".Falha no Envio do e-mail, entrar em contato com TI"
			Conout(cError)
		Endif
	Endif

Return()
