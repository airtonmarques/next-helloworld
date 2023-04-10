select distinct --com.id_plano,
                com.codigo_do_plano,
                com.plano,
                --net.plano,
								com.idade_minima,
								com.idade_maxima,
								com.valor,
								--net.valor,
								ce.cod_ts_contrato,
								ce.num_contrato,
								c.id_contratante,
								--c.id_subcontrato,
								/*'update ts.valor_fe_contrato fe set fe.val_faixa_pagar = ' || replace(net.valor,',', '.' ) ||
								' where fe.cod_ts_contrato = ' || ce.cod_ts_contrato ||
								' and fe.cod_plano = ''' || net.codigo_do_plano || 
								''' and fe.dt_ini_vigencia >= to_date(''01/02/2023'', ''dd/mm/yyyy'') and fe.val_faixa_pagar is null; '*/
								'update ts.valor_fe_contrato fe set fe.val_faixa = ' || replace(com.valor,',', '.' ) ||
                ' where fe.cod_ts_contrato = ' || ce.cod_ts_contrato ||
                ' and fe.cod_plano = ''' || com.codigo_do_plano || 
                ''' and fe.dt_ini_vigencia >= to_date(''01/03/2023'', ''dd/mm/yyyy'') and fe.val_faixa <> ' || com.valor || ';' 
from pm_contrato c
     join ts.entidade_sistema es on es.num_cgc = c.cnpj_contratante
		 join ts.contrato_empresa ce on ce.cod_titular_contrato = es.cod_entidade_ts
     join pm_tabela_atualizada com on com.id_contratante = c.id_contratante
    /* join pm_preco_net net on net.id_plano = com.id_plano
		                       and net.idade_minima = com.idade_minima
													 and net.idade_maxima = com.idade_maxima*/
where 1 = 1
      --and net.id_plano = 1786
      and exists (select 1
			        from ts.valor_fe_contrato fe
              where fe.cod_ts_contrato = ce.cod_ts_contrato
                    and fe.cod_plano = com.codigo_do_plano
										and fe.cod_faixa_etaria = 1
										and fe.ind_momento = 'I'
										and fe.tipo_associado = 'T'
										and fe.dt_ini_vigencia >= to_date('01/03/2023', 'dd/mm/yyyy')
										and fe.val_faixa = (select fe1.val_faixa
                                        from ts.valor_fe_contrato fe1
                                        where fe1.cod_ts_contrato = fe.cod_ts_contrato
                                              and fe1.cod_plano = fe.cod_plano
																							and fe1.tipo_faixa = fe.tipo_faixa
																							and fe1.ind_momento = fe.ind_momento
																							and fe1.tipo_associado = fe.tipo_associado
																							and fe1.dt_ini_vigencia = fe.dt_ini_vigencia
                                              and fe1.cod_faixa_etaria = 2))
			
order by 1, 5, 7
