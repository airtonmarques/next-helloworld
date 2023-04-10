#Include "Totvs.ch"

User Function MyCriatab()

Processa({|| Execproc() })

RETURN


Static Function Execproc()

ProcRegua(LastRec())

dbSelectArea("SX2")
dbSetOrder(1)
dbGotop()

While SX2->(!Eof())

  IncProc("Criando tabela "+SX2->X2_CHAVE)

  dbSelectArea(SX2->X2_CHAVE)
  dbSetOrder(1)

  SX2->(dbSkip())

End

Return
