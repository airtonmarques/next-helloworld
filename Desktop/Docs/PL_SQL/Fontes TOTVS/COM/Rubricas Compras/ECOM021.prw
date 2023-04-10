#include 'protheus.ch'
#include 'parmtype.ch'
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | ECOM021   | Autor | DFSSISTEMAS | Data | 20/06/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Execblock para gravacao das rubricas                |
|           |                                                     |
+-----------+-----------------------------------------------------+
| Uso       | Ponto de entrada MT100GE2                           | 
+-----------+------------------------------------- ----------------+ 
*/
user function ECOM021(nPercPar)

	Local nPosItem	:= 0
	Local nPosCod 	:= 0
	Local nPosDesc	:= 0
	Local nPosVal 	:= 0
	Local nX		:= 0
	Local nTotDupl	:= 0

	
	If IsIncallstack('u_MT100GE2')
		
		
		__nIrf   := SF1->F1_IRRF    //MaFisRet(,"NF_VALIRR") **retorno da função fiscal incorreta
		__nPis   := SF1->F1_VALPIS  //MaFisRet(,"NF_VALPIS") **retorno da função fiscal incorreta
		__nCof   := SF1->F1_VALCOFI //MaFisRet(,"NF_VALCOF") **retorno da função fiscal incorreta
		__nCsl   := SF1->F1_VALCSLL //MaFisRet(,"NF_VALCSL") **retorno da função fiscal incorreta
		
		nTotDupl := SF1->F1_VALBRUT - __nIrf - __nPis - __nCof - __nCsl

		// tratamento abatimento ISS ( NF C RETENCAO DE ISS )- Jackson
		If SF1->F1_ISS > 0 .And. SA2->A2_RECISS == "N" .And. SED->ED_CALCISS == "S" .And. SF4->F4_ISS == "S" .And. SF4->F4_LFISS $ "T|O|I"
			nTotDupl -= SF1->F1_ISS
		EndIf


		If nTotDupl>0 .And. Alltrim(SE2->E2_TIPO)=="NF"
			SE2->E2_IRRF   := SF1->F1_IRRF
			SE2->E2_VRETIRF:= SF1->F1_IRRF
			SE2->E2_PIS    := __nPis
			SE2->E2_COFINS := __nCof
			SE2->E2_CSLL   := __nCsl 
			SE2->E2_VALOR  := nTotDupl	//SF1->F1_VALBRUT - __nIrf - __nPis - __nCof - __nCsl
			SE2->E2_SALDO  := SE2->E2_VALOR
			SE2->E2_VLCRUZ := SE2->E2_VALOR
		Endif
		nPercPar	:= SE2->E2_VALOR / nTotDupl
	Else
		nPercPar	:= 1
	Endif

	nPosItem	:= aScan(aHeadSZ1,{|x|UPPER(Alltrim(x[2])) == "Z1_ITEM"})
	nPosCod 	:= aScan(aHeadSZ1,{|x|UPPER(Alltrim(x[2])) == "Z1_RUBRICA"})
	nPosDesc	:= aScan(aHeadSZ1,{|x|UPPER(Alltrim(x[2])) == "Z1_DESCRI"})
	nPosVal		:= aScan(aHeadSZ1,{|x|UPPER(Alltrim(x[2])) == "Z1_TOTAL"})
	
	If nPosCod > 0 .and. nPosVal > 0
		For nX := 1 to Len(aColsSZ1)
			
			nPercPar	:= Round(aColsSZ1[nX,nPosVal]/SF1->F1_VALBRUT,2)
			nValdesc    := Round((nPercPar * (__nIrf + __nPis + __nCof + __nCsl)),2)

			Reclock('SZ1',.T.)
				SZ1->Z1_FILIAL  := xFilial('SZ1') 
				SZ1->Z1_PREFIXO := SE2->E2_PREFIXO
				SZ1->Z1_NUM     := SE2->E2_NUM    
				SZ1->Z1_PARCELA := SE2->E2_PARCELA
				SZ1->Z1_TIPO    := SE2->E2_TIPO   
				SZ1->Z1_FORNECE := SE2->E2_FORNECE
				SZ1->Z1_LOJA    := SE2->E2_LOJA   
				SZ1->Z1_ITEM    := aColsSZ1[nX,nPosItem]  
				SZ1->Z1_RUBRICA := aColsSZ1[nX,nPosCod]
				SZ1->Z1_DESCRI  := aColsSZ1[nX,nPosDesc] 
				SZ1->Z1_TOTAL   := Round(aColsSZ1[nX,nPosVal] - nValdesc  , 2 )
				SZ1->Z1_EMIS1	:= SE2->E2_EMIS1
				SZ1->Z1_DTCOMPE	:= SE2->E2_XCOMPET
				SZ1->Z1_NOME	:= GetAdvFVal("SA2","A2_NOME",xFilial("SA2") + SE2->(E2_FORNECE+E2_LOJA),1)
			SZ1->(MsUnlock())
		Next nX
	Endif 
				
return
