
Select 
  a.NUM_FATURA||';'||
  a.ADMINISTRADORA||';'||
  a.PORTE||';'||
  a.TIPO_ASSOCIADO||';'||
  a.NOME||';'||
  Lpad(a.CPF,11,0)||';'||
  a.VIGENCIA||';'||
  a.OPERADORA||';'||
  a.TIPO_CONTRATO||';'||
  a.COD_PLANO||';'||
  a.NOME_PLANO||';'||
  a.DATA_EXCLUSAO||';'||
  a.DEPENDENTES||';'||
  a.VALOR_MENSALIDADE||';'||
  a.VALOR_ULTIMA_COBRANCA||';'||
  a.TAXA_ADMINISTRATIVA||';'||
  a.TAXA_ASSOCIATIVA||';'||
  a.OPCIONAL_ODONTO||';'||
  a.COPARTICIPACAO||';'||
  to_char(a.DATA_OCORRENCIA,'DD/MM/YYYY HH24:Mi:SS')||';'||
  a.DT_PAGTO_ULTIMA_COBRANCA||';'||
  a.DT_COMPETENCIA||';'||
  a.COD_ANS||';'||
  a.COD_TIPO_SOLICITACAO||';'||
  a.NOM_SOLICITACAO||';'||
  a.COD_MOTIVO_EXC_ASSOC||';'||
  a.NOME_MOTIVO_EXC_ASSOC||';'||
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
From  (
 select distinct
       b.cod_entidade_ts
      ,adm.nom_operadora Administradora
      ,porte.nome_tipo_empresa Porte
      ,(select distinct (max(f2.dt_vencimento)) from ts.fatura f2 where f2.num_seq_fatura_ts = cob.num_seq_fatura_ts) dt_vencimento
      ,cob.num_seq_cobranca
      ,cob.num_ciclo_ts
      ,f.num_seq_fatura_ts
      ,(select (max(f2.num_fatura)) from ts.fatura f2 where f2.num_seq_fatura_ts = cob.num_seq_fatura_ts) num_fatura
      ,b.num_associado
      ,b.cod_ts_contrato
      ,b.cod_ts
      ,b.cod_ts_tit
      ,b.tipo_associado
      ,b.nome_associado Nome
      ,lpad(be.num_cpf, 11, 0) CPF
      ,b.data_inclusao Vigencia
      ,op.nom_operadora Operadora 
      ,case when ca.cod_aditivo is not null then 'AMBOS'
            when ca.cod_aditivo is null and pm.cod_tipo_plano = 1 then 'MEDICO'
            when ca.cod_aditivo is null and pm.cod_tipo_plano = 4 then 'MEDICO' 
         end Tipo_contrato
      ,pm.cod_plano
      ,pm.nome_plano
      ,b.data_exclusao          
      ,(select distinct (f2.val_fatura) from ts.fatura f2 where f2.num_seq_fatura_ts = cob.num_seq_fatura_ts and f2.dt_baixa is null) Valor_ultima_cobranca      
      ,(select distinct (max(f2.dt_baixa)) from ts.fatura f2 where f2.num_seq_fatura_ts = cob.num_seq_fatura_ts) Dt_pagto_ultima_cobranca      
      ,(select distinct (max(o.dt_ocorrencia)) from ts.ocorrencia_associado o where o.cod_ocorrencia = 4 and o.cod_ts = b.cod_ts)Data_ocorrencia
      ,(select replace(to_char(wm_concat(distinct t.nom_solicitacao)), ',',',') from ts.sac_registro sr
                                                   join ts.sac_tipo_solicitacao t on t.cod_tipo_solicitacao = sr.cod_tipo_solicitacao
                                                   where sr.cod_tipo_solicitacao in (12,41, 45, 46) and sr.cod_ts = b.cod_ts) wfs -- rn412    
      ,(SELECT SUM(I.VAL_ITEM_COBRANCA)FROM TS.ITENS_COBRANCA I WHERE I.COD_TIPO_RUBRICA = 50
                                                                  AND I.NUM_SEQ_COBRANCA = COB.NUM_SEQ_COBRANCA
                                                                  AND I.NUM_CICLO_TS = COB.NUM_CICLO_TS
                                                                  AND F.NUM_SEQ_FATURA_TS = COB.NUM_SEQ_FATURA_TS ) OPCIONAL_ODONTO
      ,(select max(f2.val_fatura) from ts.fatura f2 where f2.num_seq_fatura_ts = cob.num_seq_fatura_ts)  valor_mensalidade        
      ,(SELECT SUM(I.VAL_ITEM_COBRANCA) FROM TS.ITENS_COBRANCA I WHERE I.COD_TIPO_RUBRICA = 46
                                                                   AND I.NUM_SEQ_COBRANCA = COB.NUM_SEQ_COBRANCA
                                                                   AND I.NUM_CICLO_TS = COB.NUM_CICLO_TS
                                                                   AND F.NUM_SEQ_FATURA_TS = COB.NUM_SEQ_FATURA_TS ) TAXA_ADMINISTRATIVA                          
      ,(SELECT SUM(I.VAL_ITEM_COBRANCA) FROM TS.ITENS_COBRANCA I WHERE I.COD_TIPO_RUBRICA = 45
                                                                   AND I.NUM_SEQ_COBRANCA =COB.NUM_SEQ_COBRANCA
                                                                   AND I.NUM_CICLO_TS = COB.NUM_CICLO_TS
                                                                   AND F.NUM_SEQ_FATURA_TS = COB.NUM_SEQ_FATURA_TS ) TAXA_ASSOCIATIVA      
      ,(SELECT SUM(I.VAL_ITEM_COBRANCA) FROM TS.ITENS_COBRANCA I WHERE I.COD_TIPO_RUBRICA = 16
                                                                   AND I.NUM_SEQ_COBRANCA = COB.NUM_SEQ_COBRANCA
                                                                   AND I.NUM_CICLO_TS = COB.NUM_CICLO_TS
                                                                   AND F.NUM_SEQ_FATURA_TS = COB.NUM_SEQ_FATURA_TS ) COPARTICIPACAO
      ,f.dt_competencia  
       ,(SELECT TO_CHAR(WM_CONCAT(NOME_ASSOCIADO)) FROM TS.BENEFICIARIO T2 WHERE T2.TIPO_ASSOCIADO IN ('D', 'A') AND T2.COD_TS_TIT = B.COD_TS_TIT
                                                   --  AND T2.DATA_EXCLUSAO BETWEEN '01/01/2017' AND to_date(sysdate,'DD/MM/YYYY')
                             AND T2.DATA_EXCLUSAO BETWEEN TO_DATE('1/'||TO_CHAR(ADD_MONTHS(SYSDATE,- 2),'MM/YYYY'),'DD/MM/YYYY') 
                             AND TRUNC(SYSDATE)) AS DEPENDENTES  
      ,me.cod_ans
      ,(select distinct (max(sr1.cod_tipo_solicitacao)) from ts.sac_registro sr1 where SR1.COD_TS = B.COD_TS_TIT) cod_tipo_solicitacao
      ,(select distinct (max(t1.nom_solicitacao)) from ts.sac_tipo_solicitacao t1 where T.COD_TIPO_SOLICITACAO = SR.COD_TIPO_SOLICITACAO) nom_solicitacao
      ,me.cod_motivo_exc_assoc
      ,me.nome_motivo_exc_assoc
      ,e.num_cep
      ,e.nom_logradouro
      ,e.num_endereco                                          
      ,Nvl(ba.Nom_Bairro, M.Nom_Bairro) NOME_BAIRRO  
      ,Nvl(mu.nom_municipio, Mun.Nom_Municipio) NOME_CIDADE
      ,mu.sgl_uf
      ,e.txt_complemento
      ,all_get_mail_fnc(B.COD_ENTIDADE_TS_TIT) email
      ,all_get_tel_fnc(B.COD_ENTIDADE_TS_TIT, 'C') telefone  
      ,row_number() over (partition by f.cod_ts order by f.dt_vencimento desc) indice   
        FROM TS.BENEFICIARIO B
        JOIN TS.BENEFICIARIO_CONTRATO BC ON BC.COD_TS = B.COD_TS
        JOIN TS.BENEFICIARIO_ENTIDADE BE ON B.COD_ENTIDADE_TS = BE.COD_ENTIDADE_TS
        JOIN TS.CONTRATO_EMPRESA CE ON CE.COD_TS_CONTRATO = B.COD_TS_CONTRATO
        JOIN TS.PPF_OPERADORAS OP ON OP.COD_OPERADORA = CE.COD_OPERADORA_CONTRATO
        LEFT JOIN TS.PLANO_MEDICO PM ON PM.COD_PLANO = B.COD_PLANO
        LEFT JOIN TS.CONTRATO_ADITIVO CA ON CA.COD_TS_CONTRATO = CE.COD_TS_CONTRATO 
        left JOIN TS.MOTIVO_EXCLUSAO_ASSOC ME ON BC.COD_MOTIVO_EXCLUSAO = ME.COD_MOTIVO_EXC_ASSOC 
        LEFT  JOIN TS.COBRANCA COB ON COB.COD_TS = B.COD_TS
        LEFT JOIN TS.FATURA F ON COB.NUM_SEQ_FATURA_TS = F.NUM_SEQ_FATURA_TS
        JOIN TS.REGRA_EMPRESA PORTE ON CE.TIPO_EMPRESA = PORTE.TIPO_EMPRESA
        JOIN TS.OPERADORA ADM ON B.COD_OPERADORA = ADM.COD_OPERADORA
        left JOIN TS.SAC_REGISTRO SR ON SR.COD_TS = B.COD_TS_TIT
        left JOIN TS.SAC_TIPO_SOLICITACAO T ON T.COD_TIPO_SOLICITACAO = SR.COD_TIPO_SOLICITACAO
        JOIN TS.BENEFICIARIO_ENDERECO E ON E.COD_ENTIDADE_TS = B.COD_ENTIDADE_TS AND (E.IND_CORRESP = 'S' OR E.IND_RESIDENCIA = 'S' or e.ind_cobranca = 'S')
        left Join Ts_top.Bairro M On M.cod_bairro = e.cod_bairro
        left Join Ts_Top.Municipio Mun On Mun.Cod_Municipio = e.Cod_Municipio
        left join ts.municipio mu on mu.cod_municipio = e.cod_municipio
        left join ts.bairro ba on ba.cod_bairro = e.cod_bairro     
-- where (b.data_exclusao) between '01/01/2017' and to_date(sysdate,'DD/MM/YYYY')
   where b.data_exclusao between to_date('1/'||to_char(add_months(sysdate,- 2),'mm/yyyy'),'dd/mm/yyyy') and trunc(sysdate)
     and b.ind_situacao = 'E'     
     and b.tipo_associado = 'T'
   and BC.COD_MOTIVO_EXCLUSAO in (55,28,40,18,99,3,26,27,16,33,23,17,15,7,98,13,1)
--     AND ( F.DT_VENCIMENTO IS NULL OR F.DT_VENCIMENTO = ( SELECT MAX(F2.DT_VENCIMENTO) FROM TS.FATURA F2 WHERE F2.COD_TS = F.COD_TS AND F2.DT_CANCELAMENTO IS NULL))
     AND E.NUM_SEQ_END = (SELECT MAX(XE.NUM_SEQ_END) FROM TS.BENEFICIARIO_ENDERECO XE WHERE XE.COD_ENTIDADE_TS = B.COD_ENTIDADE_TS_TIT 
                                                                                  AND (XE.IND_CORRESP = 'S' OR XE.IND_RESIDENCIA = 'S' or xe.ind_cobranca = 'S'))
     and F.DT_CANCELAMENTO IS NULL
/*   
      group by
       f.num_fatura
      ,b.cod_entidade_ts
      ,adm.nom_operadora 
      ,porte.nome_tipo_empresa 
      ,f.dt_vencimento
      ,cob.num_seq_cobranca
      ,cob.num_ciclo_ts
      ,f.num_seq_fatura_ts
      ,b.num_associado
      ,b.cod_ts_contrato
      ,b.cod_ts
      ,b.cod_ts_tit
      ,b.tipo_associado
      ,b.nome_associado 
      ,be.num_cpf
      ,b.data_inclusao 
      ,op.nom_operadora  
      ,ca.cod_aditivo
      ,pm.cod_plano
      ,pm.nome_plano
      ,b.data_exclusao          
      ,me.cod_ans
      ,sr.cod_tipo_solicitacao
      ,t.nom_solicitacao
      ,me.cod_motivo_exc_assoc
      ,me.nome_motivo_exc_assoc
      ,e.num_cep
      ,e.nom_logradouro
      ,e.num_endereco                                          
      ,ba.Nom_Bairro
      ,M.Nom_Bairro   
      ,mu.nom_municipio
      ,Mun.Nom_Municipio 
      ,mu.sgl_uf
      ,e.txt_complemento
      ,pm.cod_tipo_plano
      ,f.dt_competencia
      ,cob.num_seq_fatura_ts
      ,T.COD_TIPO_SOLICITACAO
      ,B.COD_ENTIDADE_TS_TIT 
*/    
)a where a.indice = 1



