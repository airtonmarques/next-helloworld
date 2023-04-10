insert into ts.associado_desconto(cod_ts,
                                  dt_ini_vigencia,
                                  dt_fim_vigencia,
                                  cod_tipo_desconto,
                                  pct_desconto,
                                  cod_usuario_inc,
                                  dt_registro_inc,
                                  cod_usuario_fim,
                                  dt_registro_fim,
                                  txt_observacao,
                                  cod_usuario_atu,
                                  dt_atu)
select distinct b.cod_ts,
                to_date('01/09/2022', 'dd/mm/yyyy'),
                --last_day('01/06/2021'),
                last_day('01/02/2023'),
                2,
                /*
                case pm.ind_participacao 
                  when 'S'
                  then 15
                    else 10 
                end,
                */
                20,
                'ACFARANIO',
                SYSDATE,
                'ACFARANIO',
                SYSDATE,
                'Desconto S1 PME SET/2022',
                'ACFARANIO',
                SYSDATE
from ts.beneficiario b
     --join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     --join ts.pj_proposta p on p.num_seq_proposta_pj_ts = ce.num_seq_proposta_pj_ts
where not exists (select 1
                  from ts.associado_desconto ad2
                  where ad2.cod_ts = b.cod_ts
                        and ad2.dt_ini_vigencia = to_date('01/09/2022', 'dd/mm/yyyy'))
and b.num_associado IN ()
--and p.num_proposta IN ()
