select adm.nom_operadora adm,
       porte.nome_tipo_empresa porte,
			 op.nom_operadora operadora,
			 ce.num_contrato,
			 es.nome_entidade,
			 b.cod_ts_tit familia,
			 b.tipo_associado,
			 b.num_seq_matric_empresa, 
			 b.ind_situacao,
			 b.num_associado,
			 b.nome_associado,
			 b.data_inclusao,
			 b.data_exclusao,
			 pm.nome_plano plano,
			 tp.nome_tipo_plano tipo_plano
from num_associado_tmp tmp
     join ts.beneficiario b on b.num_associado = tmp.num_associado
		 join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
		 join ts.entidade_sistema es on es.cod_entidade_ts = ce.cod_titular_contrato
		 join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
		 join ts.plano_medico pm on pm.cod_plano = b.cod_plano
		 join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
		 join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
		 join ts.tipo_plano tp on tp.cod_tipo_plano = pm.cod_tipo_plano
order by 1, 3, 2, 6, 8 		  
