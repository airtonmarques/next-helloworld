select distinct op.nom_operadora,
       es.nome_entidade,
			 ce.num_contrato,
			 b.cod_ts_tit,
			 b.tipo_associado,
       b.num_associado,
       b.nome_associado,
			 c.num_seq_cobranca,
			 f.num_fatura,
			 c.dt_competencia,
			 c.dt_emissao,
			 c.dt_cancelamento,
			 c.dt_geracao,
			 f.val_fatura,
			 f.txt_motivo_cancelamento,
			 f.cod_usuario_cancelamento canc_fat,
			 case when c.dt_cancelamento is not null
				 then 'CANCELAMENTO' else 'REFATURAMENTO' end as evento
from ts.cobranca c
     join ts.beneficiario b on b.cod_ts = c.cod_ts
		 join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
		 join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
		                                and (b.cod_empresa is null or b.cod_empresa = ec.cod_entidade_ts)
		 join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
		 join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
		 join ts.fatura f on f.num_seq_fatura_ts = c.num_seq_fatura_ts
where c.dt_competencia between to_date('01/01/2022', 'dd/mm/yyyy') and last_day('01/10/2022')
      and (c.dt_cancelamento is not null OR exists (select 1
                                                    from ts.cobranca c1
                                                    where c1.cod_ts = c.cod_ts 
																										      and c1.num_seq_cobranca <> c.num_seq_cobranca
                                                          and c1.dt_competencia = c.dt_competencia
                                                          and c1.dt_cancelamento is not null
                                                          and c1.dt_emissao is not null))
			and c.dt_emissao is not null
			--and b.nome_associado = 'CAROLINE BRASILIENSE ZANINI'
order by 1, 2, 3 ,4 ,5 desc
