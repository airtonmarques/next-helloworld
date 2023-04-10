 SELECT 
          'update ts.controle_carta set cod_ts = 1010672 where num_controle_carta_ts = ' || cc.num_controle_carta_ts || ';',
          ce.cod_titular_contrato,
                            NVL(ppf.num_proposta_adesao,ce.num_contrato),
                            NVL(re.ind_regra_dias_inadimplencia, 'C') ind_regra_dias,
                            cc.num_controle_carta_ts,
                            cc.cod_ts_contrato,
                            cc.cod_ts,
                            DECODE(tc.ind_tipo_carta, 15, 1, 18, 1, 16, 2, 19, 2, 62, 3) ind_tipo_carta,
                            cc.cod_produto,
                            p.nome_produto,
                            TO_CHAR(cc.dt_prazo_pagamento, 'dd/mm/RRRR') dt_cancelamento,
                            ass.cod_entidade_ts cod_entidade_ts_tit,
                            cc.cod_entidade_ts,
                            ce.cod_operadora,
                            cc.ind_aviso_rec,
                            ppf_op.nom_operadora,
                            pdt.nome_produto_ans,
                            case
                               when CE.IND_TIPO_PRODUTO = 1 and
                                    (select count(*)
                                       from associado_aditivo ad, aditivo adt
                                      where ad.cod_ts = cc.cod_ts
                                        and ad.cod_aditivo = adt.cod_aditivo
                                        and adt.cod_grupo_aditivo = 1) = 0 then
                                       'M'
                               when CE.IND_TIPO_PRODUTO = 1 and
                                    (select count(*)
                                       from associado_aditivo ad, aditivo adt
                                      where ad.cod_ts = cc.cod_ts
                                        and ad.cod_aditivo = adt.cod_aditivo
                                        and adt.cod_grupo_aditivo = 1) > 0 then
                                        'A'
                               when CE.IND_TIPO_PRODUTO = 2 then
                                        'D'
                                     end as tipo_plano,
                            nvl(be.num_cpf, '') num_cpf,
                            (select replace(replace(LISTAGG('(' || bc.num_ddd || ')' ||
                                       bc.num_telefone,
                                       ', ') WITHIN
                               GROUP(ORDER BY bc.cod_entidade_ts asc),
                               '(),',
                               ''),
                       '()',
                       '')
          from beneficiario_contato bc
         where bc.cod_entidade_ts = ass.cod_entidade_ts
           and bc.ind_class_contato in ('T', 'C')) as telefone,

       (select replace(replace(LISTAGG(bc.end_email, ', ') WITHIN
                               GROUP(ORDER BY bc.cod_entidade_ts asc),
                               '(),',
                               ''),
                       '()',
                       '')
          from beneficiario_contato bc
         where bc.cod_entidade_ts = ass.cod_entidade_ts
           and bc.ind_class_contato in ('E'))email
                       FROM controle_carta        cc
                          , contrato_empresa      ce
                          , regra_empresa         re
                          , produto               p
                          , associado             ass
                          , tipo_carta            tc
                          , ppf_proposta          ppf
                          , ppf_operadoras        ppf_op
                          , plano_medico          pm
                          , produto_ans           pdt
                          , beneficiario_entidade be
                      WHERE cc.cod_ts               = ass.cod_ts (+)
                        AND ass.num_seq_proposta_ts = ppf.num_seq_proposta_ts (+)
                        AND cc.cod_produto          = p.cod_produto(+)
                        AND ce.tipo_empresa         = re.tipo_empresa
                        AND cc.cod_ts_contrato      = ce.cod_ts_contrato
                        AND ce.cod_operadora_contrato = ppf_op.cod_operadora
                        AND cc.ind_tipo_carta       IN(15,16,18,19,62)
                        AND cc.ind_tipo_carta       = tc.ind_tipo_carta
                        AND ass.cod_plano           = pm.cod_plano (+)
                        AND pm.cod_produto_ans      = pdt.cod_produto_ans (+)
                        AND be.cod_entidade_ts(+)      = ass.cod_entidade_ts 
                        and cc.cod_ts is null
                        and CC.DT_EMISSAO is null ORDER BY ind_tipo_carta, cc.num_controle_carta_ts 
                        
