#INCLUDE "PROTHEUS.CH" 	
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

User Function MTDESCRNFE()

	Local cMsgNf := ""
	
	If Existblock('EFAT001')
		cMsgNf := ExecBlock('EFAT001',.F.,.F.,{})
	Endif
	
Return cMsgNf