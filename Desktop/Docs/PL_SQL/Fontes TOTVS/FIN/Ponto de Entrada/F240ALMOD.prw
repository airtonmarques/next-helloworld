#include 'protheus.ch'
#include 'parmtype.ch'

user function F240ALMOD()
Local cModelo := ParamIxb[1]

If cModelo == "91" // Novo Modelo
   cModelo :=  "13"
Endif
return(cModelo)
