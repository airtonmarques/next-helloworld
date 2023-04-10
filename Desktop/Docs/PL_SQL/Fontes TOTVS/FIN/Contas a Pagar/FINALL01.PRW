#iNCLUDE "TOTVS.CH"

/*/{Protheus.doc}'FINALL01' 
Rotinina responsavel em aglutinar titulos de acordo com nr de contrato
@author Ovio Consultoria
@since '01/04/2020'
@version 'P12.1.25 v.01'
@type function
@see ''
@obs ''
@param 'mv_par01 - Informar se deve gerar o relatorio após execução.'
@return 'Nil'
/*/ 
Function u_FINALL01()

    Local cMsg		:= ""
    Local cPerg		:= "FINALL0003"
    Local cProcess	:= "FINALL01"
    Local cCadastro := "Aglutinação de Titulos"
    Local oProcess  := Nil

    AjusPerg(cPerg)

    Pergunte(cPerg,.F.)

    bProcess := {|oProcess| fAglTitulo(oProcess) }

    cMsg := " Esta rotina tem como objetivo gerar os titulos aglutinados com "+CRLF
    cMsg += "base nos contratos lançados no contas a pagar. Os titulos para aglutinação "+CRLF
    cMsg += "devem possuir mesmo número de contrato [E2_XCONTRA], mesmo número de "+CRLF
    cMsg += "linha digitavel [E2_LINDIG], possuir situação em aberto e estar liberado. "+CRLF

    oProcess := tNewProcess():New( cProcess , cCadastro , bProcess ,OemtoAnsi(cMsg), cPerg , NIL , .T. , NIL , NIL , .T. , .F. )

Return

/*/{Protheus.doc} fAglTitulo
@sample 	fAglTitulo
@author	    Ovio Consultoria		
@since		01/04/2020
@version	P12
/*/
Static Function fAglTitulo(oProcess)

    Local f
    Local nTitAgl   := 1
    Local nLen13
    Local nRecs     := 0
    Local __cAlias  := GetNextAlias()
    Local lContinua := .T.
    Local __cWhere  := "%SE2.E2_EMISSAO>='"+DtoS(MV_PAR03)+"' AND SE2.E2_XCONTRA<>' ' AND SE2.E2_LINDIG<>' ' AND SE2.E2_BAIXA=' ' AND  SE2.E2_VALOR=SE2.E2_SALDO AND SE2.E2_XAGLUTI='S' AND SE2.E2_FATURA=' '%"

    Local __cPrfxFat := Alltrim(GetMv("OV_PREFFAT",,"FTA")) //Prefixo do Titulo da Fatura
    Local __cCondPag := Alltrim(GetMv("OV_CONDFAT",,"001")) //Condição de Pgto Titulo da Fatura
    Local __cNumFatu := ""
    Local __cNumCont := ""
    Local __cNaturez := ""
    Local __dCompIni := ""
    Local __dCompFim := ""
    Local __Forneced := ""
    Local __FornecLj := ""


    Private __lGerLog   := mv_par01==1
    Private __lShowBrow := mv_par02==1
    Private lMsErroAuto := .F.

    Private aFatAll   := {}
    Private aFatPag   := {}
    Private aFatGrp   := {}
    Private aFatLog   := {}
    Private lFatAut   := .T.

    oProcess:SaveLog("INICIO")

    BeginSql Alias __cAlias
SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,E2_VENCREA,E2_NATUREZ,E2_LINDIG,E2_XCONTRA,E2_XCOMPET,E2_EMISSAO
FROM %Table:SE2% SE2
WHERE 
     E2_FILIAL  = %xfilial:SE2% AND %Exp:__cWhere% AND 
     SE2.%notDel% AND E2_XCONTRA IN ( SELECT E2_XCONTRA
                                      FROM %Table:SE2% SE2  
                                      WHERE 
                                           E2_FILIAL  = %xfilial:SE2% AND %Exp:__cWhere% AND SE2.%notDel%
                                           GROUP BY E2_LINDIG,E2_XCONTRA    
                                           HAVING COUNT(E2_LINDIG+E2_XCONTRA) > 1 )
ORDER BY E2_XCONTRA,E2_LINDIG
    ENDSQL

// GetLastQuery() -- Debugar query executada pelo BeginSql

    dbSelectArea(__cAlias)
    dbGotop()

    If (__cAlias)->(Eof())
        Aviso("Atenção","Não existem titulos de mesmo contrato disponiveis para aglutinação.",{"Ok"})
        Return
    Endif

    nRecs := Contar(__cAlias,"!Eof()")

    oProcess:SetRegua1(nRecs)

    dbSelectArea(__cAlias)
    dbGotop()
    While (__cAlias)->(!Eof())

        __cNumFatu := ""
        __cNumCont := (__cALias)->E2_XCONTRA
        __cNaturez := (__cALias)->E2_NATUREZ
        __dCompIni := FirstDay(StoD((__cALias)->E2_EMISSAO))
        __dCompFim := LastDay(StoD((__cALias)->E2_EMISSAO))
        __Forneced := (__cALias)->E2_FORNECE
        __FornecLj := (__cALias)->E2_LOJA
        __TipoTitu := (__cALias)->E2_TIPO
        __cLindigi := (__cALias)->E2_LINDIG

        aFatPag := {}
        aFatGrp := {}

        aAdd(aFatPag,__cPrfxFat)			//[01] - Prefixo
        aAdd(aFatPag,"FT "     )			//[02] - Tipo
        aAdd(aFatPag,__cNumFatu)			//[03] - Numero da Fatura (se o numero estiver em branco obtem pelo FINA290)
        aAdd(aFatPag,__cNaturez)			//[04] - Natureza
        aAdd(aFatPag,__dCompIni)      		//[05] - Data de
        aAdd(aFatPag,__dCompFim)			//[06] - Data Ate
        aAdd(aFatPag,__Forneced)			//[07] - Fornecedor
        aAdd(aFatPag,__FornecLj)			//[08] - Loja
        aAdd(aFatPag,__Forneced)			//[09] - Fornecedor para geracao
        aAdd(aFatPag,__FornecLj)			//[10] - Loja do fornecedor para geracao
        aAdd(aFatPag,__cCondPag)			//[11] - Condicao de pagto
        aAdd(aFatPag,1)						//[12] - Moeda

        While (__cAlias)->(!Eof()) .And. Alltrim(__cNumCont) == Alltrim( (__cALias)->E2_XCONTRA ) .And. Alltrim(__cLindigi) == Alltrim( (__cALias)->E2_LINDIG )

            oProcess:IncRegua1("Consultando contratos lançados." )

            aAdd(aFatGrp,{})
            aAdd(aFatGrp[Len(aFatGrp)],(__cALias)->E2_PREFIXO )	//[1] Prefixo
            aAdd(aFatGrp[Len(aFatGrp)],(__cALias)->E2_NUM     )	//[2] Numero
            aAdd(aFatGrp[Len(aFatGrp)],(__cALias)->E2_PARCELA )	//[3] Parcela
            aAdd(aFatGrp[Len(aFatGrp)],(__cALias)->E2_TIPO    )	//[4] Tipo
            aAdd(aFatGrp[Len(aFatGrp)],.F.                    ) //[5] Título localizado na geracao de fatura (lógico). Iniciar com falso.
            aAdd(aFatGrp[Len(aFatGrp)],(__cALias)->E2_FORNECE ) //[6] Cod Fornecedor (E2_FORNECE) do título, deve ser igual ao informado na posição 7.
            aAdd(aFatGrp[Len(aFatGrp)],(__cALias)->E2_LOJA    ) //[7] Loja do Fornecedor do título

            (__cAlias)->(dbSkip())
        End

        If Empty(aFatGrp)
            aAdd(aFatPag,Nil)					//[13] - ARRAY com os titulos da fatura
        Else
            aAdd(aFatPag,{})					//[13] - ARRAY com os titulos da fatura
            For f:=1 To Len(aFatGrp)
                nLen13  := Len(aFatPag)
                aAdd(aFatPag[nLen13],{})
                aFatPag[nLen13][Len(aFatPag[nLen13])] := aFatGrp[f]
            Next f
        EndIf

        aAdd(aFatPag,0)				//[14] - Valor de decrescimo
        aAdd(aFatPag,0)		    	//[15] - Valor de acrescimo

        aAdd(aFatAll,aFatPag)
    End

    If lContinua

        oProcess:SetRegua2(Len(aFatAll))

        For nTitAgl := 1 To Len(aFatAll)

            oProcess:IncRegua2("Gerando Faturas Aglutinadas." )

            aFatPag :={}
            aFatPag := aClone(aFatAll[nTitAgl])

            lMsErroAuto := .F.

            MsExecAuto( { |x,y,z| FINA290(x,y,z)},3,aFatPag,)

            If lMsErroAuto
                MostraErro()
            Endif
        Next

        If Len(aFatLog)>1 .And. __lGerLog
            fGeraLog(aFatLog)
        Endif
    Endif

    oProcess:SaveLog("FIM")

Return

/*/{Protheus.doc} AjusPerg
@sample 	Criar pergunta de usuario.
@author	    Ovio Consultoria
@since		01/04/2020
@version	P12
/*/
Static Function AjusPerg(cPerg)
    Local aRegs := {}

    aAdd(aRegs,{cPerg,"01","Gerar Log        ?","","","mv_ch1","N", 01,0,0,"C","","MV_PAR01","Sim"  ,"","","","","Nao" ,"","","","","","","","","","","","","","","","","","",""   ,""})
    aAdd(aRegs,{cPerg,"02","Tela Conferencia ?","","","mv_ch2","N", 01,0,0,"C","","MV_PAR02","Sim"  ,"","","","","Nao" ,"","","","","","","","","","","","","","","","","","",""   ,""})
    aAdd(aRegs,{cPerg,"03","Data Emissao De  ?","","","mv_ch3","D", 08,0,0,"G","","MV_PAR03",""     ,"","","","",""    ,"","","","","","","","","","","","","","","","","","",""   ,""})

    CriaSx1(aRegs)

Return Nil

/*/{Protheus.doc} CriaSx1
@sample 	CriaSx1
@author	    Ovio Consultoria		
@since		01/04/2020
@version	P12
/*/
Static Function CriaSx1(aRegs)

    Local aAreaAtu	:= GetArea()
    Local aAreaSX1	:= SX1->(GetArea())
    Local nJ		:= 0
    Local nY		:= 0

    dbSelectArea("SX1")
    dbSetOrder(1)

    For nY := 1 To Len(aRegs)
        If !MsSeek(aRegs[nY,1]+aRegs[nY,2])
            RecLock("SX1",.T.)
            For nJ := 1 To FCount()
                If nJ <= Len(aRegs[nY])
                    FieldPut(nJ,aRegs[nY,nJ])
                EndIf
            Next nJ
            MsUnlock()
        EndIf
    Next nY

    RestArea(aAreaSX1)
    RestArea(aAreaAtu)

Return(Nil)

/*/{Protheus.doc}fGeraLog
@author Ovio Consultoria
@since 01/04/2020
@version P12 
@param 	
@return	
/*/ 
Static Function fGeraLog(aFaturas)
    Local cDesc1        := "Este programa tem como objetivo imprimir LOG "
    Local cDesc2        := "de afaturas geradas com base nos contratos existentes."
    Local cDesc3        := "LOG de faturas geradas."
    Local titulo        := "LOG de faturas geradas."
    Local nLin          := 80
    Local Cabec1        := ""
    Local Cabec2        := ""

    Private M_PAG		:= 0
    Private lEnd        := .F.
    Private lAbortPrint := .F.
    Private limite      := 132
    Private tamanho     := "M"
    Private nomeprog    := "LOGFINALL01"
    Private nTipo       := 18
    Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
    Private nLastKey    := 0
    Private wnrel       := "LOGFINALL01" // Coloque aqui o nome do arquivo usado para impressao em disco
    PRIVATE cPerg	  	:= ""
    Private cString		:= "SE2"

    wnrel := SetPrint(cString,NomeProg,cPerg,titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho,,.T.)

    If nLastKey == 27
        Return
    Endif

    SetDefault(aReturn,cString)

    If nLastKey == 27
        Return
    Endif

    nTipo := If(aReturn[4]==1,15,18)

    RptStatus({|| RunReport(Cabec1,Cabec2,titulo,nLin,aFaturas) },titulo)

Return

/*/{Protheus.doc}RunReport
Regras para chamada do método

@author Ovio Consultoria
@since 01/04/2020
@version P12 
@param 	
@return	
/*/ 
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,aFaturas)
    Local nFat := 1
    Local nTotal := 0
    //         1         2         3         4         5         6         7         8         9         1
    //1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
    Cabec1        := "Prefixo Titulo     Parcela  Fatura    Contrato  Vencimento Valor       Fornecedor                              "
    //FAT     123456789  001      123456789 12345     18/12/2020 999.999,99  000001/01 - UNIAO DA SANTA BARBARA DO OESTE


    SetRegua(Len(aFaturas))

    For nFat := 1 To Len(aFaturas)

        If nLin > 55
            nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
            nLin++
            nLin++
        Endif

        If lAbortPrint
            @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
            Exit
        Endif

        incRegua("Gerando log, aguarde!")

        cFatura := Alltrim(aFaturas[nFat][4])

        dbSelectArea("SE2")
        dbSetOrder(20)
        If dbSeek( xFilial("SE2") + PADR(cFatura,TamSX3("E2_FATURA")[1]) )

            While SE2->(!Eof()) .And. Alltrim(SE2->E2_FILIAL) + Alltrim(SE2->E2_FATURA) == ;
                    Alltrim(xFilial("SE2")) + Alltrim(cFatura)

                If nLin > 55
                    nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                    nLin++
                    nLin++
                Endif

                @ nLin,00  PSAY SE2->E2_PREFIXO
                @ nLin,09  Psay SE2->E2_NUM
                @ nLin,20  Psay SE2->E2_PARCELA
                @ nLin,29  PSAY SE2->E2_FATURA
                @ nLin,39  PSAY SE2->E2_XCONTRA
                @ nLin,49  PSAY SE2->E2_VENCREA
                @ nlin,60  PSAY SE2->E2_VALOR PICTURE "@E 999,999.99"
                @ nlin,72  PSAY SE2->E2_FORNECE + '/' + SE2->E2_LOJA + '-' + SE2->E2_NOMFOR

                nlin++

                SE2->(dbSkip())
            End
            @ nLin,00  PSAY aFaturas[nFat][1]
            @ nLin,09  Psay aFaturas[nFat][2]
            @ nLin,20  Psay aFaturas[nFat][3]
            @ nLin,29  PSAY aFaturas[nFat][4]
            @ nLin,39  PSAY aFaturas[nFat][5]
            @ nLin,49  PSAY aFaturas[nFat][6]
            @ nlin,60  PSAY aFaturas[nFat][7] PICTURE "@E 999,999.99"
            @ nlin,72  PSAY SE2->E2_FORNECE + '/' + SE2->E2_LOJA + '-' + SE2->E2_NOMFOR

            nTotal += aFaturas[nFat][7]

            nlin++
            @ nlin,00  PSAY Replicate("_",132)
            nlin++
            nlin++
        Endif
    Next
    nlin++
    @ nlin,00  PSAY "Total Geral:"
    @ nlin,60  PSAY nTotal PICTURE "@E 999,999.99"
    nlin++
    @ nlin,00  PSAY Replicate("_",132)
    nlin++

    SET DEVICE TO SCREEN

    If aReturn[5]==1
        dbCommitAll()
        SET PRINTER TO
        OurSpool(wnrel)
    Endif

    MS_FLUSH()

Return
