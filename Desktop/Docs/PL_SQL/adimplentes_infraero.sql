select (select bb.num_matric_empresa from ts.beneficiario bb where bb.cod_ts = b.cod_ts_tit) MATRICULA_TITULAR,
       (select substr(bb.nome_associado, 0, 100) from ts.beneficiario bb where bb.cod_ts = b.cod_ts_tit) NOME_TITULAR,
       (select lpad(bbe.num_cpf, 11, '0') from ts.beneficiario_entidade bbe where bbe.cod_entidade_ts = b.cod_entidade_ts_tit) CPF_TITULAR, 
       CASE b.tipo_associado
        WHEN 'T' THEN ''
         ELSE to_char(lpad(b.num_cco_dv, 2, '0'))
        END  COD_DEP,
       CASE b.tipo_associado
        WHEN 'T' THEN ''
         ELSE b.nome_associado
        END NOME_DEP,
       CASE b.tipo_associado
        WHEN 'T' THEN ''
         ELSE lpad(be.num_cpf, 11, '0')
        END CPF_DEP,
       to_char(c.dt_competencia, 'MM') MES,
       to_char(c.dt_competencia, 'YYYY') ANO,
       to_char(SUM(ic.val_item_cobranca), '99999999999.99') VALOR,
       '1' COD_ADMINISTRADORA
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.cobranca c on c.cod_ts = b.cod_ts_tit
     join ts.itens_cobranca ic on ic.num_seq_cobranca = c.num_seq_cobranca and ic.cod_ts = b.cod_ts
     
where ce.num_contrato in (:NUM_CONTR)
  and c.dt_baixa between to_date(:DT_BAIXA_INICIO, 'DD/MM/YYYY') and
      to_date(:DT_BAIXA_FIM, 'DD/MM/YYYY')
 and b.num_cco_dv not in (99)
group by b.cod_ts_tit, b.cod_entidade_ts_tit, b.num_cco_dv, b.nome_associado, be.num_cpf, c.dt_competencia, c.dt_baixa, b.tipo_associado       
order by c.dt_baixa, b.tipo_associado desc


--Alterar a forma do Titular
