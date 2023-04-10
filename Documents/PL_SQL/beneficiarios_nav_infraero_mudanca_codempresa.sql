select b.cod_empresa,
       b.nome_associado,
       'update ts.beneficiario_empresa be set be.cod_empresa = (select b1.cod_empresa from ts.beneficiario b1 where b1.cod_ts = ' || b.cod_ts_tit || ') where be.cod_ts = ' || b.cod_ts || ';', 
       b.tipo_associado,
       'update ts.beneficiario b set b.cod_empresa = (select b1.cod_empresa from ts.beneficiario b1 where b1.cod_ts = ' || b.cod_ts_tit || ') where b.cod_ts = ' || b.cod_ts || ';' 
from ts.beneficiario b
     join ts.beneficiario_empresa be on be.cod_ts = b.cod_ts
where b.cod_empresa not in (select b1.cod_empresa 
                            from ts.beneficiario b1 where b1.cod_ts = b.cod_ts_tit)
      --and b.cod_ts_tit = 1109228
      
order by 3 desc
