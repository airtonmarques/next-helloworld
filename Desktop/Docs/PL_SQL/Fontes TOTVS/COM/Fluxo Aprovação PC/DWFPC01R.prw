#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DWFPC01R  ºAutor  ³Marcus Ferraz       º Data ³  28/07/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para tratamento do Retorno do WF                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±

±±ºUso       ³ DFS SISTEMAS                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DWFPC01R(oProcess)     

Local _cNum 	:= PadR(Alltrim(oProcess:oHtml:RetByName('C7_NUM')),6)
Local _lAprov 	:= RIGHT(Alltrim(Upper(oProcess:oHtml:RetByName('aprovacao'))),1) == "S"
Local _aprova 	:= oProcess:oHtml:RetByName('APROVADOR')
Local _cGrupo 	:= PadR(Alltrim(oProcess:oHtml:RetByName('GRUPO')),6)
Local _lAchouSC := .F.
Local cTpAprov	:= Alltrim(Upper(GetNewPar("SM_TPAPWFC","U"))) //->> Tipo de aprovação, se por codigo de aprovador ou código de usuario (C=>AK_COD, U=>AK_USER (Padrao)) ->> DFS - Marcelo Celi - 04/02/2017
Local cCdAprov	:= "" //->> DFS - Marcelo Celi - 04/02/2017
Local _lAchouPC	:= .F.

Private nTotal  := 0

CONOUT("Retorno de Aprovacao/Rejeicao - Pedido de Compra: [" + _cNum + "]")

CONOUT("Pedido de Compra: [" + _cNum + "] - " + Iif(_lAprov,"Aprovado","Rejeitado") + " por [" + _aprova + "]")

DBSelectArea("SC7")
DBSetOrder(1)
If DBSeek(xFilial("SC7")+_cNum)	                                                  
	
	_lAchouPC := .T.
	
	//Verifica se foi aprovado ou não
	If _lAprov//Left(Alltrim(Upper(oProcess:oHtml:RetByName('aprovacao'))),1) == "S"
		//Funcao que atualiza o status de rastreamento do WF
		RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,oProcess:fProcCode,'200002')
		
		//->> DFS - Marcelo Celi - 04/02/2017
		If cTpAprov == "U" .Or.	!CanAprByCod(oProcess:oHtml:RetByName('APROV'))
			//->> Aprovacao pelo codigo do usuario - L E G A D O Smith		
			DbSelectArea("SCR")
			SCR->(DbGoTop())		
			SCR->( dbSetOrder(5) ) //CR_FILIAL+CR_TIPO+CR_NUM+CR_GRUPO+CR_ITGRP
			If SCR->(dbseek(xFilial("SCR")+"IP"+PADR(_cNum,50)+PADR(_cGrupo,6)))//+PADR(_cItGrp,2)))
				
				While SCR->(!EOF()) .and. Alltrim(SCR->CR_GRUPO) == Alltrim(_cGrupo)
					
					If Alltrim(_aprova) == Alltrim(SCR->CR_USER)
						
						DBSelectArea("SAK")
						DBSetOrder(2)
						If DBSeek(xFilial("SAK")+_aprova)

							aRetSaldo := MaSalAlc(_aprova,Date(),.F.)

							nTotal    := xMoeda(SCR->CR_TOTAL,SCR->CR_MOEDA,aRetSaldo[2],SCR->CR_EMISSAO,,SCR->CR_TXMOEDA)
						   
						Endif
						//DbSelectArea("DBL")
						//DbSetOrder("")
						
						aItmDBM := {}
						cChvDBM := SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_GRUPO+CR_ITGRP+CR_USER+CR_USERORI)
						
						DbSelectArea("DBM")
						DBM->(DbGoTop())
						DBM->(DbSetOrder(1))//DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USER+DBM_USEROR
						If DBM->(DbSeek(SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_GRUPO+CR_ITGRP+CR_USER+CR_USERORI)))
							//Do While !DBM->(eof()) .AND. cChvDBM == SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_GRUPO+CR_ITGRP+CR_USER+CR_USERORI) 
								aadd(aItmDBM,{DBM->DBM_ITEM,DBM->DBM_ITEMRA,DBM->DBM_VALOR,DBM->DBM_TIPO})
								//DBM->(DbSkip())
							//EndDo
						EndIf
						            
						//Adaptacao para versão 12 - 17/10/2017
						DBSelectArea("SAL")
						DBSetOrder(1)
													
						lLiberou := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,nTotal,SCR->CR_APROV,,SCR->CR_GRUPO,,,,,oProcess:oHtml:RetByName('MOTIVO')},Date(),4,'','','',SCR->CR_ITGRP,aItmDBM,,aItmDBM)
						
						if lLiberou
							dbSelectArea("SC7")
							cPCLib := SC7->C7_NUM
							cPCUser:= SC7->C7_USER
							While !Eof() .And. SC7->C7_FILIAL+Substr(SC7->C7_NUM,1,len(SC7->C7_NUM)) == xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM))
								Reclock("SC7",.F.)
								SC7->C7_CONAPRO := "L"
								MsUnlock()
								SC7->(dbSkip())
							EndDo
						Endif
						SCR->(DbSkip())
					Else
						SCR->(DbSkip())
					EndIf
				EndDo
			Endif
		Else
			
			//->> Aprovacao pelo codigo do aprovador
			SCR->( dbSetOrder(3) )

			cCdAprov := SubStr(oProcess:oHtml:RetByName('APROV'),1,6)			
			
			If SCR->(dbseek(xFilial("SCR")+"IP"+PADR(_cNum,50)+cCdAprov))
				
				DBSelectArea("SAK")
				DBSetOrder(2)
				If DBSeek(xFilial("SAK")+_aprova)

					aRetSaldo := MaSalAlc(cCdAprov,Date(),.F.)
					
					nTotal    := xMoeda(SCR->CR_TOTAL,SCR->CR_MOEDA,aRetSaldo[2],SCR->CR_EMISSAO,,SCR->CR_TXMOEDA)
				
				Endif	
				

				//Adaptacao para versão 12 - 17/10/2017
				DBSelectArea("SAL")
				DBSetOrder(1)
							
				lLiberou := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,nTotal,SCR->CR_APROV,,SCR->CR_GRUPO,,,,,oProcess:oHtml:RetByName('MOTIVO')},Date(),4)
				
				//Corrigido dia 01/04/2016 por erro no posicionamento da tabela SAK - Diego Fernandes
				//lLiberou := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,nTotal,SAK->AK_COD,,SC7->C7_APROV,,,,,oProcess:oHtml:RetByName('MOTIVO')},Date(),4)
				If lLiberou
					dbSelectArea("SC7")
					cPCLib := SC7->C7_NUM
					cPCUser:= SC7->C7_USER
					While !Eof() .And. SC7->C7_FILIAL+Substr(SC7->C7_NUM,1,len(SC7->C7_NUM)) == xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM))
						Reclock("SC7",.F.)
						SC7->C7_CONAPRO := "L"
						MsUnlock()
						SC7->(dbSkip())
					EndDo	
				Endif
			EndIf
		EndIf		
	//WF Reprovado
	Else
		//Funcao que atualiza o status de rastreamento do WF
		//RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,oProcess:fProcCode,'100003')
		RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,oProcess:fProcCode,'200003')
		
		//->> DFS - Marcelo Celi - 04/02/2017
		If cTpAprov == "U" .Or.	!CanAprByCod(oProcess:oHtml:RetByName('APROV'))
			//->> Aprovacao pelo codigo do usuario - L E G A D O Smith
			SCR->(dbsetorder(2))
			If SCR->(dbseek(xFilial("SCR")+"IP"+PADR(_cNum,50)+oProcess:oHtml:RetByName('APROVADOR')))
				
				DBSelectArea("SAK")
				DBSetOrder(2)
				if DBSeek(xFilial("SAK")+oProcess:oHtml:RetByName('APROVADOR'))

					aRetSaldo := MaSalAlc(oProcess:oHtml:RetByName('APROVADOR'),Date(),.F.)
					
					nTotal   := xMoeda(SCR->CR_TOTAL,SCR->CR_MOEDA,aRetSaldo[2],SCR->CR_EMISSAO,,SCR->CR_TXMOEDA)
				
				Endif	
				
				lLiberou := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,nTotal,SCR->CR_APROV,,SCR->CR_GRUPO,,,,,oProcess:oHtml:RetByName('MOTIVO')},Date(),6)
			EndIf
		Else
			//->> Aprovacao pelo codigo do aprovador
			SCR->( dbSetOrder(3) )
			
			cCdAprov := SubStr(oProcess:oHtml:RetByName('APROV'),1,6)			
			
			If SCR->(dbseek(xFilial("SCR")+"IP"+PADR(_cNum,50)+cCdAprov))
			
				DBSelectArea("SAK")
				DBSetOrder(1)
				If DBSeek(xFilial("SAK")+cCdAprov)				
			
					aRetSaldo := MaSalAlc(cCdAprov,Date(),.F.)
			
					nTotal    := xMoeda(SCR->CR_TOTAL,SCR->CR_MOEDA,aRetSaldo[2],SCR->CR_EMISSAO,,SCR->CR_TXMOEDA)				
					lLiberou  := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,nTotal,SCR->CR_APROV,,SCR->CR_GRUPO,,,,,oProcess:oHtml:RetByName('MOTIVO')},Date(),6)
			
				EndIf	
			EndIf
		EndIf	
	EndIf
	
endif

oProcess:Finish()
oProcess:Free()

//Chama a funcao para ver se tem mais algum nivel
If _lAchouPC

	DBSelectArea("SC7")
	DBSetOrder(1)
	if DBSeek(xFilial("SC7")+_cNum)
		u_WFW120P()
		
		//Envia o status para o comprador
		u_ACWFA004(_cNum,_cGrupo)

		CONOUT("Enviado Status do Pedido de Compra: [" + _cNum + "] - " + Iif(_lAprov,"Aprovado","Rejeitado") + " por [" + _aprova + "]")

	endif
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CanAprByCodºAutor ³Marcelo Celi Marquesº Data ³  04/02/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Se pode usar o codigo do aprovador para aprovar            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DFS SISTEMAS                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CanAprByCod(cAprovador)
Local lRet := .T.

//->> Se o traco + espaços nao existirem na string significa que o email é antigo e deve ser considerado o metodo antes da alteracao
If SubStr(cAprovador,7,3) <> " - " 
	lRet := .F.
EndIf          

//->> Se nickname existir na base
If lRet       
	lRet := .F.
	SIX->(dbSeek("SCR"))
	Do While !SIX->(Eof()) .And. SIX->INDICE == "SCR"
	    If Alltrim(Upper(SIX->NICKNAME))=="CR-CDAPROV"
	    	lRet := .T.
	    	Exit
	    EndIf
    	SIX->(dbSkip())           
	EndDo
EndIf

Return lRet
