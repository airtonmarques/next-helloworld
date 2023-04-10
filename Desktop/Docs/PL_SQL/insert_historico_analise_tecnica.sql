--insert into ts.mc_analise_tecnica_hist(num_seq_associado_mov, dt_historico, cod_situacao_analise, cod_usuario_analise, dt_situacao_analise, txt_obs_analise, DTH_ATUALIZACAO) values ((select distinct aa.num_seq_associado_mov from ts.mc_associado_mov aa join ts.ppf_proposta p on p.num_seq_proposta_ts = aa.num_seq_proposta_ts where p.num_proposta_adesao = '06380023283' and aa.tipo_associado = 'T'), to_date('16/09/2022 14:53:48', 'dd/mm/yyyy hh24:mi:ss'), 11, 'GENESYS', to_date('16/09/2022 14:53:48', 'dd/mm/yyyy hh24:mi:ss'), 'Contato sem sucesso', sysdate); 
------------------------------

  
delete ts.mc_analise_tecnica_hist h 
where trunc(h.dth_atualizacao) = to_date('25/10/2022', 'dd/mm/yyyy')
			and h.cod_usuario_analise = 'GENESYS'
			and exists (select 1
			            from ts.mc_analise_tecnica_hist h1
									where h1.cod_situacao_analise IN (14, 15, 16, 17)
									      and h1.num_seq_associado_mov = h.num_seq_associado_mov) 
