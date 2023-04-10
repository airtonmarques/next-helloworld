#include 'protheus.ch'
#include 'parmtype.ch'
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | ECOM022   | Autor | DFSSISTEMAS | Data | 20/06/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Funcao para identificar se existem rubricas asso-   |
|           | ciadas a nota fiscal de entrada                     |
+-----------+-----------------------------------------------------+
| Uso       | LPs de notas fiscais de entrada                     | 
+-----------+-----------------------------------------------------+ 
*/
user function ECOM022()

	Local lRet := .F.
	
	cChaveSZ1 := SF1->(F1_PREFIXO+F1_DUPL+F1_FORNECE+F1_LOJA)
	//SZ1->(DbGoTop())
	SZ1->(DbOrderNickName('INDXSF1'))
	If SZ1->(dbSeek(xFilial('SZ1')+cChaveSZ1))
		lRet := .T.
	Endif

Return lRet