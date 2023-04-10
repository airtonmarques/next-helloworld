create table TMP_BENE
as select 
        BENEFICIARIO.COD_TS_TIT Familia,
              CE.NUM_CONTRATO,
              ce.num_contrato_operadora,
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
              cobranca.dt_competencia,
              COBRANCA.DT_BAIXA,

              (SELECT COUNT(1)
                 FROM TS.BENEFICIARIO@prod_allsys MOV
                WHERE MOV.COD_TS_TIT = BENEFICIARIO.COD_TS_TIT) AS VIDASMEDICO,

              0                           AS VIDASODONTO,
              COBRANCA.VAL_A_PAGAR,
              COBRANCA.VAL_PAGO,

              be.data_nascimento Nascimento,
              sys_get_idade_fnc(be.data_nascimento, sysdate) Idade,

             (SELECT S.NOME_SUCURSAL
                FROM TS.SUCURSAL@prod_allsys s,
                  TS.CORRETOR_VENDA@prod_allsys sup
                WHERE SUP.COD_CORRETOR_TS = P.COD_PRODUTOR_TS
                 AND S.COD_SUCURSAL = SUP.COD_SUCURSAL) FILIAL_CORRETORA,
                  
                  (select LPAD(es2.NUM_CPF, 11, '0')
                   from ts.beneficiario_entidade@prod_allsys es2
                   where es2.cod_entidade_ts = beneficiario.cod_entidade_ts_tit) cpf_titular,

                  (select b2.nome_associado
                   from ts.beneficiario@prod_allsys b2
                   where b2.cod_ts = beneficiario.cod_ts_tit) nome_titular,
                   
                   (select aa.num_associado_operadora 
                   from ts.associado_aditivo@prod_allsys aa
                   where aa.cod_ts = beneficiario.cod_ts
                         and aa.cod_ts_contrato = beneficiario.cod_ts_contrato
                         and aa.dt_ini_vigencia = (select max(aa1.dt_ini_vigencia)
                                                   from ts.associado_aditivo@prod_allsys aa1
                                                   where aa1.cod_ts = beneficiario.cod_ts
                                                         and aa1.cod_ts_contrato = beneficiario.cod_ts_contrato
                                                         and rownum = 1)
                   
                         and aa.dt_atu = (select max(aa2.dt_atu)
                                                   from ts.associado_aditivo@prod_allsys aa2
                                                   where aa2.cod_ts = beneficiario.cod_ts
                                                         and aa2.cod_ts_contrato = beneficiario.cod_ts_contrato)
                                                         and rownum = 1) mo_dental

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
      /*
      AND COBRANCA.DT_BAIXA between to_date('01/06/2021', 'dd/mm/yyyy') 
                                    and to_date('10/06/2021', 'dd/mm/yyyy')
      */
      
      and cobranca.dt_competencia between to_date('01/06/2020', 'dd/mm/yyyy')
          and last_day('01/06/2021')
      AND CE.TIPO_EMPRESA = PORTE.TIPO_EMPRESA
      AND O.COD_OPERADORA = CE.COD_OPERADORA
      AND FAT.NUM_SEQ_FATURA_TS = COBRANCA.NUM_SEQ_FATURA_TS
      
      AND NOT EXISTS (SELECT 1
                      FROM TS.ASSOCIADO@prod_allsys ASS
                      WHERE ASS.COD_TS_DESTINO = BENEFICIARIO.COD_TS
                            AND ASS.DATA_INCLUSAO < BENEFICIARIO.DATA_INCLUSAO)
                            
       
       and op.cod_operadora IN (70, 4, 1)                                                        
                            
--order by 1, 30 desc                             
