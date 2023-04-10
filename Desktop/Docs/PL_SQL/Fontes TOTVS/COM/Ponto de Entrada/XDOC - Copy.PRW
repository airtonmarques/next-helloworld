#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc}''
''
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	
User Function MSDOCBUT
	Local aRot :={}
	AAdd( aRot, { "NORMAS" , { || U_fOtherDocs() }, "Outros Documentos", "Outros Documentos" } )
Return aRot

/*/{Protheus.doc}''
''
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/		
User Function fOtherDocs()

	Local oTela
	Local aSizex    := {}
	Local aArea     := GetArea()
	Local cCadastro	:= "Outros Documentos"
	Local cAlias	:= "SC1"
	Local lGravou   := .F.
	Local lTravas   := .T.
	Local	cQuery	:= ""
	Local cDadoSC1  := ""
	Local cDadoSC7  := ""
	Local cDadoSC8  := ""
	Local cDadoSE2 := ""
	Local cDadoSF1  := ""
	Local cCond1 	:= ""
	Local cCond2   	:= ""
	Local cCond3    := ""
	Local cCond4    := ""
	Local aHeaDad	:= {}
	Local aColDad	:= {}

	Private aColsSize := {}

	If FunName(0) $ "MATA110/FINA050"
		If !Empty(SC1->C1_PEDIDO)
			cDadoSC7 := SC1->C1_FILIAL+SC1->C1_PEDIDO
			cCond1 := "AC9_ENTIDA='SC7' AND SUBSTRING(AC9_CODENT,1,10)='" + cDadoSC7 + "'"
		Endif
		If !Empty(SC1->C1_COTACAO)
			cDadoSC8 := SC1->C1_FILIAL+SC1->C1_COTACAO
			cCond2 := "AC9_ENTIDA='SC8' AND SUBSTRING(AC9_CODENT,1,10)='" + cDadoSC8 + "'"
		Endif
		If FunName(0) $ "FINA050"
		If !Empty(SE2->E2_NUM)
			cDadoSE2 := SE2->E2_FILIAL+SE2->E2_NUM
			cCond4 := "AC9_ENTIDA='SE2' AND SUBSTRING(AC9_CODENT,1,10)='" + cDadoSE2 + "'"
			dbSelectArea("SE2")
			dbSetOrder(1)
		If dbSeek(cDadoSE2)
			cDadoSE2 := SE2->E2_FILIAL+SE2->E2_NUM                                                                     
			cCond4 := "AC9_ENTIDA='SF1' AND SUBSTRING(AC9_CODENT,1,20)='" + cDadoSE2 + "'"
		Endif
	    Endif
		Endif
		dbSelectArea("SD1")
		dbSetOrder(22)
		If dbSeek(cDadoSC7)
			cDadoSF1 := SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			cCond3 := "AC9_ENTIDA='SF1' AND SUBSTRING(AC9_CODENT,1,20)='" + cDadoSF1 + "'"
		Endif
	Elseif FunName(0) $ "MATA120/MATA121"
		If !Empty(SC7->C7_NUMSC)
			cDadoSC1 := SC7->C7_FILIAL+SC7->C7_NUMSC
			cCond1 := "AC9_ENTIDA='SC1' AND SUBSTRING(AC9_CODENT,1,10)='" + cDadoSC1 + "'"
		Endif
		If !Empty(SC7->C7_NUMCOT)
			cDadoSC8 := SC7->C7_FILIAL+SC7->C7_NUMCOT
			cCond2 := "AC9_ENTIDA='SC8' AND SUBSTRING(AC9_CODENT,1,10)='" + cDadoSC8 + "'"
		Endif
		dbSelectArea("SD1")
		dbSetOrder(22)
		If dbSeek(SC7->C7_FILIAL+SC7->C7_NUM)
			cDadoSF1 := SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			cCond3   := "AC9_ENTIDA='SF1' AND SUBSTRING(AC9_CODENT,1,20)='" + cDadoSF1 + "'"
		Endif
	Elseif FunName(0) $ "MATA150/MATA161"
		If !Empty(SC8->C8_NUMSC)
			cDadoSC1 := SC8->C8_FILIAL+SC8->C8_NUMSC
			cCond1 := "AC9_ENTIDA='SC1' AND SUBSTRING(AC9_CODENT,1,10)='" + cDadoSC1 + "'"
		Endif
		If !Empty(SC8->C8_NUMPED)
			cDadoSC7 := SC8->C8_FILIAL+SC8->C8_NUMPED
			cCond2 := "AC9_ENTIDA='SC7' AND SUBSTRING(AC9_CODENT,1,10)='" + cDadoSC7 + "'"
		Endif
		dbSelectArea("SD1")
		dbSetOrder(22)
		If dbSeek(SC8->C8_FILIAL+Padr(SC8->C8_NUMPED,TamSx3("C7_NUM")[1]))
			cDadoSF1 := SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			cCond3   := "AC9_ENTIDA='SF1' AND SUBSTRING(AC9_CODENT,1,20)='" + cDadoSF1 + "'"
		Endif
	Elseif FunName(0) $ "MATA103/MATA140"
		dbSelectArea("SD1")
		dbSetOrder(1)
		if dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
			If !Empty(SD1->D1_PEDIDO)
				cDadoSC7 := SD1->D1_FILIAL+SD1->D1_PEDIDO
				cCond1 := "AC9_ENTIDA='SC7' AND SUBSTRING(AC9_CODENT,1,10)='" + cDadoSC7 + "'"
				dbSelectArea("SC7")
				dbSetOrder(1)
				if dbSeek(cDadoSC7) .And. !Empty(SC7->C7_NUMCOT)
					cDadoSC8 := SC7->C7_FILIAL+SC7->C7_NUMCOT
					cCond2 := "AC9_ENTIDA='SC8' AND SUBSTRING(AC9_CODENT,1,10)='" + cDadoSC8 + "'"
					If !Empty(SC7->C7_NUMSC)
						cDadoSC1 := SC7->C7_FILIAL+SC7->C7_NUMSC
						cCond3 := "AC9_ENTIDA='SC1' AND SUBSTRING(AC9_CODENT,1,10)='" + cDadoSC1 + "'"
					Endif
				Endif
			Endif
		Endif
	Elseif FunName(0) $ "MATA094"
		If SCR->CR_TIPO=="SC"
			dbSelectArea("SC1")
			dbSetOrder(1)
			If dbSeek( xFilial("SC1") + substr(SCR->CR_NUM,1,6) )
				cDadoSC1 := SC1->C1_FILIAL+SC1->C1_NUM
				cCond1 := "AC9_ENTIDA='SC1' AND SUBSTRING(AC9_CODENT,1,10)='" + cDadoSC1 + "'"
				If !Empty(SC1->C1_PEDIDO)
					cDadoSC7 := SC1->C1_FILIAL+SC1->C1_PEDIDO
					cCond1 := "AC9_ENTIDA='SC7' AND SUBSTRING(AC9_CODENT,1,10)='" + cDadoSC7 + "'"
				Endif
				If !Empty(SC1->C1_COTACAO)
					cDadoSC8 := SC1->C1_FILIAL+SC1->C1_COTACAO
					cCond2 := "AC9_ENTIDA='SC8' AND SUBSTRING(AC9_CODENT,1,10)='" + cDadoSC8 + "'"
				Endif
			Endif
		Elseif SCR->CR_TIPO $ "PC/IP"
			dbSelectArea("SC7")
			dbSetOrder(1)
			If dbSeek( xFilial("SC7") + substr(SCR->CR_NUM,1,6) )
				cDadoSC7 := SC7->C7_FILIAL+SC7->C7_NUM
				cCond1 := "AC9_ENTIDA='SC7' AND SUBSTRING(AC9_CODENT,1,10)='" + cDadoSC7 + "'"
				If !Empty(SC7->C7_NUMSC)
					cDadoSC1 := SC7->C1_FILIAL+SC7->C7_NUMSC
					cCond1 := "AC9_ENTIDA='SC1' AND SUBSTRING(AC9_CODENT,1,10)='" + cDadoSC1 + "'"
				Endif
				If !Empty(SC7->C7_NUMCOT)
					cDadoSC8 := SC7->C7_FILIAL+SC7->C7_NUMCOT
					cCond2 := "AC9_ENTIDA='SC8' AND SUBSTRING(AC9_CODENT,1,10)='" + cDadoSC8 + "'"
				Endif
			Endif
		Endif
	Endif

	If Empty(cCond1) .And. Empty(cCond2) .And. Empty(cCond3) .And. Empty(cCond4) 
		Aviso("Atenção","Esta rotina realiza o tracker de documento apenas para rotinas de suprimento.")
		Return
	Endif

	cQuery += "SELECT AC9.*,AC9.R_E_C_N_O_ AC9RECNO,ACB_OBJETO "
	cQuery += "FROM " + RetSqlName( "AC9" ) + " AC9 "
	cQuery += "INNER JOIN "+RetSqlName("ACB")+" ACB ON AC9_FILIAL=ACB_FILIAL AND AC9_CODOBJ=ACB_CODOBJ AND ACB.D_E_L_E_T_= ' ' "
	cQuery += "WHERE "
	cQuery += "AC9_FILIAL='" + xFilial( "AC9" )     + "' AND "
	cQuery += "AC9_FILENT='" + xFilial( cAlias ) + "' AND "

	cQuery +=  " ( "
	If !Empty(cCond1)
		cQuery += cCond1 + " OR "
	Endif

	If !Empty(cCond2)
		cQuery += cCond2 + " OR "
	Endif

	If !Empty(cCond3)
		cQuery += cCond3 + " OR "
	Endif

	
	If Right(cQuery,3)=="OR "
		cQuery := Substr(cQuery,1,Len(cQuery)-3)
	Endif
	cQuery +=  " ) "
	cQuery += " AND AC9.D_E_L_E_T_=' ' ORDER BY " + SqlOrder( AC9->( IndexKey() ) )


	fDados(@aHeaDad,@aColDad,cQuery)

	If ( lTravas )

		aSizex := MsAdvSize( )

		DEFINE MSDIALOG oTela TITLE cCadastro FROM 0,0 TO 600,900 OF oMainWnd PIXEL

		oPanel0:= TPanel():New(0, 0, "", oTela , NIL, .T., .F., NIL, NIL, 0, 20 , .T., .F. )
		oPanel0:Align:=CONTROL_ALIGN_TOP

		oPanel1:= TPanel():New(0, 0, "", oTela , NIL, .T., .F., NIL, NIL, 0, 0, .T., .F. )
		oPanel1:Align:=CONTROL_ALIGN_ALLCLIENT

		oGetDad := MsNewGetDados():New(0  ,0    ,0      ,0     ,GD_INSERT+GD_UPDATE+GD_DELETE,/*"LK"*/  ,/*"TK"*/ ,/*"+IT"*/,/*aAlter*/,       ,    ,        ,         ,      ,oPanel1,aHeaDad,aColDad,,,aColsSize)

		oGetDad:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
		oGetDad:lInsert := .F.	// Inibe inclusao
		oGetDad:lDelete := .F.	// Inibe exclusao

		@  4,400  BUTTON oButPrev PROMPT "Preview" SIZE 035,012 FONT oTela:oFont ACTION fopenArq() OF oPanel0 PIXEL

		oPanel0:= TPanel():New(0, 0, "", oTela , NIL, .T., .F., NIL, NIL, 0, 8 , .T., .F. )
		oPanel0:Align:=CONTROL_ALIGN_BOTTOM

		oOle := TOleContainer():New( 0, 0, 300,600,oTela, , "" )
		oOle:Hide()



		ACTIVATE MSDIALOG oTela CENTERED

	EndIf

	RestArea( aArea )

Return(lGravou)

/*/{Protheus.doc}''
''
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/		

Static Function FOpenArq()
	Local cFile     := Alltrim(oGetDad:aCols[oGetDad:nAt][4])
	Local cPastaRmt := Alltrim(GetTempPath())
	Local cPastaSrv := Alltrim(MsDocPath())+"\"
	Local cOper     := "open"
	Local cParam    := ""
	Local cDir      := ""

	If Right(cPastaSrv,1)<>"\"
		cPastaSrv+="\"
	Endif

	If Right(cPastaRmt,1)<>"\"
		cPastaRmt+="\"
	Endif

	lCpy := CpyS2T( cPastaSrv+cFile , cPastaRmt ,.F., .F. )
	If lCpy
		nRet := ShellExecute(cOper,cPastaRmt+cFile,cParam,cDir, 1 )
		If nRet <= 32
			Aviso( "Atenção", "Não foi possivel abrir o arquivo " + cPastaRmt+cFile , { "Ok" }, 2 )
		EndIf
	Else
		Aviso("Atenção","Falha ao copiar o arquivo "+cPastaSrv+cFile+" para a pasta "+ cPastaRmt+cFile+" - Ferror "+Str(Ferror()) ,{"Ok"},2 )
	Endif

Return

/*/{Protheus.doc}''
''
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
Static Function fDados(aHeaDad, aColDad , cQuery)
	Local nI
	Local nHeader

	aHeaAux	:= {"Entidade"	,; // 01 - Titulo
	"AC9_PROCES",; // 02 - Campo
	"@!"		,; // 03 - Picture
	100			,; // 04 - Tamanho
	0  			,; // 05 - Decimal
	Nil			,; // 06 - Valid
	Nil			,; // 07 - Usado
	"C"			,; // 08 - Tipo
	Nil			,; // 09 - F3
	"V"			,; // 10 - Contexto
	Nil			,; // 11 - Box - Opcoes do combo
	Nil			,; // 12 - Ini. Padrao
	".F."		,; // 13 - When
	Nil			,; // 14 - Visual
	Nil			,; // 15 - Val. User
	Nil			 } // 16 - PictVar

// Adiciona o checkmark no aHeader
	aAdd(aHeaDad, aClone(aHeaAux))

	aAdd(aColsSize , {"AC9_PROCES" , 80 } )

	DbSelectArea("SX3")
	DbSetOrder(2)

// Monta os campos do GetDados
	aFieAux	:= { "AC9_CODENT", "AC9_CODOBJ", "ACB_OBJETO" }

	For nI := 1 To Len(aFieAux)
		If SX3->(DbSeek(aFieAux[nI]))
			aHeaAux		:= fSetHea()
			aHeaAux[14]	:= "V"
			aAdd(aHeaDad, aClone(aHeaAux))
		EndIf
	Next nI

	If Select("TRB")>0
		dbSelectArea("TRB")
		dbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)

	TcQuery cQuery New Alias "TRB"

	TRB->(dbGotop())
	While TRB->(!Eof())

		aColAux := {}												// Inicializa o vetor auxiliar
		For nHeader := 1 To Len(aHeaDad)
			SX2->( dbSetOrder( 1 ) )
			SX2->( DbSeek( TRB->AC9_ENTIDA ) )
			If aHeaDad[nHeader][2]=="AC9_PROCES"
				aAdd(aColAux, Capital( X2NOME() ) )
			Else
				aAdd(aColAux, TRB->(&(aHeaDad[nHeader][2]))  )
			Endif
		Next
		aAdd(aColAux, .F.)
		aAdd(aColDad, aClone(aColAux))
		TRB->(DbSkip())
	EndDo

	TRB->(DbCloseArea())

Return Nil

/*/{Protheus.doc}''
''
@author Ovio Consultoria
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
Static Function fSetHea()
	Local aRetFun := {}

	aRetFun	:= {	AllTrim(X3TITULO())	,; // 01 - Titulo
	SX3->X3_CAMPO		,; // 02 - Campo
	SX3->X3_PICTURE		,; // 03 - Picture
	SX3->X3_TAMANHO		,; // 04 - Tamanho
	SX3->X3_DECIMAL		,; // 05 - Decimal
	SX3->X3_VALID		,; // 06 - Valid
	SX3->X3_USADO		,; // 07 - Usado
	SX3->X3_TIPO		,; // 08 - Tipo
	SX3->X3_F3  		,; // 09 - F3
	SX3->X3_CONTEXT		,; // 10 - Contexto
	SX3->X3_CBOX		,; // 11 - Box - Opcoes do combo
	SX3->X3_RELACAO		,; // 12 - Ini. Padrao
	SX3->X3_WHEN		,; // 13 - When
	SX3->X3_VISUAL		,; // 14 - Visual
	SX3->X3_VLDUSER		,; // 15 - Val. User
	SX3->X3_PICTVAR		 } // 16 - PictVar

	If Alltrim(SX3->X3_CAMPO)=="AC9_CODENT"
		nTam := 120
	Else
		nTam := 60
	Endif

	aAdd(aColsSize , { Alltrim(SX3->X3_CAMPO) , nTam } )

Return aRetFun
