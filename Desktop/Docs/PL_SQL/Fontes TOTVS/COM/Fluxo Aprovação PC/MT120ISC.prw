#INCLUDE "PROTHEUS.CH"

/*------------------------------------------------------------------------------------------------------------------------------------------------*\
| Fonte:	 |	MT120ISC.PRW                                                                                                                       |
| Autor:	 |	Marcus Ferraz                                                                                                                      |
| Data:		 |	20/08/2018                                                                                                                         |
| Descrição: |	Ponto de Entrada para preencher os campos de valor da solcitação no pedido de compras.           								   |
\*------------------------------------------------------------------------------------------------------------------------------------------------*/

User Function MT120ISC()

	Local nPosVrUnit := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRECO'}) 
	Local nPosVrTot  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_TOTAL'}) 
	
	aCols[n][nPosVrUnit] := SC1->C1_VUNIT
	aCols[n][nPosVrTot]  := SC1->C1_VUNIT * SC1->C1_QUANT

Return