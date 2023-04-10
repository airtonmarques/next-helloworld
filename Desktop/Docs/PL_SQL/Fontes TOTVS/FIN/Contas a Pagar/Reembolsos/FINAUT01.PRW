#iNCLUDE "TOTVS.CH"
#iNCLUDE "TOPCONN.CH"

/*/{Protheus.doc}'FINAUT01' 
Rotinina responsavel em gerar o contas a pagar atraves de csv
@author Ovio Consultoria
@since '01/04/2020'
@version 'P12.1.25 v.01'
@return 'Nil'
/*/ 

Function u_FINAUT01()

Local cMsg		:= ""
Local cPerg		:= "FINAUT0001"
Local cProcess	:= "FINAUT01"
Local cCadastro := "Inclusão de Titulos a Pagar"
Local oProcess  := Nil

AjusPerg(cPerg)

Pergunte(cPerg,.F.)

bProcess := {|oProcess| fImpArq(oProcess) }
		
cMsg := " Esta rotina tem como objetivo gerar a inclusão dos  "+CRLF
cMsg += "titulos a pagar com base na planilha (CSV) informada. "+CRLF

oProcess := tNewProcess():New( cProcess , cCadastro , bProcess ,OemtoAnsi(cMsg), cPerg , NIL , .T. , NIL , NIL , .T. , .F. )

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

Static Function fImpArq(oProcess)

Local nFld     := 0 
Local nHandle  := 0
Local nRecs    := 0 
Local cArq     := Alltrim(MV_PAR01)
Local lPrim	   := .T.
Local cLinha   := ""
Local nTit     := 0 
Local nQtdNat  := 0
Local nQtCCu   := 0
Local nRat     := 0
Local nMoeda   := 1
Local nTXMoeda := 0
Local nGrvs    := 0
Local cCodFornec := ""
Local cCodLoja   := ""
Local nLidos   := 0
Local aCab      := {}
Local aAuxEz    := {}
Local aAuxEv    := {}
Local aRatEz    := {}
Local aRatEvEz  := {}
Local nVlrTit   := 0
Local nVlrRatNa := 0
Local aEmps     := FWLoadSM0( .F. , .F. )
Local aFilesImp := {}
Local nFiles    := 1
Local cCodObj   := ""
Local cDirImp   := GetMv("MV_XDIRIMP",,"\reembolsos\")
Local cCpyPlan  := ""
Local lCpyPlan  := .F.
Local cTime     := StrTran(Time(),":","")

Private aTitulos:= {}
Private aDados	:= {}
Private aCampos	:= {}
Private aCpoAu  := {}

Private lAutoErrNoFile := .T.

If !File(cArq) .Or. Upper(Substr(Alltrim(cArq),-3)) # "CSV"
	MsgStop("Arquivo não existe ou não é um arquivo CSV. Selecione um arquivo CSV válido.")
    Return
Endif


FT_FUSE(cArq)
if nHandle = -1
    Alert("Atenção","Erro ao abrir o arquivo informado.Verifique!")
    Return
endif

oProcess:SaveLog("INICIO")

nRecs := FT_FLastRec()

oProcess:SetRegua1(nRecs)

FT_FGOTOP()
While !FT_FEOF()
	
    oProcess:IncRegua1("Consultando arquivo para importação..." )

	cLinha := FT_FREADLN()
    If ";;;;;;;;;;;;;;;;;;" $ Alltrim(cLinha)
        FT_FSKIP()
        Loop
    endif    
	If lPrim
		aCampos := Separa(cLinha,";",.T.)
		lPrim   := .F.
	Else
        Aadd(aDados, Separa( cLinha,";",.T.))
	Endif
	FT_FSKIP()
End

If !CheckCab(aCampos)
    Return
Else
    For nLidos := 1 To Len(aCpoAu)
        &(aCpoAu[nLidos][3]) := aCpoAu[nLidos][4]
    Next    
Endif

//Validações antes de prosseguir
aErrCTT := {}
aErrCTD := {}
aErrCTH := {}
aErrSED := {}
aErrSA2 := {}
aErrTIT := {}
aErrEMIS:= {}
aErrVECTO:={}

aErr58  := {}
aErrSM0 := {}

cErrVECTO:=""
cErrEMIS:= ""
cErrCTT := ""
cErrCTD := ""
cErrCTH := ""
cErrSED := ""
cErrSA2 := ""
cErrTIT := ""
cErr58  := ""
cErrSM0 := ""

/*
1-Filial	
2-Prefixo	
3-Nº Titulo	
4-Tipo	
5-CNPJ/CPF	
6-ID Recebedor	
7-Data de emissão	
8-Vencimento	
9-Valor	
10-Histórico	
11-Forma Pagto	
12-Centro de custo	
13-Item conta	
14-Classe de valor	
15-Nome do arquivo	
16-Parcela	
17-Natureza	
*/
cErrfile := ''

For nTit := 1 To Len(aDados)
    
    __cFilial   := Padr( Alltrim(aDados[nTit][XVAR01]),TamSX3("E2_FILIAL" )[1])
    cPrefixo    := Padr( Alltrim(aDados[nTit][XVAR02]),TamSX3("E2_PREFIXO")[1])
    cNumero     := Padr( Alltrim(aDados[nTit][XVAR03]),TamSX3("E2_NUM"    )[1])
    cTipo       := Padr( Alltrim(aDados[nTit][XVAR04]),TamSX3("E2_TIPO"   )[1])
    cCnpjfor    := Alltrim(aDados[nTit][XVAR05])
    dDtEmissao  := CTOD(Alltrim(aDados[nTit][XVAR07]))
    dDtVencto   := CTOD(Alltrim(aDados[nTit][XVAR08]))

    cCodCusto   := Padr( Alltrim(aDados[nTit][XVAR12]),TamSX3("EZ_CCUSTO" )[1])
    cCodItemc   := Padr( Alltrim(aDados[nTit][XVAR13]),TamSX3("EZ_ITEMCTA")[1])
    cCodClass   := Padr( Alltrim(aDados[nTit][XVAR14]),TamSX3("EZ_CLVL"   )[1])
    __cParc     := Padr( Alltrim(aDados[nTit][XVAR16]),TamSX3("E2_PARCELA")[1]) 
    cCodNatur   := Padr( Alltrim(aDados[nTit][XVAR17]),TamSX3("E2_NATUREZ" )[1])
    __cFile     := Alltrim(aDados[nTit][XVAR15])
    
    
    cCnpjfor    := StrTran(cCnpjfor,".","")
    cCnpjfor    := StrTran(cCnpjfor,"/","")
    cCnpjfor    := StrTran(cCnpjfor,"-","")

    cFormPag    := Alltrim(aDados[nTit][XVAR11])

    
    If Len(__cFile)>TamSx3("ACB_OBJETO")[1]
    
        cErrfile += __cFile + chr(10)+chr(13)

    Endif
    
    
    nPos := aScan( aEmps,{ |x| Alltrim(x[2]) == Alltrim(__cFilial)  } )
    If nPos==0
        cErrSM0 += __cFilial + chr(13) + chr(10)
        aAdd(aErrSM0 , __cFilial )
    Endif
    
    If !Empty(cCnpjfor)
        dbSelectArea("SA2")
        dbSetOrder(3)
        if !dbSeek( xFilial("SA2") + Padr(cCnpjfor,TamSX3("A2_CGC")[1]) )
            if aScan(aErrSA2, cCnpjfor )==0
                cErrSA2 += cCnpjfor + chr(13) + chr(10)
                aAdd(aErrSA2 , cCnpjfor)
            endif 
        Else
            
            cCodFornec := SA2->A2_COD
            cCodLoja   := SA2->A2_LOJA 
            
            aDados[nTit][XVAR05] := cCnpjfor

            If Empty(cCodNatur)
                If Empty(SA2->A2_NATUREZ)
                    cErrSED += "Fornecedor " +SA2->A2_COD+"/"+SA2->A2_LOJA+" sem natureza cadastrada." + chr(13) + chr(10)
                    aAdd(aErrSED , cCodNatur)
                Else
                    aDados[nTit][XVAR17]:=Alltrim(SA2->A2_NATUREZ)
                Endif
            Endif    
        endif    
    Else
        cErrSA2 += "CNPJ do fornecedor não preenchido." + chr(13) + chr(10)
        aAdd(aErrSA2 , cCnpjfor)
    Endif

    If Valtype(dDtEmissao)<>"D"
        cErrEMIS += "Data Emissão Invalida na linha: "+Alltrim(Str(nTit))
        aAdd(aErrEMIS , cErrEMIS)
    Endif

    If Valtype(dDtVencto)<>"D"
        cErrVECTO += "Data Vencimento Invalida na linha: "+Alltrim(Str(nTit))
        aAdd(aErrVECTO , cErrVECTO)
    Endif
        
    If !Empty(cCodNatur)
        dbSelectArea("SED")
        dbSetOrder(1)
        if !dbSeek( xFilial("SED") + cCodNatur )
            if aScan(aErrSED, cCodNatur)==0
                cErrSED += cCodNatur + chr(13) + chr(10)
                aAdd(aErrSED , cCodNatur)
            endif    
        endif
    Endif    

    If !Empty(cFormPag)
        dbSelectArea("SX5")
        dbSetOrder(1)
        If !dbSeek(xFilial("SX5")+"58"+Padr(cFormPag,TamSx3("X5_CHAVE")[1]))
            cErr58 += cFormPag + chr(13) + chr(10)
            aAdd(aErr58 , cFormPag )
        Endif
    Endif    
    
    If !Empty(cCodCusto)
        dbSelectArea("CTT")
        dbSetOrder(1)
        if !dbSeek(xFilial("CTT") + cCodCusto )
            if aScan(aErrCTT, cCodCusto)==0
                cErrCTT += cCodCusto + chr(13) + chr(10)
                aAdd(aErrCTT , cCodCusto )
            Endif    
        endif
    Endif    

    iF !Empty(cCodItemc)
        dbSelectArea("CTD")
        dbSetOrder(1)
        if !dbSeek(xFilial("CTD") + cCodItemc )
            if aScan(aErrCTD, cCodItemc)==0
                cErrCTD += cCodItemc + chr(13) + chr(10)
                aAdd(aErrCTD , cCodItemc )
            endif    
        endif
    Endif    
    
    If !Empty(cCodClass)
        dbSelectArea("CTH")
        dbSetOrder(1)
        if !dbSeek(xFilial("CTH") + cCodClass )
            if aScan(aErrCTH, cCodClass)==0
                cErrCTH += cCodClass + chr(13) + chr(10)
                aAdd(aErrCTH , cCodClass )
            endif    
        endif
    Endif    

    dbSelectArea("SE2")
    dbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
    if dbSeek( __cFilial + cPrefixo + cNumero + __cParc + cTipo + cCodFornec + cCodLoja )
        if aScan(aErrTIT, __cFilial + cPrefixo + cNumero + __cParc + cTipo + cCodFornec + cCodLoja)==0
            
            cErrTIT +=  "Prefixo: "+cPrefixo +" Numero: "+cNumero+" Parcela: "+__cParc +" Tipo: "+cTipo +" Fornecedor: "+cCodFornec+" Loja: "+cCodLoja + chr(13) + chr(10)
        
            aAdd( aErrTIT ,__cFilial + cPrefixo + cNumero + __cParc + cTipo + cCodFornec + cCodLoja )
        endif    
    endif

Next

cMsgErr := ""

if !empty(cErrSM0)
    cMsgErr += "Código de Filial invalido: "+chr(13)+chr(10)
    cMsgErr += cErrSM0 + chr(13)+chr(10)
endif

if !empty(cErrEMIS)
    cMsgErr += "Tipo de dado invalido: "+chr(13)+chr(10)
    cMsgErr += cErrEMIS + chr(13)+chr(10)
endif

if !empty(cErrVECTO)
    cMsgErr += "Tipo de dado invalido: "+chr(13)+chr(10)
    cMsgErr += cErrVECTO + chr(13)+chr(10)
endif

if !empty(cErrCTT)
    cMsgErr += "Centros de Custos informado e não encontrado: "+chr(13)+chr(10)
    cMsgErr += cErrCTT + chr(13)+chr(10)
endif
 
if !Empty(cErrCTD)
    cMsgErr += "Itens Contabeis informado e não encontrado: "+chr(13)+chr(10)
    cMsgErr += cErrCTD + chr(13)+chr(10)
endif

if !Empty(cErrCTH)
    cMsgErr += "Classe Valor informado e não encontrado: "+chr(13)+chr(10)
    cMsgErr += cErrCTH + chr(13)+chr(10)
Endif

If !EMpty(cErrSED)
    cMsgErr += "Naturezas informado e não encontrado: "+chr(13)+chr(10)
    cMsgErr += cErrSED + chr(13)+chr(10)
Endif

if !Empty(cErrSA2)
    cMsgErr += "Fornecedores informado e não encontrado: "+chr(13)+chr(10)
    cMsgErr += cErrSA2 + chr(13)+chr(10)
endif

if !Empty(cErrTIT)
    cMsgErr += "Titulos ja existentes: "+chr(13)+chr(10)
    cMsgErr += cErrTIT + chr(13)+chr(10)
endif

if !Empty(cErr58)
    cMsgErr += "Forma de Pagamento não encontrada: "+chr(13)+chr(10)
    cMsgErr += cErr58 + chr(13)+chr(10)
endif

If !Empty(cMsgErr)
    Aviso("Divergencias Encontradas",cMsgErr, {"Ok"} )
    Return
Endif

If !Empty(cErrfile)
    Aviso("Atenção"," O Nome dos anexos estão maior que o permitido, tamanho maximo de "+Alltrim(Str(TamSx3("ACB_OBJETO")[1]))+" caracteres."+chr(10)+chr(13) +''+chr(10+chr(13) + cErrfile ))
    Return
Endif

For nTit := 1 To Len(aDados)

    cCnpjfor   := Alltrim(aDados[nTit][XVAR05])
    cNatureza  := Alltrim(aDados[nTit][XVAR17])
    aNaturezas := {}
    aCentroCus := {}
    
    If Empty(cNatureza)
        dbSelectArea("SA2")
        dbSetOrder(3)
        dbGotop()
        If dbSeek(xFilial("SA2") + Padr(cCnpjfor,TamSx3("A2_CGC")[1]) )
            cNatureza := Alltrim(SA2->A2_NATUREZ)
            If Empty(cNatureza)
                cMsg := "Natureza financeira não informada e não preenchida no cadastro de fornecedor: " + SA2->A2_COD + "/"+ SA2->A2_LOJA+" - "+ Alltrim(SA2->A2_NOME)+chr(13)+chr(10)
                cMsg += "Registro não sera importado"
                Alert( cMsg )
                Loop
            Endif
        Endif
    Endif

    nPosTit := aScan( aTitulos,{ |x| Alltrim(x[1]) +;  //Filial
                                     Alltrim(x[2]) +;  //Prefixo
                                     Alltrim(x[3]) +;  //Titulo
                                     Alltrim(x[4]) +;  //Parcela//excluir
                                     Alltrim(x[5]) +;  //Tipo 
                                     Alltrim(x[7]) ==; //CNPJ Fornecedor
                                                 Alltrim(aDados[nTit][XVAR01])  + ; //Filial
                                                 Alltrim(aDados[nTit][XVAR02])  + ; //Prefixo
                                                 Alltrim(aDados[nTit][XVAR03])  + ; //Titulo
                                                 Alltrim(aDados[nTit][XVAR16])  + ; //Parcela
                                                 Alltrim(aDados[nTit][XVAR04])  + ; //Tipo
                                                 Alltrim(cCnpjfor)               }) //CNPJ Fornecedor
                                                  
    If nPosTit==0
        Aadd( aTitulos, {;
                        Alltrim(aDados[nTit][XVAR01])   ,; //01-Filial'
                        Alltrim(aDados[nTit][XVAR02])   ,; //02-Prefixo'
                        Alltrim(aDados[nTit][XVAR03])   ,; //03-Titulo'
                        Alltrim(aDados[nTit][XVAR16])   ,; //04-Parcela'
                        Alltrim(aDados[nTit][XVAR04])   ,; //05-Tipo'
                        Alltrim(cNatureza)              ,; //06-Natureza
                        Alltrim(cCnpjfor)               ,; //07-CNPJ Fornecedor'
                        Alltrim(aDados[nTit][XVAR10])   ,; //08-Historico'
                        {}                              ,; //09-Vetor com Naturezas + Vetor com Centros de Custos 
                        Alltrim(aDados[nTit][XVAR07])   ,; //10-Emissao
                        Alltrim(aDados[nTit][XVAR08])   ,; //11-Vencimento
                        "0"                             ,; //12-Moeda
                        Alltrim(aDados[nTit][XVAR11])   ,; //13-Forma de Pagamento
                        Alltrim(aDados[nTit][XVAR06])   ,; //14-ID RECEBEDOR
                        "0"                             ,; //15-Taxa Moeda
                        Alltrim(aDados[nTit][XVAR15])})    //16-Nome do Arquivo



        If !Empty(Alltrim(cNatureza))//Natureza
                    //                           Natureza                        Valor                 
            aAdd( aTitulos[Len(aTitulos)][9] , { Alltrim(cNatureza) , Alltrim(aDados[nTit][XVAR09]), {} })
            If !Empty(Alltrim(aDados[nTit][XVAR12]))//Centro de custo
                        //                                                             //  Centro de custo	           item conta                      //classe valor                  //valor                              	
                aAdd( aTitulos[Len(aTitulos)][9][Len(aTitulos[len(atitulos),9])][3], { Alltrim(aDados[nTit][XVAR12]) , Alltrim(aDados[nTit][XVAR13]) , Alltrim(aDados[nTit][XVAR14]) , Alltrim(aDados[nTit][XVAR09])})
            Endif
        Endif    
    Else                                          
        nPosNat := aScan(aTitulos[nPosTit][9],{|x| Alltrim(x[1])== Alltrim(cNatureza) })//natureza
        If nPosNat == 0 
                                            //natureza                         //valor
            aAdd( aTitulos[nPosTit][9] , { Alltrim(cNatureza) , Alltrim(aDados[nTit][XVAR09]), {} })

            If !Empty(Alltrim(aDados[nTit][12]))//centro de custo
                                                                            //centro de custo               //item contabil                 //classe valor                  //valor                
                aAdd( aTitulos[nPosTit][9][Len(aTitulos[nPosTit][9])][3], { Alltrim(aDados[nTit][XVAR12]) , Alltrim(aDados[nTit][XVAR13]) , Alltrim(aDados[nTit][XVAR14]) , Alltrim(aDados[nTit][XVAR09])})
            Endif
        Else                   
                                                                                    //centro de custo
            nPosCus := aScan(aTitulos[nPosTit][9][nPosNat][3],{|x| Alltrim(x[1])== Alltrim(aDados[nTit][XVAR12]) })
            if nPosCus==0
                                                            //Centro de Custo               //intem contabil               //classe valor                   //valor                     
                aAdd( aTitulos[nPosTit][9][nPosNat][3] , { Alltrim(aDados[nTit][XVAR12]) , Alltrim(aDados[nTit][XVAR13]) , Alltrim(aDados[nTit][XVAR14]) , Alltrim(aDados[nTit][XVAR09]) })
            endif
        Endif    
    Endif
Next

FT_FUSE()

oProcess:SetRegua2( Len(aTitulos) )

__cLote := GetSXENum("ZT5","ZT5_LOTE")

cFilBkp := cFilAnt

For nTit := 1 To Len(aTitulos)

    aCab      := {}
    aAuxEz    := {}
    aAuxEv    := {}
    aRatEz    := {}
    aRatEvEz  := {}
    nVlrTit   := 0
    nVlrRatNa := 0
    
    cFilAnt   := aTitulos[nTit][1]  
    cNatureza := aTitulos[nTit][6]
    cFile     := Alltrim(aTitulos[nTit][16])

    oProcess:IncRegua2("Incluindo titulos, aguarde...")

    If Empty(aTitulos[nTit][3])
        Loop
    Endif    
    
    aCab     := {}
    aAuxEv   := {}
    aAuxEz   := {}
    aRatEz   := {}
    aRatEvEz := {}
    nVlrTit  := 0

    nMoeda   := Val( aTitulos[nTit][14] ) 
    nTXMoeda := Val( StrTran(StrTran( aTitulos[nTit][15],".",""),",",".") )  

    dbSelectArea("SA2")
    dbSetOrder(3)
    If dbSeek(xFilial("SA2") + Padr(Alltrim(aTitulos[nTit][7]),TamSx3("A2_CGC")[1]) )

        aadd( aCab ,{"E2_FILIAL"    , aTitulos[nTit][1]         , Nil })            
        aadd( aCab ,{"E2_PREFIXO"   , aTitulos[nTit][2]         , Nil })            
        aadd( aCab ,{"E2_NUM"       , aTitulos[nTit][3]         , Nil })
        aadd( aCab ,{"E2_PARCELA"   , aTitulos[nTit][4]         , Nil })
        aadd( aCab ,{"E2_TIPO"      , aTitulos[nTit][5]         , Nil })
        aadd( aCab ,{"E2_NATUREZ"   , cNatureza                 , Nil })
        aadd( aCab ,{"E2_FORNECE"   , SA2->A2_COD               , Nil })
        aadd( aCab ,{"E2_LOJA"      , SA2->A2_LOJA              , Nil })
        aadd( aCab ,{"E2_EMISSAO"   , CTOD(aTitulos[nTit][10])  , Nil })
        aadd( aCab ,{"E2_VENCTO"    , CTOD(aTitulos[nTit][11])  , Nil }) 
        aadd( aCab ,{"E2_HIST"      , aTitulos[nTit][8]         , Nil }) 
        aadd( aCab ,{"E2_FORMPAG"   , aTitulos[nTit][13]        , Nil }) 
        aadd( aCab ,{"E2_VALOR"     , nVlrTit                   , Nil })
        aadd( aCab ,{"E2_MULTNAT"   , '1'                       , Nil })
        aadd( aCab ,{"E2_CCUSTO"    , Alltrim(aTitulos[nTit][9][1][3][1][1]), Nil }) 
        aadd( aCab ,{"E2_ITEMCTA"   , Alltrim(aTitulos[nTit][9][1][3][1][2]), Nil }) 
        aadd( aCab ,{"E2_CLVL"      , Alltrim(aTitulos[nTit][9][1][3][1][3]), Nil }) 
        
        if nMoeda>0
            aadd( aCab ,{"E2_MOEDA"     , nMoeda                , Nil })
        endif    
        
        if nTXMoeda>0
            aadd( aCab ,{"E2_TXMOEDA"   , nTXMoeda              , Nil })
        endif    

        For nQtdNat := 1 To Len(aTitulos[nTit][9])
            
            nVlrRat   := Val( StrTran(StrTran( aTitulos[nTit][9][nQtdNat][2],".",""),",",".") ) 
            nVlrRatNa := 0

            aAuxEz  := {}
            aRatEz  := {}
            aAuxEv  := {}
            
            aadd( aAuxEv ,{"EV_NATUREZ" , aTitulos[nTit][9][nQtdNat][1]  , Nil })
            aadd( aAuxEv ,{"EV_VALOR"   , nVlrRat            , Nil })
            aadd( aAuxEv ,{"EV_PERC"    , "50"              , Nil })
                
            If Len(aTitulos[nTit][9][nQtdNat][3]) >= 1
                aadd( aAuxEv ,{"EV_RATEICC" , "1"            , Nil })
            Else
                aadd( aAuxEv ,{"EV_RATEICC" , "2"            , Nil })
            Endif    

            For nQtCCu := 1 To Len(aTitulos[nTit][9][nQtdNat][3])
                    
                aAuxEz:={}
                
                cCodCusto := Padr( Alltrim(aTitulos[nTit][9][nQtdNat][3][nQtCCu][1]),TamSX3("EZ_CCUSTO")[1])
                cCodItemc := Padr( Alltrim(aTitulos[nTit][9][nQtdNat][3][nQtCCu][2]),TamSX3("EZ_ITEMCTA")[1])
                cCodClass := Padr( Alltrim(aTitulos[nTit][9][nQtdNat][3][nQtCCu][3]),TamSX3("EZ_CLVL")[1])

                nVlrRatei := Val( StrTran(StrTran( aTitulos[nTit][9][nQtdNat][3][nQtCCu][4] ,".",""),",",".") )
                nVlrRatNa += Val( StrTran(StrTran( aTitulos[nTit][9][nQtdNat][3][nQtCCu][4] ,".",""),",",".") )

                aAdd( aAuxEz ,{"EZ_CCUSTO" ,cCodCusto , Nil })
                aAdd( aAuxEz ,{"EZ_VALOR"  ,nVlrRatei , Nil })
                aAdd( aAuxEz ,{"EZ_ITEMCTA",cCodItemc , Nil })
                aAdd( aAuxEz ,{"EZ_CLVL"   ,cCodClass , Nil })				   

                aadd(aRatEz,aAuxEz)
            Next
            
            If Len(aRatEz)>0
                aadd(aAuxEv,{"AUTRATEICC" , aRatEz, Nil })
                aAuxEv[ aScan(aAuxEv,{|X| Alltrim(x[1])== "EV_VALOR" }) ][2] := nVlrRatNa
            Endif    
        
            aAdd(aRatEvEz,aAuxEv)    
        Next    
        
        For nRat := 1 To Len(aRatEvEz)
            nVlrTit += aRatEvEz[nRat][2][2]
        Next

        For nRat := 1 To Len(aRatEvEz)
            nPerc := (aRatEvEz[nRat][2][2]/nVlrTit)*100
            aRatEvEz[nRat][3][2] := Alltrim(Str(nPerc))
        Next

        aCab[aScan(aCab,{|x| Alltrim(x[1])=="E2_VALOR" })][2]  := nVlrTit 

        aAdd(aCab,{"AUTRATEEV",ARatEvEz,Nil}) 

        lMsErroAuto := .F.

        MsExecAuto( { |x,y,z| FINA050(x,y,z)} , aCab, ,3)
        
        cFilAnt := cFilBkp
        
        Reclock("ZT5",.T.)
        ZT5->ZT5_FILIAL := aTitulos[nTit][1]
        ZT5->ZT5_FILORI := aTitulos[nTit][1]
        ZT5->ZT5_PREFIX := aTitulos[nTit][2]
        ZT5->ZT5_NUM    := aTitulos[nTit][3]
        ZT5->ZT5_PARCEL := aTitulos[nTit][4]
        ZT5->ZT5_TIPO   := aTitulos[nTit][5] 
        ZT5->ZT5_FORNEC := SA2->A2_COD
        ZT5->ZT5_LOJA   := SA2->A2_LOJA
        ZT5->ZT5_NATURE := cNatureza
        ZT5->ZT5_NOMFOR := SA2->A2_NOME
        ZT5->ZT5_EMISSA := CTOD(aTitulos[nTit][10])
        ZT5->ZT5_VENCTO := CTOD(aTitulos[nTit][11])
        ZT5->ZT5_VENCRE := CTOD(aTitulos[nTit][11])
        ZT5->ZT5_VALOR  := nVlrTit
        ZT5->ZT5_HIST   := aTitulos[nTit][8]
        ZT5->ZT5_CC     := Alltrim(aTitulos[nTit][9][1][3][1][1])
        ZT5->ZT5_ITEM   := Alltrim(aTitulos[nTit][9][1][3][1][2])
        ZT5->ZT5_CLVLD  := Alltrim(aTitulos[nTit][9][1][3][1][3])
        ZT5->ZT5_IDREC  := Upper(Substr(aTitulos[nTit][14],1,1))
        ZT5->ZT5_FORMPA := aTitulos[nTit][13]
        ZT5->ZT5_CGC    := aTitulos[nTit][7]
        ZT5->ZT5_LOTE   := __cLote 
        ZT5->ZT5_ANEXO  := cFile
        ZT5->ZT5_PLAN   := cArq
        ZT5->ZT5_TIME   := cTime
        MsUnlock()

    
        If lMsErroAuto
            cDetalhe:=""
            aLogs   :={} 
            aEval(GetAutoGrLog(), {|x| aAdd(aLogs,x)  })
            cDetalhe+= StrTran(aLogs[1],chr(13)+chr(10),"")
            nPosErr := ASCAN(aLogs, { |x| "INVALIDO" $ UPPER(x)   }) 
            If nPosErr>0
                cDetalhe+= StrTran(aLogs[nPosErr],chr(13)+chr(10),"")
            Endif    
            cDetalhe := Alltrim(NoAcento(cDetalhe))
            Alert(cDetalhe)
            Reclock("ZT5",.F.)
            ZT5->ZT5_LOG    := cDetalhe
            ZT5->ZT5_STATUS := "0"
            MsUnlock()
        Else
            ConfirmSx8()

            nGrvs++    
            
            Reclock("ZT5",.F.)
            ZT5->ZT5_STATUS := "1"
            MsUnlock()
            
            cIDREC := aTitulos[nTit][14]
            If Upper(Alltrim(cIDREC))=="SIM"
                cBanco     := ""
                cAgencia   := ""
                cDvAgencia := ""
                cConta     := ""
                cDvConta   := ""
                cNumIdREC  := ""
                dbSelectArea("FIL")
                dbSetOrder(1)//FIL_FILIAL, FIL_FORNEC, FIL_LOJA, FIL_TIPO, FIL_BANCO, FIL_AGENCI, FIL_CONTA, R_E_C_N_O_, D_E_L_E_T_
                If dbSeek(xFilial("FIL")+SE2->E2_FORNECE+SE2->E2_LOJA)
                    While FIL->(!Eof()) .And. xFilial("FIL")+SE2->E2_FORNECE+SE2->E2_LOJA==;
                                            FIL->FIL_FILIAL+FIL->FIL_FORNEC+FIL_LOJA 
                        If !Empty(FIL->FIL_XIDREC)
                            cBanco     := FIL->FIL_BANCO 
                            cAgencia   := FIL->FIL_AGENCI
                            cDvAgencia := FIL->FIL_DVAGE 
                            cConta     := FIL->FIL_CONTA 
                            cDvConta   := FIL->FIL_DVCTA 
                            cNumIdREC  := FIL->FIL_XIDREC
                        Endif
                        FIL->(DBsKIP())
                    End    
                    Reclock("SE2",.F.)
                    SE2->E2_PORTADO:= cBanco
                    SE2->E2_FORMPAG:= cFormPag
                    SE2->E2_FORBCO := cBanco    
                    SE2->E2_FORAGE := cAgencia  
                    SE2->E2_FAGEDV := cDvAgencia
                    SE2->E2_FORCTA := cConta    
                    SE2->E2_FCTADV := cDvConta  
                    SE2->E2_XIDRECE:= cNumIdREC
                    MsUnLock()
                Endif    
            Endif
            
            If !Empty(cFile)
                afolders   := {}
                afolders   := StrTokArr(cArq, "\")
                cFileImp   := Alltrim(afolders[Len(afolders)])
                cFolderImp := ""   
                
                For nFld := 1 To Len(afolders)
                    If Alltrim(afolders[nFld]) <> Alltrim(cFileImp)
                        cFolderImp += Alltrim(Lower(afolders[nFld]))+"\"
                    Endif    
                Next
                
                cDirDocs := Alltrim(Lower(GetNewPar("MV_DIRDOC" , "\dirdoc" ))) 
                if Substr(cDirDocs,Len(cDirDocs),1)=="\"
                    cDirDocs := Substr(cDirDocs,1,Len(cDirDocs)-1)
                endif
                
                cDirDocs += "\co"+Alltrim(cEmpAnt)+"\shared\"
                
                If File(cFolderImp+cFile)
                    
                    If aScan(aFilesImp , cFolderImp + cFile )==0
                        aAdd(aFilesImp , cFolderImp + cFile )
                    Endif

                    If !File(cDirDocs+cFile)
                        
                        lCpy := CpyT2S( cFolderImp + cFile , cDirDocs , .F. )
                        If lCpy
                            cCodObj := ACBRetObj()

                            dbSelectArea("ACB")
                            dbSetOrder(1)
                            While dbSeek( SE2->E2_FILIAL + cCodObj )
                                cCodObj := Soma1(cCodObj,TamSx3("ACB_CODOBJ")[1])
                            End
                            Reclock("ACB",.T.)
                            ACB->ACB_FILIAL := SE2->E2_FILIAL
                            ACB->ACB_CODOBJ := cCodObj
                            ACB->ACB_OBJETO := cFile
                            ACB->ACB_DESCRI := 'IMPORTAÇÃO PLANILHA'
                            ACB->ACB_XROT   := 'REEMBOLSO'
                            MsUnlock()
                        Else
                            Alert("Não foi possivel copiar o arquivo "+cFile)
                        Endif
                    Else
                        dbSelectArea("ACB")
                        dbSetOrder(2)
                        If dbSeek( SE2->E2_FILIAL + Padr(cFile,tamSx3("ACB_OBJETO")[1] ) )
                            cCodObj := ACB->ACB_CODOBJ
                        Endif
                    Endif        
                
                    If !Empty(cCodObj)
                        DbSelectArea("SE2")
                        SE2->(DbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
                        __cChave := SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM)
                        If SE2->(DbSeek(__cChave))
                            While Alltrim(__cChave) == Alltrim(SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM))
                                Reclock("AC9",.T.)
                                AC9->AC9_FILIAL := SE2->E2_FILIAL
                                AC9->AC9_FILENT := SE2->E2_FILIAL
                                AC9->AC9_ENTIDA := "SE2"
                                AC9->AC9_CODENT := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
                                AC9->AC9_CODOBJ := cCodObj
                                AC9->AC9_XROT   := 'REEMBOLSO'
                                AC9->(MsUnlock())
                                SE2->(DbSkip())
                            End
                        Endif
                    Endif    
                Else
                    Alert("Anexo "+cFile+" informado na planilha não existe na pasta "+cFolderImp)
                Endif
            Endif    
        Endif
    Else
        Aviso("Atenção","Fornecedor com CNPJ/CPF " + Alltrim(aTitulos[nTit][7]) + " não localizado no cadastro de fornecedor, verifique.",{"Ok"})
    Endif    
Next   

//Importar os arquivos
For nFiles := 1 To Len(aFilesImp)
    
    cFile := aFilesImp[nFiles]

    If !Empty(cFile)
        fRename( cFile , cFile+".imp" )
    Endif

Next    

Aviso("Atenção","Foram importados "+Alltrim(Str(nGrvs))+" titulos.",{"Ok"} )

If nGrvs > 0

    If !File(cDirImp+cArq)

        cCpyPlan := cDirImp + __cLote + '_' + cTime + '_' + cFile

        lCpyPlan := CpyT2S( cArq , cCpyPlan , .F. )

        If lCpyPlan
            Aviso("Atenção","gerado cópia do arquivo importado "+Alltrim(cArq)+" para a pasta "+cCpyPlan,{"Ok"},3)
        Endif

    Endif

Endif

oProcess:SaveLog("FIM")	

Return

/*/{Protheus.doc}'ACBRetObj' 
Rotinina responsavel em anexar o arquivo no banco de conhecimento
@author Ovio Consultoria
@since '01/04/2020'
@version 'P12.1.25 v.01'
@return 'Nil'
/*/ 

Static Function ACBRetObj()
Local cQry := ""

cQry := "SELECT MAX(ACB_CODOBJ) AS PROXNUM FROM "+RetSqlName("ACB")+" ACB WHERE D_E_L_E_T_= ' ' "

If Select("TRB")>0
    dbSelectArea("TRB")
    dbCloseArea()
Endif

TcQuery cQry New Alias "TRB"

TRB->(dbGotop())

Return Soma1(TRB->PROXNUM,TamSx3("ACB_CODOBJ")[1])

/*/{Protheus.doc} AjusPerg
@sample 	Criar pergunta de usuario.
@author	    Ovio Consultoria
@since		01/04/2020
@version	P12
/*/
Static Function AjusPerg(cPerg)
Local aRegs := {}

aAdd(aRegs,{cPerg,"01","Caminho Arquivo .CSV","Caminho Arquivo .CSV","Caminho Arquivo .CSV","MV_CH0","C",99,0,0,"F","","MV_PAR01","56","","","","","" ,"","","","","","","","","","","","","","","","","","","DIR",""})

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

/*/{Protheus.doc} FINAUT03
//Exportar layout
@author Ovio Consultoria
@since 14/05/2021
@version undefined
@return return, return_description
/*/
Static Function CheckCab(aCampos)
	Local cCabec := "Filial;Prefixo;Nº Titulo;Tipo;CNPJ/CPF;ID Recebedor;Data de emissão;Vencimento;Valor;Histórico;Forma Pagto;Centro de custo;Item conta;Classe de valor;Nome do arquivo;Parcela;Natureza"
    Local aCabec := Separa(cCabec,";",.T.)
    Local nPos   := 0
    Local cMsg1   := ""
    Local lRet   := .T.
    Local nLidos := 1 

    For nLidos := 1 To Len(aCabec)
        aAdd(aCpoAu,{Lower(Alltrim(aCabec[nLidos])),nLidos,'XVAR'+StrZero(nLidos,2),0})
    Next
    
    For nLidos := 1 To Len(aCpoAu)
        nPos := aScan( aCampos ,{|x| Lower(Alltrim(x))==Lower(Alltrim(aCpoAu[nLidos][1])) })
        If nPos==0
            cMsg1 += Lower(Alltrim(aCpoAu[nLidos][1]))+" "+chr(13)+chr(10)
        Else
            aCpoAu[nLidos][4] := nPos
        Endif
    Next

    If !Empty(cMsg1)
        Alert("As Colunas a seguir não foram encontradas no arquivo, Verifique!"+chr(13)+chr(10)+cMsg1)
        lRet   := .F.
    Endif

Return lRet
