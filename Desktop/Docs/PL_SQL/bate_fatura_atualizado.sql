SELECT

          tipo.NOME_TIPO_EMPRESA PORTE,
          ADM.NOM_OPERADORA Administradora,
          SU.NOME_SUCURSAL FILIAL,
          MU.SGL_UF,
          DECODE(B.TIPO_ASSOCIADO, 'T', 'TITULAR', 'DEPENDENTE') TIPO_ASSOCIADO,
          DECODE(B.IND_SITUACAO, 'A', 'ATIVO','S', 'SUSPENSO', 'E', 'EXCLU�DO') AS SITUACAO,
          B.NUM_ASSOCIADO,
          B.NUM_ASSOCIADO_OPERADORA,
          TRUNC(B.DATA_INCLUSAO) DATA_INCLUSAO,
          TRUNC(BC.DATA_ADESAO) DATA_ADESAO,
          TRUNC(B.DATA_EXCLUSAO) DATA_EXCLUSAO,
          B.NOME_ASSOCIADO,
          BE.NUM_CPF,
          TRUNC(BE.DATA_NASCIMENTO) DATA_NASCIMENTO,
          TRUNC(MONTHS_BETWEEN(SYSDATE,BE.DATA_NASCIMENTO)/12) IDADE,
          OP.NOM_OPERADORA Operadora,
          PM.NOME_PLANO Plano,   
                 
         
         (SELECT B.NUM_DDD||'-'||B.NUM_TELEFONE
            FROM TS.BENEFICIARIO_CONTATO B
            WHERE B.COD_ENTIDADE_TS = B.COD_ENTIDADE_TS_TIT
            AND IND_CLASS_CONTATO = 'C'
            AND ROWNUM = 1) TELEFONE_CONTATO,  
              
         (SELECT B.NUM_DDD||'-'||B.NUM_TELEFONE
            FROM TS.BENEFICIARIO_CONTATO B
            WHERE B.COD_ENTIDADE_TS = B.COD_ENTIDADE_TS_TIT
            AND IND_TIPO_CONTATO = 'R'
            AND ROWNUM = 1) TELEFONE_REDENCIAL,  
           
         (SELECT B.NUM_DDD||'-'||B.NUM_TELEFONE
            FROM TS.BENEFICIARIO_CONTATO B
            WHERE B.COD_ENTIDADE_TS = B.COD_ENTIDADE_TS_TIT
            AND IND_TIPO_CONTATO = 'C'
            AND ROWNUM = 1)  TELEFONE_COMERCIAL,            
                       
          (SELECT B.NUM_DDD||'-'||B.NUM_TELEFONE
          FROM TS.BENEFICIARIO_CONTATO B
          WHERE B.COD_ENTIDADE_TS = B.COD_ENTIDADE_TS_TIT
          AND IND_TIPO_CONTATO = 'R'
          AND ROWNUM = 1) TELEFONE_COBRANCA,
          
          (SELECT B.END_EMAIL
           FROM TS.BENEFICIARIO_CONTATO B
           WHERE B.COD_ENTIDADE_TS = B.COD_ENTIDADE_TS_TIT
           AND IND_CLASS_CONTATO = 'E'
           AND ROWNUM = 1) EMAIL,          

          (SELECT XX.NOME_ASSOCIADO
           FROM TS.BENEFICIARIO XX
           WHERE XX.COD_TS = B.COD_TS_TIT) AS NOME_TITULAR,

          (SELECT AA.NUM_ASSOCIADO_OPERADORA
           FROM TS.ASSOCIADO_ADITIVO AA
           WHERE AA.COD_TS = B.COD_TS and AA.COD_ADITIVO <> 10
           AND ROWNUM = 1) NUM_ASSOCIADO_OPERADORA_DENTAL,

          M.NOME_MOTIVO_EXC_ASSOC MOTIVO_EXCLUSAO,

          (SELECT SUM(ITENS.VAL_ITEM_COBRANCA)
                            FROM TS.ITENS_COBRANCA ITENS
                            WHERE ITENS.COD_TS = B.COD_TS
                                  AND ITENS.VAL_ITEM_PAGAR IS NOT NULL
                                  AND (
                                      (B.TIPO_ASSOCIADO = 'T' AND ITENS.COD_TIPO_RUBRICA  IN (2,18,13))
                                      OR
                                      (B.TIPO_ASSOCIADO = 'D' AND ITENS.COD_TIPO_RUBRICA  IN (9,20,17,8,19,14))
                                       )
                                  AND ITENS.COD_ADITIVO IS NULL
                                  AND ITENS.MES_ANO_REF = TO_DATE ('01/09/2021', 'DD/MM/RRRR') ) VALOR_COM,

          (SELECT SUM(ITENS.VAL_ITEM_PAGAR)
                            FROM TS.ITENS_COBRANCA ITENS
                            WHERE ITENS.COD_TS = B.COD_TS
                                  AND (
                                      (B.TIPO_ASSOCIADO = 'T' AND ITENS.COD_TIPO_RUBRICA  IN (2,18,13))
                                      OR
                                      (B.TIPO_ASSOCIADO = 'D' AND ITENS.COD_TIPO_RUBRICA  IN (9,20,17,8,19,14))
                                       )
                                  AND ITENS.VAL_ITEM_PAGAR IS NOT NULL
                                  AND ITENS.COD_ADITIVO IS NULL
                                  AND ITENS.MES_ANO_REF = TO_DATE ('01/09/2021', 'DD/MM/RRRR') ) VALOR_NET,

          ES.NOME_ENTIDADE Nome_Entidade_De_Classe,
          CE.NUM_CONTRATO_OPERADORA,

          (SELECT TRUNC(MAX(OCO.DT_OCORRENCIA))
          FROM TS.OCORRENCIA_ASSOCIADO OCO
          WHERE OCO.COD_TS = B.COD_TS
          AND OCO.COD_OCORRENCIA IN (8, 54 /*, 185*/)) DATA_ULTIMA_SUSPENSAO,

          (SELECT MAX(TRUNC(OA.DT_OCORRENCIA))
           FROM TS.OCORRENCIA_ASSOCIADO OA
           WHERE OA.COD_TS = B.COD_TS
                 AND OA.COD_OCORRENCIA IN (186, 19)) DATA_REATIVACAO,

          (SELECT MAX( F.MES_ANO_REF)
           FROM TS.COBRANCA C
                JOIN TS.ITENS_COBRANCA I ON I.NUM_SEQ_COBRANCA = C.NUM_SEQ_COBRANCA
                JOIN TS.FATURA F ON F.NUM_SEQ_FATURA_TS = C.NUM_SEQ_FATURA_TS
           WHERE F.MES_ANO_REF =  TO_DATE ('01/09/2021', 'DD/MM/RRRR')
                 AND I.COD_TS = B.COD_TS) MES_REFERENCIA,

          DECODE((SELECT COUNT(*)
                  FROM TS.ACAO_JUD_PGTO A
                  WHERE A.COD_TS = B.COD_TS),1, 'POSSUI', 'N�O POSSUI') POSSUI_ACAO_JUDICIAL,

          (SELECT SUM(ITENS.VAL_ITEM_COBRANCA)
           FROM TS.ITENS_COBRANCA ITENS
           WHERE ITENS.COD_TS = B.COD_TS
                 AND ITENS.COD_TIPO_RUBRICA=50
                 AND ITENS.MES_ANO_REF = TO_DATE ('01/09/2021', 'DD/MM/RRRR') ) VALOR_COM_ODONTO,

          (SELECT SUM(ITENS.VAL_ITEM_PAGAR)
           FROM TS.ITENS_COBRANCA ITENS
           WHERE ITENS.COD_TS = B.COD_TS AND  ITENS.COD_TIPO_RUBRICA=50
                 AND ITENS.MES_ANO_REF = TO_DATE ('01/09/2021', 'DD/MM/RRRR') ) VALOR_NET_ODONTO,

          (SELECT TRUNC(MAX(COBRANCA.DT_BAIXA))
           FROM TS.COBRANCA COBRANCA
           WHERE COBRANCA.COD_TS = B.COD_TS_TIT
                 AND COBRANCA.DT_BAIXA IS NOT NULL ) DT_ULTIMO_PAGAMENTO,

          BF.NOME_RESP_REEMB,
          BF.NUM_CPF_RESP_REEMB,
          DECODE(PM.IND_PARTICIPACAO,'', 'N�o', 'S', 'Sim') AS COPARTICIPACAO,
          CE.NUM_CONTRATO CONTRATO_ALLCARE,
          B.COD_TS CODIGO_TS,
          B.COD_TS_TIT,
          B.COD_ENTIDADE_TS_TIT,
          B.COD_MIG_TIT FAMILIA,
          DECODE(B.IND_SITUACAO,'A','1','S','2','E','3') ORDEM_SITUACAO,
          BE.NOME_MAE,
          DECODE(BE.IND_SEXO, 'M', 'MASCULINO', 'F', 'FEMININO') SEXO,
          EC.NOME_ESTADO_CIVIL,
          BE.NUM_IDENTIDADE RG,
          P.DT_VENDA,
          DECODE(CE.COD_OPERADORA_CONTRATO, 3, 'AMBOS', DECODE(CE.IND_TIPO_PRODUTO, 1, 'MEDICO',2, 'DENTAL')) AS TIPO_PRODUTO,

          (SELECT MAX(O.DT_ENVIO_MOVIMENTO)
          FROM TS.ASSOCIADO_OPERADORA O
          WHERE O.COD_TS = B.COD_TS
                AND O.IND_TIPO_MOVIMENTO = 'E' ) DT_ENVIO_MOVIMENTO_EXCLUSAO,

     (SELECT MAX(O.DT_ENVIO_MOVIMENTO)
      FROM TS.ASSOCIADO_OPERADORA O
      WHERE O.COD_TS = B.COD_TS
        AND O.IND_TIPO_MOVIMENTO = 'N' ) DT_ENVIO_MOVIMENTO_SUSPENSAO,

        (SELECT S.NOME_SUCURSAL
        FROM TS.SUCURSAL s,
        TS.CORRETOR_VENDA sup
        WHERE SUP.COD_CORRETOR_TS = P.COD_PRODUTOR_TS
        AND S.COD_SUCURSAL = SUP.COD_SUCURSAL) FILIAL_CORRETORA,
         
      (SELECT NOME_ENTIDADE
         FROM TS.ENTIDADE_SISTEMA CE
        WHERE CE.COD_ENTIDADE_TS = B.COD_EMPRESA) EMPRESA_PARTICIPANTE

   FROM TS.BENEFICIARIO B
   JOIN TS.BENEFICIARIO_ENTIDADE BE ON B.COD_ENTIDADE_TS = BE.COD_ENTIDADE_TS
   JOIN TS.ESTADO_CIVIL EC ON EC.IND_ESTADO_CIVIL = BE.IND_ESTADO_CIVIL
   JOIN TS.BENEFICIARIO_CONTRATO BC ON BC.COD_TS = B.COD_TS
   JOIN TS.BENEFICIARIO_FATURAMENTO BF ON BF.COD_TS = B.COD_TS
   JOIN TS.PLANO_MEDICO PM ON B.COD_PLANO = PM.COD_PLANO
   JOIN TS.CONTRATO_EMPRESA CE ON CE.COD_TS_CONTRATO = B.COD_TS_CONTRATO
   join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
          and (b.cod_empresa is null OR ec.cod_entidade_ts = b.cod_empresa)
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
   JOIN TS.OPERADORA ADM ON B.COD_OPERADORA = ADM.COD_OPERADORA
   JOIN TS.REGRA_EMPRESA TIPO ON TIPO.TIPO_EMPRESA = CE.TIPO_EMPRESA
   JOIN TS.PPF_OPERADORAS OP ON OP.COD_OPERADORA = CE.COD_OPERADORA_CONTRATO
   JOIN TS.SUCURSAL SU ON SU.COD_SUCURSAL = CE.COD_SUCURSAL
   JOIN TS.MUNICIPIO MU ON MU.COD_MUNICIPIO = SU.COD_MUNICIPIO
   LEFT JOIN TS.PPF_PROPOSTA P ON P.NUM_SEQ_PROPOSTA_TS = B.NUM_SEQ_PROPOSTA_TS
   LEFT JOIN TS.MOTIVO_EXCLUSAO_ASSOC M ON BC.COD_MOTIVO_EXCLUSAO = M.COD_MOTIVO_EXC_ASSOC

   --WHERE (NOME_OPERADORA is null OR UPPER(OP.NOM_OPERADORA) LIKE '%'||trim(UPPER(NOME_OPERADORA))||'%');
