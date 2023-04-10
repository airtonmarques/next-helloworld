--ADM/Operadora; n� fatura/ n� cobran�a / data cancelamento / retorno do banco


select distinct 
       o.nom_operadora Adm,
       op.nom_operadora,
       f.num_fatura,
       c.num_seq_cobranca,
       f.dt_cancelamento,
       f.txt_motivo_cancelamento,
       cob.txt_retorno--, cob.*
from ts.fatura f
     join ts.operadora o on o.cod_operadora = f.cod_operadora
     join ts.cobranca c on c.num_seq_fatura_ts = f.num_seq_fatura_ts
     join ts.controle_cobranca_reg cob on cob.num_seq_cobranca = c.num_seq_cobranca
     join ts.contrato_empresa ce on ce.cod_ts_contrato = f.cod_ts_contrato
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
where f.dt_cancelamento >= to_date('25/08/2020','dd/mm/yyyy')
      and (cob.dt_retorno is null OR cob.dt_retorno = (select max(dt_retorno) from ts.controle_cobranca_reg where num_seq_cobranca = c.num_seq_cobranca))
      --and f.num_fatura = 5940318
order by 1, 2, 5
