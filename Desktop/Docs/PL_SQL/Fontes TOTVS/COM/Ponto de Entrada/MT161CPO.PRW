#INCLUDE "TOTVS.CH"

USER FUNCTION MT161CPO
    Local nPag   := 1
    Local nProps := 1
    Local nItens := 1
    Local aAux   := {}

    Public __cForVenc := ""

    aPropostas := ParamIxb[1]
    aItens := ParamIxb[2]
    aRetPe := {}

    FWMsgRun(, {|| XA161AnIt(aItens, aPropostas, SC8->C8_NUM )  }, "Processando", "ordenando cotações...")

    aAux := aClone(aPropostas)

    For nPag := 1 To Len(aPropostas)
        For nProps := 1 To Len(aPropostas[nPag]) 
            If Len(aPropostas[nPag][nProps][1])>0
                cFornece := aPropostas[nPag][nProps][1][1]+aPropostas[nPag][nProps][1][2]
            Else
                cFornece := ""
            Endif
            nWin := 0
            For nItens := 1 To Len(aPropostas[nPag][nProps][2])
                If aPropostas[nPag][nProps][2][nItens][1]
                    nWin+=1
                Endif
            Next
            if aScan(aRetPe,{|x| Alltrim(x[1])==cFornece})==0
                aAdd(aRetPe,{cFornece,iif(Empty(cFornece),-1,nWin),nPag,nProps})
            Endif
        Next
    Next
    
    aSort(aRetPe,,,{|x,y| x[2] > y[2] })

    If Len(aRetPe)>0
        __cForVenc := aRetPe[1][1]
    Endif    

    nTotP := 0
    For nPag := 1 To Len(aAux)
        For nProps := 1 To Len(aAux[nPag])
            nTotP+=1
            aAux[nPag][nProps] := aPropostas[aRetPe[nTotP][3]][aRetPe[nTotP][4]]
        Next
    Next

Return {aAux,{},aItens,{}}

/*/{Protheus.doc} A161AnIt()
Realiza a análise da cotação pelo critério de item
 
@since 13/09/2019
@version 1.0
@return Nil
/*/
Static Function XA161AnIt(aItens, aPropostas, cNumCot)

    Local aVencedor	 := {'', '', '', 0, ''}
    Local aMinMaxPrc := {}
    Local aMinMaxPrz := {}
    Local aMinMaxNt  := {}

    Local cIdent 	 := ''
    Local cAliasAux	 := GetNextAlias()
    Local cWhereAux  := "% (C8_PRODUTO >= '" + MV_PAR01 + "'  AND C8_PRODUTO <= '" + MV_PAR02 + "' ) %"

    Local nScoreAux	 := 0
    Local lFirst	 := .T.

    Default aItens 		:= {}
    Default aPropostas 	:= {}
    Default cNumCot 	:= ""

    BeginSQL Alias cAliasAux

		SELECT		C8_PRODUTO,
					SC8.R_E_C_N_O_ SC8REC,
					C8_IDENT,
					C8_NUMPRO,
					C8_FORNECE,
					C8_LOJA,  										 
					C8_ITEM,
					C8_PRAZO,
					C8_PRECO,
					ISNULL(A5_NOTA, 0) A5NOTA
		FROM 		%Table:SC8% SC8
		LEFT JOIN 	%Table:SA5% SA5
		ON			SA5.A5_FILIAL  		= %xFilial:SA5%
					AND SA5.A5_FORNECE 	= SC8.C8_FORNECE
					AND A5_LOJA 		= SC8.C8_LOJA
					AND SA5.A5_PRODUTO  = SC8.C8_PRODUTO
					AND SA5.%NotDel%
		WHERE 		C8_FILIAL 		= %xFilial:SC8%
					AND C8_NUM 		= %Exp:cNumCot%
					AND %Exp:cWhereAux%
					AND SC8.%NotDel%
		ORDER BY 	C8_IDENT, C8_PRODUTO, C8_NUMPRO, C8_FORNECE, C8_LOJA, C8_FORNOME

    EndSQL

    While (cAliasAux)->(!EOF())

        If Empty(cIdent) .Or. cIdent <> (cAliasAux)->(C8_IDENT)

            If !Empty(cIdent)
                A161MarkW(aPropostas, aVencedor,, .F., @aItens)
            EndIf

            aVencedor[1] := ""
            aVencedor[2] := ""
            aVencedor[3] := ""
            aVencedor[4] := 0
            aVencedor[5] := ""
            lFirst		 := .T.
            cIdent := (cAliasAux)->(C8_IDENT)

            aMinMaxPrc := A161MMPrc((cAliasAux)->(C8_IDENT), (cAliasAux)->(C8_FORNECE), (cAliasAux)->(C8_LOJA), (cAliasAux)->(C8_NUMPRO), aPropostas, .F.)
            aMinMaxPrz := A161MinMax( 'C8_PRAZO', cNumCot, (cAliasAux)->(C8_IDENT),,,, .F. )
            aMinMaxNt  := A161MinMax( 'A5_NOTA' , cNumCot, (cAliasAux)->(C8_IDENT),,,, .F. )
        EndIf

        If (cAliasAux)->(C8_PRECO) > 0

            nVlTotIt := A161VlTIt((cAliasAux)->(C8_IDENT), (cAliasAux)->(C8_FORNECE), (cAliasAux)->(C8_LOJA), (cAliasAux)->(C8_NUMPRO), aPropostas)

            nScoreAux := A161Score(aMinMaxPrc, aMinMaxPrz, aMinMaxNt, nVlTotIt, (cAliasAux)->(C8_PRAZO), (cAliasAux)->(A5NOTA))

            If lFirst .Or. nScoreAux < aVencedor[4]
                aVencedor[1] := (cAliasAux)->(C8_IDENT)
                aVencedor[2] := (cAliasAux)->(C8_FORNECE)
                aVencedor[3] := (cAliasAux)->(C8_LOJA)
                aVencedor[4] := nScoreAux
                aVencedor[5] := (cAliasAux)->(C8_NUMPRO)
                lFirst := .F.
            EndIf

        EndIf

        (cAliasAux)->(DbSkip())

    EndDo
    A161MarkW(aPropostas, aVencedor,, .F., @aItens)
    FwFreeArray(aVencedor)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} A161MarkW()
Marca vencedor.
@since  12/11/2019
@version 1.0
@return nRegItens
/*/
//-------------------------------------------------------------------
Static Function A161MarkW(aPropostas, aVencedor, aScoreAux, lAnProp, aItens, lIntPCO)
    Local nX		:= 0
    Local nY		:= 0
    Local nZ		:= 0
    Local nPosIdPro	:= 0
    Local nPosIdIt  := 0
    Local nRecSC1	:= 0
    Local lFound	:= .F.
    Local aAreaSC1	:= SC1->(GetArea())
    Local aAreaSC8	:= SC8->(GetArea())

    Default aPropostas 	:= {}
    Default aVencedor 	:= {}
    Default aItens	 	:= {}
    Default aScoreAux   := {}
    Default lAnProp 	:= (MV_PAR04 == 2)
    Default lIntPCO		:= SuperGetMV("MV_PCOINTE",.F.,"2")=="1"

    SC1->(DbSetOrder(1))
    SC1->(DbGoTop())

    If ( (Len(aVencedor) > 0 .And. !Empty(aVencedor[1]) ) .Or. ( Len(aScoreAux) > 0 .And. !Empty(aScoreAux[1][1]) ) )
        For nX := 1 To Len(aPropostas)
            For nY := 1 To Len(aPropostas[nX])
                If Len(aPropostas[nX][nY][1]) > 0
                    If lAnProp //-- Análise por proposta
                        If (aPropostas[nX][nY][1][1] == aScoreAux[1][1]) .And. (aPropostas[nX][nY][1][2] == aScoreAux[1][2]) .And. (aPropostas[nX][nY][1][4] == aScoreAux[1][4])
                            For nZ := 1 To Len(aPropostas[nX][nY][2])
                                If !(aPropostas[nX,nY,2,nZ,8]) .And. (aPropostas[nX,nY,2,nZ,4] > 0)
                                    If lIntPCO
                                        nRecSC1 := A161RecSC1(aPropostas[nX,nY,2,nZ,9]) //-- Através da SC8 busca-se o RECNO da SC1
                                        If nRecSC1 > 0
                                            SC8->(DbGoTo(aPropostas[nX,nY,2,nZ,9])) //-- Posiciona na SC8 correspondente
                                            SC1->(DbGoTo(nRecSC1)) //-- Com a SC1 posicionada, aciona validação PCO
                                            If !A161PcoVld(aPropostas[nX,nY,2,nZ,1]) //-- Caso a validação PCO falhe, não marca o registro como vencedor e para o processamento
                                                PcoFreeBlq('000051')
                                                PcoFreeBlq('000052')
                                                aPropostas[nX,nY,2,nZ,1] := .F.
                                                lOkPCO := .F.
                                                Exit
                                            Else
                                                aPropostas[nX,nY,2,nZ,1] := .T. //-- Marca vencedor
                                                If Len(aItens) > 0 .And. nZ <= Len(aItens)
                                                    aItens[nZ][7] := aPropostas[nX,nY,2,nZ,4] //-- Atualiza valor total do item
                                                EndIf
                                            EndIf
                                        Else
                                            Help("", 1, "A161MarkW",, "Falha na integridade das tabelas SC1 (Solicitações de Compra) e SC8 (Cotações)", 1, 0) //--
                                            lOkPCO := .F.
                                            Exit
                                        EndIf
                                    Else
                                        aPropostas[nX,nY,2,nZ,1] := .T. //-- Marca vencedor
                                        If Len(aItens) > 0 .And. nZ <= Len(aItens)
                                            aItens[nZ][7] := aPropostas[nX,nY,2,nZ,4] //-- Atualiza valor total do item
                                        EndIf
                                    EndIf
                                EndIf
                            Next nZ
                            lFound := .T.
                            Exit
                        EndIf
                    Else //-- Análise por item
                        If (aPropostas[nX][nY][1][1] == aVencedor[2]) .And. (aPropostas[nX][nY][1][2] == aVencedor[3]) .And. (aPropostas[nX][nY][1][4] == aVencedor[5])
                            nPosIdPro := aScan(aPropostas[nX][nY][2], {|x| AllTrim(x[10]) == aVencedor[1]})
                            If nPosIdPro > 0 .And. !(aPropostas[nX,nY,2,nPosIdPro,8]) .And. (aPropostas[nX,nY,2,nPosIdPro,4] > 0)
                                If lIntPCO
                                    nRecSC1 := A161RecSC1(aPropostas[nX,nY,2,nPosIdPro,9]) //-- Através da SC8 busca-se o RECNO da SC1
                                    If nRecSC1 > 0
                                        SC8->(DbGoTo(aPropostas[nX,nY,2,nPosIdPro,9])) //-- Posiciona na SC8 correspondente
                                        SC1->(DbGoTo(nRecSC1)) //-- Com a SC1 posicionada, aciona validação PCO
                                        If !A161PcoVld(aPropostas[nX,nY,2,nPosIdPro,1]) //-- Caso a validação PCO falhe, não marca o registro como vencedor e para o processamento
                                            PcoFreeBlq('000051')
                                            PcoFreeBlq('000052')
                                            aPropostas[nX,nY,2,nPosIdPro,1] := .F.
                                        Else
                                            aPropostas[nX,nY,2,nPosIdPro,1] := .T.	//-- Marca vencedor
                                            If Len(aItens) > 0
                                                nPosIdIt := aScan(aItens, {|x| AllTrim(x[2]) == aVencedor[1]})
                                                If nPosIdIt > 0
                                                    aItens[nPosIdIt][7] := aPropostas[nX,nY,2,nPosIdPro,4] //-- Atualiza valor total do item
                                                EndIf
                                            EndIf
                                        EndIf
                                    Else
                                        Help("", 1, "A161MarkW",, "Falha na integridade das tabelas SC1 (Solicitações de Compra) e SC8 (Cotações)", 1, 0) //--
                                        lOkPCO := .F.
                                        Exit
                                    EndIf
                                Else
                                    aPropostas[nX,nY,2,nPosIdPro,1] := .T.	//-- Marca vencedor
                                    If Len(aItens) > 0
                                        nPosIdIt := aScan(aItens, {|x| AllTrim(x[2]) == aVencedor[1]})
                                        If nPosIdIt > 0
                                            aItens[nPosIdIt][7] := aPropostas[nX,nY,2,nPosIdPro,4] //-- Atualiza valor total do item
                                        EndIf
                                    EndIf
                                EndIf
                                lFound := .T.
                                Exit
                            EndIf
                        EndIf
                    EndIf
                Else
                    Loop
                EndIf
            Next nY
            If lFound
                Exit
            Endif
        Next nX
    EndIf

    RestArea(aAreaSC1)
    RestArea(aAreaSC8)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A161MMPrc()
 
@since 05/09/2019
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A161MMPrc(cIdt, cCodFor, cLojaFor, cNumPro, aProp, lAnProp)
    Local aPrcAux	 := {}
    Local aRet    	 := {}
    Local nX		 := 0
    Local nY		 := 0
    Local nZ		 := 0
    Local nPosId     := 0

    Default lAnProp  := (MV_Par04 == 2)
    Default cIdt  	 := ""
    Default cCodFor  := ""
    Default cLojaFor := ""
    Default cNumPro  := ""
    Default aProp 	 := {}

    //-- Posições do aPropostas que serão verificadas
    //-- Se for análise por proposta:
    //---- aPropostas[n,p,1,1 ]	: Cod Fornecedor
    //---- aPropostas[n,p,1,2 ]	: Loja
    //---- aPropostas[n,p,1,4 ]	: Proposta
    //---- aPropostas[n,p,1,7 ]	: Valor total (soma de nCusto dos itens)
    //-- Se for análise por item:
    //---- aPropostas[n,p,2,x,4]	: Valor total (nCusto)
    //---- aPropostas[n,p,2,x,10]	: Ident. (SC8->C8_IDENT)

    If lAnProp //-- Análise por proposta
        For nX := 1 to Len(aProp)
            For nY := 1 To Len(aProp[nX])
                If Len(aProp[nX][nY][1]) > 0
                    If aProp[nX][nY][1][7] > 0
                        aAdd(aPrcAux, {aProp[nX][nY][1][1] + aProp[nX][nY][1][2] + aProp[nX][nY][1][4], aProp[nX][nY][1][7]})
                    EndIf
                EndIf
            Next nY
        Next nX

        //-- Ordena os preços
        If Len(aPrcAux) > 0
            aSort(aPrcAux,,, {|a,b| a[2] < b[2]})
            aAdd(aRet, aPrcAux[1,2])
            aAdd(aRet, aPrcAux[Len(aPrcAux),2])
        EndIf

    Else //-- Análise por item
        For nX := 1 to Len(aProp)
            For nY := 1 To Len(aProp[nX])
                For nZ := 1 To Len(aProp[nX][nY][2])
                    If (aProp[nX][nY][2][nZ][10] == cIdt) .And. (aProp[nX][nY][2][nZ][4] > 0)
                        nPosId := aScan(aPrcAux, {|x| x[1] == aProp[nX][nY][2][nZ][10]})
                        If nPosId == 0
                            aAdd(aPrcAux, {aProp[nX][nY][2][nZ][10], {aProp[nX][nY][2][nZ][4]}})
                        Else
                            aAdd(aPrcAux[nPosId][2], aProp[nX][nY][2][nZ][4])
                        EndIf
                    EndIf
                Next nZ
            Next nY
        Next nX
        //-- Ordena os preços
        If Len(aPrcAux) > 0
            aSort(aPrcAux[1,2])
            aAdd(aRet, aPrcAux[1,2,1])
            aAdd(aRet, aPrcAux[1,2,Len(aPrcAux[1,2])])
        EndIf

    EndIf

Return aRet

/*/{Protheus.doc} A161MinMax()
Verificação de máximos e minimo para todos os critérios avaliados
@since 12/11/2019
@version 1.0
@return aMinMax
/*/
Static Function A161MinMax(cCampo, cNumCot, cIdent, cForn, cProd, cLoja, lAnProp)

    Local cAliasQry := GetNextAlias()
    Local aMinMax 	:= {}

    Default lAnProp := (MV_PAR04 == 2)

    cCampo := '%'+cCampo+'%'

    If lAnProp //-- Análise por proposta

        BeginSQL Alias cAliasQry
			
		SELECT 		MAX(%Exp:cCampo%) AS MAXIMO, 
					MIN(%Exp:cCampo%) AS MINIMO
		FROM 		%Table:SC8% SC8
		LEFT JOIN 	%Table:SA5% SA5
		ON 			SA5.A5_FILIAL 		= %xFilial:SA5%
					AND SA5.A5_FORNECE 	= SC8.C8_FORNECE
					AND SA5.A5_LOJA 	= SC8.C8_LOJA	
					AND SA5.A5_PRODUTO	= SC8.C8_PRODUTO
					AND SA5.%NotDel%
		WHERE 		SC8.C8_FILIAL 		= %xFilial:SC8% 
					AND SC8.C8_NUM		= %Exp:cNumCot%
					AND SC8.C8_PRECO 	> 0
					AND SC8.%NotDel%

        EndSQL

    Else //-- Análise por item

        BeginSQL Alias cAliasQry
				
		SELECT 		MAX(%Exp:cCampo%) AS MAXIMO, 
					MIN(%Exp:cCampo%) AS MINIMO
		FROM 		%Table:SC8% SC8
		LEFT JOIN 	%Table:SA5% SA5
		ON 			SA5.A5_FILIAL 		= %xFilial:SA5%
					AND SA5.A5_FORNECE 	= SC8.C8_FORNECE
					AND SA5.A5_LOJA 	= SC8.C8_LOJA	
					AND SA5.A5_PRODUTO	= SC8.C8_PRODUTO
					AND SA5.%NotDel%
		WHERE 		SC8.C8_FILIAL 		= %xFilial:SC8% 
					AND SC8.C8_NUM		= %Exp:cNumCot%
					AND SC8.C8_IDENT 	= %Exp:cIdent% 
					AND SC8.C8_PRECO 	> 0		
					AND SC8.%NotDel%

        EndSQL

    EndIf
    If !(cAliasQry)->(EOF())
        aAdd(aMinMax, (cAliasQry)->MINIMO)
        aAdd(aMinMax, (cAliasQry)->MAXIMO)
    EndIf
    (cAliasQry)->(DbCloseArea())

Return aMinMax
/*/{Protheus.doc} A161VlTIt()
Retorna valor total do item
@version 1.0
@return Nil
/*/
Static Function A161VlTIt(cIdt, cCodFor, cLojaFor, cNumProp, aProp)
    Local nRet 		 := 0
    Local nX		 := 0
    Local nY		 := 0
    Local nZ		 := 0

    Default cIdt 	 := ""
    Default cCodFor  := ""
    Default cLojaFor := ""
    Default cNumProp := ""
    Default aProp 	 := {}
    //-- Posições do aPropostas que serão verificadas
    //-- aPropostas[n,p,1,1 ]	: Cod Fornecedor
    //-- aPropostas[n,p,1,2 ]	: Loja
    //-- aPropostas[n,p,1,4 ]	: Proposta
    //-- aPropostas[n,p,2,x,4]	: Valor total (nCusto)
    //-- aPropostas[n,p,2,x,10]	: Ident. (SC8->C8_IDENT)
    For nX := 1 to Len(aProp)
        For nY := 1 To Len(aProp[nX])
            If Len(aProp[nX][nY][1]) > 0
                If aProp[nX][nY][1][1] == cCodFor .And. aProp[nX][nY][1][2] == cLojaFor .And. aProp[nX][nY][1][4] == cNumProp
                    For nZ := 1 To Len(aProp[nX][nY][2])
                        If (aProp[nX][nY][2][nZ][10] == cIdt) .And. (aProp[nX][nY][2][nZ][4] > 0)
                            nRet := aProp[nX][nY][2][nZ][4]
                            Exit
                        EndIf
                    Next nZ
                EndIf
                If nRet > 0
                    Exit
                EndIf
            EndIf
        Next nY
        If nRet > 0
            Exit
        EndIf
    Next nX

Return nRet

/*/{Protheus.doc} A161Score()
@since  12/11/2019
@version 1.0
@return nRegItens
/*/
Static Function A161Score(aMinMaxPrc, aMinMaxPrz, aMinMaxNt, nPreco, nPrazo, nNota)
    Local nPpreco 	:= mvPAR05
    Local nPprazo	:= mvPAR06
    Local nPnota	:= mvPAR07
    Local nScore	:= 0
    Local nLenPrc	:= 0
    Local nLenPrz	:= 0
    Local nLenNt	:= 0

    Default aMinMaxPrc 	:= {}
    Default aMinMaxPrz 	:= {}
    Default aMinMaxNt  	:= {}
    Default nPreco 	   	:= 0
    Default nPrazo		:= 0
    Default nNota 		:= 0

    nLenPrc := Len(aMinMaxPrc)
    nLenPrz := Len(aMinMaxPrz)
    nLenNt  := Len(aMinMaxNt)

    If nLenPrc > 0 .And. nLenPrc <= 2
        nScore	+=	nPpreco * ( (nPreco - aMinMaxPrc[1]) / (aMinMaxPrc[2] - aMinMaxPrc[1]) )
    EndIf
    If nLenPrz > 0 .And. nLenPrz <= 2
        nScore	+=	nPprazo * ( (nPrazo - aMinMaxPrz[1]) / (aMinMaxPrz[2] - aMinMaxPrz[1]) )
    EndIf
    If nLenNt > 0 .And. nLenNt <= 2
        nScore	+=	nPnota	* ( (aMinMaxNt[2] - nNota)   / (aMinMaxNt[2]  - aMinMaxNt[1])  )
    EndIf
Return nScore
/*/{Protheus.doc} A161RecSC1()
Retorna o RECNO da SC1 correspondente ao item da cotação
@since 29/11/2019
@version 1.0
@return lRet
/*/
Static Function A161RecSC1(nRecSC8)
    Local nRet := 0
    Local cAliasAux := GetNextAlias()

    Default nRecSC8 := SC8->(Recno())

    BeginSQL Alias cAliasAux
		SELECT 	SC1.R_E_C_N_O_ AS SC1RECNO
		FROM 	%Table:SC8% SC8
		JOIN 	%Table:SC1% SC1
		ON 		SC1.C1_FILIAL 		= %xFilial:SC1%
				AND SC1.C1_NUM		= SC8.C8_NUMSC
				AND SC1.C1_ITEM		= SC8.C8_ITEMSC
				AND SC1.%NotDel%
		WHERE 	SC8.R_E_C_N_O_ 		= %Exp:nRecSC8%
				AND SC8.%NotDel%
    EndSQL

    If (cAliasAux)->(!Eof())
        nRet := (cAliasAux)->SC1RECNO
    EndIf
    (cAliasAux)->(DbCloseArea())

Return nRet

/*{Protheus.doc} 
Valida bloqueios na integracao com SIGAPCO
@since 13/11/2015
@version P12.1.7
*/
Static Function A161PcoVld(lDeleta)
    Local aAreaAnt	:= GetArea()
    Local lRetPCO	:= .T.
    Local lRetorno	:= .T.

    Default lDeleta := .F.

    SCX->(dbSetOrder(1))
    If SCX->(MsSeek(xFilial("SCX")+SC1->(C1_NUM+C1_ITEM)))
        While SCX->(!Eof()) .And. SCX->(CX_FILIAL+CX_SOLICIT+CX_ITEMSOL) == xFilial("SCX")+SC1->(C1_NUM+C1_ITEM)

            lRetPCO := PcoVldLan('000051','03',,,lDeleta)	// Solicitacao de compras - Rateio por CC na cotacao
            If !lRetPCO
                lRetorno := .F.
            EndIf

            SCX->(DbSkip())
        End
    EndIf
    lRetPCO := PcoVldLan('000052','02',,,lDeleta)
    If !lRetPCO
        lRetorno := .F.
    EndIf
    RestArea(aAreaAnt)

Return lRetorno
