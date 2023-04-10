select ROW_NUMBER() OVER(
        ORDER BY ce.num_contrato) "Nº",
       ce.num_contrato,
       es.num_cgc cnpj,
			 es.nome_entidade "nome fantasia",
			 es.nome_razao_social "razão social",
			 e.nom_logradouro || ' ' || e.num_endereco || ' cep ' || e.num_cep "endereço de cobrança",
			 (select count(1) 
			  from ts.beneficiario b
				where b.cod_ts_contrato = ce.cod_ts_contrato
				      and b.data_exclusao is null) "Nº de funcionários",
				ce.data_inicio_vigencia "data do contrato",
				cc.nom_contato "Nome do contato da empresa",
				' ' "CPF do contato da empresa",
				cc.txt_email_contato "E-mail do contato da empresa"
from ts.entidade_sistema es
     join ts.contrato_empresa ce on ce.cod_titular_contrato = es.cod_entidade_ts
		                             and ce.data_inicio_vigencia = (select min(ce1.data_inicio_vigencia)
                                                                    from ts.contrato_empresa ce1
                                                                    where ce1.cod_ts_contrato = ce.cod_ts_contrato)
     left join ts.enderecos e on e.cod_entidade_ts = es.cod_entidade_ts
		                             and e.num_seq_end = (select max(e1.num_seq_end)
                                                                    from ts.enderecos e1
                                                                    where e1.cod_entidade_ts = es.cod_entidade_ts)
		 left join ts.contrato_contato cc on cc.cod_ts_contrato = ce.cod_ts_contrato
		                                  and cc.num_seq_contato = (select max(cc1.num_seq_contato)
                                                                    from ts.contrato_contato cc1
                                                                    where cc1.cod_ts_contrato = ce.cod_ts_contrato)
where 1 = 1 
      and exists (select 1
              from ts.associado_aditivo aa
							where aa.cod_aditivo = 33
							      and aa.cod_ts_contrato = ce.cod_ts_contrato
										and aa.dt_fim_vigencia is null)
      and exists (select 1
                  from ts.contrato_campos_operadora cco
                  where cco.cod_operadora = ce.cod_operadora_contrato
                        and cco.cod_ts_contrato = ce.cod_ts_contrato
                        and cco.val_campo like 'PROJETO MORUMBI%')
group by ce.cod_ts_contrato,
         ce.num_contrato,
       es.num_cgc,
			 es.nome_entidade,
			 es.nome_razao_social,
       ce.data_inicio_vigencia,
			 cc.nom_contato,
			 cc.txt_email_contato,
			 e.nom_logradouro,
			 e.num_endereco,
			 e.num_cep
