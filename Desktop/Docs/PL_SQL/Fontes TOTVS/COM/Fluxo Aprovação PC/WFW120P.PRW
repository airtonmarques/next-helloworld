#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WFW120P   ºAutor  ³Anderson Messias    º Data ³  18/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para disparar a aprovacao do WF           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DELTADECISAO                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User function WFW120P()

	Local nApv 		:= 1
	Local cQuery 	:= ""
	Local aGrps  	:= {}
	Local aAprvAnt 	:= {}
	Local cQryApv   := ""
	Local lAtivApr	:= GetNewPar("MV_XATVAPR",.T.)
	Local _cIPWF    := Alltrim(GetNewPar("MV_WFBRWSR","aprovacao.allcare.com.br:9897"))
	Local aGrpApv	:= {}
	Local aAprov	:= {}
	Local aItmApv	:= {}
	Local cGrpApv	:= ""
	Local __xcObs   := ""

	private oHTML,nVlrTotal,nSC7ItFrSg,nDesconto
	_nome:= ""                                  

	If Type("_lReenvio") == "U"
		_lReenvio := .F.
	EndIf        

	If !lAtivApr
		Return .T.
	EndIf	

	//Variaveis
	//Verifico se o Pedido ja foi Pré Aprovado!

	//if PdCota()

	//Verifica tabela de aprovadores do PV para disparar WF para aprovacao
	_cPC 	:= SC7->C7_NUM
	_cFilPC := SC7->C7_FILIAL
	_cTipo	:= "IP"
    

	If Select('TMPA') > 0
		TMPA->(dbCloseArea())
	EndIf

	BeginSQL Alias 'TMPA'

		SELECT C7_FILIAL, C7_NUM, C7_APROV
		FROM %Table:SC7% SC7
		WHERE SC7.%NotDel% AND C7_NUM = %Exp:_cPC% 
		AND C7_FILIAL = %Exp:_cFilPC% 
		GROUP BY C7_FILIAL, C7_NUM, C7_APROV
		ORDER BY C7_FILIAL, C7_NUM, C7_APROV

	EndSQL

	DbSelectArea("TMPA")

	Do While TMPA->(!EOF())

		aGrps	  	:= {}
		aAprvAnt 	:= {}	

		dbSelectArea("SCR")
		dbSetOrder(5)
		if dbSeek(xFilial("SCR")+"IP"+PADR( TMPA->C7_NUM, TamSx3("CR_NUM")[1])+PADR( TMPA->C7_APROV, TamSx3("CR_GRUPO")[1]))

			While !Eof() .And. Alltrim(SCR->CR_NUM)==_cPC .and. TMPA->C7_APROV == SCR->CR_GRUPO
			
				If SCR->CR_STATUS <> '02' /*.Or. ( !Empty(SCR->CR_WF) .And. !_lReenvio )*/  //Aguardando Liberacao
					SCR->(dbskip())
					Loop
				ElseIf SCR->CR_STATUS == '02' .And. !Empty(SCR->CR_WF) .And. !_lReenvio   //Aguardando Liberacao
					SCR->(dbskip())
					Loop
				Else   // Verifica se o Tipo de Aprovação é por Centro de Custo e se já houve alguma aprovação do nível e não manda de novo
					_lAprova := .F.
					//If lForApvCC .And. !_lReenvio
					If !_lReenvio
						_aAreaSCR := SCR->(GetArea())
						_xNivel := SCR->CR_NIVEL
						_xUser  := SCR->CR_USER
						_xAprov := SCR->CR_APROV //-->> DFS - Marcelo Celi - 04/02/2017
						_xGrupo	:= SCR->CR_GRUPO
						//_xItGrp	:= SCR->CR_ITGRP
						
						dbSelectArea("SCR")
						dbSetOrder(1)
						dbGoTop()
						If dbSeek(xFilial("SCR")+"IP"+PADR( _cPC, TamSx3("CR_NUM")[1] ))
							While !Eof() .And. Alltrim(SCR->CR_NUM)==_cPC .and. Alltrim(TMPA->C7_APROV) == Alltrim(SCR->CR_GRUPO) 
								//-->> DFS - Marcelo Celi - 04/02/2017                                                  
								// If SCR->CR_NIVEL <> _xNivel .Or. SCR->CR_USER == _xUser
								If SCR->CR_NIVEL <> _xNivel .Or. (SCR->CR_USER == _xUser .And. SCR->CR_APROV == _xAprov .and. SCR->CR_GRUPO == _xGrupo) //.and. SCR->CR_ITGRP == _xItGrp )
									SCR->(dbSkip())
									Loop
								EndIf
								If !Empty(SCR->CR_DATALIB)
									_lAprova := .T.
								EndIf
								SCR->(dbSkip())
							EndDo
						EndIf
						RestArea(_aAreaSCR)
					EndIf
					If _lAprova
						SCR->(dbskip())
						Loop
					EndIf
			
				endif  

				_aAreaSCR := SCR->(GetArea())

				//Busca informações dos aprovadores anteriores
					cQryApv := " SELECT CR_APROV, CR_STATUS, CR_DATALIB, CR_NIVEL, CR_USER, CR_GRUPO, R_E_C_N_O_ AS RECSCR "
				cQryApv += " FROM "+RetSqlName("SCR")+"  "
				cQryApv += " WHERE CR_NUM = '"+_cPC+"' "
				//cQryApv += " AND CR_APROV <> '"+SCR->CR_APROV+"' "
				cQryApv += " AND CR_FILIAL = '"+_cFilPC+"' "
				cQryApv += " AND CR_GRUPO = '"+TMPA->C7_APROV+"' "
				cQryApv += " AND CR_TIPO = 'IP' "
				cQryApv += " AND D_E_L_E_T_ <> '*' " 
				cQryApv += " ORDER BY CR_NIVEL,CR_DATALIB,CR_APROV "

				ChangeQuery(cQryApv) 

				If Select("TAPV") > 0
					TAPV->(dbCloseArea())
				EndIf

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryApv), "TAPV",.T.,.T.)

				dbSelectArea("TAPV")
				TAPV->(dbGotop())

				While TAPV->(!Eof())		   	                                                      

					//Ajustado para versão 12 - 07/08/2017 
					dbSelectArea("SCR")
					SCR->(dbGoto( TAPV->RECSCR ))

					Do Case
						Case TAPV->CR_STATUS == "01"                                                
						_cStatus := "Bloqueado p/ sistema"
						Case TAPV->CR_STATUS == "02"                                                
						_cStatus := "Aguardando Liberacao do usuario"
						Case TAPV->CR_STATUS== "03"                                                
						_cStatus := "Pedido Liberado"
						Case TAPV->CR_STATUS== "04"
						_cStatus := "Pedido Bloqueado pelo usuario"					   	
						Case TAPV->CR_STATUS== "05"
						_cStatus := "Nivel Liberado por outro usuario"
					End Case

					DBSelectArea("SAK")
					DBSetOrder(2)
					DBSeek(xFilial("SAK")+TAPV->CR_USER)
					_nPosApv := aScan(aAprvAnt,{|x| x[1] == SAK->AK_NOME})
					_nPosGrp := aScan(aAprvAnt,{|x| x[1] == TAPV->CR_GRUPO})

					If _nPosGrp == 0 .And. _nPosApv == 0
						AADD( aAprvAnt, {SAK->AK_NOME, Alltrim(_cStatus), SCR->CR_OBS, DTOC(STOD(TAPV->CR_DATALIB)), TAPV->CR_NIVEL, TAPV->CR_APROV, TAPV->CR_USER,TAPV->CR_GRUPO } )
					EndIf

					TAPV->(dbSkip())

				EndDo             
				RestArea(_aAreaSCR)								

				//Busca grupos de aprovacao do usuário - 21/01/2016
				aGrps := {}
				//If lApvCC .And. lForApvCC
				cQuery := " SELECT AL_COD, AL_ITEM, AL_APROV, DBL_CC
				cQuery += " FROM "+RetSqlName("SAL")+" SAL , "+RetSqlName("DBL")+" DBL "
				cQuery += " WHERE "
				cQuery += " DBL_GRUPO = AL_COD
				cQuery += " AND SAL.D_E_L_E_T_ <> '*'
				cQuery += " AND DBL.D_E_L_E_T_ <> '*'
				cQuery += " AND AL_COD = '"+TMPA->C7_APROV+"'
				cQuery += " AND AL_FILIAL = '"+xFilial("SAL")+"'

				ChangeQuery(cQuery)

				If Select("TSAL") > 0
					TSAL->(dbCloseArea())
				EndIf

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "TSAL",.T.,.T.)

				dbSelectArea("TSAL")
				TSAL->(dbGotop())

				While TSAL->(!Eof())

					AADD( aGrps, TSAL->AL_COD )

					TSAL->(dbSkip())
				EndDo
				//EndIf 

				DbSelectArea("DBL")
				DBL->(DbGoTop())
				DBL->(DbSetOrder(1))
				If DBL->(DbSeek(xFILIAL("DBL")+SCR->CR_GRUPO))
					cCCusto := DBL->DBL_CC
				Else
					cCCusto := ""
				EndIf

				_cMoeda := Alltrim(GetMV("MV_SIMB" + Alltrim(Str(SC7->C7_MOEDA)),.F.))

				//Funcao que da o Start no Workflow
				oProcess := TWFProcess():New( "000001", "ENVIO DO EMAIL - WF de Aprovação de Pedido de Compras" )
				//Funcao que busca o Modelo do HTML
				oProcess:NewTask( "000001", "\workflow\PEDCOM1.htm" )
				//Subject do Email
				oProcess:cSubject := "WF de Aprovação de Pedido de Compras "+SC7->C7_NUM	
				RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,oProcess:fProcCode,'200001')

				oProcess:bReturn := "U_DWFPC01R()"

				oProcess:fDesc := "Pedido de Compras No "+SC7->C7_NUM

				oHTML := oProcess:oHTML
				oHTML:ValByName('C7_FILIAL',SC7->C7_FILIAL + " - " + strtran( UPPER(Alltrim(FWFilialName())) ,"FILIAL","")  )
				oHTML:ValByName('C7_FORNECE',SC7->C7_FORNECE)
				oHTML:ValByName('NOME',Posicione("SA2",1,XFILIAL("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME"))
				oHTML:ValByName('C7_NUM',SC7->C7_NUM)
				oHTML:ValByName('C7_EMISSAO',SC7->C7_EMISSAO)
				oHTML:ValByName('C7_COND',SC7->C7_COND)
				oHTML:ValByName('E4_DESCRI',POSICIONE("SE4",1,xFILIAL("SE4")+SC7->C7_COND,"E4_DESCRI"))
				oHTML:ValByName('C7_MOEDA',Alltrim(Str(SC7->C7_MOEDA)) + " - " + _cMoeda)
				//oHTML:ValByName('CCUSTO',Alltrim(SC7->C7_CC) + " - " + POSICIONE("CTT",1,xFILIAL("CTT")+SC7->C7_CC,"CTT_DESC01"))

				//Posiciona no Pedido de Compra para preenchimento dos Itens
				SC7->(dbsetorder(1))
				SC7->(dbseek(xFILIAL("SC7")+_cPC))

				nVlrTotal	:= 0
				nSC7ItFrSg	:= 0
				nDesconto	:= 0
				nTotPedido 	:= 0
				cChave		:= SC7->C7_FILIAL+SC7->C7_NUM
				cComprador 	:= SC7->C7_USER
				cHtml      	:= ""
				__xcObs     := SC7->C7_XMOTALT

				While !SC7->(EOF()) .and. SC7->C7_FILIAL+SC7->C7_NUM==cChave
					cPRODUTO	:= 	SC7->C7_PRODUTO
					nContador := 0
					While !SC7->(EOF()) .and. SC7->C7_FILIAL==xFILIAL("SC7") .and. SC7->C7_NUM==_cPC .and. ;
					GrupoOk(SCR->CR_GRUPO, SC7->C7_CC, SC7->C7_CONTA, SC7->C7_ITEMCTA, SC7->C7_CLVL)
						If SC7->C7_APROV == TMPA->C7_APROV
							//SC7->C7_CC == cCCusto //.and. SC7->C7_PRODUTO==cPRODUTO 

							//If lApvCC .And. lForApvCC//Aprovao por centro de custo
							//	If Ascan( aGrps, SC7->C7_APROV ) == 0          
							//	
							//		nTotPedido +=(SC7->C7_TOTAL+SC7->C7_VALIPI)
							//		
							//		SC7->(dbSkip())
							//		Loop
							//	EndIf
							//EndIf 

							aadd((oHtml:ValByName( 'C7.ITEM' )),SC7->C7_ITEM)
							aadd((oHtml:ValByName( 'C7.PRODUTO' )),SC7->C7_PRODUTO)
							aadd((oHtml:ValByName( 'C7.DESCRI' )),SC7->C7_DESCRI)
							aadd((oHtml:ValByName( 'C7.QUANT' )),Transform(SC7->C7_QUANT,PesqPict("SC7","C7_QUANT")))
							aadd((oHtml:ValByName( 'C7.UM' )),SC7->C7_UM)
							aadd((oHtml:ValByName( 'C7.DATPRF' )),SC7->C7_DATPRF)
							aadd((oHtml:ValByName( 'C7.CUSTO' )),Posicione("CTT",1,xFilial("CTT")+SC7->C7_CC,"CTT_DESC01"))
							aadd((oHtml:ValByName( 'C7.PRECO' )),Transform(SC7->C7_PRECO,PesqPict("SC7","C7_TOTAL")))
							aadd((oHtml:ValByName( 'C7.TOTAL' )),Transform(SC7->C7_TOTAL+SC7->C7_VALIPI,PesqPict("SC7","C7_TOTAL")))
							aadd((oHtml:ValByName( 'C7.OBS' )),SC7->C7_OBSM)

							//Totais do pedido
							nVlrTotal  +=(SC7->C7_TOTAL+SC7->C7_VALIPI)
							nTotPedido +=(SC7->C7_TOTAL+SC7->C7_VALIPI)
							nSC7ItFrSg +=(SC7->C7_SEGURO+SC7->C7_VALFRE)
							nDesconto  += SC7->C7_VLDESC
							//nTotPedido +=(SC7->C7_TOTAL+SC7->C7_VALIPI)

							//Salva o ID
							WFSalvaID('SC7','C7_WFID',oProcess:fProcessID)
						EndIf
						SC7->(dbskip())
					Enddo
					SC7->(dbskip())
				Enddo   

				SC7->(dbSetorder(1))
				SC7->(dbGoTop())
				SC7->(dbseek(xFILIAL("SC7")+_cPC))

				aadd((oHtml:ValByName( "total.C7_TOTAL" )),Transform(nVlrTotal,PesqPict("SC7","C7_TOTAL")))						
				aadd((oHtml:ValByName( "total.PEDIDO" )),Transform(nTotPedido,PesqPict("SC7","C7_TOTAL")))


				For nApv := 1 To Len(aAprvAnt)
					aadd((oHtml:ValByName( 'CR.CODIGO' )),aAprvAnt[nApv][7])
					aadd((oHtml:ValByName( 'CR.USER' )),aAprvAnt[nApv][1])
					aadd((oHtml:ValByName( 'CR.NIVEL' )),aAprvAnt[nApv][5])
					aadd((oHtml:ValByName( 'CR.GRUPO' )),aAprvAnt[nApv][8])
					aadd((oHtml:ValByName( 'CR.STATUS' )),aAprvAnt[nApv][2])
					aadd((oHtml:ValByName( 'CR.DATALIB' )),aAprvAnt[nApv][4])
					aadd((oHtml:ValByName( 'CR.OBS' )),aAprvAnt[nApv][3])

				next nApv

				//oHtml:ValByName( "cItens", cHtml)

				oHtml:ValByName( "aprovacao","S" )			
				//Posiciona na tabela de aprovador
				eMail:=""

				//If SC7->C7_ORIGEM = "EICPO400"
				//	xComprador := usrRetName(SC7->C7_USER)
				//Else 
				xComprador := Posicione("SY1",3,xFILIAL("SY1")+cComprador,"Y1_NOME")
				//EndIF

				_cSolicita := ""
				xSolicita  := ""
				//Verifica se o Pedido é oriundo de uma SC - Solicitação de Compra
				If !Empty(SC7->C7_NUMSC)
					_cChvSC1 := xFilial("SC1") + SC7->C7_NUMSC + SC7->C7_ITEMSC
					dbSelectArea("SC1")
					SC1->(dbSetOrder(1))
					SC1->(dbGoTop())
					If SC1->(dbSeek(_cChvSC1))
						While !SC1->(Eof()) .And.  (SC1->(C1_FILIAL + C1_NUM + C1_ITEM) == _cChvSC1)
							If !Empty(SC1->C1_USER)
								_cSolicita := SC1->C1_USER
							EndIf
							SC1->(dbSkip())
						EndDo
					EndIf
				EndIf
				If !Empty(Alltrim(_cSolicita))
					//If SC7->C7_ORIGEM = "EICPO400" 
					//	xSolicita := usrRetName(_cSolicita)
					//Else 
					xSolicita := Posicione("SY1",3,xFILIAL("SY1")+_cSolicita,"Y1_NOME")
					//EndIF 
				EndIf

				DBSelectArea("SAK")
				DBSetOrder(2)
				DBSeek(xFilial("SAK")+SCR->CR_USER)

				eMail += USRRETMAIL(SAK->AK_USER)

				//Preenche o Aprovador e Solicitante
				oHtml:ValByName("SOLI",xSolicita)
				oHtml:ValByName("CMPR",xComprador)
				oHtml:ValByName("APROVADOR",SAK->AK_USER )

				oHtml:ValByName("OBSPED", __xcObs)

				//->> DFS - Marcelo Celi - 04/02/2017 - Considerar o codigo do aprovador na aprovação (mediante parametro).			
				//oHtml:ValByName("APROV",SAK->AK_NOME )
				oHtml:ValByName("APROV",SCR->CR_APROV+" - "+SAK->AK_NOME )
				oHTML:ValByName('GRUPO',Alltrim(SCR->CR_GRUPO))
				//oHTML:ValByName('ITGRP',Alltrim(SCR->CR_ITGRP)) 


				oProcess:cTo := "pedcom"

				//eMail
				//Identifica ID do usuario
				oProcess:UserSiga := __CUSERID
				cMailId := oProcess:Start()              

				//usado para teste			                
				//eMail := "marcus.ferraz@dfssistemas.com.br"						
				//If SCR->CR_NIVEL == "01" 
				//	eMail := "cristiano.cunha@dfssistemas.com.br"
				//EndIf

				cAssunto:= "Pedido: " + SC7->C7_NUM + " - " + Alltrim(FWFilialName()) + " - " + Posicione("SA2",1,XFILIAL("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME" )
				cHtmlModelo := "\workflow\wflink_WFPC.htm"
				oProcess:NewTask(cAssunto, cHtmlModelo)  
				oProcess:cSubject := cAssunto
				oProcess:cTo := eMail
				oProcess:ohtml:ValByName("usuario",SAK->AK_NOME)
				//oProcess:ohtml:ValByName("proc_link","http://187.94.60.83:8285/messenger/emp01/pedcom/" + cMailID + ".htm")
				//If _cIPWF = "187.94.60.83:8285"
				oProcess:ohtml:ValByName("proc_link","http://" + _cIPWF + "/wf/messenger/emp"+cEmpAnt+"/pedcom/" + cMailID + ".htm")
				//Else 
				//	oProcess:ohtml:ValByName("proc_link","http://" + _cIPWF + "/wf/messenger/emp01/pedcom/" + cMailID + ".htm")
				//EndIF 
				oProcess:Start()
				
				cRecSCR := SCR->(RECNO())
				cGrpChv	:= SCR->(CR_FILIAL+CR_NUM+CR_GRUPO)
				cGrpNiv		:= SCR->CR_NIVEL
				
				Do While !SCR->(eof()) .AND. SCR->(CR_FILIAL+CR_NUM+CR_GRUPO) ==  cGrpChv
 					
 					If SCR->CR_NIVEL == cGrpNiv
 					
						SCR->(RecLock("SCR",.F.))
						SCR->CR_WF := "S"
						SCR->(MsUnLock())
						
					EndIf
						
					SCR->(dbskip())
				EndDo
				
				SCR->(DbGoTo(cRecSCR))
				SCR->(dbskip())
				//			Exit
			Enddo   
		Endif
		TMPA->(DbSkip())
	EndDo
Return .T.


//Verifica se o Centro de Custo Pertence ao Grupo de Aprovação.
//Marcus Ferraz - DFS Sistemas - 17/01/2018
Static Function GrupoOk(_cGrupo, _cCC, _cConta, _cItmCta, _cClvl)

	Local lRet:= .F.


	If !lRet
		DBL->(DbGoTop())
		DBL->(DbSetOrder(2))//DBL_FILIAL, DBL_CC, DBL_CONTA, DBL_ITEMCT, DBL_CLVL
		If DBL->(DbSeek(xFilial("DBL")+Padr(_cCC,TamSx3("DBL_CC")[1])+Padr(_cConta,TamSx3("DBL_CONTA")[1])+Padr(_cItmCta,TamSx3("DBL_ITEMCT")[1])+Padr(_cClvl,TamSx3("DBL_CLVL")[1]),.F.))
			Do While DBL->(!EOF()) .and. Alltrim(_cCC+_cConta+_cItmCta+_cClvl) == Alltrim(DBL->(DBL_CC+DBL_CONTA+DBL_ITEMCT+DBL_CLVL)) 
				If Alltrim(DBL->DBL_GRUPO) == Alltrim(_cGrupo)
					lRet := .T.
				EndIf
				DBL->(DbSkip())
			EndDo
		EndIf
	EndIf

	If !lRet
		DBL->(DbGoTop())
		DBL->(DbSetOrder(2))//DBL_FILIAL, DBL_CC, DBL_CONTA, DBL_ITEMCT, DBL_CLVL
		If DBL->(MsSeek(xFilial("DBL")+Padr(_cCC,TamSx3("DBL_CC")[1])+Padr(_cConta,TamSx3("DBL_CONTA")[1])+Padr(_cItmCta,TamSx3("DBL_ITEMCT")[1]),.F. ))
			Do While DBL->(!EOF()) .and. Alltrim(_cCC+_cConta+_cItmCta) == Alltrim(DBL->(DBL_CC+DBL_CONTA+DBL_ITEMCT)) 
				If Alltrim(DBL->DBL_GRUPO) == Alltrim(_cGrupo)
					lRet := .T.
				EndIf
				DBL->(DbSkip())
			EndDo
		EndIf
	EndIf

	If !lRet
		DBL->(DbGoTop())
		DBL->(DbSetOrder(2))//DBL_FILIAL, DBL_CC, DBL_CONTA, DBL_ITEMCT, DBL_CLVL
		If DBL->(MsSeek(xFilial("DBL")+Padr(_cCC,TamSx3("DBL_CC")[1])+Padr(_cConta,TamSx3("DBL_CONTA")[1]),.F. ))
			Do While DBL->(!EOF()) .and. Alltrim(_cCC+_cConta) == Alltrim(DBL->(DBL_CC+DBL_CONTA)) 
				If Alltrim(DBL->DBL_GRUPO) == Alltrim(_cGrupo)
					lRet := .T.
				EndIf
				DBL->(DbSkip())
			EndDo
		EndIf
	EndIf

	If !lRet
		DBL->(DbGoTop())
		DBL->(DbSetOrder(2))//DBL_FILIAL, DBL_CC, DBL_CONTA, DBL_ITEMCT, DBL_CLVL
		If DBL->(MsSeek(xFilial("DBL")+Padr(_cCC,TamSx3("DBL_CC")[1]) ,.T.))
			Do While DBL->(!EOF()) .and. Alltrim(_cCC) == Alltrim(DBL->(DBL_CC)) 
				If Alltrim(DBL->DBL_GRUPO) == Alltrim(_cGrupo)
					lRet := .T.
				EndIf
				DBL->(DbSkip())
			EndDo	
		EndIf
	EndIf

Return(lRet)
