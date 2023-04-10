#Include "Protheus.ch"

#INCLUDE "PROTHEUS.CH" 	
      
User Function MTOBSNFE()

Local cRet := ""                                    
Local dVencISS:= LastDay(SF3->F3_EMISSAO,0)+10
Local lPipe := (Funname() <> "MATA916") // Se não for a impressao da Nota de Servico, a mensagem deve ser encaminhada com PIPE para a prefeitura
           
If cEmpAnt == "01" // Se for o grupo de empresas "Allcare"
	If cFilAnt == "0301"           // Se for a corretora Allcare na filial São Paulo
		cRet += "(1)Esta NF-e foi emitida com respaldo na Lei n. 14.097/2005;"
		cRet += " (2)Esta NFS-e não gera crédito;"
		cRet += " (3)Esta NFS-e substiitui o RPS N. "+Alltrim(SF3->F3_NFISCAL)+", emitido em "+DTOC(SF3->F3_EMISSAO)+";"
		If SF3->F3_VALICM > 0 // Se houve retencao de ISS
			dVencISS:= LastDay(SF3->F3_EMISSAO,0)+10
			cRet += " (4)O ISS referente a esta NFS-e foi recolhido em: "+DTOC(dVencISS)
		Else
			cRet += " (4)O ISS desta NFS-e será RETIDO pelo Tomador de Serviço que deverá recolher atraves da Guia de NFS-e"
			cRet += " (5)Valor Liquido a Pagar: R$ "+Alltrim(Transform(SF2->F2_VALFAT-SF2->F2_VALIRRF,"@E 999,999,999,999.99"))
		EndIf            
	ElseIf cFilAnt == "0302"           // Se for a corretora Allcare na filial Rio de Janeiro
		cRet += "- Esta NF-e foi emitida com respaldo na Lei n. 5.098 de 15/10/2009 e no decreto n. 32.250 de 11/10/2010"+"|"
		cRet += "- PROCON-RJ Av. Rio Brando n. 25, 5 andar, tel 151: www.procon.rj.br"+"|"
		If SF3->F3_VALICM > 0 // Se houve retencao de ISS
			dVencISS:= LastDay(SF3->F3_EMISSAO,0)+10
			cRet += "- O ISS referente a esta NF-s foi recolhido em: 10/"+DTOC(dVencISS)+"|"
		Else
			cRet += "- O ISS desta NFS-e será RETIDO pelo Tomador de Serviço que deverá recolher atraves de DARM, gerado pelo sistem de NFS-e"+"|"
			cRet += "- Valor Liquido a Pagar: R$ "+Alltrim(Transform(SF2->F2_VALFAT-SF2->F2_VALIRRF,"@E 999,999,999,999.99"))+"|"
		EndIf
		cRet += "- Esta NFS-e não gera Crédito"+"|"
		cRet += "- Esta NFS-e substiitui o RPS N. "+Alltrim(SF3->F3_NFISCAL)+", emitido em "+DTOC(SF3->F3_EMISSAO)+"|"           
/*	ElseIf cFilAnt == "0303"           // Se for a corretora Allcare na filial Rio de Janeiro
		cRet += "- Esta NF-e foi emitida com respaldo na Lei n. 5.098 de 15/10/2009 e no decreto n. 32.250 de 11/10/2010"+"|"
		cRet += "- PROCON-RJ Av. Rio Brando n. 25, 5 andar, tel 151: www.procon.rj.br"+"|"
		If SF3->F3_VALICM > 0 // Se houve retencao de ISS
			dVencISS:= LastDay(SF3->F3_EMISSAO,0)+10
			cRet += "- O ISS referente a esta NF-s foi recolhido em: 10/"+DTOC(dVencISS)+"|"
		Else
			cRet += "- O ISS desta NFS-e será RETIDO pelo Tomador de Serviço que deverá recolher atraves de DARM, gerado pelo sistem de NFS-e"+"|"
			cRet += "- Valor Liquido a Pagar: R$ "+Alltrim(Transform(SF2->F2_VALFAT-SF2->F2_VALIRRF,"@E 999,999,999,999.99"))+"|"
		EndIf
		cRet += "- Esta NFS-e não gera Crédito"+"|"
		cRet += "- Esta NFS-e substiitui o RPS N. "+Alltrim(SF3->F3_NFISCAL)+", emitido em "+DTOC(SF3->F3_EMISSAO)+"|"           
*/	EndIf
EndIF
		
IF !lPipe
	cRet := NfeQuebra(cRet)
EndIF 

Return cRet