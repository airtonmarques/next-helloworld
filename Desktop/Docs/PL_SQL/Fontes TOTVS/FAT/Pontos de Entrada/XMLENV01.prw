#include 'protheus.ch'
#include 'parmtype.ch'
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | XMLENV01  | Autor | DFSSISTEMAS | Data | 13/04/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Ponto de entrada após a coleta dos dados nos arrays |
|           | e antes da geração da string XML.                   |
+-----------+-----------------------------------------------------+
| Uso       | NFSEXMLENV                                          | 
+-----------+-----------------------------------------------------+ 
*/
user function XMLENV01()

	Local aProd		:= aParam[1]
	Local cMensCli	:= aParam[2]
	Local cMensFis	:= aParam[3]
	Local aDest 	:= aParam[4]
	Local aNota 	:= aParam[5]
	Local aDupl		:= aParam[6]  
	Local aDeduz	:= aParam[7]
	Local aTotal	:= aParam[8]
	Local aISSQN	:= aParam[9]
	Local aAIDF		:= aParam[10]
	Local aInterm	:= aParam[11]
	Local aRetido	:= aParam[12]				
	Local aDeducao	:= aParam[13]
	Local aConstr	:= aParam[14]

	Local cCodMun	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
	Local cCGC		:= if( type( "oSigamatX" ) == "U",SM0->M0_CGC,oSigamatX:M0_CGC )
	
	// DFS 13/04/2018: Regime especial NF carioca SMF 2.759 de 28/02/2013 (SEM TOMADOR)
	If cCodMun == "3304557"
		If aDest[1] == cCGC .and. aDest[7] == substr(cCodMun,3,len(cCodMun)-2)  
			aDest[1] := ''
			aDest[2] := ''
		Endif
	Endif 
	
return {aProd,cMensCli,cMensFis,aDest,aNota,aDupl,aDeduz,aTotal,aISSQN,aAIDF,aInterm,aRetido,aDeducao,aConstr}