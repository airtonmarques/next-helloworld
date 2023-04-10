#include 'protheus.ch'
#include 'parmtype.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SF1100I   ºAutor  ³Microsiga           º Data ³  09/04/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tratamentos após a gravação das notas                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßß ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SF1100I() 
Local _x       := 1
Local _aAc9    := {}
Local aAreaSF1 := SF1->(GetArea())
Local aAreaSE2 := SE2->(GetArea())
Local aSED := SED->(GetArea())

If Existblock('ECOM011') .And. !IsIncallstack("MSEXECAUTO")//Dados para Pagamento
	
	U_ECOM011()
	
	If (inclui .or. altera) .AND. MsgYesNo("Deseja anexar documento ao título?","Banco de conhecimento")
		MsDocument("SF1", SF1->(Recno()), 4)//, xVar, nOper, aRecACB , lExcelConnect)
		
		DbSelectArea("AC9")
		AC9->(DbSetOrder(2)) //AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
		If AC9->(DbSeek(xFilial("AC9")+"SF1"+SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
			_cChave := AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT
			While AC9->(!Eof()) .and. _cChave == AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT
				aAdd(_aAc9,{AC9->AC9_CODOBJ, AC9->AC9_FILIAL})
				AC9->(DbSkip())
			End
			
			If Len(_aAC9)>0
				DbSelectArea("SE2")
				SE2->(DbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
				If SE2->(DbSeek(xFilial("SE2")+SF1->(F1_FORNECE+F1_LOJA+F1_PREFIXO+F1_DUPL)))
					While SF1->(F1_FORNECE+F1_LOJA+F1_SERIE+F1_DOC)==SE2->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM)
						For _x:=1 to Len(_aAC9)
							Reclock("AC9",.T.)
							AC9->AC9_FILIAL :=_aAC9[_x,2]
							AC9->AC9_FILENT := SE2->E2_FILIAL
							AC9->AC9_ENTIDA := "SE2"
							AC9->AC9_CODENT := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
							AC9->AC9_CODOBJ := _aAC9[_x,1]
							AC9->(MsUnlock())
						Next
						SE2->(DbSkip())
					End
				Endif
			Endif
		EndIf
	Endif
Endif
 

If IsInCallStack( "U_ECOM024" ) /*.Or. IsInCallStack( "U_ECOM099" ) */
	
	__nTotal := MaFisRet(,"NF_BASEDUP")
	__nIrf   := SF1->F1_IRRF    //MaFisRet(,"NF_VALIRR") **retorno da função fiscal incorreta
	__nPis   := SF1->F1_VALPIS  //MaFisRet(,"NF_VALPIS") **retorno da função fiscal incorreta
	__nCof   := SF1->F1_VALCOFI //MaFisRet(,"NF_VALCOF") **retorno da função fiscal incorreta
	__nCsl   := SF1->F1_VALCSLL //MaFisRet(,"NF_VALCSL") **retorno da função fiscal incorreta

	If __nTotal>0
		dbSelectArea("SE2")
		dbSetOrder(6)//E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, R_E_C_N_O_, D_E_L_E_T_
		dbGotop()
		If dbSeek( xFilial("SE2") + SF1->(F1_FORNECE+F1_LOJA+F1_PREFIXO+F1_DOC) )
			
			If SA2->A2_MINIRF=="1"
				Reclock("SE2",.F.)
				SE2->E2_VALOR := (SE2->E2_VALOR + SE2->E2_IRRF)-SF1->F1_IRRF
				SE2->E2_SALDO := (SE2->E2_SALDO + SE2->E2_IRRF)-SF1->F1_IRRF
				SE2->E2_VLCRUZ:= (SE2->E2_VALOR + SE2->E2_IRRF)-SF1->F1_IRRF
				SE2->E2_IRRF  := SF1->F1_IRRF
				MsUnlock()

				Reclock("SF1",.F.)
				SF1->F1_VALIRF := SF1->F1_IRRF
				MsUnlock()
			Else
				If SF1->F1_IRRF >= GetMv("MV_VLRETIR")
					Reclock("SE2",.F.)
					SE2->E2_VALOR := (SE2->E2_VALOR + SE2->E2_IRRF)-SF1->F1_IRRF
					SE2->E2_SALDO := (SE2->E2_SALDO + SE2->E2_IRRF)-SF1->F1_IRRF
					SE2->E2_VLCRUZ:= (SE2->E2_VALOR + SE2->E2_IRRF)-SF1->F1_IRRF
					SE2->E2_IRRF  := SF1->F1_IRRF
					MsUnlock()

					Reclock("SF1",.F.)
					SF1->F1_VALIRF := SF1->F1_IRRF
					MsUnlock()
				Endif	
			Endif	

		Else
		
			Aviso("Atenção","Titulo não localizado para nota fiscal "+SF1->F1_DOC,{"Ok"})
		
		Endif	
	Endif	


	dbSelectArea("SE2")
	dbSetOrder(6) //Filial+Fornecedor+Loja+Prefixo+Numero
	dbGotop()
	If dbSeek( xFilial("SE2") + SF1->(F1_FORNECE+F1_LOJA+F1_PREFIXO+F1_DOC) )
		While SE2->(!Eof()) .And. xFilial("SE2")+SF1->(F1_FORNECE+F1_LOJA+F1_PREFIXO+F1_DOC)==;
								SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM)

			aAreaSE2:= SE2->(GetArea())
			cChave  := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)

			dbSelectArea("SE2")
			dbSetOrder(17)//(prefixo+número+parcela+tipo+fornecedor+loja).
			If dbSeek(xFilial("SE2")+ cChave)
				While SE2->(!Eof()) .And. Alltrim(cChave) == Alltrim(SE2->E2_TITPAI)
					Reclock("SE2",.F.)
						If Alltrim(SE2->E2_NATUREZ)=="IRF"  
								SE2->E2_VALOR := SF1->F1_IRRF //nVlrIRRF
								SE2->E2_SALDO := SF1->F1_IRRF //nVlrIRRF
								SE2->E2_VLCRUZ:= SF1->F1_IRRF //nVlrIRRF
						Elseif 	Alltrim(SE2->E2_NATUREZ)=="PIS"
								SE2->E2_VALOR := __nPis 
								SE2->E2_SALDO := __nPis 
								SE2->E2_VLCRUZ:= __nPis 
						Elseif 	Alltrim(SE2->E2_NATUREZ)=="COFINS"
								SE2->E2_VALOR := __nCof 
								SE2->E2_SALDO := __nCof 
								SE2->E2_VLCRUZ:= __nCof 
						Elseif 	Alltrim(SE2->E2_NATUREZ)=="CSLL"	
								SE2->E2_VALOR := __nCsl 
								SE2->E2_SALDO := __nCsl 
								SE2->E2_VLCRUZ:= __nCsl 
						Endif
						SE2->E2_DATALIB := dDataBase
					MsUnlock()
					SE2->(dbSkip())
				End
			Endif
			RestArea(aAreaSE2)
			SE2->(dbSkip())
		End
	Else
		Aviso("Atenção","Titulo não localizado para nota fiscal "+SF1->F1_DOC,{"Ok"})
	Endif
Endif

RestArea(aAreaSF1)
RestArea(aAreaSE2)
RestArea(aSED)

Return()
