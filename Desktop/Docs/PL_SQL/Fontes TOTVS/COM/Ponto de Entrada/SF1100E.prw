#INCLUDE "totvs.ch"
#INCLUDE 'Protheus.ch'
#INCLUDE 'Topconn.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SF1100E   �Autor  �DFS Sistemas        � Data �  14/08/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �Elimina registros de rubricas na importacao                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function SF1100E()

Local _cChave := xFilial("SZ1")+SF1->(F1_SERIE+F1_DOC+F1_FORNECE+F1_LOJA) //Z1_FILIAL+Z1_PREFIXO+Z1_NUM+Z1_FORNECE+Z1_LOJA

DbSelectArea("SZ1")
SZ1->(DbSetOrder(3))
If SZ1->(DbSeek(_cChave))
	While SZ1->(!Eof()) .and. _cChave==SZ1->(Z1_FILIAL+Z1_PREFIXO+Z1_NUM+Z1_FORNECE+Z1_LOJA)
		RecLock("SZ1",.F.)
		SZ1->(DbDelete())
		SZ1->(DbSkip())
	End
Endif

Return()