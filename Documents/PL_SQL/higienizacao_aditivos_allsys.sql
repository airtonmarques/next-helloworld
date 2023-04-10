select 'update ts.associado_aditivo set dt_fim_vigencia = ''' || b.data_exclusao || ''' where cod_ts = ' || b.cod_ts || ';'
from ts.associado_aditivo aa
     join ts.beneficiario b on b.cod_ts = aa.cod_ts
where b.data_exclusao is not null        
      and aa.dt_fim_vigencia is null 
