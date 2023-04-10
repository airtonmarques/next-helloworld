#include 'protheus.ch'
#include 'parmtype.ch'
#include "FWMVCDEF.CH"
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | ECOM017   | Autor | DFSSISTEMAS | Data | 20/06/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Tela para cadastro das rubricas                     |
|           |                                                     |
+-----------+-----------------------------------------------------+
| Uso       | Menu do modulo de compras                           | 
+-----------+-----------------------------------------------------+ 
*/
user function ECOM017()
	
	Local oBrowse

	If !AliasInDic("SZ0")
		Alert("Tabela SZ0 inexistente. Favor atualizar o dicionário de dados.")
		Return
	EndIf
	
	NEW MODEL ;
	TYPE 1 ;
	DESCRIPTION "Rúbricas" ;
	BROWSE oBrowse ;
	SOURCE "ECOM017" ;
	MODELID "ECOM017MVC" ;
	MASTER "SZ0"

Return NIL
	


