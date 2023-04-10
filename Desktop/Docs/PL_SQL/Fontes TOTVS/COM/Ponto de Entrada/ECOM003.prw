#include 'protheus.ch'
#include 'parmtype.ch'
/*
+-----------+-----------+-------+-------------------------------+------+------------+
| Programa  | ECOM003   | Autor | DFSSISTEMAS                   | Data | 24/04/2018 |
+-----------+-----------+-------+-------------------------------+------+------------+
| Descricao | Preencher o numero das NFEs de entrada com zeros a esquerda           |
|           | esquerda                                                              |
+-----------+-----------------------------------------------------------------------+
| Uso       | X3_VLDUSER do campo F1_DOC                                            |
|           | Sintaxe: If(Existblock('ECOM003'),ExecBlock('ECOM003',.F.,.F.,{}),.T.)|
+-----------+-----------------------------------------------------------------------+ 
*/
User Function ECOM003()

	Local lRet		:= .T.
	Local cNumNFE	:= &(ReadVar())
	
	If Val(cNumNFE) > 0
		cNFiscal := StrZero( Val(cNumNFE) , TamSX3("F1_DOC")[1] )
	Endif
	
Return lRet
