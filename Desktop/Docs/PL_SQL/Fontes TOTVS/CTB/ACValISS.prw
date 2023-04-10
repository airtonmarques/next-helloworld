#INCLUDE "TOTVS.CH"
#include 'protheus.ch'
#include 'parmtype.ch'
#include "TopConn.ch"
#include "TBICONN.CH"
#include "TbiCode.ch"
#include "rwmake.CH"

#DEFINE CRLF CHR(13) + CHR(10)

User Function ACValISS(cChave)
//cChave - SF1->(F1_FORNECE+F1_LOJA+F1_SERIE+F1_DOC)
	Local _aArea 	:= GetArea()
	Local nValRet 	:= 0
//Local cForISS	:= Alltrim(GetMv("MV_MUNIC"))

	DbSelectArea("SD1")
	SD1->(DbGoTop())
	SD1->(DbSetOrder(01))//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
	dbSeek(xFilial()+cChave)
    While !Eof() .And. xFilial()+cChave == (SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
	
	nValRet += SD1->D1_VALISS
	
   		dbSkip()
	End

	RestArea(_aArea)

Return(nValRet)
