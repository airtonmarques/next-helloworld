select distinct --com.id_plano,
                com.codigo_do_plano,
                com.plano,
                --net.plano,
                com.idade_minima,
                com.idade_maxima,
                com.valor,
                --net.valor,
                --ce.cod_ts_contrato,
                ce.num_contrato,
								c.id_contratante,
                --c.id_subcontrato,
                'update ts.valor_fe_contrato fe set fe.val_faixa_pagar = ' || replace(net.valor,',', '.' ) || --replace(com.valor,',', '.' ) ||
                ' where fe.cod_ts_contrato = ' || ce.cod_ts_contrato ||
                ' and fe.cod_plano = ''' || net.codigo_do_plano || --com.codigo_do_plano ||
								''' and fe.cod_faixa_etaria = ' || fe.cod_faixa_etaria ||
                ' and fe.dt_ini_vigencia >= to_date(''01/03/2023'', ''dd/mm/yyyy'') and fe.val_faixa_pagar <> ' || replace(net.valor, ',', '.') || '; ' --|| replace(com.valor, ',', '.') || '; ' 
from pm_contrato c
     join ts.entidade_sistema es on es.num_cgc = c.cnpj_cpf_subcontrato
     join ts.contrato_empresa ce on ce.cod_titular_contrato = es.cod_entidade_ts
		 join pm_tabela com on com.id_contratante = c.id_contratante
		                               and upper(com.operadora) like '%BRADESCO%'
																	 and upper(com.tipo_segurado) like '%TITULAR%'
		 join pm_tabela_net_atualizada net on net.Id_Plano = com.Id_Plano
		                                   and upper(net.operadora) like '%BRADESCO%'
																			 and net.idade_minima = com.idade_minima
																			 and upper(net.tipo_segurado) like '%TITULAR%'
																			 
     --join pm_tabela_atualizada com on com.id_contratante = c.id_contratante
     /*join pm_preco_net net on net.id_plano = com.id_plano
                           and net.idade_minima = com.idade_minima
                           and net.idade_maxima = com.idade_maxima*/
		join ts.valor_fe_contrato fe on fe.cod_ts_contrato = ce.cod_ts_contrato
		                             and fe.cod_plano = net.codigo_do_plano
																 and fe.tipo_associado = 'T'
																 and fe.ind_momento = 'I'
																 and fe.dt_ini_vigencia > to_date('01/03/2023', 'dd/mm/yyyy')
		join ts.faixa_etaria fee on fee.tipo_faixa = fe.tipo_faixa
		                         and fee.cod_faixa_etaria = fe.cod_faixa_etaria
														 and fee.idade_inicial = net.idade_minima --com.idade_minima
where 1 = 1
      and com.idade_minima < 199
			--and com.codigo_do_plano = 'P4SP'
      --and net.id_plano =  2856
      --and ce.num_contrato = '47033'
      
order by 6, 1, 3 
