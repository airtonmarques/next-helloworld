#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FAT290SE5 ºAutor  ³DFS SISTEMAS        º Data ³  26/11/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada após Baixa por aglutinacao de titulos      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Allcare       se                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FAT290SE5()

 Local aRet := aClone(ParamIxb) 
 Local nX := 1 
 Local nPosFil	:= Ascan(aRet[nX], {|nCmp| Alltrim(nCmp[1]) = "E5_FILIAL"	})
 Local nPosPrf	:= Ascan(aRet[nX], {|nCmp| Alltrim(nCmp[1]) = "E5_PREFIXO"	})
 Local nPosNum	:= Ascan(aRet[nX], {|nCmp| Alltrim(nCmp[1]) = "E5_NUMERO"	})
 Local nPosTip	:= Ascan(aRet[nX], {|nCmp| Alltrim(nCmp[1]) = "E5_TIPO"		}) 
 Local nPosFor	:= Ascan(aRet[nX], {|nCmp| Alltrim(nCmp[1]) = "E5_CLIFOR"	})
 Local nPosloj	:= Ascan(aRet[nX], {|nCmp| Alltrim(nCmp[1]) = "E5_LOJA"		})
 
 For nX := 1 to Len(aRet)
 	
 	cChave := aRet[nX][nPosFil][2]+aRet[nX][nPosPrf][2]+aRet[nX][nPosNum][2]+aRet[nX][nPosTip][2]+aRet[nX][nPosFor][2]+aRet[nX][nPosloj][2]
 	
 	DbSelectArea("SZ1")
	SZ1->(DbGoTop())
	SZ1->(DbOrderNickName("Z1F1"))//Z1_FILIAL+Z1_PREFIXO+Z1_NUM+Z1_TIPO+Z1_FORNECE+Z1_LOJA+ 
	If SZ1->(DbSeek(cChave)) //Z1_FILIAL+Z1_PREFIXO+Z1_NUM+Z1_FORNECE+Z1_LOJA
		Do While SZ1->(!EOF()) .and. cChave == SZ1->(Z1_FILIAL+Z1_PREFIXO+Z1_NUM+Z1_FORNECE+Z1_LOJA)
			RecLock("SZ1",.F.)
			SZ1->Z1_FATURA := SE2->E2_FATURA
			SZ1->(MsUnlock())
			SZ1->(DbSkip())
		EndDo
	EndIf
 Next nX

Return
