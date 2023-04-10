#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"     
#INCLUDE "TOPCONN.CH"    
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ACWFA005  �Autor  �Marcus Ferraz      � Data �  06/01/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para reenvio do workflow de compras 	 	          ���
���          � 													          ���
�������������������������������������������������������������������������͹��
���Uso       � DFS Sistemas                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ACWFA005()
    
Local aAreaSC7 := GetArea()  
Local _cNUmPed := SC7->C7_NUM
Local _cQuery  := ""
          
Private _lReenvio := .T.

If MsgYesNo("Confirma reenvio do workflow de aprova��o para o pedido: "+_cNUmPed+" ?" )	     
		
	//��������������������������������������������Ŀ
	//�Encerra o processo anterior antes do reenvio�
	//����������������������������������������������
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
