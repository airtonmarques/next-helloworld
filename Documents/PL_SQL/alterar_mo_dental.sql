select a.*
from ts.associado_aditivo ad
     join ts.aditivo a on a.cod_aditivo = ad.cod_aditivo
where a.cod_tipo_rubrica = 50     
      and ad.dt_ini_vigencia = (select max(ad1.dt_ini_vigencia) from ts.associado_aditivo ad1 where ad1.cod_ts = ad.cod_ts and ad1.cod_aditivo = ad.cod_aditivo)
