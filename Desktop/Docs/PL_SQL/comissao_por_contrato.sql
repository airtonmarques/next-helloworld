select distinct adm.nom_operadora adm,
       op.nom_operadora operadora,
       ce.num_contrato,
       es.nome_entidade,
			 ce.ind_situacao,
			 ce.data_inicio_vigencia,
			 ce.data_fim_vigencia,
			 cc.dt_ini_vigencia inicio_comissao,
			 cc.dt_fim_vigencia fim_comissao,
			 fv.nom_funcao,
			 cv.cod_corretor cod_produtor,
			 es1.nome_entidade produtor,
			 decode(cc.ind_tipo_regra_agencia, 1, 'Por contrato', 2, 'Por família', 3, 'Por beneficiário', ' - ') tipo_regra,
 			 decode(cc.ind_tipo_valor, 1, 'Percentual', 2, 'Valor') tipo_comissao,
			 decode(cc.ind_abate_agenciamento, 'S', 'Sim', 'N', 'Não', 'Não') abate_agenciamento,
			 decode(cc.ind_base_calculo, 1, 'Valor venda', 2, 'Valor net', ' - ') base_calculo,
			 cc.txt_obs observacao,
			 ccp.num_parcela_ini,
			 ccp.num_parcela_fim,
			 ccp.val_comissao
from ts.cms_contrato_comissao cc
     join ts.FUNCAO_VENDA fv on fv.cod_funcao = cc.cod_funcao
     join ts.contrato_empresa ce on ce.cod_ts_contrato = cc.cod_ts_contrato
		 join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
		 join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
		 join ts.entidade_sistema es on es.cod_entidade_ts = ce.cod_titular_contrato
		 join ts.corretor_venda cv on cv.cod_corretor_ts = cc.cod_corretor_ts
		 join ts.entidade_sistema es1 on es1.cod_entidade_ts = cv.cod_entidade_ts
		 left join ts.CMS_CONTRATO_COMISSAO_PER ccp on ccp.cod_ts_contrato = ce.cod_ts_contrato
		                                               and ccp.cod_funcao = cc.cod_funcao
--where ce.num_contrato = '06906'
order by 1, 2, 3
