#INCLUDE "TOTVS.CH"

USER FUNCTION FA050GRV

    If FunName(0)$"MATA103/MATA140"
        Reclock("SE2",.F.)
        SE2->E2_DATALIB := dDatabase
        MsUnlock()
    Endif

Return
