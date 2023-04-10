#Include "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT103IPC  �Autor  �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada para gravar campos customizados na        ���
���          �importacao da nota discal de entrada                        ���
�������������������������������������������������������������������������͹��
���Uso       � Allcare - SIGAEST - MATA103                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MT103IPC

	Local nPosDes := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_XDESC" } ) //Descri��o do Produro
	Local nPosCod := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_COD"     } ) //Codigo do Produto
	Local nItem   := ParamIXB[1]	
	Local aArea   := GetArea()
	
	if nPosDes > 0 .and. nPosCod > 0
	   aCols[nItem][nPosDes] := Posicione( "SB1" , 1 , xFilial("SB1") + aCols[nItem][nPosCod] , "B1_DESC" )
	endif
  
	RestArea(aArea)
	
Return		   