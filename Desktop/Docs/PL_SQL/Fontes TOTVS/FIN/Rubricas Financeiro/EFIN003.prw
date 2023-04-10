#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EFIN003   �Autor  �DFS SISTEMAS        � Data �  06/08/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �ROTINA DE CONTABILIZACAO DE FATURAMENTO                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function EFIN003()

Local oSelf
Local aInfoCustom	:= {}
Local oProcess
Local cArquivo		:= ''
Local nTotalLcto 	:= 0

Private cTitulo		:= "Baixa de Rubricas - Contabilizacao"
Private cPergunte	:= "EFIN002"

//CriaSx1(cPergunte)
Pergunte(cPergunte,.T.)

Private xMv_01 := MV_PAR01
Private xMv_02 := MV_PAR02
Private xMv_03 := MV_PAR03
//Private xMv_04 := MV_PAR04

bProcess := {|oSelf| Contabiliza(oSelf) }

oProcess := tNewProcess():New("EFIN003",cTitulo,bProcess,"O objetivo desta rotina � contabilizar a baixa das rubricas.",cPergunte,aInfoCustom, .T.,5, "Descri��o do painel Auxiliar", .T. )

Return

Static Function Contabiliza(oProcess)

Local cArquivo	:= ""
Local cPadrao	:= ""
Local cLote		:= "008850"
Local aItens	:= {}
Local nThreads	:= GETNEWPAR( 'MV_THEF2', 50 )
Local lExec		:= .F.
Local lCtbOnLine := .T.
Local _lCont 	:= .T.
Local cAliasSE5 := GetNextAlias()
Local nRet := 0
Local lDigita := Iif(xMv_03 == 1, .T.,.F.)
Local cQuery := ""

Private nRegSE5

DEBITO 	:= 0
CREDITO := 0
_CONTA := ""

oProcess:SaveLog("Inicio da importa��o")

If Select(cAliasSE5) > 0
	cAliasSE5->(dbCloseArea())
EndIf

cQuery += " SELECT                                                                                            "
cQuery += " 	SE5.E5_FILIAL, SE5.E5_DATA, SE5.E5_PREFIXO,                                                   " 
cQuery += " 	SE5.E5_NUMERO, SE5.E5_TIPO, SE5.E5_PARCELA,                                                   " 
cQuery += " 	SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_TIPODOC,                                                   " 
cQuery += " 	SE5.E5_MOTBX, SE5.E5_DTDISPO,                                                                 " 
cQuery += " 	SE5.E5_BANCO,SE5.E5_AGENCIA,SE5.E5_CONTA,                                                     " 
cQuery += " 	SE5.R_E_C_N_O_ RECNOSE5                                                                       " 
cQuery += " 	FROM  SE5010 SE5, SA2010 SA2, SZ1010 SZ1 													  " 
cQuery += " 	WHERE SE5.D_E_L_E_T_ <> '*'                                                                   " 
cQuery += " 	AND SA2.D_E_L_E_T_ <> '*'                                                                     " 
cQuery += " 	AND SZ1.D_E_L_E_T_ <> '*'                                                                     " 
cQuery += " 	AND E5_DTDISPO BETWEEN '"+DTOS(xMv_01)+"' AND '"+DTOS(xMv_02)+"'                              " 
cQuery += " 	AND E5_FILORIG = '"+cFilAnt+"'                                                                " 
cQuery += " 	AND E5_TIPO = 'NF'                                                                            " 
cQuery += " 	AND E5_TIPODOC IN ('BA','VL','ES')                                                            " 
cQuery += " 	AND E5_SITUACA <> 'C'                                                                         " 
cQuery += " 	AND E5_MOTBX IN ('DEB','NOR','FAT')                                                           " 
cQuery += " 	AND A2_COD = E5_CLIFOR AND A2_LOJA = E5_LOJA                                                  " 
cQuery += "     AND E5_TIPO = Z1_TIPO                                                                         " 
cQuery += " 	AND E5_FILIAL = Z1_FILIAL                                                                     " 
cQuery += "     AND E5_PREFIXO = Z1_PREFIXO                                                                   " 
cQuery += " 	AND E5_NUMERO = Z1_NUM                                                                        " 
cQuery += "     AND E5_FORNECE = Z1_FORNECE                                                                   " 
cQuery += " 	AND E5_LOJA = Z1_LOJA                                                                         " 
cQuery += " 	AND E5_PARCELA = Z1_PARCELA                                                                   "
cQuery += " 	AND A2_GRUPO = 'OPE'                                                                          " 
cQuery += " 	AND Z1_LA <> 'S'                                                                              " 
cQuery += " GROUP BY                                                                                          " 
cQuery += "     SE5.E5_FILIAL, SE5.E5_DATA, SE5.E5_PREFIXO,                                                   " 
cQuery += " 	SE5.E5_NUMERO, SE5.E5_TIPO, SE5.E5_PARCELA,                                                   " 
cQuery += " 	SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_TIPODOC,                                                   " 
cQuery += " 	SE5.E5_MOTBX, SE5.E5_DTDISPO,                                                                 " 
cQuery += " 	SE5.E5_BANCO,SE5.E5_AGENCIA,SE5.E5_CONTA,                                                     " 
cQuery += " 	SE5.R_E_C_N_O_                                                                                " 
cQuery += " 	ORDER BY SE5.R_E_C_N_O_                                                                       " 					

IF SELECT(cAliasSE5)>0
	(cAliasSE5)->(dbCloseArea())
ENDIF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE5,.T.,.T.)

nRegSE5 := CountSE5()
oProcess:SetRegua1(nRegSE5)
nContSlote	:= 1
nContSE5	:= 1


DbSelectArea(cAliasSE5)

(cAliasSE5)->(DbGoTop())

While !(cAliasSE5)->(EOF())
	
	aTitFat		:= {}
	cChvTit		:= (cAliasSE5)->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
	JUROS		:= 0
	MULTA		:= 0
	DESCONTO	:= 0
	IRRF		:= 0
	PIS			:= 0
	COFINS		:= 0
	CSLL		:= 0
	
	If (cAliasSE5)->E5_TIPODOC <> 'ES'
		cPadrao = '102'
	Else
		cPadrao = '103'
	EndIf
	
	DbSelectArea("SE2")
	SE2->(DbGoTop())
	SE2->(DbSetOrder(1))
	SE2->( DbSeek(cChvTit) )
	IF (cAliasSE5)->E5_MOTBX <> 'FAT'
		dDataBase := StoD((cAliasSE5)->E5_DTDISPO)
		_lCont := .T.
		
		DbSelectArea("SA6")
		SA6->(DbGoTop())            	
		SA6->(DbSetOrder(1))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
		SA6->(dBSeek(xFilial("SA6")+(cAliasSE5)->(E5_BANCO+E5_AGENCIA+E5_CONTA)))
		
	Else
		
		aTitFat := GetAdvFVal("SE2",{"E2_FILIAL","E2_FATPREF","E2_FATURA","E2_PARCELA","E2_TIPOFAT","E2_FATFOR","E2_FATLOJ"},cChvTit,1)
				
		
		If len(aTitFat) > 1
			aBxFat := RetDtBxFat(aTitFat)
			If aBxFat[1]
				dDataBase := StoD(aBxFat[2])
				_lCont := .T.
				
				DbSelectArea("SA6")
				SA6->(DbGoTop())
				SA6->(DbSetOrder(1))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
				SA6->(dBSeek(xFilial("SA6")+(cAliasSE5)->(aBxFat[3]+aBxFat[4]+aBxFat[5])))
			Else
				_lCont := .F.
			EndIf
		Else
			_lCont := .F.
		EndIf
	EndIf
	
	If _lCont
		dbSelectArea('SA2')
		SA2->(DbGoTop())
		SA2->(dbSetOrder(1))
		SA2->(dbSeek(xFilial("SA2")+(cAliasSE5)->(E5_CLIFOR+E5_LOJA)))
		
		oProcess:IncRegua1("Processando Rubricas: " +str(nContSE5,5) +"/"+ str(nRegSE5,5))
		dbSelectArea('CT2')
		dbSetOrder(1)
		If !CT2->(dbSeek(xFilial('CT2')+dtos(xMv_01)+"008850"+Strzero(nContSlote,TamSx3("CT2_SBLOTE")[1])+alltrim((cAliasSE5)->E5_NUMERO)))
			lCtbOnLine := .T.
			nHdlPrv := HeadProva("008850","EFIN003",Subs(cUsuario,7,6),@cArquivo)
			If nHdlPrv <= 0
				lCtbOnLine := .F.
			EndIf
			If lCtbOnLine //.and. VerPadrao(cPadrao)
				nTotalLcto := 0
				DbSelectArea("SZ1")
				SZ1->(DbGoTop())
				//SZ1->(DbOrderNickName("Z1F1"))//Z1_FILIAL+Z1_PREFIXO+Z1_NUM+Z1_TIPO+Z1_FORNECE+Z1_LOJA
				SZ1->(DbOrderNickName("Z1PAR"))
				DEBITO  := 0
				If SZ1->(DbSeek((cAliasSE5)->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA))) //Z1_FILIAL+Z1_PREFIXO+Z1_NUM+Z1_FORNECE+Z1_LOJA
					nContSZ1	:= 1
					aItens		:= {}
					aRecnoSZ1	:= {}					
					//DbSelectArea("SZ0")
					//SZ0->(DbGoTop())
					//SZ0->(DbOrderNickName("SZ0RUBRICA"))
					//If SZ0->(DbSeek("    "+SZ1->Z1_RUBRICA))
					cAliasSZ1 := GetNextAlias()
					cQuery := "" 
					cQuery := " SELECT CONTA , SUM(VALOR) VALOR FROM "
					cQuery += "(SELECT  SUM(VALOR) VALOR, "	
					cQuery += " CASE "
					cQuery += " WHEN SUM(VALOR) <0 THEN '2136190110001       '"
					cQuery += " ELSE CONTA END AS CONTA"
					cQuery += "	FROM ( "
					cQuery += "		SELECT "
					cQuery += "		Z1_NUM, "
					cQuery += "		Z1_RUBRICA, "
					cQuery += "		Z0_DESCRI,  "
					cQuery += "		CASE  "
					cQuery += "			WHEN Z0_DC = 'C' AND Z0_NATRUBR = 'A' THEN Z0_CONTAC "
					cQuery += "			WHEN Z0_DC = 'D' AND Z0_NATRUBR = 'A' THEN Z0_CONTAC "
					cQuery += "			ELSE Z0_CONTAD "
					cQuery += "		END AS CONTA, "
					cQuery += "	CASE "
					cQuery += "		WHEN "
					cQuery += "			Z0_DC = 'C' AND Z0_NATRUBR = 'A' THEN Z1_TOTAL "
					cQuery += "		WHEN "
					cQuery += "			Z0_DC = 'D' AND Z0_NATRUBR = 'A' THEN Z1_TOTAL "
					cQuery += "		ELSE "
					cQuery += "			(Z1_TOTAL*-1) "
					cQuery += "	END AS VALOR "
					//cQuery += "		Z1_TOTAL VALOR "
					cQuery += "	FROM "
					cQuery += "		SZ1010 Z1, SZ0010 Z0 "
					cQuery += "	WHERE "
					cQuery += "		Z1.D_E_L_E_T_ <> '*' "
					cQuery += "		AND Z0.D_E_L_E_T_ <> '*' "
					cQuery += "		AND Z1_RUBRICA = Z0_RUBRICA "
					cQuery += "		AND Z1_FILIAL = '"+(cAliasSE5)->E5_FILIAL+"' "
					cQuery += "		AND Z1_PREFIXO = '"+(cAliasSE5)->E5_PREFIXO+"' "
					cQuery += "		AND Z1_NUM = '"+(cAliasSE5)->E5_NUMERO+"' "
					cQuery += "		AND Z1_TIPO = '"+(cAliasSE5)->E5_TIPO+"' "
					cQuery += "		AND Z1_PARCELA = '"+(cAliasSE5)->E5_PARCELA+"' "
					cQuery += "		AND Z1_FORNECE = '"+(cAliasSE5)->E5_CLIFOR+"' "
					cQuery += "		AND Z1_LOJA = '"+(cAliasSE5)->E5_LOJA+"' "
					cQuery += "		AND Z0_TOTALIZ = '1' "
					cQuery += "	) TRB "
					cQuery += "GROUP BY CONTA) GROUP BY CONTA  "
					
					If Select(cAliasSZ1) > 0
						(cAliasSZ1)->(dbCloseArea())
					EndIf
					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSZ1,.T.,.T.)
					
					DbSelectArea("SE5")
										
					DbSelectArea(cAliasSZ1)
					(cAliasSZ1)->(DbGoTop())
					DbGoTo((cAliasSE5)->RECNOSE5)
					While !(cAliasSZ1)->(EOF())
						If (cAliasSZ1)->VALOR > 0
							DEBITO	:= (cAliasSZ1)->VALOR
							_CONTA 	:= (cAliasSZ1)->CONTA
						    nTotalLcto += DetProva(nHdlPrv,cPadrao,"EFIN003",cLote)
							nContSZ1++
						Else
							DEBITO := 0
							_CONTA := ""
						EndIf
						(cAliasSZ1)->(DbSkip())
					EndDo
					
					aadd(aRecnoSZ1,SZ1->(Recno()))
					//EndIf
					nContSZ1++
					//While !SZ1->(EOF()) .and. SZ1->(Z1_FILIAL+Z1_PREFIXO+Z1_NUM+Z1_FORNECE+Z1_LOJA) == (cAliasSE5)->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_CLIFOR+E5_LOJA)
					//	SZ1->(dbSkip())
					//EndDo
				Else
					conout("N�o localizou titulo SZ1 "+(cAliasSE5)->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA))
				EndIf
				nRecSZ1 := SZ1->(Recno())
				SZ1->(dbGoBottom())
				SZ1->(dbSkip())
				If nTotalLcto > 0
					DbSelectArea("SE5")
					
					DbGoTo((cAliasSE5)->RECNOSE5)
					
					//Valor Rateado de Juros, Multa, Desconto e impostos
					If len(aTitFat) > 1
						If aBxFat[1]
							JUROS 		:= (aBxFat[7]/(aBxFat[14]-aBxFat[7]-aBxFat[8]+aBxFat[9]))*SE5->E5_VALOR     //Wagner 09/09/2019
							MULTA 		:= (aBxFat[8]/(aBxFat[14]-aBxFat[7]-aBxFat[8]+aBxFat[9]))*SE5->E5_VALOR		//Wagner 09/09/2019
							DESCONTO 	:= (aBxFat[9]/(aBxFat[14]-aBxFat[7]-aBxFat[8]+aBxFat[9]))*SE5->E5_VALOR		//Wagner 09/09/2019
							IRRF 		:= (aBxFat[10]/(aBxFat[14]-aBxFat[7]-aBxFat[8]+aBxFat[9]))*SE5->E5_VALOR	//Wagner 09/09/2019
							PIS 		:= (aBxFat[11]/(aBxFat[14]-aBxFat[7]-aBxFat[8]+aBxFat[9]))*SE5->E5_VALOR	//Wagner 09/09/2019
							COFINS 		:= (aBxFat[12]/(aBxFat[14]-aBxFat[7]-aBxFat[8]+aBxFat[9]))*SE5->E5_VALOR	//Wagner 09/09/2019
							CSLL 		:= (aBxFat[13]/(aBxFat[14]-aBxFat[7]-aBxFat[8]+aBxFat[9]))*SE5->E5_VALOR	//Wagner 09/09/2019
							CREDITO 	:= (SE5->E5_VALOR+JUROS+MULTA)-(DESCONTO+IRRF+PIS+COFINS+CSLL)
						EndIf			
					Else
						JUROS 		:= SE5->E5_VLJUROS
						MULTA 		:= SE5->E5_VLMULTA
						DESCONTO	:= SE5->E5_VLDESCO
						IRRF		:= SE2->E2_VRETIRF
						PIS			:= SE2->E2_VRETPIS
						COFINS		:= SE2->E2_VRETCOF
						CSLL		:= SE2->E2_VRETCSL
						CREDITO 	:= SE5->E5_VALOR
					EndIf			
					
					nTotalLcto += DetProva(nHdlPrv,cPadrao,"EFIN003",cLote)
					
					oProcess:IncRegua2("Incluindo movimento cont�bil.")
					RodaProva(nHdlPrv,nTotalLcto)
					
					// Envia para Lancamento Contabil
					cA100Incl(cArquivo,nHdlPrv,3,cLote,.F.,.F.)
					RecLock("SE5",.F.)
					SE5->E5_LA := "S"
					SE5->(MsUnlock())
				EndIf
				SZ1->(dbGoTo(nRecSZ1))
				Do While ! SZ1->(EOF()) .And. SZ1->(Z1_FILIAL+Z1_PREFIXO+Z1_NUM+Z1_PARCELA+Z1_TIPO+Z1_FORNECE+Z1_LOJA) == (cAliasSE5)->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
					RecLock("SZ1",.F.)
					SZ1->Z1_LA := "S"
					SZ1->(MsUnlock())
					SZ1->(DbSkip())
				EndDo
				SZ1->(dbGoTo(nRecSZ1))
			EndIf
		Else
			conout("Titulo Encontrado na CTB "+(cAliasSE5)->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) )
		EndIf
	EndIf
	lExec := .F.
	nTotalLcto := 0
	_lCont := .F.
	nContSE5++
	(cAliasSE5)->(DbSkip())
	//(cAliasSZ1)->(DbCloseArea())
	SE2->(DbCloseArea())
	SA6->(DbCloseArea())
	SA2->(DbCloseArea())
	CT2->(DbCloseArea())
	SZ1->(DbCloseArea())
	SE5->(DbCloseArea())
EndDo
(cAliasSE5)->(DbCloseArea())
oProcess:SetRegua1(nThreads)
oProcess:SetRegua2(1)
oProcess:IncRegua2("")
Return

Static Function CountSE5()
Local cAlias := GetNextAlias()
Local nRet := 0
Local cQuery := ""
cQuery += " SELECT COUNT(*) REG FROM (                                                                            "
cQuery += " SELECT                                                                                            "
cQuery += " 	SE5.E5_FILIAL, SE5.E5_DATA, SE5.E5_PREFIXO,                                                   " 
cQuery += " 	SE5.E5_NUMERO, SE5.E5_TIPO, SE5.E5_PARCELA,                                                   " 
cQuery += " 	SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_TIPODOC,                                                   " 
cQuery += " 	SE5.E5_MOTBX, SE5.E5_DTDISPO,                                                                 " 
cQuery += " 	SE5.E5_BANCO,SE5.E5_AGENCIA,SE5.E5_CONTA,                                                     " 
cQuery += " 	SE5.R_E_C_N_O_ RECNOSE5                                                                       " 
cQuery += " 	FROM  SE5010 SE5, SA2010 SA2, SZ1010 SZ1 													  " 
cQuery += " 	WHERE SE5.D_E_L_E_T_ <> '*'                                                                   " 
cQuery += " 	AND SA2.D_E_L_E_T_ <> '*'                                                                     " 
cQuery += " 	AND SZ1.D_E_L_E_T_ <> '*'                                                                     " 
cQuery += " 	AND E5_DTDISPO BETWEEN '"+DTOS(xMv_01)+"' AND '"+DTOS(xMv_02)+"'                              " 
cQuery += " 	AND E5_FILORIG = '"+cFilAnt+"'                                                                " 
cQuery += " 	AND E5_TIPO = 'NF'                                                                            " 
cQuery += " 	AND E5_TIPODOC IN ('BA','VL','ES')                                                            " 
cQuery += " 	AND E5_SITUACA <> 'C'                                                                         " 
cQuery += " 	AND E5_MOTBX IN ('DEB','NOR','FAT')                                                           " 
cQuery += " 	AND A2_COD = E5_CLIFOR AND A2_LOJA = E5_LOJA                                                  " 
cQuery += "     AND E5_TIPO = Z1_TIPO                                                                         " 
cQuery += " 	AND E5_FILIAL = Z1_FILIAL                                                                     " 
cQuery += "     AND E5_PREFIXO = Z1_PREFIXO                                                                   " 
cQuery += " 	AND E5_NUMERO = Z1_NUM                                                                        " 
cQuery += "     AND E5_FORNECE = Z1_FORNECE                                                                   " 
cQuery += " 	AND E5_LOJA = Z1_LOJA                                                                         " 
cQuery += " 	AND E5_PARCELA = Z1_PARCELA                                                                   "
cQuery += " 	AND A2_GRUPO = 'OPE'                                                                          " 
cQuery += " 	AND Z1_LA <> 'S'                                                                              " 
cQuery += " GROUP BY                                                                                          " 
cQuery += "     SE5.E5_FILIAL, SE5.E5_DATA, SE5.E5_PREFIXO,                                                   " 
cQuery += " 	SE5.E5_NUMERO, SE5.E5_TIPO, SE5.E5_PARCELA,                                                   " 
cQuery += " 	SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_TIPODOC,                                                   " 
cQuery += " 	SE5.E5_MOTBX, SE5.E5_DTDISPO,                                                                 " 
cQuery += " 	SE5.E5_BANCO,SE5.E5_AGENCIA,SE5.E5_CONTA,                                                     " 
cQuery += " 	SE5.R_E_C_N_O_                                                                                " 
cQuery += " 	)TRB                                                                                          " 					

IF SELECT(cAlias)>0
	(cAlias)->(dbCloseArea())
ENDIF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

nRet := (cAlias)->REG
(cAlias)->(dbCloseArea())
Return nRet

Static Function CriaSx1()

Local aP	:= {}
Local i		:= 0
Local cSeq
Local cMvCh
Local cMvPar
Local aHelp := {}

AADD(aP,{"Data de?"				,"D",08,0,"G","","",""		,""		,"","",""})
AADD(aP,{"Data at�?"			,"D",08,0,"G","","",""		,""		,"","",""})
AADD(aP,{"Mostra Lan�amento"	,"N",01,0,"C","","","Sim"	,"Nao"	,"","",""})
//AADD(aP,{"Lote"				,"C",06,0,"G","","",""		,""		,"","",""})
//AADD(aP,{"Cod. LP"			,"C",03,0,"G","","",""		,""		,"","",""})
//AADD(aP,{"Recontabiliza"	,"N",01,0,"C","","","Sim"	,"Nao"	,"","",""})

AADD(aHelp,{"Informe a data."})
//AADD(aHelp,{"Mostra Lançamentos em tela para confirmação?"})
//AADD(aHelp,{"Aglutina lancamentos com mesmas caracteristicas?"})
//AADD(aHelp,{"Informe o lote contábil."})
//AADD(aHelp,{"Informe o código do lançamento padrao."})

For i:=1 To Len(aP)
	cSeq := StrZero(i,2,0)
	cMvPar := "mv_par"+cSeq
	cMvCh := "mv_ch"+IIF(i<=9,Chr(i+48),Chr(i+87))
	PutSx1(cPergunte, cSeq, aP[i,1],aP[i,1],aP[i,1], cMvCh, aP[i,2], aP[i,3], aP[i,4], 0, aP[i,5], aP[i,6], aP[i,7], "", "", cMvPar, aP[i,8],aP[i,8],aP[i,8], "", aP[i,9],aP[i,9],aP[i,9], aP[i,10],aP[i,10],aP[i,10], aP[i,11],aP[i,11],aP[i,11], aP[i,12],aP[i,12],aP[i,12], aHelp[i], {}, {}, "")
Next i

Return Nil

//Retorna a Data de Baixa da Fatura.
//13/09/2018 - DFS Sistemas - Marcus Ferraz
static function RetDtBxFat(_aTitFat)

//Local cAliasFAT := GetNextAlias()
Local _aBxFat	:= {}

If Select('TFAT') > 0
	TFAT->(dbCloseArea())
EndIf

BeginSQL Alias 'TFAT'
	SELECT
	SE5.E5_DTDISPO,SE5.E5_BANCO,SE5.E5_AGENCIA,SE5.E5_CONTA, SE5.R_E_C_N_O_ RECNOFAT, SE5.E5_VLJUROS, SE5.E5_VLMULTA, SE5.E5_VLDESCO,
	SE2.E2_VRETIRF, SE2.E2_VRETPIS, SE2.E2_VRETCOF, SE2.E2_VRETCSL, SE5.E5_VALOR
	FROM %Table:SE5% SE5, %Table:SE2% SE2
	WHERE SE5.%NotDel%
	AND SE2.%NotDel%
	AND SE5.E5_FILIAL = SE2.E2_FILIAL
	AND SE5.E5_PREFIXO = SE2.E2_PREFIXO
	AND SE5.E5_NUMERO = SE2.E2_NUM
	AND SE5.E5_PARCELA = SE2.E2_PARCELA
	AND SE5.E5_FORNECE = SE2.E2_FORNECE
	AND SE5.E5_LOJA = SE2.E2_LOJA
	AND SE5.E5_FILIAL = %Exp:_aTitFat[1]%
	AND SE5.E5_PREFIXO = %Exp:_aTitFat[2]%
	AND SE5.E5_NUMERO = %Exp:_aTitFat[3]%
	AND SE5.E5_TIPO = %Exp:_aTitFat[5]%
	AND SE5.E5_CLIFOR = %Exp:_aTitFat[6]%
	AND SE5.E5_LOJA = %Exp:_aTitFat[7]%
	AND SE5.E5_MOTBX IN ('DEB','NOR')
	AND SE5.E5_SITUACA <> 'C'
	AND SE5.E5_TIPODOC IN ('VL')
	ORDER BY %Order:SE5%
EndSQL

TFAT->(DbGoTop())
Do While !TFAT->(EOF())
	CONOUT("Achou titulo Fatura e salvou Data Dispo")
	_aBxFat	:= {.T., ;
				TFAT->E5_DTDISPO,;
				TFAT->E5_BANCO,;
				TFAT->E5_AGENCIA,;
				TFAT->E5_CONTA,;
				TFAT->RECNOFAT,;
				TFAT->E5_VLJUROS,;
				TFAT->E5_VLMULTA,;
				TFAT->E5_VLDESCO,;
				TFAT->E2_VRETIRF,;
				TFAT->E2_VRETPIS,;
				TFAT->E2_VRETCOF,;
				TFAT->E2_VRETCSL,;
				TFAT->E5_VALOR }
	TFAT->(DbSkip())
EndDo

If !Len(_aBxFat) > 0
	CONOUT("Nao achou o Titulo de Fatura, Retornou Falso, titulo "+_aTitFat[3])
	_aBxFat	:= {.F.}
EndIf

If Select('TFAT') > 0
	TFAT->(dbCloseArea())
EndIf

return(_aBxFat)
