--select * from 

/*update ts.all_bene_inc a
set a.data_exclusao_anterior = (select max(b.data_exclusao)
                                from ts.beneficiario b
                                     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts                                
                                where be.num_cpf = to_number(a.cpf)
                                      and b.nome_associado = a.nome_associado
                                      and b.cod_ts <> a.cod_ts)
where a.lote_inclusao = '050520220900'
      and a.nome_associado = 'LUCAS CERQUEIRA LOPES'*/
      
update ts.all_bene_exc a
set a.data_inclusao_futura = (select max(b.data_inclusao)
                                from ts.beneficiario b
                                     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts                                
                                where be.num_cpf = to_number(a.cpf)
                                      and b.nome_associado = a.nome_associado
                                      and b.cod_ts <> a.cod_ts
                                      and b.data_inclusao >= a.data_inclusao)
where a.lote_inclusao = '050520220900'
      and a.nome_associado = 'LUCAS CERQUEIRA LOPES'
