#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "rwmake.ch"
#Include "ApWebSrv.ch"
#INCLUDE "ap5mail.ch"
#INCLUDE "shell.ch"
#Include "TbiConn.ch"

#DEFINE BR Chr(10)

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
User Function ALLRPC01()
	Local aArea := SC7->(GetArea())

	Private cNumPed   := SC7->C7_NUM
	Private cSubject  := "Pedido de Compra."
	Private cEmail    := ""
	Private cTextoGer := ""

	CSS6 := ""
	CSS6 +=  BR+"QTextEdit {";
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

	CSSA := "QPushButton {background-image: url(rpo:totvsprinter_email.png);background-repeat: none; margin: 2px;}"

	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)

	cTextoGer := "" + CRLF
	cTextoGer += " Prezado fornecedor, "  + CRLF
	cTextoGer += " Estamos enviando nosso pedido de compra para abastecimento " + CRLF
	cTextoGer += "do estoque de nossas unidades, aguardamos confirmação do recebimento deste pedido e" + CRLF
	cTextoGer += "também a confirmação do agendamento para entrega do mesmo."+ CRLF
	cTextoGer += " Obrigado!"+ CRLF

	cEmail := Lower(Alltrim(SA2->A2_EMAIL))

	DEFINE MSDIALOG oBrMail FROM 0,0 TO 350,635 PIXEL TITLE 'ENVIO DE PEDIDO DE COMPRA'

	oTPane1XX:= TPanel():New(0,0,"",oBrMail,NIL,.T.,.F.,NIL,NIL,0,30,.T.,.F.)
	oTPane1XX:Align := CONTROL_ALIGN_BOTTOM

	oSimpleEdit := tSimpleEditor():New(4,4,oBrMail,305,060,cTextoGer, .F. , {|u| if(Pcount()>0,cTextoGer:=u,cTextoGer)},,.T.)
	oSimpleEdit:TextFormat(2)
	oSimpleEdit:SetCss(CSS6)

	oSubJect := TGet():New( 070,10 ,{|| cSubJect } ,oBrMail,300,011,""   ,   ,0   ,  ,  ,.F.,,.T.,,.F.,,.F.,.F.,  ,.T. ,.F. , ,"cSubJect"  ,   ,    ,    ,   ,   ,    ,"Assunto: "  ,1   ,   ,   ,    ,                     ,            )
	oEmail 	 := TGet():New( 100,10 ,{|| cEmail   } ,oBrMail,300,011,""   ,   ,0   ,  ,  ,.F.,,.T.,,.F.,,.F.,.F.,  ,.T. ,.F. , ,"cEmail"    ,   ,    ,    ,   ,   ,    ,"E-Mails: "  ,1   ,   ,   ,    ,                     ,            )

	oBtnEmail:= TButton():New(005,005,"     Enviar E-mail" 	,oTPane1XX,{|| FWMsgRun(, {|oSay| fImpPc() }, "Gerando Pedido de Compra", "Gerando Pedido de Compra") ,oBrMail:End() },60,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnEmail:SetCss(CSSA)

	ACTIVATE MSDIALOG oBrMail CENTERED

	RestArea(aArea)
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
Static Function fImpPc()

	Local oPrint

	Private cNomeArq  := ""
	Private cCaminho  := Alltrim(GetMv("OV_PCDIR",,"\pc\"))
	Private cDirTmp   := Alltrim(GetTempPath())

	cNomeArq := "pc_"+SC7->C7_FILIAL+SC7->C7_NUM

	If File(cCaminho+cNomeArq+".pdf")
		FErase( cCaminho+cNomeArq+".pdf" )
	Endif

	If File(cDirTmp+cNomeArq+".pdf")
		FErase( cCaminho+cNomeArq+".pdf" )
	Endif

	oPrint := FwMSPrinter():New( cNomeArq, 6 , .T. , cDirTmp , .T., , , , , .F., ,.F. )
	oPrint:cPathPDF := cDirTmp
	oPrint:SetPortrait()					// Modo retrato
	oPrint:SetPaperSize(9)					// Papel A4
	oPrint:lInJob:= .T.

	If .NOT. ExistDir(cCaminho)
		nRet := MakeDir(cCaminho)
		if nRet != 0
			Aviso("Atenção","Não foi possível criar o diretório. Erro: " + cValToChar(FError()), {"Ok"} )
			Return
		Endif
	Endif

	fCabec(oPrint)

	oPrint:SetViewPDF(.T.)

	oPrint:Print()

	ATEnvMail( cTextoGer , cEmail , cSubject , { cNomeArq +".pdf" } )


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
Static Function fCabec(oPrint)

//Parametros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
	Local nObs      := 1
	Local oFont14n	:= TFont():New("Cambria"	,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont14	:= TFont():New("Cambria"	,9,12,.T.,.F.,5,.T.,5,.T.,.F.)
	Local oFont16n	:= TFont():New("Cambria"	,9,16,.T.,.T.,5,.T.,5,.T.,.F.)
	Local cStartPath:= GetSrvProfString("StartPath","")
	Local cBmp		:= "allcarepc.bmp"
	Local cCotacao  := fCotacao()
	Local cCondi    := SC7->C7_COND+" - "+Alltrim(Posicione("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_DESCRI"))
	Local aObs      := {}

	cStartPath	:= AllTrim(cStartPath)
	If SubStr(cStartPath,Len(cStartPath),1) <> "\"
		cStartPath	+= "\"
	EndIf
	cBmp	:= cStartPath+cBmp

	oPrint:StartPage()
	oPrint:SayBitMap( 0010 , 1950 , cBmp , 350 , 230 )

	oPrint:Box( 240, 050 , 2950 , 2350 , "-4")
	oPrint:Say(0110,050,"PEDIDO DE COMPRA",oFont16n)
	oPrint:Say(0160,050,"Nº "+cNumPed,oFont16n)

	oPrint:SayAlign( 0250, 060, "ALLCARE ADMINISTRADORA DE BENEFICIOS SÃO PAULO LTDA", oFont14n, 2350, 050 , 0, 2, 0)
	oPrint:Line(0290,050,0290, 2350 , /*nColor*/ , "-4" )

	oPrint:Line(0290,150,0660, 0150 , /*nColor*/ , "-4" )
	oPrint:Line(0660,050,0660, 2350 , /*nColor*/ , "-4" )
	oPrint:Say(0650,095,"DADOS FORNECEDOR",oFont14n,0,,270)

	oPrint:Say(0315,170,"Código/Loja:",oFont14n)
	oPrint:Say(0315,470,SA2->A2_COD+"/"+SA2->A2_LOJA,oFont14n)

	oPrint:Say(0355,170,"Razão Social:",oFont14n)
	oPrint:Say(0355,470,SA2->A2_NOME,oFont14n)

	oPrint:Say(0405,170,"CNPJ:",oFont14n)
	oPrint:Say(0405,470,Transform(SA2->A2_CGC,"@R 99.999.999/9999-99") ,oFont14n)

	oPrint:Say(0455,170,"Insc. Estadual:")
	oPrint:Say(0455,470,SA2->A2_INSCR,oFont14n)

	oPrint:Say(0505,170,"Endereço:",oFont14n)
	oPrint:Say(0505,470,Alltrim(SA2->A2_END)+" "+Alltrim(SA2->A2_NR_END),oFont14n)

	oPrint:Say(0555,170,"Contato:" ,oFont14n)
	oPrint:Say(0555,470,Alltrim(SA2->A2_CONTATO) ,oFont14n)

	oPrint:Say(0605,170,"E-mail:"  ,oFont14n)
	oPrint:Say(0605,470,Alltrim(SA2->A2_EMAIL)  ,oFont14n)

	oPrint:Say(0655,170,"Telefone:",oFont14n)
	oPrint:Say(0655,470,"("+Alltrim(SA2->A2_DDD)+") "+Transform(SA2->A2_TEL,"@R 9999-9999"),oFont14n)


	oPrint:Line(0660,150,1010, 0150 , /*nColor*/ , "-4" )
	oPrint:Line(1010,050,1010, 2350 , /*nColor*/ , "-4" )
	oPrint:Say(1000,095,"DADOS FATURAMENTO",oFont14n,0,,270)

	oPrint:Say(0710,170,"Razão Social:",oFont14n)
	oPrint:Say(0710,470,Alltrim(SM0->M0_NOMECOM),oFont14n)

	oPrint:Say(0760,170,"CNPJ:",oFont14n)
	oPrint:Say(0760,470,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),oFont14n)

	oPrint:Say(0810,170,"Insc. Estadual:",oFont14n)
	oPrint:Say(0810,470,SM0->M0_INSC,oFont14n)

	oPrint:Say(0860,170,"Endereço:",oFont14n)
	oPrint:Say(0860,470,SM0->M0_ENDCOB,oFont14n)

	dbSelectArea("SY1")
	dbSetOrder(3)
	dbSeek( xFilial("SY1") + SC7->C7_USER )

	oPrint:Say(0910,170,"Contato:" ,oFont14n)
	oPrint:Say(0910,470,Alltrim(SY1->Y1_NOME),oFont14n)

	oPrint:Say(0960,170,"E-mail:"  ,oFont14n)
	oPrint:Say(0960,470,Alltrim(SY1->Y1_EMAIL),oFont14n)

	oPrint:Say(1005,170,"Telefone:",oFont14n)
	oPrint:Say(1005,470,Transform(SM0->M0_TEL,"@R (99) 9999-9999"),oFont14n)


	oPrint:Line(1060,050,1060, 2350 , /*nColor*/ , "-4" )
	oPrint:Say(1055,080,"CONDIÇÃO DE PAGAMENTO: "+cCondi,oFont14n)
	
	//oPrint:Say(1055,1300,"NÃO ENCAMINHAR PAGAMENTOS COM VENCIMENTOS NOS DIAS 1/15/30",oFont14n,,CLR_HRED)

	oPrint:Line(1110,050,1110, 2350 , /*nColor*/ , "-4" )
	oPrint:Say(1105,080,"ORÇAMENTO FORNECEDOR Nº.: "+cCotacao,oFont14n)


	oPrint:Line(1210,050,1210, 2350 , /*nColor*/ , "-4" )
	oPrint:Line(1310,050,1310, 2350 , /*nColor*/ , "-4" )
	oPrint:Line(1360,050,1360, 2350 , /*nColor*/ , "-4" )

	oPrint:SayAlign( 1110, 060, "OBSERVAÇÃO: Todas as notas fiscais deverão ser encaminhadas assim que emitidas para o e-mail compras@allcare.com.br", oFont14n, 2350, 050 , CLR_HRED, 2, 0)
	
	oPrint:SayAlign( 1160, 060, "SEMPRE INFORMAR NO CAMPO DADOS OPCIONAIS DA NOTA FISCAL O NÚMERO DO PEDIDO ACIMA.", oFont14n, 2350, 050 , CLR_HRED , 2, 0)
	oPrint:SayAlign( 1210, 060, "DATA DE CORTE PARA EMISSÃO DE NOTAS FISCAIS ATÉ O DIA 25 DE CADA MÊS, APÓS ESTA DATA A NF ESTARÁ SUJEITA A NÃO ACEITE.", oFont14n, 2350, 050 , CLR_HRED , 2, 0)

	oPrint:Line(1310,0150,1360, 0150 , /*nColor*/ , "-4" )
	oPrint:Line(1310,0950,1360, 0950 , /*nColor*/ , "-4" )
	oPrint:Line(1310,1300,1360, 1300 , /*nColor*/ , "-4" )
	oPrint:Line(1310,1500,1360, 1500 , /*nColor*/ , "-4" )
	oPrint:Line(1310,1950,1360, 1950 , /*nColor*/ , "-4" )

	oPrint:Say(1340,060,"Item",oFont14n)
	oPrint:Say(1340,160,"Descrição dos Itens",oFont14n)
	oPrint:Say(1340,960,"Quantidade",oFont14n)
	oPrint:Say(1340,1310,"Unidade",oFont14n)
	oPrint:Say(1340,1510,"Vlr. Unitario",oFont14n)
	oPrint:Say(1340,1960,"Vlr. Total",oFont14n)

	nVlrTotal := 0
	nVlrDesc  := 0
	nVlrFrete := 0

	nLinha  := 1390
	nLinIni := 1360
	dbSelectArea("SC7")
	dbSetOrder(1)
	dbSeek(xFilial("SC7") + cNumPed )
	While SC7->(!Eof()) .And. SC7->C7_FILIAL+SC7->C7_NUM==xFilial("SC7")+cNumPed

		If nLinha>=2700
			oPrint:EndPage()
			oPrint:StartPage()
			oPrint:SayBitMap( 0010 , 1950 , cBmp , 350 , 230 )

			oPrint:Box( 260, 050 , 2950 , 2350 , "-4")
			oPrint:Say(0110,050,"PEDIDO DE COMPRA",oFont16n)
			oPrint:Say(0160,050,"Nº "+cNumPed,oFont16n)

			oPrint:SayAlign( 0260, 060, "ALLCARE ADMINISTRADORA DE BENEFICIOS SÃO PAULO LTDA", oFont14n, 2350, 050 , 0, 2, 0)
			oPrint:Line(0310,050,0310, 2350 , /*nColor*/ , "-4" )

			oPrint:Line(310,0150,360, 0150 , /*nColor*/ , "-4" )
			oPrint:Line(310,0950,360, 0950 , /*nColor*/ , "-4" )
			oPrint:Line(310,1300,360, 1300 , /*nColor*/ , "-4" )
			oPrint:Line(310,1500,360, 1500 , /*nColor*/ , "-4" )
			oPrint:Line(310,1950,360, 1950 , /*nColor*/ , "-4" )

			oPrint:Say(340,060,"Item",oFont14n)
			oPrint:Say(340,160,"Descrição dos Itens",oFont14n)
			oPrint:Say(340,960,"Quantidade",oFont14n)
			oPrint:Say(340,1310,"Unidade",oFont14n)
			oPrint:Say(340,1510,"Vlr. Unitario",oFont14n)
			oPrint:Say(340,1960,"Vlr. Total",oFont14n)

			oPrint:Line(360,050,360, 2350 , /*nColor*/ , "-4" )

			nLinha  := 390
			nLinIni := 360
		Endif

		dbSelectArea("SC1")
		dbSetOrder(1)
		If dbseek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC)
			If !Empty(SC1->C1_XOBS)
				aAdd(aObs,{ SC7->C7_ITEM,SC1->C1_XOBS })
			Endif
		Endif

		nVlrTotal+=SC7->C7_TOTAL
		nVlrDesc +=SC7->C7_VLDESC
		nVlrFrete+=SC7->C7_FRETE

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+SC7->C7_PRODUTO)

		oPrint:Say(nLinha,060 , SC7->C7_ITEM,oFont14)
		oPrint:Say(nLinha,160 , Alltrim(SB1->B1_COD)+"-"+Alltrim(SB1->B1_DESC),oFont14)
		oPrint:Say(nLinha,960 , Transform(SC7->C7_QUANT,"@E 9,999,999.99"),oFont14)
		oPrint:Say(nLinha,1310, SC7->C7_UM,oFont14)
		oPrint:Say(nLinha,1510,Transform(SC7->C7_PRECO,"@E 9,999,999.99"),oFont14)
		oPrint:Say(nLinha,1960,Transform(SC7->C7_TOTAL,"@E 9,999,999.99"),oFont14)

		oPrint:Line(nLinha+10,050,nLinha+10, 2350 , /*nColor*/ , "-4" )

		nLinha += 50
		SC7->(dbSkip())
	End


	If nLinha>=2700
		oPrint:EndPage()
		oPrint:StartPage()
		oPrint:SayBitMap( 0010 , 1950 , cBmp , 350 , 230 )

		oPrint:Box( 260, 050 , 2950 , 2350 , "-4")
		oPrint:Say(0110,050,"PEDIDO DE COMPRA",oFont16n)
		oPrint:Say(0160,050,"Nº "+cNumPed,oFont16n)

		oPrint:SayAlign( 0260, 060, "ALLCARE ADMINISTRADORA DE BENEFICIOS SÃO PAULO LTDA", oFont14n, 2350, 050 , 0, 2, 0)
		oPrint:Line(0310,050,0310, 2350 , /*nColor*/ , "-4" )
		nLinha:=360
	Endif

	oPrint:Line(nLinIni,0150,nLinha, 0150 , /*nColor*/ , "-4" )
	oPrint:Line(nLinIni,0950,nLinha, 0950 , /*nColor*/ , "-4" )
	oPrint:Line(nLinIni,1300,nLinha, 1300 , /*nColor*/ , "-4" )
	oPrint:Line(nLinIni,1500,nLinha, 1500 , /*nColor*/ , "-4" )
	oPrint:Line(nLinIni,1950,nLinha, 1950 , /*nColor*/ , "-4" )

	oPrint:Line(nLinha,1500,nLinha+50, 1500 , /*nColor*/ , "-4" )
	oPrint:Line(nLinha,0050,nLinha   , 2350 , /*nColor*/ , "-4" )

	oPrint:SayAlign( nLinha, 060, "VALOR TOTAL", oFont14n, 1420, 050 , CLR_BLACK, 1, 2)
	oPrint:SayAlign( nLinha, 060, Transform(nVlrTotal,"@E 9,999,999.99") , oFont14n, 2250, 050 , CLR_BLACK, 1, 2)


	nLinha+= 50
	If nLinha>=2700
		oPrint:EndPage()
		oPrint:StartPage()
		oPrint:SayBitMap( 0010 , 1950 , cBmp , 350 , 230 )

		oPrint:Box( 260, 050 , 2950 , 2350 , "-4")
		oPrint:Say(0110,050,"PEDIDO DE COMPRA",oFont16n)
		oPrint:Say(0160,050,"Nº "+cNumPed,oFont16n)

		oPrint:SayAlign( 0260, 060, "ALLCARE ADMINISTRADORA DE BENEFICIOS SÃO PAULO LTDA", oFont14n, 2350, 050 , 0, 2, 0)
		oPrint:Line(0310,050,0310, 2350 , /*nColor*/ , "-4" )
		nLinha:=360
	Endif
	oPrint:Line(nLinha,1500,nLinha+50, 1500 , /*nColor*/ , "-4" )
	oPrint:Line(nLinha,0050,nLinha   , 2350 , /*nColor*/ , "-4" )
	oPrint:SayAlign( nLinha, 060, "FRETE", oFont14n, 1420, 050 , CLR_BLACK, 1, 2)
	oPrint:SayAlign( nLinha, 060, Transform(nVlrFrete,"@E 9,999,999.99") , oFont14n, 2250, 050 , CLR_BLACK, 1, 2)

	nLinha+= 50
	If nLinha>=2700
		oPrint:EndPage()
		oPrint:StartPage()
		oPrint:SayBitMap( 0010 , 1950 , cBmp , 350 , 230 )

		oPrint:Box( 260, 050 , 2950 , 2350 , "-4")
		oPrint:Say(0110,050,"PEDIDO DE COMPRA",oFont16n)
		oPrint:Say(0160,050,"Nº "+cNumPed,oFont16n)

		oPrint:SayAlign( 0260, 060, "ALLCARE ADMINISTRADORA DE BENEFICIOS SÃO PAULO LTDA", oFont14n, 2350, 050 , 0, 2, 0)
		oPrint:Line(0310,050,0310, 2350 , /*nColor*/ , "-4" )
		nLinha:=360
	Endif
	oPrint:Line(nLinha,1500,nLinha+50, 1500 , /*nColor*/ , "-4" )
	oPrint:Line(nLinha,0050,nLinha   , 2350 , /*nColor*/ , "-4" )
	oPrint:SayAlign( nLinha, 060, "DESCONTO", oFont14n, 1420, 050 , CLR_BLACK, 1, 2)
	oPrint:SayAlign( nLinha, 060, Transform(nVlrDesc ,"@E 9,999,999.99") , oFont14n, 2250, 050 , CLR_BLACK, 1, 2)

	nLinha+= 50
	If nLinha>=2700
		oPrint:EndPage()
		oPrint:StartPage()
		oPrint:SayBitMap( 0010 , 1950 , cBmp , 350 , 230 )

		oPrint:Box( 260, 050 , 2950 , 2350 , "-4")
		oPrint:Say(0110,050,"PEDIDO DE COMPRA",oFont16n)
		oPrint:Say(0160,050,"Nº "+cNumPed,oFont16n)

		oPrint:SayAlign( 0260, 060, "ALLCARE ADMINISTRADORA DE BENEFICIOS SÃO PAULO LTDA", oFont14n, 2350, 050 , 0, 2, 0)
		oPrint:Line(0310,050,0310, 2350 , /*nColor*/ , "-4" )
		nLinha:=360
	Endif
	oPrint:Line(nLinha,1500,nLinha+50, 1500 , /*nColor*/ , "-4" )
	oPrint:Line(nLinha,0050,nLinha   , 2350 , /*nColor*/ , "-4" )
	oPrint:SayAlign( nLinha, 060, "VALOR TOTAL COM DESCONTO", oFont14n, 1420, 050 , CLR_HRED, 1, 2)
	oPrint:SayAlign( nLinha, 060, Transform(nVlrTotal+nVlrFrete-nVlrDesc ,"@E 9,999,999.99") , oFont14n, 2250, 050 , CLR_BLACK, 1, 2)

	nLinha+=50
	oPrint:Line(nLinha,0050,nLinha   , 2350 , /*nColor*/ , "-4" )

	//oPrint:Line(1110,050,1110, 2350 , /*nColor*/ , "-4" )
	nLinha+=50
	oPrint:Say(nLinha,080,"Observações: ",oFont14n)
	If Len(aObs)>0
		For nObs := 1 To Len(aObs)
			If nLinha>=2700
				oPrint:EndPage()
				oPrint:StartPage()
				oPrint:SayBitMap( 0010 , 1950 , cBmp , 350 , 230 )

				oPrint:Box( 260, 050 , 2950 , 2350 , "-4")
				oPrint:Say(0110,050,"PEDIDO DE COMPRA",oFont16n)
				oPrint:Say(0160,050,"Nº "+cNumPed,oFont16n)

				oPrint:SayAlign( 0260, 060, "ALLCARE ADMINISTRADORA DE BENEFICIOS SÃO PAULO LTDA", oFont14n, 2350, 050 , 0, 2, 0)
				oPrint:Line(0310,050,0310, 2350 , /*nColor*/ , "-4" )
				nLinha:=360
			Endif
			nLinha+=50
			oPrint:Say(nLinha,060 , "Item: "+aObs[nObs][1]+" - "+aObs[nObs][2] ,oFont14)
		Next
	Endif
	nLinha+70
	oPrint:Line(nLinha,050,nLinha, 2350 , /*nColor*/ , "-4" )

	oPrint:Line(2740,0050, 2740 , 2350 , /*nColor*/ , "-4" )
	oPrint:Say(2790,060,"Status do Pedido: "+iif(Alltrim(SC7->C7_CONAPRO)=="B","Bloqueado","Aprovado"),oFont14n)
	oPrint:Say(2840,060,"Departamento de Compras",oFont14n)
	oPrint:Say(2890,060,Alltrim(SM0->M0_NOMECOM),oFont14n)
	oPrint:Say(2940,060,"Telefone: "+Transform(SY1->Y1_TEL,"@R (99) 9999-9999") + " - Ramal: "+SY1->Y1_XRAMAL ,oFont14n)


	oPrint:EndPage()

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

Static Function ATEnvMail(cHtml,cEmail,cSubject,aAnexos)

	Local lResult    	:= .T.
	Local cError     	:= ""
	Local cTo      		:= ""
	Local lAuth    		:= .T.//GetMv("MV_RELAUTH")
	Local cMailConta	:= Alltrim(GetMv("MV_RELACNT" ,, "noreply@allcarebeneficios.com.br" ))
	Local cMailServer	:= Alltrim(GetMv("MV_RELSERV" ,, "email-smtp.sa-east-1.amazonaws.com:587" ))
	Local cUserAuth     := Alltrim(GetMv("MV_USLOGIN" ,, "AKIAXX5CDJRVTL4JIVCW" ))
	Local cMailSenha 	:= Alltrim(GetMv("MV_RELPSW"  ,, "BHO17VGje1REGXDXfwYC330dCBYKITJ9nltaycKpaIXH" ))
	Local cAnexos		:= ""
	Local nI:=1
	Local lOk := .F.

	Default aAnexos     := {}

	cTo	:= RTrim(cEmail)

	If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha)

	/*
		Endereço de e-mail: noreply@allcarebeneficios.com.br
		Server Name: email-smtp.sa-east-1.amazonaws.com
		Port: 587
		Login: AKIAXX5CDJRVTL4JIVCW
		Senha: BHO17VGje1REGXDXfwYC330dCBYKITJ9nltaycKpaIXH
		TLS Ativo
	*/

		CONNECT SMTP SERVER "email-smtp.sa-east-1.amazonaws.com:587" ACCOUNT "AKIAXX5CDJRVTL4JIVCW" PASSWORD "BHO17VGje1REGXDXfwYC330dCBYKITJ9nltaycKpaIXH" RESULT lResult

		If lResult
			If lAuth
				lResult := MailAuth( cUserAuth , cMailSenha )
			EndIf
			If lResult
				lOk := .T.
				If Len(aAnexos)>0
					cAnexos:=''
					For nI:=1 to Len(aAnexos)
						CpyT2S( cDirTmp+aAnexos[nI] , cCaminho , .F. )
						cAnexos += If(!Empty(cAnexos),",","")+cCaminho+aAnexos[nI]
					Next
				Endif

				SEND MAIL  				;
					FROM	"noreply@allcarebeneficios.com.br" 	;
					TO		cTo			;
					SUBJECT	cSubject	;
					BODY	cHtml		;
					ATTACHMENT cAnexos      ;
					RESULT	   lResult
				
				If !lResult
					GET MAIL ERROR cError
					cError := cError+".Falha no Envio do e-mail."
					If (!IsBlind())
						ALERT(cError)
					Else
						Conout(cError)
					Endif
				Else
					Aviso("Atenção","Envio do pedido de compra "+cNumPed+" realizado com sucesso para "+cTo,{"Ok"},2)
				EndIf

			Else
				//Erro na autenticacao da conta
				GET MAIL ERROR cError
				cError := cError+".Falha no Envio do e-mail."
				If (!IsBlind())
					ALERT(cError)
				Else
					Conout(cError)
				Endif
			Endif
		Else
			GET MAIL ERROR cError
			cError := cError+".Falha no Envio do e-mail."
			If (!IsBlind())
				ALERT(cError)
			Else
				Conout(cError)
			Endif
		Endif
	Endif

	If lOk
		DISCONNECT SMTP SERVER
	EndIf

Return()

/*/{Protheus.doc}''
''
@author Sergio Celestino
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/
Static Function fCotacao()
	Local cQuery := ""

	cQuery := " SELECT DISTINCT C8_NUM "
	cQuery += " FROM "+RetSqlName("SC8")+" SC8 "
	cQuery += " WHERE "
	cQuery += " C8_FILIAL='"+xFilial("SC7")+"' AND C8_NUMPED='"+cNumPed+"' AND D_E_L_E_T_= ' ' "

	If Select("TRX")>0
		dbSelectArea("TRX")
		dbCloseArea()
	Endif

	TcQUery cQuery New Alias "TRX"

	TRX->(dbGotop())

Return TRX->C8_NUM
