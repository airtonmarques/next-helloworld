
#include 'protheus.ch'
#include 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ACRENVWF    �Autor  �Marcus Ferraz    � Data �  28/07/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Rotina para reenviar worklofw de compras n�o aprovados    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Allcare                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

user function ACVALIDCC(nEnt)

//Local nPosCC 	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CC'})
//Local nPosItC 	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_ITEMCTA'})
Local lRet 		:= .F. 

DbSelectArea("DBK")
DBK->(DbGoTop())
DBK->(DbSetOrder(1))//DBK_FILIAL+DBK_USER+DBK_GRUSER+DBK_GRUPO+DBK_PRODUT+DBK_ITEM


If DBK->(DbSeek(xFilial("DBK")+RetCodUsr()))
	Do While (!DBK->(EOF()) .and. DBK->DBK_USER == RetCodUsr())
		If !lRet		
			If nEnt == 1
				If Alltrim(DBK->DBK_CC) == "*" .Or. Empty(Alltrim(DBK->DBK_CC))
					lRet := .T.
				Else
					If Alltrim(DBK->DBK_CC) == Alltrim(M->C1_CC)
						lRet := .T.
					EndIf
				EndIf
			EndIf
			
			If nEnt == 2
				If Alltrim(DBK->DBK_ITEMCTA) == "*" .Or. Empty(Alltrim(DBK->DBK_ITEMCTA))
					lRet := .T.
				Else
					If Alltrim(DBK->DBK_ITEMCTA) == Alltrim(M->C1_ITEMCTA)
						lRet := .T.
					EndIf
				EndIf
			EndIf
		EndIf
		DBK->(DbSkip())
	EndDo
EndIf


If !lRet
	Aviso("Entidade N�o Permitida","Solicitante sem permiss�o para utulizar este "+Iif(nEnt==1,"Centro de Custo ","Item Conta ")+"!")
EndIf
                                                                                                     	
return lRet