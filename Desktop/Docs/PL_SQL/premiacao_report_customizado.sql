  select 
  BENEFICIARIO.COD_TS_TIT Familia,
  ALL_GET_PARCELA_CONTR_BEN_FNC(COBRANCA.COD_TS_CONTRATO, 
                                FAT.DT_INI_PERIODO,
                                BENEFICIARIO.COD_TS_TIT,
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
                BENEFICIARIO.NOME_ASSOCIADO NOME_BENEFICIARIO,
                lpad(BE.NUM_CPF, 11, '0') CPF,
                PM.COD_PLANO COD_PLANO,
                PM.NOME_PLANO NOME_PLANO,

                (SELECT SUM(ITENS.VAL_ITEM_COBRANCA)
                   FROM TS.ITENS_COBRANCA@prod_allsys ITENS
                  WHERE ITENS.COD_TS_TITULAR = BENEFICIARIO.COD_TS_TIT
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
                    AND ITENS.NUM_CICLO_TS = COBRANCA.NUM_CICLO_TS) VALOR_DESCONTOS_MENSALIDADE,
                    
                    (select LPAD(es2.NUM_CPF, 11, '0')
                     from ts.beneficiario_entidade@prod_allsys es2
                     where es2.cod_entidade_ts = beneficiario.cod_entidade_ts_tit) cpf_titular,

                    (select b2.nome_associado
                     from ts.beneficiario@prod_allsys b2
                     where b2.cod_ts = beneficiario.cod_ts_tit) nome_titular

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

  WHERE BENEFICIARIO.NUM_SEQ_PROPOSTA_TS = P.NUM_SEQ_PROPOSTA_TS(+)
        AND BENEFICIARIO.COD_ENTIDADE_TS = BE.COD_ENTIDADE_TS
        AND BENEFICIARIO.COD_TS_CONTRATO = CE.COD_TS_CONTRATO
        AND P.COD_PRODUTOR_TS = CVCORRETORA.COD_CORRETOR_TS(+)
        AND CVCORRETORA.COD_ENTIDADE_TS = ESCORRETORA.COD_ENTIDADE_TS(+)
        AND P.COD_VENDEDOR_TS = CVCORRETOR.COD_CORRETOR_TS(+)
        AND CVCORRETOR.COD_ENTIDADE_TS = ESCORRETOR.COD_ENTIDADE_TS(+)
        AND P.COD_VENDEDOR_CONTATO_TS = CVSUPERVISOR.COD_CORRETOR_TS(+)
        AND CVSUPERVISOR.COD_ENTIDADE_TS = ESSUPERVISOR.COD_ENTIDADE_TS(+)
        AND ES1.COD_ENTIDADE_TS = CE.COD_TITULAR_CONTRATO
        AND BENEFICIARIO.COD_PLANO = PM.COD_PLANO
        AND PM.COD_TIPO_PLANO = 1
        AND P.COD_SUCURSAL = F.COD_SUCURSAL(+)
        AND OP.COD_OPERADORA = CE.COD_OPERADORA_CONTRATO
        AND COBRANCA.COD_TS = BENEFICIARIO.COD_TS_TIT
        --AND BENEFICIARIO.TIPO_ASSOCIADO = 'T'
        AND COBRANCA.DT_CANCELAMENTO IS NULL

        AND COBRANCA.DT_BAIXA between to_date('11/12/2021', 'dd/mm/yyyy') 
                                      and to_date('20/12/2021', 'dd/mm/yyyy')

        AND CE.TIPO_EMPRESA = PORTE.TIPO_EMPRESA
        AND O.COD_OPERADORA = CE.COD_OPERADORA
        AND FAT.NUM_SEQ_FATURA_TS = COBRANCA.NUM_SEQ_FATURA_TS
        
        AND NOT EXISTS (SELECT 1
                        FROM TS.ASSOCIADO@prod_allsys ASS
                        WHERE ASS.COD_TS_DESTINO = BENEFICIARIO.COD_TS
                              AND ASS.DATA_INCLUSAO < BENEFICIARIO.DATA_INCLUSAO)
                              
          
         --and op.cod_operadora = 134                                                        
                              
  order by 1, 29 desc                             
