#Include "Totvs.ch"

#Define BR Chr(10)

/*/{Protheus.doc}CKGRVTIT()

Gravacao de Dados no contas a pagar para geracao de bordero

@author Ovio Consultoria 
@since 11/03/2021
@version P12 
@param 	
@return	
/*/ 

User Function MT120GRV() 
	Local lAlt      := ParamIxb[3]
    Local lRet      := .T.
    Local __xnOpc   := 1
    
    Public __xcObs  := ""
    
	If !lAlt
		Return
	Endif

    CSS6 := ""
	CSS6 += BR+"QTextEdit {";
		+BR+ "color: #0F243E; /*Cor da fonte*/";
		+BR+ "font-size: 14px; /*Tamanho da fonte*/";
		+BR+ "min-height: 40px; /*Largura minima*/";
		+BR+ "border: 2px solid #595858; /*Cor da borda*/";
		+BR+ "border-radius: 10px; /*Arredondamento da borda*/";
		+BR+ "padding: 0 8px; /*Especo (margem)*/";
		+BR+" background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
		+BR+" stop: 0 #e8e8e8, stop: 1 #ffffff); /*Cor de fundo*/";
		+BR+" selection-background-color: #E36C09; /*Cor de fundo quando selecionado*/";
		+BR+" }"

    cCSS :=""
	cCSS +=	 BR+"QPushButton {";
		+BR+"  color: #FFFFFF; /*Cor da fonte*/";
		+BR+"  border: 2px solid #ff0202; /*Cor da borda*/";
		+BR+"  border-radius: 6px; /*Arrerondamento da borda*/";
		+BR+"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
		+BR+"  stop: 0 #800000, stop: 1 #ff0202); /*Cor de fundo*/";
		+BR+"  min-width: 80px; /*Largura minima*/";
		+BR+"}";
		+BR+"QPushButton:pressed {";
		+BR+" background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
		+BR+" stop: 0 #f98f8f, stop: 1 #800000);";
		+BR+"}"

	
	DEFINE MSDIALOG oDLg FROM 0,0 TO 300,380 PIXEL TITLE "Motivo da Alteração"

	oSimpleEdit := tSimpleEditor():New(4,4,oDLg,180,130, __xcObs, .F. , {|u| if(Pcount()>0,__xcObs:=u,__xcObs)},,.T.)
	oSimpleEdit:TextFormat(2)
	oSimpleEdit:SetCss(CSS6)

	oBUTTON1:=tBUTTON():New(138,100,"Confirma",oDlg,{|| __xnOpc := 1 , oDlg:End() } , 40 , 10 ,,,,.T.)
    oBUTTON2:=tBUTTON():New(138,145,"Cancelar",oDlg,{|| __xnOpc := 0 , oDlg:End() } , 40 , 10 ,,,,.T.)

	oBUTTON1:SetCss(cCSS)
	oBUTTON2:SetCss(cCSS)

	ACTIVATE MSDIALOG oDlg CENTERED

    If __xnOpc==1
        If Empty(__xcObs)
            Aviso("Atenção","Informe o motivo da alteração do pedido de compra para continuar",{"Ok"},2)
            lRet      := .F.
        Endif
    Else
        lRet := .F.    
    Endif    

Return lRet
