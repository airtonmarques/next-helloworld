#include 'protheus.ch'
#include 'parmtype.ch'

user function MT103NTZ()
	
Local cRet   := Iif(l103Auto,_cNaturez,ParamIxb[1])    // Rotina do usuário para g eração das Pré-Requisições.

Return(cRet) 
