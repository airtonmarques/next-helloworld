#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"

STATIC lProc	:= .F.
User Function FINIMPE1()
//Private aRotina   := MenuDef()
Local cCadastro := OemToAnsi("Cadastro de Layout")
Local oBrowse

If AliasIndic('ZT0')	
	
	dbSelectArea("ZT0")
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZT0")
	
	oBrowse:SetDescription(cCadastro)
	oBrowse:Activate()

Else
	Alert('Dicionário está desatualizado, por favor verifique atualização das tabelas.' + CRLF + "ZT0 - Layout de Importação - Não encontrada.")	
EndIF

Return(Nil)

/*/{Protheus.doc} MenuDef
//TODO Definição dos itens de menu disponiveis no mvc.
@author CODVS E.V.F. SISTEMAS
@since 25/08/2019
/*/
Static Function MenuDef()

Local aRotina := {}

aAdd( aRotina, { 'Visualizar'	, 'VIEWDEF.FINIMPE1', 0, 2, 0, NIL } ) 
aAdd( aRotina, { 'Incluir'   	, 'VIEWDEF.FINIMPE1', 0, 3, 0, NIL } )
aAdd( aRotina, { 'Alterar'   	, 'VIEWDEF.FINIMPE1', 0, 4, 0, NIL } )
aAdd( aRotina, { 'Excluir'   	, 'VIEWDEF.FINIMPE1', 0, 5, 0, NIL } )
aAdd( aRotina, { 'Imprimir'  	, 'VIEWDEF.FINIMPE1', 0, 8, 0, NIL } )
aAdd( aRotina, { 'Imp. Extrato' , 'U_FINIMPE2()'	 , 0, 4, 0, NIL } )
aAdd( aRotina, { 'Copiar'    	, 'VIEWDEF.FINIMPE1', 0, 9, 0, NIL } ) 

	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
//TODO Define o modelo da rotina
@author CODVS E.V.F. SISTEMAS
@since 25/08/2019
@version undefined
@return return, return_description
/*/
Static Function ModelDef()

Local oModel
Local oStructZT0 		:= FWFormStruct( 1 , "ZT0")
Local oStructZT1		:= FwFormStruct( 1 , "ZT1")
Local oStructZT2		:= FwFormStruct( 1 , "ZT2")
Local oStructZT4		:= FwFormStruct( 1 , "ZT4")

oModel:= MPFormModel():New('FINIM01M',/*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/)    
oModel:AddFields( "MODEL_ZT0" ,, oStructZT0 , /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:AddGrid("MODEL_ZT1","MODEL_ZT0",oStructZT1 , /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid("MODEL_ZT2","MODEL_ZT0",oStructZT2 , /*bPreValidacao*/,  /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid("MODEL_ZT4","MODEL_ZT1",oStructZT4 , /*bPreValidacao*/,/*bPosValidacao*/, /*bCarga*/ )

//oModel:SetRelation('MODEL_ZT0',{{'ZT0_FILIAL','XFilial("ZT0")'},{'ZT0_CODPAR','ZT1_CODPAR'}},ZT0->(IndexKey(1)))
oModel:SetRelation('MODEL_ZT1',{{'ZT1_FILIAL','xFilial("ZT1")'},{'ZT1_CODPAR','ZT0_CODPAR'}},ZT1->(IndexKey(1)))
oModel:SetRelation('MODEL_ZT2',{{'ZT2_FILIAL','xFilial("ZT2")'},{'ZT2_CODPAR','ZT0_CODPAR'}},ZT2->(IndexKey(1)))
oModel:SetRelation('MODEL_ZT4',{{'ZT4_FILIAL','xFilial("ZT4")'},{'ZT4_CODPAR','ZT1_CODPAR'},{'ZT4_CAMPO','ZT1_CPODIC'}},ZT4->(IndexKey(1)))

oModel:GetModel('MODEL_ZT0'):SetDescription("Cabeçalho de Layout")
oModel:GetModel('MODEL_ZT2'):SetDescription("Filtro de Dados a serem importados")
oModel:GetModel('MODEL_ZT1'):SetDescription("Cadastro de Campos")
oModel:GetModel('MODEL_ZT4'):SetDescription("Cadastro de Regras")

oModel:GetModel( 'MODEL_ZT2' ):SetOptional( .T. )

oModel:SetPrimaryKey({'ZT0_FILIAL','ZT0_CODPAR'})
oModel:GetModel("MODEL_ZT1"):SetUniqueLine({'ZT1_CPODIC'})
Return oModel 

/*/{Protheus.doc} ViewDef
//TODO FUNÇÃO PADRÃO DE MVC PARA VIEWDEF
@author CODVS E.V.F SISTEMAS
@since 25/08/2019
/*/
Static Function ViewDef()
Local oModel   		:= FWLoadModel( 'FINIMPE1' )
Local oStructZT0 	:= FWFormStruct( 2 , "ZT0")
Local oStructZT1	:= FwFormStruct( 2 , "ZT1")
Local oStructZT2	:= FwFormStruct( 2 , "ZT2")
Local oStructZT4	:= FwFormStruct( 2 , "ZT4"/*,{|x| !(Alltrim(x) $ 'ZT4_CAMPO')}*/)
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ZT0', oStructZT0, 'MODEL_ZT0' )
oView:AddGrid( 'VIEW_ZT2', oStructZT2, 'MODEL_ZT2' )
oView:AddGrid( 'VIEW_ZT1', oStructZT1, 'MODEL_ZT1' )
oView:AddGrid( 'VIEW_ZT4', oStructZT4, 'MODEL_ZT4' )


// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'CAB' , 24 )
oView:CreateHorizontalBox( 'FILTRO' , 16 )


oView:CreateHorizontalBox( 'ESTRUTURA' , 60 )

oView:CreateVerticalBox("ESQUERDA",50,"ESTRUTURA")
oView:CreateVerticalBox("DIREITA",50,"ESTRUTURA")

oView:AddIncrementField( 'VIEW_ZT1', 'ZT1_ITEM' )
oView:AddIncrementField( 'VIEW_ZT2', 'ZT2_ITEMFI' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZT0', 'CAB' )
oView:SetOwnerView( 'VIEW_ZT2', 'FILTRO' )
oView:SetOwnerView( 'VIEW_ZT1', 'ESQUERDA')
oView:SetOwnerView( 'VIEW_ZT4', 'DIREITA')

oView:SetAfterViewActivate({|oView| fPreCargaSX5(oView)})
oView:EnableTitleView( 'VIEW_ZT0' )
oView:EnableTitleView( 'VIEW_ZT1' )
oView:EnableTitleView( 'VIEW_ZT2' )
oView:EnableTitleView( 'VIEW_ZT4' )
Return oView

Static Function fPreCargaSX5(oView)
Local lRet		:= .T.
Local cALSSE5	:= "SE5"
Local oModel	:= oView:GetModel()
Local oMdlZT1	:= oModel:GetModel("MODEL_ZT1")
Local oMdlZT4	:= oModel:GetModel("MODEL_ZT4")
Local nOpc		:= oView:GetOperation()


If nOpc	==	3
	If MsgYesNo("Para facilitar o cadastro do Layout, deseja realizar o pré-carregamento dos campos obrigatórios da tabela SE5 - Movimentação Bancária?")
		oMdlZT1:Activate()
		oMdlZT4:Activate()
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek(cALSSE5)
		lProc	:= .T.
		While !SX3->( Eof() ) .And. AllTrim(SX3->X3_ARQUIVO) == AllTrim(cALSSE5)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se e obrigatorio											   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lObri := X3Obrigat(SX3->X3_CAMPO)
			If Upper(SX3->X3_CONTEXT) <> 'V' .And. !Empty(X3TITULO()) .AND. !("_FILIAL" $ SX3->X3_CAMPO) .And. (lObri .Or. ALLTRIM(SX3->X3_CAMPO) $ "E5_DATA/E5_MOEDA/E5_VALOR/E5_NATUREZ/E5_BANCO/E5_AGENCIA/E5_CONTA/E5_BENEF/E5_HISTOR/")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Estrutura de Campos													   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				If oMdlZT1:AddLine()
					oMdlZT1:SetValue('ZT1_CPODIC',SX3->X3_CAMPO)
					oMdlZT1:SetValue('ZT1_SX3TIT',X3Titulo())
					oMdlZT1:SetValue('ZT1_TPDADO',SX3->X3_TIPO)
					oMdlZT1:SetValue('ZT1_FILIAL',ZT0->ZT0_FILIAL)
					oMdlZT1:SetValue('ZT1_CODPAR',M->ZT0_CODPAR)
				EndIf
/*				If oMdlZT4:AddLine()
					oMdlZT4:SetValue('ZT4_CODPAR'	,	M->ZT0_CODPAR)
					oMdlZT4:SetValue('ZT4_FILIAL'	,	ZT0->ZT0_FILIAL)
					oMdlZT4:SetValue('ZT4_CAMPO'	,oMdlZT1:GetValue('ZT1_CPODIC'))
					oMdlZT4:SetValue('ZT4_COLUNA'	,1)
					oMdlZT4:SetValue('ZT4_EXPRES'	,'-')
					oMdlZT4:SetValue('ZT4_VLRCPO'	,'-')
				EndIf*/
			EndIf
			SX3->( DbSkip() )
		EndDo
		oMdlZT1:GoLine(1)
		oView:Refresh()
	EndIf

EndIf
lProc:= .F.
Return lRet

/*/{Protheus.doc} fSX3SE5
//Consulta especifica da SE5
@author edvf8
@since 20/11/2019
@version undefined
@return return, return_description
/*/
User Function fSX3SE5()
Local aArea			:= GetArea()
Local aAlsSX3		:= SX3->(GetArea())

Local aSX3SE5		:=	Array(0)
Local nX        	:= 0
Local oView	  	  	:= FwViewActive()             	//View ativa
Local oModel      	:= oView:GetModel()           	//Pega o modelo
Local oMdlGrid		:= oModel:GetModel("MODEL_ZT1") 
Local lRet			:= .T.
Private cContVar	:= ""
Private MvRet     	:= Alltrim(ReadVar())
Private MvPar     	:= ""
Private cTitulo   	:=''
Private MvParDef  	:= ""
Private nTam      	:= 0

	MvPar := Alltrim(&(Alltrim(ReadVar()))) //Carrega o conteudo da variavel do Get em Questao
	MvRet := Alltrim(ReadVar()) //Iguala o Nome da variavel ao Nome variavel retorno
	cAlias   := Alias()	//Salva a Area Anterior
	
	dbSelectArea("SX3")
	dbSetOrder(1)
	SX3->(dbGotop())
	SX3->(dbSeek("SE5"))
	While SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == "SE5"
		aAdd(aSX3SE5,Left(SX3->X3_CAMPO+Space(Len(SX3->X3_CAMPO)+10),10)+' - '+Alltrim(SX3->X3_TITULO))
		MvParDef 	+= SX3->X3_CAMPO
		nTam		:= 10
		SX3->(Dbskip())
	EndDo

	MvPar:= PadR(StrTran(&MvRet,";",""),Len(aSX3SE5))
	&MvRet:= PadR(StrTran(&MvRet,";",""),Len(aSX3SE5))
	If F_Opcoes(@MvPar,cTitulo,aSX3SE5,MvParDef,,,.f.,nTam,1)	//Chama a Funcao Opcoes
		&MvRet  := ''
		For nX := 1 To Len(MvPar) Step nTam
			IF ( SubStr( MvPar , nX , nTam ) # Replicate("*",nTam) )
				cContVar := SubStr( mVpar , nX , nTam )
			Endif
		Next nX
		If Empty(cContVar)
			cContVar:= Space(TamSx3("ZT1_CPODIC")[1])
		EndIf
	Endif

	&MvRet 	:= cContVar //Devolve o Resultado	

   If !Empty(cContVar)
	   	SX3->(DBSETORDER(2))
	   	SX3->(dbSeek( "ZT1_SX3TIT" ))
	   	VAR_IXB	:= &MvRet 
		oMdlGrid:SetValue('ZT1_CPODIC',cContVar)
		oMdlGrid:SetValue('ZT1_SX3TIT',X3Titulo())
		oMdlGrid:SetValue('ZT1_TPDADO',SX3->X3_TIPO)
		oView:Refresh()
		lRet:= .T.
	Else
		lRet:= .F. 
		VAR_IXB	:=	""		
	EndIf
RestArea(aAlsSX3)
RestArea(aArea)
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fDire
Escolhe o local do Arquivo
@author  CODVS E.V.F. SISTEMAS
@since   19/12/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
User Function fDire (cLocal,cTitulo,cExt,lSalvar,cDir,lDir)
Local lRet  := .T.
Private cContVar	:= ""
Private MvRet     	:= Alltrim(ReadVar())

Default cLocal      := ""
Default cTitulo		:= "Selecione o Arquivo .xml a ser importado"
Default cExt		:= "xml|*.xml "
Default lSalvar		:= .F.
Default cDir		:= GETF_LOCALHARD

cLocal:= cGetFile(cExt,cTitulo,1,,lSalvar  ) 

//=====================
//VALIDAÇÃO DO ARQUIVO|
//=====================
If cDir	== GETF_LOCALHARD
	lRet:= fValidArq(cLocal)
EndIf
If lRet
	&MvRet 	:= cLocal //Devolve o Resultado
	VAR_IXB	:= &MvRet	
EndIF
Return (lRet)

/*/{Protheus.doc} fValidArq
Rotina de Validação de arquivo, nomenclatura, existência de arquivo.
@type  Function
@author CODVS E.V.F. SISTEMAS
@since 23/07/2019
@version 1.0
@param cFilelc, param_type, param_descr
@return lRet, boolean, Retorno da validação do arquivo
/*/
Static Function fValidArq(cFilelc)
Local lRet      := .T.
Local cLocal    := cFilelc

If Empty( cLocal )
    Help(NIL, NIL, "Importação", NIL, "Arquivo não selecionado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe corretamente o arquivo para importação."})
    lRet    := .F.
Else
    If File(cLocal)
        If !Substr(cLocal,rat(".",cLocal),Len(cLocal)) $ ".xml"
            Help(NIL, NIL, "Importação", NIL, "Arquivo inválido", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe corretamente o arquivo para importação, pois o mesmo não possui formato válido."})
            lRet    := .F.
        EndIf        
    Else
        Help(NIL, NIL, "Importação", NIL, "Arquivo não encontrado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe corretamente o arquivo para importação, pois o mesmo não foi localizado."})
        lRet    := .F.
    EndIf
EndIf
Return lRet

User Function fCmbOper()
Local cRet:= "1=Igual a;2=Diferente de;3=Menor que;4=Menor ou Igual a;5=Maior que;6=Maior ou igual a;7=Contém a expressão;8=Não contém;9=Está contido em;10=Diferente de Vazio;11=Vazio"
Return cRet
/*/{Protheus.doc} fGatZT4
//Função de gatilho de campos da tabela ZT4
@author edvf8
@since 26/12/2019
@version undefined
@return return, return_description
/*/
User Function fGatZT4()
Local lRet		:= .T.
Local cAliasSX3 := SX3->(GetArea())
Local oModel	:= FWMODELACTIVE()
Local oMdlZT1	:= oModel:GetModel("MODEL_ZT1")
Local oMdlZT4	:= oModel:GetModel("MODEL_ZT4")
	
	oMdlZT4:SetValue('ZT4_FILIAL'	,	oMdlZT1:GetValue('ZT1_FILIAL'))
	oMdlZT4:SetValue('ZT4_CODPAR'	,	oMdlZT1:GetValue('ZT1_CODPAR'))
	oMdlZT4:SetValue('ZT4_CAMPO'	,	oMdlZT1:GetValue('ZT1_CPODIC'))

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))

	If SX3->(DbSeek(oMdlZT1:GetValue('ZT1_CPODIC')))
		oMdlZT1:SetValue('ZT1_SX3TIT'	,	SX3->X3_TITULO)
		oMdlZT1:SetValue('ZT1_TPDADO'	,	SX3->X3_TIPO)
	Else
		oMdlZT1:SetValue('ZT1_SX3TIT'	,	'')
		oMdlZT1:SetValue('ZT1_TPDADO'	,	'')
		lRet:= .F.
	EndIf
RestArea(cAliasSX3)	
Return lRet

/*/{Protheus.doc} fGatZT4
//Função de gatilho de campos da tabela ZT4
@author edvf8
@since 26/12/2019
@version undefined
@return return, return_description
/*/
User Function fInitCDPAR()
Local lRet		:= .T.
Local oModel	:= FWMODELACTIVE()
Local oView		:= FWVIEWACTIVE()
Local oMdlZT1	:= oModel:GetModel("MODEL_ZT1")


Return iif(!lProc,oMdlZT1:GetValue('ZT1_CODPAR'),"")

/*/{Protheus.doc} fGatZT4
//Função de gatilho de campos da tabela ZT4
@author edvf8
@since 26/12/2019
@version undefined
@return return, return_description
/*/
User Function fInitCPODIC()
Local lRet		:= .T.
Local oModel	:= FWMODELACTIVE()
Local oView		:= FWVIEWACTIVE()
Local oMdlZT1	:= oModel:GetModel("MODEL_ZT1")
	

Return iif(!lProc,oMdlZT1:GetValue('ZT1_CPODIC'),"")