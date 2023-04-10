CREATE OR REPLACE PROCEDURE ALL_BI_CONF_VEND_AD_PCD(DT_VIG_INI          IN DATE,
                                                    DT_VIG_FIM          IN DATE,
                                                    DT_BAIXA_INI        IN DATE,
                                                    DT_BAIXA_FIM        IN DATE,
                                                    NOME_OPER           IN VARCHAR2 DEFAULT '',
                                                    NOM_ENTID           IN VARCHAR2 DEFAULT '',
                                                    QTDE_MAX            IN NUMBER,
                                                    MSGERROR            OUT VARCHAR2,
                                                    PCONFIRMACAO_CURSOR OUT SYS_REFCURSOR) IS
  IFLAGVI  VARCHAR2(1);
  IFLAGBX  VARCHAR2(1);
  iQtdeMax number;

BEGIN

  if nvl(QTDE_MAX,-1) = -1 then
    iQtdeMax := 999999;
  else
    iQtdeMax := QTDE_MAX;
  end if;

  -- Carrega variáveis de retorno (obrigatório)
  open PCONFIRMACAO_CURSOR for
    select 1 from dual;
  MSGERROR := ' ';

  -- Verifica parâmetros inputados
  IF (nvl(DT_VIG_INI,sys_get_data_ini_fnc) = sys_get_data_ini_fnc AND
      nvl(DT_VIG_FIM,sys_get_data_ini_fnc) != sys_get_data_ini_fnc) THEN
    MSGERROR := 'É necessário informar o período completo de vigência.';
    return;
  END IF;
  IF (nvl(DT_BAIXA_INI,sys_get_data_ini_fnc) = sys_get_data_ini_fnc AND
      nvl(DT_BAIXA_FIM,sys_get_data_ini_fnc) != sys_get_data_ini_fnc) THEN
    MSGERROR := 'É necessário informar o período completo de baixa.';
    return;
  END IF;

  -- MSGERROR := 'Qtde máxima de linhas .' || QTDE_MAX;
  -- return;

  IF DT_VIG_INI <> sys_get_data_ini_fnc AND
     DT_VIG_FIM <> sys_get_data_ini_fnc THEN
    IFLAGVI := 'S';
  END IF;

  IF DT_BAIXA_INI <> sys_get_data_ini_fnc AND
     DT_BAIXA_FIM <> sys_get_data_ini_fnc THEN
    IFLAGBX := 'S';
  END IF;

  OPEN PCONFIRMACAO_CURSOR FOR

    select *
      from (

            SELECT
            /*
             DISTINCT ROW_NUMBER() OVER(PARTITION BY COBRANCA.COD_TS, COBRANCA.COD_TS_CONTRATO
                                                 ORDER BY COBRANCA.DT_BAIXA) AS INDICE,
            */
            --                   NVL(FGET_PARCELA_BENEFICARIO(BENEFICIARIO.COD_TS,FAT.MES_ANO_REF), 
            --                   FGET_PARCELA_CONTRATO(COBRANCA.COD_TS_CONTRATO,FAT.DT_INI_PERIODO)) AS NUM_PARCELA,
             ALL_GET_PARCELA_CONTR_BEN_FNC(COBRANCA.COD_TS_CONTRATO,
                                            FAT.DT_INI_PERIODO,
                                            BENEFICIARIO.COD_TS,
                                            FAT.MES_ANO_REF) AS NUM_PARCELA,
              CE.NUM_CONTRATO,
              BENEFICIARIO.NUM_ASSOCIADO_OPERADORA MO,
              ES1.NOME_ENTIDADE NOME_ENTIDADE,
              O.NOM_OPERADORA ADM,
              PORTE.NOME_TIPO_EMPRESA PORTE,
              OP.NOM_OPERADORA NOME_OPER,
              F.NOME_SUCURSAL FILIAL,
              ESCORRETORA.NOME_ENTIDADE NOME_CORRETORA,
              CVCORRETOR.COD_CORRETOR COD_CORRETOR,
              CVCORRETORA.COD_CORRETOR COD_CORRETORA,
              ESCORRETOR.NOME_ENTIDADE NOME_CORRETOR,
              CVSUPERVISOR.COD_CORRETOR COD_SUPERVISOR,
              ESSUPERVISOR.NOME_ENTIDADE NOME_SUPERVISOR,
              P.DT_INICIO_VIGENCIA DT_VIGENCIA,
              P.NUM_PROPOSTA_ADESAO NUM_PROPOSTA,
              BENEFICIARIO.NOME_ASSOCIADO NOME_TITULAR,
              BE.NUM_CPF CPF_TITULAR,
              PM.COD_PLANO COD_PLANO,
              PM.NOME_PLANO NOME_PLANO,
              --                 P.VAL_TOTAL_COM_DESCONTO VALOR_TOTAL,
              (SELECT SUM(ITENS.VAL_ITEM_COBRANCA)
                 FROM TS.ITENS_COBRANCA@prod_allsys ITENS
                WHERE ITENS.COD_TS_TITULAR = BENEFICIARIO.COD_TS
                  AND ITENS.VAL_ITEM_PAGAR IS NOT NULL
                  AND
                     --( Unificadas Rubricas Titular e Dependente para somar valores -- Roberto Rodrigues ID: 20937
                      (ITENS.COD_TIPO_RUBRICA IN
                      (2, 18, 13, 9, 20, 17, 8, 19, 14, 100))
                     --               OR
                     --              (ITENS.COD_TIPO_RUBRICA  IN (9,20,17,8,19,14))
                     --              )
                  AND ITENS.COD_ADITIVO IS NULL
                     --         AND (IFLAGVI = 'S' AND ITENS.MES_ANO_REF = TO_DATE('01/'||TO_CHAR(DT_INI_VIG, 'MM/YYYY')) 
                     --       OR IFLAGBX = 'S' AND ITENS.MES_ANO_REF = TO_DATE('01/'||TO_CHAR(DT_BAIXA_INI, 'MM/YYYY')))  
                  AND ITENS.NUM_CICLO_TS = COBRANCA.NUM_CICLO_TS) VALOR_TOTAL,

              COBRANCA.DT_BAIXA,

              (SELECT COUNT(1)
                 FROM TS.BENEFICIARIO@prod_allsys MOV
                WHERE MOV.COD_TS_TIT = BENEFICIARIO.COD_TS_TIT) AS VIDASMEDICO,
              /*
              (SELECT COUNT(1)
               FROM TS.MC_ASSOCIADO_MOV@prod_allsys MOV
               WHERE  MOV.IND_PLANO_ODONTO = 'S'
                 AND MOV.NUM_SEQ_PROPOSTA_TS = P.NUM_SEQ_PROPOSTA_TS) AS VIDASODONTO,
              */
              0                           AS VIDASODONTO,
              COBRANCA.VAL_A_PAGAR,
              COBRANCA.VAL_PAGO,
              (SELECT SUM(ITENS.VAL_ITEM_COBRANCA)
               FROM TS.ITENS_COBRANCA@prod_allsys ITENS
               WHERE ITENS.NUM_SEQ_COBRANCA = COBRANCA.NUM_SEQ_COBRANCA
                     AND ITENS.COD_TIPO_RUBRICA IN (38, 55, 145, 245, 246)
                     AND ITENS.NUM_CICLO_TS = COBRANCA.NUM_CICLO_TS) VAL_DESCONTO,
              BENEFICIARIO.TIPO_ASSOCIADO,

              (SELECT SUM(ITENS.VAL_ITEM_PAGAR)
                 FROM TS.ITENS_COBRANCA@prod_allsys ITENS
                WHERE ITENS.NUM_SEQ_COBRANCA = COBRANCA.NUM_SEQ_COBRANCA
                  AND ITENS.COD_TIPO_RUBRICA NOT IN (4, 5, 21, 41, 45, 46, 244)
                  AND ITENS.NUM_CICLO_TS = COBRANCA.NUM_CICLO_TS) VALOR_NET,
              be.data_nascimento Nascimento,
              sys_get_idade_fnc(be.data_nascimento, sysdate) Idade,

             (SELECT S.NOME_SUCURSAL
                FROM TS.SUCURSAL@prod_allsys s,
                  TS.CORRETOR_VENDA@prod_allsys sup
                WHERE SUP.COD_CORRETOR_TS = P.COD_PRODUTOR_TS
                 AND S.COD_SUCURSAL = SUP.COD_SUCURSAL) FILIAL_CORRETORA,
                 
                 (SELECT SUM(ITENS.VAL_ITEM_COBRANCA)
                 FROM TS.ITENS_COBRANCA@prod_allsys ITENS
                WHERE ITENS.COD_TS_TITULAR = BENEFICIARIO.COD_TS
                  AND ITENS.VAL_ITEM_COBRANCA < 0
                  AND ITENS.COD_TIPO_RUBRICA IN (18, 13, 19, 14)
                  AND ITENS.NUM_CICLO_TS = COBRANCA.NUM_CICLO_TS) VALOR_DESCONTOS_MENSALIDADE

               FROM TS.BENEFICIARIO@prod_allsys          BENEFICIARIO,
                    TS.BENEFICIARIO_ENTIDADE@prod_allsys BE,
                    TS.PPF_PROPOSTA@prod_allsys          P,
                    TS.CONTRATO_EMPRESA@prod_allsys      CE,
                    TS.CORRETOR_VENDA@prod_allsys        CVCORRETORA,
                    TS.ENTIDADE_SISTEMA@prod_allsys      ESCORRETORA,
                    TS.CORRETOR_VENDA@prod_allsys        CVCORRETOR,
                    TS.ENTIDADE_SISTEMA@prod_allsys      ESCORRETOR,
                    TS.CORRETOR_VENDA@prod_allsys        CVSUPERVISOR,
                    TS.ENTIDADE_SISTEMA@prod_allsys      ESSUPERVISOR,
                    TS.PLANO_MEDICO@prod_allsys          PM,
                    TS.SUCURSAL@prod_allsys              F,
                    TS.COBRANCA@prod_allsys              COBRANCA,
                    TS.FATURA@prod_allsys                FAT,
                    TS.PPF_OPERADORAS@prod_allsys        OP,
                    TS.REGRA_EMPRESA@prod_allsys         PORTE,
                    TS.OPERADORA@prod_allsys             O,
                    TS.ENTIDADE_SISTEMA@prod_allsys      ES1
             WHERE BENEFICIARIO.NUM_SEQ_PROPOSTA_TS =
                   P.NUM_SEQ_PROPOSTA_TS(+)
               AND BENEFICIARIO.COD_ENTIDADE_TS_TIT = BE.COD_ENTIDADE_TS
               AND BENEFICIARIO.COD_TS_CONTRATO = CE.COD_TS_CONTRATO
               AND P.COD_PRODUTOR_TS = CVCORRETORA.COD_CORRETOR_TS(+)
               AND CVCORRETORA.COD_ENTIDADE_TS =
                   ESCORRETORA.COD_ENTIDADE_TS(+)
               AND P.COD_VENDEDOR_TS = CVCORRETOR.COD_CORRETOR_TS(+)
               AND CVCORRETOR.COD_ENTIDADE_TS = ESCORRETOR.COD_ENTIDADE_TS(+)
               AND P.COD_VENDEDOR_CONTATO_TS =
                   CVSUPERVISOR.COD_CORRETOR_TS(+)
               AND CVSUPERVISOR.COD_ENTIDADE_TS =
                   ESSUPERVISOR.COD_ENTIDADE_TS(+)
               AND ES1.COD_ENTIDADE_TS = CE.COD_TITULAR_CONTRATO
               AND BENEFICIARIO.COD_PLANO = PM.COD_PLANO
               AND PM.COD_TIPO_PLANO = 1
               AND P.COD_SUCURSAL = F.COD_SUCURSAL(+)
                  -- AND OP.COD_OPERADORA = PM.COD_OPERADORA
               AND OP.COD_OPERADORA = CE.COD_OPERADORA_CONTRATO
               AND COBRANCA.COD_TS = BENEFICIARIO.COD_TS
               AND BENEFICIARIO.TIPO_ASSOCIADO = 'T'
               AND COBRANCA.DT_CANCELAMENTO IS NULL
                  -- AND COBRANCA.IND_ESTADO_COBRANCA = 1
               AND COBRANCA.DT_BAIXA IS NOT NULL
               AND CE.TIPO_EMPRESA = PORTE.TIPO_EMPRESA
               AND O.COD_OPERADORA = CE.COD_OPERADORA
               AND (FAT.NUM_SEQ_FATURA_TS = COBRANCA.NUM_SEQ_FATURA_TS)
               AND ((IFLAGVI = 'S' AND
                   P.DT_INICIO_VIGENCIA BETWEEN DT_VIG_INI AND DT_VIG_FIM) OR
                   (IFLAGBX = 'S' AND COBRANCA.DT_BAIXA BETWEEN DT_BAIXA_INI AND
                   DT_BAIXA_FIM))
               AND NOT EXISTS
             (SELECT 1
                      FROM TS.ASSOCIADO@prod_allsys ASS
                     WHERE ASS.COD_TS_DESTINO = BENEFICIARIO.COD_TS
                       AND ASS.DATA_INCLUSAO < BENEFICIARIO.DATA_INCLUSAO)
               AND ES1.NOME_ENTIDADE LIKE
                   '%' || trim(UPPER(NOM_ENTID)) || '%'
               AND OP.NOM_OPERADORA LIKE
                   '%' || trim(UPPER(NOME_OPER)) || '%'
            --WHERE AA.INDICE = 1
            UNION

            SELECT
            /*
             DISTINCT ROW_NUMBER() OVER(PARTITION BY COBRANCA.COD_TS, COBRANCA.COD_TS_CONTRATO
                                                 ORDER BY COBRANCA.DT_BAIXA) AS INDICE,
            */
            --                   NVL(FGET_PARCELA_BENEFICARIO(BENEFICIARIO.COD_TS,FAT.MES_ANO_REF), 
            --                   FGET_PARCELA_CONTRATO(COBRANCA.COD_TS_CONTRATO,FAT.DT_INI_PERIODO)) AS NUM_PARCELA,
             ALL_GET_PARCELA_CONTR_BEN_FNC(COBRANCA.COD_TS_CONTRATO,
                                            FAT.DT_INI_PERIODO,
                                            BENEFICIARIO.COD_TS,
                                            FAT.MES_ANO_REF) AS NUM_PARCELA,
              CE.NUM_CONTRATO,
              BENEFICIARIO.NUM_ASSOCIADO_OPERADORA MO,
              ES1.NOME_ENTIDADE NOME_ENTIDADE,
              O.NOM_OPERADORA ADM,
              PORTE.NOME_TIPO_EMPRESA PORTE,
              OP.NOM_OPERADORA NOME_OPER,
              F.NOME_SUCURSAL FILIAL,
              ESCORRETORA.NOME_ENTIDADE NOME_CORRETORA,
              CVCORRETOR.COD_CORRETOR COD_CORRETOR,
              CVCORRETORA.COD_CORRETOR COD_CORRETORA,
              ESCORRETOR.NOME_ENTIDADE NOME_CORRETOR,
              CVSUPERVISOR.COD_CORRETOR COD_SUPERVISOR,
              ESSUPERVISOR.NOME_ENTIDADE NOME_SUPERVISOR,
              P.DT_INICIO_VIGENCIA DT_VIGENCIA,
              P.NUM_PROPOSTA_ADESAO NUM_PROPOSTA,
              BENEFICIARIO.NOME_ASSOCIADO NOME_TITULAR,
              BE.NUM_CPF CPF_TITULAR,
              PM.COD_PLANO COD_PLANO,
              PM.NOME_PLANO NOME_PLANO,
              --                 P.VAL_TOTAL_COM_DESCONTO VALOR_TOTAL,
              (SELECT SUM(ITENS.VAL_ITEM_COBRANCA)
                 FROM TS.ITENS_COBRANCA@prod_allsys ITENS
                WHERE ITENS.COD_TS_TITULAR = BENEFICIARIO.COD_TS
                  AND ITENS.VAL_ITEM_PAGAR IS NOT NULL
                  AND
                     --( Unificadas Rubricas Titular e Dependente para somar valores -- Roberto Rodrigues ID: 20937
                      (ITENS.COD_TIPO_RUBRICA IN
                      (2, 18, 13, 9, 20, 17, 8, 19, 14, 100))
                     --               OR
                     --              (ITENS.COD_TIPO_RUBRICA  IN (9,20,17,8,19,14))
                     --              )
                  AND ITENS.COD_ADITIVO IS NULL
                     --         AND (IFLAGVI = 'S' AND ITENS.MES_ANO_REF = TO_DATE('01/'||TO_CHAR(DT_INI_VIG, 'MM/YYYY')) 
                     --       OR IFLAGBX = 'S' AND ITENS.MES_ANO_REF = TO_DATE('01/'||TO_CHAR(DT_BAIXA_INI, 'MM/YYYY')))
                  AND ITENS.NUM_CICLO_TS = COBRANCA.NUM_CICLO_TS) VALOR_TOTAL,

              COBRANCA.DT_BAIXA,

              (SELECT COUNT(1)
                 FROM TS.BENEFICIARIO@prod_allsys MOV
                WHERE MOV.COD_TS_TIT = BENEFICIARIO.COD_TS_TIT) AS VIDASMEDICO,
              /*
              (SELECT COUNT(1)
               FROM TS.MC_ASSOCIADO_MOV@prod_allsys MOV
               WHERE  MOV.IND_PLANO_ODONTO = 'S'
                 AND MOV.NUM_SEQ_PROPOSTA_TS = P.NUM_SEQ_PROPOSTA_TS) AS VIDASODONTO,
              */
              0                           AS VIDASODONTO,
              COBRANCA.VAL_A_PAGAR,
              COBRANCA.VAL_PAGO,
             (SELECT SUM(ITENS.VAL_ITEM_COBRANCA)
              FROM TS.ITENS_COBRANCA@prod_allsys ITENS
              WHERE ITENS.NUM_SEQ_COBRANCA = COBRANCA.NUM_SEQ_COBRANCA
                     AND ITENS.COD_TIPO_RUBRICA IN (38, 55, 145, 245, 246)
                     AND ITENS.NUM_CICLO_TS = COBRANCA.NUM_CICLO_TS) VAL_DESCONTO,
              BENEFICIARIO.TIPO_ASSOCIADO,

              (SELECT SUM(ITENS.VAL_ITEM_PAGAR)
                 FROM TS.ITENS_COBRANCA@prod_allsys ITENS
                WHERE ITENS.NUM_SEQ_COBRANCA = COBRANCA.NUM_SEQ_COBRANCA
                  AND ITENS.COD_TIPO_RUBRICA NOT IN (4, 5, 21, 41, 45, 46, 244)
                  AND ITENS.NUM_CICLO_TS = COBRANCA.NUM_CICLO_TS) VALOR_NET,
              be.data_nascimento Nascimento,
              sys_get_idade_fnc(be.data_nascimento, sysdate) Idade,

              (SELECT S.NOME_SUCURSAL
                FROM TS.SUCURSAL@prod_allsys s,
                  TS.CORRETOR_VENDA@prod_allsys sup
                WHERE SUP.COD_CORRETOR_TS = P.COD_PRODUTOR_TS
                 AND S.COD_SUCURSAL = SUP.COD_SUCURSAL) FILIAL_CORRETORA,
                 
                 (SELECT SUM(ITENS.VAL_ITEM_COBRANCA)
                 FROM TS.ITENS_COBRANCA@prod_allsys ITENS
                WHERE ITENS.COD_TS_TITULAR = BENEFICIARIO.COD_TS
                  AND ITENS.VAL_ITEM_COBRANCA < 0
                  AND ITENS.COD_TIPO_RUBRICA IN (18, 13, 19, 14)
                  AND ITENS.NUM_CICLO_TS = COBRANCA.NUM_CICLO_TS) VALOR_DESCONTOS_MENSALIDADE

              FROM TS.BENEFICIARIO@prod_allsys          BENEFICIARIO,
                    TS.BENEFICIARIO_ENTIDADE@prod_allsys BE,
                    TS.PPF_PROPOSTA@prod_allsys          P,
                    TS.CONTRATO_EMPRESA@prod_allsys      CE,
                    TS.CORRETOR_VENDA@prod_allsys        CVCORRETORA,
                    TS.ENTIDADE_SISTEMA@prod_allsys      ESCORRETORA,
                    TS.CORRETOR_VENDA@prod_allsys        CVCORRETOR,
                    TS.ENTIDADE_SISTEMA@prod_allsys      ESCORRETOR,
                    TS.CORRETOR_VENDA@prod_allsys        CVSUPERVISOR,
                    TS.ENTIDADE_SISTEMA@prod_allsys      ESSUPERVISOR,
                    TS.PLANO_MEDICO@prod_allsys          PM,
                    TS.SUCURSAL@prod_allsys              F,
                    TS.COBRANCA@prod_allsys              COBRANCA,
                    TS.FATURA@prod_allsys                FAT,
                    TS.PPF_OPERADORAS@prod_allsys        OP,
                    TS.ASSOCIADO@prod_allsys             A,
                    TS.REGRA_EMPRESA@prod_allsys         PORTE,
                    TS.OPERADORA@prod_allsys             O,
                    TS.ENTIDADE_SISTEMA@prod_allsys      ES1
             WHERE BENEFICIARIO.NUM_SEQ_PROPOSTA_TS =
                   P.NUM_SEQ_PROPOSTA_TS(+)
               AND BENEFICIARIO.COD_ENTIDADE_TS_TIT = BE.COD_ENTIDADE_TS
               AND BENEFICIARIO.COD_TS_CONTRATO = CE.COD_TS_CONTRATO
               AND P.COD_PRODUTOR_TS = CVCORRETORA.COD_CORRETOR_TS(+)
               AND CVCORRETORA.COD_ENTIDADE_TS =
                   ESCORRETORA.COD_ENTIDADE_TS(+)
               AND P.COD_VENDEDOR_TS = CVCORRETOR.COD_CORRETOR_TS(+)
               AND CVCORRETOR.COD_ENTIDADE_TS = ESCORRETOR.COD_ENTIDADE_TS(+)
               AND P.COD_VENDEDOR_CONTATO_TS =
                   CVSUPERVISOR.COD_CORRETOR_TS(+)
               AND CVSUPERVISOR.COD_ENTIDADE_TS =
                   ESSUPERVISOR.COD_ENTIDADE_TS(+)
               AND A.COD_TS_DESTINO = BENEFICIARIO.COD_TS
               AND ES1.COD_ENTIDADE_TS = CE.COD_TITULAR_CONTRATO
               AND CE.TIPO_EMPRESA = PORTE.TIPO_EMPRESA
               AND O.COD_OPERADORA = CE.COD_OPERADORA
               AND A.COD_PLANO = PM.COD_PLANO
               AND PM.COD_TIPO_PLANO = 1
               AND P.COD_SUCURSAL = F.COD_SUCURSAL(+)
                  --  AND OP.COD_OPERADORA = PM.COD_OPERADORA
               AND OP.COD_OPERADORA = CE.COD_OPERADORA_CONTRATO
               AND (FAT.NUM_SEQ_FATURA_TS = COBRANCA.NUM_SEQ_FATURA_TS)
               AND COBRANCA.COD_TS = A.COD_TS_DESTINO
               AND A.TIPO_ASSOCIADO = 'T'
               AND COBRANCA.DT_CANCELAMENTO IS NULL
                  --  AND COBRANCA.IND_ESTADO_COBRANCA = 1
               AND COBRANCA.DT_BAIXA IS NOT NULL
               AND A.COD_TS_DESTINO IS NOT NULL
               AND ((IFLAGVI = 'S' AND
                   P.DT_INICIO_VIGENCIA BETWEEN DT_VIG_INI AND DT_VIG_FIM) OR
                   (IFLAGBX = 'S' AND COBRANCA.DT_BAIXA BETWEEN DT_BAIXA_INI AND
                   DT_BAIXA_FIM))
               AND ES1.NOME_ENTIDADE LIKE
                   '%' || trim(UPPER(NOM_ENTID)) || '%'
               AND OP.NOM_OPERADORA LIKE
                   '%' || trim(UPPER(NOME_OPER)) || '%'
            --WHERE AA.INDICE = 1
            UNION ALL

            SELECT
            /*
             DISTINCT ROW_NUMBER() OVER(PARTITION BY COBRANCA.COD_TS, COBRANCA.COD_TS_CONTRATO
                                                 ORDER BY COBRANCA.DT_BAIXA) AS INDICE,
            */
            --                   NVL(FGET_PARCELA_BENEFICARIO(BENEFICIARIO.COD_TS,FAT.MES_ANO_REF), 
            --                   FGET_PARCELA_CONTRATO(COBRANCA.COD_TS_CONTRATO,FAT.DT_INI_PERIODO)) AS NUM_PARCELA,
             ALL_GET_PARCELA_CONTR_BEN_FNC(COBRANCA.COD_TS_CONTRATO,
                                            FAT.DT_INI_PERIODO,
                                            BENEFICIARIO.COD_TS,
                                            FAT.MES_ANO_REF) AS NUM_PARCELA,
              CE.NUM_CONTRATO,
              BENEFICIARIO.NUM_ASSOCIADO_OPERADORA MO,
              ES1.NOME_ENTIDADE NOME_ENTIDADE,
              O.NOM_OPERADORA ADM,
              PORTE.NOME_TIPO_EMPRESA PORTE,
              OP.NOM_OPERADORA,
              F.NOME_SUCURSAL FILIAL,
              ESCORRETORA.NOME_ENTIDADE NOME_CORRETORA,
              CVCORRETOR.COD_CORRETOR COD_CORRETOR,
              CVCORRETORA.COD_CORRETOR COD_CORRETORA,
              ESCORRETOR.NOME_ENTIDADE NOME_CORRETOR,
              CVSUPERVISOR.COD_CORRETOR COD_SUPERVISOR,
              ESSUPERVISOR.NOME_ENTIDADE NOME_SUPERVISOR,
              P.DT_INICIO_VIGENCIA DT_VIGENCIA,
              P.NUM_PROPOSTA_ADESAO NUM_PROPOSTA,
              BENEFICIARIO.NOME_ASSOCIADO NOME_TITULAR,
              BE.NUM_CPF CPF_TITULAR,
              PM.COD_PLANO COD_PLANO,
              PM.NOME_PLANO NOME_PLANO,
              --                 P.VAL_TOTAL_ODONTO VALOR_TOTAL,
              (SELECT SUM(ITENS.VAL_ITEM_COBRANCA)
                 FROM TS.ITENS_COBRANCA@prod_allsys ITENS
                WHERE ITENS.COD_TS_TITULAR = BENEFICIARIO.COD_TS
                  AND (
                      -- Unificadas Rubricas Titular e Dependente para somar valores -- Roberto Rodrigues ID: 20937
                       ITENS.COD_TIPO_RUBRICA = 50 OR
                       ITENS.COD_TIPO_RUBRICA IN
                       (2, 18, 13, 9, 20, 17, 8, 19, 14, 100) AND
                       ITENS.COD_ADITIVO IS NULL)
                     --              OR
                     --              (ITENS.COD_TIPO_RUBRICA  IN (9,20,17,8,19,14) AND ITENS.COD_ADITIVO IS NULL)
                     --              )
                     --         AND (IFLAGVI = 'S' AND ITENS.MES_ANO_REF = TO_DATE('01/'||TO_CHAR(DT_INI_VIG, 'MM/YYYY'))
                     --       OR IFLAGBX = 'S' AND ITENS.MES_ANO_REF = TO_DATE('01/'||TO_CHAR(DT_BAIXA_INI, 'MM/YYYY')))
                  AND ITENS.NUM_CICLO_TS = COBRANCA.NUM_CICLO_TS) VALOR_TOTAL,

              COBRANCA.DT_BAIXA,
              /*
              (SELECT COUNT(1)
               FROM TS.MC_ASSOCIADO_MOV@prod_allsys MOV
               WHERE MOV.IND_PLANO = 'S'
                 AND MOV.NUM_SEQ_PROPOSTA_TS = P.NUM_SEQ_PROPOSTA_TS) AS VIDASMEDICO,
              */
              0 AS VIDASMEDICO,
              (SELECT COUNT(1)
                 FROM TS.BENEFICIARIO@prod_allsys MOV
                WHERE MOV.COD_TS_TIT = BENEFICIARIO.COD_TS_TIT) AS VIDASODONTO,

              COBRANCA.VAL_A_PAGAR,
              COBRANCA.VAL_PAGO,
              (SELECT SUM(ITENS.VAL_ITEM_COBRANCA)
               FROM TS.ITENS_COBRANCA@prod_allsys ITENS
               WHERE ITENS.NUM_SEQ_COBRANCA = COBRANCA.NUM_SEQ_COBRANCA
                     AND ITENS.COD_TIPO_RUBRICA IN (38, 55, 145, 245, 246)
                     AND ITENS.NUM_CICLO_TS = COBRANCA.NUM_CICLO_TS) VAL_DESCONTO,
              BENEFICIARIO.TIPO_ASSOCIADO,

              (SELECT SUM(ITENS.VAL_ITEM_PAGAR)
                 FROM TS.ITENS_COBRANCA@prod_allsys ITENS
                WHERE ITENS.NUM_SEQ_COBRANCA = COBRANCA.NUM_SEQ_COBRANCA
                  AND ITENS.COD_TIPO_RUBRICA NOT IN (4, 5, 21, 41, 45, 46, 244)
                  AND ITENS.NUM_CICLO_TS = COBRANCA.NUM_CICLO_TS) VALOR_NET,
              be.data_nascimento Nascimento,
              sys_get_idade_fnc(be.data_nascimento, sysdate) Idade,

              (SELECT S.NOME_SUCURSAL
                FROM TS.SUCURSAL@prod_allsys s,
                  TS.CORRETOR_VENDA@prod_allsys sup
                WHERE SUP.COD_CORRETOR_TS = P.COD_PRODUTOR_TS
                 AND S.COD_SUCURSAL = SUP.COD_SUCURSAL) FILIAL_CORRETORA,
                 
                 (SELECT SUM(ITENS.VAL_ITEM_COBRANCA)
                 FROM TS.ITENS_COBRANCA@prod_allsys ITENS
                WHERE ITENS.COD_TS_TITULAR = BENEFICIARIO.COD_TS
                  AND ITENS.VAL_ITEM_COBRANCA < 0
                  AND ITENS.COD_TIPO_RUBRICA IN (18, 13, 19, 14)
                  AND ITENS.NUM_CICLO_TS = COBRANCA.NUM_CICLO_TS) VALOR_DESCONTOS_MENSALIDADE

              FROM TS.BENEFICIARIO@prod_allsys          BENEFICIARIO,
                    TS.BENEFICIARIO_ENTIDADE@prod_allsys BE,
                    TS.PPF_PROPOSTA@prod_allsys          P,
                    TS.CONTRATO_EMPRESA@prod_allsys      CE,
                    TS.CORRETOR_VENDA@prod_allsys        CVCORRETORA,
                    TS.ENTIDADE_SISTEMA@prod_allsys      ESCORRETORA,
                    TS.CORRETOR_VENDA@prod_allsys        CVCORRETOR,
                    TS.ENTIDADE_SISTEMA@prod_allsys      ESCORRETOR,
                    TS.CORRETOR_VENDA@prod_allsys        CVSUPERVISOR,
                    TS.ENTIDADE_SISTEMA@prod_allsys      ESSUPERVISOR,
                    TS.PLANO_MEDICO@prod_allsys          PM,
                    --      TS.MC_ASSOCIADO_MOV@prod_allsys M,
                    TS.SUCURSAL@prod_allsys         F,
                    TS.COBRANCA@prod_allsys         COBRANCA,
                    TS.FATURA@prod_allsys           FAT,
                    TS.PPF_OPERADORAS@prod_allsys   OP,
                    TS.REGRA_EMPRESA@prod_allsys    PORTE,
                    TS.OPERADORA@prod_allsys        O,
                    TS.ENTIDADE_SISTEMA@prod_allsys ES1
             WHERE BENEFICIARIO.NUM_SEQ_PROPOSTA_TS =
                   P.NUM_SEQ_PROPOSTA_TS(+)
               AND BENEFICIARIO.COD_ENTIDADE_TS_TIT = BE.COD_ENTIDADE_TS
                  --   AND P.COD_TS_CONTRATO_CMS_DENTAL = CE.COD_TS_CONTRATO
               AND BENEFICIARIO.COD_TS_CONTRATO = CE.COD_TS_CONTRATO
               AND P.COD_PRODUTOR_TS = CVCORRETORA.COD_CORRETOR_TS(+)
               AND CVCORRETORA.COD_ENTIDADE_TS =
                   ESCORRETORA.COD_ENTIDADE_TS(+)
               AND P.COD_VENDEDOR_TS = CVCORRETOR.COD_CORRETOR_TS(+)
               AND CVCORRETOR.COD_ENTIDADE_TS = ESCORRETOR.COD_ENTIDADE_TS(+)
               AND P.COD_VENDEDOR_CONTATO_TS =
                   CVSUPERVISOR.COD_CORRETOR_TS(+)
               AND CVSUPERVISOR.COD_ENTIDADE_TS =
                   ESSUPERVISOR.COD_ENTIDADE_TS(+)
                  --   AND P.NUM_SEQ_PROPOSTA_TS = M.NUM_SEQ_PROPOSTA_TS(+)
               AND ES1.COD_ENTIDADE_TS = CE.COD_TITULAR_CONTRATO
               AND BENEFICIARIO.COD_PLANO = PM.COD_PLANO
               AND PM.COD_TIPO_PLANO = 4
               AND P.COD_SUCURSAL = F.COD_SUCURSAL(+)
                  --   AND OP.COD_OPERADORA = PM.COD_OPERADORA
               AND OP.COD_OPERADORA = CE.COD_OPERADORA_CONTRATO
               AND COBRANCA.COD_TS = BENEFICIARIO.COD_TS
               AND BENEFICIARIO.TIPO_ASSOCIADO = 'T'
               AND COBRANCA.DT_CANCELAMENTO IS NULL
                  -- AND COBRANCA.IND_ESTADO_COBRANCA = 1
               AND COBRANCA.DT_BAIXA IS NOT NULL
               AND CE.TIPO_EMPRESA = PORTE.TIPO_EMPRESA
               AND O.COD_OPERADORA = CE.COD_OPERADORA
               and BENEFICIARIO.TIPO_ASSOCIADO = 'T'
               AND (FAT.NUM_SEQ_FATURA_TS = COBRANCA.NUM_SEQ_FATURA_TS)
               AND ((IFLAGVI = 'S' AND
                   P.DT_INICIO_VIGENCIA BETWEEN DT_VIG_INI AND DT_VIG_FIM) OR
                   (IFLAGBX = 'S' AND COBRANCA.DT_BAIXA BETWEEN DT_BAIXA_INI AND
                   DT_BAIXA_FIM))
               AND NOT EXISTS
             (SELECT 1
                      FROM TS.ASSOCIADO@prod_allsys ASS
                     WHERE ASS.COD_TS_DESTINO = BENEFICIARIO.COD_TS
                       AND ASS.DATA_INCLUSAO < BENEFICIARIO.DATA_INCLUSAO)
               AND ES1.NOME_ENTIDADE LIKE
                   '%' || trim(UPPER(NOM_ENTID)) || '%'
               AND OP.NOM_OPERADORA LIKE
                   '%' || trim(UPPER(NOME_OPER)) || '%'
            --WHERE AA.INDICE = 1
            UNION

            SELECT
            /* 
             DISTINCT ROW_NUMBER() OVER(PARTITION BY COBRANCA.COD_TS, COBRANCA.COD_TS_CONTRATO
                                                 ORDER BY COBRANCA.DT_BAIXA) AS INDICE,
            */
            --                   NVL(FGET_PARCELA_BENEFICARIO(BENEFICIARIO.COD_TS,FAT.MES_ANO_REF), 
            --                   FGET_PARCELA_CONTRATO(COBRANCA.COD_TS_CONTRATO,FAT.DT_INI_PERIODO)) AS NUM_PARCELA,
             ALL_GET_PARCELA_CONTR_BEN_FNC(COBRANCA.COD_TS_CONTRATO,
                                            FAT.DT_INI_PERIODO,
                                            BENEFICIARIO.COD_TS,
                                            FAT.MES_ANO_REF) AS NUM_PARCELA,
              CE.NUM_CONTRATO,
              BENEFICIARIO.NUM_ASSOCIADO_OPERADORA MO,
              ES1.NOME_ENTIDADE NOME_ENTIDADE,
              O.NOM_OPERADORA ADM,
              PORTE.NOME_TIPO_EMPRESA PORTE,
              OP.NOM_OPERADORA NOME_OPER,
              F.NOME_SUCURSAL FILIAL,
              ESCORRETORA.NOME_ENTIDADE NOME_CORRETORA,
              CVCORRETOR.COD_CORRETOR COD_CORRETOR,
              CVCORRETORA.COD_CORRETOR COD_CORRETORA,
              ESCORRETOR.NOME_ENTIDADE NOME_CORRETOR,
              CVSUPERVISOR.COD_CORRETOR COD_SUPERVISOR,
              ESSUPERVISOR.NOME_ENTIDADE NOME_SUPERVISOR,
              P.DT_INICIO_VIGENCIA DT_VIGENCIA,
              P.NUM_PROPOSTA_ADESAO NUM_PROPOSTA,
              BENEFICIARIO.NOME_ASSOCIADO NOME_TITULAR,
              BE.NUM_CPF CPF_TITULAR,
              PM.COD_PLANO COD_PLANO,
              PM.NOME_PLANO NOME_PLANO,
              --                 P.VAL_TOTAL_ODONTO VALOR_TOTAL,
              (SELECT SUM(ITENS.VAL_ITEM_COBRANCA)
                 FROM TS.ITENS_COBRANCA@prod_allsys ITENS
                WHERE ITENS.COD_TS_TITULAR = BENEFICIARIO.COD_TS
                  AND (
                      -- Unificadas Rubricas Titular e Dependente para somar valores -- Roberto Rodrigues ID: 20937
                       ITENS.COD_TIPO_RUBRICA = 50 OR
                       ITENS.COD_TIPO_RUBRICA IN
                       (2, 18, 13, 9, 20, 17, 8, 19, 14, 100) AND
                       ITENS.COD_ADITIVO IS NULL)
                     --              OR
                     --              (ITENS.COD_TIPO_RUBRICA  IN (9,20,17,8,19,14) AND ITENS.COD_ADITIVO IS NULL)
                     --              )
                     --         AND (IFLAGVI = 'S' AND ITENS.MES_ANO_REF = TO_DATE('01/'||TO_CHAR(DT_INI_VIG, 'MM/YYYY'))
                     --       OR IFLAGBX = 'S' AND ITENS.MES_ANO_REF = TO_DATE('01/'||TO_CHAR(DT_BAIXA_INI, 'MM/YYYY')))
                  AND ITENS.NUM_CICLO_TS = COBRANCA.NUM_CICLO_TS) VALOR_TOTAL,

              COBRANCA.DT_BAIXA,
              /*           
              (SELECT COUNT(1)
               FROM TS.MC_ASSOCIADO_MOV@prod_allsys MOV
               WHERE MOV.IND_PLANO = 'S'
                 AND MOV.NUM_SEQ_PROPOSTA_TS = P.NUM_SEQ_PROPOSTA_TS) AS VIDASMEDICO,
              */
              0 AS VIDASMEDICO,
              (SELECT COUNT(1)
                 FROM TS.BENEFICIARIO@prod_allsys MOV
                WHERE MOV.COD_TS_TIT = BENEFICIARIO.COD_TS_TIT) AS VIDASODONTO,

              COBRANCA.VAL_A_PAGAR,
              COBRANCA.VAL_PAGO,
              (SELECT SUM(ITENS.VAL_ITEM_COBRANCA)
               FROM TS.ITENS_COBRANCA@prod_allsys ITENS
               WHERE ITENS.NUM_SEQ_COBRANCA = COBRANCA.NUM_SEQ_COBRANCA
                     AND ITENS.COD_TIPO_RUBRICA IN (38, 55, 145, 245, 246)
                     AND ITENS.NUM_CICLO_TS = COBRANCA.NUM_CICLO_TS) VAL_DESCONTO,
              BENEFICIARIO.TIPO_ASSOCIADO,

              (SELECT SUM(ITENS.VAL_ITEM_PAGAR)
                 FROM TS.ITENS_COBRANCA@prod_allsys ITENS
                WHERE ITENS.NUM_SEQ_COBRANCA = COBRANCA.NUM_SEQ_COBRANCA
                  AND ITENS.COD_TIPO_RUBRICA NOT IN (4, 5, 21, 41, 45, 46, 244)
                  AND ITENS.NUM_CICLO_TS = COBRANCA.NUM_CICLO_TS) VALOR_NET,
              be.data_nascimento Nascimento,
              sys_get_idade_fnc(be.data_nascimento, sysdate) Idade,

               (SELECT S.NOME_SUCURSAL
                FROM TS.SUCURSAL@prod_allsys s,
                  TS.CORRETOR_VENDA@prod_allsys sup
                WHERE SUP.COD_CORRETOR_TS = P.COD_PRODUTOR_TS
                 AND S.COD_SUCURSAL = SUP.COD_SUCURSAL) FILIAL_CORRETORA,
                 
                 (SELECT SUM(ITENS.VAL_ITEM_COBRANCA)
                 FROM TS.ITENS_COBRANCA@prod_allsys ITENS
                WHERE ITENS.COD_TS_TITULAR = BENEFICIARIO.COD_TS
                  AND ITENS.VAL_ITEM_COBRANCA < 0
                  AND ITENS.COD_TIPO_RUBRICA IN (18, 13, 19, 14)
                  AND ITENS.NUM_CICLO_TS = COBRANCA.NUM_CICLO_TS) VALOR_DESCONTOS_MENSALIDADE

              FROM TS.BENEFICIARIO@prod_allsys          BENEFICIARIO,
                    TS.BENEFICIARIO_ENTIDADE@prod_allsys BE,
                    TS.PPF_PROPOSTA@prod_allsys          P,
                    TS.CONTRATO_EMPRESA@prod_allsys      CE,
                    TS.CORRETOR_VENDA@prod_allsys        CVCORRETORA,
                    TS.ENTIDADE_SISTEMA@prod_allsys      ESCORRETORA,
                    TS.CORRETOR_VENDA@prod_allsys        CVCORRETOR,
                    TS.ENTIDADE_SISTEMA@prod_allsys      ESCORRETOR,
                    TS.CORRETOR_VENDA@prod_allsys        CVSUPERVISOR,
                    TS.ENTIDADE_SISTEMA@prod_allsys      ESSUPERVISOR,
                    TS.PLANO_MEDICO@prod_allsys          PM,
                    TS.SUCURSAL@prod_allsys              F,
                    TS.COBRANCA@prod_allsys              COBRANCA,
                    TS.FATURA@prod_allsys                FAT,
                    TS.PPF_OPERADORAS@prod_allsys        OP,
                    TS.ASSOCIADO@prod_allsys             A,
                    TS.REGRA_EMPRESA@prod_allsys         PORTE,
                    TS.OPERADORA@prod_allsys             O,
                    TS.ENTIDADE_SISTEMA@prod_allsys      ES1
             WHERE BENEFICIARIO.NUM_SEQ_PROPOSTA_TS =
                   P.NUM_SEQ_PROPOSTA_TS(+)
               AND BENEFICIARIO.COD_ENTIDADE_TS_TIT = BE.COD_ENTIDADE_TS
                  --   AND P.COD_TS_CONTRATO_CMS_DENTAL = CE.COD_TS_CONTRATO
               AND BENEFICIARIO.COD_TS_CONTRATO = CE.COD_TS_CONTRATO
               AND P.COD_PRODUTOR_TS = CVCORRETORA.COD_CORRETOR_TS(+)
               AND CVCORRETORA.COD_ENTIDADE_TS =
                   ESCORRETORA.COD_ENTIDADE_TS(+)
               AND P.COD_VENDEDOR_TS = CVCORRETOR.COD_CORRETOR_TS(+)
               AND CVCORRETOR.COD_ENTIDADE_TS = ESCORRETOR.COD_ENTIDADE_TS(+)
               AND P.COD_VENDEDOR_CONTATO_TS =
                   CVSUPERVISOR.COD_CORRETOR_TS(+)
               AND CVSUPERVISOR.COD_ENTIDADE_TS =
                   ESSUPERVISOR.COD_ENTIDADE_TS(+)
               AND A.COD_TS_DESTINO = BENEFICIARIO.COD_TS
               AND ES1.COD_ENTIDADE_TS = CE.COD_TITULAR_CONTRATO
               AND CE.TIPO_EMPRESA = PORTE.TIPO_EMPRESA
               AND O.COD_OPERADORA = CE.COD_OPERADORA
               AND A.cod_plano_novo = PM.COD_PLANO
               AND PM.COD_TIPO_PLANO = 4
               AND P.COD_SUCURSAL = F.COD_SUCURSAL(+)
                  --   AND OP.COD_OPERADORA = PM.COD_OPERADORA
               AND OP.COD_OPERADORA = CE.COD_OPERADORA_CONTRATO
               AND (FAT.NUM_SEQ_FATURA_TS = COBRANCA.NUM_SEQ_FATURA_TS)
               AND COBRANCA.COD_TS = A.COD_TS_DESTINO
               AND A.TIPO_ASSOCIADO = 'T'
               AND COBRANCA.DT_CANCELAMENTO IS NULL
                  --  AND COBRANCA.IND_ESTADO_COBRANCA = 1
               AND COBRANCA.DT_BAIXA IS NOT NULL
               AND A.COD_TS_DESTINO IS NOT NULL
               AND ((IFLAGVI = 'S' AND
                   P.DT_INICIO_VIGENCIA BETWEEN DT_VIG_INI AND DT_VIG_FIM) OR
                   (IFLAGBX = 'S' AND COBRANCA.DT_BAIXA BETWEEN DT_BAIXA_INI AND
                   DT_BAIXA_FIM))
               AND ES1.NOME_ENTIDADE LIKE
                   '%' || trim(UPPER(NOM_ENTID)) || '%'
               AND OP.NOM_OPERADORA LIKE
                   '%' || trim(UPPER(NOME_OPER)) || '%'
            /*
            ORDER BY 4,
                     3,
                     14;
            */

            )
     where rownum <= iQtdeMax;
END ALL_BI_CONF_VEND_AD_PCD;