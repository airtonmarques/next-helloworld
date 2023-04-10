

select distinct 
       o.nom_operadora Adm,
       op.nom_operadora Operadora,
       su.nome_sucursal Filial,
       'Grupo' Grupo,     
       es.nome_entidade,
       ce.cod_ts_contrato, 
       ce.num_contrato,
       (select count(1) from ts.beneficiario where cod_ts_tit = b.cod_ts) vidas,
       cc.dt_ultimo_reajuste,
       cc.pct_desconto_financeiro,
       porte.nome_tipo_empresa,
       tc.nome_tipo_contrato,
       b.num_associado,
       b.nome_associado,
       f.num_fatura,
       'Nota Fiscal',
       c.num_seq_cobranca,
       ciclo.nom_tipo_ciclo Ciclo,
       f.mes_ano_ref,
       c.dt_vencimento,
       c.dt_emissao,
       c.dt_baixa,
       (select sum(ic.val_item_cobranca) from ts.itens_cobranca ic where ic.cod_tipo_rubrica IN (14, 8, 9, 13, 18, 19, 20, 2) and ic.cod_ts = b.cod_ts and ic.mes_ano_ref = to_date('01/09/2020', 'dd/mm/yyyy')) Taxa_Medico,
       (select sum(ic.val_item_cobranca) from ts.itens_cobranca ic where ic.cod_tipo_rubrica = 50 and ic.cod_ts = b.cod_ts and ic.mes_ano_ref = to_date('01/09/2020', 'dd/mm/yyyy')) Taxa_Dental,
       (select sum(ic.val_item_cobranca) from ts.itens_cobranca ic where ic.cod_tipo_rubrica = 46 and ic.cod_ts = b.cod_ts and ic.mes_ano_ref = to_date('01/09/2020', 'dd/mm/yyyy')) Taxa_Adm,
       (select sum(ic.val_item_cobranca) from ts.itens_cobranca ic where ic.cod_tipo_rubrica = 45 and ic.cod_ts = b.cod_ts and ic.mes_ano_ref = to_date('01/09/2020', 'dd/mm/yyyy')) Taxa_Associativa,
       f.val_fatura,
       b.ind_situacao situacao_beneficiario,
       b.data_exclusao exclusao_beneficiario       
from ts.beneficiario b
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.sucursal su on su.cod_sucursal = ce.cod_sucursal
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.contrato_cobranca cc on cc.cod_ts_contrato = ce.cod_ts_contrato
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.operadora o on o.cod_operadora = ce.cod_operadora
     join ts.tipo_contrato tc on tc.cod_tipo_contrato = ce.cod_tipo_contrato
     left join ts.fatura f on f.cod_ts = b.cod_ts
     left join ts.cobranca c on c.num_seq_fatura_ts = f.num_seq_fatura_ts
     left join ts.tipo_ciclo ciclo on ciclo.cod_tipo_ciclo = f.cod_tipo_ciclo
where b.tipo_associado = 'T'
      and cc.dt_ini_cobranca = (select max(dt_ini_cobranca) from ts.contrato_cobranca where cod_ts_contrato = ce.cod_ts_contrato)
order by 1, 2, 3, 5
 
