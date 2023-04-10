select ce.num_contrato,
       'insert into ts.cms_contrato_comissao(cod_ts_contrato, dt_ini_vigencia, cod_corretor_ts, cod_funcao, ind_tipo_regra, ind_tipo_valor, dt_atu, cod_usuario_atu, ind_tipo_regra_agencia, ind_abate_agenciamento, ind_base_calculo) ' ||
       'values(' || ce.cod_ts_contrato || ', ''' || ce.data_inicio_vigencia || ''', ' ||
			 '(select cv.cod_corretor_ts from ts.corretor_venda cv where cv.cod_corretor = ''070955''), 2, 2, 1, sysdate, ''RAFAQUESI'', 2, ''N'', 1);',
			 'insert into ts.cms_contrato_comissao_per(cod_ts_contrato, cod_corretor_ts, cod_funcao, dt_ini_vigencia, ind_aplicacao, num_parcela_ini, num_parcela_fim, val_comissao, cod_usuario_atu, dt_atu) ' ||
			 'values(' || ce.cod_ts_contrato || ', (select cv.cod_corretor_ts from ts.corretor_venda cv where cv.cod_corretor = ''070955''), 2, ' ||
			 '''' || ce.data_inicio_vigencia || ''', 3, 1, 999999999, 2.00, ''RAFAQUESI'', sysdate);'
from ts.contrato_empresa ce
where ce.num_contrato IN ()
order by 1


--select * from ts.cms_contrato_comissao
