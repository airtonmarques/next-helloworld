#include 'protheus.ch'
#include 'parmtype.ch'
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | F240SUMA  | Autor | DFSSISTEMAS | Data | 25/04/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Ponto de entrada para soma dos valores adicionais   |
|           | na geração do arquivo SISPAG                        |
+-----------+-----------------------------------------------------+
| Uso       | FINA240                                             | 
+-----------+-----------------------------------------------------+ 
*/
user function F240SUMA()

	Local nVlr := 0

	If ExistBlock("VALDOC")
		nVlr := ExecBlock("VALDOC",.F.,.F.,{})
	Endif
	
 Return nVlr
