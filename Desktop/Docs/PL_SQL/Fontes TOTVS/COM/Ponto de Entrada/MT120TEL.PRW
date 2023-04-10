#include "Protheus.ch"

/*/{Protheus.doc}'MT120TEL'
'Adicioinar campos na tela do pedido de compras'
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
User Function MT120TEL()
/*
    Local oNewDialog:= PARAMIXB[1]
    Local aPosGet   := PARAMIXB[2]
    
    Public __cFiscal := CriaVar("C7_XREEMBO")
    Public __oFiscal

    if !INCLUI
        __cFiscal := SC7->C7_XREEMBO
    endif

    @ 060, aPosGet[2,5]-11.5 SAY "Reembolso " FONT oNewDialog:oFont OF oNewDialog PIXEL SIZE 050,006
    @ 061, aPosGet[2,6]-25  MSCOMBOBOX __oFiscal VAR __cFiscal ITEMS {"N=Nao" , "S=Sim"} SIZE 80,12 OF oNewDialog PIXEL VALID Pertence("SN")
*/
Return
