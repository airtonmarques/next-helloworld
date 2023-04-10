select distinct o.nom_operadora Adm,
       op.nom_operadora,
       ce.cod_ts_contrato,
       ce.num_contrato,
       es.nome_entidade,
       ce.ind_situacao,
       cc.dt_ini_cobranca,
       cc.dt_proximo_reajuste,
       cc.mes_fixo_reajuste,
       cc.dt_ultimo_reajuste,
       cc.pct_ultimo_reajuste,
       cc.pct_desconto_financeiro,
       (select count(1) from ts.beneficiario b where b.cod_ts_contrato = ce.cod_ts_contrato and b.data_exclusao is null) vidas,
       cc.IND_ABATER_DESC_FATURA
from ts.contrato_empresa ce
     join ts.contrato_cobranca cc on cc.cod_ts_contrato = ce.cod_ts_contrato
     join ts.operadora o on o.cod_operadora = ce.cod_operadora
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
where cc.dt_ini_cobranca = (select max(dt_ini_cobranca) from ts.contrato_cobranca where cod_ts_contrato = ce.cod_ts_contrato)
     --and ce.num_contrato = '05138'
order by 1, 2, 5     
