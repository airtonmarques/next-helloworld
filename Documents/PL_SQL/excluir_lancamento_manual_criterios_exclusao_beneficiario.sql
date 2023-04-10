select * from
ts.beneficiario b
where b.num_associado = 137586337 

select * from ts.lancamento_manual lm
where lm.cod_ts = 997760

delete ts.lancamento_manual
where num_lancamento_ts IN
(select lm.num_lancamento_ts
from ts.lancamento_manual lm
     join ts.beneficiario b on b.cod_ts = lm.cod_ts
where lm.cod_tipo_rubrica = 250
and b.data_exclusao <= to_date('18/12/2020', 'dd/mm/yyyy')
and lm.num_item_cobranca_ts is null
and exists (select 1 from ts.beneficiario b2 
            where b2.cod_ts = b.cod_ts_tit 
                  and b2.data_exclusao <= to_date('18/12/2020', 'dd/mm/yyyy')))
