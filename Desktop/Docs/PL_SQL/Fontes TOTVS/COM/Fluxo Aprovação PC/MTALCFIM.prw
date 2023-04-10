#include "protheus.ch"

User Function MTALCFIM()

_cNumSCR := Paramixb[1,1]
_cTipSCR := Paramixb[1,2]

_lRet     := .T.
_aArea    := GetArea()
_aAreaSCR := SCR->(GetArea())
_aAreaSAL := SAL->(GetArea())

_cChvSCR := xFilial("SCR") + _cTipSCR + Alltrim(_cNumSCR)
dbSelectArea("SCR")
SCR->(dbSetOrder(1))

dbSelectArea("SCR")
SCR->(dbGoTop())
If SCR->(dbSeek(_cChvSCR))
	While !SCR->(Eof()) .And. (SCR->(CR_FILIAL+CR_TIPO+Alltrim(CR_NUM)) == _cChvSCR)
		If SCR->CR_STATUS != "03" .And. SCR->CR_STATUS != "05"
			_lRet := .F.
		EndIf
        SCR->(dbSkip())
	EndDo
EndIf

RestArea(_aAreaSAL)
RestArea(_aAreaSCR)
RestArea(_aArea)

Return(_lRet)