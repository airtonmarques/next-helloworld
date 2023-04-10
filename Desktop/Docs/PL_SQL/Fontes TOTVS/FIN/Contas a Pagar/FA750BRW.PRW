#Include "Totvs.ch"

/*/{Protheus.doc}''
''
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
User Function FA750BRW
Local aRot := {}

If Existblock('FINALL01')
    aAdd( aRot,	{ "@Faturas sobre contratos" , "u_FINALL01" , 0 , 4 }) 
Endif    

Return aRot