#include 'protheus.ch'

/*/{Protheus.doc}'F290CHK'
'Ponto de Entrada para retornar filtro personalizado'
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
User Function F290CHK()
Local lExecFun := IsInCallStack('u_FINALL01')
Local aArea   := GetArea()
Local cFiltro := PARAMIXB
Local cHist := Space(250)

If !lExecFun
	DEFINE MSDIALOG oDLg FROM 0,0 TO 80,250 PIXEL TITLE "Informe o contrato "

	oTGet1  := TGet():New( 01,01,{|u| if(Pcount()>0,cHist:=u,cHist)} ,oDlg ,080 ,011,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cHist,,,,,,,"Contrato:",,,,,,)
	
	oBUTTON := tBUTTON():New(16,64,"Confirma",oDlg,{||oDlg:End()},40,10,,,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED

	If !Empty(cHist) 
			cFiltro += " AND E2_HIST LIKE('%"+Alltrim(cHist)+"%') "		
	ENDIF
Endif	

RestArea(aArea)

Return cFiltro
