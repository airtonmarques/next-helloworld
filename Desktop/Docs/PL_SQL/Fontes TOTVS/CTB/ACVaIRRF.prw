#INCLUDE "TOTVS.CH"
#include 'protheus.ch'
#include 'parmtype.ch'
#include "TopConn.ch"
#include "TBICONN.CH"
#include "TbiCode.ch"
#include "rwmake.CH"

#DEFINE CRLF CHR(13) + CHR(10)

User Function ACValIRRF(cChave)
//cChave - SF1->(F1_FORNECE+F1_LOJA+F1_SERIE+F1_DOC)
Local _aArea 	:= GetArea() 
Local nValRet 	:= 0
//Local cForISS	:= Alltrim(GetMv("MV_MUNIC"))

DbSelectArea("SE2")
SE2->(DbGoTop())
SE2->(DbSetOrder(06))//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO                                                                                               
If SE2->(DbSeek(xFilial("SE2")+cChave))
	If SE2->E2_IRRF > 0	
		nValRet := SE2->E2_IRRF		
	EndIf
EndIf

RestArea(_aArea)

Return(nValRet)