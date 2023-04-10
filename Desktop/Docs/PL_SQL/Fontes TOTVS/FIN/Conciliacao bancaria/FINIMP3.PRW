#Include "Protheus.ch" 
#Include "TopConn.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"

User Function FINIMP3()

Local cCadastro := OemToAnsi("Histórico de Importação")
Private oBrowse

Private aRotina   := MenuDef()


If AliasIndic('ZT3')	
	
	dbSelectArea("ZT3")
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZT3")
	
	oBrowse:AddLegend( "ZT3_STATUS=='0'", "RED", "Não Importado"      )
	oBrowse:AddLegend( "ZT3_STATUS=='1'", "GREEN"  , "Importado" )
	oBrowse:SetDescription(cCadastro)
	oBrowse:Activate()

Else
	Alert('Dicionário está desatualizado, por favor verifique atualização das tabelas.' + CRLF + "ZT3 - Histórico de Integração - Não encontrada.")	
EndIF

Return(Nil)

/*/{Protheus.doc} MenuDef
//TODO Definição dos itens de menu disponiveis no mvc.
@author CODVS E.V.F. SISTEMAS
@since 25/08/2019
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.FINIMP3' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir Movimento'    ACTION 'u_fExclui()' OPERATION 5 ACCESS 0


	
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
Local oStructZT3 := FWFormStruct( 1, 'ZT3', /*bAvalCampo*/,/*lViewUsado*/ )

oModel := MPFormModel():New('FINIMP3M', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ ) 

   
oModel:AddFields( 'MODEL_ZT3', /*cOwner*/, oStructZT3, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:GetModel('MODEL_ZT3'):SetPrimaryKey({"ZT3_FILIAL+ZT3_ID"   })
oModel:SetPrimaryKey( { 'ZT3_FILIAL' },{'ZT3_ID' } )   

Return oModel 

/*/{Protheus.doc} ViewDef
//TODO FUNÇÃO PADRÃO DE MVC PARA VIEWDEF
@author CODVS E.V.F SISTEMAS
@since 25/08/2019
/*/
Static Function ViewDef()
Local oModel   		:= FwLoadModel("FINIMP3")
Local oStructZT3 	:= FWFormStruct( 2 , "ZT3")
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ZT3', oStructZT3,"MODEL_ZT3")
oView:CreateHorizontalBox("FIELDS", 100)

oView:SetOwnerView("VIEW_ZT3", "FIELDS")

Return oView
/*/{Protheus.doc} fExclui
//Tela de confirmação, antes de excuir.
@author edvf8
@since 19/12/2019
@version undefined
@return return, return_description
/*/
User Function fExclui()
	If MsgYesNo("Esta ação excluirá todos os registros relacionados ao arquivo deste item de histórico, deseja continuar?", "Sim")
		MsgRun("Estamos excluindo os dados do histórico.","Aguarde",{|| fExcRegs()})
	EndIf
oBrowse:Refresh(.T.)
Return .T.
/*/{Protheus.doc} fExcRegs
//Rotina de acionamento da exclusao dos registros
@author edvf8
@since 19/12/2019
@version undefined
@return return, return_description
/*/
Static Function fExcRegs()
Local aAlsZT3	:= ZT3->(GETAREA())
Local cCodPar	:= ZT3->ZT3_CODPAR
Local cArquiv	:= ZT3->ZT3_ARQUIV
Local cFilArq	:= ZT3->ZT3_FILIAL
Local nIndic	:= RetOrder("SE5","E5_FILIAL+E5_IDORIG+E5_TIPODOC")
Private lMsHelpAuto 	:= .T. //Variavel de controle interno do ExecAuto
Private lMsErroAuto 	:= .F. //Variavel que informa a ocorrência de erros no ExecAuto
Private lAutoErrNoFile 	:= .T.

	dbSelectArea("ZT3")
	ZT3->(dbSetOrder(1))
	If ZT3->(dbSeek(cFilArq+cCodPar+cArquiv)) 
		While ZT3->(ZT3_FILIAL+ZT3_CODPAR+ZT3_ARQUIV)== (cFilArq+cCodPar+cArquiv)
	 		dbSelectArea("SE5")
	 		SE5->(dbGotop())
	        SE5->(dbSetOrder(nIndic))
	        aFINA100 := {}
	        lMsErroAuto 	:= .F.
	        If SE5->(dbSeek(cFilArq+ZT3->ZT3_IDORIG))
		        aFINA100 := {    {"E5_DATA"            ,SE5->E5_DATA        ,Nil},;
	                             {"E5_MOEDA"           ,SE5->E5_MOEDA       ,Nil},;
	                             {"E5_VALOR"           ,SE5->E5_VALOR       ,Nil},;
	                             {"E5_NATUREZ"         ,SE5->E5_NATUREZ     ,Nil},;
	                             {"E5_BANCO"           ,SE5->E5_BANCO       ,Nil},;
		                         {"E5_AGENCIA"         ,SE5->E5_AGENCIA     ,Nil},;
		                         {"E5_CONTA"           ,SE5->E5_CONTA       ,Nil},;
		                         {"E5_HISTOR"          ,SE5->E5_HISTOR      ,Nil},;
		                         {"E5_TIPOLAN"         ,SE5->E5_TIPOLAN     ,Nil},;
 		                         {"E5_IDMOVI"         ,SE5->E5_IDMOVI     	,Nil},;
                                 {"E5_IDORIG"         ,SE5->E5_IDORIG     	,Nil},;
		                         {"INDEX"			   , nIndic ,NIL} }
		   
		        MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,5)
		   
		        If lMsErroAuto
		            MostraErro()
		        Else
		        	RecLock("ZT3",.F.)
		        	dbDelete()
		        	ZT3->(msUnlock())
		        EndIf
	       EndIf
	       ZT3->(dbSkip())    
		EndDo  
	EndIf

RestArea(aAlsZT3)
Return .T.
