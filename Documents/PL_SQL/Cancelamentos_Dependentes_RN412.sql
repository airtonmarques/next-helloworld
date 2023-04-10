
Select 
       a.COD_MOTIVO_EXCLUSAO||';'||
       a.NOME_MOTIVO_EXC_ASSOC||';'||
       a.NUM_FATURA||';'||
       a.ADMINISTRADORA||';'||
       a.PORTE||';'||
       a.TIPO_ASSOCIADO||';'||
       a.NOME_ASSOCIADO_EXCLUIDO||';'||
       a.TITULAR||';'||
       a.NUM_CPF||';'||
       a.VIGENCIA||';'||
       a.DATA_EXCLUSAO||';'||
       a.OPERADORA||';'||
       a.TIPO_CONTRATO||';'||     
       a.COD_PLANO||';'||
       a.NOME_PLANO||';'||
       a.VALOR_MENSALIDADE_DEPENDENTE||';'||
       a.OPCIONAL_ODONTO||';'||
       a.VALOR_ULTIMA_COBRANCA||';'||       
       a.DATA_OCORRENCIA||';'||
       a.DT_PAGTO_ULTIMA_COBRANCA||';'||
       a.DT_COMPETENCIA||';'||
       a.WFS||';'||
       a.NUM_CEP||';'||
       a.NOM_LOGRADOURO||';'||
       a.NUM_ENDERECO||';'||
       a.NOME_BAIRRO||';'||
       a.NOME_CIDADE||';'||
       a.SGL_UF||';'||
       a.TXT_COMPLEMENTO||';'||
       a.EMAIL||';'||
       a.TELEFONE
From
(SELECT COD_MOTIVO_EXCLUSAO,
       NOME_MOTIVO_EXC_ASSOC,
       NUM_FATURA,
       ADMINISTRADORA,
       PORTE,
       TIPO_ASSOCIADO,
       TO_CHAR(wm_concat(NOME_ASSOCIADO_EXCLUIDO)) NOME_ASSOCIADO_EXCLUIDO,
       TITULAR,
       TO_CHAR(wm_concat(lPad(NUM_CPF,11,0))) NUM_CPF,
       VIGENCIA,
       DATA_EXCLUSAO,
       OPERADORA,       
       TIPO_CONTRATO,       
       COD_PLANO,
       NOME_PLANO,
       SUM(VALOR_MENSALIDADE_DEPENDENTE) VALOR_MENSALIDADE_DEPENDENTE,       
       OPCIONAL_ODONTO,       
       SUM(VALOR_ULTIMA_COBRANCA) VALOR_ULTIMA_COBRANCA,       
       to_char(DATA_OCORRENCIA,'DD/MM/YYYY HH24:Mi:SS') DATA_OCORRENCIA,
       DT_PAGTO_ULTIMA_COBRANCA,
       DT_COMPETENCIA,
       WFS,
       NUM_CEP, 
       NOM_LOGRADOURO,
       NUM_ENDERECO, 
       NOME_BAIRRO, 
       NOME_CIDADE, 
       SGL_UF, 
       TXT_COMPLEMENTO,
       EMAIL,
       TELEFONE 
  FROM (SELECT DISTINCT BEC.COD_MOTIVO_EXCLUSAO,
                        MOTIVO.NOME_MOTIVO_EXC_ASSOC,
                        F.NUM_FATURA,
                        ADM.NOM_OPERADORA AS ADMINISTRADORA,
                        PORTE.NOME_TIPO_EMPRESA PORTE,
                        B.TIPO_ASSOCIADO,
                        B.NOME_ASSOCIADO NOME_ASSOCIADO_EXCLUIDO,
                        (SELECT BX.NOME_ASSOCIADO
                           FROM TS.BENEFICIARIO BX
                          WHERE BX.COD_TS = B.COD_TS_TIT) AS TITULAR,
                        BE.NUM_CPF,
                        B.DATA_INCLUSAO AS VIGENCIA,
                        B.DATA_EXCLUSAO,
                        OPER.NOM_OPERADORA AS OPERADORA,   
                        CASE
                          WHEN CA.COD_ADITIVO IS NOT NULL THEN
                           'AMBOS'
                          WHEN CA.COD_ADITIVO IS NULL AND
                               PM.COD_TIPO_PLANO = 1 THEN
                           'MEDICO'
                          WHEN CA.COD_ADITIVO IS NULL AND
                               PM.COD_TIPO_PLANO = 4 THEN
                           'MEDICO'
                        END AS TIPO_CONTRATO,
                        PM.COD_PLANO,
                        PM.NOME_PLANO,
                        I.VAL_ITEM_COBRANCA VALOR_MENSALIDADE_DEPENDENTE, 
                        (SELECT SUM(ITENS.VAL_ITEM_COBRANCA)
                           FROM TS.ITENS_COBRANCA ITENS
                          WHERE ITENS.COD_TIPO_RUBRICA = 50
                            AND ITENS.NUM_SEQ_COBRANCA = C.NUM_SEQ_COBRANCA
                            AND ITENS.NUM_CICLO_TS = C.NUM_CICLO_TS
                            AND ITENS.COD_TS = B.COD_TS
                            AND F.NUM_SEQ_FATURA_TS = C.NUM_SEQ_FATURA_TS) OPCIONAL_ODONTO,
                        I.VAL_ITEM_COBRANCA VALOR_ULTIMA_COBRANCA,
                        (SELECT TRUNC(MAX(O.DT_OCORRENCIA))
                           FROM TS.OCORRENCIA_ASSOCIADO O
                          WHERE O.COD_OCORRENCIA = 4
                            AND O.COD_TS = B.COD_TS) AS DATA_OCORRENCIA, -- DATA OCORRÊNCIA    
                        F.DT_BAIXA       AS DT_PAGTO_ULTIMA_COBRANCA,
                        C.DT_COMPETENCIA,
                        (SELECT REPLACE(TO_CHAR(wm_concat(DISTINCT
                                                          T.NOM_SOLICITACAO)),
                                        ',',
                                        ',')
                           FROM TS.SAC_REGISTRO SR
                           JOIN TS.SAC_TIPO_SOLICITACAO T
                             ON T.COD_TIPO_SOLICITACAO =
                                SR.COD_TIPO_SOLICITACAO
                          WHERE SR.COD_TIPO_SOLICITACAO IN (12, 41, 45, 46)
                            AND SR.COD_TS = B.COD_TS_TIT) WFS, -- RN412,
                   E.NUM_CEP, 
       E.NOM_LOGRADOURO,
                   E.NUM_ENDERECO, 
             Nvl(e.Nome_Bairro,M.Nom_Bairro) NOME_BAIRRO,  
                   Nvl(E.NOME_CIDADE,Mun.Nom_Municipio) NOME_CIDADE,
                   E.SGL_UF, 
                   E.TXT_COMPLEMENTO,
                   all_get_mail_fnc(B.COD_ENTIDADE_TS_TIT) email,
                   all_get_tel_fnc(B.COD_ENTIDADE_TS_TIT, 'C') telefone   
          FROM TS.BENEFICIARIO B
         INNER JOIN TS.BENEFICIARIO_ENTIDADE BE
            ON BE.COD_ENTIDADE_TS = B.COD_ENTIDADE_TS
          LEFT JOIN TS.COBRANCA C
            ON B.COD_TS_TIT = C.COD_TS
          LEFT JOIN TS.ITENS_COBRANCA I
            ON I.COD_TS = B.COD_TS
           AND I.NUM_SEQ_COBRANCA = C.NUM_SEQ_COBRANCA
          LEFT JOIN TS.FATURA F
            ON C.NUM_SEQ_FATURA_TS = F.NUM_SEQ_FATURA_TS
          LEFT JOIN TS.BENEFICIARIO_CONTRATO BEC
            ON BEC.COD_TS = B.COD_TS
          LEFT JOIN TS.MOTIVO_EXCLUSAO_ASSOC MOTIVO
            ON BEC.COD_MOTIVO_EXCLUSAO = MOTIVO.COD_MOTIVO_EXC_ASSOC
          LEFT JOIN TS.OPERADORA ADM
            ON B.COD_OPERADORA = ADM.COD_OPERADORA
          LEFT JOIN TS.CONTRATO_EMPRESA CE
            ON CE.COD_TS_CONTRATO = B.COD_TS_CONTRATO
          LEFT JOIN TS.REGRA_EMPRESA PORTE
            ON CE.TIPO_EMPRESA = PORTE.TIPO_EMPRESA
          LEFT JOIN TS.PPF_OPERADORAS OPER
            ON OPER.COD_OPERADORA = CE.COD_OPERADORA_CONTRATO
          LEFT JOIN TS.CONTRATO_ADITIVO CA
            ON CA.COD_TS_CONTRATO = CE.COD_TS_CONTRATO
          LEFT JOIN TS.PLANO_MEDICO PM
            ON PM.COD_PLANO = B.COD_PLANO
          LEFT JOIN TS.BENEFICIARIO_ENDERECO E ON E.COD_ENTIDADE_TS = B.COD_ENTIDADE_TS_TIT AND (E.IND_CORRESP = 'S' OR E.IND_RESIDENCIA = 'S')  
          LEFT Join Ts_top.Bairro M On M.cod_bairro = e.cod_bairro
          LEFT Join Ts_Top.Municipio Mun On Mun.Cod_Municipio = e.Cod_Municipio 
         WHERE B.TIPO_ASSOCIADO = 'D'
--         AND TRUNC(B.DATA_EXCLUSAO) BETWEEN '10/05/2017' AND to_date(sysdate,'DD/MM/YYYY')
           AND B.DATA_EXCLUSAO BETWEEN TO_DATE('1/'||TO_CHAR(ADD_MONTHS(SYSDATE,- 2),'MM/YYYY'),'DD/MM/YYYY') AND TRUNC(SYSDATE)
       AND BEC.COD_MOTIVO_EXCLUSAO IN (55,28,40,18,99,3,26,27,16,33,23,17,15,7,98,13,1)
           AND I.COD_TIPO_RUBRICA = 19
           AND E.NUM_SEQ_END = (SELECT MAX(XE.NUM_SEQ_END) FROM TS.BENEFICIARIO_ENDERECO XE WHERE XE.COD_ENTIDADE_TS = B.COD_ENTIDADE_TS_TIT AND (E.IND_CORRESP = 'S' OR E.IND_RESIDENCIA = 'S'))
           AND I.NUM_ITEM_COBRANCA_TS =
               (SELECT MAX(IX.NUM_ITEM_COBRANCA_TS)
                  FROM TS.ITENS_COBRANCA IX
                 WHERE IX.COD_TS = B.COD_TS AND IX.COD_TIPO_RUBRICA = 19)
          AND EXISTS (SELECT 1
                  FROM TS.BENEFICIARIO BX
                 WHERE BX.COD_TS = B.COD_TS_TIT
                   AND BX.DATA_EXCLUSAO IS NULL)
        )
GROUP BY  
COD_MOTIVO_EXCLUSAO,
       NOME_MOTIVO_EXC_ASSOC,
       NUM_FATURA,
       ADMINISTRADORA,
       PORTE,
       TIPO_ASSOCIADO,
       TITULAR,
       VIGENCIA,
       DATA_EXCLUSAO,
       OPERADORA,       
       TIPO_CONTRATO,       
       COD_PLANO,
       NOME_PLANO,
       OPCIONAL_ODONTO,       
       DATA_OCORRENCIA,
       DT_PAGTO_ULTIMA_COBRANCA,
       DT_COMPETENCIA,
       WFS,
       NUM_CEP, NOM_LOGRADOURO,NUM_ENDERECO, NOME_BAIRRO, NOME_CIDADE, SGL_UF, TXT_COMPLEMENTO, EMAIL, TELEFONE 
) a



