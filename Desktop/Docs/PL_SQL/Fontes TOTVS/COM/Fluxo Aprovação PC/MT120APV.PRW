#Include "Rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT120APV º Autor ³ Diego Fernandes    º Data ³  21/01/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de entrada que alimenta o grupo de aprovaocao        º±±
±±º          ³ Conforme centro de custo		                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Smith				                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MT120APV()

Local aSavATU   := GetArea()
Local aSavSC7   := SC7->(GetArea())
Local cNumPed   := SC7->C7_NUM
Local cCusto    := ""
Local _cAprov   := ""
Local lRet		:= .F.
Local cGrupo	:= ""
//Local lApvCC    := GetNewPar("MV_PCAPVCC",.F.)
//Local lAtivApr  := GetNewPar("MV_XATVAPR",.T.)
//Local lForApvCC := IIF(Posicione("SA2",1,XFILIAL("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_XTPAPR")=="1",.F.,.T.)

//If lApvCC .And. lAtivApr .And. lForApvCC//Só atualiza se for aprovacao por centro de custo

dbselectArea("SC7")                                               
dbSetOrder(1)
dbSeek(xFilial("SC7")+cNumPed)
	
While !Eof() .AND. cNumPed == SC7->C7_NUM .And. SC7->C7_FILIAL == xFilial("SC7")
	cGrupo		:= ""
	aGrupo		:= {}
	_cCC		:= SC7->C7_CC
	_cConta		:= SC7->C7_CONTA
	_cItmCta	:= SC7->C7_ITEMCTA
	_cClvl		:= SC7->C7_CLVL
	
	
	aGrupo := MaGrpApEC({_cCC,_cConta,_cItmCta,_cClvl},.T.,'IP')
	cGrupo := aGrupo[1] 
	
	RecLock("SC7",.F.)
	SC7->C7_APROV := cGrupo
	SC7->(MsUnlock())		  		
		
	SC7->(dbSkip())	
EndDo
	
RestArea(aSavSC7)
RestArea(aSavATU)

Return
