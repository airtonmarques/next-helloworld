#INCLUDE "rwmake.CH"
#Include "COLORS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VLLIQNFE º Autor ³ JOSMAR CASTIGLIONI º Data ³  06/11/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ INFORMAR VALOR LIQUIDO DA NOTA FISCAL DE ENTRADA           º±±
±±º          ³ CHAMADO PELO PE MT100TOK (Valida Inclusão da NF Entrada)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ALLCARE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function VLLIQNFE() 

	Public _xVlrLiq := 0.00
	Public _nOPC

	@ 117,080 To 280,480 Dialog odlg Title "Valor Líquido da Nota Fiscal de Entrada - Allcare"
	@ 017,015 Say "Valor Líquido R$ :" Size 41,8  COLOR CLR_RED
	@ 015,060  Get _xVlrLiq Size 100,08 PICTURE "@E 999,999,999.99" 
	@ 050,070  BmpButton Type 1 Action (_nOPC:=1,close(odlg)) 
	@ 050,110  BmpButton Type 2 Action (_nOPC:=2,Close(odlg))

	Activate Dialog odlg Centered

	IF _nOPC == 1
		lRet := COMPVLR(_xVlrLiq)
	Else
		lRet := .F.
	ENDIF

	Return(lRet)

	************************************************

Static function COMPVLR(_xVlrLiq)

	Local nBaseDup	:= MaFisRet(,"NF_BASEDUP") 
	Local nVlrISS	:= MaFisRet(,"NF_VALISS")
	Local nVlrIRR	:= MaFisRet(,"NF_VALIRR")
	Local nVlrINS	:= MaFisRet(,"NF_VALINS")
	Local nVlrCOF	:= MaFisRet(,"NF_VALCOF")
	Local nVlrCSL	:= MaFisRet(,"NF_VALCSL")
	Local nVlrPIS	:= MaFisRet(,"NF_VALPIS")
	//Local cParPCC	:= GETMV("MV_BX10925")
	Local cParISS	:= GETMV("MV_MRETISS")
	Local cForIRR   := MaFisRet(,"NF_CODCLIFOR")
	Local cLjFOR    := MaFisRet(,"NF_LOJA")
	Local cParIRR	:= Posicione("SA2",1,xFilial("SA2")+cForIRR+cLjFor,"A2_CALCIRF")
	Local cParPIS	:= Posicione("SA2",1,xFilial("SA2")+cForIRR+cLjFor,"A2_RECPIS")
	Local cParCOF	:= Posicione("SA2",1,xFilial("SA2")+cForIRR+cLjFor,"A2_RECCOFI")
	Local cParCSL	:= Posicione("SA2",1,xFilial("SA2")+cForIRR+cLjFor,"A2_RECCSLL")
	
	Local cNatINS	:= MaFisRet(,"NF_NATUREZA")
	Local cParINS	:= Posicione("SED",1,xFilial("SED")+cNatINS,"ED_DEDINSS")
	Local _Enter    := Chr(10)+chr(13)
	Local lRet 		 
	Local _cMens	:= ""
	Local nVliq     := _xVlrLiq
	Local nVliq1    := _xVlrLiq+1
	Local nVliq2    := _xVlrLiq-1

	If nBaseDup > 0 //TES GERA DUPLICATA
		If cParPIS == "2" //2=NÃO - abate PIS
			nBaseDup := nBaseDup - nVlrPIS
		Endif

		If cParCOF == "2" //2=NÃO - abate COFINS
			nBaseDup := nBaseDup - nVlrCOF
		Endif

		If cParCSL == "2" //2=NÃO - abate CSLL
			nBaseDup := nBaseDup - nVlrCSL
		Endif
		
		If cParISS == "1" //abate ISS na emissão
			nBaseDup := nBaseDup - nVlrISS
		Endif

		//If cParIRR <> "2" //abate IRRF na emissão SOMENTE SE FOR > 10,00
			If nVlrIRR > 10.00
				nBaseDup := nBaseDup - nVlrIRR
			Endif	
		//Endif

		If cParINS == "1" //abate INSS na emissão
			nBaseDup := nBaseDup - nVlrINS
		Endif	                                                                                                                               

		//_cMens:="O Valor Líquido do Título a Pagar é Calculado Pelo Sistema Abatendo os Impostos, se Calculados, do Valor Total do Título Conforme Parametrização Abaixo:" +_Enter	
		//_cMens+="Existe uma Tolerancia de R$ 1,00 na Comparação Entre os Valores" +_Enter
		//_cMens+="PIS/COFINS/CSLL - Parâmetro MV_BX10925 - 1 = Baixa do Título - 2 = Emissão do Título" +_Enter 
		//_cMens+="ISS - Parâmetro MV_MRETISS - 1 = Emissão do Título - 2 = Baixa do Título" +_Enter	
		//_cMens+="IRRF - Cadastro Fornecedor - Aba Fiscais - Campo Cálc.IRRF Diferente de 2 = Emissão do Título - Igual a 2 = Baixa do Título" +_Enter
		//_cMens+="INSS - Cadastro de Naturezas - Aba Impostos - Campo Ded.INSS 1 = Emissão do Título - 2 = Baixa do Título" +_Enter
		//_cMens+="____________________________________________________________________________" +_Enter

		If nBaseDup >= nVliq2 .AND. nBaseDup <= nVliq1  
			lRet := .T.
			_cMens:="Valor Líquido Informado = R$ : " + AllTrim(Transform(nVliq,"@E 999,999,999.99")) +" " +_Enter+_Enter
			_cMens+="Valor Líquido Calculado Pelo Sistema = R$ : " + AllTrim(Transform(nBaseDup,"@E 999,999,999.99")) +" " +_Enter+_Enter
			_cMens+="A Nota Fiscal de Entrada Será Incluida no Sistema"+_Enter+_Enter
			MsgAlert(_cMens)
			lRet := .T.
		Else
			lRet := .F.
			_cMens:="Valor Líquido Informado = R$ : " + AllTrim(Transform(nVliq,"@E 999,999,999.99")) + " " + _Enter + _Enter
			_cMens+="Valor Líquido Calculado Pelo Sistema = R$ : " + AllTrim(Transform(nBaseDup,"@E 999,999,999.99")) + " " + _Enter + _Enter
			_cMens+="Valores Diferentes, Cancele a Inclusão ou Salve Novamente e Digite o Valor Líquido Correto"
			MsgAlert(_cMens)
			lRet := .F.
		EndIf
	Else //TES NÃO GERA DUPLICATA
		MsgAlert("Tipo de Entrada Utilizado Não Gera Duplicata")
		lRet := .T.
	Endif

RETURN(lRet)

