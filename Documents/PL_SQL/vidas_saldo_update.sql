update all_bene_saldo_partial bsp
set bsp.cod_ts_anterior = (select max(a.cod_ts)
                           from ts.associado a
                           where a.cod_ts_destino = bsp.cod_ts)
where bsp.lote_inclusao = '250520220900';
commit;

--Update MO Dental

update all_bene_saldo_partial bsp
set (bsp.mo_dental, bsp.nome_plano_dental) = (select aa.num_associado_operadora,
                                                       a.nom_aditivo
                                                from ts.associado_aditivo aa
                                                     join ts.aditivo a on a.cod_aditivo = aa.cod_aditivo
                                                where a.cod_tipo_rubrica IN (50)
                                                      and aa.num_associado_operadora is not null
                                                      and aa.cod_ts = bsp.cod_ts
                                                      and aa.dt_ini_vigencia = (select max(aa1.dt_ini_vigencia)
                                                                                from ts.associado_aditivo aa1
                                                                                where aa1.cod_ts = aa.cod_ts
                                                                                      and aa1.cod_aditivo = aa.cod_aditivo)
                                                      and rownum = 1)
where bsp.lote_inclusao = '250520220900';
commit;
----------------------------------------------------------------------------------------

update all_bene_saldo_partial bsp
set bsp.data_exclusao_anterior = (select max(b.data_exclusao)
                                from ts.beneficiario b
                                     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts                                
                                where be.num_cpf = to_number(bsp.cpf)
                                      and b.nome_associado = bsp.nome_associado
                                      and b.cod_ts <> bsp.cod_ts)
where bsp.lote_inclusao = '250520220900';

commit;

-------------------------------------------------------------------------------------      
update all_bene_saldo_partial bsp
set bsp.data_inclusao_futura = (select max(b.data_inclusao)
                                from ts.beneficiario b
                                     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts                                
                                where be.num_cpf = to_number(bsp.cpf)
                                      and b.nome_associado = bsp.nome_associado
                                      and b.cod_ts <> bsp.cod_ts
                                      and b.data_inclusao >= bsp.data_inclusao)
where bsp.lote_inclusao = '250520220900';
commit;

-------------------------------------------------------------------------------------
update all_bene_saldo_partial bsp
set bsp.data_primeiro_pagamento = (select min(c.dt_baixa)
                                   from ts.cobranca c
                                   where c.cod_ts = bsp.cod_ts_tit
                                         and c.dt_cancelamento is null
                                         and c.dt_emissao is not null
                                         and c.dt_baixa is not null)
where bsp.lote_inclusao = '250520220900';
commit;

-------------------------------------------------------------------------------------
update all_bene_saldo_partial bsp
set bsp.data_primeiro_pagamento = (select min(c.dt_baixa)
                                   from ts.cobranca c
                                   where c.cod_ts_contrato = bsp.cod_ts_contrato
                                         and c.dt_cancelamento is null
                                         and c.dt_emissao is not null
                                         and c.dt_baixa is not null
                                         and c.cod_ts is null)
where bsp.lote_inclusao = '250520220900'
      and bsp.data_primeiro_pagamento is null;
commit;


-------------------------------------------------------------------------------------
update all_bene_saldo_partial bsp
set bsp.boletos_atrasado = (select count(1)
                            from ts.cobranca c
                            where c.cod_ts = bsp.cod_ts_tit
                                  and c.dt_cancelamento is null
                                  and c.dt_emissao is not null
                                  and c.dt_vencimento < trunc(sysdate)
                                  and c.dt_baixa is null)
where bsp.lote_inclusao = '250520220900';
commit;
-------------------------------------------------------------------------------------

update all_bene_saldo_partial bsp
set bsp.boletos_atrasado = (select count(1)
                            from ts.cobranca c
                            where c.cod_ts_contrato = bsp.cod_ts_contrato
                                  and c.dt_cancelamento is null
                                  and c.dt_emissao is not null
                                  and c.dt_vencimento < trunc(sysdate)
                                  and c.dt_baixa is null
                                  and c.cod_ts is null)
where bsp.lote_inclusao = '250520220900'
      and (bsp.boletos_atrasado is null or bsp.boletos_atrasado = 0);
commit;

-------------------------------------------------------------------------------------      

update all_bene_saldo_partial bsp
       set bsp.acao_judicial = DECODE((SELECT COUNT(1)
                                               FROM ts.acao_jud_pgto a
                                               WHERE a.cod_ts IN (bsp.cod_ts, bsp.cod_ts_tit)
                                                     AND SYSDATE BETWEEN a.DT_INI_ACAO AND
                                                         NVL(a.DT_FIM_ACAO, to_date('31/12/3000', 'DD/MM/YYYY'))),
                  0,
                  'NÃO POSSUI',
                  'POSSUI')
where bsp.lote_inclusao = '250520220900';

commit;
