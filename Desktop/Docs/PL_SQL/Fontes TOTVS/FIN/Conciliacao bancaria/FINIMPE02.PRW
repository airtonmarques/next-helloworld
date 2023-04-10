#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"
/*/{Protheus.doc} FINIMPE2
//Função responsável pela leitura 
@author edvf8
@since 22/11/2019
@version undefined
@return return, return_description
/*/
User Function FINIMPE2()
Local cPerg			:= "ZT1FINIMPO"
Local lContinua		:= .F.
Local lREt			:= .T.
Private cArq		:= ""
Private cCodLay		:= ""
Private cCodBco		:= ""
Private cCodCont	:= ""
Private cCodAge		:= ""

While Empty(cArq) 
	lContinua := Pergunte(cPerg,.T.)
	cArq	:= UPPER(MV_PAR01)
	cCodLay	:= MV_PAR02
	cCodBco	:= MV_PAR03
	cCodCont:= MV_PAR04
	cCodAge	:= MV_PAR05
	If Right(Alltrim(cArq),4) != ".XML" 
		Help("",1,"Help","Help","Salve o arquivo de extrato em xml(excel) e selecione o arquivo xml.",1,0)
		cArq:= ""
	EndIf
EndDo
If lContinua
	MsgRun("Processando o Arquivo Selecionado","Aguarde",{|| fProc()})
EndIf
Return lRet

/*/{Protheus.doc} fProc
//Funçao de Processamento
@author edvf8
@since 19/12/2019
@version undefined
@return return, return_description
/*/
Static Function fProc()
Local cDirPos		:= "" //DIRETÓRIO PÓS PROCESSAMENTO, PARA GRAVAR O ARQUIVO PROCESSADO
Local lREt			:= .T.
Local oDdsMovBanc	:= nil
Local aArea 		:= GetArea()
Local aArExAuto		:= {}
Local nX			:= 0
Local nOp			:= 3
Local aCredit		:= {}
Local aDebit		:= {}
Local cDirPend		:= ""
Local cServer		:= ""
Local cFiltGRL		:= ""
Local cFilt			:= ""
Local aFilttOp		:= {"==","!=","<","<=",">",">=","$",'NOT$','$-',"!EMPTY","EMPTY"," "}
Private cTpNeg		:= '2'
Private aDdsArq		:= {}
Private nCredito	:= 0
Private nDebito		:= 0
Private cCarSep		:= ""
Private cChaveMarca	:= ""

cChaveMarca:= Alltrim(cCodLay)+"_"+DTOC(date())+"_"+ time()
 
dbSelectArea("ZT0")
ZT0->(DBSETORDER(1))
If ZT0->(DBSEEK(xFilial("ZT0")+cCodLay))
	cDirPos		:= ZT0->ZT0_DIRPOS
	cLinIni		:= ZT0->ZT0_CARSEP
	nCredito	:= Val(ZT0->ZT0_COLCRE)
	nDebito		:= Val(ZT0->ZT0_COLDEB) 
	cCarSep		:= ZT0->ZT0_CARSEP
	cTpNeg		:= ZT0->ZT0_TPNEG
EndIf

oDdsMovBanc	:= fCargDds(cArq,cDirPos,@cDirPend,@cServer)
aDdsArq		:= XmlToArray(oDdsMovBanc,Val(cLinIni))
fFormtNum(@aDdsArq)
fAjtArray(@aCredit,@aDebit,aDdsArq)

cFiltGrl	:= fFiltro(cCodLay,aFilttOp)
//Foi separado o processamento, justamente para compartilhar o lógica do 
//execauto, com o processamento divido 
If Empty(cFiltGrl)
	cFiltGrl:= ".T."
EndIF
For nX:=1	To Len(aCredit)
	cFilt	:=	cFiltGRL
	cFilt	:= 	fTratForm(Alltrim(cFilt),aCredit[nX])

	If &cFilt			
		aArExAuto	:= fTrtArrAuto(aCredit[nX],"C",aFilttOp)
		fExAutoSE5(aArExAuto,4)
		aArExAuto	:= {}
	EndIf
Next nX

For nX:=1	To Len(aDebit)
	cFilt	:=	cFiltGRL
	
	cFilt	:= 	iif(cFilt != '.T.', fTratForm(Alltrim(cFilt),aDebit[nX]) ,".T.")
	If &cFilt 		
		aArExAuto	:= fTrtArrAuto(aDebit[nX],"D",aFilttOp)
		fExAutoSE5(aArExAuto,3)
		aArExAuto	:= {}
	EndIf
Next nX	
RestArea(aArea)
fMvArqProc(cArq,cDirPend,cDirPos,cServer)
Return(lRet)


/*/{Protheus.doc} fCargDds	
//TODO Descrição auto-gerada.
@author CODVS E.V.F. SISTEMAS
@since 27/07/2019
@param cLcArq, characters, localização do arquivo a ser importado.
@return oDdsAtiv,object, objeto xml com dados a serem importados
/*/
Static Function fCargDds(cLcArq,cLDirPos,cDirPend,cServerDir)

Local oDdsMovBanc	:= NIL
Local oSheetNode	:= NIL

Local cArqName		:= Substr(cLcArq,rat("\",cLcArq),Len(cLcArq))

Local lPCLCAL		:= .T.
Local cError		:= ""
Local cWarning		:= ""
Local aAtt			:=  {}
Local lRet			:= .T.

cDirPend	:= "\Mov.Bancaria\Arq.Pendente"
cServerDir	:= "\Mov.Bancaria"
lPCLCAL := At(":",Substr(cLcArq,1,4)) > 0

/*
COMO A FUNÇÃO XMLPARSERFILE POR PADRÃO, BUSCA DADOS DIRETAMENTE DA PASTA PROTHEUS_DATA, 
É NECESSÁRIO QUE O ARQUIVO A SER IMPORTADO, SEJA TRANSFERIO PARA UM DIRETÓRIO DENTRO DA 
MESMA, FAÇO A VERIFICAÇÃO DA EXISTÊNCIA DO DIRETÓRIO E CRIO CASO O MESMO NÃO EXISTA.
*/
If !ExistDir(cServerDir)
	MakeDir( cServerDir /*, [ uParam2 ], [ lChangeCase ]*/ )
EndIf

If left(cLDirPos,1) != "\"
	cLDirPos:= "\"+cLDirPos
EndIf
If !Empty(cLDirPos) .And. !ExistDir(cServerDir+cLDirPos) 
	MakeDir( cServerDir+cLDirPos /*, [ uParam2 ], [ lChangeCase ]*/ )
EndIf

If !ExistDir(cDirPend) 
	MakeDir( cDirPend /*, [ uParam2 ], [ lChangeCase ]*/ )
EndIf
/*
CASO O ARQUIVO ESTEJA NA MÁQUINA DO CLIENTE, FAÇO A MOVIMENTAÇÃO DO 
MESMO PARA DENTRO DA PROTHEUS_DATA. 
 */
If lPCLCAL
	CpyT2S( cLcArq, cDirPend, .F. )
EndIf
/*
REALIZA O PARSE DO XML MOVIDO PARA DENTRO DA PASTA PROTHEUS_DATA
*/
If lRet
	oDdsMovBanc := XmlParserFile( cDirPend+cArqName, "_", @cError, @cWarning )
EndIf

If !Empty(cError)
	Help(NIL, NIL, "Importacao", NIL, cError, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Ocorreu um erro na transferencia do arquivo selecionado para a pasta do servidor, verifique se o arquivo se encontra no diretório de origem selecionado na tela anterior."})
EndIf 

Return oDdsMovBanc

/*
================================================================================
BLOCO ABAIXO RESPONSÁVEL PELO ACIONAMENTO DA ROTINA AUTOMÁTICA ATFA010, GERANDO
ATIVO FIXO IMOBILIZADO
================================================================================
*/
/*/{Protheus.doc} fSN1SN3Mnt
//TODO Descrição auto-gerada.
@author edvf8
@since 05/08/2019
@version undefined
@return return, return_description
@param oXML, object, descricao
@type function
/*/
Static Function XmlToArray(oXML,nLinIni)
Local lRet			:= .T.
Local nCSheet		:= 0
Local nCCells		:= 0
Local nCRows		:= 0
Local nColsTab		:= 0
Local aCells		:= {}
Local aRows			:= {}
Local aLinArq		:= {}
Local lCarrega		:= .T.
DEFAULT oXML		:= NIL
DEFAULT nLinIni		:= 1

If oXML != NIL
	aRows	:= oXML:_WORKBOOK:_WORKSHEET:_TABLE:_ROW
	nColsTab:= Val(oXMl:_WORKBOOK:_WORKSHEET:_TABLE:_SS_EXPANDEDCOLUMNCOUNT:TEXT)
	For nCRows:= nLinIni To Len(aRows) 
		If XmlChildEx(aRows[nCRows], "_CELL") != NIL
			If ValType(aRows[nCRows]:_CELL)== "A" .And. len(aRows[nCRows]:_CELL) == nColsTab 
				For nCCells	:= 1 To Len(aRows[nCRows]:_CELL)
					If XmlChildEx(aRows[nCRows]:_CELL[nCCells], "_DATA") != NIL
						aAdd(aCells,aRows[nCRows]:_CELL[nCCells]:_DATA:TEXT)
					EndIf 
				Next nCCells
				If len(aCells) > 0
					aAdd(aLinArq,aClone(aCells))
				EndIf
			EndIf
			aCells:= {}
		EndIf
	Next nCRows
EndIf

Return aLinArq

/*/{Protheus.doc} fTrtArrAuto
//Carrega os dados de array , para execauto
@author edvf8
@since 17/12/2019
@return return, return_description
@param aDdsEx, array, descricao
@param nOpc, numeric, descricao
/*/
Static Function fTrtArrAuto(aDdsEx,cOpc,aFilttOp)
Local lRet		:= .T.
Local cRegra	:= ""
Local aDdAuto	:= {}

Default aDdsEx	:= {}
Default cOpc	:= "C"

dbSelectArea("ZT1")
dbSelectArea("ZT4")
ZT1->(dbSetOrder(1))
ZT4->(dbSetOrder(1))
ZT4->(DBGOTOP())
ZT1->(DBGOTOP())
If ZT1->(dbSeek(ZT0->ZT0_FILIAL+Alltrim(cCodLay)))
	While !ZT1->(eof()) .And. (ZT0->ZT0_FILIAL+Alltrim(cCodLay) == ZT1->ZT1_FILIAL+Alltrim(ZT1->ZT1_CODPAR))
		If ZT4->(dbSeek(ZT1->ZT1_FILIAL+ZT1->ZT1_CODPAR+ZT1->ZT1_CPODIC))
			While !ZT4->(EOF()) .AND.  (ZT4->ZT4_FILIAL+ZT4->ZT4_CODPAR+ZT4->ZT4_CAMPO == ZT1->ZT1_FILIAL+ZT1->ZT1_CODPAR+ZT1->ZT1_CPODIC)
				cRegra	:= fMntMacro(ZT4->ZT4_COLUNA,ZT4->ZT4_EXPRES,IIF(EMPTY(ZT4->ZT4_OPERAD),'',aFilttOp[VAL(ZT4->ZT4_OPERAD)]) )
				If ZT4->ZT4_COLUNA <> 0
					cRegra	:= fTratForm(Alltrim(cRegra),aDdsEx)
				Else
					cRegra	:= "" 
				EndIf
				If  &cRegra .And. !Empty(ZT4->ZT4_OPERAD)
					aAdd(aDdAuto,{ZT1->ZT1_CPODIC,;
							fPgValor(aDdsEx,ZT1->ZT1_TPDADO,fRegra(ZT1->ZT1_CPODIC,cRegra,cOpc,ZT4->ZT4_COLUNA,ZT4->ZT4_VLRCPO),ZT4->ZT4_COLUNA,ZT4->ZT4_VLRCPO),;
							NIL})
				ElseIf Empty(ZT4->ZT4_OPERAD) .And. ZT4->ZT4_COLUNA > 0
					aAdd(aDdAuto,{ZT1->ZT1_CPODIC,;
							fPgValor(aDdsEx,ZT1->ZT1_TPDADO,fRegra(ZT1->ZT1_CPODIC,,cOpc,ZT4->ZT4_COLUNA,ZT4->ZT4_VLRCPO),ZT4->ZT4_COLUNA,ZT4->ZT4_VLRCPO),;
							NIL})					
							
				ElseIf 	ZT4->ZT4_COLUNA == 0				
						aAdd(aDdAuto,{ZT1->ZT1_CPODIC,;
							fPgValor(aDdsEx,ZT1->ZT1_TPDADO,fRegra(ZT1->ZT1_CPODIC,,cOpc,ZT4->ZT4_COLUNA,ZT4->ZT4_VLRCPO),ZT4->ZT4_COLUNA,ZT4->ZT4_VLRCPO),;
							NIL})	
				EndIf
				ZT4->(dbSkip())
			EndDo
			
		EndIf
		ZT1->(dbSkip())
	EndDo 
EndIf
Return aDdAuto
/*/{Protheus.doc} fPgValor
//Função responsável por pegar os dados reais do array
@author edvf8
@since 27/11/2019
@version undefined
@return return, return_description
@param aDdsEx, array, descricao
@param cTpDado, characters, descricao
@param cRegra, characters, descricao
@param cCol, characters, descricao
/*/
Static Function fPgValor(aDdsEx,cTpDado,cRegra,nCol,cVlr)
Local xVal		:= NIL

Default aDdsEx	:= {}
Default cTpDado	:= ""
Default cRegra	:= "" 
Default nCol	:= 0
Default cVlr	:= ""
	If Len(aDdsEx)	>	0
		
		If Empty(cRegra) .And. nCol > 0
			xVal	:= fVldTpDado(cTpDado,aDdsEx[nCol])
		EndIf
		If !Empty(cRegra) .And. nCol > 0
			cRegra:= fTratForm(Alltrim(cRegra),aDdsEx)
			xVal:= fVldTpDado(cTpDado,iif(&(cRegra),cVlr,"") )
		EndIf
		If  nCol == 0
			If At("[",cRegra) > 0
				cRegra:= fTratForm(Alltrim(cRegra),aDdsEx)
			EndIf
			xVal	:= fVldTpDado(cTpDado,IIF(Empty(cVlr),cRegra,cVlr))
		EndIf
	EndIf

Return xVal 
/*/{Protheus.doc} fVldTpDado
//Função responsável pela Conversão de dados de acordo com o tipo de dado
@author edvf8
@since 27/11/2019
@version undefined
@return return, return_description
@param cDado, characters, descricao
@param cVlrs, characters, descricao
/*/
Static Function fVldTpDado(cDado,cVlrs)
Local xValConv	:= NIL

Default cVlrs	:= ""
Default cDado	:= ""
	
	Do Case                              
		Case cDado = "C" 
			xValConv	:= StrTran(cVlrs,"'","")
		Case cDado = "N"
			xValConv	:= Val(StrTran(StrTran(cVlrs,",","."),"'",""))
		Case cDado = "D"
			If Empty(CTOD(Left(StrTran(StrTran(StrTran(cVlrs,"-",""),"/",""),"\",""),8) ))
				xValConv	:=  STOD(Left(StrTran(StrTran(StrTran(cVlrs,"-",""),"/",""),"\",""),8) )
			Else
				xValConv	:=  CTOD(Left(StrTran(StrTran(StrTran(cVlrs,"-",""),"/",""),"\",""),8) )
			EndIf
				If xValConv == STOD('20191224')
					conout("")
				EndIf
	EndCase

Return xValConv

/*/{Protheus.doc} fExAutoSE5
//Função responsável pelo acionamento do execauto
@author edvf8
@since 27/11/2019
@version undefined
@return return, return_description
@param aArSx5, array, descricao
/*/
Static Function fExAutoSE5(aArSx5,nOpc)
Local lRet		:= .T.
Local aFina100	:= {}
Local aErros	:= []
Local nX		:= 0 
Local cMsgErro	:= ""
Default  aArSx5	:= {}
Default	 nOpc	:= 3
Private lMsHelpAuto 	:= .T. //Variavel de controle interno do ExecAuto
Private lMsErroAuto 	:= .F. //Variavel que informa a ocorrência de erros no ExecAuto
Private lAutoErrNoFile 	:= .T.

If Len(aArSx5) > 0 

	aFINA100 := Aclone(aArSx5)
	MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,nOpc)
	If lMsErroAuto
		
		aErros := GetAutoGRLog()
		For nX := 1 To Len(aErros)
			cMsgErro += aErros[nX] + CRLF
		Next
		lRet := .F.
		
	EndIf
	fGrvHist(cMsgErro)
EndIf

Return lRet

/*/{Protheus.doc} fTratErro
//TODO Descrição auto-gerada.
@author edvf8
@since 05/08/2019
@version undefined
@param aLogAuto, array, descricao
/*/
Static Function fTratErro(aLogAuto)
Local nY	:= 0
Local nLin	:= 0

Local cAux1	:= ""
Local cAux2	:= ""
Local cLErro:= ""

nLin:= mlcount(aLogAuto)

For ny:=1 to nLin
	cAux1 += Alltrim(memoline(aLogAuto,40,ny)) + " "
	cAux2 += Alltrim(memoline(aLogAuto,,ny)) + " "
Next

clErro	:= cAux1 + cAux2 

Return clErro

/*/{Protheus.doc} fLogImp
//Rotina de Log de processamento.
@author edvf8
@since 05/08/2019
@return return, return_description
@param oPanel, object, descricao
@param oFont1, object, descricao
@param oFont2, object, descricao
/*/
Static Function fLogImp(oPanel, oFont1,oFont2,cTpExp)
Local cTxtIntro     := ""
Local lRet			:= .T.
Local cTitulo		:= "Selecione o diretório:"
Local cExt			:= ""
Local lDir			:= .F.	   
Local oBtnArq := TButton():New( 100, 010, "Local do Arquivo" ,oPanel,{|| lRet:=  fDire ( @cTpExp,cTitulo,cExt,.F. ,GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY)} , 70,20,,,.F.,.T.,.F.,,.F.,,,.F. ) 

cTxtIntro   := "A importação foi realizada e caso desejar baixar o log para melhor analisá-lo."  + CRLF
cTxtIntro   += "Escolha abaixo o local de destino:"+CRLF

oSay1:= TSay():New(05,10,{||"LOG"},oPanel,,oFont1,,,,.T.,,,200,20)

oSay2:= TSay():New(030,10,{||cTxtIntro},oPanel,,oFont2,,,,.T.,,,300,100)
Return .T.

/*/{Protheus.doc} fCopyArq
//Rotina de cópia do arquivo de log, para o diretório de escolha do usuário
@author CODVS EVF SISTEMAS
@since 07/08/2019
@return return, return_description
@param cTpExp, characters, descricao
/*/
Static Function fCopyArq(cTpExp)
Local lRet		:= .T.
Local nLog		:= 0
Local cTexto	:= ""
Local cArq  	:= ""
Local nHandle	:= ""

If !Empty(cTpExp)
	cArq  	:= IIF(Substr(cTpExp,len(cTpExp)-1,len(cTpExp))=="\","","\")+DtoS(dDataBase) + Strtran(Time(), ":") + ".log"
	nHandle	:= FCreate(cTpExp + cArq)
	
	For nLog:= 1 to Len(aLog)
		FWrite(nHandle, aLog[nLog]	+ CRLF)
	Next nLog
	
	FClose(nHandle)
	lRet := .T.
Else
	Help(NIL, NIL, "Exportação", NIL, "Diretório não selecionado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe o diretório para que arquivo de log seja exportado."})
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} fTratForm
//Trata Informação do campo de regra quando se trata do tipo Formulas
@author edvf8
@since 17/12/2019
@version undefined
@return return, return_description
@param cRegra, characters, descricao
@param aDdsEx, array, descricao
/*/
Static Function fTratForm(cRegra,aDdsEx)
Loca lFormat	:= .T.
Local nPosAr	:= 0 
Local nAtAbre	:= 0
Local nAtFecha	:= 0
Local cSubt		:= ""
Default cRegra	:= ""
Default aDdsEx	:= {}

While lFormat
	nAtAbre	:= at("[",cRegra)
	nAtFecha:= at("]",cRegra)
	If nAtAbre > 0 .And. nAtFecha > 0
		nPos	:= Val(SubStr(cRegra,nAtAbre+1,nAtFecha-nAtAbre-1))
		cSubt	:= SubStr(cRegra,nAtAbre,nAtFecha-nAtAbre+1)
		cRegra 	:= StrTran(cRegra,cSubt,"'"+aDdsEx[nPos]+"'") 
	Else
		lFormat := .F.
	EndIf
EndDo


Return cRegra
/*/{Protheus.doc} fFormtNum
//Rotina pra tratar os dados negativos.
@author edvf8
@since 17/12/2019
@version undefined
@param aDdsArq, array, descricao
/*/
Static Function fFormtNum(aDdsArq)
Local nX	:= 0

For nX:= 1 to Len(aDdsArq)
	If cTpNeg == '1'
		aDdsArq[nX][nDebito]	:= StrTran(StrTran(Alltrim(aDdsArq[nX][nDebito])," ",""),"  ","")
	ElseIf  cTpNeg == '2'
		aDdsArq[nX][nDebito]	:= "-" + StrTran(StrTran(Alltrim(UPPER(aDdsArq[nX][nDebito])),"D",""),"D","") 
	Else
		
	EndIf
Next nX

Return .T.

Static Function fRegra(cCampo,cRegra,cOpc,nCol,cVlr)
Local cRegNova	:= ""
Default cRegra 	:= ""
Default nCol	:= 0
Default cVlr	:= ""

If ALLTRIM(cCampo) == "E5_BANCO" .And. Empty(cRegra) .And. nCol == 0 .And. cVlr == ''
	cRegNova	:= cCodBco
EndIf

If ALLTRIM(cCampo) == "E5_AGENCIA" .And. Empty(cRegra)  .And. nCol == 0 .And. cVlr == ''
	cRegNova	:= cCodCont
EndIf

If ALLTRIM(cCampo) == "E5_CONTA" .And. Empty(cRegra)  .And. nCol == 0 .And. cVlr == ''
	cRegNova	:= cCodAge
EndIf
If Empty(cRegNova)
	cRegNova	:= cRegra 
EndIf
If ALLTRIM(cCampo) == "E5_VALOR" .And. Empty(cRegra)
	If cOpc == "C"
		cRegNova	:=  "["+Alltrim(Str(nCredito)) +"]"
	Else
		cRegNova	:=  "["+Alltrim(Str(nDebito))+"]" 
	EndIf
EndIf
Return cRegNova
/*/{Protheus.doc} fGrvHist
//Função que realiza a gravação do histórico
@author edvf8
@since 19/12/2019
@param cMsgErro, characters, Mensagem de Erro
/*/
Static Function fGrvHist(cMsgErro)

Default cMsgErro:= ""
	
	dbSelectArea("ZT3")
	ZT3->(dbSetOrder(1))//ZT3_FILIAL+ZT3_CODPAR+ZT3_ARQUIV
	RecLock("ZT3",.T.)
		ZT3->ZT3_FILIAL	:= xFILIAL("ZT3") 
		ZT3->ZT3_ID		:= GETSX8NUM("ZT3","ZT3_ID")
		ZT3->ZT3_CODPAR := cCodLay	
		ZT3->ZT3_ARQUIV	:= SubStr(cArq,Rat("\",cArq)+1,Len(cArq))
		ZT3->ZT3_IDMOVI	:= SE5->E5_IDMOVI
		ZT3->ZT3_IDORIG	:= SE5->E5_IDORIG
		ZT3->ZT3_OBSERV :=  cMsgErro
		ZT3->ZT3_STATUS	:= If(Empty(cMsgErro),"1","0")
		ZT3->ZT3_CHAVEI	:= cChaveMarca
	ZT3->(MsUnlock())
Return .T.
/*/{Protheus.doc} fAjtArray
//Função que separa débito do crédito
@author edvf8
@since 19/12/2019
@version undefined
@return return, return_description
@param aCredit, array, descricao
@param aDebit, array, descricao
@param aDados, array, descricao
/*/
Static Function fAjtArray(aCredit,aDebit,aDados)
Local lRet		:= .T.
Local nX		:= 0
Default aCredit	:= {}
Default aDebit	:= {}
//nCredito
//nDebito	
For nX:= 1 to Len(aDados)
	If nCredito == nDebito
		If Val(StrTran(aDados[nX][nCredito],",",".")) > 0
			aAdd(aCredit	, aClone(aDados[nX]))
		Else 
			aDados[nX][nCredito]:= Alltrim(StrTran(aDados[nX][nCredito],"-",""))  
  			aAdd(aDebit		, aClone(aDados[nX]))
  		EndIf 
	Else
		If  !Empty(aDados[nX][nCredito])
			aAdd(aCredit	, aClone( aDados[nX] ))
		Else
		 	aDados[nX][nDebito]:= Alltrim(StrTran(aDados[nX][nCredito],"-",""))
			aAdd(aDebit		, aClone(aDados[nX]))
		EndIf
	EndIf
Next Nx

Return lRet
/*/{Protheus.doc} fMvArqProc
//Move arquivo após o processamento..
@author edvf8
@since 19/12/2019
@version undefined
@return return, return_description
@param cArq, characters, descricao
@param cDirPend, characters, descricao
@param cDirPos, characters, descricao
@param cServer, characters, descricao
/*/
Static Function fMvArqProc(cArq,cDirPend,cDirPos,cServer)
	fErase(cDirPend+"\" + SubStr(cArq,Rat("\",cArq)+1,Len(cArq)))
	CpyT2S(  cArq ,cServer+ALLTRIM(Lower(cDirPos)), .F. ,.T.)
Return .T.
/*/{Protheus.doc} fFiltro
//Função de interpretação de filtro
@author edvf8
@since 27/12/2019
@version undefined
@return return, return_description
@param cCodLay, characters, descricao
/*/
Static Function fFiltro(cCodLay,aFilttOp)
Local cFiltro	:= ""

Default aFilttOp:= {}
Default cCodLay	:= ""
dbSelectArea("ZT2")
ZT2->(dbSetOrder(1))

If ZT2->(dbSeek(xFilial("ZT2")+cCodLay))
	While  !ZT2->(EOF()) .And. ZT2->ZT2_FILIAL+ZT2->ZT2_CODPAR == Alltrim(xFilial("ZT2")+cCodLay)
		If Empty(cFiltro)
			cFiltro	:= fMntMacro(ZT2->ZT2_COLFIL,ZT2->ZT2_INFFIL,aFilttOp[VAL(ZT2->ZT2_OPFILT)])
		Else
			cFiltro	+= fMntMacro(ZT2->ZT2_COLFIL,ZT2->ZT2_INFFIL,aFilttOp[VAL(ZT2->ZT2_OPFILT)],1)
		EndIf
		ZT2->(DBSKIP())
	EndDo
EndIf
Return cFiltro
/*/{Protheus.doc} fMntMacro
//Função de conversão de filtros para correta interpretação de macros.
@author edvf8
@since 27/12/2019
@version undefined
@return return, return_description
@param nCol, numeric, descricao
@param cValor, characters, descricao
@param cOp, characters, descricao
@param nConc, numeric, descricao
/*/
Static Function fMntMacro(nCol,cValor,cOp,nConc,cVlr)
Local cVlrFV		:= ""

Default nCol	:= 0
Default cValor	:= ""
Default cOp		:= ""
Default nConc	:= 0
Default cVlr	:= ""

If Empty(cOp)
	cVlrFV	:= "["+ALLTRIM(STR(nCol))+"]==["+ALLTRIM(STR(nCol))+"]"   
EndIf
cValor := Alltrim(cValor)
If !Empty(cOp)
	Do Case                              
		Case cOp $ '==,!=,<,<=,>,>='
		
			cVlrFV	:=  "["+ALLTRIM(STR(nCol))+"] " +  cOp + " '" + cValor + "'"  		

		Case "$" $ cOp
			If cOp == '$-'
				cVlrFV	:= "["+ALLTRIM(STR(nCol))+"] $ '" + cValor + "' "
			ElseIf cOp == "$"
				cVlrFV	:= "'"   + cValor + "' $ ["+ALLTRIM(STR(nCol))+"] "
			Else
				cVlrFV	:= "!( '" + cValor + "' $ ["+ALLTRIM(STR(nCol))+"]) "
			EndIf
		
		Case "EMPTY" $ cOp 
			cVlrFV	:= cOp + "("+"["+ALLTRIM(STR(nCol))+"]"+")"
	EndCase
	
EndIf
If nConc > 0
	cVlrFV:= ' .Or. ' + cVlrFV 
EndIf
Return cVlrFV