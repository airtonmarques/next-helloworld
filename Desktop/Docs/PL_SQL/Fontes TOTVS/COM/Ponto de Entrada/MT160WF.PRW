#INCLUDE "TOTVS.CH"

User Function MT160WF
Local cNumCot := ParamIxb[1]
Local aArea   := SC8->(GetArea())

dbSelectArea("SC8")
dbSetOrder(1)
If dbSeek(xFilial("SC8")+cNumCot)
    Reclock("SC8",.F.)
    SC8->C8_MOTIVO := __cMotivo
    MsUnLock()
Endif

RestArea(aArea)

Return
