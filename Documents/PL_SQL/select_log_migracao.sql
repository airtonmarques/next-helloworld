select distinct l.cod_cad, msg_retorno, trunc(dth_insert) dth_insert
  from alt_mig_log_det l
 where msg_retorno like '%ERRO%'  AND NOME_JOG IN ( 'ALT_MIG_CAD_PROP_PKG.MIGRACAOFULL','ALT_MIG_CAD_PROP_PKG.MIGRACAOUNICA','ALT_MIG_CAD_PROP_PKG.IMPORTAR')
   and dth_insert > to_date('01/07/2022 10:30','dd/mm/yyyy hh24:mi:ss');
