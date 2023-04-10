select adm.nom_operadora Administradora,
       op.Nom_Operadora Operadora,
       es.nome_entidade Entidade,
       su.nome_sucursal Filial,
       c.dt_competencia Competencia,
       c.dt_vencimento Vencimento,
       c.dt_baixa Pagamento,
       b.cod_ts_tit codigoFamilia,
       b.tipo_associado,
       b.num_associado,
       b.nome_associado,
       ce.num_contrato Contrato,
       (select cc.pct_desconto_financeiro
        from ts.contrato_cobranca cc
        where cc.cod_ts_contrato = ce.cod_ts_contrato
              and cc.dt_ini_cobranca = (select max(dt_ini_cobranca) from ts.contrato_cobranca where cod_ts_contrato = ce.cod_ts_contrato)) Desconto,
       rubrica.nom_tipo_rubrica rubrica,
       ic.val_item_cobranca val_com,
       ic.val_item_pagar val_net,
       f.num_fatura
from ts.cobranca c
     join ts.itens_cobranca ic on ic.num_seq_cobranca = c.num_seq_cobranca and ic.num_ciclo_ts = c.num_ciclo_ts
     join ts.fatura f on f.num_seq_fatura_ts = c.num_seq_fatura_ts
     join ts.tipo_rubrica_cobranca rubrica on rubrica.cod_tipo_rubrica = ic.cod_tipo_rubrica
     join ts.contrato_empresa ce on ce.cod_ts_contrato = c.cod_ts_contrato
     join ts.beneficiario b on b.cod_ts_contrato = ce.cod_ts_contrato
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
     join ts.sucursal su on su.cod_sucursal = ce.cod_sucursal
     left join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
     left join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
where c.dt_cancelamento is null
      and c.dt_emissao is not null
      and c.dt_competencia between to_date('01/11/2020', 'dd/mm/yyyy') and to_date('30/11/2020', 'dd/mm/yyyy')
      and b.cod_ts = ic.cod_ts
/*group by adm.nom_operadora,
         op.Nom_Operadora,
         es.nome_entidade,
         su.nome_sucursal,
         c.dt_competencia,
         c.dt_vencimento,
         c.dt_baixa,
         c.val_multa,
         c.val_acrescimo,
         c.num_seq_cobranca,
         ce.cod_ts_contrato,
         b.cod_ts_tit,
         b.tipo_associado,
         b.num_associado,
         b.nome_associado,
         ce.num_contrato,
          b.cod_ts*/
order by 1, 2, 3, 4, 5, 8, 9 desc, 14
