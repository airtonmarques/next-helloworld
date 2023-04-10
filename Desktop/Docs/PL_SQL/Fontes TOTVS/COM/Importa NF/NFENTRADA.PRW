
/*

https://centraldeatendimento.totvs.com/hc/pt-br/articles/360025397031-MP-SIGACOM-Documento-de-Entrada-Rotina-Autom%C3%A1tica-MATA103-EXECAUTO-

MP - SIGACOM - Documento de Entrada (Rotina Automática MATA103 - EXECAUTO)
Atualizado em:
28 de abril de 2021 11:42


Dúvida
Como posso criar o Execauto da rotina MATA103 - Documento de Entrada?


Ambiente
Protheus – Compras – A partir da versão 12.17

Solução
Para sanar essa dúvida, siga o exemplo abaixo:
*/

//DOCUMENTO TIPO NORMAL

#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"

User Function EXEC103()

Local aCab := {}
Local aItem := {}
Local aItens := {}
Local aItensRat := {}
Local aCodRet := {}
Local nOpc := 3 
Local cNum := ""
Local nI := 0
Local nX := 0
Local nReg := 1

Conout("Inicio: " + Time())

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.


cNum := "" // Colocar o Nr da Nota de TESTE AQUI
SF1->(dbSetOrder(1)) 


//Cabeçalho
aadd(aCab,{"F1_TIPO"    ,"N"     ,NIL})
aadd(aCab,{"F1_FORMUL"  ,"N"     ,NIL})
aadd(aCab,{"F1_DOC"     ,cNum    ,NIL})
aadd(aCab,{"F1_SERIE"   ,"1"     ,NIL})
aadd(aCab,{"F1_EMISSAO" ,DDATABASE ,NIL})
aadd(aCab,{"F1_DTDIGIT" ,DDATABASE ,NIL})
aadd(aCab,{"F1_FORNECE" ,"001 ",NIL})       //colocar o codigo do fornecedor aqui
aadd(aCab,{"F1_LOJA"    ,"01"  ,NIL})       //colocar a loja   do fornecedor aqui
aadd(aCab,{"F1_ESPECIE" ,"NFE" ,NIL})       //Colocar a Especie do Documento aqui
aadd(aCab,{"F1_COND"    ,"001" ,NIL})       //Colocar a Condicao de pagamento aqui
aadd(aCab,{"F1_DESPESA" , 0    ,NIL})
aadd(aCab,{"F1_DESCONT" , 0    ,Nil})
aadd(aCab,{"F1_SEGURO"  , 0    ,Nil})
aadd(aCab,{"F1_FRETE"   , 0    ,Nil})
aadd(aCab,{"F1_MOEDA"   , 1    ,Nil})
aadd(aCab,{"F1_TXMOEDA" , 1    ,Nil})
aadd(aCab,{"F1_STATUS" , "A"   ,Nil})

//Itens - Prencher conforme necessidade do teste
For nX := 1 To 1
   aItem := {}
   aadd(aItem,{"D1_ITEM" ,StrZero(nX,4) ,NIL})
   aadd(aItem,{"D1_COD" ,PadR("0001",TamSx3("D1_COD")[1]) ,NIL})
   aadd(aItem,{"D1_UM" ,"UN" ,NIL})
   aadd(aItem,{"D1_LOCAL" ,"01" ,NIL})
   aadd(aItem,{"D1_QUANT" ,1 ,NIL}) 
   aadd(aItem,{"D1_VUNIT" ,7508.33 ,NIL}) 
   aadd(aItem,{"D1_TOTAL" ,7508.33 ,NIL})
   aadd(aItem,{"D1_TES" ,"001" ,NIL})
   aadd(aItem,{"D1_RATEIO" ,"1" ,NIL}) 
   aAdd(aItens,aItem)
Next nX

//Rateio de Centro de Custo
aItem := {}
aAdd(aItensRat, Array(2))
aItensRat[Len(aItensRat)][1] := "0001"
aItensRat[Len(aItensRat)][2] := {}

aAdd(aItem, {"DE_FILIAL" , xFilial("SDE") , Nil})
aAdd(aItem, {"DE_ITEM" , StrZero(1,TamSx3("DE_ITEM")[1]) , Nil})
aAdd(aItem, {"DE_DOC" , cNum , Nil})
aAdd(aItem, {"DE_SERIE" , "1" , Nil})
aAdd(aItem, {"DE_FORNECE" , "001 " , Nil})
aAdd(aItem, {"DE_LOJA" , "01" , Nil})
aAdd(aItem, {"DE_ITEMNF" , "0001" , Nil})
aAdd(aItem, {"DE_PERC" , 100 , Nil})
aAdd(aItem, {"DE_CC" , "01" , Nil})
aAdd(aItensRat[Len(aItensRat)][2], aClone(aItem))

//Array contendo a informação se gera DIRF e os códigos de retenção por imposto
aAdd( aCodRet, {01, "0297", 1, "..."} )
aAdd( aCodRet, {02, "0297", 1, "IRR"} )
aAdd( aCodRet, {03, "5979", 1, "PIS"} )
aAdd( aCodRet, {04, "5960", 1, "COF"} )
aAdd( aCodRet, {05, "5987", 1, "CSL"} )

//3-Inclusão / 4-Classificação / 5-Exclusão
MSExecAuto({|x,y,z,a,b| MATA103(x,y,z,,,,,a,,,b)},aCab,aItens,nOpc,aItensRat,aCodRet)

If !lMsErroAuto
    alert(" Incluido NF: " + cNum)
Else
    MostraErro()
    ConOut("Erro na inclusao!")
EndIf

ConOut("Fim: " + Time())


Return
