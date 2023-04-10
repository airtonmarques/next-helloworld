#include 'protheus.ch'
#include 'parmtype.ch'
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | M460FIM   | Autor | DFSSISTEMAS | Data | 25/04/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Ponto de entrada após gravação das NFs de saída,    |
|           | fora da transação                                   |
+-----------+-----------------------------------------------------+
| Uso       | MATA460                                             | 
+-----------+-----------------------------------------------------+ 
*/
User Function M460FIM()

	Local cMsgNf := ""
	
	// 25/04/2018 - Preencher mensagem para notas NFe e NFSe
	If Existblock('EFAT001')
		cMsgNf := ExecBlock('EFAT001',.F.,.F.,{})
	Endif

Return cMsgNf