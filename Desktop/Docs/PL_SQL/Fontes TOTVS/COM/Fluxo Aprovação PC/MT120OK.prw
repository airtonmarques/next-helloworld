#Include "Protheus.ch"
#Include "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT120OK   ºAutor  ³Marcus Ferraz        º Data ³  28/07/18  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para validar inclusão do pedido de        º±±
±±º          ³ compras                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Allcare                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT120OK   

Local lRet 	   := .T.
Local cQuery   := ""
Local cGrpApv  := ""
Local _nY      := 0
Local _nPosFil := GDFieldPos( "C7_FILIAL" )
Local _nPosPed := GDFieldPos( "C7_NUM" )
Local _nPosItm	:= GDFieldPos( "C7_ITEM" )
//Local _nPosGRP := GDFieldPos( "C7_APROV" ) 
Local _nPosCC  := GDFieldPos( "C7_CC" ) 
Local _nPosWFID := GDFieldPos( "C7_WFID" ) 
Local aAreaATU  := GetArea()
//Local lApvCC 	:= GetNewPar("MV_PCAPVCC",.F.)
Local lAtivApr	:= GetNewPar("MV_XATVAPR",.T.)
//Local lForApvCC := IIF(Posicione("SA2",1,XFILIAL("SA2")+cA120Forn+cA120Loj,"A2_XTPAPR")=="1",.F.,.T.)   
Local _nPosPrd  := GDFieldPos( "C7_PRODUTO" )
Local _nPosTES  := GDFieldPos( "C7_TES" )
Local _nPosTot  := GDFieldPos( "C7_TOTAL" )
//Local _nPosCer  := GDFieldPos( "C7_XCER" ) 
//Local _nPObsCer := GDFieldPos( "C7_XOBSCER" )
//Local _nValCer	:= GetMv("MV_XCER",.F.,18500) 
//Local _cTipAtf	:= GetMv("MV_XTIPATF",.F.,"AI")

Private _nTotAtf:= 0
Private cVarCER	:= space(100) 
Private cObsCER	:= space(200)
Private aVetor	:=	{}


//Encerra processos de aprovacao em aberto  - 28/03/2016     
If !IsInCallStack( "A120Copia" ) //Não encerra processo se for copia - 23/05/2016
	If _nPosWFID > 0 .And. !Empty(aCols[1][_nPosWFID])
		U_ACWFA006(aCols[1][_nPosWFID])
	EndIf
Else
	For _nY := 1 To Len(aCols)
		aCols[_nY][_nPosWFID] :=  Space(TamSx3("C7_WFID")[1]) 

	Next _nY		
EndIf	
                                                                                                              
For _nY := 1 To Len(aCols)

	// DFS Sistemas - 22/08/2017
	//If GetAdvFVal("SB1","B1_XAPROVC",xFilial("SB1")+aCols[_nY][_nPosPrd],1,"") == "S"
		If !aCols[_nY][Len(aHeader) + 1]
			
			If lAtivApr //.And. lForApvCC
			    		
				dbSelectarea("DBL")
				dbSetOrder(2)
				lRet := MsSeek(xFIlial("DBL")+aCols[_nY][_nPosCC],.F.)
			
				If !lRet 
					Aviso("Aviso","Não existe Grupo de aprovador cadastrado para o centro de custo "+aCols[_nY][_nPosCC]+"! ",{"&OK"},1)
					Return lRet
				EndIf
				
			EndIf
				
	
		EndIf
	//EndIf

Next _nY
                       
RestArea(aAreaATU)

Return( lRet )