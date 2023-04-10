select 'insert into ts.valor_fe_contrato(tipo_faixa, cod_ts_contrato, cod_plano, cod_faixa_etaria, dt_ini_vigencia, tipo_associado, val_faixa, dt_atu, cod_usuario_atu, ind_momento) values (' ||
       fe.tipo_faixa || ', ' || ce.cod_ts_contrato || ', ''' ||pm.cod_plano || ''', ' || fe.cod_faixa_etaria || ', ''01/02/2023'', ''D'', ' || replace(fe.val_faixa, ',', '.') || ', sysdate, ''RAFAQUESI'', ''P'');'   
			 
from ts.contrato_empresa ce
     join ts.valor_fe_contrato fe on fe.cod_ts_contrato = ce.cod_ts_contrato
		 join ts.plano_medico pm on pm.cod_plano = fe.cod_plano
where ce.num_contrato IN (45733, 45751, 45731, 45747, '45835', '45854', '46073')
      --and fe.cod_faixa_etaria = 1
			and not exists (select 1
			                from ts.valor_fe_contrato fe1
											where fe1.cod_ts_contrato = fe.cod_ts_contrato
											      and fe1.cod_plano = fe.cod_plano
														and fe1.tipo_associado = 'D'
														and fe1.ind_momento = 'P')
