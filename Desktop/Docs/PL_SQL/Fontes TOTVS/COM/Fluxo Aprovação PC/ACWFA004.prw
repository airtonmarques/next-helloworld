#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ACWFA004  ºAutor  ³Marcus Ferraz      º Data ³  06/01/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Workflow de status do pedido de compras 		 	          º±±
±±º          ³ 													          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DFS Sistemas                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ACWFA004(cNumPed, cGrupo)

Local cQryApv  := ""
Local _cStatus := ""  
Local aAprvAnt := {}
Local aAreaATU := GetArea()
Local aAreaSC7 := SC7->(GetArea())
Local eMail    := GetNewPar("MV_XMAILC","marcus.ferraz@dfssistemas.com.br;")
Local aSolic   := {}      
Local _lRejeit := .F.    
Local _cSc     := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca os usuarios solicitantes da SC1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC7")
dbSetOrder(1)
MsSeek(xFilial("SC7")+cNumPed)

aAreaTMP := SC7->(GetArea())

While SC7->(!Eof()) .And. xFilial("SC7")+cNumPed == SC7->C7_FILIAL+SC7->C7_NUM
	
	If !Empty(SC7->C7_NUMSC)
		If !SC7->C7_NUMSC $_cSc  
			_cSc += SC7->C7_NUMSC + " / "
		EndIf
	
		dbSelectArea("SC1")
		dbSetOrder(1)
		If MsSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC)
			If Ascan( aSolic, SC1->C1_USER ) == 0    
				AADD(aSolic, SC1->C1_USER)
			EndIf
		EndIf
	EndIf
	SC7->(dbSkip())
EndDo
                  
dbSelectArea("SC7")
RestArea(aAreaTMP)
     
//Busca informações dos aprovadores anteriores
cQryApv := " SELECT CR_APROV, CR_STATUS, CR_DATALIB, CR_USER, CR_GRUPO, R_E_C_N_O_ AS RECSCR "
cQryApv += " FROM "+RetSqlName("SCR")+"  "
cQryApv += " WHERE CR_NUM = '"+SC7->C7_NUM+"' "
cQryApv += " AND CR_FILIAL = '"+SC7->C7_FILIAL+"' "
//cQryApv += " AND CR_GRUPO = '"+cGrupo+"' "
cQryApv += " AND CR_TIPO = 'IP' "
cQryApv += " AND D_E_L_E_T_ <> '*' "
cQryApv += " GROUP BY CR_APROV, CR_STATUS, CR_DATALIB, CR_USER, CR_GRUPO, R_E_C_N_O_ "

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
		Case TAPV->CR_STATUS == "03"                                                
		   	_cStatus := "Pedido Liberado"
		Case TAPV->CR_STATUS == "04"
		   	_cStatus := "Pedido Bloqueado pelo usuario"
		   	_lRejeit := .T.
		Case TAPV->CR_STATUS == "05"
		   	_cStatus := "Nivel Liberado por outro usuario"
	End Case
	
	DBSelectArea("SAK")
	DBSetOrder(2)
	DBSeek(xFilial("SAK")+TAPV->CR_USER)
	
	_nPosApv := aScan(aAprvAnt,{|x| x[1] == SAK->AK_NOME})
	//If _nPosApv == 0    
		AADD( aAprvAnt, {SAK->AK_NOME, Alltrim(_cStatus), SCR->CR_OBS, DTOC(STOD(TAPV->CR_DATALIB)), TAPV->CR_USER, TAPV->CR_STATUS, TAPV->CR_GRUPO  } )
	//EndIf
	
	dbSelectArea("TAPV")
	TAPV->(dbSkip())

EndDo             

//Funcao que da o Start no Workflow
oProcess := TWFProcess():New( "PEDCOM2", "WF de Aprovação de Pedido de Compras" )
//Funcao que busca o Modelo do HTML
oProcess:NewTask( "000001", "\workflow\PEDCOM2.htm" )
//Subject do Email
oProcess:cSubject := "Status do Pedido de Compras "+SC7->C7_NUM

oProcess:fDesc := "Pedido de Compras No "+SC7->C7_NUM

oHTML := oProcess:oHTML       

If !Empty(_cSc)
	oHTML:ValByName('CNUMPED'," STATUS DO PEDIDO DE COMPRA - " + Alltrim(FWFilialName()) + " - " + SC7->C7_NUM + SPACE(06)+ "  - SCs: " + _cSc )
Else
	oHTML:ValByName('CNUMPED'," STATUS DO PEDIDO DE COMPRA - " + Alltrim(FWFilialName()) + " - " + SC7->C7_NUM)
EndIf

_lFirst := .T.   // Primeiro e-mail???

For nApv := 1 To Len(aAprvAnt)
	aadd((oHtml:ValByName( 'CR.USER' )),aAprvAnt[nApv][1])
	aadd((oHtml:ValByName( 'CR.STATUS' )),aAprvAnt[nApv][2])
	aadd((oHtml:ValByName( 'CR.OBS' )),aAprvAnt[nApv][3])
	aadd((oHtml:ValByName( 'CR.DATALIB' )),aAprvAnt[nApv][4])	
	aadd((oHtml:ValByName( 'CR.GRUPO' )),aAprvAnt[nApv][7])
	                                     
	If _lRejeit
		If !Empty(aAprvAnt[nApv][5]) .And. aAprvAnt[nApv][6] == "05" //Envia somente para aprovadores anteriores
			_xEmail := Alltrim(USRRETMAIL(aAprvAnt[nApv][5]))
			If AT(_xEmail,eMail) == 0   // Se já existir o e-mail na lista não há necessidade de acrescentar novamente
				eMail += Iif(_lFirst,_xEmail,";" + _xEmail)
				_lFirst := .F.
			EndIf
		EndIf		
	EndIf
	       
next nApv                
       
_xEmail := Alltrim(USRRETMAIL(SC7->C7_USER))
If AT(_xEmail,eMail) == 0   // Se já existir o e-mail na lista não há necessidade de acrescentar novamente
	eMail += Iif(_lFirst,_xEmail,";" + _xEmail)
	_lFirst := .F.
EndIf

//Adiciona e-mail do solicitante 
If Len(aSolic) > 0
	For _nSol := 1 To Len(aSolic)
		If !Empty(aSolic[_nSol])
//			alert(USRRETMAIL(aSolic[_nSol]))
			_xEmail := Alltrim(USRRETMAIL(aSolic[_nSol]))
			If AT(_xEmail,eMail) == 0   // Se já existir o e-mail na lista não há necessidade de acrescentar novamente
				eMail += Iif(_lFirst,_xEmail,";" + _xEmail)
				_lFirst := .F.
			EndIf
		EndIf			
	Next _nSol	
EndIf

//eMail := "marcus.ferraz@dfssistemas.com.br"

oProcess:cTo := eMail
oProcess:Start()

RestArea(aAreaSC7)
RestArea(aAreaATU)

Return