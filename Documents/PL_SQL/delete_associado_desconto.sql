delete ts.associado_desconto ad
where ad.cod_usuario_inc = 'RAFAQUESI' 
      and ad.cod_ts IN (select cod_ts 
                        from ts.beneficiario b 
                             join ts.ppf_proposta p on p.num_seq_proposta_ts = b.num_seq_proposta_ts
                             where p.num_proposta_adesao IN (13480008325, 13480007821))
