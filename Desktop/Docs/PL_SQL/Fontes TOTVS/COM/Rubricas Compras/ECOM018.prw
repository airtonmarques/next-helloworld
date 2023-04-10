#include 'protheus.ch'
#include 'parmtype.ch'
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | ECOM018   | Autor | DFSSISTEMAS | Data | 20/06/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Execblock para contabilizacao das rubricas na exclu-|
|           | sao da NFE, substituindo o array da contabilizacao  |
|           | pelo gerado no execblock ECOM019                    |
+-----------+-----------------------------------------------------+
| Uso       | LPs de notas fiscais de entrada                     | 
+-----------+-----------------------------------------------------+ 
*/
user function ECOM018()

	Local aCtbInf		:= ParamIXB[1]
	Local l103Exclui	:= ParamIXB[2]
	Local lExcCmpAdt	:= ParamIXB[3]
						
	If l103Exclui
		aCtbInf := aCtbExcRb
	Endif
							
return aCtbInf