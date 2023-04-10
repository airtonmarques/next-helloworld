#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"     
#INCLUDE "TOPCONN.CH"    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ACWFA003  บAutor  ณMarcus Ferraz      บ Data ณ  28/07/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para validar centro de custo na digitacao  	      บฑฑ
ฑฑบ          ณ do pedido de compras								          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Allcare                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ACWFA003()

Local cCusto 	:= &__ReadVar
Local lRet   	:= .T.
//Local lApvCC 	:= GetNewPar("MV_PCAPVCC",.F.)
Local lAtivApr	:= GetNewPar("MV_XATVAPR",.T.)
//Local lForApvCC := IIF(Posicione("SA2",1,XFILIAL("SA2")+cA120Forn+cA120Loj,"A2_XTPAPR")=="1",.F.,.T.)
                                              
If lAtivApr
	
	dbSelectarea("DBL")
	dbSetOrder(2)
	lRet := MsSeek(xFIlial("DBL")+aCols[_nY][_nPosCC],.F.)

	If !lRet 
		Aviso("Aviso","Nใo existe Grupo de aprovador cadastrado para o centro de custo "+cCusto+"! ",{"&OK"},1)
	EndIf
EndIf	

Return( lRet )