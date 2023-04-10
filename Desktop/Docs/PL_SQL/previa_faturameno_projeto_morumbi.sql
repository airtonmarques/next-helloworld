select distinct       c.num_seq_cobranca,      
       b.num_seq_matric_empresa,     
			   adm.nom_operadora administradora,            
				  es.nome_entidade entidade,       
					ce.num_contrato contrato,      
					 ce.num_contrato_operadora contrato_operadora,       
					 b.cod_plano codigo_plano_medico,       
					 lpad(be.num_cpf, 11, '0') CPF,       
					 be.data_nascimento data_nascimento,       
					 b.num_associado_operadora mo_medico,       
					 be.nome_entidade nome_beneficiario,       
					 pm.nome_plano nome_plano_medico,      
					  b.num_associado numero_beneficiario,       
						op.nom_operadora Operadora,       
						b.tipo_associado tipo_beneficiario,       
						rubrica.cod_tipo_rubrica codigo_rubrica,       
						rubrica.nom_tipo_rubrica nome_rubrica,       
						ic.val_item_cobranca valor_comercial,       
						ic.val_item_pagar valor_net,      
						 b.data_inclusao Vigencia,      
						  b.cod_ts_tit codigo_familia_allsys,       
							b.cod_ts codigo_unico_beneficiario,
							tf.nom_tipo_fat,
							c.dt_emissao,
							c.dt_geracao,
							f.num_fatura,
							c.num_seq_cobranca,
							ccc.nom_arq_gerado,
							ccc.dt_geracao,
							ccc.usuario_geracao   
from ts.cobranca c
     join ts.fatura f on f.num_seq_fatura_ts = c.num_seq_fatura_ts
     join ts.itens_cobranca ic on ic.num_seq_cobranca = c.num_seq_cobranca and ic.num_ciclo_ts = c.num_ciclo_ts
     --join ts.fatura f on f.num_seq_fatura_ts = c.num_seq_fatura_ts     
		 --join ts.situacao_fatura sf on sf.ind_situacao_fatura = f.ind_situacao      
		 join ts.tipo_rubrica_cobranca rubrica on rubrica.cod_tipo_rubrica = ic.cod_tipo_rubrica
     join ts.beneficiario b on b.cod_ts = ic.cod_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
		  join ts.tipo_faturamento tf on tf.cod_tipo_fat = ce.cod_tipo_fat
     join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
          and (b.cod_empresa is null OR ec.cod_entidade_ts = b.cod_empresa)     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
		 left join ts.controle_cobranca_reg reg on reg.num_seq_cobranca = c.num_seq_cobranca
		 left join ts.controle_cobranca ccc on ccc.num_seq_controle_cob = reg.num_seq_controle_cob
where 1 = 1
      and exists (select 1 from ts.contrato_campos_operadora cco
                  where cco.cod_ts_contrato = ce.cod_ts_contrato
                        and cco.cod_campo = 'NOME_MIGRACAO'
												and cco.val_campo = 'PROJETO MORUMBI')
      and c.dt_cancelamento is null
			and c.dt_emissao is null
			and b.data_inclusao >= to_date('01/04/2023', 'dd/mm/yyyy')
			--and upper(op.nom_operadora) like '%BRADESCO%'
