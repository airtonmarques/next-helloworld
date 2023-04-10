 select   nom_administradora, nome_sucursal, nome_inspetoria, num_contrato_editado, nome_entidade, nome_empresa, dt_vencimento_order, dt_emissao, dt_vencimento, dt_baixa, dt_registro_baixa, dt_cancelamento, txt_nosso_numero, txt_nosso_numero_banco, num_fatura, nom_tipo_ciclo, mes_ano_ref, nome_tipo_cobranca, ind_tipo_baixa, nome_tipo_baixa, val_fatura, val_a_pagar, val_pago, val_desconto, val_saldo, nom_arquivo, cod_banco, ind_estado_cobranca, situacao, forma_baixa, num_agencia, impostos, diferenca, qtd_dias_atraso, num_cgc, venc_alterado, ins_encargos, nome_usu, celula, ind_tipo_produto, tipo_empresa, nome_tipo_empresa, segmento, cedente, dt_prorrogacao, contrato_mae, num_nota_fiscal, status_contrato, data_status, nom_cancelamento, cod_ts, ind_apos_dem, ind_acao_jud, num_operadora_ans, nom_operadora, cod_plano_medico, nome_plano_medico, cod_plano_dental, nome_plano_dental, Val_medico, Val_outros, val_dental, val_taxas, val_mensalidade_associativa, Val_net_medico, val_net_dental, cod_grupo_empresa, nome_grupo_empresa, nvl(val_medico,0) - nvl(val_net_medico,0) val_over_medico, nvl(val_dental,0) - nvl(val_net_dental,0) val_over_dental, nvl(val_medico,0) - nvl(val_net_medico,0) + (nvl(val_dental,0) - nvl(val_net_dental,0)) val_over_total, endereco, telefone, celular, acao_judicial, dt_ini_vigencia, data_inclusao, num_cpf, dia_vencimento, email, nome_corretor, regiao, num_contrato_operadora, data_nascimento, idade, Marca_otica_Medico, marca_otica_dental, data_reativacao, motivo_exclusao, dia_vigencia, nom_empresa_cartao, data_suspensao, tipo_associado, periodo_cobertura, tipo_inadimplencia, cod_motivo_canc_cobranca, motivo_canc_cobranca, dt_vencimento_original, txt_obs_baixa from ( select /*rec_acompanhamento_cobranca.monta_query principal*/      op.nom_operadora nom_administradora,      su.nome_sucursal,      ip.nome_inspetoria,      ce.num_contrato_editado,      fa.nome_cliente nome_entidade,      es.nome_entidade nome_empresa,      nvl(co.dt_vencimento_orig,co.dt_vencimento) dt_vencimento_order,      to_char(co.dt_emissao, 'dd/MM/rrrr') dt_emissao,      to_char(co.dt_vencimento, 'dd/MM/rrrr') dt_vencimento,      to_char(co.dt_baixa, 'dd/MM/rrrr') dt_baixa,      to_char(co.dt_registro_baixa, 'dd/MM/rrrr') dt_registro_baixa,      to_char(co.dt_cancelamento, 'dd/MM/rrrr') dt_cancelamento,      co.txt_nosso_numero,      co.txt_nosso_numero_banco,      fa.num_fatura,      tc.nom_tipo_ciclo,      to_char(cf.mes_ano_ref, 'mm/rrrr') mes_ano_ref,      tcob.nome_tipo_cobranca,      co.ind_tipo_baixa,      tb.nome_tipo_baixa,      fa.val_fatura,      nvl(co.val_a_pagar, 0) val_a_pagar,      nvl(co.val_pago, 0) val_pago,      case       when co.ind_estado_cobranca = '1' and            co.val_pago < nvl(co.val_a_pagar, 0) then        nvl(co.val_a_pagar, 0) - co.val_pago       when 1 = 1 then        0      end val_desconto,      case       when co.ind_estado_cobranca = '6' and            co.val_pago < nvl(co.val_a_pagar, 0) then        nvl(co.val_a_pagar, 0) - co.val_pago       when 1 = 1 then        0      end val_saldo,               (select crsur.nom_arquivo
                                             from controle_recebimento_sur  crsur
                                            Where crsur.num_seq_controle_recbto = (select min(crs.num_seq_controle_recbto)
                                                                                        from credito_recebido_sur crs
                                                                                       where crs.ind_estado_credito = 1
                                                                                         and co.num_seq_cobranca = crs.num_seq_cobranca )
                                                                                         )  as nom_arquivo,       case         when co.cod_tipo_cobranca = 3 then          nvl(co.cod_banco_dcc,co.cod_banco)         else          co.cod_banco       end cod_banco,       co.ind_estado_cobranca,       case        when co.dt_baixa is not null and             co.ind_estado_cobranca = '1' then         'P'        when co.dt_vencimento < trunc(sysdate) and             co.ind_estado_cobranca in ('0', '3') then         'Ve'        when co.dt_vencimento >= trunc(sysdate) and             co.ind_estado_cobranca in ('0', '3') then         'Vi'        when co.dt_cancelamento is not null then         'C'        when co.ind_estado_cobranca = '4' then         'Rn'        when co.ind_estado_cobranca = '6' then         'BP'       end situacao,       (select csr1.ind_forma_criacao
                                      from credito_recebido_sur csr1
                                     where csr1.num_seq_credito_recebido = (select min(crs.num_seq_credito_recebido)
                                                                                 from credito_recebido_sur crs
                                                                                where crs.ind_estado_credito = 1
                                                                                  and co.num_seq_cobranca = crs.num_seq_cobranca)
                                       and csr1.ind_estado_credito = 1
                                       and co.num_seq_cobranca = csr1.num_seq_cobranca)  as forma_baixa,       decode(co.num_dv_agencia_dcc,null,to_char(co.cod_agencia_dcc),to_char(co.cod_agencia_dcc)) num_agencia,       nvl(fa.val_irrf, 0) + nvl(fa.val_csll, 0) +       nvl(fa.val_cofins, 0) + nvl(fa.val_pis, 0) impostos,       case when nvl(co.val_a_pagar, 0) - nvl(co.val_pago, 0) > 0 and co.ind_estado_cobranca = '1' then           nvl(co.val_a_pagar, 0) - nvl(co.val_pago, 0)             else 0       end diferenca,       nvl(co.qtd_dias_atraso, case when co.ind_estado_cobranca in ('0', '3') and trunc(sysdate) > co.dt_vencimento then trunc(sysdate) - co.dt_vencimento else 0 end) qtd_dias_atraso,       nvl(es.num_cgc, '') num_cgc,       decode(co.dt_vencimento_orig, null, 'NÃO', 'SIM') venc_alterado,       case        when nvl(co.val_a_pagar_orig, 0) > 0 then         case        when nvl(co.val_a_pagar_orig, 0) < nvl(co.val_a_pagar, 0) then         'SIM'        else         'NÃO'       end else 'NÃO' end ins_encargos,       case        when co.dt_vencimento_orig is not null then         (select nom_usuario            from usuario           where cod_usuario = co.cod_usuario_atu)        else         ''       end nome_usu,       eq.num_celula_posvenda celula,           (select case                   when exists                       (select 1                          from associado_aditivo aa2                         where aa2.cod_ts = b.cod_ts_tit                           and aa2.dt_ini_vigencia <= last_day(cf.mes_ano_ref    )                           and (aa2.dt_fim_vigencia is null or                                aa2.dt_fim_vigencia >= cf.mes_ano_ref)) then                   'Ambos'                   else                       decode(pm.cod_tipo_plano, '1', 'Médico', '4', 'Dental')                   end case         from beneficiario b, plano_medico pm, ciclo_faturamento cf        where b.cod_ts = co.cod_ts  and cf.num_ciclo_ts = co.num_ciclo_ts          and b.cod_plano = pm.cod_plano) ind_tipo_produto,              ce.tipo_empresa,              rg.nome_tipo_empresa,              'P' || tcon.ind_tipo_pessoa segmento,              case              when co.cod_tipo_cobranca = 3 then                   nvl(cedcc.cod_cedente,ced.cod_cedente)              else                   ced.cod_cedente              end cedente,        to_char(co.dt_vencimento, 'dd/mm/rrrr') dt_prorrogacao,        ce_ge.num_contrato_editado contrato_mae,        fa.num_fatura_ret_rps num_nota_fiscal,        nvl(sass.nom_situacao, scon.nom_situacao)  status_contrato,        null data_status,        mot.nom_cancelamento,        co.cod_ts,        co.ind_apos_dem,        co.ind_acao_jud,        ppf_op.num_operadora_ans,        ppf_op.nom_operadora,        (select pm.cod_plano           from itens_cobranca ic          inner join plano_medico pm             on pm.cod_plano = ic.cod_plano          where co.num_seq_cobranca = ic.num_seq_cobranca            and ic.cod_plano is not null            and pm.cod_tipo_plano = 1            and rownum = 1) cod_plano_medico,        (select pm.nome_plano           from itens_cobranca ic, plano_medico pm          where co.num_seq_cobranca = ic.num_seq_cobranca            and ic.cod_plano is not null            and pm.cod_tipo_plano = 1            and ic.cod_plano = pm.cod_plano            and rownum = 1) nome_plano_medico,         (select nvl(ic.cod_aditivo, decode(pm.cod_tipo_plano, 4, ic.cod_plano, null))            from itens_cobranca ic            left join plano_medico pm              on pm.cod_plano = ic.cod_plano           where ic.num_seq_cobranca = co.num_seq_cobranca             and (pm.cod_tipo_plano = 4 or ic.cod_aditivo is not null) and rownum = 1) cod_plano_dental,         (select nvl(ad.nom_aditivo, pm.nome_plano)            from itens_cobranca ic, aditivo ad, plano_medico pm           where ic.num_seq_cobranca = co.num_seq_cobranca             and ic.cod_plano = pm.cod_plano (+)             and pm.cod_tipo_plano (+) = 4             and ic.cod_aditivo = ad.cod_aditivo (+)             and (pm.cod_tipo_plano = 4 or ic.cod_aditivo is not null) and rownum = 1) nome_plano_dental,       case when co.ind_tipo_cobranca != 3 then         (select sum(val_item_cobranca)               from itens_cobranca ic              inner join plano_medico pm                 on ic.cod_plano = pm.cod_plano              where ic.num_seq_cobranca = co.num_Seq_cobranca                and pm.cod_tipo_plano = 1                and ic.cod_grupo_rubrica in (1, 2,9)                and ic.cod_aditivo is null                and ic.cod_tipo_rubrica not in (45, 46, 244))      when co.ind_tipo_cobranca = 3 then          (select sum(val_item_cobranca)                from itens_cobranca ic, plano_medico pm, cobranca ccc                where ic.cod_plano = pm.cod_plano                      and ic.num_seq_cobranca = ccc.num_seq_cobranca                      and ccc.num_seq_cobranca_agr = co.num_seq_cobranca                      and pm.cod_tipo_plano = 1                      and ic.cod_grupo_rubrica in (1, 2, 9)                      and ic.cod_aditivo is null                      and ic.cod_tipo_rubrica not in (45, 46, 244)) end Val_medico,                 nvl((select sum(val_item_cobranca)               from itens_cobranca ic              where ic.num_seq_cobranca = co.num_Seq_cobranca                and ic.cod_grupo_rubrica not in (1, 2,6,9)                and ic.cod_tipo_rubrica not in (45, 46, 244)),0) Val_outros,       case when co.ind_tipo_cobranca != 3 then           nvl((select sum(val_item_cobranca) valor                  from itens_cobranca ic, plano_medico pm                 where ic.num_seq_cobranca = co.num_Seq_cobranca                   and ic.cod_plano = pm.cod_plano                   and ic.cod_grupo_rubrica in (1, 2,9)                   and ic.cod_tipo_rubrica not in (45, 46, 244)               and pm.cod_tipo_plano = 4),0) +           nvl((select sum(val_item_cobranca) valor                  from itens_cobranca ic, aditivo ad                 where ic.num_seq_cobranca = co.num_Seq_cobranca                   and ic.cod_grupo_rubrica = 6                   and ic.cod_aditivo = ad.cod_aditivo),0)       when co.ind_tipo_cobranca = 3 then              (select sum(val_item_cobranca) valor                   from itens_cobranca ic, plano_medico pm, cobranca ccc                   where ic.num_seq_cobranca = ccc.num_Seq_cobranca                      and ccc.num_seq_cobranca_agr = co.num_seq_cobranca                      and ic.cod_plano = pm.cod_plano                      and ic.cod_grupo_rubrica in (1, 2,9)                      and ic.cod_tipo_rubrica not in (45, 46, 244)                      and pm.cod_tipo_plano = 4)  +           (select sum(val_item_cobranca) valor                   from itens_cobranca ic, aditivo ad, cobranca ccc                   where ic.num_seq_cobranca = ccc.num_Seq_cobranca                     and ccc.num_seq_cobranca_agr = co.num_seq_cobranca                     and ic.cod_grupo_rubrica = 6                     and ic.cod_aditivo = ad.cod_aditivo) end val_dental,            (select sum(val_item_cobranca)               from itens_cobranca ic              where ic.num_seq_cobranca = co.num_Seq_cobranca                and ic.cod_tipo_rubrica in (46, 244)) val_taxas,            (select sum(val_item_cobranca)               from itens_cobranca ic              where ic.num_seq_cobranca = co.num_Seq_cobranca                and ic.cod_tipo_rubrica in (45)) val_mensalidade_associativa,       case when co.ind_tipo_cobranca != 3 then            (select sum(val_item_pagar)               from itens_cobranca ic              inner join plano_medico pm                 on ic.cod_plano = pm.cod_plano              where ic.num_seq_cobranca = co.num_Seq_cobranca                and pm.cod_tipo_plano = 1                and ic.cod_grupo_rubrica in (1, 2,9)                and ic.cod_aditivo is null              and ic.cod_tipo_rubrica not in (45, 46, 244))       when co.ind_tipo_cobranca = 3 then            (select sum(val_item_pagar)                from itens_cobranca ic, plano_medico pm, cobranca ccc                where ic.cod_plano = pm.cod_plano                  and ic.num_seq_cobranca = ccc.num_Seq_cobranca                  and ccc.num_seq_cobranca_agr = co.num_seq_cobranca                  and pm.cod_tipo_plano = 1                  and ic.cod_grupo_rubrica in (1, 2,9)                  and ic.cod_aditivo is null                  and ic.cod_tipo_rubrica not in (45, 46, 244)) end Val_net_medico,      case when co.ind_tipo_cobranca != 3 then           nvl((select sum(val_item_pagar) valor                  from itens_cobranca ic, plano_medico pm                 where ic.num_seq_cobranca = co.num_Seq_cobranca                   and ic.cod_plano = pm.cod_plano                   and ic.cod_grupo_rubrica in (1, 2,9)                   and ic.cod_tipo_rubrica not in (45, 46, 244)                 and pm.cod_tipo_plano = 4),0) +           nvl((select sum(val_item_pagar) valor                  from itens_cobranca ic, aditivo ad                 where ic.num_seq_cobranca = co.num_Seq_cobranca                   and ic.cod_grupo_rubrica = 6                   and ic.cod_aditivo = ad.cod_aditivo),0)      when co.ind_tipo_cobranca = 3 then           (select sum(val_item_pagar) valor              from itens_cobranca ic, plano_medico pm, cobranca ccc              where ic.num_seq_cobranca = ccc.num_Seq_cobranca                 and ccc.num_seq_cobranca_agr = co.num_seq_cobranca                 and ic.cod_plano = pm.cod_plano                 and ic.cod_grupo_rubrica in (1, 2,9)                 and ic.cod_tipo_rubrica not in (45, 46, 244)                 and pm.cod_tipo_plano = 4) +           (select sum(val_item_pagar) valor              from itens_cobranca ic, aditivo ad, cobranca ccc              where ic.num_seq_cobranca = ccc.num_Seq_cobranca                and ccc.num_seq_cobranca_agr = co.num_seq_cobranca                and ic.cod_grupo_rubrica = 6                 and ic.cod_aditivo = ad.cod_aditivo) end val_net_dental,           ge.cod_grupo_empresa,           ge.nome_grupo_empresa,          (DECODE(fa.nom_logradouro,  NULL, NULL, fa.nom_logradouro         || ' ')   ||           DECODE(fa.num_endereco,    NULL, NULL, fa.num_endereco           || ',  ') ||           DECODE(fa.txt_complemento, NULL, NULL, fa.txt_complemento        || ' - ') ||           DECODE(fa.num_cep,         NULL, NULL, fa.num_cep                || ' - ') ||           DECODE(fa.nome_bairro,     NULL, NULL, fa.nome_bairro            || ' - ') ||           DECODE(fa.nome_cidade,     NULL, NULL, fa.nome_cidade            || ' - ') ||           DECODE(fa.sgl_uf,          NULL, NULL, fa.sgl_uf) ) endereco,          (SELECT '('||becon.num_ddd||')' ||' '||becon.num_telefone             FROM beneficiario_contato becon            WHERE becon.cod_entidade_ts = be.cod_entidade_ts              AND becon.ind_class_contato = 'T'              AND becon.num_telefone IS NOT NULL              AND ROWNUM = 1) telefone,          (SELECT '('||becon.num_ddd||')' ||' '||becon.num_telefone             FROM beneficiario_contato becon            WHERE becon.cod_entidade_ts = be.cod_entidade_ts              AND becon.ind_class_contato = 'C'              AND becon.num_telefone IS NOT NULL              AND ROWNUM = 1) celular,          NVL((SELECT 'S'                 FROM acao_jud_pgto                WHERE dt_ini_acao <= TRUNC(SYSDATE)                  AND (dt_fim_acao > TRUNC(SYSDATE) OR dt_fim_acao IS NULL)                  AND cod_ts = be.cod_ts                  AND rownum =1), 'N') acao_judicial,          to_char(ce.data_inicio_vigencia, 'dd/mm/rrrr') dt_ini_vigencia,          to_char(be.data_inclusao, 'dd/mm/rrrr') data_inclusao,          nvl(es.num_cpf, fa.num_cpf) NUM_CPF,         (SELECT dia_vencimento from associado a where a.cod_ts = be.cod_ts and rownum = 1) DIA_VENCIMENTO,         (SELECT end_email            FROM beneficiario_contato           WHERE cod_entidade_ts = be.cod_entidade_ts             AND ind_class_contato = 'E'          AND ROWNUM = 1) email,         coalesce(es_corr.nome_entidade,es_corrPj.nome_entidade) nome_corretor,         reg.nome_regional regiao,         ce.num_contrato_operadora ,         ent_bene.data_nascimento  ,         ts_calcula_idade(ent_bene.data_nascimento, cf.mes_ano_ref, 'A') as idade ,      case (select pm.cod_tipo_plano from plano_medico pm where pm.cod_plano = be.cod_plano)
                                    when 4 then
                                     null
                                    else
                                       be.num_associado_operadora
                                 end Marca_otica_Medico,         case (select pm.cod_tipo_plano from plano_medico pm where pm.cod_plano = be.cod_plano)
                                    when 4 then
                                      be.num_associado_operadora         else         (select num_associado_operadora            from associado_aditivo ad,                 aditivo adi,                 contrato_aditivo  ca,                 grupo_aditivo     ga           where ca.cod_ts_contrato = ad.cod_ts_contrato             and ca.dt_ini_vigencia <= ad.dt_ini_vigencia             and ca.cod_aditivo = ad.cod_aditivo             and ca.cod_ts_contrato_aditivo is not null             and ca.dt_ini_vigencia = (select max(dt_ini_vigencia)                                       from contrato_aditivo                                       where cod_ts_contrato = ca.cod_ts_contrato                                       and dt_ini_vigencia <= ad.dt_ini_vigencia                                       and cod_aditivo = ad.cod_aditivo                                       and cod_ts_contrato_aditivo is not null)             and ad.cod_aditivo = adi.cod_aditivo             and adi.cod_grupo_aditivo = ga.cod_grupo_aditivo             and ga.cod_grupo_aditivo = 1  and rownum = 1             and ad.cod_ts = be.cod_ts)          end marca_otica_dental,(select max(ass.data_reativacao) from associado ass where cod_ts = be.cod_ts) as data_reativacao, (select mea.nome_motivo_exc_assoc from motivo_exclusao_assoc mea, beneficiario_contrato bec
                               where mea.cod_motivo_exc_assoc = bec.cod_motivo_exclusao
                                 and bec.cod_ts = be.cod_ts and rownum=1) as motivo_exclusao ,                to_char(ce.data_inicio_vigencia,'dd') as dia_vigencia,  enc.nom_empresa_cartao,( select to_char(max(ao.dt_atu),'dd/mm/rrrr')                                       from associado_operadora ao                                              where ao.cod_ts = bf.cod_ts                                                and ao.ind_tipo_movimento = 'N'
                         and ao.ind_situacao not in ('3','4') ) as data_suspensao         ,      case when be.tipo_associado = 'T' then                                        'Titular'                                                          when be.tipo_associado = 'D' then                                        'Dependente'                                                       when be.tipo_associado = 'A' then                                        'Agregado'                                                         when be.tipo_associado = 'P' then                                        'Patrocinador'                                                     else                                                                       ''                                                            end tipo_associado                                                     ,(to_char(fa.dt_ini_periodo,'DD/MM/RRRR')|| ' a '|| to_char(fa.dt_fim_periodo,'DD/MM/RRRR')  )as periodo_cobertura                              , DECODE(co.tipo_venc_inadimplencia, 1, 'Vencimento Prorrogado', 2, 'Vencimento Original') tipo_inadimplencia , co.cod_motivo_cancelamento as cod_motivo_canc_cobranca,nvl(substr(co.txt_obs_cancelamento,1,50),( select mcc.txt_motivo_cancelamento
                       from motivo_canc_cobranca mcc
                      where mcc.cod_motivo_cancelamento = co.cod_motivo_cancelamento )) as motivo_canc_cobranca, to_char(fa.dt_vencimento,'dd/mm/rrrr') as dt_vencimento_original,credit.txt_obs as txt_obs_baixa           from contrato_empresa      ce,                     cobranca              co,entidade_sistema      es,beneficiario_entidade bent,ciclo_faturamento     cf,tipo_ciclo            tc,tipo_cobranca         tcob,fatura                fa,operadora             op,sucursal              su,inspetoria            ip,tipo_baixa            tb,credito_recebido_sur  credit,cedente_sur           ced,cedente_sur           cedcc ,motivo_cancelamento   mot,grupo_empresa         ge,contrato_empresa      ce_ge,tipo_contrato         tcon,regra_empresa         rg,cms_equipe_vendas     eq,situacao_cobranca     sc,ppf_operadoras        ppf_op,situacao_contrato     scon,beneficiario          be,ppf_proposta          ppf,entidade_sistema      es_corr,corretor_venda        cov,pj_proposta           pj,entidade_sistema      es_corrPj,corretor_venda        covPj,regional              reg,situacao_associado    sass,beneficiario_entidade ent_bene,empresa_contrato enc,beneficiario_faturamento bf  where ce.cod_ts_contrato      = co.cod_ts_contrato                and ce.cod_titular_contrato = es.cod_entidade_ts(+)    and ce.cod_titular_contrato_pf = bent.cod_entidade_ts(+)    and co.num_ciclo_ts = cf.num_ciclo_ts    and cf.cod_tipo_ciclo = tc.cod_tipo_ciclo    and co.cod_tipo_cobranca = tcob.cod_tipo_cobranca    and co.num_seq_fatura_ts = fa.num_seq_fatura_ts(+)    and co.ind_tipo_baixa = tb.ind_tipo_baixa(+)    and co.cod_operadora = op.cod_operadora    and ce.cod_operadora_contrato = ppf_op.cod_operadora    and ce.ind_situacao = scon.ind_situacao    and co.dt_emissao is not null    and co.cod_ts = be.cod_ts (+)    and be.ind_situacao = sass.ind_situacao (+)    and co.cod_sucursal = su.cod_sucursal    and co.cod_inspetoria_ts = ip.cod_inspetoria_ts    and co.cod_banco         = ced.cod_banco(+)    and co.num_seq_cedente   = ced.num_seq_cedente(+)    and co.cod_banco_dcc     = cedcc.cod_banco(+)    and co.num_seq_cedente_dcc = cedcc.num_seq_cedente(+)    and ce.cod_cancelamento  = mot.cod_cancelamento(+)    and co.cod_grupo_empresa = ge.cod_grupo_empresa(+)    and ge.cod_ts_contrato = ce_ge.cod_ts_contrato(+)    and ce.cod_tipo_contrato = tcon.cod_tipo_contrato(+)    and ce.tipo_empresa = rg.tipo_empresa(+)    and ce.cod_equipe_posvenda = eq.cod_equipe_vendas(+)    and be.num_seq_proposta_ts = ppf.num_seq_proposta_ts(+)    and ppf.cod_produtor_ts = cov.cod_corretor_ts(+)    and cov.cod_entidade_ts = es_corr.cod_entidade_ts(+)    and ce.num_seq_proposta_pj_ts = pj.num_seq_proposta_pj_ts(+)    and pj.cod_produtor_ts = covPj.cod_corretor_ts(+)    and covPj.cod_entidade_ts = es_corrPj.cod_entidade_ts(+)    and ce.cod_regional       = reg.cod_regional(+)    and co.ind_estado_cobranca = sc.ind_estado_cobranca(+)    and ce.cod_ts_contrato = enc.cod_ts_contrato(+)    and be.cod_entidade_ts = ent_bene.cod_entidade_ts(+)    and be.cod_ts = bf.cod_ts(+)    and credit.num_seq_cobranca = co.num_seq_cobranca   and nvl(:pCodTipoContrato, 0) = 0   and nvl(:pCodTsContrato, 'X') = 'X'   and nvl(:pCodEntidadeTs, 0) = 0   and nvl(:pCodTs, 0) = 0   and nvl(:pCodPrestadorTs, 0) = 0   and nvl(:pCodTipoCobranca, 0) = 0   and nvl(:pIndTipoBaixa, 0) = 0   and nvl(:pDtIniEmissao,  'X') = 'X'   and nvl(:pDtFimEmissao,  'X') = 'X'   and nvl(:pDtIniVencimento,  'X') = 'X'   and nvl(:pDtFimVencimento,  'X') = 'X'   and nvl(:pDtIniPagamento,  'X') = 'X'   and nvl(:pDtFimPagamento,  'X') = 'X'   and nvl(:pDtIniLiquidacao,  'X') = 'X'   and nvl(:pDtFimLiquidacao,  'X') = 'X'   and nvl(:pDtIniCancelamento,  'X') = 'X'   and nvl(:pDtFimCancelamento,  'X') = 'X'   and co.dt_competencia >= to_date(:pDtIniCompetencia,'dd/mm/rrrr')   and co.dt_competencia <= to_date(:pDtFimCompetencia,'dd/mm/rrrr')   and nvl(:pNumSeqCobranca, 0) = 0   and nvl(:pNumSeqFaturaTs, 0) = 0   and nvl(:pCodBanco, 0) = 0   and nvl(:pCodTipoCiclo, 0) = 0   and nvl(:pNumCicloTs, 0) = 0   and nvl(:pSGrupoEmpresa, 'X') = 'X'   and ce.cod_operadora in ( select /*+cardinality( x  20 )*/  *
                                                                         from table(cast(top_utl_padrao.Split(:pCodOperadora ,',') as LST_VARCHAR_4K))x
                                                                       )   and ce.cod_sucursal in ( select /*+cardinality( x  20 )*/  *
                                                                         from table(cast(top_utl_padrao.Split(:pCodSucursal ,',') as LST_VARCHAR_4K))x
                                                                       )   and ce.cod_inspetoria_ts in ( select /*+cardinality( x  20 )*/  *
                                                                             from table(cast(top_utl_padrao.Split(:pCodInspetoriaTs ,',') as LST_VARCHAR_4K))x
                                                                       )   and ce.cod_operadora_contrato in ( select /*+cardinality( x  20 )*/  *
                                                                         from table(cast(top_utl_padrao.Split(:pCodOperadoraContrato ,',') as LST_VARCHAR_4K))x
                                                                       )   and nvl(:pIndTipoProduto, '3') = '3'   and nvl(:pIndTipoEmpresa, 0) = 0   and co.cod_ts is not null   and co.ind_tipo_cobranca in (1)  and (  ( co.dt_vencimento >= trunc(sysdate) and co.ind_estado_cobranca in ('0', '3') )  ) ) x order by 39, 7, 5 