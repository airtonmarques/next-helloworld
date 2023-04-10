select 'FAT_GRANDE_EMISSAO_PJ(p_xml_parametros => ' || 
       '''<consulta><cod_operadora>' || b.cod_operadora ||
       '</cod_operadora><cod_sucursal>' || b.cod_sucursal || 
       '</cod_sucursal><cod_inspetoria_ts>' || b.cod_inspetoria_ts ||
       '</cod_inspetoria_ts><num_ciclo_ts>679</num_ciclo_ts><dt_corte></dt_corte><dia_vencimento_ini></dia_vencimento_ini><dia_vencimento_fim></dia_vencimento_fim><cod_tipo_contrato></cod_tipo_contrato><tipo_empresa></tipo_empresa><sgl_area></sgl_area><cod_grupo_empresa></cod_grupo_empresa><cod_entidade_ts></cod_entidade_ts><cod_ts_contrato>' || b.cod_ts_contrato ||
       '</cod_ts_contrato><cod_ts>' || b.cod_ts ||
       '</cod_ts><ind_tipo_pessoa></ind_tipo_pessoa><ind_gera_fatura>S</ind_gera_fatura><data_vencimento_min></data_vencimento_min><ind_tipo_vencimento>4</ind_tipo_vencimento><qtd_meses></qtd_meses></consulta>'', ' ||
       'p_cod_usuario => ''ACFARANIO'', ' ||
       'p_endereco_ip => '''', ' ||
       'p_ind_erro_out => p_ind_erro_out, ' ||
       'p_msg_retorno_out => p_msg_retorno_out, ' ||
       'p_commit => ''S'', ' ||
       'p_versao => ''N'');'
                   
from ts.beneficiario b
where b.num_associado in ()
