declare p_ind_erro_out varchar2(4000) default ''; 
        p_msg_retorno_out varchar2(4000) default ''; 
        p_nome_arquivo varchar2(4000) default ''; 
        
begin 
  
  sur_gera_carta_cobranca(p_ind_parametro => 3,
                          p_ind_pendente => 'S',
                          p_dt_regerar => null,
                          p_cod_operadora => null,
                          p_cod_sucursal => null,
                          p_cod_inspetoria_ts => null,
                          p_ind_tipo_produto => null,
                          p_tipo_empresa => null,
                          p_cod_ts_contrato => null,
                          p_cod_ts => null,
                          p_cod_usuario => 'JOB',
                          p_endereco_ip => null,
                          p_cod_retorno => p_ind_erro_out,
                          p_msg_retorno => p_msg_retorno_out,
                          p_nome_arquivo => p_nome_arquivo,
                          p_versao => 'N');

end;
