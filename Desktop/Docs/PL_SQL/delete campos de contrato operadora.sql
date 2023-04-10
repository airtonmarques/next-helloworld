select 'delete ts.contrato_campos_operadora where cod_ts_contrato = ' || ce.cod_ts_contrato || ' and (cod_campo = ''IND_MIGRADO'' OR cod_campo = ''NOME_MIGRACAO'');'
       --'update ts.contrato_empresa set data_inicio_vigencia = ''' || cc.dt_ini_cobranca || ''' where cod_ts_contrato = ' || ce.cod_ts_contrato || ';'
from ts.contrato_empresa ce
     --join ts.contrato_cobranca cc on cc.cod_ts_contrato = ce.cod_ts_contrato
where ce.num_contrato IN ('14686',
'31373',
'18151',
'18152',
'19112',
'19114',
'19359',
'18971',
'19042',
'19072')
   /*   and cc.dt_ini_cobranca = (select min(cc1.dt_ini_cobranca)
                                from ts.contrato_cobranca cc1
                                where cc1.cod_ts_contrato = cc.cod_ts_contrato);*/
