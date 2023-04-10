select distinct
       pm.nome_plano nomePlano,
       es.nome_entidade nomeEntidade,
			 ce.num_contrato numContrato,
			 ce.data_inicio_vigencia vigenciaContrato,
			 bf.dia_vencimento vencimentoBoleto,
			 beTit.Nome_Entidade nomeResponsavel,
			 ('(' || bc.num_ddd || ') ' || bc.num_telefone) telefone,
			 bTit.num_associado_operadora numeroCartaoTit,
			 beTit.ind_sexo sexoTit,
			 beTit.data_nascimento dataNascimentoTit,
			 ecTit.nome_estado_civil estadoCivilTit,
			 lpad(beTit.num_cpf, 11, '0') cpfTit,
			 bend.nom_logradouro endereco,
			 bend.num_endereco numero,
			 bend.txt_complemento complemento,
			 bend.nome_bairro bairro,
			 cidade.nom_municipio cidade,
			 cidade.sgl_uf uf,
			 bend.num_cep cep,
			 b.nome_associado nomeBeneficiario,
			 b.num_associado_operadora numeroCartao,
			 be.ind_sexo sexo,
			 be.data_nascimento dataNascimento,
			 ec.nome_estado_civil estadoCivil,
			 nvl(tp.nome_dependencia , 'Titular') parentesco,
			 lpad(be.num_cpf, 11, '0') cpf,
			 bTit.Data_Inclusao vigenciaBeneficiario,
			 b.cod_entidade_ts_tit 
from ts.beneficiario b
     join ts.beneficiario bTit on bTit.Cod_Ts = b.cod_ts_tit
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
		 join ts.beneficiario_entidade beTit on beTit.Cod_Entidade_Ts = b.cod_entidade_ts_tit
		 join ts.beneficiario_faturamento bf on bf.cod_ts = b.cod_ts_tit
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
		 join ts.entidade_sistema es on es.cod_entidade_ts = ce.cod_titular_contrato
		 join ts.plano_medico pm on pm.cod_plano = b.cod_plano
		 join ts.estado_civil ecTit on ecTit.ind_estado_civil = beTit.ind_estado_civil
		 join ts.estado_civil ec on ec.ind_estado_civil = be.ind_estado_civil
		 join ts.beneficiario_endereco bend on bend.cod_entidade_ts = b.cod_entidade_ts_tit
		 join ts.municipio cidade on cidade.cod_municipio = bend.cod_municipio
		 join ts.beneficiario_contato bc on bc.cod_entidade_ts = b.cod_entidade_ts_tit 
		                                    and bc.num_ddd is not null
																				and bc.num_seq_contato = (select max(bc1.num_seq_contato)
																				                          from ts.beneficiario_contato bc1
																																	where bc1.num_ddd is not null
																																	      and bc1.cod_entidade_ts = bc.cod_entidade_ts)
		 left join ts.TIPO_DEPENDENCIA tp on tp.cod_dependencia = b.cod_dependencia
WHERE b.nome_associado = 'AIRTON MARQUES DA SILVA JUNIOR'
