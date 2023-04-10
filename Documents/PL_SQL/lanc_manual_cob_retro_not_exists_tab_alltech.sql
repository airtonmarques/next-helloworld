select distinct
       b.num_associado,
       b.nome_associado,
       r.nom_tipo_rubrica,
       lm.dt_lancamento,
       lm.val_lancamento
from ts.lancamento_manual lm
     join ts.tipo_rubrica_cobranca r on r.cod_tipo_rubrica = lm.cod_tipo_rubrica
     join ts.beneficiario b on b.cod_ts = lm.cod_ts
where lm.cod_tipo_rubrica IN (251, 252, 253, 254, 255, 256, 257, 258, 259, 260 ,261)
      and not exists (select 1
                      from all_cob_ret_112020_cob@prod_alltech cob
                      where cob.cod_ts = lm.cod_ts)
      --and b.num_associado = 31833                                   
order by 2, 3, 4                            
                      
