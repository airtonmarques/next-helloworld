delete ts.associado_esp_hist where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.beneficiario_contrato where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.beneficiario_empresa where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.beneficiario_movimento where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.mc_associado_web where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.ocorrencia_associado where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.associado_sib where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.beneficiario_contato where cod_entidade_ts in (select cod_entidade_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.FAT_EMISSAO_CANCELADA where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.ATD_MOTIVO where num_atendimento_ts in (select num_atendimento_ts from ts.atd_controle where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959));
delete ts.atd_controle where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.CONTROLE_CARTA where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.POSICAO_CADASTRO where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.segunda_via_carteira where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.lancamento_manual where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.itens_cobranca where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.cobranca_comissao where num_seq_cobranca in (select c.num_seq_cobranca from ts.beneficiario b join ts.cobranca c on c.cod_ts = b.cod_ts where cod_ts_tit = 1486959);
delete ts.FAT_ENVIO_ALTERACAO_CNAB where num_seq_cobranca in (select c.num_seq_cobranca from ts.beneficiario b join ts.cobranca c on c.cod_ts = b.cod_ts where cod_ts_tit = 1486959);
delete ts.fatura_corporativo where num_seq_cobranca in (select c.num_seq_cobranca from ts.beneficiario b join ts.cobranca c on c.cod_ts = b.cod_ts where cod_ts_tit = 1486959);
delete ts.cobranca where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.fatura where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.beneficiario_faturamento where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.Beneficiario_Campos_Operadora where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.cms_contrato_adesao where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.associado_aditivo where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.associado_plano where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.ass_associado_protecao_credito where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);
delete ts.beneficiario where cod_ts in (select cod_ts from ts.beneficiario where cod_ts_tit = 1486959);


