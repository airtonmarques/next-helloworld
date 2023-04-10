#include 'protheus.ch'
#include 'parmtype.ch'
#include "APWIZARD.ch"
#include "FWBROWSE.CH"
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | ECOM020   | Autor | DFSSISTEMAS | Data | 20/06/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Tela para inclusao das rubricas                     |
|           |                                                     |
+-----------+-----------------------------------------------------+
| Uso       | Ponto de entrada MT100TOK                           | 
+-----------+-----------------------------------------------------+ 
*/
user function ECOM020()

	Local lRet 		:= .T.
	Local cTitulo	:= 'Rúbricas'
	Local nOpc		:= 2
	Local oTam		:= Nil
	Local aColunas 	:= {}
	Local aCampos	:= {}
	Local nX		:= 0
	Local cBkCad	:= cCadastro
	
	Local aRubricas := {}
	Local aCombo	:= {}
	Local cRub		:= ''
	Local nVal		:= 0
	
	Local nSuperior := 000
	Local nEsquerda := 000
	Local nInferior := 250
	Local nDireita	:= 397
	Local nOpc		:= 3
	Local cLinOk 	:= ""
	Local cTudoOk 	:= ""
	Local cIniCpos	:= "Z1_ITEM"
	Local aAlterGDa := {}
	Local nFreeze 	:= 000
	Local nMax 		:= 999
	Local cFieldOk 	:= ""
	Local cSuperDel := ""
	Local cDelOk 	:= ""
	Local aHeader 	:= {}
	Local aCols 	:= {}
	Local cForRb	:= alltrim(GetNewPar( "MV_XFORRB", "OPE"))
	Local aAreaSA2	:= SA2->(GetArea())
			
	Private oDialogo	:= Nil	
	Private oLista		:= Nil
	Private oColumn		:= Nil
	Private oPCabec		:= Nil
	Private oPRubricas	:= Nil
	Private oPRodape	:= Nil
	Private nTotNF		:= 0
	Private nTotSoma	:= 0
	Private nTotRub		:= 0
	Private nDif		:= 0
		
	Public aHeadSZ1	:= {}
	Public aColsSZ1	:= {}

	lRet	:= .T.
	
	If IsIncallstack('u_MT100TOK')
		nTotNF	:= MaFisRet(,"NF_BASEDUP")
		nDif	:= nTotNF
	Else
		nTotNF	:= M->E2_VALOR
		nDif	:= nTotNF
	Endif

	IF lRet .and. SA2->A2_GRUPO $ cForRb
	
		cCadastro := 'Cadastro de Rúbricas'
		
		AADD(aCampos,'Z1_ITEM')
		AADD(aCampos,'Z1_RUBRICA')
		AADD(aCampos,'Z1_DESCRI')	
		AADD(aCampos,'Z1_TOTAL')
		
		dbSelectArea('SX3')
		SX3->(dbSetOrder(2))
		For nX := 1 TO Len(aCampos)
			If SX3->(dbseek(aCampos[nX]))
				SX3->(AADD(aHeader,{ AllTrim(X3_TITULO),Alltrim(X3_CAMPO),X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CBOX } ))
			Endif
		Next nX
		aCols:={Array(Len(aHeader)+1)}
		aCols[1,Len(aCols[1])] := .F. // Campo linha deletada
		For nX:=1 to Len(aHeader)
			If aHeader[nX,2] == cIniCpos
				aCols[1,nX]:= "0001"
			Else
				aCols[1,nX]:=CriaVar(aHeader[nX,2])
			Endif
		Next	
					
		AADD(aAlterGDa,'Z1_RUBRICA')
		AADD(aAlterGDa,'Z1_TOTAL')
		
		cLinOk 	:= "u_ECOM020LN" //***** Se necessário exibir mensagem: "If(u_EF001LK(),.T.,MsgAlert('Total de rúbricas menor que o total da NF!','Valor invalido'))"
		cFieldOk:= "u_ECOM020CP"
		cTudoOk	:= "If(u_ECOM020TD(),.T.,MsgAlert('Total somado está inconsistentes com o valor total da nota!','Valor invalido'))"
		cDelOk 	:= "u_ECOM020DL"
	
		DEFINE DIALOG oDialogo FROM 0,0 TO 600,800 PIXEL TITLE 'RUBRICAS' //OF oMainWnd
			oPCabec		:= tPanel():New(030	,3	,"",oDialogo,,,,,,397,020,,.T.)
			oPRubricas	:= tPanel():New(050	,3	,"",oDialogo,,,,,,397,230,,.T.)
			oPRodape	:= tPanel():New(280	,3	,"",oDialogo,,,,,,397,020,,.T.)
			
			/****** Cabeçalho ******/
			oValNF  := TGet():New( 02, 009, { | u | If( PCount() == 0, nTotNF	, nTotNF := u	) },oPCabec,060, 010, "@E 999,999,999.99",, 0, 16777215,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F. ,,"nTotNF"	,,,,.F.,,,'Tot.Nota:'  )
			/****** Fim Cabeçalho ******/						
			
			oLista		:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita, nOpc,cLinOk,cTudoOk,"+"+cIniCpos,aAlterGDa,nFreeze,nMax,cFieldOk, cSuperDel,cDelOk, oPRubricas, aHeader, aCols)		
	
			/****** Totais ******/
			
			oValSom := TGet():New( 02, 009, { | u | If( PCount() == 0, nTotSoma	, nTotSoma := u	) },oPRodape,060, 010, "@E 999,999,999.99",, 0, 16777215,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F. ,,"nTotSoma"	,,,,.F.,,,'Tot.Somado:'  )		
			oValRub := TGet():New( 02, 119, { | u | If( PCount() == 0, nTotRub	, nTotRub := u 	) },oPRodape,060, 010, "@E 999,999,999.99",, 0, 16777215,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F. ,,"nTotRub",,,,.F.,,,'Tot.Rubricas:'  )
			oValDif := TGet():New( 02, 229, { | u | If( PCount() == 0, nDif		, nDif := u 	) },oPRodape,060, 010, "@E 999,999,999.99",, 0, 16777215,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F. ,,"nDif"	,,,,.F.,,,'Diferença NF:'  )		
			/****** Fim Totais ******/
	
		ACTIVATE DIALOG oDialogo CENTERED ;
		ON INIT EnchoiceBar(oDialogo,;
		{||If(oLista:TudoOK(),(nOpc := 1,oDialogo:End()),nOpc:=0)},;
		{||(nOpc := 0,oDialogo:End())},;
		.F.,{},,,.F.,.F.,.F.,.T.,.F.,'ECOM020') 
	
		If nOpc == 1
			aHeadSZ1	:= oLista:aHeader
			aColsSZ1	:= oLista:aCols
			lRet := .T.
			oPRubricas	:= Nil
			oPRodape	:= Nil		
			oColumn		:= Nil
			oLista 		:= Nil
			oDialogo 	:= Nil
		Else
			lRet := .F.
			oPRubricas	:= Nil
			oPRodape	:= Nil		
			oColumn		:= Nil
			oLista 		:= Nil
			oDialogo 	:= Nil
		Endif
		
		cCadastro := cBkCad
	Else
		lRet := .T.
	Endif

	Restarea(aAreaSA2)
	
return lRet

User Function ECOM020CP()

	Local lRet 		:= .T.
	Local nPosTot 	:= aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "Z1_TOTAL"})
	Local nPosRub 	:= aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "Z1_RUBRICA"})	
	Local nCol		:= oLista:oBrowse:nColPos
	Local uNovoVl	:= &(ReadVar())
	
	If nCol == nPosTot
		nTotRub := 0
		nTotSoma:= 0
		For nX := 1 to Len(aCols)
			SZ0->(dbSetOrder(1))
			If SZ0->(dbSeek(xFilial('SZ0')+aCols[nX,nPosRub]))
				If nX == oLista:nAt
					nTotRub += uNovoVl
					If SZ0->Z0_TOTALIZ == '1'
						If SZ0->Z0_NATRUBR == 'A' 
							nTotSoma += uNovoVl
						ELSE
							nTotSoma += (uNovoVl*-1)
						EndIf
					Endif
				Else
					nTotRub += aCols[nX,nPosTot]
					If SZ0->Z0_TOTALIZ == '1'
						If SZ0->Z0_NATRUBR == 'A'
							nTotSoma += aCols[nX,nPosTot]
						Else
							nTotSoma += (uNovoVl*-1)
						EndIf
					Endif
				Endif
			Endif
		Next nX	
		nDif := nTotNf - nTotSoma
	Endif
	
	oValSom:Refresh()
	oValRub:Refresh()
	oValDif:Refresh()
		
Return lRet

User Function ECOM020LN()

	Local lRet := .T.

Return lRet

User Function ECOM020TD()

	Local lRet := .T.

	If nDif <> 0
		lRet := .F.
	Endif

Return lRet

User Function ECOM020DL()

	Local lRet := .T.

Return lRet