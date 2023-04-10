#include 'protheus.ch'
#include 'parmtype.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FA290    ºAutor  ³DFS SISTEMAS        º Data ³  08/06/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FA290()

Local lExecFun := IsInCallStack('u_FINALL01')
Local aAreaSE2 := {}
Local _cFatura := ""
Local _LinDigi := ""
Local _cContra := ""
Local dFatorVc := CtoD("07/10/1997")
Local _LastBlo := ""
Local dVencBol := dDataBase
Local lVencBol := GETMV("OV_VENCBOL",,.F.)

If Existblock('ECOM011') .And. !lExecFun
	u_ECOM011()
Elseif lExecFun
  	If Type("aFatLog")=="A"
		
		aAdd( aFatLog, { SE2->E2_PREFIXO ,; 
						 SE2->E2_NUM,;
						 SE2->E2_PARCELA,;
						 SE2->E2_NUM,;
						 SE2->E2_XCONTRA,;
						 SE2->E2_VENCREA,;
						 SE2->E2_VALOR,;
						 SE2->E2_FORNECE,;
						 SE2->E2_LOJA })
		
		_cFatura := SE2->E2_NUM

		aAreaSE2 := SE2->(GetArea())
		dbSelectArea("SE2")
		dbSetOrder(20)
		If dbSeek( xFilial("SE2") + _cFatura )
			_LinDigi := SE2->E2_LINDIG
			_cContra := SE2->E2_XCONTRA
			_LastBlo := RIGHT(Alltrim(_LinDigi),14)
			if lVencBol
				dVencBol := dFatorVc + Val(Substr(_LastBlo,1,4))
			Else
				dVencBol := SE2->E2_VENCTO
			endif	
		Endif
		RestArea(aAreaSE2)	
		
		Reclock("SE2",.F.)
		SE2->E2_LINDIG := _LinDigi
		SE2->E2_BCOPAG := Substr(_LinDigi,1,3)
		SE2->E2_FORMPAG:= "30"
		SE2->E2_XCONTRA:= _cContra
		SE2->E2_VENCTO := dVencBol
		SE2->E2_VENCORI:= dVencBol
		SE2->E2_VENCREA:= DataValida(dVencBol)
		MsUnlock()
		aFatLog[Len(aFatLog)][6] := DataValida(dVencBol)
	Endif				  
EndIf

Return()