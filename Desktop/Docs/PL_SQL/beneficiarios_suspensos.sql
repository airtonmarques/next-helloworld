select op.nom_operadora,
       ce.num_contrato_operadora,
			 ce.cod_administradora_ope,
			 lpad(be.num_cpf, 11, '0') cpf,
			 b.nome_associado,
			 be.ind_sexo,
			 be.data_nascimento,
			 be.nome_mae,
			 ec.nome_estado_civil,
			 b.cod_mig_tit,
			 b.num_seq_matric_empresa seq,
			 b.data_inclusao,
			 b.data_suspensao,
			 ce.cod_administradora_ope cod_grupo_empresa,
			 (select lpad(be1.num_cpf, 11, '0')
			  from ts.beneficiario_entidade be1
				where be1.cod_entidade_ts = b.cod_entidade_ts_tit) num_cpf_tit,
				(select b1.nome_associado
			  from ts.beneficiario b1
				where b1.cod_ts = b.cod_ts_tit) nome_titular,
			 td.nome_dependencia,
			 
			 (select bend.num_cep
			 from ts.beneficiario_endereco bend 
			 where bend.cod_entidade_ts = b.cod_entidade_ts_tit
			       and bend.num_seq_end = (select max(bend1.num_seq_end)
						                         from ts.beneficiario_endereco bend1 
			                               where bend1.cod_entidade_ts = b.cod_entidade_ts_tit)) num_cep,
			 
			  (select bend.nom_logradouro
       from ts.beneficiario_endereco bend 
       where bend.cod_entidade_ts = b.cod_entidade_ts_tit
             and bend.num_seq_end = (select max(bend1.num_seq_end)
                                     from ts.beneficiario_endereco bend1 
                                     where bend1.cod_entidade_ts = b.cod_entidade_ts_tit)) nom_logradouro,
																		 
			 (select bend.num_endereco
       from ts.beneficiario_endereco bend 
       where bend.cod_entidade_ts = b.cod_entidade_ts_tit
             and bend.num_seq_end = (select max(bend1.num_seq_end)
                                     from ts.beneficiario_endereco bend1 
                                     where bend1.cod_entidade_ts = b.cod_entidade_ts_tit)) num_endereco,
																		 
			 (select bend.txt_complemento
       from ts.beneficiario_endereco bend 
       where bend.cod_entidade_ts = b.cod_entidade_ts_tit
             and bend.num_seq_end = (select max(bend1.num_seq_end)
                                     from ts.beneficiario_endereco bend1 
                                     where bend1.cod_entidade_ts = b.cod_entidade_ts_tit)) txt_complemento,
																		 
			 (select bend.nome_bairro
       from ts.beneficiario_endereco bend 
       where bend.cod_entidade_ts = b.cod_entidade_ts_tit
             and bend.num_seq_end = (select max(bend1.num_seq_end)
                                     from ts.beneficiario_endereco bend1 
                                     where bend1.cod_entidade_ts = b.cod_entidade_ts_tit)) nome_bairro,
																		 
			(select bend.nome_cidade
       from ts.beneficiario_endereco bend 
       where bend.cod_entidade_ts = b.cod_entidade_ts_tit
             and bend.num_seq_end = (select max(bend1.num_seq_end)
                                     from ts.beneficiario_endereco bend1 
                                     where bend1.cod_entidade_ts = b.cod_entidade_ts_tit)) nome_cidade,
																		 
			(select bend.sgl_uf
       from ts.beneficiario_endereco bend 
       where bend.cod_entidade_ts = b.cod_entidade_ts_tit
             and bend.num_seq_end = (select max(bend1.num_seq_end)
                                     from ts.beneficiario_endereco bend1 
                                     where bend1.cod_entidade_ts = b.cod_entidade_ts_tit)) sgl_uf,
			  
			 (select bc.end_email 
			 from ts.beneficiario_contato bc 
			 where bc.cod_entidade_ts = b.cod_entidade_ts_tit
			       and bc.end_email is not null
						 and bc.ind_class_contato = 'E'
						 and bc.num_seq_contato = (select max(bc1.num_seq_contato)
																			 from ts.beneficiario_contato bc1 
																			 where bc1.cod_entidade_ts = b.cod_entidade_ts_tit
																			       and bc1.end_email is not null
																						 and bc1.ind_class_contato = 'E')) end_email,
			
			(select bc.num_ddd 
       from ts.beneficiario_contato bc 
       where bc.cod_entidade_ts = b.cod_entidade_ts_tit
             and bc.num_ddd is not null
             and bc.ind_class_contato = 'C'
             and bc.num_seq_contato = (select max(bc1.num_seq_contato)
                                       from ts.beneficiario_contato bc1 
                                       where bc1.cod_entidade_ts = b.cod_entidade_ts_tit
                                             and bc1.num_ddd is not null
                                             and bc1.ind_class_contato = 'C')) num_ddd,
																						 
				(select bc.num_telefone 
       from ts.beneficiario_contato bc 
       where bc.cod_entidade_ts = b.cod_entidade_ts_tit
             and bc.num_telefone is not null
             and bc.ind_class_contato = 'C'
             and bc.num_seq_contato = (select max(bc1.num_seq_contato)
                                       from ts.beneficiario_contato bc1 
                                       where bc1.cod_entidade_ts = b.cod_entidade_ts_tit
                                             and bc1.num_telefone is not null
                                             and bc1.ind_class_contato = 'C')) num_telefone/*,
			 oa.dt_fato*/
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     --join ts.ocorrencia_associado oa on oa.cod_ts = b.cod_ts
		 join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
		 join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
		 left join ts.estado_civil ec on ec.ind_estado_civil = be.ind_estado_civil
		 left join ts.tipo_dependencia td on td.cod_dependencia = b.cod_dependencia
where --oa.cod_ocorrencia = 9 --Ocorrencia Cancelamento da Suspensao --8 suspensao de atendimento
      --and trunc(oa.dt_fato) between to_date('04/10/2022', 'dd/mm/yyyy') and to_date('24/10/2022', 'dd/mm/yyyy')
			--and op.cod_operadora IN (3, 7)
			--and b.tipo_associado = 'T'
			--and b.ind_situacao = 'S'
			be.num_cpf IN (31881678814,
54862112870,
59374672804,
49723583860,
44202618890,
9889184478,
33784548814,
29177473825,
52856749801,
42835477861)
			
order by 1, 2, 10, 11			

--select * from ts.ppf_operadoras
			
/*--05-17
select * 
from ts.tipo_ocorrencia_associado tp
order by 1	*/	 
