#INCLUDE "TOTVS.CH"

USER FUNCTION MT161PRO
    Local aPropo := ParamIxb[1]

    oFont	:= TFont():New("Cambria",9,16,.T.,.T.,5,.T.,5,.T.,.F.)

    oPanel5:cCaption := "Selecionar os itens na primeira coluna"
    oPanel6:cCaption := "Selecionar os itens na primeira coluna"
    oPanel5:cToolTip := "Selecionar os itens na primeira coluna"
    oPanel6:cToolTip := "Selecionar os itens na primeira coluna"

    oSayTop	:= TSay():New( 005, 005, { || "(X)" }, oPanel5, , oFont , , , , .T., CLR_WHITE,,100,011,,,,,,.F.,,)
    oSayTop	:= TSay():New( 005, 005, { || "(X)" }, oPanel6, , oFont , , , , .T., CLR_WHITE,,100,011,,,,,,.F.,,)

Return aPropo
