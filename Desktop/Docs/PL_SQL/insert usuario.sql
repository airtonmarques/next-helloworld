select distinct 'insert into ts.usuario(cod_usuario, nom_usuario, txt_senha, txt_email, ind_troca_senha, ind_bloqueio, dt_senha_gerada, dt_cadastro, ' ||
       'cod_identificacao_ts, cod_tipo_usuario, cod_usuario_atu, dt_atu) values(' ||
			 '''G' || ce.num_contrato || ''', ' || '''G' || ce.num_contrato || ''', ' || '''G' || ce.num_contrato || ''', ''' ||
			 e.end_email || ''', ''S'', ''N'', sysdate, sysdate, ' || ce.cod_ts_contrato || ', 2, ''RAFAQUESI'', sysdate);'
from ts.contrato_empresa ce
     join ts.enderecos e on e.cod_entidade_ts = ce.cod_titular_contrato
where 1 = 1
      and ce.tipo_empresa not in (1)
      --and ce.num_contrato = '46711'
			--and ce.cod_ts_contrato = 43415
			and not exists (select 1
			                from ts.usuario u
											where u.cod_identificacao_ts = ce.cod_ts_contrato)
			and exists (select 1
			            from ts.contrato_campos_operadora cco
									where cco.cod_ts_contrato = ce.cod_ts_contrato
									      and cco.cod_operadora = ce.cod_operadora_contrato
												and cco.cod_campo = 'NOME_MIGRACAO'
												and cco.val_campo = 'PROJETO MORUMBI')
			and ce.cod_operadora_contrato IN (14)
			
			--select * from ts.tipo_usuario
