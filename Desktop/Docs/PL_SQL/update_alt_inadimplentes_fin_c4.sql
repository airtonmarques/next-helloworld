update alt_inadimplentes_fin_c4 inad
       set inad.telefone_comercial = SYS_GET_TEL_FNC(inad.cod_entidade_ts_tit, 'C'),
           inad.telefone_residencial = SYS_GET_TEL_FNC(inad.cod_entidade_ts_tit, 'R'),
           inad.telefone_cobranca = SYS_GET_TEL_FNC(inad.cod_entidade_ts_tit, 'B'),
           inad.email = ts_consulta.all_get_mail_fnc(inad.cod_entidade_ts_tit),
           inad.acao_judicial = DECODE((SELECT COUNT(1)
                    FROM ts.acao_jud_pgto a
                   WHERE a.cod_ts IN (inad.cod_ts, inad.cod_ts_tit)
                     AND SYSDATE BETWEEN a.DT_INI_ACAO AND
                         NVL(a.DT_FIM_ACAO, to_date('31/12/3000', 'DD/MM/YYYY'))),
                  0,
                  'NÃO POSSUI',
                  'POSSUI')
where inad.tipo_pessoa = 'PF';
commit;
-------------------------------------------------------------------------------------------

update alt_inadimplentes_fin_c4 inad       
set (inad.fatura, inad.periodo_cobertura_inicial, inad.periodo_cobertura_final) = (select distinct f.num_fatura, f.dt_ini_periodo, f.dt_fim_periodo
                       from TS.fatura f 
                 where f.num_seq_fatura_ts = inad.num_seq_fatura_ts)
where inad.tipo_pessoa = 'PF';                  
commit;                 
-------------------------------------------------------------------------------------------                 
          
update alt_inadimplentes_fin_c4 inad       
set (inad.mo_dental, inad.nome_plano_dental) = (select aa.num_associado_operadora,
                                                       a.nom_aditivo
                                                from ts.associado_aditivo aa
                                                     join ts.aditivo a on a.cod_aditivo = aa.cod_aditivo
                                                where a.cod_tipo_rubrica IN (50)
                                                      and aa.num_associado_operadora is not null
                                                      and aa.cod_ts = inad.cod_ts
                                                      and aa.dt_ini_vigencia = (select max(aa1.dt_ini_vigencia)
                                                                                from ts.associado_aditivo aa1
                                                                                where aa1.cod_ts = aa.cod_ts
                                                                                      and aa1.cod_aditivo = aa.cod_aditivo)
                                                      and rownum = 1)
where inad.tipo_pessoa = 'PF';                                                      
commit;                                     
-------------------------------------------------------------------------------------------                                      

update alt_inadimplentes_fin_c4 inad
set inad.data_ultimo_pagamento = (select max(c.dt_baixa)
                                  from ts.cobranca c
                                  where c.dt_cancelamento is null
                                        and c.dt_baixa is not null
                                        and c.dt_emissao is not null
                                        and c.cod_ts = inad.cod_ts_tit)
where inad.tipo_pessoa = 'PF';                                        
commit;
-------------------------------------------------------------------------------------------                                      

update alt_inadimplentes_fin_c4 inad
set inad.data_ultima_competencia_paga = (select max(c.dt_competencia)
                                         from ts.cobranca c
                                         where c.cod_ts = inad.cod_ts_tit
                                               and c.dt_baixa is not null
                                               and c.dt_emissao is not null
                                               and c.dt_cancelamento is null)
where inad.tipo_pessoa = 'PF';                                               
commit;

-----------------------------------------------------------------------------------------

update alt_inadimplentes_fin_c4 inad
set inad.boletos_atrasados_total = (select count(1) 
                                    from ts.cobranca c 
                                    where c.cod_ts = inad.cod_ts_tit
                                          and c.dt_cancelamento is null
                                          and c.dt_baixa is null
                                          and c.dt_emissao is not null
                                          and c.dt_vencimento < trunc(sysdate))
where inad.tipo_pessoa = 'PF';                                          
commit;               
-----------------------------------------------------------------------------------------               

-----------------------------------------------------------------------------------------

update alt_inadimplentes_fin_c4 inad
set inad.boletos_pagos = (select count(1) 
                                    from ts.cobranca c 
                                    where c.cod_ts = inad.cod_ts_tit
                                          and c.dt_cancelamento is null
                                          and c.dt_baixa is not null
                                          and c.dt_emissao is not null)
where inad.tipo_pessoa = 'PF';                
commit;
-----------------------------------------------------------------------------------------                   
