#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc}''
''
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
User Function MT120BRW
    
    aAdd( aRotina ,{ "Enviar Pedido de Compra","U_ALLRPC01"    , 0, 1, 0, Nil })
    AAdd( aRotina, { 'Reenvio WF'             , 'u_ACWFA005()' , 0, 4, 0, Nil })

Return
