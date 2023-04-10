#INCLUDE "TOTVS.CH"

User Function MT161TOK
Local lRet  := .T.
Local aPropostas := ParamIxb[2]
Local nProps := 1
Local nPag := 1
Local nItens := 1

Public __cMotivo := Space(TamSX3("C8_MOTIVO")[1])

bValid := {|| !Empty(__cMotivo) }

aRetPe:={}

For nPag := 1 To Len(aPropostas)
    For nProps := 1 To Len(aPropostas[nPag]) 
        If Len(aPropostas[nPag][nProps][1])>0
            cFornece := aPropostas[nPag][nProps][1][1]+aPropostas[nPag][nProps][1][2]
        Else
            cFornece := ""
        Endif
        nWin := 0
        For nItens := 1 To Len(aPropostas[nPag][nProps][2])
            If aPropostas[nPag][nProps][2][nItens][1]
                nWin+=1
            Endif
        Next
        if aScan(aRetPe,{|x| Alltrim(x[1])==cFornece})==0
            aAdd(aRetPe,{cFornece,iif(Empty(cFornece),-1,nWin),nPag,nProps})
        Endif
    Next
Next

aSort(aRetPe,,,{|x,y| x[2] > y[2] })

If Len(aRetPe)>0
    If __cForVenc <> aRetPe[1][1]

        DEFINE MSDIALOG oTela FROM 0, 0 To 300,520 Title "Motivo de alteração de Vencedor"  Of GetWndDefault() PIXEL STYLE DS_MODALFRAME STATUS 
		
        oTPane1 := TPanel():New(0,0,"",oTela,NIL,.T.,.F.,NIL,NIL,0,20,.T.,.T.)
        oTPane1:Align := CONTROL_ALIGN_TOP
                                                                
        @ 010 ,010 Say "Prezado(a) cotador, foi alterado o fornecedor vencedor na cotação. Informar o motivo para prosseguir" Size 500,8  Of oTPane1 PIXEL COLOR CLR_HRED
                    
        oTPane2 := TPanel():New(0,0,"",oTela,NIL,.T.,.F.,NIL,NIL,0,0,.T.,.F.)
        oTPane2:Align := CONTROL_ALIGN_ALLCLIENT

        oGetObs:= TGet():New(005,005 ,{|u| If(PCount()>0,__cMotivo:=u,__cMotivo)},oTPane2,220,16, '@!', bValid, 0,,/*oFont4*/,.F.,,.T.,,.F.,,.F., .F.,,.F., .F.,, "oTPane2",,,,,,, "Motivo: " ,2 ,  /*oFont4*/ , /*CLR_RED*/,,,)
                    
        Activate MsDialog oTela Centered On Init EnchoiceBar(oTela, {|| IIF(!Empty(__cMotivo),oTela:End(),Alert("Preencher Motivo!")) } , {|| lRet:=.F.,oTela:End() } ) 
    Endif    
Endif

Return lRet
