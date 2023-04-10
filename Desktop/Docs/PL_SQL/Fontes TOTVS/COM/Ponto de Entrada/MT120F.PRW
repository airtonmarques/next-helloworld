#Include "Totvs.ch"


User Function MT120F()
Local __cNumPed  := ParamIxb
Local __aAreaSC7 := SC7->(GetArea()) 


If Type("__xcObs")<>"U"
    If !Empty(__xcObs)
        dbSelectArea("SC7")
        dbSetOrder(1)
        If dbSeek(__cNumPed)
            While SC7->(!Eof()) .And. __cNumPed == SC7->C7_FILIAL+SC7->C7_NUM
                Reclock("SC7",.F.)
                SC7->C7_XMOTALT := __xcObs
                MsUnlock()
                SC7->(dbSkip())
            End
        Endif        
    Endif    
Endif

RestArea(__aAreaSC7)

Return
