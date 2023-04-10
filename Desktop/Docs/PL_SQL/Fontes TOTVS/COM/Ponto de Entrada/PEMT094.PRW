#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

User Function MATA094 ()
    Local aParam := PARAMIXB
    Local xRet := .T.
    Local oObj := ""
    Local cIdPonto := ""
    Local cIdModel := ""
    Local lIsGrid := .F.
    Private cThread		:= AllTrim(Str(ThreadID()))
    If (aParam <> NIL)
        oObj := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid := (Len(aParam) > 3)

        nOpc := oObj:GetOperation() // PEGA A OPERAÇÃO

        If (cIdPonto =="BUTTONBAR")
            xRet := {{"Documentos", "Documentos", {||  u_fOtherDocs() }}}
        EndIf
        If cIdPonto == 'MODELCOMMITNTTS'
			U_WFSC1(1)// 1 - ENVIO PC PARA APROVADORES
			U_WFSC1(3)// 3 - ENVIO PC ITENS APROVADOS PARA SOLICITANTE
			U_WFSC1(4)// 4 - ENVIO PC ITENS REPROVADOS PARA SOLICITANTE

		EndIf
    EndIf
Return (xRet)
