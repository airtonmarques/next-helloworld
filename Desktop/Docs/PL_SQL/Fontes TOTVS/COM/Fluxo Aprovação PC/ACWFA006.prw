#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"     
#INCLUDE "TOPCONN.CH"    
/*
����������������������������������������������������������������������������� 
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ACWFA006  �Autor  �Marcus Ferraz      � Data �  06/01/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para finalizar processo em aberto do fluxo          ���
���Desc.     � de aprovacao										          ���
�������������������������������������������������������������������������͹��
���Uso       � Smith                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ACWFA006( _cIdWF )

Local _cCodProc 	:= GetNewPar("MV_XFINPWF","000001")    
Local nTaskID   	:= 1 
Local cFindKey  	:= ""
Local nEV_FINISH 	:= 99
Local cEvent        := ""

dbSelectArea( "WF3" )
WF3->(dbSetOrder(1))

While WF3->(dbSeek( cFindKey := xFilial("WF3") + Padr(_cIdWF + "." + StrZero( nTaskID, 2 ), TamSx3("WF3_ID")[1])))
	If !WF3->(dbSeek( cFindKey + StrZero( nEV_FINISH, 6 ) ))
		cEvent := WFLogEvent( nEV_FINISH, "", asString( _cIdWF ), asString( StrZero( nTaskID, 2 ) ) )
		if RecLock( "WF3",.T. )
			WF3_FILIAL	:= xFilial( "WF3" )
			WF3_ID			:= Lower ( _cIdWF + "." + AsString( StrZero( nTaskID, 2 ) ) )
			WF3_PROC		:= _cCodProc
			WF3_STATUS		:= strZero( nEV_FINISH, 6 )
			WF3_HORA		:= time()
			WF3_DATA		:= msdate()
			WF3_DESC		:= cEvent
			MSUnlock("WF3")   
		endif
	EndIf
	nTaskID++
EndDo

DbSelectArea("WFA")
WFA->(dbSetOrder(2))
If WFA->(MsSeek(xFilial("WFA")+_cIdWF))
	Do While !WFA->(EOF()) .And. Substr(WFA->WFA_IDENT,1,8) == _cIdWF
	    ConOut("**********************************************  Matando Processo do Workflow *****************************************")
		Reclock("WFA",.F.)
		WFA->WFA_TIPO := "4"
		WFA->(MsUnlock())
		WFA->(DbSkip())
	EndDo
EndIf 

			
Return
