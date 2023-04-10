update beneficiario_contrato bc
set bc.cod_situacao_esp = 1,
    bc.dt_ini_sit_esp = trunc(sysdate)
where bc.cod_ts IN (select cod_ts from ts.beneficiario where cod_ts_contrato = 44799) 


select * from beneficiario_contrato bc
where 1 = 1
      and bc.dt_ini_sit_esp is not null
      --and bc.cod_ts IN (select cod_ts from ts.beneficiario where cod_ts_contrato = 44799) 
