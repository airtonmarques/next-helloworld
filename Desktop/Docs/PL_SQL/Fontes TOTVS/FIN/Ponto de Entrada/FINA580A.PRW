#Include "Totvs.ch"


/*/{Protheus.doc}'FINA580A'
'Ponto de Entrada na Liberação do Titulo a Pagar ( Automatica ) '
@author Ovio Consultoria
@since ''
@version ''
@type function Libera os titulos de impostos.
@see ''
@obs ''
@param ''
@return ''
/*/     

User Function FINA580A
Local aAreaSE2:= SE2->(GetArea())
Local cChave  := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)

dbSelectArea("SE2")
dbSetOrder(17)//(prefixo+número+parcela+tipo+fornecedor+loja).
If dbSeek(xFilial("SE2")+ cChave)
    While SE2->(!Eof()) .And. Alltrim(cChave) == Alltrim(SE2->E2_TITPAI)
        Reclock("SE2",.F.)
        SE2->E2_DATALIB	:= dDataBase
		SE2->E2_USUALIB   := cUsername
		SE2->E2_STATLIB := "03"
		SE2->E2_CODAPRO := Fa006User( __cUserId, .F., 2 )
        MsUnlock()
        SE2->(dbSkip())
    End
Endif

RestArea(aAreaSE2)

Return
