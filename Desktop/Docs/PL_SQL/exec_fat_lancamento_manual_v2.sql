select 
       'fat_lancamento_manual' || 
              '(p_cod_ts => ' || cob.cod_ts || ', ' ||
              'p_cod_ts_contrato => ' || b.cod_ts_contrato || ', ' ||
              'p_cod_entidade_ts => ' || b.cod_empresa || ', ' ||
              'p_val_lancamento => ' || replace(cob.val_parc, ',', '.') || ', ' ||
              'p_txt_observacao => ''Cobrança Retroativa Reajuste 2020 - 01/12'', ' ||
              'p_ind_debito_credito => ''D'', ' || 
              'p_cod_tipo_rubrica => 250, ' ||
              'p_mes_ano_ref => ''01/2021'', ' ||
              'p_cod_plano => '''', ' ||
              'p_cod_tipo_ciclo => 1, ' ||
              'p_num_lancamento_ts => '''', ' ||
              'p_ind_acao => ''I'', ' ||
              'p_cod_usuario => ''VCGAMAS'', ' ||
              'p_txt_endereco_ip => '''', ' ||
              'p_ind_incide_ir => ''N'', ' ||
              'p_ind_incide_inss => ''N'', ' ||
              'p_num_contrato_fisico => '''', ' ||
              'p_cod_lotacao_ts => '''', ' ||
              'p_ind_erro_out => p_ind_erro_out, ' ||
              'p_msg_retorno_out => p_msg_retorno_out, ' ||
              'p_commit => ''S'', ' ||
              'p_versao => ''N'', ' ||
              'p_nom_anexo => ''''); '
from all_cob_ret_112020_cob cob
     join ts.beneficiario@allsys b on b.cod_ts = cob.cod_ts
where cob.cod_operadora_contrato = 62
