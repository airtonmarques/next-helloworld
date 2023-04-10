select ce.num_contrato,
       'fat_lancamento_manual' || 
              '(p_cod_ts => '''', ' ||
              'p_cod_ts_contrato => ' || ce.cod_ts_contrato || ', ' ||
              'p_cod_entidade_ts => '''', ' ||
              'p_val_lancamento => , ' ||
              'p_txt_observacao => ''Alteração de Plano Retroativo (REP)'', ' ||
              'p_ind_debito_credito => ''D'', ' || 
              'p_cod_tipo_rubrica => 220, ' ||
              'p_mes_ano_ref => ''03/2023'', ' ||
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
              'p_nom_anexo => ''''); '
from ts.contrato_empresa ce
where ce.num_contrato IN ()
order by 1
