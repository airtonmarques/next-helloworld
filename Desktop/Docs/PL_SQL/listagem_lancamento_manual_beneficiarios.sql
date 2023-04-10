select distinct adm.nom_operadora Adm,
                op.nom_operadora Operadora,
                ciclo.nom_tipo_ciclo,
                ce.num_contrato,
                b.num_associado, 
                b.nome_associado,
                b.tipo_associado,
                cob.val_parc,
                b.data_exclusao,
                b.data_registro_exclusao,
                lm.dt_lancamento,
                lm.mes_ano_ref
from all_cob_ret_112020_cob cob
     join ts.lancamento_manual@allsys_dbl lm on lm.cod_ts = cob.cod_ts
     join ts.beneficiario@allsys_dbl b on b.cod_ts = lm.cod_ts
     join ts.operadora@allsys_dbl adm on adm.cod_operadora = b.cod_operadora
     join ts.tipo_ciclo@allsys_dbl ciclo on ciclo.cod_tipo_ciclo = lm.cod_tipo_ciclo
     join ts.contrato_empresa@allsys_dbl ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.ppf_operadoras@allsys_dbl op on op.cod_operadora = ce.cod_operadora_contrato
where b.data_exclusao is not null    
      and lm.mes_ano_ref = '01/01/2021' 
order by 1, 2, 3, 4, 6, 7 desc


