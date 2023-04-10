#INCLUDE "TOTVS.CH"
#include 'protheus.ch'
#include 'parmtype.ch'
#include "TopConn.ch"
#include "TBICONN.CH"
#include "TbiCode.ch"
#include "rwmake.CH"


User Function ACATUSZ1( aParams )

Local cPerg   	:= "ACATUSZ1XX"
Local cCadastro := "Atualizacao SZ1"
Local cProcess  := "ACATUSZ1"
Local lSChedule	:= IsInCallStack("WFLAUNCHER")

Private aLog		:= {}
Private oProcess

Default aParams 	:= {}

If (!lSChedule)

	CriaSX1(cPerg)

    Pergunte(cPerg,.F.)

    bProcess := {|oProcess| u_fExecRot(oProcess) }

    cMsg := " Esta rotina tem como objetivo atualizar os registros "+CRLF
    cMsg += "na tabela SZ1, conforme parâmetros informado. "+CRLF

	oProcess := tNewProcess():New( cProcess , cCadastro , bProcess ,OemtoAnsi(cMsg), cPerg , NIL , .T. , NIL , NIL , .T. , .T. )

Else

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101"

	u_fExecRot(oProcess)

Endif	

Return

/*
	Execucao da Rotina da Rotina
*/
User Function fExecRot(oProcess)
Local lSChedule	:= IsInCallStack("WFLAUNCHER")
Local nRecs   	:= 0
Local dDataBx 	:= StoD("")
Local dDataIni  := Date()-90
Local dDataFim  := Date()

If !lSChedule
	dDataIni  := MV_PAR01
	dDataFim  := MV_PAR02
Endif 

If Select('TSE2') > 0
	TFAT->(dbCloseArea())
EndIf

BeginSQL Alias 'TSE2'
	SELECT
	SE2.E2_FILIAL, 
	SE2.E2_PREFIXO, 
	SE2.E2_NUM, 
	SE2.E2_PARCELA, 
	SE2.E2_TIPO, 
	SE2.E2_FORNECE, 
	SE2.E2_LOJA, 
	SE2.R_E_C_N_O_ SE2RECNO, 
	SZ1.R_E_C_N_O_ SZ1RECNO
	FROM %Table:SE2% SE2, %Table:SZ1% SZ1
	WHERE SE2.%NotDel%
	AND SZ1.%NotDel%
	AND Z1_DTCOMPE = ' ' 
	AND SZ1.Z1_FILIAL = SE2.E2_FILIAL
	AND SZ1.Z1_PREFIXO = SE2.E2_PREFIXO
	AND SZ1.Z1_NUM = SE2.E2_NUM
	AND SZ1.Z1_PARCELA = SE2.E2_PARCELA // incluido por Wagner em 08.02.2021
	AND SZ1.Z1_FORNECE = SE2.E2_FORNECE
	AND SZ1.Z1_LOJA = SE2.E2_LOJA
	AND SE2.E2_EMIS1 >= %Exp:DTOS((dDataIni))% // incluido por Wagner em 08.02.2021
	AND SE2.E2_EMIS1 <= %Exp:DTOS((dDataFim))%
	ORDER BY SZ1.Z1_DTCOMPE
EndSQL

DbSelectArea('TSE2')
TSE2->(DBGOTOP())

Count To nRecs

If (!lSChedule)
	oProcess:SetRegua1(nRecs)
Endif	

DbSelectArea('TSE2')
TSE2->(DBGOTOP())
While TSE2->(!EOF())
	
	If (!lSChedule)
		oProcess:IncRegua1("Atualizacao da tabela SZ1..." )
	Endif	

	DbSelectArea("SE2")
    SE2->(DbGoTo(TSE2->SE2RECNO))
    IF SE2->(RECNO())==TSE2->SE2RECNO
    
		DbSelectArea("SZ1")
		SZ1->(DbGoTo(TSE2->SZ1RECNO))
		IF SZ1->(RECNO())==TSE2->SZ1RECNO
			RecLock("SZ1",.F.)
			If !Empty(Alltrim(SE2->E2_FATURA))
				If Alltrim(SE2->E2_FATURA) <> 'NOTFAT'
					dDataBx	:= DtBxFat(SE2->E2_FILIAL,SE2->E2_FATURA)
					SZ1->Z1_BAIXA	:= dDataBx
					SZ1->Z1_FATURA 	:= SE2->E2_FATURA
					SZ1->Z1_DTCOMPE := SE2->E2_XCOMPET
					SZ1->Z1_EMIS1   := SE2->E2_EMIS1
					SZ1->Z1_VENCTO  := SE2->E2_VENCREA
					SZ1->Z1_EMISSAO := SE2->E2_EMISSAO

					CONOUT("Dados do Titulo "+SE2->E2_NUM+;
					       " Fatura "+SE2->E2_FATURA+;
						   " Data "+DTOC(SE2->E2_EMIS1)+;
						" Fornecedor "+ SE2->E2_FORNECE+;
						" Atualizada "+;
						" RECNO " + ALLTRIM(STR( SE2->( RECNO() ) ) ) )
				EndIf
			Else
				SZ1->Z1_BAIXA 	:= SE2->E2_BAIXA
				SZ1->Z1_DTCOMPE := SE2->E2_XCOMPET
				SZ1->Z1_EMIS1   := SE2->E2_EMIS1
				SZ1->Z1_VENCTO  := SE2->E2_VENCREA
				SZ1->Z1_EMISSAO := SE2->E2_EMISSAO
				CONOUT("Dados do Titulo "+SE2->E2_NUM+;
						" Data "+DTOC(SE2->E2_EMIS1)+;
						" Fornecedor "+ SE2->E2_FORNECE+;
						" Atualizada "+;
						" RECNO " + ALLTRIM(STR( SE2->( RECNO() ) ) ) )
					
			EndIf
			SZ1->(MsUnlock())
		ENDIF		 	
	ENDIF
	   
	TSE2->(DbSkip())
	
End

Return

/*
	Consulta SE5 para analise da baixa
*/
Static Function DtBxFat(cFilTit,cNumTit) 

Local dDataBx := StoD("")

BeginSQL Alias 'DTIT'
	SELECT
	SE5.E5_DTDISPO
	FROM %Table:SE5% SE5,
	WHERE SE5.%NotDel%
	AND SE5.E5_FILIAL = %Exp:cFilTit%
	AND SE5.E5_NUMERO = %Exp:cNumTit%
	AND SE5.E5_MOTBX IN ('DEB','NOR')
	AND SE5.E5_SITUACA <> 'C'
	AND SE5.E5_TIPODOC IN ('VL')
	ORDER BY %Order:SE5%
EndSQL

DTIT->(DbGoTop())

Do While !DTIT->(EOF())
	dDataBx := STOD(DTIT->E5_DTDISPO)
	DTIT->(Dbskip())
EndDo

If VALTYPE(dDataBx) <> 'D'
	dDataBx	:= StoD("")
EndIf

DTIT->(dbCloseArea())

Return(dDataBx)

/*
	Criar Grupo de Perguntas da Rotina
*/
Static Function CriaSX1(cPerg)
Local aRegs :={}
Local i := 0, j := 0

AADD(aRegs,{cPerg,"01","Data De  ? "  ,"Data De  ? "   ,"Data De  ? "   ,"mv_ch1","D",08,0,0,"G","NaoVazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data Ate ? "  ,"Data Ate ? "   ,"Data Ate ? "   ,"mv_ch2","D",08,0,0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

DBSelectArea("SX1")
DBSetOrder(1)

For i:= 1 To Len(aRegs)
	If !DBSeek(Padr(cPerg,Len(X1_GRUPO))+aRegs[i,2])
		RecLock("SX1", .T.)
		For j := 1 To Len(aRegs[1])
			FieldPut(j,aRegs[i,j])
		Next
		MSUnlock()
	EndIf
Next

Return Nil
