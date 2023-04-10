#INCLUDE "TOTVS.CH"  

User Function MT100AG
Local cRot1 := "U_ECOM024"
Local aSED  := SED->(GetArea())

If Type("nBaseIRR") <> "U" .And. IsInCallStack( cRot1 )
    nRet := MaFisRet(,"NF_TOTAL")
    If nBaseIRR>0
        nAlqIrr := MaFisRet(1,"IT_ALIQIRR")
        If nAlqIrr>0
		    nVlrIRRF :=  Round((nBaseIRR * nAlqIrr)/100,2)
        Endif    
        MaFisAlt("NF_BASEIRR",nBaseIRR,)
        MaFisAlt("NF_VALIRR" ,nVlrIRRF,)
        MaFisAlt("IT_BASEIRR", nBaseIRR , 1)
        MaFisAlt("IT_VALIRR" , nVlrIRRF , 1)
    Endif
Endif    	
					
If Type("nBasePis") <> "U" .And. IsInCallStack( cRot1 )
	If nBasePis>0
        nAlqPis  := MaFisRet(1,"IT_ALIQPIS")
		If nAlqPis>0
            nVlrPIS  :=  Round((nBasePis * nAlqPis )/100,2)
        Endif    
        MaFisAlt("NF_BASEPIS",nBasePis,)
        MaFisAlt("NF_VALPIS" ,nVlrPIS,)
        MaFisAlt("IT_BASEPIS", nBasePis , 1)
        MaFisAlt("IT_VALPIS" , nVlrPIS  , 1)
	Endif	
Endif    
					
If Type("nBaseCof") <> "U" .And. IsInCallStack( cRot1 )	
    If nBaseCof>0
        nAlqCof  := MaFisRet(1,"IT_ALIQCOF")
	    If nAlqCof>0
            nVlrCof  := Round((nBaseCof * nAlqCof )/100 ,2)
        Endif    
        MaFisAlt("NF_BASECOF",nBaseCof,)
        MaFisAlt("NF_VALCOF" ,nVlrCof,)
        MaFisAlt("IT_BASECOF", nBaseCof , 1)
        MaFisAlt("IT_VALCOF" , nVlrCof  , 1)
	Endif	
Endif                    

If Type("nBaseCsl") <> "U" .And. IsInCallStack( cRot1 )
	If nBaseCsl>0
        nAlqCSL  := MaFisRet(1,"IT_ALIQCSL")
        If nAlqCSL>0
		    nVlrCsl  := Round( (nBaseCsl * nAlqCSL)/100 , 2 )
        Endif    
        MaFisAlt("NF_BASECSL",nBaseCsl,)
        MaFisAlt("NF_VALCSL" ,nVlrCsl,)
        MaFisAlt("IT_BASECSL", nBaseCsl , 1)
        MaFisAlt("IT_VALCSL" , nVlrCsl , 1)
	Endif	
Endif
RestArea(aSED)
Return 
