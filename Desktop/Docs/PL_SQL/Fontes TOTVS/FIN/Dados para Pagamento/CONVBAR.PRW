#INCLUDE "TOTVS.CH"

/*/{Protheus.doc}LDtoCB

Converte Linha Digitavel para Código de Barras

@author Ovio Consultoria
@since 11/03/2021
@version P12 
@param 	
@return	
/*/ 

User Function LDtoCB(cLinDigi)

Local cCodBar := ""
Local cLinDig := Alltrim(cLinDigi)

If Len(cLinDig) == 47
     cCodBar := SubStr(cLinDig,1,4)+ SubStr(cLinDig,33,15)+ SubStr(cLinDig,5,5)+ SubStr(cLinDig,11,10)+ SubStr(cLinDig,22,10)
EndIf

__lExec := IsInCallStack("U_ECOM011")
If __lExec
	If !Empty(cCodBar)
		aPagParc[ nCODBAR ] := cCodBar
		oCODBAR:Refresh()
		Return .T.
	Endif	
Endif

Return cCodBar


/*/{Protheus.doc} CBtoLD
Converter Codigo de Barras numerico para Linha Digitavel
@author Ovio Consultoria
@since 11/03/2021
@version V.01
@type function
/*/

User Function CBtoLD(cCodBar)

Local cCampo1 := ""
Local cCampo2 := ""
Local cCampo3 := ""
Local ccampo4 := ""
Local ccampo5 := ""
Local cDigita := Space( TamSx3("E2_LINDIG")[1] ) 

If Len(Alltrim(cCodBar))==44
	cCampo1 := substr(cCodBar,01,04) + substr(cCodBar,20,01)+substr(cCodBar,21,04)
	cCampo2 := substr(cCodBar,25,05) + substr(cCodBar,30,05)
	cCampo3 := substr(cCodBar,35,05) + substr(cCodBar,40,05)
	ccampo4 := substr(cCodBar,05,01)
	ccampo5 := substr(cCodBar,06,14)	// Vencimento + Valor
	
	cDigita :=	cCampo1 + Modulo10(cCampo1) + ;
				cCampo2 + Modulo10(cCampo2) + ;
				cCampo3 + Modulo10(cCampo3) + ;
				cCampo4 + ;
				cCampo5
Endif			
			
__lExec := IsInCallStack("U_ECOM011")
If __lExec
	If !Empty(cCodBar)
		aPagParc[ nLINDIG ] := cDigita
		oLINDIG:Refresh()
		Return .T.
	Endif	
Endif

Return(cDigita)
