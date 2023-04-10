#include 'protheus.ch'
#include 'parmtype.ch'
 
User Function MT100GE2() 
	Local aSED  := SED->(GetArea())
	Local aCols   	:= PARAMIXB[1]
	Local nOpc    	:= PARAMIXB[2]
	Local aHeadSE2	:= PARAMIXB[3]
	
	If Type('aPagtos') == "A" .and. Len(aPagtos) > 0 .and. Type('aCpHPag') == "A" .and. Len(aCpHPag) > 0
		lRet := ExecBlock('ECOM008',.F.,.F.,{aCols,nOpc,aHeadSE2})
	Endif

	If Type('aColsSZ1') == "A" .and. Len(aColsSZ1) > 0 
		lRet := ExecBlock('ECOM021',.F.,.F.,1)
	Endif
	
	SE2->E2_DATALIB := dDatabase

	RestArea(aSED)

Return Nil 
 