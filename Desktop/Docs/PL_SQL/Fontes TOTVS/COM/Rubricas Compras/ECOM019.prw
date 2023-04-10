#include 'protheus.ch'
#include 'parmtype.ch'
/*
+-----------+-----------+-------+-------------+------+------------+
| Programa  | ECOM019   | Autor | DFSSISTEMAS | Data | 20/06/2018 |
+-----------+-----------+-------+-------------+------+------------+
| Descricao | Execblock para contabilizacao das rubricas associ-  |
|           | adas as notas fiscais de entrada na exclusao da NFE |
+-----------+-----------------------------------------------------+
| Uso       | LPs de notas fiscais de entrada                     | 
+-----------+-----------------------------------------------------+ 
*/
user function ECOM019()

	Local aAreaSZ1		:= SZ1->(GetArea())
	Local lCtbOnLine	:= .F.
	Local cLote 		:= ''
	Local nHdlPrv		:= 0
	Local cPadrao		:= GetNewPar('MV_XLPRBE','101')
	Local lPadrao		:= .F.
	Local lDigita		:= (mv_par01==1)
	Local lAglutina		:= (mv_par02==1)
	Local nTotalLcto	:= 0 
	Local aCtbDia		:= {}
	Local lEstNfClass	:= IsInCallStack('A140EstCla')
	Local cArquivo		:= ''
		
	If Type('aCtbExcRb') == "U"
		Public aCtbExcRb := {}
	Endif 
	
	dbSelectArea('SZ1')
	SZ1->(dbSetOrder(1))
	If SZ1->(dbSeek(xFilial('SZ1')+cChaveSZ1))
		If !Empty(SF1->F1_DTLANC)
			lCtbOnLine := .T.
			DbSelectArea("SX5")
			DbSetOrder(1)
			MsSeek(xFilial("SX5")+"09COM")
			cLote := IIf(Found(),Trim(X5DESCRI()),"COM ")
			If At(UPPER("EXEC"),X5Descri()) > 0
				cLote := &(X5Descri())
			EndIf
			nHdlPrv := HeadProva(cLote,"ECOM019",Subs(cUsuario,7,6),@cArquivo)
			If nHdlPrv <= 0
				lCtbOnLine := .F.
			EndIf
		EndIf
		If lCtbOnLine .and. VerPadrao(cPadrao)
			DbSelectArea("SA2")
			DbSetOrder(1)
			MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
			While !SZ1->(EOF()) .and. SZ1->(Z1_PREFIXO+Z1_NUM+Z1_PARCELA+Z1_TIPO+Z1_FORNECE+Z1_LOJA) == cChaveSZ1
				nTotalLcto += DetProva(nHdlPrv,cPadrao,"ECOM019",cLote)
				SZ1->(dbskip())
			EndDo
			If lCtbOnLine .And. nTotalLcto > 0
				RodaProva(nHdlPrv,nTotalLcto)
				If UsaSeqCor()
					aCtbDia := {{"SF1",SF1->(RECNO()),cCodDiario,"F1_NODIA","F1_DIACTB"}}
				Else
					aCtbDia := {}
				EndIF
				aCtbExcRb := {}
				aAdd(aCtbExcRb,cArquivo)
				aAdd(aCtbExcRb,nHdlPrv)
				aAdd(aCtbExcRb,cLote)
				aAdd(aCtbExcRb,lDigita)
				aAdd(aCtbExcRb,lAglutina)
				aAdd(aCtbExcRb,aCtbDia)
				If !lEstNfClass //-- Se nao for estorno de Nota Fiscal Classificada (MATA140)
					aAdd(aCtbExcRb,{{"F1_DTLANC",dDataBase,"SF1",SF1->(Recno()),0,0,0}})
				Else
					aAdd(aCtbExcRb,{{,,,0,0,0,0}})
				EndIf			
			Endif
		Endif
	Endif
	dbSelectArea('SZ1')
	SZ1->(dbSetOrder(1))
	If SZ1->(dbSeek(xFilial('SZ1')+cChaveSZ1))
		While !SZ1->(EOF()) .and. SZ1->(Z1_PREFIXO+Z1_NUM+Z1_PARCELA+Z1_TIPO+Z1_FORNECE+Z1_LOJA) == cChaveSZ1
			RecLock('SZ1',.F.)
				SZ1->(dbDelete())
			SZ1->(MsUnlock())
			SZ1->(dbskip())
		EndDo		
	Endif
	
	RestArea(aAreaSZ1)

return Nil