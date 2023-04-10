delete ts.lancamento_manual
where num_lancamento_ts IN
(select lm.num_lancamento_ts
from ts.lancamento_manual lm
where lm.cod_tipo_rubrica = 250
and lm.num_item_cobranca_ts is null
and lm.dt_lancamento between to_date('15/12/2020 00:00:00', 'dd/mm/yyyy hh24:mi:ss')
                             and to_date('15/12/2020 23:59:59', 'dd/mm/yyyy hh24:mi:ss')
and lm.cod_ts IN (57997,
1007889,
28577,
1123474,
970396,
1007890,
29349,
952569,
29381,
956117))
