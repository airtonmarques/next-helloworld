select b.cod_ts_tit,
       b.tipo_associado,
       b.num_associado_operadora carteirinha,
       b.nome_associado nome,
			 lpad(be.num_cpf, 11, '0') cpf,
			 es.nome_entidade entidade,
			 c.dt_competencia,
			 c.dt_vencimento,
			 case when b.tipo_associado not in ('D') then
			 (select count(1)
			  from ts.beneficiario b1
				where b1.cod_ts_tit = b.cod_ts_tit
				      and nvl(b1.data_exclusao, '31/12/3000') > trunc(sysdate))
				else 0 end as vidasAtivas,
			 
				(select count(1)
				 from ts.cobranca c1
				 where c1.cod_ts_contrato = b.cod_ts_contrato
				       and c1.cod_ts is null
				       and c1.dt_cancelamento is null
							 and c1.dt_emissao is not null
							 and c1.dt_competencia <= c.dt_competencia) parcela,
				bf.dia_vencimento diaVigencia,
				ic.val_item_cobranca valor,
				c.num_seq_cobranca numeroCobranca,
				bc.data_adesao dataAdesao,
				b.data_exclusao dataExclusao,
				op.nom_operadora operadora			 
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.beneficiario_contrato bc on bc.cod_ts = b.cod_ts
		 join ts.beneficiario_faturamento bf on bf.cod_ts = b.cod_ts_tit
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
                              		 and (b.cod_empresa is null OR ec.cod_entidade_ts = b.cod_empresa)
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
		 join ts.cobranca c on c.cod_ts_contrato = b.cod_ts_contrato 
		                    and c.cod_ts is null
     join ts.itens_cobranca ic on ic.cod_ts = b.cod_ts
		                           and ic.num_seq_cobranca = c.num_seq_cobranca
where ce.num_contrato in ('41078', '41077')   
order by 1, 2 desc
     
