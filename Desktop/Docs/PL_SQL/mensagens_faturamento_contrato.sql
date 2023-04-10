--ind_abater_desc_fatura

--select table_name from all_tab_columns where column_name = 'IND_ABATER_DESC_FATURA';


select distinct
       mf.num_mensagem_faturamento_ts,
       es.nome_entidade,
       ciclo.nom_tipo_ciclo,
       mf.mes_ano_ref,
       mf.mes_ano_ref_final,
       mf.mes_aniversario_contrato,
       mf.cod_grupo_empresa,
       mf.txt_mensagem,
       mf.txt_linha_1,
       mf.txt_linha_2,
       mf.txt_linha_3,
       mf.txt_linha_4,
       mf.txt_linha_5
from ts.mensagem_faturamento mf
     left join ts.tipo_ciclo ciclo on ciclo.cod_tipo_ciclo = mf.cod_tipo_ciclo
     left join ts.empresa_contrato ec on ec.cod_ts_contrato = mf.cod_ts_contrato
     left join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
where mf.cod_grupo_empresa is not null     
order by 2     
