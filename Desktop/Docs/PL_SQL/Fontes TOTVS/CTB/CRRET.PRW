#include "rwmake.ch"

USER FUNCTION CRRET(cRet)

Local aArea
Local cTipo    := cRet
Local nValor := 0 

DbSelectArea("SE2")
aArea := GetArea()
DbSetOrder(1)
  IF DbSeek(xFilial("SE2")+SD1->D1_SERIE+SD1->D1_DOC+"01"+cTipo+SD1->D1_FORNECE+SD1->D1_LOJA)
	nValor := SE1->E1_VALOR
ENDIF
RestArea(aArea)
Return nValor