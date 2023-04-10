#INCLUDE "TOTVS.CH"
#include 'protheus.ch'
#include 'parmtype.ch'
#include "TopConn.ch"
#include "TBICONN.CH"
#include "TbiCode.ch"
#include "rwmake.CH"


User Function ACATUSZ1()

Local dDataBx := StoD("")
//Local aTables := {"SZ1"}
//Local dDataIni := date()-90
//Local dDataFim := date()

//seta o ambiente com a empresa 99 filial 01 com os direitos do usuario administrador
//RpcSetEnv( "01","0101", "Administrador", " ", "FIN", , aTables, , , ,  )
PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101"


If Select('TSE2') > 0
	TFAT->(dbCloseArea())
EndIf

BeginSQL Alias 'TSE2'
	SELECT
	SE2.E2_FILIAL, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA, SE2.E2_TIPO, SE2.E2_FORNECE, SE2.E2_LOJA, SE2.R_E_C_N_O_ SE2RECNO, SZ1.R_E_C_N_O_ SZ1RECNO
	FROM %Table:SE2% SE2, %Table:SZ1% SZ1
	WHERE SE2.%NotDel%
	AND SZ1.%NotDel%
	AND SZ1.Z1_FILIAL = SE2.E2_FILIAL
	AND SZ1.Z1_PREFIXO = SE2.E2_PREFIXO
	AND SZ1.Z1_NUM = SE2.E2_NUM
	AND SZ1.Z1_PARCELA = SE2.E2_PARCELA // incluido por Wagner em 08.02.2021
	AND SZ1.Z1_FORNECE = SE2.E2_FORNECE
	AND SZ1.Z1_LOJA = SE2.E2_LOJA
	//AND SE2.E2_EMISSAO >= %Exp:DTOS((dDatabase-365))%
	//AND SE2.E2_EMISSAO >= %Exp:DTOS((dDatabase-365))% // incluido por Wagner em 08.02.2021
	//AND SE2.E2_EMISSAO <= %Exp:DTOS((dDatabase))%
	AND SE2.E2_EMIS1 >= %Exp:DTOS((dDatabase-365))% // incluido por Wagner em 08.02.2021
	AND SE2.E2_EMIS1 <= %Exp:DTOS((dDatabase))%
	ORDER BY %Order:SE2%
EndSQL

DbSelectArea('TSE2')

Do While TSE2->(!EOF())
	DbSelectArea("SE2")
    SE2->(DbGoTo(TSE2->SE2RECNO))
    
    
    DbSelectArea("SZ1")
    SZ1->(DbGoTo(TSE2->SZ1RECNO))
    
 	RecLock("SZ1",.F.)
	If !Empty(Alltrim(SE2->E2_FATURA))
 		If Alltrim(SE2->E2_FATURA) <> 'NOTFAT'
			//dDataBx	:= GetAdvFVal("SE2","E2_BAIXA",SE2->E2_FILIAL+SE2->E2_FATPREF+SE2->E2_FATURA+SE2->E2_PARCELA+SE2->E2_TIPOFAT+SE2->E2_FATFOR+SE2->E2_FATLOJ,1,STOD(""))
 			dDataBx	:= DtBxFat(SE2->E2_FILIAL,SE2->E2_FATURA)
 			SZ1->Z1_BAIXA	:= dDataBx
 			SZ1->Z1_FATURA 	:= SE2->E2_FATURA
 			SZ1->Z1_DTCOMPE := SE2->E2_XCOMPET
 			SZ1->Z1_EMIS1   := SE2->E2_EMIS1
 			SZ1->Z1_VENCTO  := SE2->E2_VENCREA
 			SZ1->Z1_EMISSAO := SE2->E2_EMISSAO
 			CONOUT("Dados do Titulo "+SE2->E2_NUM+" Fatura "+SE2->E2_FATURA+" Data "+DTOC(SE2->E2_EMIS1)+" Fornecedor "+ SE2->E2_FORNECE+" Atualizada ")
 		EndIf
	Else
	 	SZ1->Z1_BAIXA 	:= SE2->E2_BAIXA
	 	SZ1->Z1_DTCOMPE := SE2->E2_XCOMPET
	 	SZ1->Z1_EMIS1   := SE2->E2_EMIS1
	 	SZ1->Z1_VENCTO  := SE2->E2_VENCREA
	 	SZ1->Z1_EMISSAO := SE2->E2_EMISSAO
	 	CONOUT("Dados do Titulo "+SE2->E2_NUM+" Data "+DTOC(SE2->E2_EMIS1)+" Fornecedor "+ SE2->E2_FORNECE+" Atualizada ")
 			
 	EndIf
 	SZ1->(MsUnlock())	 	
	
	//CONOUT("Dados do Titulo "+SE2->E2_NUM+" Data "+DTOC(SE2->E2_EMIS1)+"  N�o Atualizada ")	
    
	TSE2->(DbSkip())
	SE2->(DbCloseArea())
	SZ1->(DbCloseArea())
EndDo

CONOUT("Atualizacao Finalizada")	

//RpcClearEnv() //Limpa o ambiente, liberando a licen�a e fechando as conex�es  

Return

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
