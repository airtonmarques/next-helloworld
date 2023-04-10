#INCLUDE "TOTVS.CH"

/*/{Protheus.doc}'MATA131'
'Ponto de Entrada após a gravação do Model na geração da cotação - MATA131'
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
Static aCot := {}

User Function MATA131()
Local aParam     := PARAMIXB
Local xRet       := .T.
Local oObj       := Nil
Local cIdPonto   := ''
Local cIdModel   := ''
Local cNumCot    := ''

If aParam <> NIL
    oObj       := aParam[1]
    cIdPonto   := aParam[2]
    cIdModel   := aParam[3]
    If cIdPonto == 'FORMCOMMITTTSPOS'
        cNumCot := oObj:GetValue("C8_NUM")
        if aScan(aCot,cNumCot)==0
            aAdd(aCot,cNumCot)
            ApMsgInfo('Cotação número ' + cNumCot + " gerada com sucesso.")
        Endif    
    Endif
Endif      

Return xRet
