#INCLUDE "TOTVS.CH"

/*/{Protheus.doc}'F290CON'
'Ponto de Entrada para calculo co vencimento da parcela da fatura aglutinada.'
@author Oviio Consultoria
@since '01/04/2020'
@version 'P12.1.25 v.01'
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
User Function F290CON

Local nValor   := Paramixb[1]
Local cCond    := Paramixb[2]
Local lExecFun := IsInCallStack('u_FINALL01')

If Empty(cCond) .And. lExecFun 
    cCondicao := Alltrim(GetMv("OV_CONDFAT",,"001"))
    aVenc := Condicao(nValor,cCondicao,0)
else
    aVenc := Condicao(nValor,"001",0)
Endif

Return aVenc