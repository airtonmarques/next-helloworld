select o.nom_operadora,
       ce.num_contrato,
			 ce.num_contrato_operadora,
			 lpad(es.num_cgc, 14, '0') cnpj,
			 es.nome_entidade,
			 es.nome_razao_social,
			 ce.data_inicio_vigencia,
			 ce.data_fim_vigencia,
			 ce.ind_situacao
from ts.contrato_empresa ce
     join ts.entidade_sistema es on es.cod_entidade_ts = ce.cod_titular_contrato
     join ts.ppf_operadoras o on o.cod_operadora = ce.cod_operadora_contrato
where o.cod_operadora in (2, 67)
      --and es.num_cgc = 4925446000188
