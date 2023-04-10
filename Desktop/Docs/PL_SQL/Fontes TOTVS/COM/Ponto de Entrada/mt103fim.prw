#INCLUDE "protheus.ch"
/**************************************************************************************************
Funcao:
MT103FIM

Descrição:
Ponto de entrada para gravar os campos : 

 SE2_CCD    - SD1_CC
 SE2_CCC    - SD1_ITEM
 SE2_ITEMD  - SD1_CC
 SE2_ITEMC  - SD1_ITEM
 SE2_CLVL   - SD1_CLVL

Parâmetros:

Retorno:
Nenhum 
**************************************************************************************************/

User Function MT103FIM()  

Local aArea          := GetArea()
Local nPosD1_CC      := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_CC"})		//Centro de Custo
Local nPosD1_ITEMCC  := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_ITEMCTA"}) 	//Item contabil
Local nPosD1_CLVL    := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_CLVL"}) 	//Classe Valor
Local cDOC           := SF1->F1_DOC
Local cFornece       := SF1->F1_FORNECE
Local cLoja          := SF1->F1_LOJA      
Local cSerie         := SF1->F1_SERIE  
Local cTipo          := SF1->F1_TIPO
Local cICC           := Iif(len(aCols)>=1 .and. nPosD1_CC   >= 1 ,aCols[1][nPosD1_CC]  ,'')
Local cItCC          := Iif(len(aCols)>=1 .and. nPosD1_ITEM >=1  ,aCols[1][nPosD1_ITEM],'')
Local cItCV          := Iif(len(aCols)>=1 .and. nPosD1_clvl >=1  ,aCols[1][nPosD1_CLVL],'')
Local nUsado1        := Len(aHeader)
Local nOpcao         := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina 
Local nConfirma      := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFE 

Local cPrefixo	:= GetNewPar("MV_2DUPREF","")   

Local aSED := SED->(GetArea())

cPrefixo := PadR(If(!Empty(cPrefixo),&(cPrefixo),cSerie),Tamsx3("E2_PREFIXO")[1])

If nOpcao = 3 .and. nConfirma = 1
	DbSelectArea("SE2")
	Dbsetorder(6)                                               
	If !DbSeek(xFilial("SE2")+ cFornece + cLoja + cPrefixo + cDoc ,.T.)
		If !Empty(GetNewPar("MV_2DUPREF",""))
			cPrefixo := PadR(RTrim(SF1->F1_FILIAL),Tamsx3("E2_FILIAL")[1])
			DbSeek(xFilial("SE2")+ cFornece + cLoja + cPrefixo + cDoc ,.T.)
		EndIf	
	EndIf	
	
	IF SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) = (xFilial("SE2")+cFornece+cLoja+cPrefixo+cDoc)
		While !Eof() .And. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) = (xFilial("SE2")+cFornece+cLoja+cPrefixo+cDoc)
			
			Reclock("SE2",.F.)
			SE2->E2_CCD   	:= cICC
			SE2->E2_CCC   	:= cICC
			SE2->E2_CCUSTO	:= cICC
			SE2->E2_ITEMCTA := cITCC
			SE2->E2_ITEMD 	:= cITCC
			SE2->E2_ITEMC 	:= cITCC
			SE2->E2_CLVL  	:= cItCV
			Msunlock()
			
			DbSkip()
		End
	EndiF  
	
Endif   

RestArea(aArea)
RestArea(aSED)
         
Return(.T.)
