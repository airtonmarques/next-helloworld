#include 'protheus.ch'
#include 'parmtype.ch'
/*
+-----------+--------------+-------+-------------+------+------------+
| Programa  | PE01NFESEFAZ | Autor | DFSSISTEMAS | Data | 13/04/2018 |
+-----------+--------------+-------+-------------+------+------------+
| Descricao | Ponto de entrada após a coleta dos dados nos arrays e  |
|           | antes da geração da string XML.                        |
+-----------+--------------------------------------------------------+
| Uso       | NFESEFAZ                                               | 
+-----------+--------------------------------------------------------+ 
*/
user function PE01NFESEFAZ()

	Local aProd		:= aParam[1]
	Local cMensCli	:= aParam[2]
	Local cMensFis	:= aParam[3]
	Local aDest 	:= aParam[4]
	Local aNota 	:= aParam[5]
	Local aInfoItem	:= aParam[6]  
	Local aDupl		:= aParam[7]
	Local aTransp	:= aParam[8]
	Local aEntrega	:= aParam[9]
	Local aRetirada	:= aParam[10]
	Local aVeiculo	:= aParam[11]
	Local aReboque	:= aParam[12]
	Local aNfVincRur:= aParam[13]
	Local aEspVol   := aParam[14]
	Local aNfVinc	:= aParam[15]
	Local aDetPag	:= aParam[16]
	Local nX		:= 0

	// Usar descrição científica para a descrição do produto
	For nX := 1 to len(aProd)
		_cDesc := AllTrim(GetAdvFVal("SB5","B5_CEME",xFilial("SB5")+aProd[nX,2],1)) // 20180807 - correção da descrição para nf-e 4.0
		aProd[nX,4] := Iif(Empty(_cDesc),aProd[nX,4],_cDesc)
	Next nX
	
return {aProd,cMensCli,cMensFis,aDest,aNota,aInfoItem,aDupl,aTransp,aEntrega,aRetirada,aVeiculo,aReboque,aNfVincRur,aEspVol,aNfVinc,aDetPag}