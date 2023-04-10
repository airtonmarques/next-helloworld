select 'update ts.beneficiario set num_seq_proposta_ts = ' ||  
       (select b2.num_seq_proposta_ts from ts.beneficiario b2 where b2.cod_ts = b.cod_ts_tit) || ' where cod_ts = ' ||
       b.cod_ts || ';'
from ts.beneficiario b
where b.tipo_associado = 'D'
      and b.num_seq_proposta_ts is null
      --and b.num_associado = 139197672
      and exists (select 1 from ts.beneficiario b1 where b1.cod_ts = b.cod_ts_tit and b1.num_seq_proposta_ts is not null)
 
