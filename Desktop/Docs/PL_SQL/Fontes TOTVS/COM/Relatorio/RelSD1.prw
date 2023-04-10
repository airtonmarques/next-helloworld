#include "protheus.ch"                       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFECH02  ºAutor  ³					   º Data ³  		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 													          º±±
±±º          ³ 										   					  º±±                          
±±º          ³ 										 					  º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ALLCARE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                         

User Function RFECH02()                     
	Local oReport
	Private cPerg := "RELSD1"
	
	//ValidPerg(cPerg)

	Pergunte(cPerg,.F.)	
	oReport := ReportDef()
	oReport:PrintDialog()
Return
                     

Static Function ReportDef()
	Local oReport
	Local oSection
	
	oReport := TReport():New("RFECH02", "Relatorio SD1", cPerg, {|oReport| PrintReport(oReport)}, "Divergencias")
	
	oSection := TRSection():New(oReport, "Divergencias", {"SD1","SE2","SB1"})
 
		TRCell():New(oSection,"D1_FILIAL", "SD1")
		TRCell():New(oSection,"D1_DOC", "SD1")
		TRCell():New(oSection,"D1_COD" , "SD1")
		TRCell():New(oSection,"B1_DESC", "SB1")
		TRCell():New(oSection,"D1_ITEM", "SD1")
		TRCell():New(oSection,"E2_FORNECE", "SE2")
		TRCell():New(oSection,"E2_LOJA", "SE2")
		TRCell():New(oSection,"E2_NOMFOR", "SE2")
		TRCell():New(oSection,"E2_PARCELA", "SE2")
		TRCell():New(oSection,"D1_QUANT", "SD1")
		TRCell():New(oSection,"D1_VUNIT", "SD1")
		TRCell():New(oSection,"D1_TOTAL", "SD1")
		TRCell():New(oSection,"D1_CONTA", "SD1")
		TRCell():New(oSection,"D1_ITEMCTA", "SD1")
		TRCell():New(oSection,"D1_CC", "SD1")
		TRCell():New(oSection,"D1_CLVL", "SD1")
		TRCell():New(oSection,"E2_TIPO", "SE2")
		TRCell():New(oSection,"E2_NATUREZ", "SE2")
		TRCell():New(oSection,"D1_EMISSAO", "SD1")
		TRCell():New(oSection,"D1_DTDIGIT", "SD1")
		TRCell():New(oSection,"E2_EMISSAO", "SE2")
		TRCell():New(oSection,"E2_VENCTO", "SE2")
		TRCell():New(oSection,"E2_VENCREA", "SE2")
		TRCell():New(oSection,"D1_ALIQIRR", "SD1")
		TRCell():New(oSection,"D1_VALIRR", "SD1")
		TRCell():New(oSection,"D1_ALIQISS", "SD1")
		TRCell():New(oSection,"D1_VALISS", "SD1")
		TRCell():New(oSection,"E2_IRRF", "SE2")
		TRCell():New(oSection,"E2_VRETIRF", "SE2")

	oReport:SetPortrait()

Return oReport


Static Function PrintReport(oReport)
	Local oSection  := oReport:Section(1)
	Local cDataIni		:= DToS(MV_PAR03)   
	Local cDataFim		:= DToS(MV_PAR04)          
	//Local cData		:= DToS(MV_PAR01)

	oSection:BeginQuery()       
		
	BeginSql alias "QRY"	
	SELECT 
			D1.D1_FILIAL, D1.D1_DOC, D1.D1_COD, B1.B1_DESC, D1.D1_ITEM, E2.E2_FORNECE, E2.E2_LOJA, E2.E2_NOMFOR, E2.E2_PARCELA, D1.D1_QUANT, D1.D1_VUNIT, D1.D1_TOTAL, D1.D1_CONTA, D1.D1_ITEMCTA, D1.D1_CC, D1.D1_CLVL, 
			E2.E2_TIPO, E2.E2_NATUREZ, D1.D1_EMISSAO, D1.D1_DTDIGIT, E2.E2_EMISSAO, E2.E2_VENCTO, E2.E2_VENCREA, D1.D1_ALIQIRR, D1.D1_VALIRR, D1.D1_ALIQISS, D1.D1_VALISS, 
			E2.E2_IRRF, E2.E2_VRETIRF   
			FROM 
			%table:SD1% D1 INNER JOIN 
			%table:SE2% E2 ON
			D1.D1_FILIAL = E2.E2_FILORIG AND
			D1.D1_DOC = E2.E2_NUM AND
			D1.D1_SERIE = E2.E2_PREFIXO AND
			D1.D1_EMISSAO = E2.E2_EMISSAO AND 
			D1.D1_FORNECE = E2.E2_FORNECE AND 
			D1.D1_LOJA = E2.E2_LOJA INNER JOIN 
			%table:SB1% B1 ON
			D1.D1_COD = B1.B1_COD 
			WHERE
			D1.%notDel% AND E2.%notDel% AND B1.%notDel%
			AND D1.D1_FILIAL >= %EXP:mv_par01%
			AND D1.D1_FILIAL <= %EXP:mv_par02% 
			AND D1.D1_EMISSAO >= %Exp:cDataIni%
			AND D1.D1_EMISSAO <= %Exp:cDataFim%
			ORDER BY D1_FILIAL, D1_DOC, D1_ITEM, E2.E2_PARCELA					

	EndSql                   

	oSection:EndQuery()	
	oSection:Print()

Return              

/*                                            
Static Function ValidPerg(cPerg)     
	PutSx1(cPerg,"01","Data Fechamento?","Data Fechamento?","Data Fechamento?","mv_ch1","D",8,0,0,"G","","","","","mv_par01")
Return
*/