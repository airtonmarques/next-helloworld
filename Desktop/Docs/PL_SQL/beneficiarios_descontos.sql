select b.cod_ts_tit,
       b.num_associado,
       b.nome_associado,
       b.tipo_associado,
       lpad(be.num_cpf, 11, '0') CPF,
       b.data_inclusao vigencia,
       p.num_proposta_adesao,
       ce.num_contrato contrato,
       (select sys_get_vlr_cont_fe_fnc(2, ce.cod_ts_contrato, b.cod_plano, b.tipo_associado, SYS_GET_IDADE_FNC(be.data_nascimento, 
               last_day(ad.dt_ini_vigencia)), last_day(ad.dt_ini_vigencia)) from dual) as valor_comercial,
       ad.pct_desconto percentual_desconto,
       ad.val_desconto valor_desconto,
       ad.dt_ini_vigencia inicio_desconto,
       ad.dt_fim_vigencia final_desconto,
       ad.cod_usuario_inc
from ts.associado_desconto ad
     join ts.beneficiario b on b.cod_ts = ad.cod_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     left join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     left join ts.ppf_proposta p on p.num_seq_proposta_ts = b.num_seq_proposta_ts
where ad.cod_usuario_inc NOT IN ('RAFAQUESI')
      and ad.dt_registro_inc >= to_date('01/01/2021 00:00:00', 'dd/mm/yyyy hh24:mi:ss') 
order by 1, 4 desc
