#include 'protheus.ch'
#include 'parmtype.ch'

user function MT103NTZ()
	
Local cRet   := Iif(l103Auto,_cNaturez,ParamIxb[1])    // Rotina do usu�rio para g era��o das Pr�-Requisi��es.

Return(cRet) 
