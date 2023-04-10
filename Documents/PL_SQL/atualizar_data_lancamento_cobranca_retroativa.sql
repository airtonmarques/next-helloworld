update all_cob_ret_112020_cob cc
set cc.dt_lanc = null
where cc.dt_lanc is not null
      and cc.cod_ts IN
      (select c.cod_ts
      from all_cob_ret_112020_cob c
           join ts.beneficiario@allsys b on b.cod_ts = c.cod_ts
      where b.data_exclusao <= to_date('16/12/2020', 'dd/mm/yyyy')
            and exists (select 1 from ts.beneficiario@allsys b2 
                  where b2.cod_ts = b.cod_ts_tit 
                        and b2.data_exclusao <= to_date('16/12/2020', 'dd/mm/yyyy')))
                         
--7154
--7153
------------------------------------------------------------------------------------------------------

update all_cob_ret_112020_cob cc
set cc.dt_lanc = sysdate
where cc.dt_lanc is null
     and cc.cod_ts IN
      (select l.cod_ts
      from ts.lancamento_manual@allsys l
      where l.cod_tipo_rubrica = 250)
                         
--------------------------------------------------------------------------------------------------
update all_cob_ret_112020_cob cc
set cc.dt_lanc = null
where cc.dt_lanc is not null
     and not exists
      (select 1
      from ts.lancamento_manual@allsys l
      where l.cod_tipo_rubrica = 250
            and l.cod_ts = cc.cod_ts)



