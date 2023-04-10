#include 'protheus.ch'
#include 'parmtype.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EFAT001   �Autor  �DFS SISTEMAS        � Data �  25/04/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �Preencher mensagem para notas NFe e NFSe                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Pontos de entrada M460FIM e MTDESCRNFE                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function EFAT001()

	Local lPipe		:= (Funname() <> "MATA916") // Se n�o for a impressao da Nota de Servico, a mensagem deve ser encaminhada com PIPE para a prefeitura
	Local cMsgNf	:= ""
	Local cPerIni	:= IIF(!Empty(GetAdvFVal("SC5","C5_XPERINI",xFilial("SC5")+SD2->D2_PEDIDO,1)),DTOC(GetAdvFVal("SC5","C5_XPERINI",xFilial("SC5")+SD2->D2_PEDIDO,1)),"")	// Periodo Inicial / Competencia 
	Local cPerFim	:= IIF(!Empty(GetAdvFVal("SC5","C5_XPERFIM",xFilial("SC5")+SD2->D2_PEDIDO,1)),DTOC(GetAdvFVal("SC5","C5_XPERFIM",xFilial("SC5")+SD2->D2_PEDIDO,1)),"")	// Periodo Final / Competencia
	Local cDocOper	:= Alltrim(GetAdvFVal("SC5","C5_XDOCOPE",xFilial("SC5")+SD2->D2_PEDIDO,1))																				// Doc. Identifica��o Operadora
	Local cMsgRegE	:= GetMv("MV_XMSGESP")																																	// Mensagem de Regime Especial
	Local cMsgNota	:= Alltrim(Formula(GetAdvFVal("SC5","C5_MENPAD",xFilial("SC5")+SD2->D2_PEDIDO,1)))																		// Mensagem para nota fiscal (C5_MENNOTA)
	
	cMsgNF += (AllTrim(GetAdvFVal("SB5","B5_CEME",xFilial("SB5")+SD2->D2_COD,1)))+"|" 								   														// Descri��o do servi�o
	cMsgNF += "Operadora: "+Alltrim(GetADVFVal("SA1","A1_NREDUZ",xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,1))+"|" 														// Operadora
	cMsgNF += IIF(!Empty(cPerIni) ,"Competencia: "+cPerIni,"")+IIF(Empty(cPerFim),""," - "+cPerFim)+"|"																		// Competencia
	cMsgNF += IIF(!Empty(cDocOper),"Documento Operadora: "+cDocOper+"|","")																									// Identificacao docto da operadora
	cMsgNF += IIF(SF2->F2_VALIRRF >0 .and. SF2->F2_BASEIRR >0,"IR: "  +Alltrim(Transform(SF2->F2_VALIRRF,"@E 999,999,999,999.99"))+"|","")									// Valor IRRF
	cMsgNF += IIF(SF2->F2_VALISS > 0 .and. SFT->FT_VALICM > 0, "ISS: "+Alltrim(Transform(SF2->F2_VALISS ,"@E 999,999,999,999.99"))+"|","")									// Valor ISS
	If !Empty(Alltrim(cMsgRegE))
		cMsgNF += cMsgRegE+"|"
	EndIf
	cMsgNF += cMsgNota																																						// Mensagem para nota 
	
	IF !lPipe
		cMsgNF := NfeQuebra(cMsgNF)
	EndIF
	
	RecLock("SC5",.F.)
		SC5->C5_DISCNFE := cMsgNF
	SC5->(MsUnLock())
	
Return cMsgNf