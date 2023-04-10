 SELECT  LPAD (bs.cod_banco, 3, 0) cod_banco,
                             cob.dt_emissao,
                          cob.cod_entidade_ts,
                          cob.cod_ts,
                          bs.nome_banco,
                          fat_formata_num_carteira(bs.cod_banco, nvl(cob.num_carteira,LPAD(cs.num_carteira,3,0)), cs.ind_tipo_convenio) num_carteira,
                          bs.txt_digito_verificador,
                          cs.txt_local_pgto,
                          cs.txt_especie,
                          cs.txt_especie_doc,
                          cs.nom_cedente,
                          cs.sacador_avalista,
                          cs.num_convenio,
                          cs.num_conta,
                          TO_CHAR (cob.dt_geracao, 'dd/mm/RRRR') AS dt_geracao,
                          cob.txt_nosso_numero,
                          fat_formata_cod_cedente( cs.cod_banco
                                                  ,cs.cod_agencia
                                                  ,cs.NUM_DV_AGENCIA
                                                  ,cs.num_conta
                                                  ,cs.num_dv_cc
                                                  ,nvl(cob.cod_cedente,cs.cod_cedente)
                                                  ,cs.cod_transacao_cvt) cod_cedente,
                          cs.cod_agencia,
                          fat_formata_txt_nosso_numero(bs.cod_banco, nvl(cob.num_carteira,cs.num_carteira), cs.num_convenio, cob.txt_nosso_numero_banco, bs.txt_digito_verificador) txt_nosso_numero_banco,
                          nvl(cob.val_a_pagar,0) val_a_pagar,
                          nvl(cob.val_acrescimo,0) val_acrescimo,
                          nvl(cob.val_desconto,0) val_desconto,
                          nvl(cob.VAL_IRRF,0) VAL_IRRF,
                          to_char(cob.dt_vencimento, 'dd/mm/RRRR') AS dt_vencimento,
                          to_char(cob.dt_competencia,'dd/mm/RRRR') AS dt_competencia_date,
                          to_char(cob.dt_limite_recebimento, 'dd/mm/RRRR') dt_limite_recebimento,
                          cob.num_seq_cobranca,
                          cob.cod_barras,
                          lpad(cob.num_linha_digitavel, 47, 0) num_linha_digitavel,
                          nvl(to_char(cob.DT_EMISSAO,'dd/mm/RRRR'),to_char(sysdate,'dd/mm/RRRR')) AS dt_emissao_cobranca,
                          cob.sigla_moeda,
                          cs.cod_cgc,
                          cs.cod_transacao_cvt,
                          cob.pct_multa,
                          cob.val_multa,
                          cob.pct_juros_dia,
                          cob.val_taxa_permanencia,
                          to_char(cob.dt_limite_desc_antecip,'dd/mm/RRRR') dt_limite_desc_antecip,
                          cob.cod_sistema_origem,
                          to_char(cob.dt_competencia, 'dd/mm/RRRR') AS dt_competencia,
                          cob.ind_estado_cobranca,
                          cob.COD_TIPO_LOGR,
                          cob.NOM_LOGRADOURO,
                          cob.NUM_ENDERECO,
                          cob.TXT_COMPLEMENTO,
                          cob.COD_MUNICIPIO,
                          cob.COD_BAIRRO,
                          cob.NUM_CAIXA_POSTAL,
                          MU.NOM_MUNICIPIO,
                          MU.SGL_UF,
                          BA.NOM_BAIRRO,
                          cob.num_cep,
                          es.nome_razao_social,
                          es.NUM_CGC,
                          cf.cod_tipo_ciclo,
                          cob.NUM_CICLO_TS,
                          cob.COD_TS_CONTRATO,
                          to_char(cf.MES_ANO_REF,'DD/MM/RRRR') MES_ANO_REF,
                          es.num_insc_muni NUM_INSC_MUNI_estipulante,
                          cob.COD_OPERADORA,
                          cob.cod_sucursal,
                          cob.cod_inspetoria_ts,
                          ce.cod_marca,
                          ce.ind_tipo_produto,
                          regexp_replace(NVL(lpad(es.num_cgc, 14, 0), lpad(es.num_cpf, 11, 0)), '([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})','\1.\2.\3/\4-\5') CGC_ESTIPULANTE,
                          cob.cod_tipo_cobranca,
                          to_char(cob.dt_emissao,'dd/mm/RRRR') dt_emissao,
                          nvl(re.ind_classificacao,'5') ind_classificacao,
                          0 tem_fatura_emitida,
                          '          ' dt_inicio_vigencia,
                          nullif('1','1') ind_situacao,
                          nvl(case when cob.dt_vencimento_orig is null then cob.val_a_pagar
                                     else
                                       case when nvl(cob.val_acrescimo,0) > 0 then nvl(cob.val_a_pagar,0) - cob.val_acrescimo
                                       else nvl(cob.val_a_pagar,0)
                                       end
                                     end,0) val_liquido,
                          cs.cod_layout_cnab_mensagem,
                          regexp_replace(LPAD(cs.cod_cnpj_sacador, 14, '0'), '([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})','\1.\2.\3/\4-\5') cod_cnpj_sacador
                   FROM   cobranca cob,
                          cedente_sur cs,
                          banco bs,
                          moeda mc,
                          bairro ba,
                          municipio mu,
                          entidade_sistema es,
                          ciclo_faturamento cf,
                          contrato_empresa ce,
                          regra_empresa re
                   WHERE  cob.num_seq_cedente = cs.num_seq_cedente (+)
                     AND  cob.cod_banco       = cs.cod_banco (+)
                     AND  cs.cod_banco        = bs.cod_banco (+)
                     AND  cob.sigla_moeda     = mc.sigla_moeda (+)
                     and  cob.COD_MUNICIPIO   = MU.COD_MUNICIPIO (+)
                     and  cob.COD_MUNICIPIO   = BA.COD_MUNICIPIO (+)
                     and  cob.COD_BAIRRO      = BA.COD_BAIRRO (+)
                     and  cob.NUM_CICLO_TS    = cf.NUM_CICLO_TS (+)
                     and  cob.ind_tipo_cobranca     = '3'
                     and  cob.ind_estado_cobranca not in ('2','5')
                     and  cob.cod_entidade_cobranca = es.cod_entidade_ts
                     and  cob.cod_ts_contrato       = ce.cod_ts_contrato
                     and  ce.tipo_empresa           = re.tipo_empresa(+) 
										 and cob.cod_operadora = 1 
										 and cob.cod_sucursal = 1 
										 and cob.cod_inspetoria_ts = 1 
										 and cob.num_ciclo_ts = 760 
										 and cob.cod_grupo_empresa = 45979  
										 and cob.dt_emissao is null   
										 and ce.num_contrato_operadora is not null
                   and not exists (select null
                                     from beneficiario ben, itens_cobranca ic, cobranca c
                                       where c.num_seq_cobranca_agr = cob.num_seq_cobranca
                                       and ben.cod_ts = ic.cod_ts
                                       and ic.num_seq_cobranca = c.num_seq_cobranca
                                       and ben.num_associado_operadora is null)
                   and not exists (select null
                                     from associado_aditivo aa, itens_cobranca ic, cobranca c
                                       where c.num_seq_cobranca_agr = cob.num_seq_cobranca
                                       and ic.num_Seq_cobranca = c.num_seq_cobranca
                                       and ic.cod_ts = aa.cod_ts
                                       and aa.num_associado_operadora is null
                                       and aa.dt_fim_vigencia is null)  order by 1
