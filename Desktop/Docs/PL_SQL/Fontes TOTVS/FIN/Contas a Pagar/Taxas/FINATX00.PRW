#Include "Protheus.ch" 
#Include "TopConn.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH" 
 
/*/{Protheus.doc} FINATX00 
//Importacao de Reembolsos
@author Ovio Consultoria
@since 25/08/2019
/*/ 

User Function FINATX00()

Local cCadastro := OemToAnsi("Importacao de Taxas")
Private oBrowse

Private aRotina   := MenuDef()
 

If AliasIndic('ZT6')	
	
	dbSelectArea("ZT6")

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZT6")
	oBrowse:AddLegend( "ZT6_STATUS=='0'", "RED"    , "Não Importado"   )
	oBrowse:AddLegend( "ZT6_STATUS=='1'", "GREEN"  , "Importado"       )
    oBrowse:AddLegend( "ZT6_STATUS=='2'", "BLACK"  , "Estornado"       )
    oBrowse:AddLegend( "ZT6_STATUS=='3'", "WHITE"  , "Erro no Estorno" )
	oBrowse:SetDescription(cCadastro)
	oBrowse:Activate()

Else
	Alert('Dicionário está desatualizado, por favor verifique atualização das tabelas.' + CRLF + "ZT6 - Central de Reembolso - Não encontrada.")	
EndIF

Return(Nil)

/*/{Protheus.doc} MenuDef
//TODO Definição dos itens de menu disponiveis no mvc. 
@author Ovio Consultoria
@since 25/08/2021
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar'         ACTION 'VIEWDEF.FINATX00' OPERATION MODEL_OPERATION_VIEW   ACCESS 2 //OPERATION 1
ADD OPTION aRotina TITLE 'Importar Movimento' ACTION 'u_FINATX01()' OPERATION MODEL_OPERATION_INSERT ACCESS 3 //OPERATION 3
ADD OPTION aRotina TITLE 'Estornar Movimento' ACTION 'u_FINATX02()' OPERATION MODEL_OPERATION_DELETE ACCESS 5 //OPERATION 5
ADD OPTION aRotina TITLE 'Exportar Layout'    ACTION 'u_FINATX03()' OPERATION MODEL_OPERATION_VIEW ACCESS 3 //OPERATION 2

Return aRotina

/*/{Protheus.doc} ModelDef
 TODO Define o modelo da rotina
@author Ovio Consultoria
@since 14/05/2021
@version undefined
@return return, return_description
/*/
Static Function ModelDef()
	Local oModel := MPFormModel():New("COMP011M")
	Local oStruZT6 := FwFormStruct(1, "ZT6")

    oModel:AddFields("ZT6MASTER", NIL, oStruZT6)
    oModel:SetDescription("TAXAS")
    oModel:GetModel("ZT6MASTER"):SetDescription("TAXAS")
	oModel:SetPrimaryKey( { 'ZT6_FILIAL' },{'ZT6_LOTE' } )  

Return oModel 

/*/{Protheus.doc} ViewDef
//TODO FUNÇÃO PADRÃO DE MVC PARA VIEWDEF
@author Ovio Consultoria
@since 14/05/2021
/*/
Static Function ViewDef()
	Local oView := FwFormView():New()
    Local oStruZA0 := FwFormStruct(2, "ZT6")
    Local oModel := FwLoadModel("FINATX00")

    oView:SetModel(oModel)
    oView:AddField("VIEW_ZT6", oStruZA0, "ZT6MASTER")
    oView:CreateHorizontalBox("TELA" , 100)
    oView:SetOwnerView("VIEW_ZT6", "TELA")

Return (oView)

/*/{Protheus.doc} fExclui
//Tela de confirmação, antes de excuir.
@author Ovio Consultoria
@since 19/12/2019
@version undefined
@return return, return_description
/*/
User Function FINATX02()
	If MsgYesNo("Esta ação excluirá todos os registros relacionados ao lote "+ZT6->ZT6_LOTE+", deseja continuar?", "Sim")
		MsgRun("Excluindo lote "+ZT6->ZT6_LOTE,"Aguarde",{|| fExcRegs()})
	EndIf
oBrowse:Refresh(.T.)
Return .T.

/*/{Protheus.doc} fExcRegs
//Rotina de acionamento da exclusao dos registros
@author Ovio Consultoria
@since 19/12/2019
@version undefined
@return return, return_description
/*/
Static Function fExcRegs()
Local aAlsZT6	:= ZT6->(GETAREA())
Local cLote	    := ZT6->ZT6_LOTE

Private lMsErroAuto 	:= .F.
Private lAutoErrNoFile  := .T.

	dbSelectArea("ZT6")
	ZT6->(dbSetOrder(1))
	If ZT6->(dbSeek(xFilial("ZT6")+cLote)) 
		While ZT6->(ZT6_FILIAL+ZT6_LOTE)==(xFilial("ZT6")+cLote)
	 		DbSelectArea("SE2")
            SE2->(DbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
			If ZT6->ZT6_STATUS<>'1'
				ZT6->(dbSkip())
				Loop
			Endif
            If SE2->(DbSeek(Padr(Alltrim(ZT6->ZT6_FILORI),TamSx3("E2_FILIAL")[1]) + ZT6->(ZT6_FORNEC+ZT6_LOJA+ZT6_PREFIX+ZT6_NUM+ZT6_PARCEL+ZT6_TIPO)))
	        									
				aCab := {}
			    aadd( aCab ,{"E2_FILIAL"    ,SE2->E2_FILIAL  , Nil })            
				aadd( aCab ,{"E2_PREFIXO"   ,SE2->E2_PREFIXO , Nil })            
				aadd( aCab ,{"E2_NUM"       ,SE2->E2_NUM     , Nil })
				aadd( aCab ,{"E2_PARCELA"   ,SE2->E2_PARCELA , Nil })
				aadd( aCab ,{"E2_TIPO"      ,SE2->E2_TIPO    , Nil })
				aadd( aCab ,{"E2_NATUREZ"   ,SE2->E2_NATUREZ , Nil })
				aadd( aCab ,{"E2_FORNECE"   ,SE2->E2_FORNECE , Nil })
				aadd( aCab ,{"E2_LOJA"      ,SE2->E2_LOJA    , Nil })
				aadd( aCab ,{"E2_EMISSAO"   ,SE2->E2_EMISSAO , Nil })
				aadd( aCab ,{"E2_VENCTO"    ,SE2->E2_VENCTO  , Nil }) 
				aadd( aCab ,{"E2_HIST"      ,SE2->E2_HIST    , Nil }) 
				aadd( aCab ,{"E2_FORMPAG"   ,SE2->E2_FORMPAG , Nil }) 
				aadd( aCab ,{"E2_VALOR"     ,SE2->E2_VALOR   , Nil })
				aadd( aCab ,{"E2_MULTNAT"   ,SE2->E2_MULTNAT , Nil })
				aadd( aCab ,{"E2_CCUSTO"    ,SE2->E2_CCUSTO  , Nil }) 
				aadd( aCab ,{"E2_ITEMCTA"   ,SE2->E2_ITEMCTA , Nil }) 
				aadd( aCab ,{"E2_CLVL"      ,SE2->E2_CLVL    , Nil }) 
 	        
				lMsErroAuto := .F.

				MsExecAuto( { |x,y,z| FINA050(x,y,z)} , aCab, ,5)

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
					RecLock("ZT6",.F.)
					ZT6->ZT6_STATUS := "3"
					ZT6->ZT6_LOG    := cDetalhe
					ZT6->(msUnlock())
				Else
					RecLock("ZT6",.F.)
					ZT6->ZT6_STATUS := "2"
					ZT6->ZT6_LOG    := "Estornado com sucesso."
					ZT6->(msUnlock())
				EndIf
	        Else
				RecLock("ZT6",.F.)
				ZT6->ZT6_STATUS := "3"
				ZT6->ZT6_LOG    := "Titulo não localizado no financeiro."
				ZT6->(msUnlock())
			Endif
			ZT6->(dbSkip())    
		EndDo  
	EndIf
RestArea(aAlsZT6)
Return .T.

/*/{Protheus.doc} FINATX03
//Exportar layout
@author Ovio Consultoria
@since 14/05/2021
@version undefined
@return return, return_description
/*/
User Function FINATX03
	Local cCabec := "Filial;Prefixo;Nº Titulo;Tipo;Codigo Fornecedor;ID Recebedor;Data de emissão;Vencimento;Valor;Histórico;Forma Pagto;Centro de custo;Item conta;Classe de valor;Nome do arquivo;Parcela;Natureza"

	Local cArquivo  := "layout_reembolso.csv"
	Local targetDir := cGetFile( '*.*|*.*' , 'Escolha a pasta', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )

	If MemoWrite(targetDir+cArquivo , cCabec )
		Aviso("Atenção","Planilha modelo salva com sucesso na pasta " + targetDir ,{"Abrir"} )
		WinExec("cmd.exe /C" + targetDir+cArquivo)
	Else
		Aviso( "Atenção","Erro ao criar arquivo " + targetDir + cArquivo + " - fError " + Str(Ferror()) )
	Endif

Return
