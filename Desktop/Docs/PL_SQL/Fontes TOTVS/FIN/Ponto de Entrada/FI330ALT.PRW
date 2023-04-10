#Include "Totvs.ch"

User Function FI330ALT
Local __aTit := ParamIxb[1]

nValLim := Iif(nSaldo>nVAlSld,nVAlSld,nSaldo)

__aTit[Len(__aTit)][7]  := Iif(nSaldo>nVAlSld,nVAlSld,nSaldo)
__aTit[Len(__aTit)][22] := Transform(Iif(nSaldo>nVAlSld,nVAlSld,nSaldo),"@E 9,999,999.99")

Return __aTit
