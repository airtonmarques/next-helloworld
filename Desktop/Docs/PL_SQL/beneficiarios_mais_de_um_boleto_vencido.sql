select op.nom_operadora,
       b.num_associado,
			 c.dt_competencia,
       b.nome_associado,
			 c.num_seq_cobranca,
			 c.dt_vencimento,
			 f.num_fatura,
			 (select trunc(max(oa1.dt_fato))
			  from ts.ocorrencia_associado oa1
				where oa1.cod_ts = b.cod_ts
							and oa1.cod_ocorrencia = 8) data_ultima_suspensao,
			(select trunc(max(oa1.dt_fato))
        from ts.ocorrencia_associado oa1
        where oa1.cod_ts = b.cod_ts
              and oa1.cod_ocorrencia = 4) data_ultima_exclusao
from ts.beneficiario b
     join ts.cobranca c on c.cod_ts = b.cod_ts
		 join ts.fatura f on f.num_seq_fatura_ts = c.num_seq_fatura_ts
		 join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
		 join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
where --b.num_associado = '141280816'
      --b.nome_associado = 'AIRTON MARQUES DA SILVA JUNIOR'
			c.dt_baixa is null
			--and b.num_associado = '141280816'
			and c.dt_cancelamento is null
      and c.dt_emissao is not null
			and c.dt_vencimento < trunc(sysdate)
			and exists (select 1
			            from ts.cobranca c1
									where c1.cod_ts = b.cod_ts
									      and c1.dt_baixa is null
												and c1.dt_cancelamento is null
												and c1.dt_emissao is not null
												and c1.dt_vencimento < trunc(sysdate)
									group by c1.cod_ts having count(1) > 1)
									
      and exists (select 1
			            from ts.ocorrencia_associado oa
									where oa.cod_ts = b.cod_ts
									      and oa.cod_ocorrencia = 8
												and trunc(oa.dt_fato) < c.dt_emissao)
order by 1, 3, 4			
