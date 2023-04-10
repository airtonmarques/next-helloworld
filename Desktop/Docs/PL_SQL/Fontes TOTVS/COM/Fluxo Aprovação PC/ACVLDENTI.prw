
#include 'protheus.ch'
#include 'parmtype.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ACRENVWF    ºAutor  ³Marcus Ferraz    º Data ³  28/07/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Rotina para reenviar worklofw de compras não aprovados    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Allcare                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
	Aviso("Entidade Não Permitida","Solicitante sem permissão para utulizar este "+Iif(nEnt==1,"Centro de Custo ","Item Conta ")+"!")
EndIf
                                                                                                     	
return lRet