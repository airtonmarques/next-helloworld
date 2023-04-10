select * from ts.concessao_contrato cc
where cc.cod_ts = 1154588 for update
--

insert into ts.concessao_contrato(cod_concessao,
                                  cod_ts_contrato,
                                  num_contrato,
                                  cod_operadora,
                                  cod_rede_contrato,
                                  ind_tipo_esp,
                                  ind_tipo_concessao,
                                  dt_ini_validade,
                                  dt_fim_validade,
                                  dt_atu,
                                  cod_usuario_atu,
                                  txt_obs_concessao,
                                  cod_plano,
                                  cod_ts,
                                  ind_tipo_valor,
                                  val_per_capita,
                                  dt_proximo_reajuste,
                                  val_pagar_tit)
select ts_concessao_contrato_seq.nextval,
       b.cod_ts_contrato,
       ce.num_contrato,
       ce.cod_operadora_contrato,
       9999,
       'B',
       4,
       to_date('01/12/2020', 'dd/mm/yyyy'),
       to_date('31/12/2020', 'dd/mm/yyyy'),
       sysdate,
       'VCGAMAS',
       'Venda Nova - sem deconto de faixa etária',
       b.cod_plano,
       b.cod_ts,
       2,
       234.21,
       to_date('01/01/2021', 'dd/mm/yyyy'),
       192.05
from ts.beneficiario b 
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
where b.num_associado = 139154612                                  
