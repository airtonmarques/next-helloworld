#INCLUDE "RWMAKE.CH"    
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} FUNC001
ALTERA DATA DE VENCIMENTO EM LOTE DO CONTAS A RECEBER
@author Henrique Cunha
@since 05/06/2022
@version 1.0
/*/

User Function ALLFIN02()

Local _cQry  	:= ""
Local cPerg 	:= "FUNC001"
Local _cData 	:= ""

Private _cWKArea  := GetNextAlias()

//VERIFICA NA BASE O GRUPO DE PERGUNTAS
CHKSX1(cPerg)
//VERIFICA SE OS PARAMETROS FORAM INSERIDOS  
If !Pergunte(cPerg)
	MSGINFO("Processo Cancelado!")
	Return .T.
EndIf

//MONTAGEM DA QUERY DE SELECAO DE REGISTROS
_cQry := " SELECT R_E_C_N_O_ AS RECSE1 "                                        + CRLF
_cQry += "   FROM " + RETSQLNAME("SE1") + " SE1 "                               + CRLF
_cQry += "  WHERE E1_FILIAL = '" + PADR(MV_PAR01,TAMSX3("E1_FILIAL")[1]) + "' " + CRLF
_cQry += "    AND E1_VENCTO = '" + DTOS(MV_PAR02) + "' "                        +CRLF
_cQry += "    AND E1_SALDO  > 0    " 											+CRLF
_cQry += "    AND SE1.D_E_L_E_T_  = ' '  " 										+CRLF
//ABRE ALIAS TEMPORARIO
MPSYSOPENQUERY(_cQry,_cWKArea)
//VERIFICA SE HA REGISTROS A SEREM PROCESSADOS

If (_cWKArea)->(EOF())
	MSGINFO("Não há registros a serem processados!")
EndIf

//TRANSFORMA DATA EM TEXTO PARA INFORMAR POSTERIORMENTE

_cData := DTOS(MV_PAR02)
_cData := (SUBSTR(_cData,7,2) + "/" + SUBSTR(_cData,5,2) + "/" + SUBSTR(_cData,1,4))

//VERIFICA SE O USUARIO REALMENTE QUER ALTERAR O LOTE DE REGISTROS

If MSGYESNO("Deseja alterar o vencimento dos titulos? (Vencimento: " + _cData + ")", "Alteração de Vencimento")

	//PROCESSA REGISTROS
	FWMsgRun(,{||XPRCSE1()},"Processando", "Alterando Registros...")
Else
	//INFORMA QUE O PROCESSO FOI CANCELADO
	MSGINFO("Processo Cancelado!")
EndIf

Return NIL

/*/{Protheus.doc} XPRCSE1
PROCESSA REGISTROS
@author Henrique Cunha
@since 05/06/2022
@version 1.0
/*/
Static Function XPRCSE1()

While (_cWKArea)->(!EOF())
	//ABRE ALIAS QUE VAI SER GRAVADO
	DBSelectArea("SE1")
	//POSICIONA NO REGISTRO
	SE1->(DBGoTo((_cWKArea)->RECSE1))
	//GRAVA NOVA DATA NO REGISTRO
	RECLOCK("SE1",.F.)
		SE1->E1_VENCTO  := MV_PAR03
		SE1->E1_VENCREA := MV_PAR03
	SE1->(MSUnlock())
	(_cWKArea)->(DBSkip())
EndDo

MSGINFO("Processo Finalizado com Sucesso!")

Return(.T.)

/*/{Protheus.doc} CHKSX1
veriifica grupo de perguntas
@author Henrique Cunha
@since 05/06/2022
@version 1.0
/*/

Static Function CHKSX1(cPerg)
Local aRegs :={}
Local i := 0, j := 0

AADD(aRegs,{cPerg,"01","Filial? "   		        ,"Filial? " 		        ,"Filial? " 		        ,"mv_ch1","C",03,0,0,"G","NaoVazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SM0_01","",""})
AADD(aRegs,{cPerg,"02","Dt. Vencimento Atual? "     ,"Dt. Vencimento Atual? "   ,"Dt. Vencimento Atual? "   ,"mv_ch2","D",08,0,0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Nova Dt. Vencimento: " 	    ,"Nova Dt. Vencimento: "    ,"Nova Dt. Vencimento: "    ,"mv_ch3","D",08,0,0,"G","NaoVazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
