#INCLUDE "RWMAKE.CH"    
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} FUNC002
COPIA LANCAMENTOS ENTRE EMPRESAS
@author Henrique Cunha
@since 06/06/2022
@version 1.0
/*/
User Function ALLFCTB01()

Local _cQry     := ""
Local _cPerg    := "FUNC002"
Local _cInsert  := ""
Local _cWKArea  := GetNextAlias()

Local _nStatus  := 0

//VERIFICA NA BASE O GRUPO DE PERGUNTAS
CHKSX1(_cPerg)
//VERIFICA SE OS PARAMETROS FORAM INSERIDOS  
If !Pergunte(_cPerg)
	MSGINFO("Processo Cancelado!")
	Return NIL
EndIf
//MONTAGEM DA QUERY DE SELECAO DE REGISTROS
_cQry := " SELECT CT2_LOTE "
_cQry += "   FROM CT2" + MV_PAR01 + "0"
_cQry += "  WHERE CT2_FILIAL BETWEEN '" + AllTrim(MV_PAR04) + "' AND '"+ AllTrim(MV_PAR05) +"' "
_cQry += "    AND SUBSTR(CT2_DATA,5,2) = '" + AllTrim(MV_PAR02) + "' "
_cQry += "    AND SUBSTR(CT2_DATA,1,4) = '" + AllTrim(MV_PAR03) + "' "
_cQry += "    AND D_E_L_E_T_ = ' ' "
//ABRE ALIAS TEMPORARIO
MPSYSOPENQUERY(_cQry,_cWKArea)
//VERIFICA SE JA HA LANCAMENTOS
If (_cWKArea)->(!EOF())
    //DECIDE SE EXECUTA MESMO COM LANCAMENTOS JA NA BASE
    If !MSGYESNO("Já Existem Lançamentos Para Este Período. Deseja Importar? ","Confirma? ")
 	    MSGINFO("Processo Cancelado!")
	    Return NIL       
    EndIf
EndIf
//MONTA INSERT
_cInsert := " INSERT INTO CT2" + MV_PAR01 + "0 "
_cInsert += " SELECT * FROM " + RETSQLNAME("CT2") + " CT2 "
_cInsert += "  WHERE SUBSTR(CT2.CT2_DATA,5,2) = '" + AllTrim(MV_PAR02) + "' "
_cInsert += "    AND SUBSTR(CT2.CT2_DATA,1,4) = '" + AllTrim(MV_PAR03) + "' "
_cInsert += "    AND CT2.CT2_FILIAL BETWEEN '" + AllTrim(MV_PAR04) + "' AND '"+ AllTrim(MV_PAR05) +"' "
_cInsert += "    AND CT2.D_E_L_E_T_ = ' ' "
//EXECUTA INSERT
_nStatus := TCSQLEXEC(_cInsert)
//VERIFICA SE INSERT DEU ERRO
If (_nStatus < 0)
    MSGINFO("ERRO: " + TCSQLError())
EndIf

Return NIL

/*/{Protheus.doc} CHKSX1
veriifica grupo de perguntas
@author Henrique Cunha
@since 06/06/2022
@version 1.0
/*/
Static Function CHKSX1(cPerg)

Local aRegs :={}
Local i := 0, j := 0

AADD(aRegs,{cPerg,"01","Empresa Destino? "	        ,"Empresa Destino? "        ,"Empresa Destino? "        ,"mv_ch1","C",02,0,0,"G","NaoVazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Mês? "                      ,"Mês? "                    ,"Mês? "                    ,"mv_ch2","C",02,0,0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Ano? " 	                    ,"Ano? "                    ,"Ano? "                    ,"mv_ch3","C",04,0,0,"G","NaoVazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Filial Origem De? "	        ,"Filial Origem? "	        ,"Filial Origem? "	        ,"mv_ch4","C",04,0,0,"G","NaoVazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","Filial Origem Ate? "	    ,"Filial Origem? "	        ,"Filial origem? "	        ,"mv_ch5","C",04,0,0,"G","NaoVazio()","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","",""})


DBSelectArea("SX1")
DBSetOrder(1)

For i:= 1 To Len(aRegs)
	If !DBSeek(Padr(cPerg,Len(X1_GRUPO))+aRegs[i,2])
		RecLock("SX1", .T.)
		For j := 1 To Len(aRegs[1])
			FieldPut(j,aRegs[i,j])
		Next
		MSUnlock()
	EndIf
Next

Return Nil
