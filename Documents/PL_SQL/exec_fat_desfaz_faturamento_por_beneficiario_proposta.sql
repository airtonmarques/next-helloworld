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
                       'p_cod_ts_titular         => ' || b.cod_ts || ', ' ||
                       'p_ind_tipo_pessoa        => '''', ' ||
                       'p_ind_forma_cobranca     => '''', ' ||
                       'p_qtd_laminas            => '''', ' ||
                       'p_mes_aniversario        => '''', ' ||
                       'p_ind_coparticipacao     => '''', ' ||
                       'p_cod_usuario            => ''ACFARANIO'', ' ||
                       'p_endereco_ip            => '''', ' ||
                       'p_commit                 => ''S'', ' ||
                       'p_versao                 => ''N'', ' ||
                       'p_desprezar_emitidos     => ''N'', ' ||
                       'p_ind_tipo_produto       => '''', ' ||
                       'p_ind_origem_execucao    => '''', ' ||
                       'p_ind_regulamentado      => '''', ' ||
                       'p_cod_campanha_vendas    => '''');'
from ts.beneficiario b
     join ts.fatura f on f.cod_ts = b.cod_ts
     join ts.ppf_proposta p on p.num_seq_proposta_ts = b.num_seq_proposta_ts
where f.mes_ano_ref = to_date('01/01/2022', 'dd/mm/yyyy')
and p.num_proposta_adesao IN 
()
