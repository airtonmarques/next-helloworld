#include 'protheus.ch'
#include 'parmtype.ch'

#DEFINE CRLF CHR(13) + CHR(10)

/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | ECOM023   | Autor | DFSSISTEMAS | Data | 20/06/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Execblock para contabilizacao das rubricas associ-  |
|           | adas as notas fiscais de entrada                    |
+-----------+-----------------------------------------------------+
| Uso       | LPs de notas fiscais de entrada                     | 
+-----------+-----------------------------------------------------+ 
*/
user function ECOM023(nOp)

	Local nHdlPrv		:= 0
	Local cPadrao		:= ''
	Local nTotalLcto	:= 0 
	Local cArquivo		:= ''
	Local nRecSZ1		:= 0
	
	If IsInCallStack('u_SD1100E')
		nOp := 2
	Endif
	If nOP == 1
		cPadrao := GetNewPar('MV_XLPRBI','100')
	Else
		cPadrao := GetNewPar('MV_XLPRBE','101')
	Endif
	cChaveSZ1 := SF1->(F1_PREFIXO+F1_DUPL+F1_FORNECE+F1_LOJA)
	SZ1->(DbOrderNickName('INDXSF1'))
	If SZ1->(dbSeek(xFilial('SZ1')+cChaveSZ1))
		lCtbOnLine := .T.
		DbSelectArea("SX5")
		DbSetOrder(1)
		MsSeek(xFilial("SX5")+"09COM")
		cLote := IIf(Found(),Trim(X5DESCRI()),"COM ")
		If At(UPPER("EXEC"),X5Descri()) > 0
			cLote := &(X5Descri())
		EndIf
		nHdlPrv := HeadProva(cLote,"ECOM023",Subs(cUsuario,7,6),@cArquivo)
		If nHdlPrv <= 0
			lCtbOnLine := .F.
		EndIf
		If lCtbOnLine .and. VerPadrao(cPadrao)
			SA2->(DbSetOrder(1))
			SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
			nTotalLcto := 0
			VALOR 	:= 0
			DEBITO 	:= ""
			CREDITO := ""
			TOTAL	:= 0
			// Contabiliza Rubricas						
			//While !SZ1->(EOF()) .and. SZ1->(Z1_PREFIXO+Z1_NUM+Z1_FORNECE+Z1_LOJA) == cChaveSZ1
				SZ0->(dbSetOrder(1))
				SZ0->(dbSeek(xFilial("SZ0")+SZ1->Z1_RUBRICA))
				
				cAliasSZ1 := GetNextAlias()
				cQuery := ""
				cQuery+= "SELECT DEBITO, CREDITO, SUM(TOTAL) VALOR FROM (                                      		"+CRLF
				cQuery+= "        SELECT                                                                          	"+CRLF
				cQuery+= "            Z1_FILIAL,Z1_NUM NF,Z0_CONTAD DEBITO,' ' CREDITO,Z1_TOTAL TOTAL             	"+CRLF
				cQuery+= "        FROM                                                                            	"+CRLF
				cQuery+= "           SZ1010 Z1, SZ0010 Z0                    										"+CRLF
				cQuery+= "        WHERE                                                                           	"+CRLF
				cQuery+= "          Z1.D_E_L_E_T_ <> '*' AND Z0.D_E_L_E_T_ <> '*' AND Z1_RUBRICA = Z0_RUBRICA   	"+CRLF
				cQuery+= "          AND Z1_FILIAL = '"+SZ1->Z1_FILIAL+"' AND Z1_PREFIXO = '"+SZ1->Z1_PREFIXO+"'    	"+CRLF
				cQuery+= "          AND Z1_NUM = '"+SZ1->Z1_NUM+"'      											"+CRLF
				cQuery+= "          AND Z1_TIPO = '"+SZ1->Z1_TIPO+"' AND Z1_PARCELA = '"+SZ1->Z1_PARCELA+"'        	"+CRLF
				cQuery+= "          AND Z1_FORNECE = '"+SZ1->Z1_FORNECE+"' AND Z1_LOJA = '"+SZ1->Z1_LOJA+"'			"+CRLF
				cQuery+= "          AND Z0_RN <> 'S'						                   						"+CRLF
				cQuery+= "        UNION ALL                                                                       	"+CRLF
				cQuery+= "        SELECT                                                                          	"+CRLF
				cQuery+= "            Z1_FILIAL,Z1_NUM NF,' ' DEBITO,Z0_CONTAC CREDITO,Z1_TOTAL TOTAL             	"+CRLF
				cQuery+= "        FROM                                                                            	"+CRLF
				cQuery+= "            SZ1010 Z1, SZ0010 Z0                    										"+CRLF
				cQuery+= "        WHERE                                                                           	"+CRLF
				cQuery+= "          Z1.D_E_L_E_T_ <> '*' AND Z0.D_E_L_E_T_ <> '*' AND Z1_RUBRICA = Z0_RUBRICA   	"+CRLF
				cQuery+= "          AND Z1_FILIAL = '"+SZ1->Z1_FILIAL+"' AND Z1_PREFIXO = '"+SZ1->Z1_PREFIXO+"'    	"+CRLF
				cQuery+= "          AND Z1_NUM = '"+SZ1->Z1_NUM+"'      											"+CRLF
				cQuery+= "          AND Z1_TIPO = '"+SZ1->Z1_TIPO+"' AND Z1_PARCELA = '"+SZ1->Z1_PARCELA+"'        	"+CRLF
				cQuery+= "          AND Z1_FORNECE = '"+SZ1->Z1_FORNECE+"' AND Z1_LOJA = '"+SZ1->Z1_LOJA+"'			"+CRLF
				cQuery+= "          AND Z0_RN <> 'S'						                   						"+CRLF
				cQuery+= "        UNION ALL                                                                       	"+CRLF
				cQuery+= "        SELECT                                                                          	"+CRLF
				cQuery+= "            Z1_FILIAL,Z1_NUM NF,' ' DEBITO,Z0_CONTAD CREDITO,Z1_TOTAL*-1 TOTAL          	"+CRLF
				cQuery+= "        FROM                                                                            	"+CRLF
				cQuery+= "            SZ1010 Z1, SZ0010 Z0                    										"+CRLF
				cQuery+= "        WHERE                                                                           	"+CRLF
				cQuery+= "          Z1.D_E_L_E_T_ <> '*' AND Z0.D_E_L_E_T_ <> '*' AND Z1_RUBRICA = Z0_RUBRICA   	"+CRLF
				cQuery+= "          AND Z1_FILIAL = '"+SZ1->Z1_FILIAL+"' AND Z1_PREFIXO = '"+SZ1->Z1_PREFIXO+"'    	"+CRLF
				cQuery+= "          AND Z1_NUM = '"+SZ1->Z1_NUM+"'      											"+CRLF
				cQuery+= "          AND Z1_TIPO = '"+SZ1->Z1_TIPO+"' AND Z1_PARCELA = '"+SZ1->Z1_PARCELA+"'        	"+CRLF
				cQuery+= "          AND Z1_FORNECE = '"+SZ1->Z1_FORNECE+"' AND Z1_LOJA = '"+SZ1->Z1_LOJA+"'			"+CRLF
				cQuery+= "          AND Z0_RN = 'S'							                   						"+CRLF
				cQuery+= "        UNION ALL                                                                       	"+CRLF
				cQuery+= "        SELECT                                                                          	"+CRLF
				cQuery+= "            Z1_FILIAL,Z1_NUM NF,' ' DEBITO,Z0_CONTAC CREDITO, Z1_TOTAL TOTAL            	"+CRLF
				cQuery+= "        FROM                                                                            	"+CRLF
				cQuery+= "            SZ1010 Z1, SZ0010 Z0                    										"+CRLF
				cQuery+= "        WHERE                                                                           	"+CRLF
				cQuery+= "          Z1.D_E_L_E_T_ <> '*' AND Z0.D_E_L_E_T_ <> '*' AND Z1_RUBRICA = Z0_RUBRICA   	"+CRLF
				cQuery+= "          AND Z1_FILIAL = '"+SZ1->Z1_FILIAL+"' AND Z1_PREFIXO = '"+SZ1->Z1_PREFIXO+"'    	"+CRLF
				cQuery+= "          AND Z1_NUM = '"+SZ1->Z1_NUM+"'      											"+CRLF
				cQuery+= "          AND Z1_TIPO = '"+SZ1->Z1_TIPO+"' AND Z1_PARCELA = '"+SZ1->Z1_PARCELA+"'        	"+CRLF
				cQuery+= "          AND Z1_FORNECE = '"+SZ1->Z1_FORNECE+"' AND Z1_LOJA = '"+SZ1->Z1_LOJA+"'			"+CRLF
				cQuery+= "          AND Z0_RN = 'S'							                   						"+CRLF
				cQuery+= "                                                                                        	"+CRLF
				cQuery+= " ) TRB                                                                                  	"+CRLF
				cQuery+= " GROUP BY DEBITO, CREDITO                                                           		"+CRLF
				cQuery+= " ORDER BY DEBITO, CREDITO                                                               	"+CRLF
				
				
				If Select(cAliasSZ1) > 0
					(cAliasSZ1)->(dbCloseArea())
				EndIf
	
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSZ1,.T.,.T.)
				
				DbSelectArea(cAliasSZ1)
				(cAliasSZ1)->(DbGoTop())
				While !(cAliasSZ1)->(EOF()) 
					If (cAliasSZ1)->VALOR > 0
						VALOR 	:= (cAliasSZ1)->VALOR
						DEBITO 	:= (cAliasSZ1)->DEBITO
						CREDITO := (cAliasSZ1)->CREDITO
						//TOTAL	+= IIF(SUBSTR(CREDITO,1,1)=='2',VALOR,0)
						nTotalLcto += DetProva(nHdlPrv,cPadrao,"ECOM023",cLote)
					Else
						VALOR := 0
						DEBITO := ""
						CREDITO := ""
					EndIf 
					(cAliasSZ1)->(DbSkip())
				EndDo
				
				cQuery := ""
				cAliasIMP := GetNextAlias()
				
				cQuery += " SELECT "+CRLF
				cQuery += " 	Z1_FILIAL,Z1_NUM NF, Z0_CONTAC CREDITO "+CRLF
				cQuery += " FROM "+CRLF
				cQuery += " 	DADOSP12_PRODUCAO.SZ1010 Z1 "+CRLF
				cQuery += " LEFT JOIN "+CRLF
				cQuery += " 	DADOSP12_PRODUCAO.SZ0010 Z0 ON ( Z1_RUBRICA = Z0_RUBRICA AND Z0.D_E_L_E_T_ <> '*' ) "+CRLF
				cQuery += " LEFT JOIN "+CRLF
				cQuery += " 	DADOSP12_PRODUCAO.SF3010 F1 ON ( F3_SERIE||F3_NFISCAL||F3_CLIEFOR||F3_LOJA = Z1_PREFIXO||Z1_NUM||Z1_FORNECE||Z1_LOJA AND F1.D_E_L_E_T_ <> '*' ) "+CRLF
				cQuery += " LEFT JOIN "+CRLF
				cQuery += " 	DADOSP12_PRODUCAO.SA2010 A2 ON (A2_COD||A2_LOJA = Z1_FORNECE||Z1_LOJA AND A2.D_E_L_E_T_ <> '*') "+CRLF
				cQuery += " WHERE                                                                           					"+CRLF
				cQuery += " 	Z1.D_E_L_E_T_ <> '*' AND Z0.D_E_L_E_T_ <> '*' AND Z1_RUBRICA = Z0_RUBRICA   					"+CRLF
				cQuery += " 	AND Z1_FILIAL = '"+SZ1->Z1_FILIAL+"' AND Z1_PREFIXO = '"+SZ1->Z1_PREFIXO+"'    					"+CRLF
				cQuery += " 	AND Z1_NUM = '"+SZ1->Z1_NUM+"'      															"+CRLF
				cQuery += " 	AND Z1_TIPO = '"+SZ1->Z1_TIPO+"' AND Z1_PARCELA = '"+SZ1->Z1_PARCELA+"'        					"+CRLF
				cQuery += " 	AND Z1_FORNECE = '"+SZ1->Z1_FORNECE+"' AND Z1_LOJA = '"+SZ1->Z1_LOJA+"'							"+CRLF
				cQuery += " 	AND Z0_RUBRICA NOT IN ('3','19','20','21')               										"+CRLF
				cQuery += " 	AND A2_RECISS <> 'S'																			"+CRLF
				cQuery += " 	AND Z0_NATRUBR = 'A'																			"+CRLF
				cQuery += " 	AND F3_VALICM > 0																				"+CRLF
			    cQuery += " 	ORDER BY 2																						"+CRLF
				
				If Select(cAliasIMP) > 0
					(cAliasIMP)->(dbCloseArea())
				EndIf
	
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasIMP,.T.,.T.)
				
				DbSelectArea(cAliasIMP)
				(cAliasIMP)->(DbGoTop())
				
				If !Empty(Alltrim( (cAliasIMP)->CREDITO ) )
					CREDITO := (cAliasIMP)->CREDITO
				EndIf
														
				//SZ1->(dbskip())
			//EndDo
			// Contabiliza Totais
			SA2->(DbSetOrder(1))
			SA2->(DbGoTop())
			SA2->(dbSeek(xFilial("SA2")+SZ1->Z1_FORNECE+SZ1->Z1_LOJA))
			nRecSZ1 := SZ1->(Recno())			
			SZ1->(dbGoBottom())
			SZ1->(dbSkip())
			nTotalLcto += DetProva(nHdlPrv,cPadrao,"ECOM023",cLote)
			SZ1->(dbGoTo(nRecSZ1))
			TOTAL	:=0
			If Select(cAliasSZ1) > 0
				(cAliasSZ1)->(dbCloseArea())
			EndIf
			If Select(cAliasIMP) > 0
				(cAliasIMP)->(dbCloseArea())
			EndIf
			SX5->(dbCloseArea())
		Endif	
	Endif
		
return 0