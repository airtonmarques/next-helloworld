insert into ts.beneficiario_contato (num_seq_contato, cod_entidade_ts, ind_class_contato, end_email, ind_envia_email, dt_atu, cod_usuario_atu) values (ts_beneficiario_contato_seq.nextval, (select cod_entidade_ts from ts.beneficiario where cod_ts = 1228618), 'E',  lower('bsebastiaoismarcorrea@hotmail.com'), 'S', sysdate, 'RAFAQUESI');
update ts.beneficiario b set b.num_proposta = '', b.num_associado_operadora = '' where b.cod_ts = 
update ts.beneficiario b set b.num_associado_operadora = '' where b.cod_ts =   
update ts.beneficiario_contrato bc set bc.data_adesao = '' where bc.cod_ts = 
update ts.beneficiario_faturamento bf set bf.num_cpf_resp_reemb = , bf.nome_resp_reemb = '' where bf.cod_ts = 
update ts.beneficiario_faturamento bf set bf.ind_efaturamento = 'S', bf.dt_ini_efaturamento = trunc(sysdate) where bf.cod_ts = --Efaturamento 
insert into ts.ocorrencia_associado(cod_ts, cod_ocorrencia, dt_ocorrencia, txt_obs, dt_fato, cod_usuario_atu) values(, 203, sysdate, 'Adesão ao eFaturamento em ' || trunc(sysdate) || ' por RAFAQUESI', trunc(sysdate), 'RAFAQUESI'); --EFATURAMENTO 
