--CREATE TABLE alt_inadimplentes AS
insert into alt_inadimplentes
SELECT ADM.NOM_OPERADORA ADMINISTRADORA,
               SU.NOME_SUCURSAL FILIAL,
               ES.NOME_ENTIDADE,
               RE.NOME_TIPO_EMPRESA PORTE,
               OP.NOM_OPERADORA OPERADORA,
               CE.NUM_CONTRATO_OPERADORA,
               CE.NUM_CONTRATO CONTRATO_ALLCARE,
               B.COD_TS,
               B.COD_TS_TIT,
              DECODE(B.TIPO_ASSOCIADO,
                  'T',
                  'TITULAR',
                  'P',
                  'PATROCINADOR',
                  'DEPENDENTE') TIPO_ASSOCIADO,
               B.NUM_ASSOCIADO,
               B.NUM_ASSOCIADO_OPERADORA,
               TRUNC (SYSDATE
                   - NVL (C.DT_VENCIMENTO_ORIG,
                          C.DT_VENCIMENTO))DIAS_ATRASO,
               (SELECT XX.NOME_ASSOCIADO
                  FROM TS.BENEFICIARIO XX
                 WHERE     XX.COD_TS = B.COD_TS_TIT
                       AND ROWNUM = 1) AS NOME_TITULAR,
               BE.NUM_CPF,
               TRUNC (BE.DATA_NASCIMENTO)DATA_NASCIMENTO,
               TRUNC (MONTHS_BETWEEN (SYSDATE, BE.DATA_NASCIMENTO) / 12)IDADE,
               TRUNC (B.DATA_INCLUSAO)DATA_INCLUSAO,
               TRUNC (BC.DATA_ADESAO)DATA_ADESAO,
               TRUNC (B.DATA_EXCLUSAO)DATA_EXCLUSAO,
               DECODE(B.IND_SITUACAO,
                  'A',
                  'ATIVO',
                  'S',
                  'SUSPENSO',
                  'E',
                  'EXCLU�DO') AS SITUACAO,
               M.NOME_MOTIVO_EXC_ASSOC MOTIVO_EXCLUSAO,
                DECODE(CE.COD_OPERADORA_CONTRATO,
                  3,
                  'AMBOS',
                  DECODE(CE.IND_TIPO_PRODUTO, 1, 'MEDICO', 2, 'DENTAL')) AS TIPO_PRODUTO,
              /*DECODE((SELECT COUNT(*)
                    FROM LA_ACAO_JUD_PGTO A
                   WHERE A.COD_TS IN (B.COD_TS, B.COD_TS_TIT)
                     AND SYSDATE BETWEEN A.DT_INI_ACAO AND
                         NVL(A.DT_FIM_ACAO, to_date('31/12/3000', 'DD/MM/YYYY'))) as acao_judicial
                  0,
                  'N�O POSSUI',
                  'POSSUI') POSSUI_ACAO_JUDICIAL*/ ' ' as POSSUI_ACAO_JUDICIAL,
               PM.NOME_PLANO,
               (SELECT SUM (ITENS.VAL_ITEM_COBRANCA)
                  FROM TS.ITENS_COBRANCA  ITENS
                       JOIN TS.COBRANCA CX
                           ON CX.NUM_SEQ_COBRANCA = ITENS.NUM_SEQ_COBRANCA
                 WHERE CX.COD_TS = B.COD_TS
                       AND ITENS.VAL_ITEM_PAGAR IS NOT NULL
                       AND ITENS.COD_ADITIVO IS NULL
                       AND ITENS.NUM_SEQ_COBRANCA = C.NUM_SEQ_COBRANCA) VALOR_COM,
           /*ALL_GET_TEL_FNC(B.COD_ENTIDADE_TS_TIT, 'C') TELEFONE_CONTATO*/ ' ' as TELEFONE_CONTATO,
           /*ALL_GET_TEL_FNC(B.COD_ENTIDADE_TS_TIT, 'B') TELEFONE_COBRANCA*/ ' ' as TELEFONE_COBRANCA,
           /*ALL_GET_MAIL_FNC(B.COD_ENTIDADE_TS_TIT) EMAIL*/ ' ' as EMAIL,
              CE.DATA_INICIO_VIGENCIA,
           DECODE(PM.IND_PARTICIPACAO, '', 'N�o', 'S', 'Sim') AS COPARTICIPACAO,
               (SELECT MAX (CC.DT_PROXIMO_REAJUSTE)
                  FROM TS.CONTRATO_COBRANCA CC
                 WHERE CC.COD_TS_CONTRATO = CE.COD_TS_CONTRATO)DT_PROXIMO_REAJUSTE,
                TO_CHAR(C.DT_COMPETENCIA, 'MM/YYYY') MES_REFERENCIA,
               REXC.QTD_DIAS_ATRASO REGRA_EXCLUSAO_DIAS,
               NVL (C.DT_VENCIMENTO_ORIG, C.DT_VENCIMENTO)DT_VENCIMENTO,
               (SELECT COUNT (DISTINCT TC.NUM_SEQ_FATURA_TS)
                  FROM TS.COBRANCA TC, TS.FATURA TF
                 WHERE TC.COD_TS = NVL(B.COD_TS_TIT, B.COD_TS)
                       AND TF.NUM_SEQ_FATURA_TS = TC.NUM_SEQ_FATURA_TS
                       AND TF.DT_CANCELAMENTO IS NULL
                       AND TF.DT_BAIXA IS NULL
                       AND TF.DT_VENCIMENTO <= TRUNC (SYSDATE - 3))QTD_BOLETO_ATRASO,
              sysdate as DTH_Gerado,
              c.dt_vencimento as vencimento_prorrogado,
              C.DT_VENCIMENTO_ORIG AS VENCIMENTO_ORIGINAL,
              situacaoCob.Nome_Estado_Cobranca situacao_boleto
          FROM TS.BENEFICIARIO              B,
               TS.TIPO_DEPENDENCIA         D,
               TS.BENEFICIARIO_ENTIDADE     BE,
               TS.ESTADO_CIVIL              EC,
               TS.BENEFICIARIO_CONTRATO     BC,
               TS.PLANO_MEDICO              PM,
               TS.CONTRATO_EMPRESA          CE,
               TS.PPF_OPERADORAS            O,
               TS.OPERADORA                 ADM,
               TS.REGRA_EMPRESA             TIPO,
               TS.PPF_PROPOSTA              P,
               TS.PPF_OPERADORAS            OP,
               TS.CORRETOR_VENDA            CV,
               TS.ENTIDADE_SISTEMA          ESCORRETOR,
               TS.CORRETOR_VENDA            CVCORRETORA,
               TS.ENTIDADE_SISTEMA          ESCORRETORA,
               TS.CORRETOR_VENDA            CVSUPERVISOR,
               TS.ENTIDADE_SISTEMA          ESSUPERVISOR,
               TS.REGRA_EMPRESA             RE,
               TS.MOTIVO_EXCLUSAO_ASSOC     M,
               TS.ENTIDADE_SISTEMA          ES,
               TS.BENEFICIARIO_FATURAMENTO  BF,
--               TS.ASSOCIADO_ADITIVO@prod_allsys         AD,
               TS.BENEFICIARIO_ENDERECO     EN,
               TS.BAIRRO                    BA,
               TS.MUNICIPIO                 MU,
--               TS.ADITIVO@prod_allsys                   A,
               TS.COBRANCA                  C,
               --TS.FATURA                    F,
               --TS.TIPO_CICLO                CICLO,
               TS.SUCURSAL                  SU,
               TS.SITUACAO_INADIMPLENCIA    REXC,
               ts.situacao_cobranca        situacaoCob
         WHERE B.COD_DEPENDENCIA = D.COD_DEPENDENCIA(+)
               AND B.COD_ENTIDADE_TS = BE.COD_ENTIDADE_TS
               AND EC.IND_ESTADO_CIVIL = BE.IND_ESTADO_CIVIL(+)
               AND B.COD_TS = BC.COD_TS(+)
               AND B.COD_PLANO = PM.COD_PLANO(+)
               AND B.COD_TS_CONTRATO = CE.COD_TS_CONTRATO(+)
               AND CE.COD_OPERADORA_CONTRATO = O.COD_OPERADORA(+)
               AND B.COD_OPERADORA = ADM.COD_OPERADORA(+)
               AND CE.TIPO_EMPRESA = TIPO.TIPO_EMPRESA(+)
               AND B.NUM_SEQ_PROPOSTA_TS = P.NUM_SEQ_PROPOSTA_TS(+)
               AND CE.COD_OPERADORA_CONTRATO = OP.COD_OPERADORA
               AND P.COD_VENDEDOR_TS = CV.COD_CORRETOR_TS(+)
               AND CV.COD_ENTIDADE_TS = ESCORRETOR.COD_ENTIDADE_TS(+)
               AND P.COD_PRODUTOR_TS = CVCORRETORA.COD_CORRETOR_TS(+)
               AND CVCORRETORA.COD_ENTIDADE_TS = ESCORRETORA.COD_ENTIDADE_TS(+)
               AND P.COD_VENDEDOR_CONTATO_TS = CVSUPERVISOR.COD_CORRETOR_TS(+)
               AND CVSUPERVISOR.COD_ENTIDADE_TS =  ESSUPERVISOR.COD_ENTIDADE_TS(+)
               AND CE.TIPO_EMPRESA = RE.TIPO_EMPRESA(+)
               AND BC.COD_MOTIVO_EXCLUSAO = M.COD_MOTIVO_EXC_ASSOC(+)
               AND CE.COD_TITULAR_CONTRATO = ES.COD_ENTIDADE_TS(+)
               AND B.COD_TS_TIT = BF.COD_TS(+)
--             AND B.COD_TS = AD.COD_TS(+)
               AND B.COD_ENTIDADE_TS_TIT = EN.COD_ENTIDADE_TS(+)
               AND EN.COD_BAIRRO = BA.COD_BAIRRO(+)
               AND EN.COD_MUNICIPIO = MU.COD_MUNICIPIO(+)
               AND EN.COD_MUNICIPIO = MU.COD_MUNICIPIO(+)
--               AND AD.COD_ADITIVO = A.COD_ADITIVO(+)
--               AND A.COD_TIPO_RUBRICA(+) = 50
               AND C.COD_TS = B.COD_TS_TIT
               --AND F.NUM_SEQ_FATURA_TS = C.NUM_SEQ_FATURA_TS
               --AND CICLO. = c.num_ciclo_ts
               AND SU.COD_SUCURSAL(+) = CE.COD_SUCURSAL
               AND B.TIPO_ASSOCIADO IN ('T', 'D')
               AND CE.IND_TIPO_PRODUTO IN (1, 3)
               --AND F.DT_CANCELAMENTO IS NULL
               --AND F.DT_BAIXA IS NULL
               AND C.dt_cancelamento is null
               and c.dt_baixa is null 
               and c.dt_vencimento <= TRUNC (SYSDATE - 3)
               --AND F.DT_VENCIMENTO <= TRUNC (SYSDATE - 3)
               and situacaoCob.Ind_Estado_Cobranca = c.ind_estado_cobranca
               AND EN.NUM_SEQ_END =
           (SELECT MAX(NUM_SEQ_END)
              FROM ts.BENEFICIARIO_ENDERECO XX
             WHERE XX.COD_ENTIDADE_TS = B.COD_ENTIDADE_TS_TIT
               AND (XX.IND_RESIDENCIA = 'S' OR XX.IND_CORRESP = 'S'))
              /* AND NOT EXISTS
                       (SELECT 1
                          FROM TS.ACAO_JUD_PGTO A
                         WHERE     A.COD_TS IN (B.COD_TS, B.COD_TS_TIT)
                               AND SYSDATE BETWEEN A.DT_INI_ACAO
                                               AND NVL (A.DT_FIM_ACAO,
                                                        to_date('31/12/3000', 'DD/MM/YYYY')))*/
               --AND OP.COD_OPERADORA IN (' || cod_operadoras || ')
               --AND DECODE(B.IND_SITUACAO,'A',1,'S',2,'E',3) IN (' || cod_status || ')
               AND REXC.COD_OPERADORA(+) = CE.COD_OPERADORA_CONTRATO
               AND REXC.TIPO_EMPRESA(+) = CE.TIPO_EMPRESA
               AND REXC.IND_TIPO_REGRA(+) = 1
                AND REXC.IND_SITUACAO_ASSOCIADO(+) = 'E'
