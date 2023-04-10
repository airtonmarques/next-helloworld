#include "rwmake.ch"

/*/{Protheus.doc}''
''
@author 
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
User Function MT120GOK
    Local lRet := .T.
    /*
    Local aArea		:= GetArea()
    Local _cNumped  := SC7->C7_NUM

    If Inclui .or. altera
        
        DbSelectArea("SC7")
        DbSetOrder(1)
        DbSeek(xFilial("SC7")+_cNumped)

        While !SC7->(Eof()) .And. SC7->C7_FILIAL + SC7->C7_NUM == xFilial("SC7")+_cNumped
            If Inclui .Or. Altera
                If Type("__cFiscal")=="C"
			        Reclock("SC7",.F.)
                    if Alltrim(Upper(FunName(0)))=="MATA121"
                        SC7->C7_XREEMBO := __cFiscal
                    Endif
                    MSUnlock()
		        Endif
            Endif
            SC7->(DbSkip())
        End
    Endif
    RestArea(aArea)
    */
Return lRet
