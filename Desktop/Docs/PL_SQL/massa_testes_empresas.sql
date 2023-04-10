select distinct es.num_cgc cnpj,
       es.nome_entidade Empresa,
       ce.num_contrato codigo_allsys,
       ce.data_inicio_vigencia,
       ce.data_fim_vigencia,
       (select count(1)
        from ts.cobranca c
        where c.cod_ts_contrato = ce.cod_ts_contrato
              and c.dt_baixa is null
              and c.dt_vencimento <= (sysdate-10)) boletos_vencidos_10_dias,
       (select count(1)
        from ts.cobranca c
        where c.cod_ts_contrato = ce.cod_ts_contrato
              and c.dt_baixa is null
              and c.dt_vencimento between (sysdate-10) and sysdate) boletos_vencidos_menos_10_dias,
       (select count(1)
        from ts.beneficiario b
        where b.cod_ts_contrato = ce.cod_ts_contrato
              and b.data_exclusao is null) vidas_ativas,
       ((select count(1)
        from ts.beneficiario b
        where b.cod_ts_contrato = ce.cod_ts_contrato
              and b.data_exclusao is not null)) vidas_excluidas,
      nvl(ce.ind_efaturamento, 'N') boleto_sustentavel,
      (select max(cc.dt_ini_cobranca)
       from ts.contrato_cobranca cc
       where cc.cod_ts_contrato = ce.cod_ts_contrato) ultimo_reajuste
from ts.contrato_empresa ce
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
where ec.cod_entidade_ts IN (1009229,
1204485,
1187206,
1204415,
54348)
order by 2
