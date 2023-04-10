select 
       decode(ce.cod_operadora, 1, 'AllCare SP', 3, 'AllCare DF') Administradora,
       o.nom_operadora,
       su.nome_sucursal,
       ins.nome_inspetoria,
       ce.num_contrato_editado,
       es.nome_entidade, 
       es.num_cgc,
       b.num_associado,
       b.nome_associado,
       b.data_exclusao,
       rub.nom_tipo_rubrica,
       lm.val_lancamento,
       lm.ind_debito_credito,
       lm.mes_ano_ref,
       lm.dt_lancamento,
       lm.txt_observacao,
       lm.num_lancamento_ts,
       f.num_fatura,
       lot.cod_lotacao,
       cob.dt_baixa,
       acao.num_processo
from ts.lancamento_manual lm
     join ts.tipo_rubrica_cobranca rub on rub.cod_tipo_rubrica = lm.cod_tipo_rubrica
     join ts.beneficiario b on b.cod_ts = lm.cod_ts
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
          and (b.cod_empresa is null OR ec.cod_entidade_ts = b.cod_empresa)
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.ppf_operadoras o on o.cod_operadora = ce.cod_operadora_contrato
     join ts.sucursal su on su.cod_sucursal = ce.cod_sucursal
     join ts.inspetoria ins on ins.cod_inspetoria_ts = ce.cod_inspetoria_ts
     left join ts.itens_cobranca ic on ic.num_item_cobranca_ts = lm.num_item_cobranca_ts
     left join ts.cobranca cob on cob.num_seq_cobranca = ic.num_seq_cobranca
     left join ts.fatura f on f.num_seq_fatura_ts = cob.num_seq_fatura_ts
     left join ts.acao_jud_pgto acao on acao.cod_ts = b.cod_ts_tit
     left join ts.lotacao lot on lot.cod_lotacao_ts = cob.cod_lotacao_ts
where lm.mes_ano_ref between to_date('01/02/2022', 'dd/mm/yyyy') and last_day('01/02/2022')
      --lm.mes_ano_ref >= to_date('01/10/2021', 'dd/mm/yyyy')
      and lm.cod_tipo_rubrica IN (16, 100, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268)
      --and o.cod_operadora = 73
order by 1, 2, 3, 14 
