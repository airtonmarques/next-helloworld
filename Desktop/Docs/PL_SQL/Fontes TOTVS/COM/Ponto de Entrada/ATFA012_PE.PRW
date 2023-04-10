#Include "Totvs.ch"
#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE ENTER Chr(13)+Chr(10)

/*

  Ponto de ENtrada para gravar a OBS do Pedido de compra no Ativo FIxo

*/
 
User Function ATFA012
Local aParam  := PARAMIXB
Local lRet    := .T.
Local oObj    := ''
Local cIdPonto:= ''
Local cIdModel:= ''
 
If aParam <> Nil 


  oObj := aParam[1]
  cIdPonto := aParam[2]
  cIdModel := aParam[3]

  If cIdPonto == 'FORMPOS'
  
    oModelx := FWModelActive() //Carregando Model Ativo

    oModelSN1:= oModelx:GetModel("SN1MASTER")
    oModelSN3:= oModelx:GetModel("SN3DETAIL")
    
    cD1_FILIAL  := xFilial("SD1")
    cN1_NFISCAL := oModelSN1:getValue('N1_NFISCAL')
    cN1_NSERIE  := oModelSN1:getValue('N1_NSERIE')
    cN1_FORNECE := oModelSN1:getValue('N1_FORNEC')
    cN1_LOJA    := oModelSN1:getValue('N1_LOJA')
    cN1_PRODUTO := oModelSN1:getValue('N1_PRODUTO')
    cN1_NFITEM  := oModelSN1:getValue('N1_NFITEM')
    cN3_DESCEST := oModelSN3:getValue('N3_DESCEST')
    
    aAreaSC7 := SC7->(GetArea())
    aAreaSD1 := SD1->(GetArea())
    dbSelectArea("SD1")
    dbSetOrder(1) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
    If dbSeek(;
              cD1_FILIAL  +;
              cN1_NFISCAL +;
              cN1_NSERIE  +;
              cN1_FORNECE +;
              cN1_LOJA    +;
              cN1_PRODUTO +;
              cN1_NFITEM   )

      dbSelectArea("SC7")
      dbSetOrder(1)
      If dbSeek(SD1->(D1_FILIAL+D1_PEDIDO+D1_ITEMPC))
        If Empty(cN3_DESCEST)
          cN3_DESCEST += Alltrim(SC7->C7_OBSM)
        Endif
      Endif    
      oModelSN3:setValue('N3_DESCEST',cN3_DESCEST)
    Endif
  EndIf
Endif

Return lRet


