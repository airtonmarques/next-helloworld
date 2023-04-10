#include 'protheus.ch'
#include 'parmtype.ch'
/*
+-----------+-----------+-------+-------------------------------+------+------------+
| Programa  | ECOM011   | Autor | DFSSISTEMAS                   | Data | 18/07/2018 |
+-----------+-----------+-------+-------------------------------+------+------------+
| Descricao | Tela customizada para informação de dados de pagamento                |
+-----------+-----------------------------------------------------------------------+
| Uso       | Pontos de entrada F050ROT e FA750BRW                                  |
+-----------+-----------------------------------------------------------------------+ 
*/ 
user function ECOM011()

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
	Private cTipoId	:= ''

	Private oMODELO  := Nil
	Private oDescTipo:= Nil
	Private oDATAAGE := Nil
	Private oDATAVEN := Nil
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
	Private oXIDENTF := Nil
	Private oXIDENTJ := Nil
	Private oXJUROS  := Nil
	Private oXMULTA  := Nil
	Private oCODINS  := Nil
	Private oXVLROUT := Nil
	Private oXDESC   := Nil
	Private oXSACADO := Nil
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
	Private oCPFCNPJ := Nil
	Private oLeitor	 := Nil
	Private oXIDRECE := Nil
	Private oXNOMREC := Nil

	cBkCad		:= cCadastro

	Private nLinAnt	:= 0
	Private oTitulos:= Nil
	Private oGrp01 := Nil
	Private oGrp02 := Nil
	Private oGrp03 := Nil
	Private oGrp04 := Nil
	Private oGrp05 := Nil
	Private oGrp06 := Nil
	Private oGrp07 := Nil
	Private oGrp41 := Nil
	Private oGrp45 := Nil
	Private oGrp43 := Nil
	Private oGrp10 := Nil
	Private oGrp11 := Nil
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
	Private nDATAAGE := 0
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
	Private nXIDRECE := 0
	Private nXNOMREC := 0
	Private lFinExec := IsInCallStack("FINA750") .Or. IsInCallStack("FINA050")

	Private aPagParc := {}

	If Type("aPagtos") == "U"
		Public aPagtos	:= {}
		Public aCpHPag	:= {}
		Public nParcPag	:= 1
	Else
		aPagtos	:= {}
		aCpHPag	:= {}
		nParcPag:= 1
	Endif

	cCadastro := 'Dados para Pagamento'

	aAdd(aCampos,{'E2_FORMPAG'}) //,TamSX3('EA_MODELO'  )[1],'oCpo01'})
	aAdd(aCampos,{'E2_DATAAGE'})
	
	If lFinExec
		aAdd(aCampos,{'E2_VENCTO'})  
		aAdd(aCampos,{'E2_VENCREA'}) 
	Endif

	aAdd(aCampos,{'E2_FCTADV' })   // TamSX3('E2_FCTADV' )[1]*4})
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
	aAdd(aCampos,{'E2_XSACADO'}) //,TamSX3('E2_XSACADO')[1]*4})
	aAdd(aCampos,{'E2_XCFGTS' }) //,TamSX3('E2_XCFGTS' )[1]*4})
	aAdd(aCampos,{'E2_XIDFGTS'}) //,TamSX3('E2_XIDFGTS')[1]*4})
	aAdd(aCampos,{'E2_XDLFGTS'}) //,TamSX3('E2_XDLFGTS')[1]*4})
	aAdd(aCampos,{'E2_XLCFGTS'}) //,TamSX3('E2_XLCFGTS')[1]*4})
	aAdd(aCampos,{'E2_XNBENEF'})
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

	For nI := 1 to Len(aCampos)
		If !Empty(GetSx3Cache(aCampos[nI,1] ,'X3_CAMPO'))
			aadd(aCpHPag,aCampos[nI,1])
			aAdd(aLinha,&('SE2->'+aCampos[nI,1]))
		Endif
	Next nI
	aAdd(aLinha,.F.)

	nXIDRECE := aScan(aCpHPag,'E2_XIDRECE')
	nXNOMREC := aScan(aCpHPag,'E2_XNOMREC')
	nFORAGE  := aScan(aCpHPag,'E2_FORAGE' )
	nFORBCO  := aScan(aCpHPag,'E2_FORBCO' )
	nFORCTA  := aScan(aCpHPag,'E2_FORCTA' )

		
	dbSelectArea("SA2")
	dbSetOrder(1) //A2_FILIAL+A2_COD+A2_LOJA                                                                                       
	dbSeek( xFilial("SA2") + SE2->E2_FORNECE+SE2->E2_LOJA)
	
	dbSelectArea("FIL")
	dbSetOrder(1)//FIL_FILIAL+FIL_FORNEC+FIL_LOJA+FIL_TIPO+FIL_BANCO+FIL_AGENCI+FIL_CONTA                                                                                          
	If dbSeek( xFilial("FIL") + SA2->A2_COD + SA2->A2_LOJA + "1" + aLinha[nFORBCO] + aLinha[nFORAGE] + aLinha[nFORCTA] )
		aLinha[nXIDRECE] := FIL->FIL_XIDREC
		aLinha[nXNOMREC] := FIL->FIL_XNOMRE
	Endif
	
	aPagParc := aClone(aLinha)

	nMODELO  := aScan(aCpHPag,'E2_FORMPAG')

	If lFinExec
		nDTVNORI := aScan(aCpHPag,'E2_VENCTO' ) 
		nDATAVEN := aScan(aCpHPag,'E2_VENCREA')
	Endif	

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
	nXIDRECE := aScan(aCpHPag,'E2_XIDRECE')
	nXNOMREC := aScan(aCpHPag,'E2_XNOMREC')


	cDescForma := AllTrim(GetAdvFVal("SX5","X5_DESCRI",xFilial("SX5")+PADR(GetSx3Cache('E2_FORMPAG','X3_F3'),TamSX3('E2_FORMPAG')[1])+aPagParc[ nMODELO],1))
	cTipoID := If(Len(Alltrim(aPagParc[nXIDENT])) == 14,"1","2")
	lEditar := (__cUserId=='000000' .or. (SE2->E2_SALDO > 0 .AND. alltrim(SE2->E2_NUMBOR) = ''))

	DEFINE DIALOG oDialogo FROM 0,0 TO 380,670 PIXEL TITLE 'DADOS PARA PAGAMENTO'

	oGrupo1 := TGroup():New(33,02,62,335,'',oDialogo,,,.T.)
	
	If lFinExec
	
		@ 40, 004 SAY   'Vencimento'						SIZE  40,10 PIXEL OF oDialogo //20180803 - DFS
		@ 37, 045 MSGET oDATAVEN	VAR aPagParc[nDATAVEN]	SIZE  70,10 PIXEL OF oDialogo WHEN lEditar PICTURE GetSx3Cache('E2_VENCTO','X3_PICTURE')

		@ 40, 120 SAY   'Forma Pagto.'						SIZE  40,10 PIXEL OF oDialogo
		@ 37, 171 MSGET oMODELO		VAR aPagParc[nMODELO]	SIZE  20,10 PIXEL OF oDialogo F3 GetSx3Cache('EA_MODELO' ,'X3_F3') VALID {|| cDescForma := AllTrim(GetAdvFVal("SX5","X5_DESCRI",xFilial("SX5")+PADR(GetSx3Cache('EA_MODELO','X3_F3'),TamSX3('EA_MODELO')[1])+aPagParc[ nMODELO],1)),u_TrocaP(aPagParc[ nMODELO ])} WHEN lEditar PICTURE GetSx3Cache('EA_MODELO' ,'X3_PICTURE')
		@ 37, 192 MSGET oDescForma	VAR cDescForma			SIZE 130,10 PIXEL OF oDialogo VALID .T. WHEN .F.
	
	Else
		
		@ 40, 004 SAY   'Forma Pagto.'						SIZE  40,10 PIXEL OF oDialogo
		@ 37, 045 MSGET oMODELO		VAR aPagParc[nMODELO]	SIZE  20,10 PIXEL OF oDialogo F3 GetSx3Cache('EA_MODELO' ,'X3_F3') VALID {|| cDescForma := AllTrim(GetAdvFVal("SX5","X5_DESCRI",xFilial("SX5")+PADR(GetSx3Cache('EA_MODELO','X3_F3'),TamSX3('EA_MODELO')[1])+aPagParc[ nMODELO],1)),u_TrocaP(aPagParc[ nMODELO ])} WHEN lEditar PICTURE GetSx3Cache('EA_MODELO' ,'X3_PICTURE')
		@ 37, 066 MSGET oDescForma	VAR cDescForma			SIZE 130,10 PIXEL OF oDialogo VALID .T. WHEN .F.
	
	Endif	

	If lFinExec
		aPagParc[nDTVNORI] := aPagParc[nDATAVEN]
	Endif	

	nMgX	:= 3 //175
	nMgY	:= 55 // 35
	nLarg	:= 310 //oFolder:nWidth-nMgX
	nAlt	:= 130 //oFolder:nHeight-20

	oGrupo2 := TGroup():New(64, 02,208,335,'',oDialogo,,,.T.)

	oGrp01 := TPanel():New(nMgY, nMgX,/*'Credito em Conta Corrente'			*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //CRÉDITO EM CONTA CORRENTE NO ITAÚ
	oGrp03 := TPanel():New(nMgY, nMgX,/*'DOC C'								*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //DOC “C ”
	oGrp05 := TPanel():New(nMgY, nMgX,/*'Credito em Conta Poupanca'			*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //CRÉDITO EM CONTA POUPANÇA NO ITAÚ
	oGrp06 := TPanel():New(nMgY, nMgX,/*'Credito C/c mesma titularidade'	*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //CRÉDITO EM CONTA CORRENTE DE MESMA TITULARIDADE
	oGrp07 := TPanel():New(nMgY, nMgX,/*'DOC D'								*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //DOC “D ”
	oGrp41 := TPanel():New(nMgY, nMgX,/*'TED – OUTRO TITULAR'				*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //TED – OUTRO TITULAR
	oGrp45 := TPanel():New(nMgY, nMgX,/*'TED – OUTRO TITULAR'				*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //TED – OUTRO TITULAR
	oGrp43 := TPanel():New(nMgY, nMgX,/*'TED – MESMO TITULAR'				*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //TED – MESMO TITULAR
	oGrp04 := TPanel():New(nMgY, nMgX,/*'Ordem de Pagamento com aviso'		*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //ORDEM DE PAGAMENTO À DISPOSIÇÃO
	oGrp10 := TPanel():New(nMgY, nMgX,/*'Ordem de Pagamento sem aviso'		*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //ORDEM DE PAGAMENTO À DISPOSIÇÃO
	oGrp13 := TPanel():New(nMgY, nMgX,/*'Pagamento a concessionarias'		*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //PAGAMENTO DE CONCESSIONÁRIAS
	oGrp16 := TPanel():New(nMgY, nMgX,/*'DARF Normal'						*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //DARF NORMAL
	oGrp17 := TPanel():New(nMgY, nMgX,/*'GPS'								*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //GPS - GUIA DA PREVIDÊNCIA SOCIAL
	oGrp30 := TPanel():New(nMgY, nMgX,/*'PAGAMENTO TITULOS DO ITAU'			*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //PAGAMENTO DE TÍTULOS EM COBRANÇA NO ITAÚ
	oGrp31 := TPanel():New(nMgY, nMgX,/*'PAGAMENTO TITULOS OUTROS BANCOS'	*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //PAGAMENTO DE TÍTULOS EM COBRANÇA EM OUTROS BANCOS
	oGrp35 := TPanel():New(nMgY, nMgX,/*'FGTS – GFIP'						*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //FGTS – GFIP

	oGrp02 := TPanel():New(nMgY, nMgX,/*'Cheque Administrativo'				*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //CHEQUE PAGAMENTO/ADMINISTRATIVO
	oGrp18 := TPanel():New(nMgY, nMgX,/*'DARF SIMPLES'						*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //DARF SIMPLES
	oGrp19 := TPanel():New(nMgY, nMgX,/*'IPTU/ISS/OUTROS TRIBUTOS MUNIC.'	*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //IPTU/ISS/OUTROS TRIBUTOS MUNICIPAIS
	oGrp21 := TPanel():New(nMgY, nMgX,/*'DARJ'								*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //DARJ
	oGrp22 := TPanel():New(nMgY, nMgX,/*'GARE – SP ICMS'					*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //GARE – SP ICMS
	oGrp25 := TPanel():New(nMgY, nMgX,/*'IPVA'								*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //IPVA
	oGrp27 := TPanel():New(nMgY, nMgX,/*'DPVAT'								*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //DPVAT
	oGrp32 := TPanel():New(nMgY, nMgX,/*'LIQUIDACAO ELETRONICA'				*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //NOTA FISCAL – LIQUIDAÇÃO ELETRÔNICA
	oGrp60 := TPanel():New(nMgY, nMgX,/*'CARTÃO SALÁRIO'					*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //CARTÃO SALÁRIO
	oGrp11 := TPanel():New(nMgY, nMgX,/*'LUCIANO CATIMBA'					*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //LUCIANO CATIMBA
	oGrp91 := TPanel():New(nMgY, nMgX,/*'GNRE E TRIBUTOS COM CÓD.BARRAS'	*/,oDialogo,,.F.,,,,nLarg,nAlt,.F.,.F.) //GNRE E TRIBUTOS COM CÓDIGO DE BARRAS
	
	@ 8, 5  SAY   GetSx3Cache('E2_CODBAR' ,'X3_TITULO')		SIZE  35,10 PIXEL OF oGrp11
	@ 5, 40 MSGET oCODBAR VAR aPagParc[ nCODBAR ]			SIZE GetSx3Cache('E2_CODBAR' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp11 VALID u_CBtoLD(aPagParc[nCODBAR]) WHEN lEditar
	@ 23, 5  SAY   GetSx3Cache('E2_LINDIG' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp11
	@ 20, 40 MSGET oLINDIG VAR aPagParc[ nLINDIG ]			SIZE GetSx3Cache('E2_LINDIG' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp11 VALID u_LDtoCB(aPagParc[nLINDIG]) WHEN lEditar PICTURE '@R 99999.99999 99999.999999 99999.999999 9 999999999999999'


	@ 8, 5  SAY   GetSx3Cache('E2_CODBAR' ,'X3_TITULO')		SIZE  35,10 PIXEL OF oGrp91
	@ 5, 40 MSGET oCODBAR VAR aPagParc[ nCODBAR ]			SIZE GetSx3Cache('E2_CODBAR' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp91 VALID u_CBtoLD(aPagParc[nCODBAR]) WHEN lEditar
	@ 23, 5  SAY   GetSx3Cache('E2_LINDIG' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp91
	@ 20, 40 MSGET oLINDIG VAR aPagParc[ nLINDIG ]			SIZE GetSx3Cache('E2_LINDIG' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp91 VALID u_LDtoCB(aPagParc[nLINDIG]) WHEN lEditar PICTURE '@R 99999.99999 99999.999999 99999.999999 9 999999999999999'

	//Grp01
	@  8,  5 SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp01
	//@  5, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp01 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN lEditar PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')
	@  5, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp01 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN lEditar PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')
	@ 23,  5 SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp01
	@ 20, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp01 VALID .T. WHEN .F.
	@ 20, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp01 VALID .T. WHEN .F.
	@ 38,  5 SAY   GetSx3Cache('E2_FORCTA' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp01
	@ 35, 40 MSGET oFORCTA VAR aPagParc[ nFORCTA ]			SIZE 30,10 PIXEL OF oGrp01 VALID .T. WHEN .F.
	@ 35, 70 MSGET oFCTADV VAR aPagParc[ nFCTADV ]			SIZE 10,10 PIXEL OF oGrp01 VALID .T. WHEN .F.
	@ 53,  5 SAY   GetSx3Cache('E2_XIDRECE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp01
	@ 50, 40 MSGET oXIDRECE VAR aPagParc[ nXIDRECE ]		SIZE 75,10 PIXEL OF oGrp01 VALID .T. WHEN lEditar
	@ 68,  5 SAY   'Nome receb.'						 	SIZE 35,10 PIXEL OF oGrp01
	@ 65, 40 MSGET oXNOMREC VAR aPagParc[ nXNOMREC ]		SIZE 200,10 PIXEL OF oGrp01 VALID .T. WHEN lEditar

	//Grp03
	@ 8, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')		SIZE 35,10 PIXEL OF oGrp03
	@ 5, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp03 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN lEditar PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')
	@ 23, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp03
	@ 20, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp03 VALID .T. WHEN .F.
	@ 20, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp03 VALID .T. WHEN .F.
	@ 38, 5  SAY   GetSx3Cache('E2_FORCTA' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp03
	@ 35, 40 MSGET oFORCTA VAR aPagParc[ nFORCTA ]			SIZE 30,10 PIXEL OF oGrp03 VALID .T. WHEN .F.
	@ 35, 70 MSGET oFCTADV VAR aPagParc[ nFCTADV ]			SIZE 10,10 PIXEL OF oGrp03 VALID .T. WHEN .F.
	@ 53,  5 SAY   GetSx3Cache('E2_XIDRECE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp03
	@ 50, 40 MSGET oXIDRECE VAR aPagParc[ nXIDRECE ]		SIZE 75,10 PIXEL OF oGrp03 VALID .T. WHEN lEditar
	@ 68,  5 SAY   'Nome receb.'						 	SIZE 35,10 PIXEL OF oGrp03
	@ 65, 40 MSGET oXNOMREC VAR aPagParc[ nXNOMREC ]		SIZE 200,10 PIXEL OF oGrp03 VALID .T. WHEN lEditar

		/*@ 53,  5 SAY   'TIPO ID'								SIZE 35,10 PIXEL OF oGrp03	
		@ 50, 40 MSCOMBOBOX oCPFCNPJ VAR cTipoID ITEMS {"1=CPNJ","2=CPF"} SIZE 40,12 OF oGrp03 PIXEL VALID (If(cTipoID=="2",(oXIDENTF:lVisibleControl := .T.,oXIDENTJ:lVisibleControl := .F.),(oXIDENTF:lVisibleControl := .F.,oXIDENTJ:lVisibleControl := .T.)),.T.)
		@ 50, 80 MSGET oXIDENTF VAR aPagParc[nXIDENT]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp03 VALID .T. WHEN lEditar PICTURE '@R 999.999.999-9'
		@ 50, 80 MSGET oXIDENTJ VAR aPagParc[nXIDENT]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp03 VALID .T. WHEN lEditar PICTURE '@R 99.999.999/9999-99'
		@ 68,  5 SAY   GetSx3Cache('E2_XNBENEF' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp03
		@ 65, 40 MSGET oXNBENEF VAR aPagParc[nXNBENEF]			SIZE GetSx3Cache('E2_XNBENEF','X3_TAMANHO')*4,10 PIXEL OF oGrp03 VALID .T. WHEN lEditar	
		*/
	
	//Grp05
	@ 8, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')		SIZE 35,10 PIXEL OF oGrp05
	@ 5, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp05 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN lEditar PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')
	@ 23, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp05
	@ 20, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp05 VALID .T. WHEN .F.
	@ 20, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp05 VALID .T. WHEN .F.
	@ 38, 5  SAY   GetSx3Cache('E2_FORCTA' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp05
	@ 35, 40 MSGET oFORCTA VAR aPagParc[ nFORCTA ]			SIZE 30,10 PIXEL OF oGrp05 VALID .T. WHEN .F.
	@ 35, 70 MSGET oFCTADV VAR aPagParc[ nFCTADV ]			SIZE 10,10 PIXEL OF oGrp05 VALID .T. WHEN .F.
	@ 53,  5 SAY   GetSx3Cache('E2_XIDRECE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp05
	@ 50, 40 MSGET oXIDRECE VAR aPagParc[ nXIDRECE ]		SIZE 75,10 PIXEL OF oGrp05 VALID .T. WHEN lEditar
	@ 68,  5 SAY   'Nome receb.'						 	SIZE 35,10 PIXEL OF oGrp05
	@ 65, 40 MSGET oXNOMREC VAR aPagParc[ nXNOMREC ]		SIZE 200,10 PIXEL OF oGrp05 VALID .T. WHEN lEditar


		/*@ 53,  5 SAY   'TIPO ID'								SIZE 35,10 PIXEL OF oGrp05	
		@ 50, 40 MSCOMBOBOX oCPFCNPJ VAR cTipoID ITEMS {"1=CPNJ","2=CPF"} SIZE 40,12 OF oGrp05 PIXEL VALID (If(cTipoID=="2",(oXIDENTF:lVisibleControl := .T.,oXIDENTJ:lVisibleControl := .F.),(oXIDENTF:lVisibleControl := .F.,oXIDENTJ:lVisibleControl := .T.)),.T.)
		@ 50, 80 MSGET oXIDENTF VAR aPagParc[nXIDENT]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp05 VALID .T. WHEN lEditar PICTURE '@R 999.999.999-9'
		@ 50, 80 MSGET oXIDENTJ VAR aPagParc[nXIDENT]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp05 VALID .T. WHEN lEditar PICTURE '@R 99.999.999/9999-99'
		@ 68,  5 SAY   GetSx3Cache('E2_XNBENEF' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp05
		@ 65, 40 MSGET oXNBENEF VAR aPagParc[nXNBENEF]			SIZE GetSx3Cache('E2_XNBENEF','X3_TAMANHO')*4,10 PIXEL OF oGrp05 VALID .T. WHEN lEditar	
		*/
	
	//Grp06
	@ 8, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')		SIZE 35,10 PIXEL OF oGrp06
	@ 5, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp06 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN lEditar PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')
	@ 23, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp06
	@ 20, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp06 VALID .T. WHEN .F.
	@ 20, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp06 VALID .T. WHEN .F.
	@ 38, 5  SAY   GetSx3Cache('E2_FORCTA' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp06
	@ 35, 40 MSGET oFORCTA VAR aPagParc[ nFORCTA ]			SIZE 30,10 PIXEL OF oGrp06 VALID .T. WHEN .F.
	@ 35, 70 MSGET oFCTADV VAR aPagParc[ nFCTADV ]			SIZE 10,10 PIXEL OF oGrp06 VALID .T. WHEN .F.
	@ 53,  5 SAY   GetSx3Cache('E2_XIDRECE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp06
	@ 50, 40 MSGET oXIDRECE VAR aPagParc[ nXIDRECE ]		SIZE 75,10 PIXEL OF oGrp06 VALID .T. WHEN lEditar
	@ 68,  5 SAY   'Nome receb.'						 	SIZE 35,10 PIXEL OF oGrp06
	@ 65, 40 MSGET oXNOMREC VAR aPagParc[ nXNOMREC ]		SIZE 200,10 PIXEL OF oGrp06 VALID .T. WHEN lEditar
	
		/*@ 53,  5 SAY   'TIPO ID'								SIZE 35,10 PIXEL OF oGrp06	
		@ 50, 40 MSCOMBOBOX oCPFCNPJ VAR cTipoID ITEMS {"1=CPNJ","2=CPF"} SIZE 40,12 OF oGrp06 PIXEL VALID (If(cTipoID=="2",(oXIDENTF:lVisibleControl := .T.,oXIDENTJ:lVisibleControl := .F.),(oXIDENTF:lVisibleControl := .F.,oXIDENTJ:lVisibleControl := .T.)),.T.)
		@ 50, 80 MSGET oXIDENTF VAR aPagParc[nXIDENT]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp06 VALID .T. WHEN lEditar PICTURE '@R 999.999.999-9'
		@ 50, 80 MSGET oXIDENTJ VAR aPagParc[nXIDENT]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp06 VALID .T. WHEN lEditar PICTURE '@R 99.999.999/9999-99'
		@ 68,  5 SAY   GetSx3Cache('E2_XNBENEF' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp06
		@ 65, 40 MSGET oXNBENEF VAR aPagParc[nXNBENEF]			SIZE GetSx3Cache('E2_XNBENEF','X3_TAMANHO')*4,10 PIXEL OF oGrp06 VALID .T. WHEN lEditar	
		*/
	
	//Grp07
	@ 8, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')		SIZE 35,10 PIXEL OF oGrp07
	@ 5, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp07 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN lEditar PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')
	@ 23, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp07
	@ 20, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp07 VALID .T. WHEN .F.
	@ 20, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp07 VALID .T. WHEN .F.
	@ 38, 5  SAY   GetSx3Cache('E2_FORCTA' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp07
	@ 35, 40 MSGET oFORCTA VAR aPagParc[ nFORCTA ]			SIZE 30,10 PIXEL OF oGrp07 VALID .T. WHEN .F.
	@ 35, 70 MSGET oFCTADV VAR aPagParc[ nFCTADV ]			SIZE 10,10 PIXEL OF oGrp07 VALID .T. WHEN .F.
	@ 53,  5 SAY   GetSx3Cache('E2_XIDRECE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp07
	@ 50, 40 MSGET oXIDRECE VAR aPagParc[ nXIDRECE ]		SIZE 75,10 PIXEL OF oGrp07 VALID .T. WHEN lEditar
	@ 68,  5 SAY   'Nome receb.'						 	SIZE 35,10 PIXEL OF oGrp07
	@ 65, 40 MSGET oXNOMREC VAR aPagParc[ nXNOMREC ]		SIZE 200,10 PIXEL OF oGrp07 VALID .T. WHEN lEditar
	
		/*@ 53,  5 SAY   'TIPO ID'								SIZE 35,10 PIXEL OF oGrp07	
		@ 50, 40 MSCOMBOBOX oCPFCNPJ VAR cTipoID ITEMS {"1=CPNJ","2=CPF"} SIZE 40,12 OF oGrp07 PIXEL VALID (If(cTipoID=="2",(oXIDENTF:lVisibleControl := .T.,oXIDENTJ:lVisibleControl := .F.),(oXIDENTF:lVisibleControl := .F.,oXIDENTJ:lVisibleControl := .T.)),.T.)
		@ 50, 80 MSGET oXIDENTF VAR aPagParc[nXIDENT]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp07 VALID .T. WHEN lEditar PICTURE '@R 999.999.999-9'
		@ 50, 80 MSGET oXIDENTJ VAR aPagParc[nXIDENT]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp07 VALID .T. WHEN lEditar PICTURE '@R 99.999.999/9999-99'
		@ 68,  5 SAY   GetSx3Cache('E2_XNBENEF' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp07
		@ 65, 40 MSGET oXNBENEF VAR aPagParc[nXNBENEF]			SIZE GetSx3Cache('E2_XNBENEF','X3_TAMANHO')*4,10 PIXEL OF oGrp07 VALID .T. WHEN lEditar	
		*/
	
	//Grp45
	@ 8, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')		SIZE 35,10 PIXEL OF oGrp45
	@ 5, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp45 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN lEditar PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')
	@ 23, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp45
	@ 20, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp45 VALID .T. WHEN .F.
	@ 20, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp45 VALID .T. WHEN .F.
	@ 38, 5  SAY   GetSx3Cache('E2_FORCTA' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp45
	@ 35, 40 MSGET oFORCTA VAR aPagParc[ nFORCTA ]			SIZE 30,10 PIXEL OF oGrp45 VALID .T. WHEN .F.
	@ 35, 70 MSGET oFCTADV VAR aPagParc[ nFCTADV ]			SIZE 10,10 PIXEL OF oGrp45 VALID .T. WHEN .F.
	@ 53,  5 SAY   GetSx3Cache('E2_XIDRECE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp45
	@ 50, 40 MSGET oXIDRECE VAR aPagParc[ nXIDRECE ]		SIZE 75,10 PIXEL OF oGrp45 VALID .T. WHEN lEditar
	@ 68,  5 SAY   'Nome receb.'						 	SIZE 35,10 PIXEL OF oGrp45
	@ 65, 40 MSGET oXNOMREC VAR aPagParc[ nXNOMREC ]		SIZE 200,10 PIXEL OF oGrp45 VALID .T. WHEN lEditar

	//Grp41
	@ 8, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')		SIZE 35,10 PIXEL OF oGrp41
	@ 5, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp41 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN lEditar PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')
	@ 23, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp41
	@ 20, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp41 VALID .T. WHEN .F.
	@ 20, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp41 VALID .T. WHEN .F.
	@ 38, 5  SAY   GetSx3Cache('E2_FORCTA' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp41
	@ 35, 40 MSGET oFORCTA VAR aPagParc[ nFORCTA ]			SIZE 30,10 PIXEL OF oGrp41 VALID .T. WHEN .F.
	@ 35, 70 MSGET oFCTADV VAR aPagParc[ nFCTADV ]			SIZE 10,10 PIXEL OF oGrp41 VALID .T. WHEN .F.
	@ 53,  5 SAY   GetSx3Cache('E2_XIDRECE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp41
	@ 50, 40 MSGET oXIDRECE VAR aPagParc[ nXIDRECE ]		SIZE 75,10 PIXEL OF oGrp41 VALID .T. WHEN lEditar
	@ 68,  5 SAY   'Nome receb.'						 	SIZE 35,10 PIXEL OF oGrp41
	@ 65, 40 MSGET oXNOMREC VAR aPagParc[ nXNOMREC ]		SIZE 200,10 PIXEL OF oGrp41 VALID .T. WHEN lEditar
	
		/*@ 53,  5 SAY   'TIPO ID'								SIZE 35,10 PIXEL OF oGrp41	
		@ 50, 40 MSCOMBOBOX oCPFCNPJ VAR cTipoID ITEMS {"1=CPNJ","2=CPF"} SIZE 40,12 OF oGrp41 PIXEL VALID (If(cTipoID=="2",(oXIDENTF:lVisibleControl := .T.,oXIDENTJ:lVisibleControl := .F.),(oXIDENTF:lVisibleControl := .F.,oXIDENTJ:lVisibleControl := .T.)),.T.)
		@ 50, 80 MSGET oXIDENTF VAR aPagParc[nXIDENT]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp41 VALID .T. WHEN lEditar PICTURE '@R 999.999.999-9'
		@ 50, 80 MSGET oXIDENTJ VAR aPagParc[nXIDENT]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp41 VALID .T. WHEN lEditar PICTURE '@R 99.999.999/9999-99'
		@ 68,  5 SAY   GetSx3Cache('E2_XNBENEF' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp41
		@ 65, 40 MSGET oXNBENEF VAR aPagParc[nXNBENEF]			SIZE GetSx3Cache('E2_XNBENEF','X3_TAMANHO')*4,10 PIXEL OF oGrp41 VALID .T. WHEN lEditar	
		*/
	//Grp43
	@ 8, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')		SIZE 35,10 PIXEL OF oGrp43
	@ 5, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp43 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN lEditar PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')
	@ 23, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp43
	@ 20, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp43 VALID .T. WHEN .F.
	@ 20, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp43 VALID .T. WHEN .F.
	@ 38, 5  SAY   GetSx3Cache('E2_FORCTA' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp43
	@ 35, 40 MSGET oFORCTA VAR aPagParc[ nFORCTA ]			SIZE 30,10 PIXEL OF oGrp43 VALID .T. WHEN .F.
	@ 35, 70 MSGET oFCTADV VAR aPagParc[ nFCTADV ]			SIZE 10,10 PIXEL OF oGrp43 VALID .T. WHEN .F.
	@ 53,  5 SAY   GetSx3Cache('E2_XIDRECE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp43
	@ 50, 40 MSGET oXIDRECE VAR aPagParc[ nXIDRECE ]		SIZE 75,10 PIXEL OF oGrp43 VALID .T. WHEN lEditar
	@ 68,  5 SAY   'Nome receb.'						 	SIZE 35,10 PIXEL OF oGrp43
	@ 65, 40 MSGET oXNOMREC VAR aPagParc[ nXNOMREC ]		SIZE 200,10 PIXEL OF oGrp43 VALID .T. WHEN lEditar
	
		/*@ 53,  5 SAY   'TIPO ID'								SIZE 35,10 PIXEL OF oGrp43	
		@ 50, 40 MSCOMBOBOX oCPFCNPJ VAR cTipoID ITEMS {"1=CPNJ","2=CPF"} SIZE 40,12 OF oGrp43 PIXEL VALID (If(cTipoID=="2",(oXIDENTF:lVisibleControl := .T.,oXIDENTJ:lVisibleControl := .F.),(oXIDENTF:lVisibleControl := .F.,oXIDENTJ:lVisibleControl := .T.)),.T.)
		@ 50, 80 MSGET oXIDENTF VAR aPagParc[nXIDENT]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp43 VALID .T. WHEN lEditar PICTURE '@R 999.999.999-9'
		@ 50, 80 MSGET oXIDENTJ VAR aPagParc[nXIDENT]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp43 VALID .T. WHEN lEditar PICTURE '@R 99.999.999/9999-99'
		@ 68,  5 SAY   GetSx3Cache('E2_XNBENEF' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp43
		@ 65, 40 MSGET oXNBENEF VAR aPagParc[nXNBENEF]			SIZE GetSx3Cache('E2_XNBENEF','X3_TAMANHO')*4,10 PIXEL OF oGrp43 VALID .T. WHEN lEditar	
		*/
	
	//Grp04
	@ 8, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')		SIZE 35,10 PIXEL OF oGrp04
	@ 5, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp04 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN lEditar PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')
	@ 23, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp04
	@ 20, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp04 VALID .T. WHEN .F.
	@ 20, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp04 VALID .T. WHEN .F.
	@ 53,  5 SAY   GetSx3Cache('E2_XIDRECE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp04
	@ 50, 40 MSGET oXIDRECE VAR aPagParc[ nXIDRECE ]		SIZE 75,10 PIXEL OF oGrp04 VALID .T. WHEN lEditar
	@ 68,  5 SAY   'Nome receb.'						 	SIZE 35,10 PIXEL OF oGrp04
	@ 65, 40 MSGET oXNOMREC VAR aPagParc[ nXNOMREC ]		SIZE 200,10 PIXEL OF oGrp04 VALID .T. WHEN lEditar
	
		/*@ 53,  5 SAY   'TIPO ID'								SIZE 35,10 PIXEL OF oGrp04	
		@ 50, 40 MSCOMBOBOX oCPFCNPJ VAR cTipoID ITEMS {"1=CPNJ","2=CPF"} SIZE 40,12 OF oGrp04 PIXEL VALID (If(cTipoID=="2",(oXIDENTF:lVisibleControl := .T.,oXIDENTJ:lVisibleControl := .F.),(oXIDENTF:lVisibleControl := .F.,oXIDENTJ:lVisibleControl := .T.)),.T.)
		@ 50, 80 MSGET oXIDENTF VAR aPagParc[nXIDENT]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp04 VALID .T. WHEN lEditar PICTURE '@R 999.999.999-9'
		@ 50, 80 MSGET oXIDENTJ VAR aPagParc[nXIDENT]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp04 VALID .T. WHEN lEditar PICTURE '@R 99.999.999/9999-99'
		@ 68,  5 SAY   GetSx3Cache('E2_XNBENEF' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp04
		@ 65, 40 MSGET oXNBENEF VAR aPagParc[nXNBENEF]			SIZE GetSx3Cache('E2_XNBENEF','X3_TAMANHO')*4,10 PIXEL OF oGrp04 VALID .T. WHEN lEditar	
		*/
	
	//Grp10
	@ 8, 5  SAY   GetSx3Cache('E2_FORBCO' ,'X3_TITULO')		SIZE 35,10 PIXEL OF oGrp10
	@ 5, 40 MSGET oFORBCO VAR aPagParc[ nFORBCO ]			SIZE 20,10 PIXEL OF oGrp10 F3 GetSx3Cache('E2_FORBCO','X3_F3') VALID .T. WHEN lEditar PICTURE GetSx3Cache('E2_FORBCO','X3_PICTURE')
	@ 23, 5  SAY   GetSx3Cache('E2_FORAGE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp10
	@ 20, 40 MSGET oFORAGE VAR aPagParc[ nFORAGE ]			SIZE 20,10 PIXEL OF oGrp10 VALID .T. WHEN .F.
	@ 20, 70 MSGET oFAGEDV VAR aPagParc[ nFAGEDV ]			SIZE 10,10 PIXEL OF oGrp10 VALID .T. WHEN .F.
	@ 53,  5 SAY   GetSx3Cache('E2_XIDRECE' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp10
	@ 50, 40 MSGET oXIDRECE VAR aPagParc[ nXIDRECE ]		SIZE 75,10 PIXEL OF oGrp10 VALID .T. WHEN lEditar
	@ 68,  5 SAY   'Nome receb.'						 	SIZE 35,10 PIXEL OF oGrp10
	@ 65, 40 MSGET oXNOMREC VAR aPagParc[ nXNOMREC ]		SIZE 200,10 PIXEL OF oGrp10 VALID .T. WHEN lEditar  
	
		/*@ 53,  5 SAY   'TIPO ID'								SIZE 35,10 PIXEL OF oGrp10	
		@ 50, 40 MSCOMBOBOX oCPFCNPJ VAR cTipoID ITEMS {"1=CPNJ","2=CPF"} SIZE 40,12 OF oGrp10 PIXEL VALID (If(cTipoID=="2",(oXIDENTF:lVisibleControl := .T.,oXIDENTJ:lVisibleControl := .F.),(oXIDENTF:lVisibleControl := .F.,oXIDENTJ:lVisibleControl := .T.)),.T.)
		@ 50, 80 MSGET oXIDENTF VAR aPagParc[nXIDENT]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp10 VALID .T. WHEN lEditar PICTURE '@R 999.999.999-9'
		@ 50, 80 MSGET oXIDENTJ VAR aPagParc[nXIDENT]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp10 VALID .T. WHEN lEditar PICTURE '@R 99.999.999/9999-99'
		@ 68,  5 SAY   GetSx3Cache('E2_XNBENEF' ,'X3_TITULO')	SIZE 35,10 PIXEL OF oGrp10
		@ 65, 40 MSGET oXNBENEF VAR aPagParc[nXNBENEF]			SIZE GetSx3Cache('E2_XNBENEF','X3_TAMANHO')*4,10 PIXEL OF oGrp10 VALID .T. WHEN lEditar	
		*/		
	
	//Grp13
	@ 8, 5  SAY   GetSx3Cache('E2_CODBAR' ,'X3_TITULO')		SIZE  35,10 PIXEL OF oGrp13
	@ 5, 40 MSGET oCODBAR VAR aPagParc[ nCODBAR ]			SIZE GetSx3Cache('E2_CODBAR' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp13 VALID u_CBtoLD(aPagParc[nCODBAR]) WHEN lEditar
	@ 23, 5  SAY   GetSx3Cache('E2_LINDIG' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp13
	@ 20, 40 MSGET oLINDIG VAR aPagParc[ nLINDIG ]			SIZE GetSx3Cache('E2_LINDIG' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp13 VALID u_LDtoCB(aPagParc[nLINDIG]) WHEN lEditar PICTURE '@R 99999.99999 99999.999999 99999.999999 9 999999999999999'

	//Grp16
	@ 8, 5  SAY   GetSx3Cache('E2_CODBAR' ,'X3_TITULO')		SIZE  35,10 PIXEL OF oGrp16
	@ 5, 40 MSGET oCODBAR VAR aPagParc[ nCODBAR ]			SIZE GetSx3Cache('E2_CODBAR' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp16 VALID  u_CBtoLD(aPagParc[nCODBAR]) WHEN lEditar
	@ 23, 5  SAY   GetSx3Cache('E2_LINDIG' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp16
	@ 20, 40 MSGET oLINDIG VAR aPagParc[ nLINDIG ]			SIZE GetSx3Cache('E2_LINDIG' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp16 VALID  u_LDtoCB(aPagParc[nLINDIG]) WHEN lEditar PICTURE '@R 99999.99999 99999.999999 99999.999999 9 999999999999999'
	@ 38, 5  SAY   GetSx3Cache('E2_XCDARF' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp16
	@ 35, 40 MSGET oXCDARF VAR aPagParc[ nXCDARF ]			SIZE GetSx3Cache('E2_XCDARF' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp16 VALID .T. WHEN lEditar
	@ 53, 5  SAY   GetSx3Cache('E2_IDDARF' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp16
	@ 50, 40 MSGET oIDDARF VAR aPagParc[ nIDDARF ]			SIZE GetSx3Cache('E2_IDDARF' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp16 VALID .T. WHEN lEditar
	@ 68, 5  SAY   GetSx3Cache('E2_XIDENT' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp16
	@ 65, 40 MSGET oXIDENT VAR aPagParc[ nXIDENT ]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp16 VALID .T. WHEN lEditar
	@ 83, 5  SAY   GetSx3Cache('E2_XDTREF' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp16
	@ 80, 40 MSGET oXDTREF VAR aPagParc[ nXDTREF ]			SIZE GetSx3Cache('E2_XDTREF' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp16 VALID .T. WHEN lEditar PICTURE GetSx3Cache('E2_XDTREF','X3_PICTURE')
	@ 108, 5  SAY   GetSx3Cache('E2_XJUROS' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp16
	@ 105, 40 MSGET oXJUROS VAR aPagParc[ nXJUROS ]			SIZE GetSx3Cache('E2_XJUROS' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp16 VALID .T. WHEN lEditar PICTURE GetSx3Cache('E2_XJUROS','X3_PICTURE')
	@ 123, 5  SAY   GetSx3Cache('E2_XMULTA' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp16
	@ 120, 40 MSGET oXMULTA VAR aPagParc[ nXMULTA ]			SIZE GetSx3Cache('E2_XMULTA' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp16 VALID .T. WHEN lEditar PICTURE GetSx3Cache('E2_XMULTA','X3_PICTURE')

	//Grp17
	@ 8, 5  SAY   GetSx3Cache('E2_CODINS' ,'X3_TITULO')		SIZE  35,10 PIXEL OF oGrp17
	@ 5, 40 MSGET oCODINS VAR aPagParc[ nCODINS ]			SIZE GetSx3Cache('E2_CODINS' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp17 VALID .T. WHEN lEditar
	@ 23, 5  SAY   GetSx3Cache('E2_XDTREF' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp17
	@ 20, 40 MSGET oCODINS VAR aPagParc[ nXDTREF ]			SIZE GetSx3Cache('E2_XDTREF' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp17 VALID .T. WHEN lEditar
	@ 38, 5  SAY   GetSx3Cache('E2_XIDENT' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp17
	@ 35, 40 MSGET oXIDENT VAR aPagParc[ nXIDENT ]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp17 VALID .T. WHEN lEditar
	@ 53, 5  SAY   GetSx3Cache('E2_XJUROS' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp17
	@ 50, 40 MSGET oXJUROS VAR aPagParc[ nXJUROS ]			SIZE GetSx3Cache('E2_XJUROS' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp17 VALID .T. WHEN lEditar  PICTURE GetSx3Cache('E2_XJUROS','X3_PICTURE')
	@ 68, 5  SAY   GetSx3Cache('E2_XMULTA' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp17
	@ 65, 40 MSGET oXMULTA VAR aPagParc[ nXMULTA ]			SIZE GetSx3Cache('E2_XMULTA' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp17 VALID .T. WHEN lEditar  PICTURE GetSx3Cache('E2_XMULTA','X3_PICTURE')
	@ 83, 5  SAY   GetSx3Cache('E2_XVLROUT' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp17
	@ 80, 40 MSGET oXVLROUT VAR aPagParc[ nXVLROUT ]		SIZE GetSx3Cache('E2_XVLROUT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp17 VALID .T. WHEN lEditar PICTURE GetSx3Cache('E2_XVLROUT','X3_PICTURE')

	//Grp19
	@ 8, 5  SAY   GetSx3Cache('E2_CODBAR' ,'X3_TITULO')		SIZE  35,10 PIXEL OF oGrp19
	@ 5, 40 MSGET oCODBAR VAR aPagParc[ nCODBAR ]			SIZE GetSx3Cache('E2_CODBAR' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp19 VALID u_CBtoLD(aPagParc[nCODBAR]) WHEN lEditar
	@ 23, 5  SAY   GetSx3Cache('E2_LINDIG' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp19
	@ 20, 40 MSGET oLINDIG VAR aPagParc[ nLINDIG ]			SIZE GetSx3Cache('E2_LINDIG' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp19 VALID u_LDtoCB(aPagParc[nLINDIG]) WHEN lEditar PICTURE '@R 99999.99999 99999.999999 99999.999999 9 999999999999999'
	
	//Grp30
	@ 8, 5  SAY   GetSx3Cache('E2_CODBAR' ,'X3_TITULO')		SIZE  35,10 PIXEL OF oGrp30
	@ 5, 40 MSGET oCODBAR VAR aPagParc[ nCODBAR ]			SIZE GetSx3Cache('E2_CODBAR' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp30 VALID  u_CBtoLD(aPagParc[nCODBAR]) WHEN lEditar
	@ 23, 5  SAY   GetSx3Cache('E2_LINDIG' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp30
	@ 20, 40 MSGET oLINDIG VAR aPagParc[ nLINDIG ]			SIZE GetSx3Cache('E2_LINDIG' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp30 VALID  u_LDtoCB(aPagParc[nLINDIG]) WHEN lEditar PICTURE '@R 99999.99999 99999.999999 99999.999999 9 99999999999999' PICTURE '@R 99999.99999 99999.999999 99999.999999 9 99999999999999'
	
	//@ 38, 5  SAY   GetSx3Cache('E2_XIDENT' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp30
	//@ 35, 40 MSGET oXIDENT VAR aPagParc[ nXIDENT ]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp30 VALID .T. WHEN lEditar
	//@ 53, 5  SAY   GetSx3Cache('E2_XDESC' ,'X3_TITULO')		SIZE  35,10 PIXEL OF oGrp30
	//@ 50, 40 MSGET oXDESC VAR aPagParc[ nXDESC ]			SIZE GetSx3Cache('E2_XDESC' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp30 VALID .T. WHEN lEditar  PICTURE GetSx3Cache('E2_XJUROS','X3_PICTURE')
	//@ 68, 5  SAY   GetSx3Cache('E2_XSACADO' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp30
	//@ 65, 40 MSGET aPagParc[ nXSACADO ]			SIZE GetSx3Cache('E2_XSACADO' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp30 VALID .T. WHEN lEditar

	//Grp31
	@  8, 5  SAY   GetSx3Cache('E2_CODBAR' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp31
	@  5, 40 MSGET oCODBAR VAR aPagParc[ nCODBAR ]			SIZE GetSx3Cache('E2_CODBAR' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp31 VALID  u_CBtoLD(aPagParc[nCODBAR]) WHEN lEditar
	@ 23, 5  SAY   GetSx3Cache('E2_LINDIG' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp31
	@ 20, 40 MSGET oLINDIG VAR aPagParc[ nLINDIG ]			SIZE GetSx3Cache('E2_LINDIG' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp31 VALID  u_LDtoCB(aPagParc[nLINDIG]) WHEN lEditar PICTURE '@R 99999.99999 99999.999999 99999.999999 9 99999999999999' PICTURE '@R 99999.99999 99999.999999 99999.999999 9 999999999999999'
	//@ 38, 5  SAY   GetSx3Cache('E2_XIDENT' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp31
	//@ 35, 40 MSGET oXIDENT VAR aPagParc[ nXIDENT ]			SIZE GetSx3Cache('E2_XIDENT' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp31 VALID CGC(aPagParc[nXIDENT]) WHEN lEditar
	//@ 53, 5  SAY   GetSx3Cache('E2_XDESC' ,'X3_TITULO')		SIZE  35,10 PIXEL OF oGrp31
	//@ 50, 40 MSGET oXDESC VAR aPagParc[ nXDESC ]			SIZE GetSx3Cache('E2_XDESC' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp31 VALID .T. WHEN lEditar  PICTURE GetSx3Cache('E2_XJUROS','X3_PICTURE')
	//@ 68, 5  SAY   GetSx3Cache('E2_XSACADO' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp31
	//@ 65, 40 MSGET aPagParc[ nXSACADO ]			SIZE GetSx3Cache('E2_XSACADO' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp31 VALID .T. WHEN lEditar

	//Grp35
	@  8, 5  SAY    GetSx3Cache('E2_CODBAR' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp35
	@  5, 40 MSGET  oCODBAR VAR aPagParc[ nCODBAR ]			SIZE GetSx3Cache('E2_CODBAR' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp35 VALID u_CBtoLD(aPagParc[nCODBAR]) WHEN lEditar
	@ 23, 5  SAY   GetSx3Cache('E2_LINDIG' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp35
	@ 20, 40 MSGET oLINDIG VAR aPagParc[ nLINDIG ]			SIZE GetSx3Cache('E2_LINDIG' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp35 VALID u_LDtoCB(aPagParc[nLINDIG]) WHEN lEditar PICTURE '@R 999999999999 999999999999 999999999999 999999999999'
	@ 38, 5  SAY   GetSx3Cache('E2_XCFGTS' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp35
	@ 35, 40 MSGET oXCFGTS VAR aPagParc[ nXCFGTS ]			SIZE GetSx3Cache('E2_XCFGTS' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp35 VALID .T. WHEN lEditar
	@ 53, 5  SAY   GetSx3Cache('E2_XIDFGTS' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp35
	@ 50, 40 MSGET oXIDFGTS VAR aPagParc[ nXIDFGTS ]		SIZE GetSx3Cache('E2_XIDFGTS' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp35 VALID .T. WHEN lEditar
	@ 68, 5  SAY   GetSx3Cache('E2_XDLFGTS' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp35
	@ 65, 40 MSGET oXDLFGTS VAR aPagParc[ nXDLFGTS ]		SIZE GetSx3Cache('E2_XDLFGTS' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp35 VALID .T. WHEN lEditar
	@ 83, 5  SAY   GetSx3Cache('E2_XLCFGTS' ,'X3_TITULO')	SIZE  35,10 PIXEL OF oGrp35
	@ 80, 40 MSGET oXLCFGTS VAR aPagParc[ nXLCFGTS ]		SIZE GetSx3Cache('E2_XLCFGTS' ,'X3_TAMANHO')*4,10 PIXEL OF oGrp35 VALID .T. WHEN lEditar

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

	ACTIVATE DIALOG oDialogo CENTERED ON INIT (u_TrocaP(aPagParc[ nMODELO ]),EnchoiceBar(oDialogo,{||(nOpc := 1,oDialogo:End())},{||(nOpc := 0,oDialogo:End())},.F.,{},,,.F.,.F.,.F.,.T.,.F.,'ECOM005'))
	
	If nOpc == 1
		lRet := .T.
		oMODELO  := Nil
		oDescTipo:= Nil
		oDATAAGE := Nil
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
		oXDESC   := Nil
		oXSACADO := Nil
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
		oGrp11 := Nil
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
		
		If lFinExec
			RecLock('SE2',.F.)
			For nX := 1 to len(aCpHPag)
				If Alltrim(aPagParc[nMODELO])<>"PD"
					&("SE2->"+aCpHPag[nX]) := aPagParc[nX]
				Else
					If Alltrim(aCpHPag[nX])<>'E2_VENCTO'
						If Alltrim(aCpHPag[nX])<>'E2_VENCREA' 
							&("SE2->"+aCpHPag[nX]) := aPagParc[nX]
						Endif	
					Endif	
				Endif	
			Next nX
			SE2->(MsUnlock())
		Else
			aAreaSE2 := SE2->(GetArea())
			SE2->(DbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
			If SE2->(DbSeek(xFilial("SE2")+SF1->(F1_FORNECE+F1_LOJA+F1_PREFIXO+F1_DUPL)))
				While SF1->(F1_FORNECE+F1_LOJA+F1_SERIE+F1_DOC)==SE2->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM)
					RecLock('SE2',.F.)
					For nX := 1 to len(aCpHPag)
						If Alltrim(aPagParc[nMODELO])<>"PD"
							&("SE2->"+aCpHPag[nX]) := aPagParc[nX]
						Else
							If Alltrim(aCpHPag[nX])<>'E2_VENCTO'
							    If Alltrim(aCpHPag[nX])<>'E2_VENCREA' 
									&("SE2->"+aCpHPag[nX]) := aPagParc[nX]
								Endif	
							Endif	
						Endif	
					Next nX
					SE2->(MsUnlock())
					SE2->(dbSkip())
				End	
			Endif		
			RestArea(aAreaSE2)
		Endif	
	Else
		lRet := .F.
		oDialogo 	:= Nil
		oTitulos	:= Nil
	Endif

	cCadastro := cBkCad

return lRet

Static Function AtuCpo()

	If nLinAnt <> oTitulos:nAt
		aPagParc 	:= oTitulos:aArray[oTitulos:nAt,Len(aCpHead)+2]
		nLinAnt 	:= oTitulos:nAt
		cDescForma	:= AllTrim(GetAdvFVal("SX5","X5_DESCRI",xFilial("SX5")+PADR(GetSx3Cache('EA_MODELO','X3_F3') ,TamSX3('EA_MODELO')[1]) +aPagParc[ nMODELO ],1))
		oDescForma:Refresh()
		oMODELO :Refresh()
		oDATAAGE:Refresh()
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
		oXIDENTF:Refresh()
		oXIDENTJ:Refresh()
		oXJUROS :Refresh()
		oXMULTA :Refresh()
		oCODINS :Refresh()
		oXVLROUT:Refresh()
		oXDESC  :Refresh()
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



