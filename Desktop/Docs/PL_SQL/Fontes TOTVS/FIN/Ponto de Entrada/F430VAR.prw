#Include "TOTVS.CH"

/*/{Protheus.doc} F430VAR
Ponto de entrada para tratar os dados para Baixa CNAB.
 
@owner      TOTVS
@version    P12
@since      01/02/2022
/*/
User Function F430VAR()

Local aAreaAnt := GetArea()

	//Carrega todos os dados Refrente ao titulo
    paramIXB[1][08] := paramIXB[1][08]+SE2->(E2_XMULTA+E2_XJUROS)
	paramIXB[1][10] := SE2->(E2_XMULTA+E2_XJUROS)

	RestArea(aAreaAnt)

Return Nil
