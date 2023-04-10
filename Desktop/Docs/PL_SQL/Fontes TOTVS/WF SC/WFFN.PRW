#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NotifyAdm ºAutor  ³Ovio                º Data ³  20/20/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Utilizado para enviar qualquer notificacao ao administrador º±±
±±º          ³do Siga.     												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function Notifica(cEmail, cSubject, cMsgcompl)	
 	Local lOk := .T.

	cMsg := '<html>'
	cMsg += '<head>'
	cMsg += '</head>'
	cMsg += '<body>'
	cMsg += '<div style="color:#E6007E;"><big><span'
	cMsg += ' class="610203920-12022004"><img alt="logo" src="https://tembici.com.br/assets/img/logo/tembici-logo.png"</span><font face="Verdana"'
	cMsg += ' size="2"><big><strong><small><br>'
	cMsg += '<br>'
	cMsg += '</small><span style="color: #E6007E;">Workflow</span>'
	cMsg += '- Servi&ccedil;o Envio de Mensagens<br>'
	cMsg += '</strong></big></font></span></big></div>'
	cMsg += '<hr>'
	cMsg += '<div><font color="#000080" face="Verdana"'
	cMsg += ' size="3"><span class="216593018-10022004"><br>'
	cMsg += cMsgcompl
	cMsg += '<hr>'
	cMsg += '</body>'
	cMsg += '</html>'
//	CONNECT SMTP SERVER GetMV("MV_RELSERV") ACCOUNT GetMV("MV_RELACNT") PASSWORD GetMV("MV_RELPSW") RESULT lOk
	CONNECT SMTP SERVER GetMV("MV_WFSMTP") ACCOUNT GetMV("MV_WFACC") PASSWORD GetMV("MV_WFPASSW") RESULT lOk

	If lOk
		SEND MAIL FROM GetMV("MV_WFACC") ;
		TO cEmail ;
		SUBJECT cSubject ;
		BODY cMsg ;
		RESULT lOk

		If !lOk
			GET MAIL ERROR cError
			Help("",1,"Atencao",,cError + " " + cError ,4,5)
		Endif
	Else 
		MsgAlert("Nao foi possivel conexao com servidor de e-mail, verifique os parametros MV_WFSMTP, MV_WFPASSW e MV_MV_WFACC")
	Endif				
	Return lOk



USER FUNCTION NotifyAdm(cTo,cTitle,aMsg,aFiles )

    RETURN U_MailNotify(cTo,cTitle,aMsg,aFiles )

USER FUNCTION MailNotify(cTo, cTitle, aMsg, aFiles )
Local cBody, nInd


   conout("************* cTo"+cTo)

   conout("************* cTitle"+cTitle)
   

	cBody := '<html>'
	cBody += '<head>'
	cBody += '</head>'
	cBody += '<body>'
	cBody += '<div style="color:#E6007E;"><big><span'
	cBody += ' class="610203920-12022004"><img alt="logo" src="https://tembici.com.br/assets/img/logo/tembici-logo.png"</span></big></div>'
	cBody += '<hr>'
	cBody += '<div><font color="#E6007E" face="Verdana"'
	cBody += ' size="3"><span class="216593018-10022004"><br>'
	For nInd := 1 TO Len(aMsg)
		cBody += '<DIV><FONT face=Verdana color=#000080 size=3><SPAN class=216593018-10022004>' + aMsg[nInd] + '</SPAN></FONT></DIV><p>'
	Next
	cBody += '<p></p>'
	cBody += '<FONT face=Arial size=1>Workflow - Serviço de Envio de Mensagens</FONT><br>'
	cBody += '</body>'
	cBody += '</html>'

	conout("************* MailNotify cTo :"+cTo)
	conout("************* MailNotify cTitle :"+cTitle)
	
    ATEnvMail(cBody,cTo,cTitle,aFiles)
	
	RETURN //WFNotifyAdmin( cTo , cTitle, cBody, aFiles )
	

//---------------- RETORNO E ENVIO

User Function Ret
	U_REC({'01'})

User Function Snd
	U_SEND({'01'})

//------------------------------------------------------------------------
// ENVIO DE EMAIL
//------------------------------------------------------------------------

USER FUNCTION SEND(aParam)
	If aParam == Nil .OR. VALTYPE(aParam) == "U"
		U_CONSOLE("Parametros nao recebidos => SENDMAIL(cEmp)" )
		RETURN
	EndIf
	
	U_CONSOLE('SENDMAIL() /' + aParam[1] )
	
	WFSENDMAIL({aParam[1],"01"})
	RETURN

//------------------------------------------------------------------------
// RETORNO DO WORKFLOW
//------------------------------------------------------------------------

USER FUNCTION REC( aParam )
	IF aParam == Nil .OR. VALTYPE(aParam) == "U"
		U_CONSOLE("Parametros nao recebidos => RECMAIL()")
		RETURN
	EndIf

	PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL "01"
	
	U_CONSOLE('RECMAIL() /' + aParam[1] )
	
	IF ! U_SMTPConnect()
		U_CONSOLE("Nao foi possivel conexao SMTP" )
		RETURN
	ENDIF
	
	RESET ENVIRONMENT
	
	WFReturn({aParam[1],"01"})
	RETURN

//------------------------------------------------------------------------
// SEMAFORO
//------------------------------------------------------------------------
                    
USER FUNCTION SEMAFORO(Params)
Local nHdl 	:= 0                  
Local cFile := ""

    IF Params == Nil .OR. ! ValType(Params) $ "N|C" 
    	U_CONSOLE("SEMAFORO - Parametro invalido")
    	RETURN
    ENDIF            

	IF VALTYPE(Params) == "C"	// Quando for caracter - fecha o semaforo
		cFile := TRIM(Params) + ".LCK"
		       
		IF !FILE(cFile)
			nHdl:=MSFCREATE(cFile,0)
			fClose(nHdl)
		ENDIF
			
		While .T.
			nHdl := FOPEN(cFile , 16)
			IF nHdl > 0
			   	EXIT
			ENDIF			    
		    
			SLEEP(5000)
		END
	ENDIF
	
	IF VALTYPE(Params) == "N"	// Quando for numerico - abre o semaforo
		fClose(Params)
	ENDIF
	
	RETURN IIF(nHdl <> 0, nHdl, Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetTimeOut                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
User function GetTimeOut(nTimeOut,dData, cHora)
Local cQuery := ""
                  
IF dData == Nil
	dData	:= MSDATE()
ENDIF
IF cHora == Nil
	cHora	:= TIME()
ENDIF
IF nTimeOut == Nil
	nTimeOut:= 24
ENDIF

cHoraI 	:= GetNewPar("MV_WFHORAI","08:00")
cHoraF  := GetNewPar("MV_WFHORAF","18:00")

nHora	:= Val(Left(cHora,2))  + Val(Substr(cHora,4,2))/60
nHoraI  := Val(Left(cHoraI,2)) + Val(Substr(cHoraI,4,2))/60
nHoraF  := Val(Left(cHoraF,2)) + Val(Substr(cHoraF,4,2))/60

IF nHora<=nHoraI  
	nHora	:= nHoraI 
ENDIF                
  
dDtVld := dData
While .T.
	IF (nHora + nTimeOut) <= nHoraF
		nHora	:= nHora + nTimeOut
		EXIT
	ENDIF
	nTimeOut	:= nTimeOut - (nHoraF - nHora)
	nHora		:= nHoraI

	dDtVld		:= dDtVld + 1     
	dDtVld		:= DataValida(dDtVld,.T.)
END

return {dData,cHora,dDtVld, ALLTRIM(STRZERO(int(nHora),2)) + ":" + ALLTRIM(STRZERO((nHora - Int(nHora)) * 60,2))}


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MAAlcDoc Autor ³ Aline Correa do Vale   ³  Data ³07.08.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controla a alcada dos documentos (SCS-Saldos/SCR-Bloqueios)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MAAlcDoc(ExpA1,ExpD1,ExpN1,ExpC1)                     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com informacoes do documento                 ³±±
±±³          ³       [1] Numero do documento                              ³±±
±±³          ³       [2] Tipo de Documento                                ³±±
±±³          ³       [3] Valor do Documento                               ³±±
±±³          ³       [4] Codigo do Aprovador                              ³±±
±±³          ³       [5] Codigo do Usuario                                ³±±
±±³          ³       [6] Grupo do Aprovador                               ³±±
±±³          ³       [7] Aprovador Superior                               ³±±
±±³          ³       [8] Moeda do Documento                               ³±±
±±³          ³       [9] Taxa da Moeda                                    ³±±
±±³          ³      [10] Data de Emissao do Documento                     ³±±
±±³          ³      [11] Grupo de Compras                                 ³±±
±±³          ³ ExpD1 = Data de referencia para o saldo                    ³±±
±±³          ³ ExpN1 = Operacao a ser executada                           ³±±
±±³          ³       1 = Inclusao do documento                            ³±±
±±³          ³       2 = Estorno do documento                             ³±±
±±³          ³       3 = Exclusao do documento                            ³±±
±±³          ³       4 = Aprovacao do documento                           ³±±
±±³          ³       5 = Estorno da Aprovacao                             ³±±
±±³          ³       6 = Bloqueio Manual da Aprovacao                     ³±±
±±³          ³ ExpC1 = Respondido a 1 Vez ou a 2						  		  ³±±
±±³          ³ ExpB1 = Chamado via Menu do Sistema .T. or .F.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MAAlcDoc(aDocto,dDataRef,nOper, lTimeOut)
	Local cDocto	:= aDocto[1]
	Local cTipoDoc	:= aDocto[2]
	Local nValDcto	:= aDocto[3]
	Local cAprov	:= If(aDocto[4]==Nil,"",aDocto[4])
	Local cUsuario	:= If(aDocto[5]==Nil,"",aDocto[5])
	Local nMoeDcto	:= If(Len(aDocto)>7,If(aDocto[8]==Nil, 1,aDocto[8]),1)
	Local nTxMoeda	:= If(Len(aDocto)>8,If(aDocto[9]==Nil, 0,aDocto[9]),0)
	Local aArea		:= GetArea()
	Local aAreaSCS  := SCS->(GetArea())
	Local aAreaSCR  := SCR->(GetArea())
	Local nSaldo	:= 0
	Local cGrupo	:= If(aDocto[6]==Nil,"",aDocto[6])
	Local lFirstNiv:= .T.
	Local cAuxNivel:= ""
	Local cNextNiv := ""
	Local lAchou	:= .F.
	Local nRec		:= 0
	Local lRetorno	:= .T.
	Local aSaldo	:= {}
	Local nAprov	:= 0
	Local aAprov	:= {}
	dDataRef 	:= dDataBase
	cDocto 		:= cDocto+Space(Len(SCR->CR_NUM)-Len(cDocto))
	lTimeOut	:= IF(lTimeOut==Nil, .F. , lTimeOut)

	//CHKFile("SC1")
	//CHKFile("SAK")
	//CHKFile("SC7")
	//CHKFile("SCR")
	//CHKFile("SCS")
	//CHKFile("SAL")
			
	If Empty(cUsuario) .And. (nOper != 1 .And. nOper != 6) //nao e inclusao ou estorno de liberacao
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSeek(xFilial()+cAprov)
		cUsuario :=	AK_USER
		nMoeDcto :=	AK_MOEDA
		nTxMoeda	:=	0
	EndIf
	If nOper == 1  //Inclusao do Documento
		cGrupo := If(!Empty(aDocto[6]),aDocto[6],cGrupo)
		dbSelectArea("SAL")
		dbSetOrder(2)
		If !Empty(cGrupo) .And. dbSeek(xFilial()+cGrupo)
			While !Eof() .And. xFilial("SAL")+cGrupo == AL_FILIAL+AL_COD
	  		 	If SAL->AL_AUTOLIM == "S" .And. !MaAlcLim(SAL->AL_APROV,nValDcto,nMoeDcto,nTxMoeda) .AND. !EMPTY(cWF)
					dbSelectArea("SAL")
					dbSkip()
					Loop
				EndIf
				If lFirstNiv
					cAuxNivel := SAL->AL_NIVEL
					lFirstNiv := .F.
				EndIf
				Reclock("SCR",.T.)
				SCR->CR_FILIAL	:= xFilial("SCR")
				SCR->CR_NUM		:= cDocto
				SCR->CR_TIPO	:= cTipoDoc
				SCR->CR_NIVEL	:= SAL->AL_NIVEL
				SCR->CR_USER	:= SAL->AL_USER
				SCR->CR_APROV	:= SAL->AL_APROV
				SCR->CR_STATUS	:= IIF(SAL->AL_NIVEL == cAuxNivel,"02","01")
				SCR->CR_TOTAL	:= nValDcto
				SCR->CR_EMISSAO := aDocto[10]
		   		SCR->CR_MOEDA	:=	nMoeDcto
		    	SCR->CR_TXMOEDA := nTxMoeda
				MsUnlock()
				dbSelectArea("SAL")
				dbSkip()
			EndDo
		EndIf
		lRetorno := lFirstNiv
	EndIf
	
	If nOper == 3  //exclusao do documento
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSelectArea("SCR")
		dbSetOrder(1)
		dbSeek(xFilial("SCR")+cTipoDoc+cDocto)
		While !Eof() .And. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM == xFilial("SCR")+cTipoDoc+cDocto
			If SCR->CR_STATUS == "03"
				dbSelectArea("SAL")
				dbSetOrder(3)
				dbSeek(xFilial()+cGrupo+SAK->AK_COD)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Reposiciona o usuario aprovador.               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SAK")
				dbSeek(xFilial()+SCR->CR_LIBAPRO)
				If SAL->AL_LIBAPR == "A" .and. MaAlcLim(SAL->AL_APROV,nValDcto,nMoeDcto,nTxMoeda) 
					dbSelectArea("SCS")
					dbSetOrder(2)
					If dbSeek(xFilial()+SAK->AK_COD+DTOS(MaAlcDtRef(SCR->CR_LIBAPRO,SCR->CR_DATALIB,SCR->CR_TIPOLIM)))
						RecLock("SCS",.F.)
						SCS->CS_SALDO := SCS->CS_SALDO + SCR->CR_VALLIB
						MsUnlock()
					EndIf
				EndIf
			EndIf

			Reclock("SCR",.F.,.T.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf
	
	If nOper == 4 //Aprovacao do documento
		U_CONSOLE(" 4 -Aprovacao ")

//		dbSelectArea("SCR")
//		dbSetOrder(2)
//		dbSeek(xFilial("SCR")+cTipoDoc+cDocto+cAprov)
//		U_CONSOLE(" Linha 373 : xFilial('SCR')+cTipoDoc+cDocto+cAprov: "+xFilial("SCR")+cTipoDoc+cDocto+cAprov)
//		U_CONSOLE(" Seek SCR "+Iif(SCR->(Found()),"T","F"))
		dbSelectArea("SCS")
		dbSetOrder(2)
		aSaldo 		:= MaSalAlc(cAprov,dDataRef,.T.)
		nSaldo 		:= aSaldo[1]
		dDataRef	:= aSaldo[3]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o saldo do aprovador.                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		u_console("c A p r o v : "+cAprov)

		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSeek(xFilial()+cAprov)
		dbSelectArea("SAL")
		dbSetOrder(3)
		dbSeek(xFilial()+cGrupo+cAprov)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Libera o pedido pelo aprovador.                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SCR")
		cAuxNivel := CR_NIVEL
		U_CONSOLE(" 4 -Aprovacao - CR STATUS = 03")
		Reclock("SCR",.F.)
		CR_STATUS	:= "03"
//		CR_OBS		:= If(Len(aDocto)>10,aDocto[11],"")
		CR_DATALIB	:= dDataBase
		CR_USERLIB	:= SAK->AK_USER
		CR_LIBAPRO	:= SAK->AK_COD
		CR_VALLIB	:= nValDcto
		CR_TIPOLIM	:= SAK->AK_TIPO
		MsUnlock()
		DbSelectArea("SAL")
		DbSeek(xFilial("SAL")+cGrupo)
//		While SAL->(AL_FILIAL + AL_COD) = xFilial("SAL")+cGrupo .and. !SAL->(Eof())
//			nAprov ++		
//			Aadd(aAprov,SAL->AL_APROV)
//			SAL->(DbSkip())
//		Enddo
		
		U_CONSOLE("nValDcto  - "+Alltrim(Str(nValDcto)))
		
		dbSelectArea("SCR")
		dbSetOrder(1)
		dbSeek(xFilial("SCR")+cTipoDoc+cDocto+cAuxNivel)
		nRec := SCR->(RecNo())
		While !Eof() .And. xFilial("SCR")+cDocto+cTipoDoc == CR_FILIAL+CR_NUM+CR_TIPO
			If cAuxNivel == CR_NIVEL .And. CR_STATUS != "03" .And. SAL->AL_TPLIBER$"U "
				Exit
			EndIf
			If cAuxNivel == CR_NIVEL .And. CR_STATUS != "03" .And. SAL->AL_TPLIBER$"NP"
				Reclock("SCR",.F.)
				CR_STATUS	:= "05"
				CR_DATALIB	:= dDataBase
				CR_USERLIB	:= SAK->AK_USER
//					CR_APROV	:= cAprov
				CR_OBS		:= "aprovado por " + UsrRetName(SAK->AK_USER)
				MsUnlock()
			EndIf
		
		
			If CR_NIVEL > cAuxNivel .And. CR_STATUS != "03" .And. !lAchou
				lAchou 	:= .T.
				cNextNiv := CR_NIVEL
			EndIf
			If lAchou .And. CR_NIVEL == cNextNiv .And. CR_STATUS != "03"
				Reclock("SCR",.F.)
				CR_STATUS	:= "02"
				IF (SAL->AL_TPLIBER=="P" .AND. !lTimeOut )
					CR_STATUS	:= "05"
					CR_DATALIB	:= dDataBase
					CR_USERLIB	:= SAK->AK_USER
//						CR_APROV	:= cAprov
					CR_OBS		:= "aprovado por " + UsrRetName(SAK->AK_USER)
				ENDIF			
				MsUnlock()
			Endif
			dbSkip()
		EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Reposiciona e verifica se ja esta totalmente liberado.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    
		dbSelectArea("SCR")
		dbGoto(nRec)
		While !Eof() .And. xFilial("SCR")+cTipoDoc+cDocto == CR_FILIAL+CR_TIPO+CR_NUM
			If CR_STATUS != "03" .And. CR_STATUS != "05" 
				lRetorno := .F.
			EndIf
			dbSkip()
		EndDo

		If SAL->AL_LIBAPR == "A" .and. MaAlcLim(SAL->AL_APROV,nValDcto,nMoeDcto,nTxMoeda) .and. nAprov >= 2
			dbSelectArea("SCS")
			If dbSeek(xFilial()+cAprov+dToS(dDataRef))
				Reclock("SCS",.F.)
			Else
				Reclock("SCS",.T.)
			EndIf
			CS_FILIAL:= xFilial("SCS")
			CS_SALDO	:= CS_SALDO - nValDcto
			CS_APROV	:= cAprov
			CS_USER		:= cUsuario
			CS_MOEDA	:= nMoeDcto
			CS_DATA		:= dDataRef
			MsUnlock()
			                       
			// LIBERA OS NIVEIS SUPERIORES QUANDO FOR APROVADO COM ALÇADAS
			dbSelectArea("SCR")
			dbGoto(nRec)
			U_Console("nRec "+Alltrim(Str(nRec)))
			While !Eof() .And. xFilial("SCR")+cTipoDoc+cDocto == CR_FILIAL+CR_TIPO+CR_NUM
				U_Console("SCR->CR_USER "+SCR->CR_USER)
				U_Console("SAK->AK_USER "+SAK->AK_USER)

				U_CONSOLE("Reposiciona e verifica aAprov(len): "+Alltrim(Str(len(aAprov))))

				IF SCR->CR_USER <> SAK->AK_USER  // ADICIONADO ESTA LINHA
					RECLOCK("SCR",.F.)
					CR_STATUS	:= "05"
					CR_DATALIB	:= dDataBase
					CR_USERLIB	:= SAK->AK_USER
//					CR_APROV	:= cAprov
					CR_OBS		:= "aprovado por: " + UsrRetName(SAK->AK_USER)
					MsUnlock()
				ENDIF
				dbSkip()
			EndDo
			
			lRetorno := .T.	// LIBERA APROVACAO POIS O APROVADOR TEM SALDO PARA ISSO
		EndIf
	EndIf
	
	If nOper == 5  //Estorno da Aprovacao
		cGrupo := If(!Empty(aDocto[6]),aDocto[6],cGrupo)
		dbSelectArea("SAK")
		dbSetOrder(1)
		
		dbSelectArea("SCR")
		dbSetOrder(1)
		dbSeek(xFilial("SCR")+cTipoDoc+cDocto)
		
		nMoeDcto := SCR->CR_MOEDA
		nTxMoeda := SCR->CR_TXMOEDA
		
		While !Eof() .And. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM == xFilial("SCR")+cTipoDoc+cDocto
			If SCR->CR_STATUS == "03"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Reposiciona o usuario aprovador.               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SAK")
				dbSeek(xFilial()+SCR->CR_LIBAPRO)
		
				dbSelectArea("SAL")
				dbSetOrder(3)
				dbSeek(xFilial()+cGrupo+SAK->AK_COD)
				If SAL->AL_LIBAPR == "A" .and. MaAlcLim(SAL->AL_APROV,nValDcto,nMoeDcto,nTxMoeda) 
					dbSelectArea("SCS")
					dbSetOrder(2)
					If dbSeek(xFilial()+SAK->AK_COD+DTOS(MaAlcDtRef(SAK->AK_COD,SCR->CR_DATALIB)))
						RecLock("SCS",.F.)
						SCS->CS_SALDO := SCS->CS_SALDO + SCR->CR_VALLIB
						If SCS->CS_SALDO > SAK->AK_LIMITE
							SCS->CS_SALDO := SAK->AK_LIMITE
						EndIf
						MsUnlock()
					EndIf
				EndIf
			EndIf

			Reclock("SCR",.F.,.T.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	
		dbSelectArea("SAL")
		dbSetOrder(2)
		If !Empty(cGrupo) .And. dbSeek(xFilial()+cGrupo)
			While !Eof() .And. xFilial("SAL")+cGrupo == AL_FILIAL+AL_COD
				If SAL->AL_AUTOLIM == "S" .And. !MaAlcLim(SAL->AL_APROV,nValDcto,nMoeDcto,nTxMoeda) 
					dbSelectArea("SAL")
					dbSkip()
					Loop
				EndIf
				If lFirstNiv
					cAuxNivel := SAL->AL_NIVEL
					lFirstNiv := .F.
				EndIf
				Reclock("SCR",.T.)
				SCR->CR_FILIAL	:= xFilial("SCR")
				SCR->CR_NUM		:= cDocto
				SCR->CR_TIPO	:= cTipoDoc
				SCR->CR_NIVEL	:= SAL->AL_NIVEL
				SCR->CR_USER	:= SAL->AL_USER
				SCR->CR_APROV	:= SAL->AL_APROV
				SCR->CR_STATUS	:= IIF(SAL->AL_NIVEL == cAuxNivel,"02","01")
				SCR->CR_TOTAL	:= nValDcto
				SCR->CR_EMISSAO:= dDataRef
			   	SCR->CR_MOEDA	:=	nMoeDcto
		    	SCR->CR_TXMOEDA:= nTxMoeda
				MsUnlock()
				dbSelectArea("SAL")
				dbSkip()
			EndDo
		EndIf
		lRetorno := lFirstNiv
	EndIf
	
	If nOper == 6  //Bloqueio manual

		U_CONSOLE("  6  - Bloqueio por " + cAprov)

		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSeek(xFilial()+cAprov)
			
		dbSelectArea("SCR")
		cAuxNivel := CR_NIVEL
		
		Reclock("SCR",.F.)
		CR_STATUS   := "04"
		CR_OBS	   	:= If(Len(aDocto)>10,aDocto[11],"Reprovaçao manual")
		CR_DATALIB  := dDataBase
		CR_USERLIB	:= SAK->AK_USER
		CR_LIBAPRO	:= SAK->AK_COD
		MsUnlock()

		cNome		:= UsrRetName(SAK->AK_USER)
				
		dbSelectArea("SCR")                       
		dbSetOrder(1)
		dbSeek(xFilial("SCR")+cTipoDoc+cDocto+cAuxNivel)
		      
		nRec := RecNo()
		While !Eof() .And. xFilial("SCR")+cDocto+cTipoDoc == CR_FILIAL+CR_NUM+CR_TIPO  
		    U_CONSOLE(" 6 - Bloqueio - LOOP SCR " + CR_FILIAL+CR_NUM+CR_TIPO + CR_NIVEL + CR_STATUS )
		    
			If (CR_NIVEL==cAuxNivel .And. CR_STATUS != "04" ) 
				Reclock("SCR",.F.)
				CR_STATUS	:= "04"
				CR_DATALIB	:= dDataBase
				CR_USERLIB	:= SAK->AK_USER
				CR_OBS		:= "reprovado por " + ALLTRIM(cNome)
				MsUnlock()
			EndIf
			dbSkip()
		EndDo
		
		lRetorno := .F.
	EndIf
	
	dbSelectArea("SCR")
	RestArea(aAreaSCR)

	dbSelectArea("SCS")
	RestArea(aAreaSCS)
	RestArea(aArea) 
	Return(lRetorno)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SCAlcDoc Autor ³ Aline Correa do Vale   ³  Data ³07.08.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controla a alcada dos documentos (SCS-Saldos/SCR-Bloqueios)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SCAlcDoc(ExpA1,ExpD1,ExpN1,ExpC1)                     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com informacoes do documento                 ³±±
±±³          ³       [1] Numero do documento                              ³±±
±±³          ³       [2] Tipo de Documento                                ³±±
±±³          ³       [3] Valor do Documento                               ³±±
±±³          ³       [4] Codigo do Aprovador                              ³±±
±±³          ³       [5] Codigo do Usuario                                ³±±
±±³          ³       [6] Grupo do Aprovador                               ³±±
±±³          ³       [7] Aprovador Superior                               ³±±
±±³          ³       [8] Moeda do Documento                               ³±±
±±³          ³       [9] Taxa da Moeda                                    ³±±
±±³          ³      [10] Data de Emissao do Documento                     ³±±
±±³          ³      [11] Grupo de Compras                                 ³±±
±±³          ³ ExpD1 = Data de referencia para o saldo                    ³±±
±±³          ³ ExpN1 = Operacao a ser executada                           ³±±
±±³          ³       1 = Inclusao do documento                            ³±±
±±³          ³       2 = Estorno do documento                             ³±±
±±³          ³       3 = Exclusao do documento                            ³±±
±±³          ³       4 = Aprovacao do documento                           ³±±
±±³          ³       5 = Estorno da Aprovacao                             ³±±
±±³          ³       6 = Bloqueio Manual da Aprovacao                     ³±±
±±³          ³ ExpC1 = Observacao                						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SCAlcDoc(cFilSCR,aDocto,dDataRef,nOper, lTimeOut, cObs)
	Local cDocto	:= aDocto[1]
	Local cTipoDoc	:= aDocto[2]    
	Local nValDcto	:= aDocto[3]
	Local cAprov	:= If(aDocto[4]==Nil,"",aDocto[4])
	Local cUsuario	:= If(aDocto[5]==Nil,"",aDocto[5])
	Local nMoeDcto	:= If(Len(aDocto)>7,If(aDocto[8]==Nil, 1,aDocto[8]),1)
	Local nTxMoeda	:= If(Len(aDocto)>8,If(aDocto[9]==Nil, 0,aDocto[9]),0)
	Local aArea		:= GetArea()
	Local aAreaSCS  := SCS->(GetArea())
	Local aAreaSCR  := SCR->(GetArea())
	Local nSaldo	:= 0
	Local cGrupo	:= If(aDocto[6]==Nil,"",aDocto[6])
	Local lFirstNiv:= .T.
	Local cAuxNivel:= ""
	Local cNextNiv := ""
	Local lAchou	:= .F.
	Local nRec		:= 0
	Local lRetorno	:= .T.
	Local aSaldo	:= {}
	dDataRef 	:= dDataBase
	cDocto 		:= cDocto+Space(Len(SCR->CR_NUM)-Len(cDocto))
	lTimeOut	:= IF(lTimeOut==Nil, .F. , lTimeOut)

	//CHKFile("SC1")
	//CHKFile("SAK")
	//CHKFile("SC7")
	//CHKFile("SC1")
	//CHKFile("SCR")
	//CHKFile("SCS")
	//CHKFile("SAL")
			

	If Empty(cUsuario) .And. (nOper != 1 .And. nOper != 6) //nao e inclusao ou estorno de liberacao
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSeek(xFilial()+cAprov)
		cUsuario :=	AK_USER
		nMoeDcto :=	AK_MOEDA
		nTxMoeda	:=	0
	EndIf
	If nOper == 1  //Inclusao do Documento
		cGrupo := If(!Empty(aDocto[6]),aDocto[6],cGrupo)
		dbSelectArea("SAL")
		dbSetOrder(2)
		If !Empty(cGrupo) .And. dbSeek(xFilial()+cGrupo)
			While !Eof() .And. xFilial("SAL")+cGrupo == AL_FILIAL+AL_COD
	  		 	If SAL->AL_AUTOLIM == "S" .And. !MaAlcLim(SAL->AL_APROV,nValDcto,nMoeDcto,nTxMoeda) //.AND. !EMPTY(cWF)
					dbSelectArea("SAL")
					dbSkip()
					Loop
				EndIf
				If lFirstNiv
					cAuxNivel := SAL->AL_NIVEL
					lFirstNiv := .F.
				EndIf
				Reclock("SCR",.T.)
				SCR->CR_FILIAL	:= xFilial("SCR")
				SCR->CR_NUM		:= cDocto
				SCR->CR_TIPO	:= cTipoDoc
				SCR->CR_NIVEL	:= SAL->AL_NIVEL
				SCR->CR_USER	:= SAL->AL_USER
				SCR->CR_APROV	:= SAL->AL_APROV
				SCR->CR_STATUS	:= IIF(SAL->AL_NIVEL == cAuxNivel,"02","01")
				SCR->CR_TOTAL	:= nValDcto
				SCR->CR_EMISSAO := aDocto[10]
		   		SCR->CR_MOEDA	:=	nMoeDcto
		    	SCR->CR_TXMOEDA := nTxMoeda
				MsUnlock()
				dbSelectArea("SAL")
				dbSkip()
			EndDo
		EndIf
		lRetorno := lFirstNiv
	EndIf
	
	If nOper == 3  //exclusao do documento
		dbSelectArea("SAK")
		dbSetOrder(1)

		dbSelectArea("SCR")
		dbSetOrder(1)
		dbSeek(xFilial("SCR")+cTipoDoc+cDocto)
		While !Eof() .And. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM == xFilial("SCR")+cTipoDoc+cDocto
			If SCR->CR_STATUS == "03"
				dbSelectArea("SAL")
				dbSetOrder(3)
				dbSeek(xFilial()+cGrupo+SAK->AK_COD)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Reposiciona o usuario aprovador.               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SAK")
				dbSeek(xFilial()+SCR->CR_LIBAPRO)
				If SAL->AL_LIBAPR == "A" .and. MaAlcLim(SAL->AL_APROV,nValDcto,nMoeDcto,nTxMoeda) 
					dbSelectArea("SCS")
					dbSetOrder(2)
					If dbSeek(xFilial()+SAK->AK_COD+DTOS(MaAlcDtRef(SCR->CR_LIBAPRO,SCR->CR_DATALIB,SCR->CR_TIPOLIM)))
						RecLock("SCS",.F.)
						SCS->CS_SALDO := SCS->CS_SALDO + SCR->CR_VALLIB
						MsUnlock()
					EndIf
				EndIf
			EndIf

			dbSelectArea("SCR")
			Reclock("SCR",.F.,.T.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf
	
	If nOper == 4 //Aprovacao do documento

		U_CONSOLE(" 4 -Aprovacao ")
		
		dbSelectArea("SCS")
		dbSetOrder(2)
		aSaldo 		:= MaSalAlc(cAprov,dDataRef,.T.)
		nSaldo 		:= aSaldo[1]
		dDataRef	:= aSaldo[3]
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o saldo do aprovador.                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSeek(xFilial()+cAprov)
		dbSelectArea("SAL")
		dbSetOrder(3)
		dbSeek(xFilial()+cGrupo+cAprov)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Libera o pedido pelo aprovador.                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SCR")
		cAuxNivel := CR_NIVEL
		Reclock("SCR",.F.)
		CR_STATUS	:= "03"
		CR_OBS		:= If(Len(aDocto)>10,aDocto[11],"")
		CR_DATALIB	:= dDataBase
		CR_USERLIB	:= SAK->AK_USER
		CR_LIBAPRO	:= SAK->AK_COD
		CR_VALLIB	:= nValDcto
		CR_TIPOLIM	:= SAK->AK_TIPO
		CR_DTLIMIT  := CTOD("  /  /  ")
		CR_HRLIMIT  := "     "
    	SCR->CR_OBS := cObs
		MsUnlock()
		
		dbSelectArea("SCR")
		dbSetOrder(1)
		dbSeek(cFilSCR+cTipoDoc+cDocto+cAuxNivel)
		nRec := SCR->(RecNo())
		While !Eof() .And. cFilSCR+cDocto+cTipoDoc == CR_FILIAL+CR_NUM+CR_TIPO
			If cAuxNivel == CR_NIVEL .And. CR_STATUS != "03" .And. SAL->AL_TPLIBER$"U "
				Exit
			EndIf
			If cAuxNivel == CR_NIVEL .And. CR_STATUS != "03" .And. SAL->AL_TPLIBER$"NP"
				Reclock("SCR",.F.)
				CR_STATUS	:= "05"
				CR_DATALIB	:= dDataBase
				CR_USERLIB	:= SAK->AK_USER
				CR_APROV	:= cAprov
				MsUnlock()
				
			EndIf
			If CR_NIVEL > cAuxNivel .And. CR_STATUS != "03" .And. !lAchou     
				lAchou 	:= .T.
				cNextNiv := CR_NIVEL
			EndIf
			If lAchou .And. CR_NIVEL == cNextNiv .And. CR_STATUS != "03"
				Reclock("SCR",.F.)
				CR_STATUS	:= "02"
				IF (SAL->AL_TPLIBER=="P" .AND. !lTimeOut )
					CR_STATUS	:= "05"
					CR_DATALIB	:= dDataBase
					CR_USERLIB	:= SAK->AK_USER
					CR_APROV	:= cAprov
					CR_OBS		:= "aprovado por " + UsrRetName(SAK->AK_USER)
				ENDIF			
				MsUnlock()
			Endif
			dbSkip()
		EndDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Reposiciona e verifica se ja esta totalmente liberado.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		lRetorno := .T.
		dbSelectArea("SCR")
		dbGoto(nRec)
		While !Eof() .And. cFilSCR+cTipoDoc+cDocto == CR_FILIAL+CR_TIPO+CR_NUM
			If CR_STATUS != "03" .And. CR_STATUS != "05" 
				lRetorno := .F.
			EndIf
			dbSkip()
		EndDo

		If SAL->AL_LIBAPR == "A" .and. MaAlcLim(SAL->AL_APROV,nValDcto,nMoeDcto,nTxMoeda)
			dbSelectArea("SCS")
			If dbSeek(xFilial()+cAprov+dToS(dDataRef))
				Reclock("SCS",.F.)
			Else
				Reclock("SCS",.T.)
			EndIf
			CS_FILIAL:= xFilial("SCS")
			CS_SALDO	:= CS_SALDO - nValDcto
			CS_APROV	:= cAprov
			CS_USER		:= cUsuario
			CS_MOEDA	:= nMoeDcto
			CS_DATA		:= dDataRef
			MsUnlock()
			                       
			// LIBERA OS NIVEIS SUPERIORES QUANDO FOR APROVADO COM ALÇADAS
			dbSelectArea("SCR")
			dbGoto(nRec)
			While !Eof() .And. cFilSCR+cTipoDoc+cDocto == CR_FILIAL+CR_TIPO+CR_NUM
				IF SCR->CR_USER <> SAK->AK_USER  // ADICIONADO ESTA LINHA
					RECLOCK("SCR",.F.)
					CR_STATUS	:= "05"
					CR_DATALIB	:= dDataBase
					CR_USERLIB	:= SAK->AK_USER
					CR_APROV	:= cAprov
					CR_OBS		:= "aprovado por " + UsrRetName(SAK->AK_USER)
					MsUnlock()
				ENDIF
				dbSkip()
			EndDo
			
			lRetorno := .T.	// LIBERA APROVACAO POIS O APROVADOR TEM SALDO PARA ISSO
		EndIf
	EndIf
	
	If nOper == 5  //Estorno da Aprovacao
		cGrupo := If(!Empty(aDocto[6]),aDocto[6],cGrupo)
		dbSelectArea("SAK")
		dbSetOrder(1)
		
		dbSelectArea("SCR")
		dbSetOrder(1)
		dbSeek(xFilial("SCR")+cTipoDoc+cDocto)
		
		nMoeDcto := SCR->CR_MOEDA
		nTxMoeda := SCR->CR_TXMOEDA
		
		While !Eof() .And. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM == xFilial("SCR")+cTipoDoc+cDocto
			If SCR->CR_STATUS == "03"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Reposiciona o usuario aprovador.               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SAK")
				dbSeek(xFilial()+SCR->CR_LIBAPRO)
		
				dbSelectArea("SAL")
				dbSetOrder(3)
				dbSeek(xFilial()+cGrupo+SAK->AK_COD)
				If SAL->AL_LIBAPR == "A" .and. MaAlcLim(SAL->AL_APROV,nValDcto,nMoeDcto,nTxMoeda) 
					dbSelectArea("SCS")
					dbSetOrder(2)
					If dbSeek(xFilial()+SAK->AK_COD+DTOS(MaAlcDtRef(SAK->AK_COD,SCR->CR_DATALIB)))
						RecLock("SCS",.F.)
						SCS->CS_SALDO := SCS->CS_SALDO + SCR->CR_VALLIB
						If SCS->CS_SALDO > SAK->AK_LIMITE
							SCS->CS_SALDO := SAK->AK_LIMITE
						EndIf
						MsUnlock()
					EndIf
				EndIf
			EndIf

			DBSelectArea("SCR")
			Reclock("SCR",.F.,.T.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	
		dbSelectArea("SAL")
		dbSetOrder(2)
		If !Empty(cGrupo) .And. dbSeek(xFilial()+cGrupo)
			While !Eof() .And. xFilial("SAL")+cGrupo == AL_FILIAL+AL_COD
				If SAL->AL_AUTOLIM == "S" .And. !MaAlcLim(SAL->AL_APROV,nValDcto,nMoeDcto,nTxMoeda) 
					dbSelectArea("SAL")
					dbSkip()
					Loop
				EndIf
				If lFirstNiv
					cAuxNivel := SAL->AL_NIVEL
					lFirstNiv := .F.
				EndIf
				Reclock("SCR",.T.)
				SCR->CR_FILIAL	:= xFilial("SCR")
				SCR->CR_NUM		:= cDocto
				SCR->CR_TIPO	:= cTipoDoc
				SCR->CR_NIVEL	:= SAL->AL_NIVEL
				SCR->CR_USER	:= SAL->AL_USER
				SCR->CR_APROV	:= SAL->AL_APROV
				SCR->CR_STATUS	:= IIF(SAL->AL_NIVEL == cAuxNivel,"02","01")
				SCR->CR_TOTAL	:= nValDcto
				SCR->CR_EMISSAO:= dDataRef
			   	SCR->CR_MOEDA	:=	nMoeDcto
		    	SCR->CR_TXMOEDA:= nTxMoeda
				MsUnlock()
				dbSelectArea("SAL")
				dbSkip()
			EndDo
		EndIf
		lRetorno := lFirstNiv
	EndIf
	
	If nOper == 6  //Bloqueio manual

		U_CONSOLE("  6  - Bloqueio por " + cAprov)

		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSeek(xFilial()+cAprov)
			
		dbSelectArea("SCR")
		cAuxNivel := CR_NIVEL
		
		Reclock("SCR",.F.)
		CR_STATUS   := "04"
		CR_OBS	   	:= If(Len(aDocto)>10,aDocto[11],"Reprovaçao manual")
		CR_DATALIB  := dDataBase
		CR_USERLIB	:= SAK->AK_USER
		CR_LIBAPRO	:= SAK->AK_COD
		CR_DTLIMIT  := CTOD("  /  /  ")
		CR_HRLIMIT  := "     "
		MsUnlock()

		cNome		:= UsrRetName(SAK->AK_USER)
				
		dbSelectArea("SCR")                       
		dbSetOrder(1)
		dbSeek(xFilial("SCR")+cTipoDoc+cDocto+cAuxNivel)
		      
		nRec := RecNo()
		While !Eof() .And. xFilial("SCR")+cDocto+cTipoDoc == CR_FILIAL+CR_NUM+CR_TIPO
		    U_CONSOLE(" 6 - Bloqueio - LOOP SCR " + CR_FILIAL+CR_NUM+CR_TIPO + CR_NIVEL + CR_STATUS )
		    
			If cAuxNivel == CR_NIVEL .And. CR_STATUS != "04"
				Reclock("SCR",.F.)
				CR_STATUS	:= "05"
				CR_DATALIB	:= dDataBase
				CR_USERLIB	:= SAK->AK_USER
				CR_OBS		:= "reprovado por " + ALLTRIM(cNome)
				MsUnlock()
			EndIf
			If CR_NIVEL > cAuxNivel .And. CR_STATUS != "04" .And. !lAchou
				lAchou 	:= .T.
				cNextNiv := CR_NIVEL
			EndIf
			If lAchou .And. CR_NIVEL == cNextNiv .And. CR_STATUS != "04"
				Reclock("SCR",.F.)
				CR_STATUS	:= "05"
				CR_DATALIB	:= dDataBase
				CR_USERLIB	:= SAK->AK_USER
				CR_OBS		:= "reprovado por " + ALLTRIM(cNome)
				MsUnlock()
			Endif
			dbSkip()
		    
		EndDo
		
		lRetorno := .F.
	EndIf
	
	dbSelectArea("SCR")
	RestArea(aAreaSCR)

	dbSelectArea("SCS")
	RestArea(aAreaSCS)
	RestArea(aArea) 
	Return(lRetorno)


//---------------- TESTA SE HÁ CONEXAO COM O SERVIDOR SMTP

User Function SMTPConnect()
Local  lRet 	   := .F.
Local  lSmtpAuth   := GetMv("MV_RELAUTH",,.F.)
Static cMailConta  := NIL
Static cMailServer := NIL
Static cMailSenha  := NIL  
Static cMailCtaAut := NIL
Static lAvalMMail  := NIL
Static lAvalFiltr  := NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Obtem dados necessarios a conexao                                                |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMailConta  := If(cMailConta == NIL,GETMV("MV_WFACC"),cMailConta)
cMailServer := If(cMailServer== NIL,GETMV("MV_WFSMTP"),cMailServer)
cMailSenha  := If(cMailSenha == NIL,GETMV("MV_WFPASSW"),cMailSenha)
		
cMailCtaAut := If(cMailCtaAut == NIL,GETMV("MV_WFACC"),cMailCtaAut)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Caso nao exista conta definida, pega o proprio e-mail origem                       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( cMailCtaAut ) 
	cMailCtaAut := cMailConta
EndIf 		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia e-mail com os dados necessarios                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha) .And. !Empty(cMailCtaAut) 
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Conecta uma vez com o servidor de e-mails                                        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CONNECT SMTP SERVER cMailServer ACCOUNT cMailCtaAut PASSWORD cMailSenha RESULT lOk

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Se configurado, efetua a autenticacao                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( lSmtpAuth ) 
		lAutOk := MailAuth(cMailCtaAut,cMailSenha)
	Else
		lAutOk := .T.
	EndIf 
			
	If lOk .And. lAutOk 
		DISCONNECT SMTP SERVER
		lRet := .T.
	EndIf
EndIf
RETURN lRet

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³MONTA AS TABELAS NO BANCO A PARTIR DO ARQUIVO TEXTO CHKFILE.TXT
// INFORMAR O CONTEUDO DA SEGUINTE FORMA :
// SA1,SA2,SA3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function Tab01()

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"

cPath := AllTrim( GetSrvProfString( "StartPath","\" ) )
cPath += if( Right( cPath,1 ) == "\", "", "\" )
cParam1 := cPath + "chkfile.txt"

if !file( cParam1 )
	WFSaveFile( cParam1, "" )
end
if file( cParam1 )
	cTabela := AllTrim( WFLoadFile( cParam1 ) )
	cTabela := StrTran( cTabela, chr(13), "" )
	cTabela := StrTran( cTabela, chr(10), "" )
	aTabela   := WFTokenChar( cTabela, "," )
	for nInd := 1 to Len( aTabela )
		IF !Empty(aTabela[nInd])
			//chkfile(aTabela[nInd])
			DBSelectArea(aTabela[nInd])
			CONOUT(aTabela[nInd] + " Ok")
		ENDIF
	next
ENDIF
RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CONSOLE   ºAutor  ³Microsiga           º Data ³  Ago/2006   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³
±±º          ³
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CSU                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function Console(_ctxt)
local _ctxt

if _ctxt == NIL
	_ctxt := 'nulo'
endif

CONOUT(_cTXT)

nHdl2:= FOPEN("conout.log",2)
IIF(nHdl2 > 0,,nHdl2:=MSFCREATE("conout.log",0))
fseek(nHdl2,0,2)

_cLogBody := ''
_cLogBody += DTOC(DATE()) +" @ "+ TIME() +" "+ _cTxt + chr(13) + chr(10)
Fwrite(nHdl2,_cLogBody,len(_cLogBody))

_cLogBody := replicate('-',80) + chr(13) + chr(10)
Fwrite(nHdl2,_cLogBody,len(_cLogBody))

FCLOSE(nHdl2)
Return

/*/{Protheus.doc}''
''
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	
Static Function ATEnvMail(cHtml,cEmail,cSubject,aAnexos)
Local lResult    	:= .T.
Local cError     	:= ""
Local cTo      		:= ""  
Local lAuth    		:= .T.//GetMv("MV_RELAUTH",,.T.)
Local nTimeout		:= 240
Local cMailConta	:= "wfecoprotheus@gmail.com"
Local cMailServer	:= "smtp.gmail.com:587" 
Local cPort			:= "587"
Local cMailSenha 	:= "Protheus@2020"     
Local cUser		   	:= Left(cMailConta, At("@", cMailConta)-1)  
Local cFileSrv      := "\pedidos"
Local cAnexos		:= ""
                     
cTo	:= RTrim(cEmail) 

If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha)
	// Envia e-mail com os dados necessarios
	CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lResult
	// Autenticacao da conta de e-mail      
	If lResult
		If lAuth
			lResult := MailAuth(cMailConta,cMailSenha)
		EndIf
		If lResult
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta String com Anexos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
				//Erro no Envio do E-Mail.
				GET MAIL ERROR cError
				cError := cError+".Falha no Envio do e-mail, entrar em contato com TI" 
				ALERT(cError) 
			Else
				Aviso("Atenção","E-Mail Enviado com sucesso, verifique sua caixa de entrada",{"Ok"})
			EndIf
		Else
			//Erro na autenticacao da conta
			GET MAIL ERROR cError
			cError := cError+".Falha no Envio do e-mail, entrar em contato com TI" 
			ALERT(cError) 
		Endif
	Else
		GET MAIL ERROR cError
		cError := cError+".Falha no Envio do e-mail, entrar em contato com TI" 
		ALERT(cError) 
	Endif
Endif
  
Return()
