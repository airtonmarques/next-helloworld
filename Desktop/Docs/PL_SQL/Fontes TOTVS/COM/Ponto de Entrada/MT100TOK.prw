#include 'protheus.ch'
#include 'parmtype.ch'

user function MT100TOK()
	Local aSED := SED->(GetArea())
	Local lRet 		:= ParamIXB[1]
	Local nPosTot	:= 0
	Local nTotal	:= 0
	Local lExecPE   := IsInCallStack("MATA920")
	
	lMT100TOK := .F.
	
	If !lExecPE
		If !l103Auto
			If lRet .and. Existblock('ECOM020') .and. Existblock('ECOM021') 
				lRet := ExecBlock('ECOM020',.F.,.F.,{3})
			Endif
			//Chama a tela de valor líquido
			If lRet
				If !IsinCallStack("ECOM024")
					lRet := U_VLLIQNFE()	
				Endif	
			Endif
			
		EndIf
	Endif	
	
	RestArea(aSED)

return lRet
