												
select --'delete ts.contrato_campos_operadora where cod_operadora = 9 and cod_ts_contrato = ' || ce.cod_ts_contrato || ';' 
       distinct 
       'con_exclui_implantacao(p_cod_ts_contrato => ' || ce.cod_ts_contrato || 
			                ', p_cod_usuario => ''RAFAQUESI'', p_endereco_ip => '''', p_ind_erro_out => v_ind_erro_out, p_msg_retorno_out => v_msg_retorno_out, ' ||
                       'p_commit => ''S'', p_versao => ''N'');'
 --co.*
      
from pm_contrato pm
     join ts.entidade_sistema es on es.num_cgc = pm.cnpj_cpf_subcontrato
		 join ts.contrato_empresa ce on ce.cod_titular_contrato = es.cod_entidade_ts
		 join ts.contrato_campos_operadora co on co.cod_ts_contrato = ce.cod_ts_contrato and co.cod_operadora = 9
where upper(pm.operadora) like '%BRADESCO ADES%'
      --and pm.tipo_subcontrato = 'PJ'
			and ce.cod_operadora_contrato = 14
			--and co.cod_campo = 'IND_MIGRADO'
			--and co.val_campo = 'PROJETO MORUMBI'
--update ts.contrato_campos_operadora set cod_campo = 'NOME_MIGRACAO' where cod_campo = 'IND_MIGRADO' and val_campo = 'PROJETO MORUMBI' 			
			
--select * from ts.ppf_operadoras o where upper(o.nom_operadora) like '%FESP%'
