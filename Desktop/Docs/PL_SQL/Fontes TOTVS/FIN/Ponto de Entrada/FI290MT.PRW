#INCLUDE "TOTVS.CH"

/*/{Protheus.doc}'FI290MT'
'Ponto de Entrada para abrir tela antes de gravação da fatura'
@author Sergio Celestino
@since '01/04/2020'
@version 'P12.1.25 v.01'
@type function
@see ''
@obs ''
@param ''
@return ''
/*/

User Function FI290MT
Local lRet := .F.
Local lExecFun := IsInCallStack('u_FINALL01')

if Type("__LSHOWBROW")<>"U"
    If __lShowBrow .ANd. lExecFun
        lRet := .T.
    Endif
endif    

Return lRet