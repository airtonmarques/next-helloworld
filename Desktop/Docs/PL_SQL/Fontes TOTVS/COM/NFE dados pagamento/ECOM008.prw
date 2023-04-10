#include 'protheus.ch'
#include 'parmtype.ch'
/*
+-----------+-----------+-------+-------------------------------+------+------------+
| Programa  | ECOM008   | Autor | DFSSISTEMAS                   | Data | 20/07/2018 |
+-----------+-----------+-------+-------------------------------+------+------------+
| Descricao | Gravação dos dados de pagamento informados no momento da inclusão da  |
|           | NFE                                                                    |
+-----------+-----------------------------------------------------------------------+
| Uso       | Ponto de entrada MT100GE2                                             |
+-----------+-----------------------------------------------------------------------+ 
*/
user function ECOM008() 

	Local nX		:= 0

	For nX := 1 to len(aCpHPag)
		If SubStr(aCpHPag[nX],1,2) == 'E2'
			&("SE2->"+aCpHPag[nX]) := aPagtos[nParcPag,nX]
		Endif
	Next nX
	nParcPag ++
	
return
