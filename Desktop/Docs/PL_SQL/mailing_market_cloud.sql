/*select distinct b.nome_associado,
       lpad(be.num_cpf, 11, '0') cpf,
       c.dt_competencia competencia,
			 f.num_fatura fatura,
			 c.val_a_pagar valorBoleto,
			 c.dt_vencimento vencimento,
			 (trunc(sysdate) - c.dt_vencimento) diasAtraso,
			 bc.end_email email
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.beneficiario_contato bc on bc.cod_entidade_ts = b.cod_entidade_ts
		                                 and bc.end_email is not null
		join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
		join ts.cobranca c on c.cod_ts = b.cod_ts
		join ts.fatura f on f.num_seq_fatura_ts = c.num_seq_fatura_ts
where c.dt_baixa is null
      and c.dt_cancelamento is null
			and c.dt_emissao is not null
			and c.dt_vencimento < trunc(sysdate)
			and exists (select 1
			            from ts.contrato_campos_operadora cco
									where cco.cod_operadora = ce.cod_operadora_contrato
									      and cco.cod_ts_contrato = ce.cod_ts_contrato
												and cco.cod_campo = 'NOME_PROJETO'
												and cco.val_campo = 'SISDF - SOLUTIONS')
order by 3, 1*/
-----------------------------------------------------------------------------------------------------
select distinct b.nome_associado,
       lpad(be.num_cpf, 11, '0') cpf,
       b.cod_ts,
			 op.nom_operadora operadora,
			 es.nome_entidade entidade,
			 adm.nom_operadora adm,
			 porte.nome_tipo_empresa porte,
       lower(bc.end_email) email,
			 trunc(months_between(sysdate,be.data_nascimento)/12) idade
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.beneficiario_contato bc on bc.cod_entidade_ts = b.cod_entidade_ts
                                     and bc.end_email is not null
		join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
		join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
		join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
		join ts.entidade_sistema es on es.cod_entidade_ts = ce.cod_titular_contrato
		join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
where 1 = 1 
      and b.ind_situacao IN ('A', 'S')
			and b.tipo_associado in ('T', 'P')
			and porte.tipo_empresa in (1, 7, 10)
			and trunc(months_between(sysdate,be.data_nascimento)/12) > 15
order by 6, 7, 4, 5, 1
