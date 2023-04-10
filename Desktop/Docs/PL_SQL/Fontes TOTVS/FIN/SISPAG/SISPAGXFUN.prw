#include 'protheus.ch'
#include 'parmtype.ch'
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | IDLANC    | Autor | DFSSISTEMAS | Data | 26/04/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Execblock para informação da identificação do paga- |
|           | mento no header do segmento A                       |
+-----------+-----------------------------------------------------+
| Uso       | Arquivo de configuração SISPAG                      |
+-----------+-----------------------------------------------------+
*/
User Function IDLANC(cTipo,cForma)
	
	Local cRet := ''
	
	If cTipo $ '30/31' .and. cForma $ '01/60' // Tipos de Pagamentos “30” (Salários) e “31” (Salários Poder Público) e Formas de Pagamentos “01” (Crédito em Conta Corrente no Itaú) e “60” (Cartão Salário)
		cRet := '1707'
	Else
		cRet := Space(4)
	Endif
	
Return cRet
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | INCRFAV   | Autor | DFSSISTEMAS | Data | 26/04/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Execblock para configuração da inscrição do favore- |
|           | cido (CPF/CNPJ) de acordo com a quantidade de carac-|
|           | teres informada.                                    |
+-----------+-----------------------------------------------------+
| Uso       | Arquivo de configuração SISPAG                      |
+-----------+-----------------------------------------------------+
*/
User Function INCRFAV(cTipo,cCPFCGC,nCar,cInscSE2) 

	Local cRet := ''
	Local cIdent := ''

	If alltrim(cInscSE2) == ''
		cIdent := cCPFCGC
	Else
		cIdent := cInscSE2
	Endif
	If cTipo == 'F'
		cRet := PADR(TRIM(cIdent),nCar)
	Else
		cRet := STRZERO(VAL(cIdent),nCar)
	Endif

Return cRet
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | NOMFAV    | Autor | DFSSISTEMAS | Data | 12/06/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Execblock para escolha do nome do beneficiário, de  |
|           | acordo com o nome informado no título a pagar       |
+-----------+-----------------------------------------------------+
| Uso       | Arquivo de configuração SISPAG                      |
+-----------+-----------------------------------------------------+
*/
User Function NOMFAV(cNomeE2,cNomeA2,nCar)

	Local cRet := ''
	
	If alltrim(cNomeE2) <> ''
		cRet := PADR(cNomeE2,30)	
	Else
		cRet := PADR(cNomeA2,30)
	Endif
	
Return cRet
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | DADTRIB   | Autor | DFSSISTEMAS | Data | 26/04/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Execblock para criar a string com os dados dos tri- |
|           | butos sem código de barras                          |
+-----------+-----------------------------------------------------+
| Uso       | Arquivo de configuração SISPAG                      | 
+-----------+-----------------------------------------------------+ 
*/
User Function DADTRIB(cModelo)

	Local cRet		:= ''
	Local cIdent	:= ''
	Local cTipo		:= ''
	Local cLinDig	:= ''
		
	If Empty(SE2->E2_XIDENT)
		cIdent := StrZero(Val(SM0->M0_CGC),14)
		If Len(alltrim(SM0->M0_CGC)) <= 11
			cTipo := 'F'
		Else
			cTipo := 'J'
		Endif
	Else
		cIdent := StrZero(VAL(SE2->E2_XIDENT),14)
		If Len(alltrim(SE2->E2_XIDENT)) <= 11
			cTipo := 'F'
		Else
			cTipo := 'J'
		Endif		
	Endif


	Do Case
		Case cModelo == "17" //GPS
			cRet := "01"																					//018 a 019-IDENTIFICACAO DO TRIBUTO (2) 01=GPS
			cRet += PADL(SE2->E2_CODINS,4)																	//020 a 023-CODIGO DE PAGTO (4)
			cRet += RIGHT(GRAVADATA(SE2->E2_XDTREF,.F.,5),6)												//024 a 029-MES E ANO DA COMPETENCIA (6)
			cRet += cIdent	//030 a 043-INSCRICAO NUMERO - CNPJ OU CPF (14)
			cRet += StrZero(SE2->(E2_VALOR-E2_XMULTA-E2_XJUROS)*100,14)										//044 a 057-VALOR PRINCIPAL (14)
			cRet += REPLICATE("0",14) /*StrZero((SE2->E2_XVLROUT)*100,14)*/	 								//058 a 071-VALOR ENTIDADES (14)
			cRet += StrZero(SE2->(E2_XMULTA+E2_XJUROS)*100,14)												//072 a 085-VALOR DA MULTA + JUROS (14)
			cRet += StrZero((SE2->(E2_VALOR))*100,14)														//086 a 099-VALOR TOTAL (14)
			cRet += GravaData(SE2->E2_DATAAGE,.F.,5)														//100 a 107-DATA PAGAMENTO (8)
			cRet += Space(8)																				//108 a 115-BRANCOS (8)
			cRet += Space(50)																				//116 a 165-BRANCOS (50)
			cRet += u_Sacado(cIdent)																					//166 a 195-NOME DO CONTRIBUINTE (30)

		Case cModelo == "16" //DARF (exceto SIMPLES)	
			cRet := "02"																					//018 a 019-IDENTIFICACAO DO TRIBUTO (02) 02=DARF
			cRet += PADL(SE2->E2_XCDARF,4)																	//020 a 023-CODIGO DA RECEITA (04)
			cRet += If( cTipo == 'F' , "1" , "2" )															//024 a 024-TIPO DE INSCRICAO DO CONTRIBUINTE 1=CPF, 2=CNPJ  (1)
			cRet += cIdent																					//025 a 038-INSCRICAO NUMERO - CNPJ OU CPF (14)
			cRet += GRAVADATA(SE2->E2_XDTREF,.F.,5)															//039 a 046-PERIODO DE APURACAO (8)       
			cRet += STRZERO(VAL(SE2->E2_IDDARF),17)															//047 a 063-NUMERO DE REFERENCIA (17)
			cRet += STRZERO(SE2->(E2_VALOR-E2_XMULTA-E2_XJUROS)*100,14)										//064 a 077-VALOR PRINCIPAL (14)
			cRet += STRZERO((SE2->E2_XMULTA)*100,14)														//078 a 091-VALOR DA MULTA (14)
			cRet += STRZERO((SE2->E2_XJUROS)*100,14)														//092 a 105-VALOR DOS JUROS/ENCARGOS (14)
			cRet += STRZERO(SE2->E2_VALOR*100,14,0)                                							//106 a 119-VALOR TOTAL (14)
			cRet += GRAVADATA(SE2->E2_VENCTO,.F.,5)															//120 a 127-DATA VENCIMENTO (8)
			cRet += GRAVADATA(SE2->E2_DATAAGE,.F.,5)		    											//128 a 135-DATA PAGAMENTO (8)
			cRet += SPACE(30)																				//136 a 165-BRANCOS (30)
			cRet += u_Sacado(cIdent)																//166 a 195-NOME DO CONTRIBUINTE (30)

		Case cModelo == "22" // GARE	
			cRet := "05"																					//018 a 019-IDENTIFICACAO DO TRIBUTO (02) 05=ICMS
			cRet += PADR(Alltrim(SE2->E2_XCGARE),4)															//020 a 023-CODIGO DA RECEITA (04)
			cRet += If( cTipo == 'F' , "1" , "2" )					   										//024 a 024-TIPO DE INSCRICAO DO CONTRIBUINTE 1=CPF, 2=CNPJ  (01)
			cRet += cIdent	   								   												//025 a 038-INSCRICAO NUMERO - CNPJ OU CPF (14)
			cRet += IIF("ISENTO"$SUBSTR(SM0->M0_INSC,1,12),SPACE(12),SUBSTR(SM0->M0_INSC,1,12))				//039 a 050-INSCRICAO ESTADUAL - CNPJ OU CPF (12)
			cRet += REPLICATE("0",13) 	     																//051 a 063-DIVIDA ATIVA/ETIQUETA (13)
			cRet += RIGHT(GRAVADATA(SE2->E2_XDTREF,.F.,5),6)						   						//064 a 069-REFERENCIA (06) MMAAAA
			cRet += STRZERO(VAL(SE2->E2_XNUMREF),13)														//070 a 082-PARCELA/NOTIFICACAO (13)
			cRet += STRZERO(SE2->(E2_VALOR-E2_XMULTA-E2_XJUROS)*100,14)										//083 a 096-VALOR RECEITA (14)
			cRet += STRZERO(SE2->E2_XJUROS*100,14)			 												//097 a 110-VALOR DOS JUROS/ENCARGOS (14)
			cRet += STRZERO(SE2->E2_XMULTA*100,14)															//111 a 124-VALOR DA MULTA (14)
			cRet += STRZERO(SE2->E2_VALOR *100,14) 															//125 a 138-VALOR DO PAGAMENTO (14)
			cRet += GRAVADATA(SE2->E2_VENCTO,.F.,5)															//139 a 146-DATA VENCIMENTO (8)
			cRet += GRAVADATA(SE2->E2_DATAAGE,.F.,5)														//147 a 154-DATA PAGAMENTO (8)
			cRet += SPACE(11)															   					//155 a 165-BRANCOS (11)
			cRet += u_Sacado(cIdent)											   					//166 a 195-NOME DO CONTRIBUINTE (30)

		Case cModelo == "35" // FGTS
			If Empty(SE2->E2_LINDIG)
				cLinDig := Substr(SE2->E2_CODBAR, 1,11)+Mod10(Substr(SE2->E2_CODBAR,  1, 11))
				cLinDig += Substr(SE2->E2_CODBAR,12,11)+Mod10(Substr(SE2->E2_CODBAR, 12, 11))
				cLinDig += Substr(SE2->E2_CODBAR,23,11)+Mod10(Substr(SE2->E2_CODBAR, 23, 11))
				cLinDig += Substr(SE2->E2_CODBAR,34,11)+Mod10(Substr(SE2->E2_CODBAR, 34, 11))
			Else
				cLinDig := PADR(SE2->E2_LINDIG,48)
			Endif 
			cRet := "11"																					// IDENTIFICACAO DO TRIBUTO (02) 11=FGTS-GFIP
			cRet += StrZero(Val(SE2->E2_XCFGTS),4)															// Codigo da Receita
			cRet += If( cTipo == 'J' , "1" , "2" )															// TIPO DE INSCRICAO DO CONTRIBUINTE (1-CPF / 2-CNPJ) 
			//cRet += cIdent																				// CPF OU CNPJ DO CONTRIBUINTE -- wagner 11/09/2019
			cRet += StrZero(Val(SE2->E2_XIDFGTS),14) 														// CPF OU CNPJ DO CONTRIBUINTE -- Wagner 11/09/2019
			cRet += cLinDig									      											// CODIGO DE BARRAS (LINHA DIGITAVEL)	(*criar campo*) 
			cRet += StrZero(Val(SE2->E2_XIDFGTS),16) 														// Identificador FGTS 
			cRet += StrZero(Val(SE2->E2_XLCFGTS),9)   														// Lacre de Conectividade Social 
			cRet += StrZero(Val(SE2->E2_XDLFGTS),2)  														// Digito do Lacre  
			cRet += u_Sacado(cIdent)                												// NOME DO CONTRIBUINTE
			cRet += GravaData(SE2->E2_DATAAGE,.F.,5)      							     					// DATA DO PAGAMENTO 
			cRet += StrZero(SE2->E2_SALDO*100,14)      								       					// VALOR DO PAGAMENTO 
			cRet += Space(30)                                  												// COMPLEMENTO DE REGISTRO 

		Case cModelo == "25" // IPVA
			cRet := IIF(SE2->E2_XOPIPVA="0","08","07")														//TRIBUTO 				IDENTIFICAÇÃO DO TRIBUTO 			018   019 	9(02) 		07 – IPVA 08 - DPVAT
			cRet += Space(4) 																				//BRANCOS  				COMPLEMENTO DE REGISTRO 			020   023 	X(04)  
			cRet += If( cTipo == 'F' , "1" , "2" )															//TIPO IDENT.CONTRIB. 	TIPO DE INSCRIÇÃO DO CONTRIBUINTE 	024   024 	9(01)		1 = CPF 2- CNPJ 
			cRet += cIdent																					//INSCRIÇÃO 			NÚMERO CPF OU CNPJ DO CONTRIBUINTE 	025   038 	9(14)  
			cRet += SE2->E2_XEXIPVA																			//EXERCÍCIO 			ANO BASE  							039   042 	9(04) 		AAAA 
			cRet += Substr(SE2->E2_XRENAVA,1,9)																//RENAVAM (9 DIGITOS) 	CÓDIGO DO RENAVAM COM 9 DÍGITOS 	043   051 	9(09)  
			cRet += SE2->E2_XUFIPVA																			//UF 					UNIDADE DA FEDERAÇÃO 				052   053 	X(02) 		MG / RJ / SP 
			cRet += StrZero(Val(Alltrim(SE2->E2_XMUIPVA)),5)												//CÓDIGO MUNICÍPIO 		CÓDIGO DO MUNICÍPIO 				054   058 	9(05)  
			cRet += SE2->E2_XPLACA																			//PLACA  				PLACA DO VEÍCULO 					059   065 	X(07)  
			cRet += SE2->E2_XOPIPVA																			//OPÇÃO PAGTO 			OPÇÃO DE PAGAMENTO 					066   066 	X(01) 		NOTA 28 
			cRet += StrZero(SE2->E2_VALOR*100,14)															//IPVA/DPVAT 			VALOR DO IPVA/DPVAT 				067   080 	9(12)V9(02) NOTA 29 
			cRet += StrZero(SE2->E2_XDESC*100,14)															//DESCONTO  			VALOR DO DESCONTO 					081   094 	9(12)V9(02) NOTA 29 
			cRet += StrZero(SE2->(E2_VALOR-E2_XDESC)*100,14)												//VALOR PAGAMENTO 		VALOR DO PAGAMENTO 					095   108 	9(12)V9(02) NOTA 29 
			cRet += GravaData(SE2->E2_DATAAGE,.F.,5)														//DATA VENCIMENTO  		DATA DE VENCIMENTO 					109   116 	9(08)	 	NOTA 29 
			cRet += GravaData(SE2->E2_DATAAGE,.F.,5)														//DATA PAGAMENTO 		DATA DO PAGAMENTO 					117   124 	9(08) 		DDMMAAAA 
			cRet += Space(29)																				//BRANCOS 				COMPLEMENTO DE REGISTRO 			125   153 	X(29)  
			cRet += SE2->E2_XRENAVA																			//RENAVAM (12 DIGITOS) 	CÓDIGO DO RENAVAM COM 12 DÍGITOS 	154   165 	9(12)  
			cRet += u_Sacado(cIdent)																//CONTRIBUINTE 			NOME DO CONTRIBUINTE 				166   195 	X(30) 		NOTA 22 
		
	EndCase	

Return cRet
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | AGCONTA   | Autor | DFSSISTEMAS | Data | 26/04/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Execblock para criar a string com os dados de agên- |
|           | cia e conta de acordo com a forma de pagamento.     |
+-----------+-----------------------------------------------------+
| Uso       | Arquivo de configuração SISPAG                      | 
+-----------+-----------------------------------------------------+ 
*/
User Function AgConta(cForma)

	Local cRet := "" 

	If SubStr(SE2->E2_FORBCO,1,3) $"341|409"
		cRet := "0"																										//024 a 024 - Zeros
		cRet += StrZero(Val(SubStr(SE2->E2_FORAGE,1,4)),4)																//025 a 028 - Numero da Agência    
		cRet += Space(1)																								//029 a 029 - Complemento de Registro
		cRet += StrZero(0,6)																							//030 a 035 - Zeros
		cRet += If(cForma$"02/10",Repl("0",6),StrZero(Val(SE2->E2_FORCTA),6))											//036 a 041 - Numero de C/C   
		cRet += Space(1)                                        														//042 a 042 - Complemento de Registro
		cRet += If(cForma$"02/10",Repl("0",1),StrZero(Val(SE2->E2_FCTADV),1))											//043 a 043 - DAC da Agência/Conta
	Else
		cRet := StrZero(Val(SE2->E2_FORAGE),5)																			//024 a 028 - Numero da Agencia
		cRet += Space(1)                                            	        										//029 a 029 - Complemento de Registro
		cRet += StrZero(Val(SE2->E2_FORCTA),12)     		            												//030 a 041 - Numero de C/C
		cRet += If(Len(alltrim(SE2->E2_FCTADV))==2,substr(alltrim(SE2->E2_FCTADV),1,1),Space(1))   						//042 a 042 - Complemento de Registro
		cRet += If(Len(alltrim(SE2->E2_FCTADV))==2,substr(alltrim(SE2->E2_FCTADV),2,1),StrZero(Val(SE2->E2_FCTADV),1))	//043 a 043 - DAC da agência/Conta CREDITADA
	EndIf

Return cRet
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | AGCONTA   | Autor | DFSSISTEMAS | Data | 26/04/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Execblock para preencher os campos utilizados no    |
|           | segmento J de acordo com os dados informados.       |
+-----------+-----------------------------------------------------+
| Uso       | Arquivo de configuração SISPAG                      | 
+-----------+-----------------------------------------------------+ 
*/
User Function CodBol(cCodBar,cLinDig)

	Local cCBBanco		:= ''
	Local cCBMoeda		:= ''
	Local cCBDV			:= ''
	Local cCBVencto		:= ''
	Local cCBValor		:= ''
	Local cCBCpoLivre	:= ''
	
	If alltrim(cCodBar) <> ''
		cCBBanco	:= SubStr(cCodBar, 1, 3)
		cCBMoeda	:= SubStr(cCodBar, 4, 1)
		cCBDV		:= SubStr(cCodBar, 5, 1)
		cCBVencto	:= SubStr(cCodBar, 6, 4)
		cCBValor	:= SubStr(cCodBar,10,10)
		cCBCpoLivre	:= SubStr(cCodBar,20,25)		
	Else
		cCBBanco	:= SubStr(cLinDig, 1, 3)
		cCBMoeda	:= SubStr(cLinDig, 4, 1)
		cCBCpoLivre	:= SubStr(cLinDig, 5, 5)+SubStr(cLinDig,11,10)+SubStr(cLinDig,22,10)
		cCBDV		:= SubStr(cLinDig,33, 1)
		cCBVencto	:= SubStr(cLinDig,34, 4)
		cCBValor	:= SubStr(cLinDig,38,10)
	Endif
	
Return {cCBBanco,cCBMoeda,cCBDV,cCBVencto,cCBValor,cCBCpoLivre}
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | CODCON    | Autor | DFSSISTEMAS | Data | 26/04/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Execblock para criar a string de código de barras   |
|           | de acordo com os dados informados.                  |
+-----------+-----------------------------------------------------+
| Uso       | Arquivo de configuração SISPAG                      | 
+-----------+-----------------------------------------------------+ 
*/
User Function CodCon(cCodBar,cLinDig)

	Local cRet := ''
	
	If alltrim(cCodBar) <> ''
		cRet := cCodBar
	Else
		cRet := SubStr(cLinDig, 1,	11)
		cRet += SubStr(cLinDig,13,	11)
		cRet += SubStr(cLinDig,25,	11)
		cRet += SubStr(cLinDig,37,	11)
		cRet += Space(4)
	Endif
	
Return cRet
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | VALDOC    | Autor | DFSSISTEMAS | Data | 26/04/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Execblock para somar os valores das outras receitas |
|           | no bloco N.                                         |
+-----------+-----------------------------------------------------+
| Uso       | Arquivo de configuração SISPAG                      | 
+-----------+-----------------------------------------------------+ 
*/
User Function ValDoc()

	Local nRet := 0

	nRet := SE2->E2_XMULTA+SE2->E2_XJUROS
	If Type("nSomaOutra") == "U"
		Public nSomaOutra := 0
	Endif
	If nSeq == 1
		nSomaOutra := SE2->E2_XVLROUT * 100
	Else
		nSomaOutra += SE2->E2_XVLROUT * 100
	Endif

Return nRet
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | VALDOC    | Autor | DFSSISTEMAS | Data | 26/04/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Execblock para criar string com nome do sacado (pa- |
|           | gador).                                             |
+-----------+-----------------------------------------------------+
| Uso       | Arquivo de configuração SISPAG                      | 
+-----------+-----------------------------------------------------+ 
*/
User Function Sacado(cCPFCGC)

	Local cRet := ''
	
	If !Empty(cCPFCGC)
		cRet := PADR(GetAdvFVal("SA2","A2_NOME",xFilial("SA2")+cCPFCGC,3,""),30)
	Endif
	If Empty(cRet)
		If Empty(SE2->E2_XSACADO)
			cRet := PADR(SM0->M0_NOMECOM,30)
		Else
			cRet := PADR(SE2->E2_XSACADO,30)
		Endif
	Endif
	
Return cRet

Static Function Mod10( cNum )
Local nFor    := 0
Local nTot    := 0
Local nMult   := 2
Local cRet 	  := ""

For nFor := Len(cNum) To 1 Step -1
	nTot += (nMult * Val(SubStr(cNum,nFor,1)))
	nMult := If(nMult==2,1,2)
Next

nTot := nTot % 10
nTot := If( nTot#0, 10-nTot, nTot )

cRet := Alltrim(str(nTot))

Return(cRet)


/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | VALIMP    | Autor | Ovio        | Data | 11/09/2019 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Execblock para informar o valor de pagamento        |
|           | no bloco O.                                         |
+-----------+-----------------------------------------------------+
| Uso       | Arquivo de configuração SISPAG                      | 
+-----------+-----------------------------------------------------+ 
*/
User Function Valimp()

	Local nRet := 0

	nRet := STRZERO(SE2->(E2_SALDO+E2_ACRESC+E2_XJUROS-E2_DECRESC)*100,15)
	//nRet := STRZERO(SE2->(E2_SALDO+E2_XMULTA+E2_ACRESC+E2_XJUROS-E2_DECRESC)*100,15)         

Return nRet
