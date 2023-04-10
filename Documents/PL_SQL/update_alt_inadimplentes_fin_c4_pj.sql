update alt_inadimplentes_fin_c4 inad
       set inad.telefone_comercial = (select ts_consulta.sys_format_tel_fnc(55, cc.num_ddd, cc.num_telefone) 
                                      from ts.contrato_contato cc 
                                      where cc.cod_ts_contrato = inad.cod_ts_contrato
                                            and cc.num_seq_contato = 1
                                            and cc.num_ddd is not null and cc.num_telefone is not null
                                            and length(cc.num_ddd) > 0 and length(cc.num_telefone) > 0),
           inad.telefone_cobranca = (select ts_consulta.sys_format_tel_fnc(55, cc.num_ddd, cc.num_telefone) 
                                      from ts.contrato_contato cc 
                                      where cc.cod_ts_contrato = inad.cod_ts_contrato
                                            and cc.num_seq_contato = 2
                                            and cc.num_ddd is not null and cc.num_telefone is not null
                                            and length(cc.num_ddd) > 0 and length(cc.num_telefone) > 0),
           inad.email = (select txt_email_contato 
                                      from ts.contrato_contato cc 
                                      where cc.cod_ts_contrato = inad.cod_ts_contrato
                                            and cc.num_seq_contato = 1
                                            and cc.txt_email_contato is not null)
where inad.tipo_pessoa = 'PJ';
commit;

-------------------------------------------------------------------------------------------

update alt_inadimplentes_fin_c4 inad       
set (inad.fatura, inad.periodo_cobertura_inicial, inad.periodo_cobertura_final) = (select distinct f.num_fatura, f.dt_ini_periodo, f.dt_fim_periodo
                                                                                   from TS.fatura f 
                                                                                   where f.num_seq_fatura_ts = inad.num_seq_fatura_ts)
where inad.tipo_pessoa = 'PJ'; 
commit;
                 
-------------------------------------------------------------------------------------------                 
          
                                  

update alt_inadimplentes_fin_c4 inad
set inad.data_ultimo_pagamento = (select max(c.dt_baixa)
                                  from ts.cobranca c
                                  where c.dt_cancelamento is null
                                        and c.dt_baixa is not null
																				and c.cod_ts is null
																				and c.dt_emissao is not null
                                        and c.cod_ts_contrato = (select ce.cod_ts_contrato 
                                                                from ts.contrato_empresa ce 
                                                                where ce.cod_ts_contrato = inad.cod_ts_contrato))
where inad.tipo_pessoa = 'PJ';
commit;

-------------------------------------------------------------------------------------------                                      

update alt_inadimplentes_fin_c4 inad
set inad.data_ultima_competencia_paga = (select max(c.dt_competencia)
                                         from ts.cobranca c
                                         where c.dt_baixa is not null
                                               and c.dt_cancelamento is null
																							 and c.cod_ts is null
                                               and c.dt_emissao is not null
                                               and c.cod_ts_contrato = (select ce.cod_ts_contrato 
                                                                from ts.contrato_empresa ce 
                                                                where ce.cod_ts_contrato = inad.cod_ts_contrato))
where inad.tipo_pessoa = 'PJ';
commit;

-----------------------------------------------------------------------------------------

update alt_inadimplentes_fin_c4 inad
set inad.boletos_atrasados_total = (select count(1) 
                                    from ts.cobranca c 
                                    where c.dt_cancelamento is null
                                          and c.dt_baixa is null
                                          and c.dt_vencimento < trunc(sysdate)
																					and c.cod_ts is null
                                          and c.dt_emissao is not null
                                          and c.cod_ts_contrato = (select ce.cod_ts_contrato 
                                                                from ts.contrato_empresa ce 
                                                                where ce.cod_ts_contrato = inad.cod_ts_contrato))
where inad.tipo_pessoa = 'PJ';
commit;
               
-----------------------------------------------------------------------------------------               

update alt_inadimplentes_fin_c4 inad
set inad.telefone_contato = (select ts_consulta.sys_format_tel_fnc(55, to_number(ende.num_ddd_telefone_1), to_number(ende.num_telefone_1)) 
                                    from ts.enderecos ende 
                                    where ende.cod_entidade_ts = inad.cod_entidade_ts_tit
                                          and ende.num_ddd_telefone_1 is not null and ende.num_telefone_1 is not null
                                          and length(ende.num_ddd_telefone_1) > 0 and length(ende.num_telefone_1) > 0
                                          and rownum = 1)
where inad.tipo_pessoa = 'PJ'
      and inad.telefone_contato is null;
commit;
      
-----------------------------------------------------------------------------------------

update alt_inadimplentes_fin_c4 inad
set inad.boletos_pagos = (select count(1) 
                                    from ts.cobranca c 
                                    where c.cod_ts_contrato = inad.cod_ts_contrato
                                          and c.dt_cancelamento is null
                                          and c.dt_baixa is not null
                                          and c.dt_emissao is not null
																					and c.cod_ts is null)
where inad.tipo_pessoa = 'PJ';                
commit;
-----------------------------------------------------------------------------------------      

update alt_inadimplentes_fin_c4 inad
       set inad.acao_judicial = DECODE((SELECT COUNT(1)
                    FROM ts.acao_jud_pgto a
                   WHERE a.cod_ts_contrato IN (inad.cod_ts_contrato)
									       and a.cod_ts is null
                     AND SYSDATE BETWEEN a.DT_INI_ACAO AND
                         NVL(a.DT_FIM_ACAO, to_date('31/12/3000', 'DD/MM/YYYY'))),
                  0,
                  'NÃO POSSUI',
                  'POSSUI')
where inad.tipo_pessoa = 'PJ';
commit;
