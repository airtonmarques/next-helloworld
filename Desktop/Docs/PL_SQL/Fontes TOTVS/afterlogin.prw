#Include "Totvs.ch"
 
User Function afterlogin
Local cCommand := ""
Local nStatus  := 0
Local dUltDt   := Getmv("BR_DTSZ1")
Local lExec    := .T.

If dUltDt<Date()
    //Atualizar SZ1 para faturas
    cCommand :=""
    cCommand += "MERGE INTO "+RetSqlName("SZ1")+" TB1 "                     + chr(13)+chr(10)
    cCommand += "USING "                                                    + chr(13)+chr(10)
    cCommand += "( SELECT"                                                  + chr(13)+chr(10)
    cCommand += "DISTINCT E2_FILIAL,E2_NUM,E2_PREFIXO,E2_PARCELA,E2_BAIXA," + chr(13)+chr(10)
    cCommand += "         E2_XCOMPET,E2_EMIS1,E2_VENCREA,E2_EMISSAO,"       + chr(13)+chr(10)
    cCommand += "         E2_FATURA,E5_DTDISPO,SZ1.R_E_C_N_O_ AS RECSZ1"    + chr(13)+chr(10)
    cCommand += "FROM "+RetSqlName("SE2")+" SE2"                            + chr(13)+chr(10)
    cCommand += "INNER JOIN "+RetSqlName("SZ1")+" SZ1 ON "                  + chr(13)+chr(10)
    cCommand += "    SZ1.Z1_FILIAL = SE2.E2_FILIAL AND "                    + chr(13)+chr(10)
    cCommand += "    SZ1.Z1_PREFIXO = SE2.E2_PREFIXO AND "                  + chr(13)+chr(10)
    cCommand += "    SZ1.Z1_NUM = SE2.E2_NUM AND "                          + chr(13)+chr(10)
    cCommand += "    SZ1.Z1_PARCELA = SE2.E2_PARCELA  AND "                 + chr(13)+chr(10)
    cCommand += "    SZ1.Z1_FORNECE = SE2.E2_FORNECE AND "                  + chr(13)+chr(10)
    cCommand += "    SZ1.Z1_LOJA = SE2.E2_LOJA AND SZ1.D_E_L_E_T_=' '"      + chr(13)+chr(10)
    cCommand += "INNER JOIN "+RetSqlName("SE5")+" SE5 ON "                  + chr(13)+chr(10)
    cCommand += "    SE5.E5_FILIAL=SE2.E2_FILIAL AND "                      + chr(13)+chr(10)
    cCommand += "    SE5.E5_PREFIXO=SE2.E2_PREFIXO AND "                    + chr(13)+chr(10)
    cCommand += "    SE5.E5_NUMERO=SE2.E2_NUM AND "                         + chr(13)+chr(10)
    cCommand += "    SE5.E5_PARCELA=SE2.E2_PARCELA AND "                    + chr(13)+chr(10)
    cCommand += "    SE5.E5_CLIFOR=SE2.E2_FORNECE AND "                     + chr(13)+chr(10)
    cCommand += "    SE5.E5_LOJA=SE2.E2_LOJA AND "                          + chr(13)+chr(10)
    cCommand += "    SE5.E5_SITUACA <> 'C' AND "                            + chr(13)+chr(10)
    cCommand += "    SE5.E5_TIPODOC='VL' AND "                              + chr(13)+chr(10)
    cCommand += "    SE5.E5_MOTBX IN ('DEB','NOR') AND "                    + chr(13)+chr(10)
    cCommand += "    SE5.D_E_L_E_T_=' ' "                                   + chr(13)+chr(10)
    cCommand += "WHERE "                                                    + chr(13)+chr(10)
    cCommand += "SE2.E2_SALDO<SE2.E2_VALOR AND "                            + chr(13)+chr(10)
    cCommand += "SE2.D_E_L_E_T_=' ' AND "                                   + chr(13)+chr(10)
    cCommand += "SE2.E2_FATURA<>' ' AND "                                   + chr(13)+chr(10)
    cCommand += "SE2.E2_FATURA<>'NOTFAT' AND "                              + chr(13)+chr(10)
    cCommand += "SE2.E2_EMIS1 <=  '"+DTOS(Date())+"' AND "                  + chr(13)+chr(10)
    cCommand += "SZ1.Z1_DTCOMPE =' ' ) TB2"                                 + chr(13)+chr(10)
    cCommand += "ON (TB1.R_E_C_N_O_ = TB2.RECSZ1)"                          + chr(13)+chr(10)
    cCommand += "WHEN MATCHED THEN UPDATE SET "                             + chr(13)+chr(10)
    cCommand += "TB1.Z1_BAIXA=TB2.E5_DTDISPO,"                              + chr(13)+chr(10)
    cCommand += "TB1.Z1_FATURA=TB2.E2_FATURA,"                              + chr(13)+chr(10)
    cCommand += "TB1.Z1_DTCOMPE=TB2.E2_XCOMPET,"                            + chr(13)+chr(10)
    cCommand += "TB1.Z1_EMIS1=TB2.E2_EMIS1,"                                + chr(13)+chr(10)
    cCommand += "TB1.Z1_VENCTO=TB2.E2_VENCREA,"                             + chr(13)+chr(10)
    cCommand += "TB1.Z1_EMISSAO=TB2.E2_EMISSAO"                             + chr(13)+chr(10)

    nStatus := TCSqlExec(cCommand)

    If nStatus<0
        alert(TCSQLError())
        lExec := .F.
    Endif

    //Atualizar SZ1 para nao faturas
    cCommand :=""
    cCommand += "MERGE INTO "+RetSqlName("SZ1")+" TB1 "                     + chr(13)+chr(10)
    cCommand += "USING "                                                    + chr(13)+chr(10)
    cCommand += "( SELECT"                                                  + chr(13)+chr(10)
    cCommand += "DISTINCT E2_FILIAL,E2_NUM,E2_PREFIXO,"                     + chr(13)+chr(10) 
    cCommand += "E2_PARCELA,E2_BAIXA,E2_XCOMPET,"                           + chr(13)+chr(10)
    cCommand += "E2_EMIS1,E2_VENCREA,E2_EMISSAO,"                           + chr(13)+chr(10)
    cCommand += "E2_FATURA,SZ1.R_E_C_N_O_ AS RECSZ1"                        + chr(13)+chr(10)
    cCommand += "FROM "+RetSqlName("SE2")+" SE2"                            + chr(13)+chr(10)
    cCommand += "INNER JOIN "+RetSqlName("SZ1")+" SZ1 ON "                  + chr(13)+chr(10)
    cCommand += "    SZ1.Z1_FILIAL = SE2.E2_FILIAL AND "                    + chr(13)+chr(10)
    cCommand += "    SZ1.Z1_PREFIXO = SE2.E2_PREFIXO AND "                  + chr(13)+chr(10)
    cCommand += "    SZ1.Z1_NUM = SE2.E2_NUM AND "                          + chr(13)+chr(10)
    cCommand += "    SZ1.Z1_PARCELA = SE2.E2_PARCELA  AND "                 + chr(13)+chr(10)
    cCommand += "    SZ1.Z1_FORNECE = SE2.E2_FORNECE AND "                  + chr(13)+chr(10)
    cCommand += "    SZ1.Z1_LOJA = SE2.E2_LOJA AND SZ1.D_E_L_E_T_=' '"      + chr(13)+chr(10)
    cCommand += "WHERE "                                                    + chr(13)+chr(10)
    cCommand += "SE2.E2_SALDO<SE2.E2_VALOR AND "                            + chr(13)+chr(10)
    cCommand += "SE2.D_E_L_E_T_=' ' AND "                                   + chr(13)+chr(10)
    cCommand += "SE2.E2_FATURA=' ' AND "                                    + chr(13)+chr(10)
    cCommand += "SE2.E2_EMIS1 <=  '"+DTOS(Date())+"' AND "                  + chr(13)+chr(10)
    cCommand += "SZ1.Z1_DTCOMPE = ' ' ) TB2"                                + chr(13)+chr(10)
    cCommand += "ON (TB1.R_E_C_N_O_ = TB2.RECSZ1)"                          + chr(13)+chr(10)
    cCommand += "WHEN MATCHED THEN UPDATE SET "                             + chr(13)+chr(10)
    cCommand += "TB1.Z1_BAIXA=TB2.E2_BAIXA,"                                + chr(13)+chr(10)
    cCommand += "TB1.Z1_DTCOMPE=TB2.E2_XCOMPET,"                            + chr(13)+chr(10)
    cCommand += "TB1.Z1_EMIS1=TB2.E2_EMIS1,"                                + chr(13)+chr(10)
    cCommand += "TB1.Z1_VENCTO=TB2.E2_VENCREA,"                             + chr(13)+chr(10)
    cCommand += "TB1.Z1_EMISSAO=TB2.E2_EMISSAO"                             + chr(13)+chr(10)

    nStatus := TCSqlExec(cCommand)

    If nStatus<0
        alert(TCSQLError())
        lExec := .F.
    Endif

    If lExec
        PutMv("BR_DTSZ1",Date())
    Endif    
Endif    

Return
