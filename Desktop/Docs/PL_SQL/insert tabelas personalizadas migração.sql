select distinct 
     
   'insert into ts.CONTRATO_ADESAO_PLANO(cod_plano, Cod_Ts_Contrato, Dt_Ini_Vigencia, dt_ini_validade, cod_tipo_cartao, dt_atu, Cod_Usuario_Atu, Ind_Tipo_Periodo, Ind_Acompanhante) values (''' ||
       t.codigo_do_plano || ''', ' || ce.cod_ts_contrato || ', ''01/02/2023'', ''01/02/2023'', 1, sysdate, ''RAFAQUESI'', 1, 20);',  

       'insert into ts.contrato_plano(cod_plano, cod_ts_contrato, ind_tipo_valor, dt_ini_vigencia, dt_atu, cod_usuario_atu, tipo_fd_tit_imp, tipo_fd_tit_pos, tipo_fd_dep_imp, tipo_fd_dep_pos) values(''' || t.codigo_do_plano ||
       ''',' || ce.cod_ts_contrato || ', 1, ''01/02/2023'', sysdate, ''RAFAQUESI'', ' || fe.tipo_faixa || ', ' || fe.tipo_faixa || ', ' || fe.tipo_faixa || ', ' || fe.tipo_faixa || ');',
       
     
 /* 'insert into ts.valor_fe_contrato(tipo_faixa, cod_ts_contrato, cod_plano, cod_faixa_etaria, dt_ini_vigencia, tipo_associado, val_faixa, dt_atu, cod_usuario_atu, ind_momento) values (' ||
       fe.tipo_faixa || ', ' || ce.cod_ts_contrato || ', ''' || t.codigo_do_plano || ''', ' || fe.cod_faixa_etaria || ', ''01/02/2023'', ''D'', ' || replace(t.valor, ',', '.') || ', sysdate, ''RAFAQUESI'', ''P'');',    
       */
			 
			 ce.cod_ts_contrato
from ts.entidade_sistema es
     join ts.contrato_empresa ce on ce.cod_titular_contrato = es.cod_entidade_ts
     join pm_contrato c on c.cnpj_cpf_subcontrato = es.num_cgc
		 join pm_tabela t on t.id_subcontrato = c.id_subcontrato
		 join ts.faixa_etaria fe on fe.tipo_faixa = 468 --and fe.idade_inicial = 0
where upper(c.operadora) like '%METLIFE%'
      and t.tipo_tabela_faixa_etaria = 'UNICA'
			--and t.tipo_tabela_faixa_etaria not IN ('UNICA')
			and t.tipo_segurado = 'TITULAR'
     /* and not exists (select 1
			                from ts.Contrato_Adesao_Plano ap
											where ap.cod_ts_contrato = ce.cod_ts_contrato
											      and ap.cod_plano = t.codigo_do_plano)*/
														
      and not exists (select 1
                      from  ts.valor_fe_contrato fec
                      where fec.cod_ts_contrato = ce.cod_ts_contrato
											      and fec.cod_plano = t.codigo_do_plano
														and fec.ind_momento = 'P'
														and fec.tipo_associado = 'D')
			--and ce.cod_ts_contrato = 43221
order by ce.cod_ts_contrato

