select o.nom_operadora,
       b.cod_ts_tit,
			 b.num_seq_matric_empresa,
			 b.num_associado_operadora cartao,
			 b.nome_associado,
			 lpad(be.num_cpf, 9, '0') cpf,
			 me.nome_motivo_exc_assoc motivo_exclusao,
			 b.data_exclusao,
			 b.data_inclusao
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
		 join ts.beneficiario_contrato bc on bc.cod_ts = b.cod_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
		 join ts.ppf_operadoras o on o.cod_operadora = ce.cod_operadora_contrato
		 left join ts.motivo_exclusao_assoc me on me.cod_motivo_exc_assoc = bc.cod_motivo_exclusao
where b.data_exclusao between to_date('01/07/2022', 'dd/mm/yyyy') and last_day('01/10/2022')
      and ce.cod_operadora_contrato IN (134, 135, 230, 235)
order by 1, 2, 3
/*			select *
			from ts.ppf_operadoras o
			where upper(o.nom_operadora) like '%NATAL%'*/
