select (select bb.num_matric_empresa from ts.beneficiario bb where bb.cod_ts = b.cod_ts_tit) MATRICULA_TITULAR,
       (select substr(bb.nome_associado, 0, 100) from ts.beneficiario bb where bb.cod_ts = b.cod_ts_tit) NOME_TITULAR,
       (select lpad(bbe.num_cpf, 11, '0') from ts.beneficiario_entidade bbe where bbe.cod_entidade_ts = b.cod_entidade_ts_tit) CPF_TITULAR,
       (select to_char(bbe.data_nascimento, 'DDMMYYYY') from ts.beneficiario_entidade bbe where bbe.cod_entidade_ts = b.cod_entidade_ts_tit) DT_NASC_TITULAR, 
       lpad(case
                       when b.cod_dependencia is null then
                        0
                       when b.cod_dependencia = 1 then
                        24
                       when b.cod_dependencia in (2, 31, 9) then
                        01
                       when b.cod_dependencia = 12 then
                        02
                       when b.cod_dependencia in (3, 29, 30) then
                        03
                       when b.cod_dependencia in (65, 66, 11) then
                        06
                       when b.cod_dependencia in (5, 80, 85) then
                        14
                       when b.cod_dependencia in (7, 57, 56) then
                        17
                       when b.cod_dependencia in (61, 62) then
                        20
                       when b.cod_dependencia in (4, 6, 10, 58, 59) then
                        31
                       when b.cod_dependencia = 13 then
                        33
                     end,
                     2,
                     '0') COD_VINCULO, 
                ts_top.ts_limpa_acentuacao(nvl(nvl(mov.nom_logradouro, mov.nom_logradouro2), mov.nom_logradouro3)) END_LOGRADOURO, 
                decode((substr(mov.nom_logradouro,
                               0,
                               instr(mov.nom_logradouro, ' ', 1))),
                       'AC ',
                       50,
                       'AL ',
                       2,
                       'AV ',
                       4,
                       'BL ',
                       45,
                       'CJ ',
                       9,
                       'EST ',
                       13,
                       'PR ',
                       49,
                       'PRQ ',
                       24,
                       'PSG ',
                       136,
                       'Q ',
                       28,
                       'R ',
                       32,
                       'RES ',
                       30,
                       'ROD ',
                       31,
                       'TV ',
                       35,
                       'VL ',
                       43,
                       'ALAMEDA ',
                       2,
                       'ÁREA ',
                       3,
                       'AVENIDA ',
                       4,
                       'JARDIM ',
                       16,
                       'Quadra ',
                       28,
                       'QUADRA ',
                       28,
                       'RUA ',
                       32,
                       'ASA ',
                       3,
                       'AV. ',
                       4,
                       'COND ',
                       8,
                       'CONJ ',
                       9,
                       'JDN ',
                       16,
                       'PÇ ',
                       27,
                       'praca ',
                       27,
                       'QBR ',
                       28,
                       'QE ',
                       28,
                       'QI ',
                       28,
                       'QMS ',
                       28,
                       'QMSW ',
                       28,
                       'QN ',
                       28,
                       'QNG ',
                       28,
                       'QNL ',
                       28,
                       'QNM ',
                       28,
                       'QNN ',
                       28,
                       'QR ',
                       28,
                       'SCS ',
                       33,
                       'SGAN ',
                       33,
                       'SGAS ',
                       33,
                       'SHCES ',
                       33,
                       'SHIN ',
                       33,
                       'SMPW ',
                       33,
                       'SMT ',
                       33,
                       'SQ ',
                       33,
                       'SQN ',
                       33,
                       'SQS ',
                       33,
                       'SQSW ',
                       33,
                       116) END_TIPO_LOGRAD, 
                ts_top.ts_limpa_acentuacao(bairro.nom_bairro) END_BAIRRO,
                m.cod_municipio END_COD_MUNICIPIO,
                m.sgl_uf END_UF,
                nvl(nvl(mov.num_cep, mov.num_cep2), mov.num_cep3) END_CEP,
                nvl(nvl(mov.num_ddd_telefone_1, mov.num_ddd_telefone_2), mov.num_ddd_telefone_3) DDD_RESIDENCIA,
                nvl(nvl(mov.num_telefone_1, mov.num_telefone_2), mov.num_telefone_3) FONE_RESIDENCIA,
                nvl(nvl(mov.ddd_celular_1, mov.ddd_celular_2), mov.ddd_celular_3) DDD_CELULAR,
                nvl(nvl(mov.num_celular_1, mov.num_celular_2), mov.num_celular_3) FONE_CELULAR,
                nvl(nvl(mov.end_email_1, mov.end_email_2), mov.end_email_3) EMAIL_PARTICULAR,
                bf.cod_banco_reemb BANCO,
                bf.cod_agencia_reemb AGENCIA,
                (bf.num_conta_corrente_reemb || '-' || bf.num_dv_cc_reemb) CONTA, 
                '001' TIPO_CONTA,
                lpad(b.num_cco_dv, 2, '0') COD_DEP,
                b.nome_associado NOME_DEP,
                lpad(be.num_cpf, 11, '0') CPF_DEP,
                be.nome_mae NOME_MAE_DEP,
                to_char(be.data_nascimento, 'DDMMYYYY') DT_NASC_DEP,
                '1' COD_ADMINISTRADORA,
                to_char(b.data_inclusao, 'DDMMYYYY') DT_INICIO_CONTRATO,
                to_char(b.data_exclusao, 'DDMMYYYY') DT_FIM_CONTRATO,
                'I' OPERACAO

 from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.mc_associado_mov mov on mov.num_seq_proposta_ts = b.num_seq_proposta_ts
     left join ts.beneficiario_faturamento bf on bf.cod_ts = b.cod_ts_tit
     left join ts.bairro bairro on bairro.cod_municipio = mov.cod_municipio and bairro.cod_bairro = mov.cod_bairro
     left join ts.municipio m on m.cod_municipio = mov.cod_municipio
     left join ts.tipo_dependencia_operadora dep on dep.cod_dependencia = b.cod_dependencia 
                                                    and dep.cod_operadora = ce.cod_operadora_contrato 
     left join ts.estado_civil ec on ec.ind_estado_civil = be.ind_estado_civil
where ce.num_contrato = :NUM_CONTR
      and b.data_inclusao between to_date(:DT_INCL_INICIO, 'DD/MM/YYYY') and
       to_date(:DT_INCL_FIM, 'DD/MM/YYYY')
      and b.data_exclusao is null
      and mov.cod_tipo_operacao = 1
