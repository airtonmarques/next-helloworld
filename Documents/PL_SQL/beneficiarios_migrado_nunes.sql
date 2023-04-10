select distinct adm.nom_operadora adm,
       porte.nome_tipo_empresa porte,
       op.nom_operadora,
       ce.num_contrato,
       es.nome_entidade,
			 b.cod_ts_tit familia,
			 b.tipo_associado,
			 b.ind_situacao situacao_beneficiario,
			 b.data_inclusao,
			 b.data_exclusao,
			 b.num_associado,
			 b.nome_associado,
			 pm.nome_plano plano,
			 case when pm.cod_tipo_plano = 1 then 'Médico' else 'Dental' end as tipo_plano,
			 f.num_fatura,
			 c.dt_competencia,
			 c.dt_vencimento,
			 c.dt_baixa,
			 c.dt_cancelamento,
			 case when b.tipo_associado in ('T', 'P') then c.val_a_pagar else 0 end as val_a_pagar,
			 case when b.tipo_associado in ('T', 'P') then c.val_pago else 0 end as val_pago,
			 case when c.dt_baixa is null then 'A Pagar' else 'Pago' end as Status_cobranca
from ts.contrato_empresa ce
     join ts.entidade_sistema es on es.cod_entidade_ts = ce.cod_titular_contrato
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
		 join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
		 join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.beneficiario b on b.cod_ts_contrato = ce.cod_ts_contrato
		 --join num_associado_tmp tmp on tmp.num_associado = b.num_associado
		 join ts.plano_medico pm on pm.cod_plano = b.cod_plano
		 left join ts.cobranca c on c.cod_ts = b.cod_ts_tit
		 left join ts.fatura f on f.num_seq_fatura_ts = c.num_seq_fatura_ts
where exists (select 1
              from ts.contrato_campos_operadora cco
              where cco.cod_campo = 'NOME_MIGRACAO'
                    and cco.val_campo = 'NUNES'
										and cco.cod_ts_contrato = ce.cod_ts_contrato)
      and c.dt_emissao is not null 
			and c.dt_cancelamento is null
      and c.dt_competencia = (select min(c1.dt_competencia)
			                        from ts.cobranca c1
															where c1.cod_ts = b.cod_ts_tit)
															
      and c.dt_vencimento = (select max(c3.dt_vencimento)
                              from ts.cobranca c3
                              where c3.cod_ts = b.cod_ts_tit
                                     and c3.dt_emissao is not null
                                     and c3.dt_cancelamento is null
                                     and c3.dt_competencia = c.dt_competencia)															
    --b.nome_associado = ''															
		--and b.num_associado = '141603348'
															
															
union all
 															
select distinct adm.nom_operadora adm,
       porte.nome_tipo_empresa porte,
       op.nom_operadora,
       ce.num_contrato,
       es.nome_entidade,
       b.cod_ts_tit familia,
       b.tipo_associado,
       b.ind_situacao situacao_beneficiario,
       b.data_inclusao,
       b.data_exclusao,
       b.num_associado,
       b.nome_associado,
       pm.nome_plano plano,
       case when pm.cod_tipo_plano = 1 then 'Médico' else 'Dental' end as tipo_plano,
       f.num_fatura,
       c.dt_competencia,
       c.dt_vencimento,
       c.dt_baixa,
       c.dt_cancelamento,
       case when b.tipo_associado in ('T', 'P') then c.val_a_pagar else 0 end as val_a_pagar,
       case when b.tipo_associado in ('T', 'P') then c.val_pago else 0 end as val_pago,
       case when c.dt_baixa is null then 'A Pagar' else 'Pago' end as Status_cobranca
from ts.contrato_empresa ce
     join ts.entidade_sistema es on es.cod_entidade_ts = ce.cod_titular_contrato
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.beneficiario b on b.cod_ts_contrato = ce.cod_ts_contrato
		 --join num_associado_tmp tmp on tmp.num_associado = b.num_associado
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
     left join ts.cobranca c on c.cod_ts = b.cod_ts_tit
     left join ts.fatura f on f.num_seq_fatura_ts = c.num_seq_fatura_ts
where exists (select 1
              from ts.contrato_campos_operadora cco
              where cco.cod_campo = 'NOME_MIGRACAO'
                    and cco.val_campo = 'NUNES'
                    and cco.cod_ts_contrato = ce.cod_ts_contrato)
      and c.dt_emissao is not null
			and c.dt_cancelamento is not null
      and c.dt_competencia = (select min(c1.dt_competencia)
                              from ts.cobranca c1
                              where c1.cod_ts = b.cod_ts_tit)						
    
       and c.dt_vencimento = (select max(c3.dt_vencimento)
                              from ts.cobranca c3
                              where c3.cod_ts = b.cod_ts_tit
															       and c3.dt_emissao is not null
			                               and c3.dt_cancelamento is not null
																		 and c3.dt_competencia = c.dt_competencia)
 			and not exists (select 1 
			                from ts.cobranca c2
											where c2.cod_ts = b.cod_ts_tit
											      and c2.dt_cancelamento is null
														    and c2.dt_emissao is not null)		
		--and b.num_associado = '141603348'																													
order by 1, 2, 3, 5, 6, 7 desc
