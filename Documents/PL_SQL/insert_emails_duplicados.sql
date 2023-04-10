select distinct 
       'insert into all_enderecos_duplicados(cod_ts_entidade, email) values(' || e.cod_entidade_ts || ', ''' || e.end_email || ''');'
			 from ts.enderecos e 
where instr(e.end_email, ';') = 0
and not exists (select 1
                from all_enderecos_duplicados ed
								where ed.email = e.end_email)
    and exists (select 1 
		            from ts.contrato_campos_operadora cco1
		                 join ts.contrato_empresa ce on ce.cod_ts_contrato = cco1.cod_ts_contrato
										                             and ce.cod_operadora_contrato = cco1.cod_operadora  
                where cco1.cod_ts_contrato = ce.cod_ts_contrato
								      and ce.cod_titular_contrato = e.cod_entidade_ts
                      and cco1.cod_campo = 'NOME_MIGRACAO'
                      and cco1.val_campo = 'PROJETO MORUMBI')
											
											--select * from all_enderecos_duplicados
