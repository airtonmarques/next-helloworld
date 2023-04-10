select distinct b.cod_ts_tit,
       b.num_associado,
       b.nome_associado,
       b.tipo_associado,
       b.data_inclusao,
       b.data_exclusao,
       b.ind_situacao
from ts.beneficiario b
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.beneficiario b1 on trim(b1.nome_associado) = trim(b.nome_associado)
                             and b1.data_inclusao >= to_date('01/10/2021', 'dd/mm/yyyy')
where ce.Cod_Operadora_Contrato = 73
      and b.data_exclusao is not null
      and exists (select 1
                  from ts.lancamento_manual lm
                  where lm.num_item_cobranca_ts is null
                        and lm.cod_tipo_rubrica >= 250
                        and lm.cod_ts IN (b.cod_ts))
      and not exists (select 1
                     from ts.lancamento_manual lm
                     where lm.cod_tipo_rubrica >= 250
                           and lm.cod_ts IN (b1.cod_ts))
order by 1, 4 desc                           
