#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"     
#INCLUDE "TOPCONN.CH"    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ACWFA005  บAutor  ณMarcus Ferraz      บ Data ณ  06/01/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para reenvio do workflow de compras 	 	          บฑฑ
ฑฑบ          ณ 													          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DFS Sistemas                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ACWFA005()
    
Local aAreaSC7 := GetArea()  
Local _cNUmPed := SC7->C7_NUM
Local _cQuery  := ""
          
Private _lReenvio := .T.

If MsgYesNo("Confirma reenvio do workflow de aprova็ใo para o pedido: "+_cNUmPed+" ?" )	     
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEncerra o processo anterior antes do reenvioณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	_cQuery  := " SELECT C7_WFID FROM "+RetSqlName("SC7")+" "
	_cQuery  += " WHERE C7_NUM = '"+_cNUmPed+"' "
	_cQuery  += " AND D_E_L_E_T_ <> '*' "
	_cQuery  += " AND C7_FILIAL = '"+xFilial("SC7")+"' "
	_cQuery  += " AND C7_CONAPRO <> 'L' "
	
	If Select("TSQL") > 0
		TSQL->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery), "TSQL",.T.,.T.)
	
	dbSelectArea("TSQL")
	TSQL->(dbGotop())
	
	While TSQL->(!Eof())	
		u_ACWFA006( TSQL->C7_WFID )	     
		TSQL->(dbSkip())
	EndDo	
	
	u_WFW120P()
	MsgInfo("WorkFlow enviado com sucesso!")
EndIf	

RestArea(aAreaSC7)

Return
