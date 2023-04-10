#Include "Totvs.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} ECOM099
@sample 	ECOM099 - Importação de Notas Fiscais de Entrada.
@author	    Ovio Consultoria		
@since		15/02/2021
@version	P12 
/*/

User Function ECOM099

    Local cMsg		:= ""
    Local cPerg		:= "ECOM099001"
    Local cProcess	:= "ECOM099"
    Local cCadastro := "Importação de Notas Fiscais de Entrada."
    Local oProcess  := Nil

    Private cArqTrb	  := GetNextAlias()
    Private _cNaturez := ""

    AjusPerg(cPerg)

    Pergunte(cPerg,.F.)

    bProcess := {|oProcess| fImpNfe(oProcess) }

    cMsg := " Esta rotina tem como objetivo realizar a importação de "+CRLF
    cMsg += "notas fiscais de entrada..."+CRLF

    oProcess := tNewProcess():New( cProcess , cCadastro , bProcess ,OemtoAnsi(cMsg), cPerg , NIL , .T. , NIL , NIL , .T. , .F. )

Return


/*/{Protheus.doc} fImpNfe
@sample 	Realiza leitura do arquivo csv para gerar notas de entrada.
@author	    Ovio Consultoria
@since		01/04/2020
@version	P12
/*/
Static Function fImpNfe(oProcess)
Local cArquivo := Alltrim(MV_PAR01)
Local lFirst   := .T.
Local aDados   := {}
Local aLayout  := {}
Local cLinAtu  := ""
Local nNotas   := 1
Local aCabec   := {}
Local aItens   := {}
Local oTmpTab  := Nil
Local aFields  := {}
Local nPos     := 0
Local aAux     := {}
Local nFld     := 1
Local aFilesImp:= {}
Local nY       := 1
Local aAutoImp :={}

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

aADD(aFields,{"ITEM"      ,  TamSX3("D1_ITEM"   )[3] , TamSx3("D1_ITEM"   )[1] , TamSX3("D1_ITEM"   )[2] })
aADD(aFields,{"COD"       ,  TamSX3("D1_COD"    )[3] , TamSx3("D1_COD"    )[1] , TamSX3("D1_COD"    )[2] })
aADD(aFields,{"QUANT"     ,  TamSX3("D1_QUANT"  )[3] , TamSx3("D1_QUANT"  )[1] , TamSX3("D1_QUANT"  )[2] })
aADD(aFields,{"VUNIT"     ,  TamSX3("D1_VUNIT"  )[3] , TamSx3("D1_VUNIT"  )[1] , TamSX3("D1_VUNIT"  )[2] })
aADD(aFields,{"TOTAL"     ,  TamSX3("D1_TOTAL"  )[3] , TamSx3("D1_TOTAL"  )[1] , TamSX3("D1_TOTAL"  )[2] })
aADD(aFields,{"TES"       ,  TamSX3("D1_TES"    )[3] , TamSx3("D1_TES"    )[1] , TamSX3("D1_TES"    )[2] })
aADD(aFields,{"CC"	      ,  TamSX3("D1_CC"	    )[3] , TamSx3("D1_CC"	  )[1] , TamSX3("D1_CC"	    )[2] })
aADD(aFields,{"ITEMCTA"   ,  TamSX3("D1_ITEMCTA")[3] , TamSx3("D1_ITEMCTA")[1] , TamSX3("D1_ITEMCTA")[2] })
aADD(aFields,{"CLVL"	  ,  TamSX3("D1_CLVL"   )[3] , TamSx3("D1_CLVL"	  )[1] , TamSX3("D1_CLVL"   )[2] })
aADD(aFields,{"TIPO"	  ,  TamSX3("D1_TIPO"   )[3] , TamSx3("D1_TIPO"	  )[1] , TamSX3("D1_TIPO"   )[2] })
aADD(aFields,{"FORMUL"    ,  TamSX3("D1_FORMUL" )[3] , TamSx3("D1_FORMUL" )[1] , TamSX3("D1_FORMUL" )[2] })
aADD(aFields,{"BASEISS"   ,  TamSX3("D1_BASEISS")[3] , TamSx3("D1_BASEISS")[1] , TamSX3("D1_BASEISS")[2] })
aADD(aFields,{"ALIQISS"   ,  TamSX3("D1_ALIQISS")[3] , TamSx3("D1_ALIQISS")[1] , TamSX3("D1_ALIQISS")[2] })
aADD(aFields,{"XHISIMP"   ,  TamSX3("D1_XHISIMP")[3] , TamSx3("D1_XHISIMP")[1] , TamSX3("D1_XHISIMP")[2] })
aADD(aFields,{"BASEIRR"   ,  TamSX3("D1_BASEIRR")[3] , TamSx3("D1_BASEIRR")[1] , TamSX3("D1_BASEIRR")[2] })
aADD(aFields,{"ALIQIRR"   ,  TamSX3("D1_ALIQIRR")[3] , TamSx3("D1_ALIQIRR")[1] , TamSX3("D1_ALIQIRR")[2] })
aADD(aFields,{"FILIAL"    ,  TamSX3("F1_FILIAL" )[3] , TamSx3("F1_FILIAL" )[1] , TamSX3("F1_FILIAL" )[2] })
aADD(aFields,{"DOC"	      ,  TamSX3("F1_DOC"	)[3] , TamSx3("F1_DOC"	  )[1] , TamSX3("F1_DOC"	)[2] })
aADD(aFields,{"SERIE"	  ,  TamSX3("F1_SERIE"  )[3] , TamSx3("F1_SERIE"  )[1] , TamSX3("F1_SERIE"  )[2] })
aADD(aFields,{"FORNECE"   ,  TamSX3("F1_FORNECE")[3] , TamSx3("F1_FORNECE")[1] , TamSX3("F1_FORNECE")[2] })
aADD(aFields,{"LOJA"	  ,  TamSX3("F1_LOJA"   )[3] , TamSx3("F1_LOJA"	  )[1] , TamSX3("F1_LOJA"   )[2] })
aADD(aFields,{"EMISSAO"   ,  TamSX3("F1_EMISSAO")[3] , TamSx3("F1_EMISSAO")[1] , TamSX3("F1_EMISSAO")[2] })
aADD(aFields,{"UF" 	      ,  TamSX3("A2_EST" 	)[3] , TamSx3("A2_EST" 	  )[1] , TamSX3("A2_EST" 	)[2] })
aADD(aFields,{"ESPECIE"   ,  TamSX3("F1_ESPECIE")[3] , TamSx3("F1_ESPECIE")[1] , TamSX3("F1_ESPECIE")[2] })
aADD(aFields,{"COND"	  ,  TamSX3("F1_COND"   )[3] , TamSx3("F1_COND"	  )[1] , TamSX3("F1_COND"   )[2] })
aADD(aFields,{"NATUREZ"   ,  TamSX3("E2_NATUREZ")[3] , TamSx3("E2_NATUREZ")[1] , TamSX3("E2_NATUREZ")[2] })
aADD(aFields,{"VENCREA"   ,  TamSX3("E2_VENCREA")[3] , TamSx3("E2_VENCREA")[1] , TamSX3("E2_VENCREA")[2] })
aADD(aFields,{"CHVNFE"    ,  TamSX3("F1_CHVNFE" )[3] , TamSx3("F1_CHVNFE" )[1] , TamSX3("F1_CHVNFE" )[2] })
aADD(aFields,{"FORMPAG"   ,  TamSX3("E2_FORMPAG")[3] , TamSx3("E2_FORMPAG")[1] , TamSX3("E2_FORMPAG")[2] }) 
aADD(aFields,{"MYFILE"    ,  'C'                     , 100                     , 0                       }) 

cFilBkp := cFilAnt

oProcess:SaveLog("INICIO")

If oTmpTab <> NIL
    oTmpTab:Delete()
    oTmpTab := NIL
EndIf

If Select(cArqTrb)>0
    dbSelectArea(cArqTrb)
    dbCloseArea()
Endif    

oTmpTab := FwTemporaryTable():New(cArqTrb)
oTmpTab:SetFields(aFields)
oTmpTab:AddIndex("01", {"FILIAL","FORNECE","LOJA","DOC","SERIE","ITEM"} )
oTmpTab:Create()

nHandle := FT_FUse(cArquivo)
If  nHandle = -1
    MsgAlert("Erro ao Abrir arquivo " + cArquivo )
    Return .F.
EndIf

FT_FGoTop()
nTotLin := FT_FLastRec()
FT_FUSE()

oProcess:SetRegua1(nTotLin)
    
oFile := FWFileReader():New(cArquivo)
oFile:SetBufferSize(4096)
If (oFile:Open())
    If ! (oFile:EoF())
        While (oFile:HasLine())
            
            cLinAtu := oFile:GetLine()
            If lFirst
                aLayout := Separa(cLinAtu,";",.T.)
                lFirst  := .F.
            Else    
                nPos := aScan(aAux,cLinAtu) 
                If nPos == 0
                    Aadd(aDados, Separa( cLinAtu,";",.T.))
                    aAdd(aAux,cLinAtu)
                Endif    
            Endif
        EndDo
    EndIf
    oFile:Close()
    oProcess:IncRegua1("Leitura do Arquivo para importação..." )
Else
    MsgStop(oFile:oErroLog:Message,"ERROR")
EndIf

aSort(aDados,,,{|x,y| x[1]+x[13] < y[1]+y[13] })

If Len(aDados)>0

      For nNotas := 1 To Len(aDados)

        //Número da Nota;Série da Nota;Data de Emissão;Espec. Docum.;Competência;Data de Vencimento;CNPJ Fornecedor;Natureza;Chave da NF-e;Forma Pagto.;Código Barras Boleto;Linha Digitável;Item;Produto;Quantidade;Tipo Entrada;Centro de Custo;Item Conta (Filial);Classe Valor (Porte);Histórico (Número do Contrato);Aliq ISS;Aliq IRRF;Valor Item
        cNumNF    := StrZero(Val(Alltrim(aDados[nNotas][1])),9)
        
        cNumSe    := Alltrim(aDados[nNotas][2])
        dDtEmi    := CTOD(aDados[nNotas][3])
        cEspec    := Alltrim(aDados[nNotas][4])
        dDtCom    := CTOD(aDados[nNotas][5])
        dDtVen    := CTOD(aDados[nNotas][6])
        cCnpjfor  := Alltrim(aDados[nNotas][7])
        
        /*
        cCnpjfor  := StrTran(cCnpjfor,".","")
        cCnpjfor  := StrTran(cCnpjfor,"/","")
        cCnpjfor  := StrTran(cCnpjfor,"-","")
        */

        _cNaturez := Alltrim(aDados[nNotas][8])
        cChaveNf  := Alltrim(aDados[nNotas][9])
        cFormaPg  := Alltrim(aDados[nNotas][10])

        cCodBarr  := Alltrim(aDados[nNotas][11])
        cLinDigi  := Alltrim(aDados[nNotas][12])
        cNumItem  := StrZero(Val(Alltrim(aDados[nNotas][13])),4)
        cProduto  := Alltrim(aDados[nNotas][14])
        nQuantid  := Val(Alltrim(aDados[nNotas][15]))
        cTES      := StrZero(Val(Alltrim(aDados[nNotas][16])),3)

        cCusto    := Alltrim(aDados[nNotas][17])
        cItemCta  := Alltrim(aDados[nNotas][18])
        cClasseV  := Alltrim(aDados[nNotas][19])

        cHistor   := Alltrim(aDados[nNotas][20])

        nAliqISS  :=  Val( StrTran(StrTran( aDados[nNotas][21] ,".",""),",",".") )
        nAliqIRR  :=  Val( StrTran(StrTran( aDados[nNotas][22] ,".",""),",",".") )
        nValorIt  :=  Val( StrTran(StrTran( aDados[nNotas][23] ,".",""),",",".") )

        __cFilial := Alltrim(aDados[nNotas][24])
        cFile     := Alltrim(aDados[nNotas][25])
        
        dbSelectArea("SA2")
        dbSetOrder(1)
        If dbSeek( xFilial("SA2") + cCnpjfor )
            Reclock(cArqTrb,.T.)
            (cArqTrb)->ITEM    := cNumItem				    
            (cArqTrb)->COD     := cProduto			    	
            (cArqTrb)->QUANT   := nQuantid			    	
            (cArqTrb)->VUNIT   := nValorIt		    		
            (cArqTrb)->TOTAL   := nQuantid*nValorIt			
            (cArqTrb)->TES     := cTES       				
            (cArqTrb)->CC	     := cCusto 					
            (cArqTrb)->ITEMCTA := cItemCta   				
            (cArqTrb)->CLVL    := cClasseV   				
            (cArqTrb)->TIPO	 := "N"            			
            (cArqTrb)->FORMUL  := "N"						
            (cArqTrb)->BASEISS := iif(nAliqISS>0,nValorIt,0) 
            (cArqTrb)->ALIQISS := nAliqISS					
            (cArqTrb)->XHISIMP := cHistor    				
            (cArqTrb)->BASEIRR := iif(nAliqIRR>0,nValorIt,0)	
            (cArqTrb)->ALIQIRR := nAliqIRR					
            (cArqTrb)->FILIAL  := __cFilial
            (cArqTrb)->DOC	 := cNumNF			  
            (cArqTrb)->SERIE   := cNumSe   	 	
            (cArqTrb)->FORNECE := SA2->A2_COD	
            (cArqTrb)->LOJA	 := SA2->A2_LOJA    
            (cArqTrb)->EMISSAO := dDtEmi        
            (cArqTrb)->UF 	 := SA2->A2_EST	  
            (cArqTrb)->TIPO	 := 'N'         	  
            (cArqTrb)->FORMUL  := ''     		
            (cArqTrb)->ESPECIE := cEspec  		
            (cArqTrb)->COND	 := '001'			  
            (cArqTrb)->NATUREZ := _cNaturez		
            (cArqTrb)->CHVNFE  := cChaveNf		
            (cArqTrb)->VENCREA := dDtVen
            (cArqTrb)->FORMPAG := cFormaPg
            (cArqTrb)->MYFILE  := cFile
            MsUnlock()
        Else
            Aviso("Atenção","Fornecedor com CNPJ "+cCnpjfor+" não localizado",{"Ok"})
        Endif                
    Next

    oProcess:SetRegua2(Len(aDados))

    nNota:=0
    dbSelectArea(cArqTrb)
    dbSetOrder(1)
    (cArqTrb)->(dbGotop())
    While (cArqTrb)->(!Eof())

        nNota++

        cFile      := ""
        aItens     := {}
        aCabec     := {}

        cFilAnt    := (cArqTrb)->FILIAL
        
        __cFilial  := (cArqTrb)->FILIAL
        __cFornece := (cArqTrb)->FORNECE
        __cLoja    := (cArqTrb)->LOJA
        __cDoc     := (cArqTrb)->DOC
        __Serie    := (cArqTrb)->SERIE
        dDtEmi     := (cArqTrb)->EMISSAO
        cUF        := (cArqTrb)->UF
        cEspecie   := (cArqTrb)->ESPECIE
        _cNaturez  := Alltrim((cArqTrb)->NATUREZ)
        cChaveNf   := (cArqTrb)->CHVNFE
        dDtVen     := (cArqTrb)->VENCREA
        cFormaPg   := (cArqTrb)->FORMPAG
        cFile      := (cArqTrb)->MYFILE   

        ddatabase  := dDtEmi

        dbSelectArea("SA2")
        dbSetOrder(1)//teste
        If dbSeek(xFilial("SA2") + Padr(__cFornece,TamSx3("A2_COD")[1]) + Padr(__cLoja,TamSx3("A2_LOJA")[1]) )

            SF1->(dbSetOrder(1)) 

            dbSelectArea("SED")
            dbSetOrder(1)
            If dbSeek(xFilial("SED")+Padr(_cNaturez,TamSx3("ED_CODIGO")[1])  )

                nItem   := 0
                nIRfBkp := SED->ED_PERCIRF
                aB1Bkp  := {}
                aAutoImp:={}
                While (cArqTrb)->(!Eof()) .And. (cArqTrb)->FILIAL+(cArqTrb)->FORNECE+(cArqTrb)->LOJA+(cArqTrb)->DOC == __cFilial + __cFornece + __cLoja + __cDoc
                    
                    nItem++

                    oProcess:IncRegua2("Gerando notas fiscais de entrada..." )        

                    dbSelectArea("SB1")
                    dbSetOrder(1)
                    if dbSeek(xFilial("SB1") + Padr((cArqTrb)->COD,TamSx3("B1_COD")[1]))

                        nPos := aScan(aB1Bkp,{|x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(SB1->B1_FILIAL)+Alltrim(SB1->B1_COD)} )
                        If nPos==0
                            aAdd(aB1Bkp,{SB1->B1_FILIAL,SB1->B1_COD,SB1->B1_ALIQISS})
                        Endif    

                        Reclock("SB1",.F.)
                        SB1->B1_ALIQISS := (cArqTrb)->ALIQISS
                        MsUnlock()

                        aItAux := {}
                        aItAux := {	{"D1_ITEM"  	,StrZero(nItem,4)   ,Nil},;
                                    {"D1_COD"   	,(cArqTrb)->COD           ,Nil},;
                                    {"D1_UM"        ,SB1->B1_UM         ,NIL},;
                                    {"D1_LOCAL"     ,"01"               ,NIL},;
                                    {"D1_QUANT" 	,(cArqTrb)->QUANT 	    ,Nil},;
                                    {"D1_VUNIT" 	,(cArqTrb)->VUNIT 	    ,Nil},;
                                    {"D1_TES"   	,(cArqTrb)->TES   	    ,Nil},;
                                    {"D1_RATEIO"    ,"2"                ,NIL},;
                                    {"D1_ITEMCTA"	,(cArqTrb)->ITEMCTA	    ,Nil},;
                                    {"D1_CC"		,(cArqTrb)->CC		    ,Nil},;
                                    {"D1_CLVL"		,(cArqTrb)->CLVL	        ,Nil},;
                                    {"D1_ALIQISS"	,(cArqTrb)->ALIQISS	    ,Nil},;
                                    {"D1_BASEISS"	,(cArqTrb)->BASEISS	    ,Nil},;
                                    {"D1_XHISIMP"	,(cArqTrb)->XHISIMP	    ,Nil},;
                                    {"D1_BASEIRR"	,(cArqTrb)->BASEIRR	    ,Nil},;
                                    {"D1_ALIQIRR"	,(cArqTrb)->ALIQIRR	    ,Nil}}


                            aAdd(aAutoImp,{"IT_ALIQISS",(cArqTrb)->ALIQISS                    ,nItem})
                            aAdd(aAutoImp,{"IT_BASEISS",(cArqTrb)->BASEISS                    ,nItem})
                            aAdd(aAutoImp,{"IT_VALISS" ,((cArqTrb)->BASEISS*(cArqTrb)->ALIQISS)/100 ,nItem})
                            aAdd(aAutoImp,{"D1_ALIQIRR",(cArqTrb)->ALIQIRR                    ,nItem})
                            aAdd(aAutoImp,{"D1_BASEIRR",(cArqTrb)->BASEIRR                    ,nItem})
                            aAdd(aAutoImp,{"D1_VALIRR" ,((cArqTrb)->BASEIRR*(cArqTrb)->BASEIRR)/100 ,nItem})


                            aAdd( aItens, aItAux)
                    Else
                        FWAlertError("O Produto "+(cArqTrb)->COD+" não existe no cadastro de produtos, verifique!")
                    Endif        
                    (cArqTrb)->(dbSkip())
                End        
                    
                aCabec := {	;
                            {"F1_TIPO"		,'N'         	,Nil},;
                            {"F1_FORMUL"	,'N'     		,Nil},;
                            {"F1_DOC"		,__cDoc			,Nil},;
                            {"F1_SERIE"		,__Serie 	    ,Nil},;
                            {"F1_EMISSAO"	,ddatabase      ,Nil},;
                            {"F1_DTDIGIT"	,ddatabase      ,Nil},;
                            {"F1_FORNECE" 	,SA2->A2_COD  	,Nil},;
                            {"F1_LOJA"		,SA2->A2_LOJA   ,Nil},;
                            {"F1_ESPECIE"	,cEspecie  		,Nil},;
                            {"F1_COND"	    ,'001'			,Nil},;
                            {"F1_DESPESA" , 0               ,NIL},;
                            {"F1_DESCONT" , 0               ,Nil},;
                            {"F1_SEGURO"  , 0               ,Nil},;
                            {"F1_FRETE"   , 0               ,Nil},;
                            {"F1_MOEDA"   , 1               ,Nil},;
                            {"F1_TXMOEDA" , 1               ,Nil},;
                            {"F1_STATUS" , "A"              ,Nil},;
                            {"F1_UF" 		,cUF        	,Nil},;
                            {"F1_CHVNFE"	,cChaveNf		,Nil}}


                lMsErroAuto := .F.
                lMsHelpAuto := .T.
   
                MSExecAuto({|a,b,c,d,e| MATA103(a,b,c,d,e)},aCabec,aItens,3,,aAutoImp)


                If lMsErroAuto
                    MostraErro()
                Else
                    
                    For nY:= 1 To Len(aB1Bkp)
                        dbSelectArea("SB1")
                        dbSetOrder(1)
                        If dbSeek( aB1Bkp[nY][1] + aB1Bkp[nY][2] )
                            Reclock("SB1",.F.)
                            SB1->B1_ALIQISS := aB1Bkp[nY][3]
                            MsUnlock()
                        Endif    
                    Next

                    dbSelectArea("SED")
                    dbSetOrder(1)
                    If dbSeek(xFilial("SED")+Padr(_cNaturez,TamSx3("ED_CODIGO")[1])  )
                        Reclock("SED",.F.)
                        SED->ED_PERCIRF := nIRfBkp
                        mSunlock()
                    Endif    
                    
                    cBanco     := ""
                    cAgencia   := ""
                    cDvAgencia := ""
                    cConta     := ""
                    cDvConta   := ""
                    cNumIdREC  := ""
                    dbSelectArea("FIL")
                    dbSetOrder(1)//FIL_FILIAL, FIL_FORNEC, FIL_LOJA, FIL_TIPO, FIL_BANCO, FIL_AGENCI, FIL_CONTA, R_E_C_N_O_, D_E_L_E_T_
                    If dbSeek(xFilial("FIL")+__cFornece+__cLoja)
                        cBanco     := FIL->FIL_BANCO 
                        cAgencia   := FIL->FIL_AGENCI
                        cDvAgencia := FIL->FIL_DVAGE 
                        cConta     := FIL->FIL_CONTA 
                        cDvConta   := FIL->FIL_DVCTA 
                        cNumIdREC  := FIL->FIL_XIDREC
                        dbSelectArea("SE2")
                        dbSetOrder(6)//E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, R_E_C_N_O_, D_E_L_E_T_
                        dbGotop()
                        If dbSeek( xFilial("SE2") + SF1->( F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC) )
                            While SE2->(!Eof()) .And. SE2->E2_FILIAL  + SF1->(F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC) == ;
                                                    xFilial("SE2")  + SE2->(E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM)
                                Reclock("SE2",.F.)
                                SE2->E2_LINDIG  := cLinDigi 
                                SE2->E2_CODBAR  := cCodBarr
                                SE2->E2_VENCTO  := DataValida(dDtVen,.T.)  
                                SE2->E2_VENCREA := DataValida(dDtVen,.T.)
                                SE2->E2_FORMPAG := cFormaPg
                                SE2->E2_DATAAGE := dDatabase 
                                SE2->E2_XCOMPET := dDtCom 
                                SE2->E2_CCUSTO  := cCusto
                                SE2->E2_ITEMCTA := cItemCta
                                SE2->E2_CLVL    := cClasseV
                                SE2->E2_XCONTRA := cHistor 
                                SE2->E2_HIST	:= cHistor  
                                SE2->E2_PORTADO:= cBanco
                                SE2->E2_FORBCO := cBanco    
                                SE2->E2_FORAGE := cAgencia  
                                SE2->E2_FAGEDV := cDvAgencia
                                SE2->E2_FORCTA := cConta    
                                SE2->E2_FCTADV := cDvConta  
                                SE2->E2_XIDRECE:= cNumIdREC
                                SE2->E2_ISS    := SF1->F1_ISS
                                MsUnLock()
                                SE2->(dbSkip())
                            End    
                        Endif    
                    Else
                        dbSelectArea("SE2")
                        dbSetOrder(6)//E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, R_E_C_N_O_, D_E_L_E_T_
                        dbGotop()
                        If dbSeek( xFilial("SE2") +  SF1->(F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC) )
                            While SE2->(!Eof()) .And. SE2->E2_FILIAL + SF1->(F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC) == ;
                                                    xFilial("SE2") + SE2->(E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM)
                                Reclock("SE2",.F.)
                                SE2->E2_ISS     := SF1->F1_ISS
                                SE2->E2_LINDIG  := cLinDigi 
                                SE2->E2_CODBAR  := cCodBarr
                                SE2->E2_VENCTO  := DataValida(dDtVen,.T.)  
                                SE2->E2_VENCREA := DataValida(dDtVen,.T.)
                                SE2->E2_FORMPAG := cFormaPg
                                SE2->E2_DATAAGE := dDatabase 
                                SE2->E2_XCOMPET := dDtCom 
                                SE2->E2_CCUSTO  := cCusto
                                SE2->E2_ITEMCTA := cItemCta
                                SE2->E2_CLVL    := cClasseV
                                SE2->E2_XCONTRA := cHistor 
                                SE2->E2_HIST	:= cHistor  
                                SE2->E2_PORTADO:= cBanco
                                MsUnLock()
                                SE2->(dbSkip())
                            End    
                        Endif    
                    Endif

                    //Incluir Documento
                    
                    If !Empty(cFile)
                        
                        afolders   := {}
                        afolders   := StrTokArr(cArquivo, "\")
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

                            cCodObj := ""
                            If !File(cDirDocs+cFile)
                                
                                lCpy := CpyT2S( cFolderImp + cFile , cDirDocs , .F. )
                                If lCpy
                                    cCodObj := ACBRetObj()

                                    dbSelectArea("ACB")
                                    dbSetOrder(1)
                                    While dbSeek( SF1->F1_FILIAL + cCodObj )
                                        cCodObj := Soma1(cCodObj,TamSx3("ACB_CODOBJ")[1])
                                    End
                                    Reclock("ACB",.T.)
                                    ACB->ACB_FILIAL := xFilial("ACB")
                                    ACB->ACB_CODOBJ := cCodObj
                                    ACB->ACB_OBJETO := cFile
                                    ACB->ACB_DESCRI := 'IMPORTAÇÃO PLANILHA'
                                    ACB->ACB_XROT   := 'ECOM099'
                                    MsUnlock()
                                Else
                                    Alert("Não foi possivel copiar o arquivo "+cFile)
                                Endif
                            Else
                                dbSelectArea("ACB")
                                dbSetOrder(2)
                                If dbSeek( SF1->F1_FILIAL + Padr(cFile,tamSx3("ACB_OBJETO")[1] ) )
                                    cCodObj := ACB->ACB_CODOBJ
                                Endif
                            Endif        
                        
                            If !Empty(cCodObj)
                                Reclock("AC9",.T.)
                                AC9->AC9_FILIAL := xFilial("AC9")
                                AC9->AC9_FILENT := SF1->F1_FILIAL
                                AC9->AC9_ENTIDA := "SF1"
                                AC9->AC9_CODENT := SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
                                AC9->AC9_CODOBJ := cCodObj
                                AC9->AC9_XROT   := 'ECOM099'
                                AC9->(MsUnlock())
                            Endif    
                        Else
                            Alert("Anexo "+cFile+" informado na planilha não existe na pasta "+cFolderImp)
                        Endif
                    Endif
                        
                Endif
            Else
                FWAlertError("A Natureza  financeira "+_cNaturez+" não existe no cadastro de naturezas, verifique!")
            Endif    
        Else
            FWAlertError("O Fornecedor "+__cFornece+" não existe no cadastro de fornecedor, verifique!")
        Endif
    End
Endif

cFilAnt := cFilBkp 
FWAlertSuccess("Importações realizadas com sucesso","Atenção")//"Wizard Configurado com sucesso!"

Return

/*/{Protheus.doc} AjusPerg
@sample 	Criar pergunta de usuario.
@author	    Ovio Consultoria
@since		01/04/2020
@version	P12
/*/
Static Function AjusPerg(cPerg)
    Local aRegs := {}

    
    aAdd(aRegs,{cPerg,"01","Caminho Arquivo .CSV" ,"","","mv_ch1","C", 99                      ,0,0,"F",""            ,"MV_PAR01","56" ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","DIR",""})

    CriaSx1(aRegs)

Return Nil

/*/{Protheus.doc} CriaSx1
@sample 	CriaSx1
@author	    Ovio Consultoria		
@since		15/02/2021
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

If Select("TRC")>0
    dbSelectArea("TRC")
    dbCloseArea()
Endif

TcQuery cQry New Alias "TRC"

TRC->(dbGotop())

Return Soma1(TRC->PROXNUM,TamSx3("ACB_CODOBJ")[1])
