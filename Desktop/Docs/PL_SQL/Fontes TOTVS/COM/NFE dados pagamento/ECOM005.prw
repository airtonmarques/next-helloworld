#include 'protheus.ch'
#include 'parmtype.ch'
/*
+-----------+-----------+-------+-------------------------------+------+------------+
| Programa  | ECOM005   | Autor | DFSSISTEMAS                   | Data | 20/07/2018 |
+-----------+-----------+-------+-------------------------------+------+------------+
| Descricao | Tela customizada para informações dos dados de pagamento no momento   |
|           | da inclusão da NFE                                                    |
+-----------+-----------------------------------------------------------------------+
| Uso       | Ponto de entrada MT103FIN                                             |
+-----------+-----------------------------------------------------------------------+ 
*/
user function ECOM005() 
	
	Local aHeadSE2	:= {}
	Local aColsSE2	:= {}
	Local oCampo	:= Nil
	Local nI,nX,nY	:= 0
	Local aCpoxPanel:= {}
	Local aCampos	:= {}
	Local aHeader	:= {}
	Local aCols		:= {}
	Local aLinha	:= {}
	Local cBkCad	:= ''
	Local nMgX		:= 0
	Local nMgY		:= 0
	Local nLarg		:= 0
	Local nAlt		:= 0
	Local oOK 		:= LoadBitmap(GetResources(),'br_verde')
	Local oNO 		:= LoadBitmap(GetResources(),'br_vermelho')
	Local nOpc		:= 0
	
	Private aCpHead	:= {}
	Private cDescTipo := ''
	Private cDescForma:= ''	

	Private oMODELO  := Nil
	Private oDescTipo:= Nil
	Private oTIPOPAG := Nil
	Private oDescForma:= Nil
	Private oFCTADV  := Nil
	Private oFAGEDV  := Nil
	Private oFORAGE  := Nil
	Private oFORBCO  := Nil
	Private oFORCTA  := Nil
	Private oCODBAR  := Nil
	Private oLINDIG  := Nil
	Private oXCDARF  := Nil
	Private oIDDARF  := Nil
	Private oXDTREF  := Nil
	Private oXIDENT  := Nil
	Private oXJUROS  := Nil
	Private oXMULTA  := Nil
	Private oCODINS  := Nil
	Private oXVLROUT := Nil
	//Private oXDESC   := Nil
	//Private oXSACADO := Nil
	Private oXCFGTS  := Nil
	Private oXIDFGTS := Nil
	Private oXDLFGTS := Nil
	Private oXLCFGTS := Nil
	Private oXNUMREF := Nil
	Private oXCGARE  := Nil
	Private oXEXIPVA := Nil
	Private oXMUIPVA := Nil
	Private oXOPIPVA := Nil
	Private oXPLACA  := Nil
	Private oXRENAVA := Nil
	Private oXUFIPVA := Nil
	Private oXNBENEF := Nil

	If !(Type("oMainWnd")=="O") // Executado direto pelo TDS/IDE para debug
		RPCSetType(3)
		RPCSetEnv('01','01',"","","COM","",{"SE2","SF1","SD1"})		
		aHeadSE2	:= {;
			{;
				'Parcela',;
				'E2_PARCELA',;
				"@!                                           ",;
				2,;
				0,;
				'.F.',;
				"€€€€€€€€€€€€€€ ",;
				'C',;
				"      ",;
				" ",;
				"                                                                                                                                ",;
				"                                                                                                                                ",;
				".T.";
			},;
			{;
				'Vencimento',;
				'E2_VENCTO',;
				"                                             ",;
				8,;
				0,;
				"M->E2_VENCTO>=M->dDEmissao",;
				"€€€€€€€€€€€€€€ ",;
				'D',;
				"      ",;
				" ",;
				"                                                                                                                                ",;
				"                                                                                                                                ",;
				".T.";
			},;
			{;
				'Vlr.Titulo',;
				'E2_VALOR',;
				"@E 9,999,999,999,999.99                      ",;
				16,;
				2,;
				"Positivo()",;
				"€€€€€€€€€€€€€€ ",;
				'N',;
				"      ",;
				" ",;
				"                                                                                                                                ",;
				"                                                                                                                                ",;
				".T.";
			};			
		}
		aColsSE2	:= {{" ",CTOD('16/05/2018'),500},{" ",CTOD('16/06/2018'),500}}
		cBkCad	:= ''
		SA2->(dbsetOrder(1))
		SA2->(dbseek(xFilial('SA2')+'000001'))
	Else
		aHeadSE2	:= Paramixb[1]
		aColsSE2	:= Paramixb[2]
		cBkCad		:= cCadastro	
	Endif

	Private nLinAnt	:= 0
	Private oTitulos:= Nil
	Private oGrp01 := Nil
	Private oGrp02 := Nil
	Private oGrp03 := Nil
	Private oGrp05 := Nil
	Private oGrp06 := Nil
	Private oGrp07 := Nil
	Private oGrp41 := Nil
	Private oGrp45 := Nil
	Private oGrp43 := Nil
	Private oGrp10 := Nil
	Private oGrp13 := Nil
	Private oGrp16 := Nil
	Private oGrp17 := Nil
	Private oGrp18 := Nil
	Private oGrp19 := Nil
	Private oGrp21 := Nil
	Private oGrp22 := Nil
	Private oGrp25 := Nil
	Private oGrp27 := Nil
	Private oGrp30 := Nil
	Private oGrp31 := Nil
	Private oGrp32 := Nil
	Private oGrp35 := Nil
	Private oGrp60 := Nil
	Private oGrp91 := Nil
		
	Private nMODELO  := 0
	Private nTIPOPAG := 0
	Private nFCTADV  := 0
	Private nFAGEDV  := 0
	Private nFORAGE  := 0
	Private nFORBCO  := 0
	Private nFORCTA  := 0
	Private nCODBAR  := 0
	Private nLINDIG  := 0
	Private nXCDARF  := 0
	Private nIDDARF  := 0
	Private nXDTREF  := 0
	Private nXIDENT  := 0
	Private nXJUROS  := 0
	Private nXMULTA  := 0
	Private nCODINS  := 0
	Private nXVLROUT := 0
	Private nXDESC   := 0
	Private nXSACADO := 0
	Private nXCFGTS  := 0
	Private nXIDFGTS := 0
	Private nXDLFGTS := 0
	Private nXLCFGTS := 0
	Private nXNUMREF := 0
	Private nXCGARE  := 0
	Private nXEXIPVA := 0
	Private nXMUIPVA := 0
	Private nXOPIPVA := 0
	Private nXPLACA  := 0
	Private nXRENAVA := 0
	Private nXUFIPVA := 0
	Private nXNBENEF := 0

	Private aPagParc := {}

	If Type("aPagtos") == "U"
		Public aPagtos	:= {}
		Public aCpHPag	:= {}
		Public nParcPag	:= 1
	Else
		aPagtos	:= {}
		aCpHPag	:= {}
		nParcPag	:= 1	
	Endif
	
	cCadastro := 'Dados para Pagamento'

	aAdd(aCampos,{'E2_FORMPAG' }) //,TamSX3('EA_MODELO'  )[1],'oCpo01'})
	aAdd(aCampos,{'EA_TIPOPAG'}) //,TamSX3('EA_TIPOPAG' )[1],'oCpo02'})

	aAdd(aCampos,{'E2_FCTADV' }) //,TamSX3('E2_FCTADV' )[1]*4})
	aAdd(aCampos,{'E2_FAGEDV' })
	aAdd(aCampos,{'E2_FORAGE' }) //,TamSX3('E2_FORAGE' )[1]*4})
	aAdd(aCampos,{'E2_FORBCO' }) //,TamSX3('E2_FORBCO' )[1]*4})
	aAdd(aCampos,{'E2_FORCTA' }) //,TamSX3('E2_FORCTA' )[1]*4})
	aAdd(aCampos,{'E2_CODBAR' }) //,TamSX3('E2_CODBAR' )[1]*4})
	aAdd(aCampos,{'E2_LINDIG' }) //,TamSX3('E2_LINDIG' )[1]*4})
	aAdd(aCampos,{'E2_XCDARF' }) //,TamSX3('E2_XCDARF' )[1]*4})
	aAdd(aCampos,{'E2_IDDARF' }) //,TamSX3('E2_IDDARF' )[1]*4})
	aAdd(aCampos,{'E2_XDTREF' }) //,TamSX3('E2_XDTREF' )[1]*4})
	aAdd(aCampos,{'E2_XIDENT' }) //,TamSX3('E2_XIDENT' )[1]*4})
	aAdd(aCampos,{'E2_XJUROS' }) //,TamSX3('E2_XJUROS' )[1]*4})
	aAdd(aCampos,{'E2_XMULTA' }) //,TamSX3('E2_XMULTA' )[1]*4})
	aAdd(aCampos,{'E2_CODINS' }) //,TamSX3('E2_CODINS' )[1]*4})
	aAdd(aCampos,{'E2_XVLROUT'}) //,TamSX3('E2_XVLROUT')[1]*4})
	aAdd(aCampos,{'E2_XDESC'  }) //,TamSX3('E2_XDESC'  )[1]*4})
	aAdd(aCampos,{'E2_XSACADO'}) //,TamSX3('E2_XSACADO')[1]*4})
	aAdd(aCampos,{'E2_XCFGTS' }) //,TamSX3('E2_XCFGTS' )[1]*4})
	aAdd(aCampos,{'E2_XIDFGTS'}) //,TamSX3('E2_XIDFGTS')[1]*4})
	aAdd(aCampos,{'E2_XDLFGTS'}) //,TamSX3('E2_XDLFGTS')[1]*4})
	aAdd(aCampos,{'E2_XLCFGTS'}) //,TamSX3('E2_XLCFGTS')[1]*4})

	aAdd(aCampos,{'E2_XNUMREF'}) //,TamSX3('E2_XNUMREF')[1]*4})
	aAdd(aCampos,{'E2_XCGARE' }) //,TamSX3('E2_XCGARE' )[1]*4})

	aAdd(aCampos,{'E2_XEXIPVA'}) //,TamSX3('E2_XEXIPVA')[1]*4})
	aAdd(aCampos,{'E2_XMUIPVA'}) //,TamSX3('E2_XMUIPVA')[1]*4})
	aAdd(aCampos,{'E2_XOPIPVA'}) //,TamSX3('E2_XOPIPVA')[1]*4})
	aAdd(aCampos,{'E2_XPLACA' }) //,TamSX3('E2_XPLACA' )[1]*4})
	aAdd(aCampos,{'E2_XRENAVA'}) //,TamSX3('E2_XRENAVA')[1]*4})
	aAdd(aCampos,{'E2_XUFIPVA'}) //,TamSX3('E2_XUFIPVA')[1]*4})

	aAdd(aCampos,{'E2_XIDRECE'})
	aAdd(aCampos,{'E2_XNOMREC'})

	aAdd(aCampos,{'E2_XNBENEF'})

	For nI := 1 to Len(aCampos)
		If !Empty(GetSx3Cache(aCampos[nI,1] ,'X3_CAMPO'))
			aadd(aCpHPag,aCampos[nI,1])
			cConteudo :=  CriaVar(aCampos[nI,1])
			aAdd(aLinha,cConteudo)
    	Endif
	Next nI
	aAdd(aLinha,.F.)
	
	nXIDRECE := aScan(aCpHPag,'E2_XIDRECE')
	nXNOMREC := aScan(aCpHPag,'E2_XNOMREC')
	nFORAGE  := aScan(aCpHPag,'E2_FORAGE' )
	nFORBCO  := aScan(aCpHPag,'E2_FORBCO' )
	nFORCTA  := aScan(aCpHPag,'E2_FORCTA' )
	
	dbSelectArea("FIL")
	dbSetOrder(1)//FIL_FILIAL+FIL_FORNEC+FIL_LOJA+FIL_TIPO+FIL_BANCO+FIL_AGENCI+FIL_CONTA                                                                                          
	If dbSeek( xFilial("FIL") + SA2->A2_COD + SA2->A2_LOJA + "1" + aLinha[nFORBCO] + aLinha[nFORAGE] + aLinha[nFORCTA] )
		aLinha[nPos] := FIL->FIL_XIDREC
		aLinha[nPos] := FIL->FIL_XNOMRE
	Endif
		
	aPagParc := aClone(aLinha)

	nMODELO  := aScan(aCpHPag,'E2_FORMPAG')
	nTIPOPAG := aScan(aCpHPag,'EA_TIPOPAG')
	nFCTADV  := aScan(aCpHPag,'E2_FCTADV' )
	nFAGEDV  := aScan(aCpHPag,'E2_FAGEDV' )
	nFORAGE  := aScan(aCpHPag,'E2_FORAGE' )
	nFORBCO  := aScan(aCpHPag,'E2_FORBCO' )
	nFORCTA  := aScan(aCpHPag,'E2_FORCTA' )
	nCODBAR  := aScan(aCpHPag,'E2_CODBAR' )
	nLINDIG  := aScan(aCpHPag,'E2_LINDIG' )
	nXCDARF  := aScan(aCpHPag,'E2_XCDARF' )
	nIDDARF  := aScan(aCpHPag,'E2_IDDARF' )
	nXDTREF  := aScan(aCpHPag,'E2_XDTREF' )
	nXIDENT  := aScan(aCpHPag,'E2_XIDENT' )
	nXJUROS  := aScan(aCpHPag,'E2_XJUROS' )
	nXMULTA  := aScan(aCpHPag,'E2_XMULTA' )
	nCODINS  := aScan(aCpHPag,'E2_CODINS' )
	nXVLROUT := aScan(aCpHPag,'E2_XVLROUT')
	nXDESC   := aScan(aCpHPag,'E2_XDESC'  )
	nXSACADO := aScan(aCpHPag,'E2_XSACADO')
	nXCFGTS  := aScan(aCpHPag,'E2_XCFGTS' )
	nXIDFGTS := aScan(aCpHPag,'E2_XIDFGTS')
	nXDLFGTS := aScan(aCpHPag,'E2_XDLFGTS')
	nXLCFGTS := aScan(aCpHPag,'E2_XLCFGTS')
	nXNUMREF := aScan(aCpHPag,'E2_XNUMREF')
	nXCGARE  := aScan(aCpHPag,'E2_XCGARE' )
	nXEXIPVA := aScan(aCpHPag,'E2_XEXIPVA')
	nXMUIPVA := aScan(aCpHPag,'E2_XMUIPVA')
	nXOPIPVA := aScan(aCpHPag,'E2_XOPIPVA')
	nXPLACA  := aScan(aCpHPag,'E2_XPLACA' )
	nXRENAVA := aScan(aCpHPag,'E2_XRENAVA')
	nXUFIPVA := aScan(aCpHPag,'E2_XUFIPVA')
	nXNBENEF := aScan(aCpHPag,'E2_XNBENEF')
	
	

		
	DEFINE DIALOG oDialogo FROM 0,0 TO 380,940 PIXEL TITLE 'DADOS PARA PAGAMENTO'
	
		AADD(aCpHead,{'E2_PARCELA'	,0})
		AADD(aCpHead,{'E2_VENCTO'	,0})
		AADD(aCpHead,{'E2_VALOR'	,0})
		
		For nX := 1 TO Len(aCpHead)
			If (aCpHead[nX,2] := aScan(aHeadSE2,{|x|UPPER(Alltrim(x[2])) == aCpHead[nX,1]})) > 0
				aadd(aHeader,aHeadSE2[aCpHead[nX,2]])
			Endif
		Next nX
		For nX := 1 TO Len(aColsSE2)
			aLinha := {}
			aadd(aLinha,.F.)
			For nY := 1 to Len(aCpHead)
				aadd(aLinha,aColsSE2[nX,aCpHead[nY,2]])
			Next nY
			aadd(aLinha,aClone(aPagParc))
			aadd(aCols,aLinha)
		Next nX
		For nI := 1 to Len(aCols)
			aadd(aPagtos,aCols[nI,Len(aCols[nI])])
		Next nI
		oTitulos := TCBrowse():New( 32, 2,145,120,, {'','Parcela','Vencimento','Valor'},{20,25,50,50}, oDialogo,,,,{|| AtuCpo() },{||},,,,,,,.F.,,.T.,,.F.,,.F.,.F. )
		oTitulos:SetArray(aCols)
		oTitulos:bLine := {|| { If(aCols[oTitulos:nAt,01],oOK,oNO),aCols[oTitulos:nAt,02],aCols[oTitulos:nAt,03],Transform(aCols[oTitulos:nAT,04],'@E 99,999,999,999.99') } }
	
		oGrupo1:= TGroup():New(153,02,190,147,'Pagamento',oDialogo,,,.T.)
		@ 163,  4 SAY   'Tipo'								SIZE 20,10 PIXEL OF oDialogo
		@ 160, 25 MSGET oTIPOPAG	VAR aPagParc[nTIPOPAG]	SIZE 20,10 PIXEL OF oDialogo F3 GetSx3Cache('EA_TIPOPAG','X3_F3') VALID (cDescTipo := AllTrim(GetAdvFVal("SX5","X5_DESCRI",xFilial("SX5")+PADR(GetSx3Cache('EA_TIPOPAG','X3_F3'),TamSX3('EA_TIPOPAG')[1])+aPagParc[ nTIPOPAG],1)),.T.) WHEN .T. PICTURE GetSx3Cache('EA_TIPOPAG','X3_PICTURE')		
		@ 160, 53 MSGET oDescTipo	VAR cDescTipo			SIZE 90,10 PIXEL OF oDialogo VALID .T. WHEN .F.
		@ 178,  4 SAY   'Forma'								SIZE 20,10 PIXEL OF oDialogo
		@ 175, 25 MSGET oMODELO		VAR aPagParc[nMODELO]	SIZE 20,10 PIXEL OF oDialogo F3 GetSx3Cache('E2_FORMPAG' ,'X3_F3') VALID {|| cDescForma := AllTrim(GetAdvFVal("SX5","X5_DESCRI",xFilial("SX5")+PADR(GetSx3Cache('E2_FORMPAG','X3_F3'),TamSX3('E2_FORMPAG')[1])+aPagParc[ nMODELO],1)),u_TrocaP(aPagParc[ nMODELO ])} WHEN .T. PICTURE GetSx3Cache('E2_FORMPAG' ,'X3_PICTURE')
		@ 175, 53 MSGET oDescForma	VAR cDescForma			SIZE 90,10 PIXEL OF oDialogo VALID .T. WHEN .F.
		
		nMgX	:= 155
		nMgY	:=  35
		nLarg	:= 310 //oFolder:nWidth-nMgX
		nAlt	:= 150 //oFolder:nHeight-20
	
		oGrupo2 := TGroup():New(32, 150,190,470,'',oDialogo,,,.T.)
		
		oGrp01 := TPanel():New(nMgY, nMgX,'Credito em Conta Corrente'		,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //CRÉDITO EM CONTA CORRENTE NO ITAÚ
		oGrp03 := TPanel():New(nMgY, nMgX,'DOC C'							,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //DOC “C ”
		oGrp05 := TPanel():New(nMgY, nMgX,'Credito em Conta Poupanca'		,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //CRÉDITO EM CONTA POUPANÇA NO ITAÚ
		oGrp06 := TPanel():New(nMgY, nMgX,'Credito C/c mesma titularidade'	,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //CRÉDITO EM CONTA CORRENTE DE MESMA TITULARIDADE
		oGrp07 := TPanel():New(nMgY, nMgX,'DOC D'							,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //DOC “D ”
		oGrp41 := TPanel():New(nMgY, nMgX,'TED – OUTRO TITULAR'				,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //TED – OUTRO TITULAR
		oGrp45 := TPanel():New(nMgY, nMgX,'PIX'								,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //PIX
		oGrp43 := TPanel():New(nMgY, nMgX,'TED – MESMO TITULAR'				,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //TED – MESMO TITULAR	
		oGrp10 := TPanel():New(nMgY, nMgX,'Ordem de Pagamento'				,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //ORDEM DE PAGAMENTO À DISPOSIÇÃO
		oGrp13 := TPanel():New(nMgY, nMgX,'Pagamento a concessionarias'		,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //PAGAMENTO DE CONCESSIONÁRIAS
		oGrp16 := TPanel():New(nMgY, nMgX,'DARF Normal'						,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //DARF NORMAL
		oGrp17 := TPanel():New(nMgY, nMgX,'GPS'								,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //GPS - GUIA DA PREVIDÊNCIA SOCIAL		
		oGrp30 := TPanel():New(nMgY, nMgX,'PAGAMENTO TITULOS DO ITAU'		,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //PAGAMENTO DE TÍTULOS EM COBRANÇA NO ITAÚ
		oGrp31 := TPanel():New(nMgY, nMgX,'PAGAMENTO TITULOS OUTROS BANCOS'	,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //PAGAMENTO DE TÍTULOS EM COBRANÇA EM OUTROS BANCOS		
		oGrp35 := TPanel():New(nMgY, nMgX,'FGTS – GFIP'						,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //FGTS – GFIP
		
		oGrp02 := TPanel():New(nMgY, nMgX,'Cheque Administrativo'			,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //CHEQUE PAGAMENTO/ADMINISTRATIVO
		oGrp04 := TPanel():New(nMgY, nMgX,'Cheque Administrativo'			,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //CHEQUE PAGAMENTO/ADMINISTRATIVO
		oGrp18 := TPanel():New(nMgY, nMgX,'DARF SIMPLES'					,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //DARF SIMPLES
		oGrp19 := TPanel():New(nMgY, nMgX,'IPTU/ISS/OUTROS TRIBUTOS MUNIC.'	,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //IPTU/ISS/OUTROS TRIBUTOS MUNICIPAIS
		oGrp21 := TPanel():New(nMgY, nMgX,'DARJ'							,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //DARJ
		oGrp22 := TPanel():New(nMgY, nMgX,'GARE – SP ICMS'					,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //GARE – SP ICMS
		oGrp25 := TPanel():New(nMgY, nMgX,'IPVA'							,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //IPVA
		oGrp27 := TPanel():New(nMgY, nMgX,'DPVAT'							,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //DPVAT
		oGrp32 := TPanel():New(nMgY, nMgX,'LIQUIDACAO ELETRONICA'			,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //NOTA FISCAL – LIQUIDAÇÃO ELETRÔNICA
		oGrp60 := TPanel():New(nMgY, nMgX,'CARTÃO SALÁRIO'					,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //CARTÃO SALÁRIO
		oGrp91 := TPanel():New(nMgY, nMgX,'GNRE E TRIBUTOS COM CÓD.BARRAS'	,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //GNRE E TRIBUTOS COM CÓDIGO DE BARRAS
	
		//oGet2 VAR cGet2
	
		//Grp01	
		@ 18, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp01
		@ 15, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp01 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN .T. PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')		
		@ 33, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp01
		@ 30, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp01 VALID .T. WHEN .F.	
		@ 30, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp01 VALID .T. WHEN .F.
		@ 48, 5  SAY   GetSx3Cache('E2_FORCTA' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp01
		@ 45, 40 MSGET oFORCTA VAR aPagParc[ nFORCTA ]			SIZE 30,10 PIXEL OF oGrp01 VALID .T. WHEN .F.		
		@ 45, 70 MSGET oFCTADV VAR aPagParc[ nFCTADV ]			SIZE 10,10 PIXEL OF oGrp01 VALID .T. WHEN .F.		
		@ 63, 5  SAY   'CPF/CNPJ BENEF.'						SIZE 35,10 PIXEL OF oGrp01
		@ 60, 40 MSGET oXIDENT VAR aPagParc[ nXIDENT ]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp01 VALID .T. WHEN .T.	
		@ 78, 5  SAY   GetSx3Cache('E2_XNBENEF' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp01
		@ 75, 40 MSGET oXNBENEF VAR aPagParc[ nXNBENEF ]		SIZE GetSx3Cache('E2_XNBENEF' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp01 VALID .T. WHEN .T.	


		//Grp03	
		@ 18, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')				SIZE 35,10 PIXEL OF oGrp03
		@ 15, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp03 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN .T. PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')		
		@ 33, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')				SIZE 35,10 PIXEL OF oGrp03
		@ 30, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp03 VALID .T. WHEN .F.	
		@ 30, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp03 VALID .T. WHEN .F.
		@ 48, 5  SAY   GetSx3Cache('E2_FORCTA' ,'X3_TITULO')				SIZE 35,10 PIXEL OF oGrp03
		@ 45, 40 MSGET oFORCTA VAR aPagParc[ nFORCTA ]			SIZE 30,10 PIXEL OF oGrp03 VALID .T. WHEN .F.		
		@ 45, 70 MSGET oFCTADV VAR aPagParc[ nFCTADV ]			SIZE 10,10 PIXEL OF oGrp03 VALID .T. WHEN .F.
		//Grp05	
		@ 18, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp05
		@ 15, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp05 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN .T. PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')		
		@ 33, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp05
		@ 30, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp05 VALID .T. WHEN .F.	
		@ 30, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp05 VALID .T. WHEN .F.
		@ 48, 5  SAY   GetSx3Cache('E2_FORCTA' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp05
		@ 45, 40 MSGET oFORCTA VAR aPagParc[ nFORCTA ]			SIZE 30,10 PIXEL OF oGrp05 VALID .T. WHEN .F.		
		@ 45, 70 MSGET oFCTADV VAR aPagParc[ nFCTADV ]			SIZE 10,10 PIXEL OF oGrp05 VALID .T. WHEN .F.
		//Grp06	
		@ 18, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp06
		@ 15, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp06 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN .T. PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')		
		@ 33, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp06
		@ 30, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp06 VALID .T. WHEN .F.	
		@ 30, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp06 VALID .T. WHEN .F.
		@ 48, 5  SAY   GetSx3Cache('E2_FORCTA' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp06
		@ 45, 40 MSGET oFORCTA VAR aPagParc[ nFORCTA ]			SIZE 30,10 PIXEL OF oGrp06 VALID .T. WHEN .F.		
		@ 45, 70 MSGET oFCTADV VAR aPagParc[ nFCTADV ]			SIZE 10,10 PIXEL OF oGrp06 VALID .T. WHEN .F.
		//Grp07	
		@ 18, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp07
		@ 15, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp07 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN .T. PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')		
		@ 33, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp07
		@ 30, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp07 VALID .T. WHEN .F.	
		@ 30, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp07 VALID .T. WHEN .F.
		@ 48, 5  SAY   GetSx3Cache('E2_FORCTA' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp07
		@ 45, 40 MSGET oFORCTA VAR aPagParc[ nFORCTA ]			SIZE 30,10 PIXEL OF oGrp07 VALID .T. WHEN .F.		
		@ 45, 70 MSGET oFCTADV VAR aPagParc[ nFCTADV ]			SIZE 10,10 PIXEL OF oGrp07 VALID .T. WHEN .F.
		//Grp41	
		@ 18, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp41
		@ 15, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp41 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN .T. PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')		
		@ 33, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp41
		@ 30, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp41 VALID .T. WHEN .F.	
		@ 30, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp41 VALID .T. WHEN .F.
		@ 48, 5  SAY   GetSx3Cache('E2_FORCTA' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp41
		@ 45, 40 MSGET oFORCTA VAR aPagParc[ nFORCTA ]			SIZE 30,10 PIXEL OF oGrp41 VALID .T. WHEN .F.		
		@ 45, 70 MSGET oFCTADV VAR aPagParc[ nFCTADV ]			SIZE 10,10 PIXEL OF oGrp41 VALID .T. WHEN .F.
		//Grp45
		@ 18, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp45
		@ 15, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp45 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN .T. PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')		
		@ 33, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp45
		@ 30, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp45 VALID .T. WHEN .F.	
		@ 30, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp45 VALID .T. WHEN .F.
		@ 48, 5  SAY   GetSx3Cache('E2_FORCTA' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp45
		@ 45, 40 MSGET oFORCTA VAR aPagParc[ nFORCTA ]			SIZE 30,10 PIXEL OF oGrp45 VALID .T. WHEN .F.		
		@ 45, 70 MSGET oFCTADV VAR aPagParc[ nFCTADV ]			SIZE 10,10 PIXEL OF oGrp45 VALID .T. WHEN .F.
		//Grp43	
		@ 18, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp43
		@ 15, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp43 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN .T. PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')		
		@ 33, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp43
		@ 30, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp43 VALID .T. WHEN .F.	
		@ 30, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp43 VALID .T. WHEN .F.
		@ 48, 5  SAY   GetSx3Cache('E2_FORCTA' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp43
		@ 45, 40 MSGET oFORCTA VAR aPagParc[ nFORCTA ]			SIZE 30,10 PIXEL OF oGrp43 VALID .T. WHEN .F.		
		@ 45, 70 MSGET oFCTADV VAR aPagParc[ nFCTADV ]			SIZE 10,10 PIXEL OF oGrp43 VALID .T. WHEN .F.
		//Grp10	
		@ 18, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp10
		@ 15, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp10 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN .T. PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')		
		@ 33, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp10
		@ 30, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp10 VALID .T. WHEN .F.	
		@ 30, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp10 VALID .T. WHEN .F.
				
		//Grp13
		@ 18, 5  SAY   GetSx3Cache('E2_CODBAR' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp13
		@ 15, 40 MSGET oCODBAR VAR aPagParc[ nCODBAR ]			SIZE GetSx3Cache('E2_CODBAR' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp13 VALID .T. WHEN .T.		
		@ 33, 5  SAY   GetSx3Cache('E2_LINDIG' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp13
		@ 30, 40 MSGET oLINDIG VAR aPagParc[ nLINDIG ]			SIZE GetSx3Cache('E2_LINDIG' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp13 VALID .T. WHEN .T.	
		
		//Grp16
		@ 18, 5  SAY   GetSx3Cache('E2_CODBAR' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp16
		@ 15, 40 MSGET oCODBAR VAR aPagParc[ nCODBAR ]			SIZE GetSx3Cache('E2_CODBAR' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp16 VALID .T. WHEN .T.		
		@ 33, 5  SAY   GetSx3Cache('E2_LINDIG' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp16
		@ 30, 40 MSGET oLINDIG VAR aPagParc[ nLINDIG ]			SIZE GetSx3Cache('E2_LINDIG' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp16 VALID .T. WHEN .T.	
		@ 48, 5  SAY   GetSx3Cache('E2_XCDARF' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp16
		@ 45, 40 MSGET oXCDARF VAR aPagParc[ nXCDARF ]			SIZE GetSx3Cache('E2_XCDARF' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp16 VALID .T. WHEN .T.	
		@ 63, 5  SAY   GetSx3Cache('E2_IDDARF' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp16
		@ 60, 40 MSGET oIDDARF VAR aPagParc[ nIDDARF ]			SIZE GetSx3Cache('E2_IDDARF' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp16 VALID .T. WHEN .T.	
		@ 78, 5  SAY   GetSx3Cache('E2_XIDENT' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp16
		@ 75, 40 MSGET oXIDENT VAR aPagParc[ nXIDENT ]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp16 VALID .T. WHEN .T.	
		@ 93, 5  SAY   GetSx3Cache('E2_XDTREF' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp16
		@ 90, 40 MSGET oXDTREF VAR aPagParc[ nXDTREF ]			SIZE GetSx3Cache('E2_XDTREF' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp16 VALID .T. WHEN .T. PICTURE GetSx3Cache('E2_XDTREF','X3_PICTURE')	
		@ 108, 5  SAY   GetSx3Cache('E2_XJUROS' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp16
		@ 105, 40 MSGET oXJUROS VAR aPagParc[ nXJUROS ]			SIZE GetSx3Cache('E2_XJUROS' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp16 VALID .T. WHEN .T. PICTURE GetSx3Cache('E2_XJUROS','X3_PICTURE')	
		@ 123, 5  SAY   GetSx3Cache('E2_XMULTA' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp16
		@ 120, 40 MSGET oXMULTA VAR aPagParc[ nXMULTA ]			SIZE GetSx3Cache('E2_XMULTA' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp16 VALID .T. WHEN .T. PICTURE GetSx3Cache('E2_XMULTA','X3_PICTURE')	
	
		//Grp17
		@ 18, 5  SAY   GetSx3Cache('E2_CODINS' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp17
		@ 15, 40 MSGET oCODINS VAR aPagParc[ nCODINS ]			SIZE GetSx3Cache('E2_CODINS' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp17 VALID .T. WHEN .T.		
		@ 33, 5  SAY   GetSx3Cache('E2_CODINS' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp17
		@ 30, 40 MSGET oCODINS VAR aPagParc[ nCODINS ]			SIZE GetSx3Cache('E2_XDTREF' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp17 VALID .T. WHEN .T.	
		@ 48, 5  SAY   GetSx3Cache('E2_XIDENT' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp17
		@ 45, 40 MSGET oXIDENT VAR aPagParc[ nXIDENT ]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp17 VALID .T. WHEN .T.	
		@ 63, 5  SAY   GetSx3Cache('E2_XJUROS' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp17
		@ 60, 40 MSGET oXJUROS VAR aPagParc[ nXJUROS ]			SIZE GetSx3Cache('E2_XJUROS' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp17 VALID .T. WHEN .T.  PICTURE GetSx3Cache('E2_XJUROS','X3_PICTURE')	
		@ 78, 5  SAY   GetSx3Cache('E2_XMULTA' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp17
		@ 75, 40 MSGET oXMULTA VAR aPagParc[ nXMULTA ]			SIZE GetSx3Cache('E2_XMULTA' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp17 VALID .T. WHEN .T.  PICTURE GetSx3Cache('E2_XMULTA','X3_PICTURE')	
		@ 93, 5  SAY   GetSx3Cache('E2_XVLROUT' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp17
		@ 90, 40 MSGET oXVLROUT VAR aPagParc[ nXVLROUT ]		SIZE GetSx3Cache('E2_XVLROUT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp17 VALID .T. WHEN .T. PICTURE GetSx3Cache('E2_XVLROUT','X3_PICTURE')		
	
		//Grp30
		@ 18, 5  SAY   GetSx3Cache('E2_CODBAR' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp30
		@ 15, 40 MSGET oCODBAR VAR aPagParc[ nCODBAR ]			SIZE GetSx3Cache('E2_CODBAR' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp30 VALID .T. WHEN .T.		
		@ 33, 5  SAY   GetSx3Cache('E2_LINDIG' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp30
		@ 30, 40 MSGET oLINDIG VAR aPagParc[ nLINDIG ]			SIZE GetSx3Cache('E2_LINDIG' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp30 VALID .T. WHEN .T.	
		@ 48, 5  SAY   GetSx3Cache('E2_XIDENT' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp30
		@ 45, 40 MSGET oXIDENT VAR aPagParc[ nXIDENT ]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp30 VALID .T. WHEN .T.	
		//@ 63, 5  SAY   GetSx3Cache('E2_XDESC' ,'X3_TITULO')		SIZE  35,10 PIXEL OF oGrp30
		//@ 60, 40 MSGET oXDESC VAR aPagParc[ nXDESC ]			SIZE GetSx3Cache('E2_XDESC' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp30 VALID .T. WHEN .T.  PICTURE GetSx3Cache('E2_XJUROS','X3_PICTURE')	
		//@ 78, 5  SAY   GetSx3Cache('E2_XSACADO' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp30
		//@ 75, 40 MSGET aPagParc[ nXSACADO ]			SIZE GetSx3Cache('E2_XSACADO' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp30 VALID .T. WHEN .T.	
	
		//Grp31
		@ 18, 5  SAY   GetSx3Cache('E2_CODBAR' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp31
		@ 15, 40 MSGET oCODBAR VAR aPagParc[ nCODBAR ]			SIZE GetSx3Cache('E2_CODBAR' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp31 VALID .T. WHEN .T.		
		@ 33, 5  SAY   GetSx3Cache('E2_LINDIG' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp31
		@ 30, 40 MSGET oLINDIG VAR aPagParc[ nLINDIG ]			SIZE GetSx3Cache('E2_LINDIG' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp31 VALID .T. WHEN .T.	
		@ 48, 5  SAY   GetSx3Cache('E2_XIDENT' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp31
		@ 45, 40 MSGET oXIDENT VAR aPagParc[ nXIDENT ]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp31 VALID .T. WHEN .T.	
		//@ 63, 5  SAY   GetSx3Cache('E2_XDESC' ,'X3_TITULO')		SIZE  35,10 PIXEL OF oGrp31
		//@ 60, 40 MSGET oXDESC VAR aPagParc[ nXDESC ]			SIZE GetSx3Cache('E2_XDESC' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp31 VALID .T. WHEN .T.  PICTURE GetSx3Cache('E2_XJUROS','X3_PICTURE')	
		//@ 78, 5  SAY   GetSx3Cache('E2_XSACADO' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp31
		//@ 75, 40 MSGET aPagParc[ nXSACADO ]			SIZE GetSx3Cache('E2_XSACADO' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp31 VALID .T. WHEN .T.	
	
		//Grp35
		@ 18, 5  SAY   GetSx3Cache('E2_CODBAR' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp35
		@ 15, 40 MSGET oCODBAR VAR aPagParc[ nCODBAR ]			SIZE GetSx3Cache('E2_CODBAR' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp35 VALID .T. WHEN .T.		
		@ 33, 5  SAY   GetSx3Cache('E2_LINDIG' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp35
		@ 30, 40 MSGET oLINDIG VAR aPagParc[ nLINDIG ]			SIZE GetSx3Cache('E2_LINDIG' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp35 VALID .T. WHEN .T.	
		@ 48, 5  SAY   GetSx3Cache('E2_XCFGTS' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp35
		@ 45, 40 MSGET oXCFGTS VAR aPagParc[ nXCFGTS ]			SIZE GetSx3Cache('E2_XCFGTS' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp35 VALID .T. WHEN .T.	
		@ 63, 5  SAY   GetSx3Cache('E2_XIDFGTS' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp35
		@ 60, 40 MSGET oXIDFGTS VAR aPagParc[ nXIDFGTS ]		SIZE GetSx3Cache('E2_XIDFGTS' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp35 VALID .T. WHEN .T.	
		@ 78, 5  SAY   GetSx3Cache('E2_XDLFGTS' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp35
		@ 75, 40 MSGET oXDLFGTS VAR aPagParc[ nXDLFGTS ]		SIZE GetSx3Cache('E2_XDLFGTS' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp35 VALID .T. WHEN .T.	
		@ 93, 5  SAY   GetSx3Cache('E2_XLCFGTS' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp35
		@ 90, 40 MSGET oXLCFGTS VAR aPagParc[ nXLCFGTS ]		SIZE GetSx3Cache('E2_XLCFGTS' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp35 VALID .T. WHEN .T.	
	
	/*
		//Grp10
		//Grp11
		//Grp13
		//Grp16
		//Grp17
		//Grp18
		//Grp19
		//Grp21
		//Grp22
		//Grp25
		//Grp27
		//Grp30
		//Grp31
		//Grp32
		//Grp35
		//Grp60
		//Grp91
	*/
		oGrp01:lVisibleControl := .F.
		oGrp02:lVisibleControl := .F.
		oGrp03:lVisibleControl := .F.
		oGrp04:lVisibleControl := .F.
		oGrp05:lVisibleControl := .F.
		oGrp06:lVisibleControl := .F.
		oGrp07:lVisibleControl := .F.
		oGrp41:lVisibleControl := .F.
		oGrp45:lVisibleControl := .F.		
		oGrp43:lVisibleControl := .F.
		oGrp10:lVisibleControl := .F.
		oGrp13:lVisibleControl := .F.
		oGrp16:lVisibleControl := .F.
		oGrp17:lVisibleControl := .F.
		oGrp18:lVisibleControl := .F.
		oGrp19:lVisibleControl := .F.
		oGrp21:lVisibleControl := .F.
		oGrp22:lVisibleControl := .F.
		oGrp25:lVisibleControl := .F.
		oGrp27:lVisibleControl := .F.
		oGrp30:lVisibleControl := .F.
		oGrp31:lVisibleControl := .F.
		oGrp32:lVisibleControl := .F.
		oGrp35:lVisibleControl := .F.
		oGrp60:lVisibleControl := .F.
		oGrp91:lVisibleControl := .F.
	
	ACTIVATE DIALOG oDialogo CENTERED ON INIT EnchoiceBar(oDialogo,{||If(TudoOK(),(nOpc := 1,oDialogo:End()),nOpc := 0)},{||(nOpc := 0,oDialogo:End())},.F.,{},,,.F.,.F.,.F.,.T.,.F.,'ECOM005') 
	
	//If aPagParc[ nMODELO ] $ "30/31/13"    
	    If !Empty(Alltrim(aPagParc[ nCODBAR ]))
			aPagParc[ nLINDIG ] := aPagParc[ nCODBAR ]
			aPagParc[ nCODBAR ] := ""
		EndIf
	//EndIf
	
	If nOpc == 1
		lRet := .T.
		oMODELO  := Nil
		oDescTipo:= Nil
		oTIPOPAG := Nil
		oDescForma:= Nil
		oFCTADV  := Nil
		oFAGEDV  := Nil
		oFORAGE  := Nil
		oFORBCO  := Nil
		oFORCTA  := Nil
		oCODBAR  := Nil
		oLINDIG  := Nil
		oXCDARF  := Nil
		oIDDARF  := Nil
		oXDTREF  := Nil
		oXIDENT  := Nil
		oXJUROS  := Nil
		oXMULTA  := Nil
		oCODINS  := Nil
		oXVLROUT := Nil
		//oXDESC   := Nil
		//oXSACADO := Nil
		oXCFGTS  := Nil
		oXIDFGTS := Nil
		oXDLFGTS := Nil
		oXLCFGTS := Nil
		oXNUMREF := Nil
		oXCGARE  := Nil
		oXEXIPVA := Nil
		oXMUIPVA := Nil
		oXOPIPVA := Nil
		oXPLACA  := Nil
		oXRENAVA := Nil
		oXUFIPVA := Nil
		oXNBENEF := Nil
		oGrp01 := Nil
		oGrp02 := Nil
		oGrp03 := Nil
		oGrp05 := Nil
		oGrp06 := Nil
		oGrp07 := Nil
		oGrp41 := Nil
		oGrp45 := Nil		
		oGrp43 := Nil
		oGrp10 := Nil
		oGrp13 := Nil
		oGrp16 := Nil
		oGrp17 := Nil
		oGrp18 := Nil
		oGrp19 := Nil
		oGrp21 := Nil
		oGrp22 := Nil
		oGrp25 := Nil
		oGrp27 := Nil
		oGrp30 := Nil
		oGrp31 := Nil
		oGrp32 := Nil
		oGrp35 := Nil
		oGrp60 := Nil
		oGrp91 := Nil
	Else
		lRet := .F.
		oDialogo 	:= Nil
		oTitulos	:= Nil
	Endif

	cCadastro := cBkCad
		
return lRet

User Function TrocaP(cAtivo)

	If Alltrim(cAtivo) <> "" .and. Type("oGrp" + cAtivo) <> "U"
		oGrp01:lVisibleControl := .F.
		oGrp02:lVisibleControl := .F.
		oGrp03:lVisibleControl := .F.
		oGrp04:lVisibleControl := .F.
		oGrp05:lVisibleControl := .F.
		oGrp06:lVisibleControl := .F.
		oGrp07:lVisibleControl := .F.
		oGrp41:lVisibleControl := .F.
		oGrp45:lVisibleControl := .F.
		oGrp43:lVisibleControl := .F.
		oGrp10:lVisibleControl := .F.
		oGrp11:lVisibleControl := .F.
		oGrp13:lVisibleControl := .F.
		oGrp16:lVisibleControl := .F.
		oGrp17:lVisibleControl := .F.
		oGrp18:lVisibleControl := .F.
		oGrp19:lVisibleControl := .F.
		oGrp21:lVisibleControl := .F.
		oGrp22:lVisibleControl := .F.
		oGrp25:lVisibleControl := .F.
		oGrp27:lVisibleControl := .F.
		oGrp30:lVisibleControl := .F.
		oGrp31:lVisibleControl := .F.
		oGrp32:lVisibleControl := .F.
		oGrp35:lVisibleControl := .F.
		oGrp60:lVisibleControl := .F.
		oGrp91:lVisibleControl := .F.

		&("oGrp" + cAtivo + ":lVisibleControl := .T.")
	Endif
	
Return

Static Function AtuCpo()

	If nLinAnt <> oTitulos:nAt
		aPagParc 	:= oTitulos:aArray[oTitulos:nAt,Len(aCpHead)+2]
		nLinAnt 	:= oTitulos:nAt
		cDescTipo	:= AllTrim(GetAdvFVal("SX5","X5_DESCRI",xFilial("SX5")+PADR(GetSx3Cache('EA_TIPOPAG','X3_F3'),TamSX3('EA_TIPOPAG')[1])+aPagParc[ nTIPOPAG],1))
		oDescTipo:Refresh()
		cDescForma	:= AllTrim(GetAdvFVal("SX5","X5_DESCRI",xFilial("SX5")+PADR(GetSx3Cache('EA_MODELO','X3_F3') ,TamSX3('EA_MODELO')[1]) +aPagParc[ nMODELO ],1))
		oDescForma:Refresh()
		oMODELO :Refresh()
		oTIPOPAG:Refresh()
		oFCTADV :Refresh()
		oFAGEDV :Refresh()
		oFORAGE :Refresh()
		oFORBCO :Refresh()
		oFORCTA :Refresh()
		oCODBAR :Refresh()
		oLINDIG :Refresh()
		oXCDARF :Refresh()
		oIDDARF :Refresh()
		oXDTREF :Refresh()
		oXIDENT :Refresh()
		oXJUROS :Refresh()
		oXMULTA :Refresh()
		oCODINS :Refresh()
		oXVLROUT:Refresh()
		//oXDESC  :Refresh()
		//oXSACADO:Refresh()
		oXCFGTS :Refresh()
		oXIDFGTS:Refresh()
		oXDLFGTS:Refresh()
		oXLCFGTS:Refresh()
		oXNBENEF:Refresh()
		//oXNUMREF:Refresh()
		//oXCGARE :Refresh()
		//oXEXIPVA:Refresh()
		//oXMUIPVA:Refresh()
		//oXOPIPVA:Refresh()
		//oXPLACA :Refresh()
		//oXRENAVA:Refresh()
		//oXUFIPVA:Refresh()
	Endif
	
Return .T.

Static Function TudoOK()

	Local lRet := .T.
	Local aArray := oTitulos:aArray
	Local nX := 0
	
	For nX := 1 to Len(aArray)
		If alltrim(aArray[nX,5,nMODELO]) == ''
			MsgAlert("A forma de pagamento é obrigatória para todas as parcelas.","Pagamento")
			lRet := .F.
			Exit
		Endif
	Next nX
	
Return lRet

/*
ClearVarSetGet
ContType (Retorna um array com o tipo da variável. Diferente do ValType, retorna o tipo original da variável)
Type (Retorna o tipo de dado de uma expressão ou variável)
VarRef (Cria referência entre duas variáveis)
ValType (Retorna um caractere que identifica o tipo de dado da variável informada através do parâmetro)
VarSetGet (Permite associar um bloco de código a uma variável de programa do Advpl, onde o bloco de código será chamado quando a variável for acessada)
*/

