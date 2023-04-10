#INCLUDE "totvs.ch"
#INCLUDE 'Protheus.ch'
#INCLUDE 'Topconn.ch'

#DEFINE CRLF CHR(13) + CHR(10)

/*/ 
+-----------------------------------------------------------------------------+
| Programa  | ECOM024    | Autor | DFS Sistemas           | Data | 18/07/2018 |
+-----------+-----------------------------------------------------------------+
| Descrição | Rotina para Importação de Nota Fiscal de Entrada através de     |
|           | planilha eletrônica (Excel).                                    |
+-----------+-----------------------------------------------------------------+
| Uso       | Específico AllCare                                              |
+-----------------------------------------------------------------------------+
/*/

User Function ECOM024()

	Local _cAliasTMP := "SZZ"
	Local _aCores 	:= {}

	Private cCadastro := "Importação de Nota Fiscal de Entrada"
	Private aRotina   := {}

	aAdd(aRotina,{"Pesquisar"      ,"AxPesqui",0,1})
	aAdd(aRotina,{"Visualizar"     ,"AxVisual",0,2})
	aAdd(aRotina,{"Importar"       ,"U_ECOM024I",0,3})
	aAdd(aRotina,{"Exportar Layout","U_ECOM024E",0,3})
	aAdd(aRotina,{"Estornar Lote"  ,"U_ECOM024D",0,5})
	aAdd(aRotina,{"Consultar LOG"  ,"U_ECOM024X",0,2})
	aAdd(aRotina,{"Legenda"        ,"U_ECOM024L",0,2})

	aAdd(_aCores,{"ZZ_STATUS == '1'","BR_VERDE"})
	aAdd(_aCores,{"ZZ_STATUS == '2'","BR_VERMELHO"})
	aAdd(_aCores,{"ZZ_STATUS == '3'","BR_AMARELO"})
	aAdd(_aCores,{"ZZ_STATUS == '4'","BR_PRETO"})
	aAdd(_aCores,{"ZZ_STATUS == '5'","BR_BRANCO"})

	dbSelectArea(_cAliasTMP)
	(_cAliasTMP)->(dbSetOrder(1))

	MBrowse(6,1,22,75,_cAliasTMP,,,,,6,_aCores)

Return Nil



/*/
	+-----------------------------------------------------------------------------+
	| Função    | ECOM024E   | Autor | DFS Sistemas           | Data | 18/07/2018 |
	+-----------+-----------------------------------------------------------------+
	| Descrição | Rotina para Exportar o Layout no formato Excel.                 |
	+-----------+-----------------------------------------------------------------+
	| Uso       | Específico ECOM024                                              |
	+-----------------------------------------------------------------------------+
/*/

User Function ECOM024E()

	Local _aArea     := GetArea()
	Local _cAliasAnt := Alias()

	Local _cTmpPath	:= GetTempPath(.T.)
	Local _cPathArq := Space(240)
	Local _cNomeArq  := Space(240)

	_aParam := {}
	_aPergs := {}

	aAdd(_aPergs,{6,"Selecione o Diretório",_cPathArq,"","","",80,.T.,"",_cTmpPath,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY})
	aAdd(_aPergs,{1,"Nome do Arquivo",_cNomeArq,"@!",'.T.',"",'.T.',80,.F.})

	If ParamBox(_aPergs,"Parâmetros",@_aParam)

		_cPathArq := Alltrim(_aParam[1])
		_cNomeArq := Alltrim(_aParam[2])

		_nArquivo := FCreate(_cPathArq + _cNomeArq + ".csv")

		If (_nArquivo == -1)

			MsgAlert("ERRO AO CRIAR O ARQUIVO - ERRO: " + STR(FError()))

		Else

			_cLinha := "Tipo de Nota;"           //01
			_cLinha += "Formulário Próprio;"     //02
			_cLinha += "Número da Nota;"         //03
			_cLinha += "Série da Nota;"          //04
			_cLinha += "Data de Emissão;"        //05
			_cLinha += "Competência;"            //06
			_cLinha += "Data de Vencimento;"     //07
			_cLinha += "CNPJ Fornecedor;"        //08
			_cLinha += "Natureza;"               //09
			_cLinha += "Chave da NF-e;"          //10
			_cLinha += "Forma Pagto.;"           //11
			_cLinha += "Código Barras Boleto;"   //12
			_cLinha += "Linha Digitável;"        //13
			_cLinha += "Banco;"                  //14
			_cLinha += "Agência;"                //15
			_cLinha += "Conta;"                  //16
			_cLinha += "Dígito Conta;"           //17
			_cLinha += "Item;"                   //18
			_cLinha += "Produto;"                //19
			_cLinha += "Quantidade;"             //20
			_cLinha += "Valor Unitário;"         //21
			_cLinha += "Tipo Entrada;"           //22
			_cLinha += "Centro de Custo;"        //23
			_cLinha += "Item Conta;"             //24
			_cLinha += "Classe Valor;"           //25
			_cLinha += "Histórico;"              //26
			_cLinha += "Aliq ISS;"               //27
			_cLinha += "Aliq INSS;"              //28
			_cLinha += "Condição Pagamento;"     //29
			_cLinha += "Base IRRF;"				 //30
			_cLinha += "Base Pis;"               //31
			_cLinha += "Base Cofins;"            //32
			_cLinha += "Base Csl;"               //33

			FWrite(_nArquivo,_cLinha + CRLF)
			FClose(_nArquivo)

			MsgInfo("Layout Exportado com Sucesso!!!")

		EndIf

	Else

		MsgAlert("Operação Cancelada!")

	EndIf

	RestArea(_aArea)
	If Empty(Alias())
		dbSelectArea(_cAliasAnt)
	EndIf

Return



/*/
	+-----------------------------------------------------------------------------+
	| Função    | ECOM024I   | Autor | DFS Sistemas           | Data | 18/07/2018 |
	+-----------+-----------------------------------------------------------------+
	| Descrição | Rotina para Importar a Planilha e gerar as Notas Fiscais de     |
	|           | Entrada.                                                        |
	+-----------+-----------------------------------------------------------------+
	| Uso       | Específico ECOM024                                              |
	+-----------------------------------------------------------------------------+
/*/


User Function ECOM024I()
	
	Processa({|| ProcImp() })

Return

/*/{Protheus.doc}''
'' 
@author 
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
Static Function ProcImp()

	Local _aArea     := GetArea()
	Local _cAliasAnt := Alias()

	Local _nCnt      := 0
	Local _nCnt1     := 0
	Local _cCamRet   := "C:\"
	Local _lFirst    := .T.
	Local _aItens    := {}
	Local _cLog      := ""
	Local _cNumImp   := ""
	Local _lContinua := .T.
	Local _lOk       := .T.
	Local _lImport   := .T.
	Local _lGeraNF   := .T.
	Local _nItem     := 0
	Local _cEspecie  := SuperGetMV("MV_XESPNFE",.F.,"NFS")
	Local _aRubricas := {}

	Private _aTotRub := {}

	_cDirArq := Alltrim(cGetFile("Arquivos (*.csv) |*.CSV|",'Abrir (.CSV)', 0,_cCamRet,.T.,GETF_LOCALHARD,.T.))

	FT_FUSE(_cDirArq)
	FT_FGOTOP()

	ProcRegua(FT_FLASTREC())

	FT_FGOTOP()

	While !FT_FEOF()

		_cLinha	:= FT_FREADLN()

		If Empty(_cLinha)

			Exit

		Else

			If _lFirst   //Ignora Cabeçalho da Planilha, porém monta array de Rúbricas
				_lFirst := .F.
				_aCabPlan := Mont_Array(_cLinha,";")
				For _nCnt := 34 to Len(_aCabPlan)
					_cCodRubr := Alltrim(_aCabPlan[_nCnt])
					_cNatRubr := ""
					_cDesRubr := ""
					_cTotRubr := ""
					_cChvSZ0  := xFilial("SZ0") + Padr( _cCodRubr , TamSx3("Z0_RUBRICA")[1] )
					dbSelectArea("SZ0")
					SZ0->(dbSetOrder(1))
					SZ0->(dbGoTop())
					If !SZ0->(dbSeek(_cChvSZ0))
						Aviso("Aviso","Rúbrica " + _cCodRubr + " não Cadastrada!")
						_lContinua := .F.
					Else
						If SZ0->Z0_MSBLQL == "1"
							Aviso("Aviso","Rúbrica " + _cCodRubr + " Bloqueada!")
							_lContinua := .F.
						Else
							_cNatRubr := SZ0->Z0_NATRUBR
							_cDesRubr := SZ0->Z0_DESCRI
							_cTotRubr := SZ0->Z0_TOTALIZ
						EndIf
					EndIf
					aAdd(_aRubricas,{_cCodRubr,_cDesRubr,_cNatRubr,_cTotRubr})
				Next _nCnt
				FT_FSKIP()
				Loop
			EndIf

		EndIf

		If !_lContinua

			Exit

		Else

			_aNotas := Mont_Array(_cLinha,";")
			IncProc("Lendo Arquivo! Documento: " + Alltrim(_aNotas[3]) + " / " + Alltrim(_aNotas[4]) + " - Item: " + Alltrim(_aNotas[16]) + "...")
			ProcessMessage()

			If Len(_aNotas) > 0
				aAdd(_aItens,_aNotas)
			EndIf

		EndIf

		_nCnt++
		FT_FSKIP()

	EndDo

	FT_FUSE()

	ProcRegua(Len(_aItens))
	ProcessMessage()

	If Len(_aItens) > 0
		_cNumImp := GetSXENum("SZZ","ZZ_CODIGO")
	Else
		_lOk := .F.
	EndIf

	For _nItem := 1 To Len(_aItens)

		_cNota  := StrZero(Val(Alltrim(_aItens[_nItem][3])),9)
		_cSerie := PadR(Alltrim(_aItens[_nItem][4]),3)
		_cItem  := StrZero(Val(Alltrim(_aItens[_nItem][18])),4)

		IncProc("Validando dados... Importação " + _cNumImp + ", Documento: " + _cNota + " / " + Alltrim(_cSerie) + " - Item: " + _cItem + "...")
		ProcessMessage()

		//Validação das Informações da PlaNilha

		_lOk := .T.
		_cLog := ""

		_cTipoNF := Alltrim(_aItens[_nItem][1])
		If Upper(_cTipoNF) <> "NORMAL"   //Tipo da Nota
			_cLog += "Tipo da Nota diferente de [Normal]." + CRLF
			_lOk := .F.
		EndIf

		_cFormul := Alltrim(_aItens[_nItem][2])
		If !Upper(_cFormul) $ "NÃO/NAO"   //Formulário Próprio
			_cLog += "Formulário Próprio não aceito." + CRLF
			_lOk := .F.
		EndIf

		_cForn  := ""
		_cLoja  := ""
		_cUF    := ""
		_cCond  := Alltrim(_aItens[_nItem][29])
		_cBanco := ""
		_cAgenc := ""
		_cConta := ""
		_cDVCta := ""
		_xBanco := ""
		_xAgenc := ""
		_xConta := ""
		_xDVCta := ""
		_cContra:= ""

		_cCNPJ := Alltrim(_aItens[_nItem][8])
		_cCNPJ := StrTran(_cCNPJ,".","")
		_cCNPJ := StrTran(_cCNPJ,"/","")
		_cCNPJ := StrTran(_cCNPJ,"-","")

		_cChvSA2 := xFilial("SA2") + _cCNPJ
		dbSelectArea("SA2")
		SA2->(dbSetOrder(3))
		SA2->(dbGoTop())
		If !SA2->(dbSeek(_cChvSA2))
			_cLog += "Fornecedor não encontrado." + CRLF
			_lOk := .F.
		Else
			_cForn  := SA2->A2_COD
			_cLoja  := SA2->A2_LOJA
			_cUF    := SA2->A2_EST
			_xBanco := SA2->A2_BANCO
			_xAgenc := SA2->A2_AGENCIA
			_xConta := SA2->A2_NUMCON
			_xDVCta := SA2->A2_DVCTA
		EndIf

		If Empty(_cCond)
			_cCond  := Iif(Empty(SA2->A2_COND),GetMV("MV_XA2COND"),SA2->A2_COND)
			If Empty(_cCond)
				_cLog += "Condição de Pagamento não informada no Fornecedor." + CRLF
				_lOk := .F.
			Endif
		Endif

		_cChvSE4 := xFilial("SE4") + _cCond
		dbSelectArea("SE4")
		SE4->(dbSetOrder(1))
		SE4->(dbGoTop())
		If !SE4->(dbSeek(_cChvSE4))
			_cLog += "Condição de Pagamento "+_cCond+" informada não foi localizada no cadastro." + CRLF
			_lOk := .F.
		EndIf

		If !Empty(_cForn)
			_cChvSF1 := xFilial("SF1") + _cNota + _cSerie + _cForn + _cLoja
			dbSelectArea("SF1")
			SF1->(dbSetOrder(1))
			SF1->(dbGoTop())
			If SF1->(dbSeek(_cChvSF1))
				_cLog += "Nota Fiscal deste Fornecedor já importada anteriormente." + CRLF
				_lOk := .F.
			EndIf
		EndIf

		_dEmiss := CtoD(_aItens[_nItem][5])
		If Empty(_dEmiss)
			_cLog += "Data de Emissão não preenchida." + CRLF
			_lOk := .F.
		Else
			If _dEmiss > dDataBase
				_cLog += "Data de Emissão maior que DataBase." + CRLF
				_lOk := .F.
			EndIf
		EndIf

		_dCompet := CtoD(_aItens[_nItem][6])
		If Empty(_dCompet)
			_cLog += "Data de Competência não preenchida." + CRLF
			_lOk := .F.
		EndIf

		_dVencto := CtoD(_aItens[_nItem][7])
		If Empty(_dVencto)
			If Empty(_cCond)
				_cLog += "Data de Vencimento e condição de pagamento não preenchida, preencha uma para prosseguir." + CRLF
				_lOk := .F.
			Endif
		EndIf

		_cNaturez := Alltrim(_aItens[_nItem][9])
		_cChvSED  := xFilial("SED") + _cNaturez
		dbSelectArea("SED")
		SED->(dbSetOrder(1))
		SED->(dbGoTop())
		If !SED->(dbSeek(_cChvSED))
			_cLog += "Natureza não Cadastrada." + CRLF
			_lOk := .F.
		EndIf

		_cChaveNF := Alltrim(_aItens[_nItem][10])
		If Empty(_cChaveNF)
			_cLog += "Chave da NF-e não informada." + CRLF
			//_lOk := .F.
		EndIf

		_cForPag := Alltrim(_aItens[_nItem][11])   //Forma de Pagamento
		_cCodBar := Alltrim(_aItens[_nItem][12])
		_cLinDig := Alltrim(_aItens[_nItem][13])
		_cBanco := Alltrim(_aItens[_nItem][14])
		_cAgenc := Alltrim(_aItens[_nItem][15])
		_cConta := Alltrim(_aItens[_nItem][16])
		_cDVCta := Alltrim(_aItens[_nItem][17])

		If Upper(_cForPag) <> "AGLUTINADO"   //Quando preenchido com AGLUTINADO não validar Código de Barras, Linha Digitável ou Dados Bancários
			If _cForPag $ "30/31" //"BOLETO"
				If Empty(_cCodBar) .And. Empty(_cLinDig)
					_cLog += "Título Tipo Boleto e não informado o Código de Barras ou a Linha Digitável." + CRLF
					_lOk := .F.
				EndIf
			EndIf
		EndIf

		If Empty(_cItem)
			_cLog += "Número do Item não Informado." + CRLF
			_lOk := .F.
		EndIf

		_cProduto := Alltrim(_aItens[_nItem][19])
		_cUM      := ""
		_cChvSB1  := xFilial("SB1") + _cProduto
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		SB1->(dbGoTop())
		If !SB1->(dbSeek(_cChvSB1))
			_cLog += "Produto não Cadastrado." + CRLF
			_lOk := .F.
		Else
			_cUM := SB1->B1_UM
		EndIf

		If Empty(_cUM)
			_cLog += "Unidade de Medida não Informada no Produto." + CRLF
			_lOk := .F.
		EndIf

		_cTES    := StrZero(Val(Alltrim(_aItens[_nItem][22])),3)
		_nQuant  := Val(_aItens[_nItem][20])
		_cChvSF4 := xFilial("SF4") + _cTES
		dbSelectArea("SF4")
		SF4->(dbSetOrder(1))
		SF4->(dbGoTop())
		If !SF4->(dbSeek(_cChvSF4))
			_cLog += "Tipo de Entrada (TES) não Cadastrado." + CRLF
			_lOk := .F.
		Else
			If SF4->F4_QTDZERO == "2" .And. _nQuant == 0
				_cLog += "Tipo de Entrada (TES) não aceita quantidade 0 (zero)." + CRLF
				_lOk := .F.
			EndIf
		EndIf

		If _nQuant <> 1
			_cLog += "Para Nota Fiscal de Serviço a Quantidade deve ser 1 (um)." + CRLF
			_lOk := .F.
		EndIf

		_cVlUnit := StrTran(Alltrim(_aItens[_nItem][21]),",",".")
		_nVlUnit := Val(_cVlUnit)
		If _nVlUnit == 0
			_cLog += "Valor Unitário não Informado." + CRLF
			_lOk := .F.
		EndIf

		_nVlTotal := _nVlUnit

		_cCCusto := ""
		_cItemCt := ""
		_cClasse := ""

		_cCCusto := Alltrim(_aItens[_nItem][23])
		_cChvCTT := xFilial("CTT") + _cCCusto
		dbSelectArea("CTT")
		CTT->(dbSetOrder(1))   //CTT_FILIAL, CTT_CUSTO
		CTT->(dbGoTop())
		If !CTT->(dbSeek(_cChvCTT))
			_cLog += "Centro de Custo não Cadastrado." + CRLF
			_lOk := .F.
		EndIf

		_cItemCt := Alltrim(_aItens[_nItem][24])
		_cChvCTD := xFilial("CTD") + _cItemCt
		dbSelectArea("CTD")
		CTD->(dbSetOrder(1))   //CTD_FILIAL, CTD_ITEM
		CTD->(dbGoTop())
		If !CTD->(dbSeek(_cChvCTD))
			_cLog += "Item Contábil não Cadastrado." + CRLF
			_lOk := .F.
		EndIf

		_cClasse := Alltrim(_aItens[_nItem][25])
		_cChvCTH := xFilial("CTH") + _cClasse
		dbSelectArea("CTH")
		CTH->(dbSetOrder(1))   //CTH_FILIAL, CTH_CLVL
		CTH->(dbGoTop())
		If !CTH->(dbSeek(_cChvCTH))
			_cLog += "Classe Valor não Cadastrada." + CRLF
			_lOk := .F.
		EndIf

		_cHist   := Substr(Alltrim(_aItens[_nItem][26]),1,tamsx3("E2_HIST")[1])
		_cContra := Substr(Alltrim(_aItens[_nItem][26]),1,At("_",Alltrim(_aItens[_nItem][26]))-1)
		_nAlISS  := Val(_aItens[_nItem][27])
		_nAlINSS := Val(_aItens[_nItem][28])


		nBaseIRR := Val(StrTran(StrTran(_aItens[_nItem][30],".",""),",","."))
		nBasePis := Val(StrTran(StrTran(_aItens[_nItem][31],".",""),",","."))
		nBaseCof := Val(StrTran(StrTran(_aItens[_nItem][32],".",""),",","."))
		nBaseCsl := Val(StrTran(StrTran(_aItens[_nItem][33],".",""),",","."))

		//Valida Rúbricas x Total do Item
		_nIteRubr := 0
		_nTotRubr := 0
		For _nCnt1 := 34 to Len(_aItens[_nItem])

			_cVlRubr := StrTran(Alltrim(_aItens[_nItem][_nCnt1]),",",".")
			_nVlRubr := Val(_cVlRubr)
			If _nVlRubr > 0
				_nIteRubr++
				_nPosRub := aScan(_aTotRub,{|x| x[1] == _cNota .And. x[2] == _cSerie .And. x[3] == _cForn .And. x[4] == _cLoja .And. x[5] == StrZero(_nIteRubr,4) .And. x[6] == _aRubricas[_nCnt1 - 33][1]})
				If _nPosRub > 0
					_aTotRub[_nPosRub][8] := _aTotRub[_nPosRub][8] + _nVlRubr
				Else
					aAdd(_aTotRub,{_cNota,_cSerie,_cForn,_cLoja,StrZero(_nIteRubr,4),_aRubricas[_nCnt1 - 33][1],_aRubricas[_nCnt1 - 33][2],_nVlRubr})
				EndIf
				If _aRubricas[_nCnt1 - 33][4] == "1"
					If _aRubricas[_nCnt1 - 33][3] == "A"
						_nTotRubr += _nVlRubr
					ElseIf _aRubricas[_nCnt1 - 33][3] == "D"
						_nTotRubr -= _nVlRubr
					EndIf
				EndIf
			EndIf
		Next _nCnt1

		//If _nTotRubr <> 0
			If _nTotRubr <> _nVlUnit
				_cLog += 	"Total de Rúbricas não bate com Valor Total do Item - Total do Item: " + Alltrim(Transform(_nVlUnit,"@E 999,999,999.99")) + ;
					" - Rúbricas: " + Alltrim(Transform(_nTotRubr,"@E 999,999,999.99")) + "." + CRLF
				_lOk := .F.
			EndIf
		//EndIf

		If !_lOk
			_lImport := .F.
		EndIf

	/* Grava dados na tabela de LOG */
		dbSelectArea("SZZ")
		SZZ->(dbSetOrder(1))

		SZZ->(RecLock("SZZ",.T.))
		SZZ->ZZ_FILIAL  := xFilial("SZZ")
		SZZ->ZZ_CODIGO  := _cNumImp
		SZZ->ZZ_DATA    := dDataBase
		SZZ->ZZ_STATUS  := Iif(_lOk,"3","2")
		SZZ->ZZ_ARQUIVO := _cDirArq
		SZZ->ZZ_LOG 	:= _cLog
		SZZ->ZZ_TIPONF  := _cTipoNF
		SZZ->ZZ_FORMUL  := _cFormul
		SZZ->ZZ_DOC     := _cNota
		SZZ->ZZ_SERIE   := _cSerie
		SZZ->ZZ_EMISSAO := _dEmiss
		SZZ->ZZ_COMPET  := _dCompet
		SZZ->ZZ_VENCTO  := _dVencto
		SZZ->ZZ_EMISSAO := _dEmiss
		SZZ->ZZ_CNPJ    := _cCNPJ
		SZZ->ZZ_FORNECE := _cForn
		SZZ->ZZ_LOJA    := _cLoja
		SZZ->ZZ_ESPECIE := _cEspecie
		SZZ->ZZ_UF      := _cUF
		SZZ->ZZ_CONDPAG := _cCond
		SZZ->ZZ_NATUREZ := _cNaturez
		SZZ->ZZ_CHVNFE  := _cChaveNF
		SZZ->ZZ_FORPAG  := Iif(Upper(Alltrim(_cForPag)) == "AGLUTINADO","",_cForPag)
		SZZ->ZZ_CODBAR  := _cCodBar
		SZZ->ZZ_LINDIG  := _cLinDig
		SZZ->ZZ_BANCO   := _cBanco
		SZZ->ZZ_AGENCIA := _cAgenc
		SZZ->ZZ_CONTA   := _cConta
		SZZ->ZZ_DVCTA   := _cDVCta
		SZZ->ZZ_ITEM    := _cItem
		SZZ->ZZ_PRODUTO := _cProduto
		SZZ->ZZ_UM      := _cUM
		SZZ->ZZ_QUANT   := _nQuant
		SZZ->ZZ_VUNIT   := _nVlUnit
		SZZ->ZZ_TOTAL   := _nVlTotal
		SZZ->ZZ_TES     := _cTES
		SZZ->ZZ_CC      := _cCCusto
		SZZ->ZZ_ITEMC   := _cItemCt
		SZZ->ZZ_CLVL    := _cClasse
		SZZ->ZZ_HIST    := _cHist
		SZZ->ZZ_ALIQINS := _nAlINSS
		SZZ->ZZ_ALIQISS := _nAlISS
		SZZ->ZZ_AGLUTIN := Iif(Upper(Alltrim(_cForPag)) == "AGLUTINADO","S","N")
		SZZ->ZZ_CONTRAT := _cContra
		SZZ->ZZ_BASEIRR := nBaseIRR
		SZZ->ZZ_BASEPIS := nBasePis
		SZZ->ZZ_BASECOF := nBaseCof
		SZZ->ZZ_BASECSL := nBaseCsl
		SZZ->(MsUnLock())
	Next _nItem

	aAreaSZZ := SZZ->(GetArea())
	
	If Len(_aItens) > 0
		ConfirmSx8()
	EndIf

	If _lImport
		Aviso("Aviso","Importação N° " + _cNumImp + " finalizada com Sucesso!",{"Gerar Notas Fiscais de Entrada"})
	Else
		If Len(_aItens) == 0
			Aviso("Aviso","Planilha sem Dados para Importar!")
		Else
			Aviso("Aviso","Importação N° " + _cNumImp + " finalizada com Inconsistências! Verifique o LOG!")
		EndIf
		_lGeraNF := .F.
	EndIf

	If _lGeraNF
		U_ECOM024G(_cNumImp,Len(_aItens))
	EndIf

	RestArea(aAreaSZZ)

Return




/*/
	+-----------------------------------------------------------------------------+
	| Função    | ECOM024L   | Autor | DFS Sistemas           | Data | 18/07/2018 |
	+-----------+-----------------------------------------------------------------+
	| Descrição | Legenda do Browse.                                              |
	+-----------+-----------------------------------------------------------------+
	| Uso       | Específico ECOM024                                              |
	+-----------------------------------------------------------------------------+
/*/

User Function ECOM024L()

	Local _aLegenda := {}

	aAdd(_aLegenda,{"BR_VERDE"   ,"Nota Fiscal Gerada"})
	aAdd(_aLegenda,{"BR_VERMELHO","Inconsistência"})
	aAdd(_aLegenda,{"BR_AMARELO" ,"Planilha Importada"})
	aAdd(_aLegenda,{"BR_PRETO" 	 ,"Lote Estornado"})
	aAdd(_aLegenda,{"BR_BRANCO"	 ,"Erro para estonar"})

	BrwLegenda(cCadastro,"Legenda",_aLegenda)

Return Nil



/*/
	+-----------------------------------------------------------------------------+
	| Função    | ECOM024G   | Autor | DFS Sistemas           | Data | 18/07/2018 |
	+-----------+-----------------------------------------------------------------+
	| Descrição | Rotina para Geração das Notas Fiscais de Entrada.               |
	+-----------+-----------------------------------------------------------------+
	| Uso       | Específico ECOM024                                              |
	+-----------------------------------------------------------------------------+
/*/


User Function ECOM024G(_cNumImp,_nTRegs)

	Local _aArea     := GetArea()
	Local _cAliasAnt := Alias()

	Processa({|| _xGeraNF(_cNumImp,_nTRegs)})

	Restarea(_aArea)
	If Empty(Alias())
		dbSelectArea(_cAliasAnt)
	EndIf

Return



Static Function _xGeraNF(_cNumImp,_nTRegs)

	Local _aArea     := GetArea()
	Local  nY		:= 1
	Local _cAliasAnt := Alias()
	Local _cValInc   := ""
	Local _cAgluti	 := ""
	Local _lErro     := .F.
	Local _lGerou    := .F.
	Local _nRegs     := 0
	Local _nCnt      := 0
	Local _aCampos   := {}

	Public aColsSZ1  := {}
	Public aHeadSZ1  := {}

// Monta os arrays aHeaderSZ1 e aColsSZ1 utilizados no Ponto de Entrada MT100GE2
	aAdd(_aCampos,'Z1_ITEM')
	aAdd(_aCampos,'Z1_RUBRICA')
	aAdd(_aCampos,'Z1_DESCRI')
	aAdd(_aCampos,'Z1_TOTAL')

	dbSelectArea('SX3')
	SX3->(dbSetOrder(2))
	SX3->(dbGoTop())
	For _nCnt := 1 To Len(_aCampos)
		If SX3->(dbSeek(_aCampos[_nCnt]))
			aAdd(aHeadSZ1,{AllTrim(SX3->X3_TITULO),Alltrim(SX3->X3_CAMPO),SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CBOX})
		EndIf
	Next _nCnt

	ProcRegua(_nRegs)
	ProcessMessage()

	_cChvSZZ := xFilial("SZZ") + _cNumImp
	dbSelectArea("SZZ")
	SZZ->(dbSetorder(1))
	SZZ->(dbGoTop())
	If SZZ->(dbSeek(_cChvSZZ))

		While !SZZ->(Eof()) .And. (SZZ->(ZZ_FILIAL + ZZ_CODIGO) == _cChvSZZ)

			_nRegs++
			IncProc("Gerando Notas... Linha: " + StrZero(_nRegs,4) + " de " + StrZero(_nTRegs,4))
			ProcessMessage()

			_cChvSZZ := xFilial("SZZ") + SZZ->ZZ_CODIGO
			_cChvNF  := SZZ->(ZZ_DOC + ZZ_SERIE + ZZ_FORNECE + ZZ_LOJA)
			_cChvSF1 := xFilial("SF1") + SZZ->(ZZ_DOC + ZZ_SERIE + ZZ_FORNECE + ZZ_LOJA)
			dbSelectArea("SF1")
			SF1->(dbSetOrder(1))
			SF1->(dbGoTop())
			If SF1->(dbSeek(_cChvSF1))

				dbSelectArea("SZZ")
				SZZ->(dbGoTop())
				If SZZ->(dbSeek(_cChvSZZ + _cChvNF))
					While !SZZ->(Eof()) .And. (SZZ->(ZZ_FILIAL + ZZ_CODIGO) == _cChvSZZ) .And. (SZZ->(ZZ_DOC + ZZ_SERIE + ZZ_FORNECE + ZZ_LOJA) == _cChvNF)
						RecLock("SZZ",.F.)
						SZZ->ZZ_STATUS := "2"
						SZZ->ZZ_LOGAUT := "Nota Fiscal deste Fornecedor já importada anteriormente."
						SZZ->(MsUnLock())
						SZZ->(dbSkip())
						_nRegs++
						IncProc("Gerando Notas... Linha: " + StrZero(_nRegs,4) + " de " + StrZero(_nTRegs,4))
						ProcessMessage()
					EndDo
				EndIf

			Else

				_cTipoNF  := "N"
				_cFormul  := "N"
				_cNota    := SZZ->ZZ_DOC
				_cSerie   := SZZ->ZZ_SERIE
				_dEmiss   := SZZ->ZZ_EMISSAO
				_dCompet  := SZZ->ZZ_COMPET
				_dVencto  := SZZ->ZZ_VENCTO
				_cForn    := SZZ->ZZ_FORNECE
				_cLoja    := SZZ->ZZ_LOJA
				_cEspecie := SZZ->ZZ_ESPECIE
				_cUF      := SZZ->ZZ_UF
				_cCond    := SZZ->ZZ_CONDPAG
				_cNaturez := SZZ->ZZ_NATUREZ
				_cChaveNF := SZZ->ZZ_CHVNFE
				_cForPag  := SZZ->ZZ_FORPAG
				_cCodBar  := SZZ->ZZ_CODBAR
				_cLinDig  := SZZ->ZZ_LINDIG
				_cBanco   := SZZ->ZZ_BANCO
				_cAgenc   := SZZ->ZZ_AGENCIA
				_cConta   := SZZ->ZZ_CONTA
				_cDVCta   := SZZ->ZZ_DVCTA
				_cCCusto  := SZZ->ZZ_CC
				_cItemCt  := SZZ->ZZ_ITEMC
				_cClasse  := SZZ->ZZ_CLVL
				_cHist	  := SZZ->ZZ_HIST
				_nAlINSS  := SZZ->ZZ_ALIQINS
				_nAlISS   := SZZ->ZZ_ALIQISS
				_cAgluti  := SZZ->ZZ_AGLUTIN
				_cContra  := SZZ->ZZ_CONTRAT
				nBaseIRR  := SZZ->ZZ_BASEIRR
				nBasePis  := SZZ->ZZ_BASEPIS
				nBaseCof  := SZZ->ZZ_BASECOF
				nBaseCsl  := SZZ->ZZ_BASECSL

				_aCabec := {}
				_aItens := {}
				_aImpAlt	:= {}

				nTotBIss := 0
				nTotAIss := 0
				nTotVIss := 0
				nTotBIns := 0
				nTotAIns := 0
				nTotVIns := 0

				_cChvNF := SZZ->(ZZ_DOC + ZZ_SERIE + ZZ_FORNECE + ZZ_LOJA)

				__cErro := ''

				While !SZZ->(Eof()) .And. (SZZ->(ZZ_FILIAL + ZZ_CODIGO) == _cChvSZZ) .And. (SZZ->(ZZ_DOC + ZZ_SERIE + ZZ_FORNECE + ZZ_LOJA) == _cChvNF)


					_aPrdAlt := {}
					If _nAlISS > 0
						DbSelectArea("SB1")
						SB1->(DbGoTop())
						SB1->(DbSetOrder(1))
						If SB1->(DbSeek(xFilial("SB1")+SZZ->ZZ_PRODUTO))
							Aadd(_aPrdAlt,{SB1->B1_COD,SB1->B1_ALIQISS})
							RecLock("SB1",.F.)
							SB1->B1_ALIQISS := _nAlISS
							SB1->(MsUnlock())
						EndIf
					EndIf

					__cErro := ''
					If Empty(SZZ->ZZ_CC) 
						__cErro += 'Centro de Custo não informado, verifique.'
					Endif

					If Empty(SZZ->ZZ_ITEMC)
						__cErro += 'Item Contabil não informado, verifique.'
					Endif

					If Empty(SZZ->ZZ_CLVL)
						__cErro += 'Classe Valor não informado, verifique.'
					Endif

					If !Empty(__cErro)

						dbSelectArea("SZZ")
						RecLock("SZZ",.F.)
						SZZ->ZZ_STATUS := "2"
						SZZ->ZZ_LOG    := __cErro
						SZZ->ZZ_LOGAUT := __cErro
						SZZ->(MsUnLock())
	
						SZZ->(dbSkip())
						Loop
					Endif

					
					_aItAux := {	{"D1_ITEM"  	,SZZ->ZZ_ITEM					,Nil},;
						{"D1_COD"   	,SZZ->ZZ_PRODUTO				,Nil},;
						{"D1_QUANT" 	,SZZ->ZZ_QUANT					,Nil},;
						{"D1_VUNIT" 	,SZZ->ZZ_VUNIT					,Nil},;
						{"D1_TOTAL" 	,SZZ->ZZ_TOTAL					,Nil},;
						{"D1_TES"   	,SZZ->ZZ_TES					,Nil},;
						{"D1_CC"		,SZZ->ZZ_CC						,Nil},;
						{"D1_ITEMCTA"	,SZZ->ZZ_ITEMC					,Nil},;
						{"D1_CLVL"		,SZZ->ZZ_CLVL					,Nil},;
						{"D1_TIPO"		,"N"            				,Nil},;
						{"D1_FORMUL"	,"N"							,Nil},;
						{"D1_BASEISS"	,SZZ->ZZ_VUNIT					,Nil},;
						{"D1_ALIQISS"	,_nAlISS						,Nil},;
						{"D1_VALISS"	,(SZZ->ZZ_VUNIT*_nAlISS)/100	,Nil},;
						{"D1_BASEINS"	,SZZ->ZZ_VUNIT					,Nil},;
						{"D1_ALIQINS"	,_nAlISS						,Nil},;
						{"D1_VALINS"	,(SZZ->ZZ_VUNIT*_nAlISS)/100	,Nil},;
						{"D1_XHISIMP"	,SZZ->ZZ_HIST					,Nil},;
						{"D1_BASEIRR"	,nBaseIRR						,Nil},;
						{"D1_BASEPIS"	,nBasePis						,Nil},;
						{"D1_BASECOF"	,nBaseCof						,Nil},;
						{"D1_BASECSL"	,nBaseCsl						,Nil}}

					aAdd(_aItens,_aItAux)
				  
					Aadd(_aImpAlt,{'IT_BASEIRR' , nBaseIRR , Len(_aItens)}) //MaFisRef("IT_BASEIRR","MT100",M->D1_BASEIRR)                                                                                    
					Aadd(_aImpAlt,{'IT_BASEPIS' , nBasePis , Len(_aItens)}) //MaFisRef("IT_BASEPIS","MT100",M->D1_BASEPIS)
					Aadd(_aImpAlt,{'IT_BASECOF' , nBaseCof , Len(_aItens)}) //MaFisRef("IT_BASECOF","MT100",M->D1_BASECOF)
					Aadd(_aImpAlt,{'IT_BASECSL' , nBaseCsl , Len(_aItens)}) //MaFisRef("IT_BASECSL","MT100",M->D1_BASECSL)
				

					SZZ->(dbSkip())
				EndDo

			/*
			NF_IMPOSTOS
			IMP_DESC //Descricao do imposto no Array NF_IMPOSTOS
			IMP_BASE //Base de Calculo do Imposto no Array NF_IMPOSTOS
			IMP_ALIQ //Aliquota de calculo do imposto
			IMP_VAL //Valor do Imposto no Array NF_IMPOSTOS
			IMP_NOME //Nome de referencia aos Impostos do cabecalho
			*/

			/*		
				If nTotVIss > 0
				Aadd(_aImpAlt,{'NF_BASEISS'		,SZZ->ZZ_VUNIT} )
				Aadd(_aImpAlt,{'NF_VALISS'		,(SZZ->ZZ_VUNIT*_nAlISS)/100})		
				Aadd(_aImpAlt,{'NF_IMPOSTOS'	,{'ISS',nTotBIss,nTotAIss,nTotVIss}})
				EndIf
			
				If nTotVIns > 0
				Aadd(_aImpAlt,{'NF_BASEINS'		,SZZ->ZZ_VUNIT})
				Aadd(_aImpAlt,{'NF_VALINS'		,(SZZ->ZZ_VUNIT*_nAlINSS)/100})
				Aadd(_aImpAlt,{'NF_IMPOSTOS'	,{'INS',nTotBIns,nTotAIns,nTotVIns}})
				EndIf
			*/

				If Len(_aItens) > 0

					_aNatAlt := {}
					If _nAlINSS > 0 //.And. _nAlINSS <> 11
						DbSelectArea("SED")
						SED->(DbGoTop())
						SED->(DbSetOrder(1))
						If SED->(DbSeek(xFilial("SED")+Padr(_cNaturez,10)))
							Aadd(_aNatAlt,{SED->ED_CODIGO,SED->ED_PERCINS})
							RecLock("SED",.F.)
							SED->ED_PERCINS := _nAlINSS
							SB1->(MsUnlock())
						EndIf
					EndIf

					_aCabec := {	{"F1_FILIAL"  	,xFilial("SF1")	,Nil},;
									{"F1_DOC"		,_cNota			,Nil},;
									{"F1_SERIE"		,_cSerie   	 	,Nil},;
									{"F1_FORNECE" 	,_cForn			,Nil},;
									{"F1_LOJA"		,_cLoja		    ,Nil},;
									{"F1_EMISSAO"	,_dEmiss		,Nil},;
									{"F1_UF" 		,_cUF			,Nil},;
									{"F1_TIPO"		,_cTipoNF     	,Nil},;
									{"F1_FORMUL"	,_cFormul		,Nil},;
									{"F1_ESPECIE"	,_cEspecie		,Nil},;
									{"F1_COND"	    ,_cCond			,Nil},;
									{"F1_NATUREZ"	,_cNaturez		,Nil} }
				EndIf

				//Alimenta Array aColsSZ1 utilizado no Ponto de Entrada MT100GE2 para as Rúbricas
				aSize(aColsSZ1,0)
				//_nPosRub := aScan(_aTotRub,{|w,x,y,z| w + x + y + z == _cChvNF})
				_nPosRub := aScan(_aTotRub,{|x| x[1] == _cNota .And. x[2] == _cSerie .And. x[3] == _cForn .And. x[4] == _cLoja})
				If _nPosRub > 0
					aAdd(aColsSZ1,{_aTotRub[_nPosRub][5],_aTotRub[_nPosRub][6],_aTotRub[_nPosRub][7],_aTotRub[_nPosRub][8]})
					While .T.
						_nPosRub++
						If _nPosRub <= Len(_aTotRub)
							If _aTotRub[_nPosRub][1] + _aTotRub[_nPosRub][2] + _aTotRub[_nPosRub][3] + _aTotRub[_nPosRub][4] == _cChvNF
								aAdd(aColsSZ1,{_aTotRub[_nPosRub][5],_aTotRub[_nPosRub][6],_aTotRub[_nPosRub][7],_aTotRub[_nPosRub][8]})
							Else
								Exit
							EndIf
						Else
							Exit
						EndIf
					EndDo
				EndIf

				If Len(_aCabec) <> 0 .And. Len(_aItens) <> 0

					Begin Transaction
					
					//PutMv("MV_ALIQISS",_nALISS)
					_cBuffer   := ""
					_nErrLin   := 1
					_nLinhas   := 0
					_cErroTemp := ""
					_cNomeArq  := "LOG_" + _cNota + _cSerie + _cForn + _cLoja + SUBSTR(TIME(),1,2) + SUBSTR(TIME(),4,2) + SUBSTR(TIME(),7,2) + ".log"

					lMsErroAuto := .F.

					MsExecAuto({|x,y,z,a,b| MATA103(x,y,z,a,b)},_aCabec,_aItens,3,,_aImpAlt)

					If lMsErroAuto

						_lErro     := .T.
						_cErroTemp := MOSTRAERRO(GetSrvProfString("Startpath",""),_cNomeArq)
						_nLinhas   := MLCOUNT(_cErroTemp)
						_cBuffer   := RTRIM(MEMOLINE(_cErroTemp,,_nErrLin))

						While (_nErrLin <= _nLinhas)
							_nErrLin++
							_cBuffer := Alltrim(MEMOLINE(_cErroTemp,,_nErrLin))
							If (UPPER(SUBSTR(_cBuffer, LEN(_cBuffer) - 7, LEN(_cBuffer))) == "INVALIDO")
								_cValInc := Alltrim(_cBuffer)
								Exit
							EndIf
						EndDo

						If Empty(_cValInc)
							_nErrLin := 0
							While (_nErrLin <= 5)
								_nErrLin++
								_cBuffer := Alltrim(MEMOLINE(_cErroTemp,,_nErrLin))
								_cValInc += Alltrim(_cBuffer) + " "
							EndDo
						EndIf

						If File(GetSrvProfString("Startpath","") + _cNomeArq)
							FErase(GetSrvProfString("Startpath","") + _cNomeArq)
						EndIf

						DisarmTransaction()

					Else

						_lGerou := .T.

						_cLinDig  := Iif(Empty(Alltrim(_cLinDig))  ," ",Alltrim(_cLinDig))
						_cCodBar  := Iif(Empty(Alltrim(_cCodBar))  ," ",Alltrim(_cCodBar))
						_cBanco   := Iif(Empty(Alltrim(_cBanco))   ," ",Alltrim(_cBanco))
						_cConta   := Iif(Empty(Alltrim(_cConta))   ," ",Alltrim(_cConta))
						_cDVCta   := Iif(Empty(Alltrim(_cDVCta))   ," ",Alltrim(_cDVCta))
						_cAgenc   := Iif(Empty(Alltrim(_cAgenc))   ," ",Alltrim(_cAgenc))
						_cVencto  := Iif(Empty(Alltrim(DtoS(_dVencto)))," ",DtoS(_dVencto))
						_cVenRea  := Iif(Empty(Alltrim(DtoS(DataValida(_dVencto))))," ",DtoS(DataValida(_dVencto)))
						_cDatAge  := Iif(Empty(Alltrim(DtoS(DataValida(_dVencto))))," ",DtoS(DataValida(_dVencto)))
						_cCompet  := Iif(Empty(Alltrim(DtoS(_dCompet)))," ",DtoS(_dCompet))
						_cForPag  := Iif(Empty(Alltrim(_cForPag))  ," ",Alltrim(_cForPag))
						_cNaturez := Iif(Empty(Alltrim(_cNaturez)) ," ",Alltrim(_cNaturez))
						_cCCusto  := Iif(Empty(Alltrim(_cCCusto))  ," ",Alltrim(_cCCusto))
						_cItemCt  := Iif(Empty(Alltrim(_cItemCt))  ," ",Alltrim(_cItemCt))
						_cClasse  := Iif(Empty(Alltrim(_cClasse))  ," ",Alltrim(_cClasse))
						_cHist	  := Iif(Empty(Alltrim(_cHist))    ," ",Alltrim(_cHist))

						// 20180727 - tratamento de formas de pagamento
						_cQuery := "UPDATE "
						_cQuery += RetSQLName("SE2")
						_cQuery += " SET "
						//20180813 -
						IF !Empty(_cCodBar) .And. Empty(_cLinDig)
							_cQuery += "E2_LINDIG  = '" + _cCodBar  + "', "
						ElseIf !Empty(_cCodBar) .And. !Empty(_cLinDig)
							_cQuery += "E2_LINDIG  = '" + _cLinDig  + "', "
						Else
							_cQuery += "E2_LINDIG  = '" + _cLinDig  + "', "
						EndIf
						//_cQuery += "E2_LINDIG  = '" + _cLinDig  + "', "
						//_cQuery += "E2_CODBAR  = '" + _cCodBar  + "', "
						_cQuery += "E2_FORBCO  = '" + _cBanco   + "', "
						_cQuery += "E2_FORCTA  = '" + _cConta   + "', "
						_cQuery += "E2_FCTADV  = '" + _cDVCta   + "', "
						_cQuery += "E2_FORAGE  = '" + _cAgenc   + "', "
						
						If Alltrim(_cCond) == "001"
							_cQuery += "E2_VENCTO  = '" + _cVencto  + "', "
							_cQuery += "E2_VENCREA = '" + _cVenRea  + "', "
						Endif	
						
						_cQuery += "E2_DATAAGE = '" + _cDatAge  + "', "
						_cQuery += "E2_XCOMPET = '" + _cCompet  + "', "
						_cQuery += "E2_FORMPAG = '" + _cForPag  + "', "
						_cQuery += "E2_NATUREZ = '" + _cNaturez + "', "
						_cQuery += "E2_CCUSTO  = '" + _cCCusto  + "', "
						_cQuery += "E2_ITEMCTA = '" + _cItemCt  + "', "
						_cQuery += "E2_HIST	   = '" + _cHist  	+ "', "
						_cQuery += "E2_CLVL    = '" + _cClasse  + "', "
						_cQuery += "E2_XAGLUTI = '" + _cAgluti  + "', "
						_cQuery += "E2_XCONTRA = '" + _cContra  + "'  "
						_cQuery += "WHERE "
						_cQuery += "D_E_L_E_T_ <> '*' "
						_cQuery += "AND E2_FILIAL  = '" + xFilial("SE2")         + "' "
						_cQuery += "AND E2_PREFIXO = '" + SF1->F1_SERIE          + "' "
						_cQuery += "AND E2_NUM     = '" + SF1->F1_DOC            + "' "
						_cQuery += "AND E2_FORNECE = '" + SF1->F1_FORNECE        + "' "
						_cQuery += "AND E2_LOJA    = '" + SF1->F1_LOJA           + "' "
						_cQuery += "AND E2_EMISSAO = '" + DTOS(SF1->F1_EMISSAO)  + "' "
						_cQuery += "AND E2_TIPO    = 'NF '"

						nStatus := TCSqlExec(_cQuery)

						If nStatus < 0
							lMsErroAuto := .T.
							_cValInc += Iif(!Empty(Alltrim(_cValInc)),Chr(13) + Chr(10),"") + "Erro na atualização do Título Financeiro." + Chr(13) + Chr(10) + TCSQLError()
							DisarmTransaction()
						EndIf

					EndIf


					If Len(_aNatAlt) > 0
						For nY:= 1 to Len(_aNatAlt)
							DbSelectArea("SED")
							SED->(DbSetOrder(1))
							SED->(DbGoTop())
							If DbSeek(xFilial("SED")+_aNatAlt[nY][1])
								RecLock("SED",.F.)
								SED->ED_PERCINS := _aNatAlt[nY][2]
								SED->(MsUnLock())
							EndIf
						Next nY
					EndIf

					If Len(_aPrdAlt) > 0
						For nY:= 1 to Len(_aPrdAlt)
							DbSelectArea("SB1")
							SB1->(DbSetOrder(1))
							SB1->(DbGoTop())
							If DbSeek(xFilial("SB1")+_aPrdAlt[nY][1])
								RecLock("SB1",.F.)
								SB1->B1_ALIQISS := _aPrdAlt[nY][2]
								SED->(MsUnLock())
							EndIf
						Next nY
					EndIf

					_nRegSZZ := SZZ->(Recno())

					dbSelectArea("SZZ")
					SZZ->(dbGoTop())
					If SZZ->(dbSeek(_cChvSZZ + _cChvNF))
						While !SZZ->(Eof()) .And. (SZZ->(ZZ_FILIAL + ZZ_CODIGO) == _cChvSZZ) .And. (SZZ->(ZZ_DOC + ZZ_SERIE + ZZ_FORNECE + ZZ_LOJA) == _cChvNF)
							RecLock("SZZ",.F.)
							SZZ->ZZ_STATUS := Iif(lMsErroAuto,"2","1")
							SZZ->ZZ_LOG    := Iif(lMsErroAuto,SZZ->ZZ_LOG,"")
							SZZ->ZZ_LOGAUT := _cValInc
							SZZ->(MsUnLock())
							SZZ->(dbSkip())
						EndDo
					EndIf

					SZZ->(dbGoTop())
					SZZ->(dbGoTo(_nRegSZZ))

					End Transaction 
				EndIf

			EndIf

		EndDo

	EndIf

	If !_lGerou
		Aviso("Aviso","Nenhuma Nota Fiscal gerada, verifique!")
	Else
		If _lErro
			Aviso("Aviso","Geração das Notas da Importação N° " + _cNumImp + " finalizada com Inconsistências! Verifique o LOG!")
		Else
			Aviso("Aviso","Geração das Notas da Importação N° " + _cNumImp + " finalizada com Sucesso!")
		EndIf
	EndIf

	Restarea(_aArea)

	If Empty(Alias())
		dbSelectArea(_cAliasAnt)
	EndIf

Return



Static Function Mont_Array(_cStr,_cChar)

	Local _cCampo
	Local _cLinha
	Local _nLen
	Local _nPos
	Local _aRet := {}

	_cLinha := _cStr

	_nPos := AT(_cChar,_cLinha)
	While _nPos > 0
		_cCampo := Substr(_cLinha,1,_nPos - 1)
		aAdd(_aRet,_cCampo)
		_nLen := Len(_cLinha)
		_cLinha := Substr(_cLinha,_nPos + 1,_nLen - _nPos)
		_nPos := AT(_cChar,_cLinha)
	EndDo
	aAdd(_aRet,_cLinha)

Return(_aRet)

/*/
	+-----------------------------------------------------------------------------+
	| Função    | ECOM024E   | Autor | DFS Sistemas           | Data | 08/02/2019 |
	+-----------+-----------------------------------------------------------------+
	| Descrição | Rotina para Deletar o Lote Importado			                  |
	+-----------+-----------------------------------------------------------------+
	| Uso       | Específico ECOM024                                              |
	+-----------------------------------------------------------------------------+
/*/

User Function ECOM024D()

	Local _aArea     	:= GetArea()
	Local _cAliasAnt 	:= Alias()
	Local nOpc			:= 0

	nOpc := Aviso("Alerta", "Deseja Excluir o Lote?", {"Não","Sim"}, 1)

	If nOpc == 2
		Processa({|| _xExcLote()})
	EndIf

	Restarea(_aArea)
	If Empty(Alias())
		dbSelectArea(_cAliasAnt)
	EndIf

Return

/*/{Protheus.doc}''
''
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	
Static Function _xExcLote()
	Local nX 		:= 1	
	Local _cLotSZZ	:= SZZ->ZZ_CODIGO
	Local _cFilSZZ 	:= SZZ->ZZ_FILIAL
	Local aTitBx	:={}
	Local cNfMsg	:= ""
	Local aCabec	:= {}
	Local aLinha	:= {}
	Local aItens	:= {}
	Local _cChvSZZ 	:= SZZ->(ZZ_FILIAL + SZZ->ZZ_CODIGO + ZZ_DOC + ZZ_SERIE + ZZ_FORNECE + ZZ_LOJA)
	Local _cValInc  := ""
	Local _nRegSZZ 	:= SZZ->(Recno())
	Local nTotReg	:= 0
	Local nAviso    := 1
	Local lPergunte := .F.

	If SZZ->ZZ_STATUS $ '1/5'
		If Select('TLOT') > 0
			TLOT->(dbCloseArea())
		EndIf

		BeginSQL Alias 'TLOT'
		
		SELECT
		ZZ_FILIAL, ZZ_CODIGO, ZZ_STATUS, ZZ_DOC, ZZ_SERIE, ZZ_FORNECE, ZZ_LOJA, E2_BAIXA, E2_VALOR, E2_SALDO
		FROM %Table:SZZ% SZZ, %Table:SE2% SE2
		WHERE SZZ.%NotDel%
		AND SE2.D_E_L_E_T_ <> '*'
		AND E2_FILORIG = ZZ_FILIAL
		AND E2_PREFIXO = ZZ_SERIE
		AND E2_NUM = ZZ_DOC
		AND E2_FORNECE = ZZ_FORNECE
		AND E2_LOJA = ZZ_LOJA
		AND ZZ_FILIAL = %Exp:_cFilSZZ%
		AND ZZ_CODIGO = %Exp:_cLotSZZ%
		GROUP BY ZZ_FILIAL, ZZ_CODIGO, ZZ_STATUS, ZZ_DOC, ZZ_SERIE, ZZ_FORNECE, ZZ_LOJA, E2_BAIXA, E2_VALOR, E2_SALDO
				
		EndSQL

		TLOT->(DbGoTop())

		Count To  nTotReg

		ProcRegua(nTotReg)

		TLOT->(DbGoTop())
		Do While !TLOT->(EOF())
			If !Empty(TLOT->E2_BAIXA) .Or. TLOT->E2_SALDO <> TLOT->E2_VALOR
				Aadd(aTitBx,TLOT->ZZ_DOC)
			EndIf
			TLOT->(DbSkip())
		EndDo

		If Len(aTitBx) > 0
			For nX := 1 to Len(aTitBx)
				cNfMsg += aTitBx[nX]+CRLF
			Next Nx
			if nTotReg==len(aTitBx)
				Aviso("Atenção","Este lote se encontra com todos os titulos baixados pelo financeiro, para estorna-lo é necessario reabrir os titulos.Contate o financeiro",{"Sair"})
				Return
			Else
				Aviso("Atenção","O(s) Titulo(s) Abaixo estão baixados e não será possivel exclui-los do Lote"+CRLF+CRLF+cNfMsg)
				lPergunte := .T.
			endif
		Endif

		If lPergunte
			nAviso := Aviso("Atenção","Deseja prosseguir com o estorno somente das notas fiscais sem movimento de baixas pelo financeiro?",{"Prosseguir","Abortar"})
		Endif

		If nAviso==1
			TLOT->(DbGoTop())
			Do While !TLOT->(EOF())

				IncProc("Excluindo Documento: " + Alltrim(TLOT->ZZ_DOC) + " / " + Alltrim(TLOT->ZZ_SERIE) + " - Fornecedor: " + Alltrim(TLOT->ZZ_FORNECE) +" / "+ Alltrim(TLOT->ZZ_LOJA) + "...")
				ProcessMessage()

				if lPergunte
					If aScan( aTitBx , TLOT->ZZ_DOC ) > 0
						TLOT->(dbSkip())
						Loop
					Endif
				Endif

				DbSelectArea("SF1")
				SF1->(DbGoTop())
				SF1->(DbSetOrder(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
				If SF1->(DbSeek(TLOT->(ZZ_FILIAL+ZZ_DOC+ZZ_SERIE+ZZ_FORNECE+ZZ_LOJA)))

					cChvNf := SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

					aCabec :={}
					aLinha :={}
					aItens :={}

					// Cabeçalho
					aadd(aCabec,{"F1_FILIAL"	,SF1->F1_FILIAL		,Nil})
					aadd(aCabec,{"F1_DOC"		,SF1->F1_DOC		,Nil})
					aadd(aCabec,{"F1_SERIE"		,SF1->F1_SERIE		,Nil})
					aadd(aCabec,{"F1_FORNECE"	,SF1->F1_FORNECE	,Nil})
					aadd(aCabec,{"F1_LOJA"		,SF1->F1_LOJA		,Nil})
					aadd(aCabec,{"F1_TIPO"		,SF1->F1_TIPO		,Nil})
					AAdd(aCabec,{"F1_EMISSAO"   ,SF1->F1_EMISSAO   	,Nil})
					AAdd(aCabec,{"F1_FORMUL"    ,SF1->F1_FORMUL    	,Nil})
					AAdd(aCabec,{"F1_ESPECIE"   ,SF1->F1_ESPECIE	,Nil})
					AAdd(aCabec,{"F1_COND"      ,SF1->F1_COND   	,Nil})

					SD1->(DbGoTop())
					SD1->(DbSetOrder(1))//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
					If SD1->(DbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
						Do While !SD1->(EOF()) .And. cChvNf == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

							aadd(aLinha,{"D1_FILIAL" ,SD1->D1_FILIAL	,Nil})
							aadd(aLinha,{"D1_DOC"    ,SD1->D1_DOC		,Nil})
							aadd(aLinha,{"D1_SERIE"  ,SD1->D1_SERIE		,Nil})
							aadd(aLinha,{"D1_FORNECE",SD1->D1_FORNECE	,Nil})
							aadd(aLinha,{"D1_LOJA"	 ,SD1->D1_LOJA  	,Nil})
							aadd(aLinha,{"D1_COD"	 ,SD1->D1_COD	  	,Nil})
							aadd(aLinha,{"D1_ITEM"	 ,SD1->D1_ITEM  	,Nil})

							aadd(aItens,aLinha)

							SD1->(DbSkip())
						EndDo

						If Len(aCabec) <> 0 .And. Len(aItens) <> 0

							_cBuffer   := ""
							_nErrLin   := 1
							_nLinhas   := 0
							_cErroTemp := ""
							_cNomeArq  := "LOG_" + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) + SUBSTR(TIME(),1,2) + SUBSTR(TIME(),4,2) + SUBSTR(TIME(),7,2) + ".log"

							lMsErroAuto := .F.

							MsExecAuto({|x,y,z| MATA103(x,y,z)},aCabec,aItens,5)

							If lMsErroAuto

								_lErro:= .T.
								_cDir := GetSrvProfString("Startpath","")

								MostraErro( _cDir , _cNomeArq )

								cRet := MemoRead(_cDir + _cNomeArq)

								If File(_cDir + _cNomeArq)
									FErase(_cDir + _cNomeArq)
								EndIf

								dbSelectArea("SZZ")
								SZZ->(dbSetOrder(1)) // ZZ_FILIAL+ZZ_CODIGO+ZZ_DOC+ZZ_SERIE+ZZ_FORNECE+ZZ_LOJA+ZZ_ITEM
								SZZ->(dbGoTop())
								If SZZ->(DbSeek(TLOT->ZZ_FILIAL+_cLotSZZ+TLOT->ZZ_DOC))
									RecLock("SZZ",.F.)
									SZZ->ZZ_STATUS := "5"
									SZZ->ZZ_LOGAUT := cRet
									SZZ->(MsUnLock())
								Else
									Aviso("Atenção","1 - Importção não localizada para atualização",{"Ok"})
								Endif
							Else
								dbSelectArea("SZZ")
								SZZ->(dbSetOrder(1)) // ZZ_FILIAL+ZZ_CODIGO+ZZ_DOC+ZZ_SERIE+ZZ_FORNECE+ZZ_LOJA+ZZ_ITEM
								SZZ->(dbGoTop())
								//If SZZ->(dbSeek( _cFilSZZ + _cLotSZZ + TLOT->(ZZ_DOC+ZZ_SERIE+ZZ_FORNECE+ZZ_LOJA) ))
								If SZZ->(DbSeek(TLOT->ZZ_FILIAL+_cLotSZZ+TLOT->ZZ_DOC))
									RecLock("SZZ",.F.)
									SZZ->ZZ_STATUS := "4"
									SZZ->(MsUnLock())
								Else
									Aviso("Atenção","2 - Importção não localizada para atualização",{"Ok"})
								Endif
							EndIf
						Else
							Aviso("Atenção","Não existem itens aptos para exclusão.",{"Ok"})
						EndIf
					else
						Aviso("Atenção","Itens não localizados para exclusão, Nota Fiscal: " +TLOT->ZZ_DOC ,{"Ok"})
					EndIf
				Else
					Aviso("Atenção","Nota Fiscal: "+TLOT->ZZ_DOC+ " não localizada para exclusão",{"Ok"})
				EndIf
				TLOT->(DbSkip())
			EndDo
			Aviso("Aviso","Lote excluido com sucesso")
		Endif
		If Select('TLOT') > 0
			TLOT->(dbCloseArea())
		EndIf
	Elseif SZZ->ZZ_STATUS == '2'
		Aviso("Aviso","Selecione um Lote sem inconsitência.")
	Elseif SZZ->ZZ_STATUS == '3'
		Aviso("Aviso","Selecione um Lote Gerado.")
	Elseif SZZ->ZZ_STATUS == '4'
		Aviso("Aviso","Lote se encontra estornado.")
	EndIf

Return()

/*/{Protheus.doc}'ECOM024X'
''
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	
User Function ECOM024X
	Local oDlg
	Local cMemo
	Local oFont

	If EMpty(SZZ->ZZ_LOGAUT)
		Aviso("Atenção","Não existem logs para este documento.",{"Ok"})
	Else
		DEFINE FONT oFont NAME "Courier New" SIZE 7,14

		cMemo :=SZZ->ZZ_LOGAUT
		DEFINE MSDIALOG oDlg TITLE "LOG" From 3,0 to 340,550 PIXEL

		@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 267,145 OF oDlg PIXEL
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont

		ACTIVATE MSDIALOG oDlg CENTER
	Endif

Return
