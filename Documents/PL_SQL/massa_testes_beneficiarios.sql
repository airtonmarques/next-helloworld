select distinct b.cod_ts id_allsys,
       lpad(be.num_cpf, 11, '0') cpf,
       b.nome_associado,
       b.ind_situacao situacao_beneficiario,
       b.data_exclusao,
       (select count(1)
        from ts.cobranca c
        where c.cod_ts = b.cod_ts
              and c.dt_baixa is null
              and c.dt_vencimento <= (sysdate-10)) boletos_vencidos_10_dias,
       (select count(1)
        from ts.cobranca c
        where c.cod_ts = b.cod_ts
              and c.dt_baixa is null
              and c.dt_vencimento between (sysdate-10) and sysdate) boletos_vencidos_menos_10_dias,
       (select count(1)
        from ts.beneficiario b1
        where b1.tipo_associado = 'D'
              and b1.cod_ts_tit = b.cod_ts) numero_dependentes,
      nvl((select bf.ind_efaturamento
       from ts.beneficiario_faturamento bf
       where bf.cod_ts = b.cod_ts), 'N') boleto_sustentavel,

     (select count(1)
      from ts.beneficiario b1
           join ts.beneficiario_entidade be1 on be1.cod_entidade_ts = b1.cod_entidade_ts
      where be1.num_cpf = be.num_cpf
            and b1.data_exclusao is null) contratos_ativos,
     
		 (select count(1)
      from ts.beneficiario b1
           join ts.beneficiario_entidade be1 on be1.cod_entidade_ts = b1.cod_entidade_ts
      where be1.num_cpf = be.num_cpf
            and b1.data_exclusao is not null) contratos_inativos,
     
		  (select max(cc.dt_ini_cobranca)
       from ts.contrato_cobranca cc
       where cc.cod_ts_contrato = b.cod_ts_contrato) ultimo_reajuste,
       
			(select count(1)
			 from ts.itens_cobranca ic
			 where ic.cod_ts = b.cod_ts
			       and ic.cod_tipo_rubrica IN (16, 100)
						 and ic.mes_ano_ref >= to_date('01/01/2022', 'dd/mm/yyyy')) copart,		
	                      
       (select count(1)
			  from ts.mensagens_fatura mf
				     join ts.fatura f on f.num_seq_fatura_ts = mf.num_seq_fatura_ts
			  where lower(mf.txt_descricao) like '%faixa%etária%'
				      and mf.ind_tipo_mensagem = 'M'
							and f.dt_competencia between to_date('01/01/2021', 'dd/mm/yyyy') and last_day('01/05/2022')
							and f.dt_emissao is not null
							and f.dt_cancelamento is null
							and mf.cod_ts = b.cod_ts) reajuste_faixa,
															 
        be.data_nascimento,
				sys_get_idade_fnc(be.data_nascimento, sysdate) idade
																			               
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
		 join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
where b.tipo_associado IN ('T')
      and b.data_exclusao is null
			and exists (select 1
			            from alt_cont2@desenv_alltech         co,
                                     alt_cad2@desenv_alltech          ca,
                                     alt_cont_prod_ben@desenv_alltech pb
                               where pb.id_cad = ca.id_cad
                                 and co.id_cont = pb.id_cont
                                 and co.id_tipo_cont in (2, 4)
                                 and ca.num_cpf_cnpj = be.num_cpf)
			
			and ce.ind_tipo_produto = 2

			
/*and b.cod_ts_contrato IN (select ce.cod_ts_contrato
                                from ts.contrato_empresa ce 
                                where ce.num_contrato IN (
			38408,
38409,
38410,
39093,
39094,
39095))*/

/*			and b.cod_ts_contrato NOT IN (select ce.cod_ts_contrato
			                          from ts.contrato_empresa ce 
																where ce.num_contrato IN (34944,
34945,
34946,
36470,
36472,
36473,
36474))*/
			--and b.nome_associado = 'ADILSON ANTUNES DA SILVA'
order by 3


