select distinct 

      /*  'insert into ts.CONTRATO_ADESAO_PLANO(cod_plano, Cod_Ts_Contrato, Dt_Ini_Vigencia, dt_ini_validade, cod_tipo_cartao, dt_atu, Cod_Usuario_Atu, Ind_Tipo_Periodo, Ind_Acompanhante) values (''' ||
       t.codigo_do_plano || ''', 43452, ''01/02/2023'', ''01/02/2023'', 1, sysdate, ''RAFAQUESI'', 1, 20);',  

       'insert into ts.contrato_plano(cod_plano, cod_ts_contrato, ind_tipo_valor, dt_ini_vigencia, dt_atu, cod_usuario_atu, tipo_fd_tit_imp, tipo_fd_tit_pos, tipo_fd_dep_imp, tipo_fd_dep_pos) values(''' || t.codigo_do_plano ||
       ''', 43452, 1, ''01/02/2023'', sysdate, ''RAFAQUESI'', ' || fe.tipo_faixa || ', ' || fe.tipo_faixa || ', ' || fe.tipo_faixa || ', ' || fe.tipo_faixa || ');',
			 */
			 
			 'insert into ts.valor_fe_contrato(tipo_faixa, cod_ts_contrato, cod_plano, cod_faixa_etaria, dt_ini_vigencia, tipo_associado, val_faixa, dt_atu, cod_usuario_atu, ind_momento) values (' ||
			 fe.tipo_faixa || ', 43452, ''' || t.codigo_do_plano || ''', ' || fe.cod_faixa_etaria || ', ''01/02/2023'', ''T'', ' || replace(t.valor, ',', '.') || ', sysdate, ''RAFAQUESI'', ''I'');',    
			 
			 
			 t.codigo_do_plano,
			 t.operadora
from pm_tabela t
     join ts.faixa_etaria fe on --fe.idade_inicial = 0--t.idade_minima
		                          --and fe.idade_final = t.idade_maxima
														     fe.tipo_faixa = 470
where t.tipo_segurado = 'TITULAR'
      and upper(t.tipo_contratação) like '%EMPRESARIAL%'
			--and t.tipo_tabela_faixa_etaria not IN ('UNICA')
      and upper(t.operadora)like '%BRADESCO EMPRESARIAL%'
			and t.codigo_do_plano is not null
			and t.codigo_contrato = (select max(t1.codigo_contrato)
			                         from pm_tabela t1
															 where t1.tipo_segurado = t.tipo_segurado
															       and t1.operadora = t.operadora
																		 and t1.codigo_do_plano = t.codigo_do_plano)
order by  t.codigo_do_plano
