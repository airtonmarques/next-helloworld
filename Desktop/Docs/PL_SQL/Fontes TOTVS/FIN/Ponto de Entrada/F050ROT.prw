#include 'protheus.ch'
#include 'parmtype.ch'

user function F050ROT()
	
	Local aRet := PARAMIXB
	
	Aadd(aRet, { 'Anexos'				,"MSDOCUMENT", 0, 4 })
	If Existblock('ECOM011')
		aAdd( aRet , { '@Dados para Pagamento', "u_ECOM011", 0, 0, 0, NIL } )
	Endif
	If Existblock('ECOM020')
		aAdd( aRet , { '@Rúbricas informadas', "u_ECOM020", 0, 2, 0, NIL } )
	Endif
	If Existblock('FINALL01')
		aAdd( aRet,	{ "@Faturas sobre contratos" , "u_FINALL01", 0, 0 ,4, Nil } ) 
	Endif	
	
	
return aRet