select distinct 'fat_desfaz_faturamento(p_ind_erro_out => p_ind_erro_out, ' ||
                       'p_msg_retorno_out        => p_msg_retorno_out, ' ||
                       'p_cod_operadora          => ' || f.cod_operadora || ', ' ||
                       'p_cod_sucursal           => ' || f.cod_sucursal || ', ' ||
                       'p_cod_inspetoria_ts      => ' || f.cod_inspetoria_ts || ', ' ||
                       'p_num_ciclo_ts           => ' || f.num_ciclo_ts || ', ' ||
                       'p_dia_vencimento_ini     => '''', ' ||
                       'p_dia_vencimento_fim     => '''', ' ||
                       'p_ind_tipo_vencimento    => '''', ' ||
                       'p_qtd_meses              => '''', ' ||
                       'p_cod_ts_contrato_matriz => '''', ' ||
                       'p_cod_ts_contrato        => '''', ' ||
                       'p_cod_tipo_contrato      => '''', ' ||
                       'p_tipo_empresa           => '''', ' ||
                       'p_cod_grupo_empresa      => '''', ' ||
                       'p_sgl_area               => '''', ' ||
                       'p_cod_ts_titular         => ' || lm.cod_ts || ', ' ||
                       'p_ind_tipo_pessoa        => '''', ' ||
                       'p_ind_forma_cobranca     => '''', ' ||
                       'p_qtd_laminas            => '''', ' ||
                       'p_mes_aniversario        => '''', ' ||
                       'p_ind_coparticipacao     => '''', ' ||
                       'p_cod_usuario            => ''VCGAMAS'', ' ||
                       'p_endereco_ip            => '''', ' ||
                       'p_commit                 => ''S'', ' ||
                       'p_versao                 => ''N'', ' ||
                       'p_desprezar_emitidos     => ''N'', ' ||
                       'p_ind_tipo_produto       => '''', ' ||
                       'p_ind_origem_execucao    => '''', ' ||
                       'p_ind_regulamentado      => '''', ' ||
                       'p_cod_campanha_vendas    => '''');'
from ts.fatura f
     left join ts.cobranca c on c.num_seq_fatura_ts = f.num_seq_fatura_ts
     left join ts.itens_cobranca ic on ic.num_seq_cobranca = c.num_seq_cobranca
     left join ts.ciclo_faturamento cf on cf.num_ciclo_ts = f.num_ciclo_ts
     left join ts.LOTE_FATURAMENTO lf on lf.num_seq_controle_lote = f.num_seq_controle_lote
     left join ts.lancamento_manual lm on lm.num_item_cobranca_ts = ic.num_item_cobranca_ts
where lm.cod_tipo_rubrica = 250
and lm.num_item_cobranca_ts is not null
and lm.dt_lancamento between to_date('15/12/2020 00:00:00', 'dd/mm/yyyy hh24:mi:ss')
                             and to_date('15/12/2020 23:59:59', 'dd/mm/yyyy hh24:mi:ss')
and f.cod_ts_
