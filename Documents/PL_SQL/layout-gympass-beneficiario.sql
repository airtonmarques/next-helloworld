

select ROW_NUMBER() OVER(
        ORDER BY ce.num_contrato, b.cod_ts_tit, b.num_seq_matric_empresa) "Nº",
       ce.num_contrato,
			 b.cod_ts_tit,
			 b.num_seq_matric_empresa,
       b.num_matric_empresa "matrícula",
       b.nome_associado "nome completo",
       lower(bc.end_email) "e-mail",
			 lpad(be.num_cpf, 11, '0') cpf,
			 be.data_nascimento "data de nascimento",
			 bc2.num_ddd || bc2.num_telefone "celular",
			 bend.num_cep cep,
			 lpad(es.num_cgc, 14, '0') "número do cnpj",
			 ' ' "Departamento 1",
			 ' ' "Departamento 2",
			 ' ' "Departamento 3",
			 ' ' "Departamento 4",
			 'NÃO' "Desconto em Folha (Sim/Não)"
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
		 join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
		                             and ce.data_inicio_vigencia = (select min(ce1.data_inicio_vigencia)
                                                                    from ts.contrato_empresa ce1
                                                                    where ce1.cod_ts_contrato = ce.cod_ts_contrato)
		 join ts.entidade_sistema es on es.cod_entidade_ts = ce.cod_titular_contrato
     join ts.associado_aditivo aa on aa.cod_ts = b.cod_ts
		                              and aa.cod_aditivo = 33
																	and aa.dt_fim_vigencia is null
		 left join ts.beneficiario_contato bc on bc.cod_entidade_ts = b.cod_entidade_ts_tit
		                                      and bc.end_email is not null
																					and bc.num_seq_contato = (select max(bc1.num_seq_contato)
																					                          from ts.beneficiario_contato bc1
																																		where bc1.cod_entidade_ts = b.cod_entidade_ts_tit
																																		      and bc1.end_email is not null)
																																					
     left join ts.beneficiario_contato bc2 on bc2.cod_entidade_ts = b.cod_entidade_ts_tit
                                          and bc2.num_ddd is not null
                                          and bc2.num_seq_contato = (select max(bc3.num_seq_contato)
                                                                    from ts.beneficiario_contato bc3
                                                                    where bc3.cod_entidade_ts = b.cod_entidade_ts_tit
                                                                          and bc3.num_ddd is not null)
		left join ts.beneficiario_endereco bend on bend.cod_entidade_ts = b.cod_entidade_ts_tit
		                                        and bend.num_seq_end = (select max(bend1.num_seq_end)
																						                        from ts.beneficiario_endereco bend1
																																		where bend1.cod_entidade_ts = b.cod_entidade_ts_tit) 
where 1 = 1
      and b.data_exclusao is null
      and exists (select 1
			            from ts.contrato_campos_operadora cco
									where cco.cod_operadora = ce.cod_operadora_contrato
									      and cco.cod_ts_contrato = ce.cod_ts_contrato
												and cco.val_campo like 'PROJETO MORUMBI%')
group by ce.num_contrato,
       b.cod_ts_tit,
       b.num_seq_matric_empresa,
       b.num_matric_empresa,
       b.nome_associado,
       bc.end_email,
       be.num_cpf,
       be.data_nascimento,
       bc2.num_ddd,
			 bc2.num_telefone,
       bend.num_cep,
       es.num_cgc												
--order by 1, 2, 3
