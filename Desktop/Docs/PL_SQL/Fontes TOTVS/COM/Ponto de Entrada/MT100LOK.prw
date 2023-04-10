#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT100LOK  ºAutor  ³DFS Sistemas        º Data ³  26/07/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Verifica o uso do centro de custo, caso nao haja rateio     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                             

User Function MT100LOK()

Local aSED := SED->(GetArea())

Private lRet		:= .T.
Private nPosProd	:= Ascan(aHeader, {|n| Alltrim(n[2]) = "D1_COD"})
Private nPosCC   	:= Ascan(aHeader, {|n| Alltrim(n[2]) = "D1_CC"})
Private nPosItm   	:= Ascan(aHeader, {|n| Alltrim(n[2]) = "D1_ITEMCTA"})
Private nPosClv   	:= Ascan(aHeader, {|n| Alltrim(n[2]) = "D1_CLVL"})
Private nPosTES  	:= Ascan(aHeader, {|n| Alltrim(n[2]) = "D1_TES"})
Private nPosRateio  := Ascan(aHeader, {|n| Alltrim(n[2]) = "D1_RATEIO"})
Private lCCObr 		:= GetNewPar("MV_XCCOBR","S")=="S"

If !Acols [n,Len(aHeader) + 1]
	// Verifica se o centro de custo foi preenchido
	If aCols[n][nPosRateio]=="2"							   	 								// Sem rateio
		If lCCObr .AND. Empty(aCols[n][nPosCC])
			Alert("Para este tipo de entrada, deve-se informar o centro de custo.","Atenção")
			lRet := .F.
		Endif
		If lCCObr .AND. Empty(aCols[n][nPosItm])
			Alert("Para este tipo de entrada, deve-se informar o Item Conta.","Atenção")
			lRet := .F.
		Endif
		If lCCObr .AND. Empty(aCols[n][nPosClv])
			Alert("Para este tipo de entrada, deve-se informar a Classe de Valor.","Atenção")
			lRet := .F.
		Endif
	Endif
	
Endif

RestArea(aSED)

Return(lRet)
