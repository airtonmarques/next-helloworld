select distinct 
       'fat_lancamento_manual' || 
              '(p_cod_ts => ' || cob.cod_ts || ', ' ||
              'p_cod_ts_contrato => ' || b.cod_ts_contrato || ', ' ||
              'p_cod_entidade_ts => ' || b.cod_empresa || ', ' ||
              'p_val_lancamento => ' || replace(cob.val_parc, ',', '.') || ', ' ||
              'p_txt_observacao => ''Cobrança Retroativa Reajuste 2020 - 02/12'', ' ||
              'p_ind_debito_credito => ''D'', ' || 
              'p_cod_tipo_rubrica => 251, ' ||
              'p_mes_ano_ref => ''02/2021'', ' ||
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
where /*cob.dt_insert = to_date('17/12/2020', 'dd/mm/yyyy')
      and*/ not exists (select 1 
                       from ts.lancamento_manual@allsys l
                       where l.cod_tipo_rubrica = 250
                             and l.cod_ts = cob.cod_ts) 
                             --cob.cod_operadora_contrato = 233
                              and cob.val_parc > 0
      and trunc(cob.dt_lanc) < to_date('28/12/2020', 'dd/mm/yyyy')
      and cob.cod_operadora_contrato in (97)
      --and b.cod_ts_contrato = 13005
                              
     /* and not exists (select 1
                   from all_cob_ret_112020_cob c
                   join ts.beneficiario@allsys b on b.cod_ts = c.cod_ts
                   where b.data_exclusao <= to_date('16/12/2020', 'dd/mm/yyyy')
                         and exists (select 1 from ts.beneficiario@allsys b2 
                                    where b2.cod_ts = b.cod_ts_tit 
                                          and b2.data_exclusao <= to_date('16/12/2020', 'dd/mm/yyyy')))*/
--select * from all_cob_ret_112020_cob

-----------------------------------
/*
declare p_ind_erro_out varchar2(4000) default ''; p_msg_retorno_out varchar2(4000) default ''; begin 

end;
*/
