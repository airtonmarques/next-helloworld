select b.num_associado,
       'fat_lancamento_manual' || 
              '(p_cod_ts => ' || b.cod_ts || ', ' ||
              'p_cod_ts_contrato => ' || b.cod_ts_contrato || ', ' ||
              'p_cod_entidade_ts => ' || b.cod_empresa || ', ' ||
              --'p_val_lancamento => ' || ca.val_aditivo_tit || ', ' ||
							'p_val_lancamento => , ' || 
							--'p_val_lancamento => ' || replace(lm.valor ,',' ,'.' ) || ', ' ||
              'p_txt_observacao => ''DESCONTO VALOR COPARTICIPA��O SAUDE - LIMITADOR'', ' ||
							--'p_txt_observacao => ''' || lm.observacao || ''', ' ||
              'p_ind_debito_credito => ''C'', ' ||
							--'p_cod_tipo_rubrica => 218, ' || --Rubrica Desconto Especial Dental
							--'p_cod_tipo_rubrica => 269, ' || --Cobran�a Retroativa Reajuste
							'p_cod_tipo_rubrica => 100, ' || --Copart
							--'p_cod_tipo_rubrica => 247, ' || --Desconto M�dico
              'p_mes_ano_ref => ''05/2023'', ' ||
							--'p_mes_ano_ref => ''' || to_char(lm.competencia, 'MM/RRRR') || ''', ' ||
              'p_cod_plano => '''', ' ||
              'p_cod_tipo_ciclo => 1, ' ||
              'p_num_lancamento_ts => '''', ' ||
              'p_ind_acao => ''I'', ' ||
              'p_cod_usuario => ''ACFARANIO'', ' ||
              'p_txt_endereco_ip => '''', ' ||
              'p_ind_incide_ir => ''N'', ' ||
              'p_ind_incide_inss => ''N'', ' ||
              'p_num_contrato_fisico => '''', ' ||
              'p_cod_lotacao_ts => '''', ' ||
              'p_ind_erro_out => p_ind_erro_out, ' ||
              'p_msg_retorno_out => p_msg_retorno_out, ' ||
              'p_commit => ''S'', ' ||
              'p_versao => ''N'', ' ||
              'p_nom_anexo => '''', ' ||
							'p_val_item_pagar => ''''); '
from ts.beneficiario b
    /* join alt_lancamento_manual lm on lm.num_associado = b.num_associado
		                               and upper(lm.rubrica) like '%DESCONTO%'
																	 and upper(lm.tipo) = 'C'    */                       
     --join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     --join ts.associado_aditivo aa on aa.cod_ts = b.cod_ts
		 --join ts.aditivo a on a.cod_aditivo = aa.cod_aditivo and a.cod_tipo_rubrica = 50
		 --join ts.contrato_aditivo ca on ca.cod_aditivo = aa.cod_aditivo and ca.cod_ts_contrato = b.cod_ts_contrato
where 1 = 1
      --and trunc(lm.dth_importado) = trunc(sysdate)
			--and b.cod_empresa is not null 
      and b.num_associado IN ()												 
order by 1
