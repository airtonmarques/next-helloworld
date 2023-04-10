select DISTINCT
       t.Administradora,
       t.Operadora,
       t.Entidade,
       t.Filial,
       t.Competencia,
       t.Vencimento,
       t.Pagamento,
       t.codigoFamilia,
       t.TipoAssociado,
       t.numAssociado,
       t.Nome,
       t.Contrato,
       t.Desconto,
       SUM(t."COM Desconto Financeiro") "COM Desconto Financeiro",
       SUM(t."NET Desconto Financeiro") "NET Desconto Financeiro",
       SUM(t."COM Mens Titular FE Imp") "COM Mens Titular FE Imp",
       SUM(t."NET Mens Titular FE Imp") "NET Mens Titular FE Imp",
       SUM(t."COM Taxa Administrativa") "COM Taxa Administrativa",
       SUM(t."NET Taxa Administrativa") "NET Taxa Administrativa",
       SUM(t."COM Mens Dependente FE Imp") "COM Mens Dependente FE Imp",
       SUM(t."NET Mens Dependente FE Imp") "NET Mens Dependente FE Imp",
       SUM(t."COM Cob Inclusao Retro") "COM Cob Inclusao Retro",
       SUM(t."NET Cob Inclusao Retro") "NET Cob Inclusao Retro",
       SUM(t."COM Cob Retro") "COM Cob Retro",
       SUM(t."NET Cob Retro") "NET Cob Retro",
       
       SUM(t."COM Coparticipação 16") "COM Coparticipação 16",
       SUM(t."NET Coparticipação 16") "NET Coparticipação 16",
       SUM(t."COM Coparticipação 100") "COM Coparticipação 100",
       SUM(t."NET Coparticipação 100") "NET Coparticipação 100",
       
       SUM(t."COM Correção") "COM Correção",
       SUM(t."NET Correção") "NET Correção",
       SUM(t."COM Desconto") "COM Desconto",
       SUM(t."NET Desconto") "NET Desconto",
       SUM(t."COM Juros") "COM Juros",
       SUM(t."NET Juros") "NET Juros",
       SUM(t."COM Mens Agr FE Imp") "COM Mens Agr FE Imp",
       SUM(t."NET Mens Agr FE Imp") "NET Mens Agr FE Imp",
       SUM(t."COM Mensalidade Associativa") "COM Mensalidade Associativa",
       SUM(t."NET Mensalidade Associativa") "NET Mensalidade Associativa",
       SUM(t."COM Mens Dep FE") "COM Mens Dep FE",
       SUM(t."NET Mens Dep FE") "NET Mens Dep FE",
       SUM(t."COM Mens Dep PM") "COM Mens Dep PM",
       SUM(t."NET Mens Dep PM") "NET Mens Dep PM",
       SUM(t."COM Mensalidade Opcionais") "COM Mensalidade Opcionais",
       SUM(t."NET Mensalidade Opcionais") "NET Mensalidade Opcionais",
       SUM(t."COM Mens PF") "COM Mens PF",
       SUM(t."NET Mens PF") "NET Mens PF",
       SUM(t."COM Mens Titular FE") "COM Mens Titular FE",
       SUM(t."NET Mens Titular FE") "NET Mens Titular FE",
       SUM(t."COM Mens Titular PM") "COM Mens Titular PM",
       SUM(t."NET Mens Titular PM") "NET Mens Titular PM",
       SUM(t."COM Opcional Odontologico") "COM Opcional Odontologico",
       SUM(t."NET Opcional Odontologico") "NET Opcional Odontologico",
       SUM(t."COM Outros Produtos") "COM Outros Produtos",
       SUM(t."NET Outros Produtos") "NET Outros Produtos",
       SUM(t."COM Premio Agreg PM") "COM Premio Agreg PM",
       SUM(t."NET Premio Agreg PM") "NET Premio Agreg PM",
       SUM(t."COM Taxa de Cadastro") "COM Taxa de Cadastro",
       SUM(t."NET Taxa de Cadastro") "NET Taxa de Cadastro"
from
(select adm.nom_operadora Administradora,
       op.Nom_Operadora Operadora,
       es.nome_entidade Entidade,
       su.nome_sucursal Filial,
       c.dt_competencia Competencia,
       c.dt_vencimento Vencimento,
       c.dt_baixa Pagamento,
       b.cod_ts_tit codigoFamilia,
       b.tipo_associado TipoAssociado,
       b.num_associado numAssociado,
       b.nome_associado Nome,
       ce.num_contrato Contrato,
       (select cc.pct_desconto_financeiro
        from ts.contrato_cobranca cc
        where cc.cod_ts_contrato = ce.cod_ts_contrato
              and cc.dt_ini_cobranca = (select max(dt_ini_cobranca) from ts.contrato_cobranca where cod_ts_contrato = ce.cod_ts_contrato)) Desconto,

     (CASE WHEN rubrica.cod_tipo_rubrica = 145 THEN ic.val_item_cobranca ELSE 0 END) as "COM Desconto Financeiro",
     (CASE WHEN rubrica.cod_tipo_rubrica = 145 THEN ic.val_item_pagar ELSE 0 END) as "NET Desconto Financeiro",

     (CASE WHEN rubrica.cod_tipo_rubrica = 18 THEN ic.val_item_cobranca ELSE 0 END) as "COM Mens Titular FE Imp",
     (CASE WHEN rubrica.cod_tipo_rubrica = 18 THEN ic.val_item_pagar ELSE 0 END) as "NET Mens Titular FE Imp",

     (CASE WHEN rubrica.cod_tipo_rubrica = 46 THEN ic.val_item_cobranca ELSE 0 END) as "COM Taxa Administrativa",
     (CASE WHEN rubrica.cod_tipo_rubrica = 46 THEN ic.val_item_pagar ELSE 0 END) as "NET Taxa Administrativa",

     (CASE WHEN rubrica.cod_tipo_rubrica = 19 THEN ic.val_item_cobranca ELSE 0 END) as "COM Mens Dependente FE Imp",
     (CASE WHEN rubrica.cod_tipo_rubrica = 19 THEN ic.val_item_pagar ELSE 0 END) as "NET Mens Dependente FE Imp",
     ----------------------------------------------------------------
     
     (CASE WHEN rubrica.cod_tipo_rubrica = 27 THEN ic.val_item_cobranca ELSE 0 END) as "COM Cob Inclusao Retro",
     (CASE WHEN rubrica.cod_tipo_rubrica = 27 THEN ic.val_item_pagar ELSE 0 END) as "NET Cob Inclusao Retro",

     (CASE WHEN rubrica.cod_tipo_rubrica = 23 THEN ic.val_item_cobranca ELSE 0 END) as "COM Cob Retro",
     (CASE WHEN rubrica.cod_tipo_rubrica = 23 THEN ic.val_item_pagar ELSE 0 END) as "NET Cob Retro",

     (CASE WHEN rubrica.cod_tipo_rubrica = 16 THEN ic.val_item_cobranca ELSE 0 END) as "COM Coparticipação 16",
     (CASE WHEN rubrica.cod_tipo_rubrica = 16 THEN ic.val_item_pagar ELSE 0 END) as "NET Coparticipação 16",
     
     (CASE WHEN rubrica.cod_tipo_rubrica = 100 THEN ic.val_item_cobranca ELSE 0 END) as "COM Coparticipação 100",
     (CASE WHEN rubrica.cod_tipo_rubrica = 100 THEN ic.val_item_pagar ELSE 0 END) as "NET Coparticipação 100",

     (CASE WHEN rubrica.cod_tipo_rubrica = 12 THEN ic.val_item_cobranca ELSE 0 END) as "COM Correção",
     (CASE WHEN rubrica.cod_tipo_rubrica = 12 THEN ic.val_item_pagar ELSE 0 END) as "NET Correção",
     
     (CASE WHEN rubrica.cod_tipo_rubrica = 245 THEN ic.val_item_cobranca ELSE 0 END) as "COM Desconto",
     (CASE WHEN rubrica.cod_tipo_rubrica = 245 THEN ic.val_item_pagar ELSE 0 END) as "NET Desconto",
     
     (CASE WHEN rubrica.cod_tipo_rubrica = 115 THEN ic.val_item_cobranca ELSE 0 END) as "COM Juros",
     (CASE WHEN rubrica.cod_tipo_rubrica = 115 THEN ic.val_item_pagar ELSE 0 END) as "NET Juros",
     
     (CASE WHEN rubrica.cod_tipo_rubrica = 115 THEN ic.val_item_cobranca ELSE 0 END) as "COM Mens Agr FE Imp",
     (CASE WHEN rubrica.cod_tipo_rubrica = 115 THEN ic.val_item_pagar ELSE 0 END) as "NET Mens Agr FE Imp",
     
     (CASE WHEN rubrica.cod_tipo_rubrica = 45 THEN ic.val_item_cobranca ELSE 0 END) as "COM Mensalidade Associativa",
     (CASE WHEN rubrica.cod_tipo_rubrica = 45 THEN ic.val_item_pagar ELSE 0 END) as "NET Mensalidade Associativa",
     
     (CASE WHEN rubrica.cod_tipo_rubrica = 8 THEN ic.val_item_cobranca ELSE 0 END) as "COM Mens Dep FE",
     (CASE WHEN rubrica.cod_tipo_rubrica = 8 THEN ic.val_item_pagar ELSE 0 END) as "NET Mens Dep FE",
     
     (CASE WHEN rubrica.cod_tipo_rubrica = 14 THEN ic.val_item_cobranca ELSE 0 END) as "COM Mens Dep PM",
     (CASE WHEN rubrica.cod_tipo_rubrica = 14 THEN ic.val_item_pagar ELSE 0 END) as "NET Mens Dep PM",
     
     (CASE WHEN rubrica.cod_tipo_rubrica = 10 THEN ic.val_item_cobranca ELSE 0 END) as "COM Mensalidade Opcionais",
     (CASE WHEN rubrica.cod_tipo_rubrica = 10 THEN ic.val_item_pagar ELSE 0 END) as "NET Mensalidade Opcionais",
     
     (CASE WHEN rubrica.cod_tipo_rubrica = 1 THEN ic.val_item_cobranca ELSE 0 END) as "COM Mens PF",
     (CASE WHEN rubrica.cod_tipo_rubrica = 1 THEN ic.val_item_pagar ELSE 0 END) as "NET Mens PF",

     (CASE WHEN rubrica.cod_tipo_rubrica = 2 THEN ic.val_item_cobranca ELSE 0 END) as "COM Mens Titular FE",
     (CASE WHEN rubrica.cod_tipo_rubrica = 2 THEN ic.val_item_pagar ELSE 0 END) as "NET Mens Titular FE",
     
     (CASE WHEN rubrica.cod_tipo_rubrica = 13 THEN ic.val_item_cobranca ELSE 0 END) as "COM Mens Titular PM",
     (CASE WHEN rubrica.cod_tipo_rubrica = 13 THEN ic.val_item_pagar ELSE 0 END) as "NET Mens Titular PM",
     -----------------------------
     
     (CASE WHEN rubrica.cod_tipo_rubrica = 50 THEN ic.val_item_cobranca ELSE 0 END) as "COM Opcional Odontologico",
     (CASE WHEN rubrica.cod_tipo_rubrica = 50 THEN ic.val_item_pagar ELSE 0 END) as "NET Opcional Odontologico",
     
     (CASE WHEN rubrica.cod_tipo_rubrica = 60 THEN ic.val_item_cobranca ELSE 0 END) as "COM Outros Produtos",
     (CASE WHEN rubrica.cod_tipo_rubrica = 60 THEN ic.val_item_pagar ELSE 0 END) as "NET Outros Produtos",
     
     (CASE WHEN rubrica.cod_tipo_rubrica = 15 THEN ic.val_item_cobranca ELSE 0 END) as "COM Premio Agreg PM",
     (CASE WHEN rubrica.cod_tipo_rubrica = 15 THEN ic.val_item_pagar ELSE 0 END) as "NET Premio Agreg PM",
     
     (CASE WHEN rubrica.cod_tipo_rubrica = 4 THEN ic.val_item_cobranca ELSE 0 END) as "COM Taxa de Cadastro",
     (CASE WHEN rubrica.cod_tipo_rubrica = 4 THEN ic.val_item_pagar ELSE 0 END) as "NET Taxa de Cadastro",
       
       --rubrica.nom_tipo_rubrica rubrica,
       --ic.val_item_cobranca val_com,
       --ic.val_item_pagar val_net,
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
      --and b.cod_ts_tit = 968540
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
          b.cod_ts,
          rubrica.cod_tipo_rubrica,
          ic.val_item_cobranca,
          ic.val_item_pagar,
          f.num_fatura*/
) t
group by t.Administradora,
       t.Operadora,
       t.Entidade,
       t.Filial,
       t.Competencia,
       t.Vencimento,
       t.Pagamento,
       t.codigoFamilia,
       t.TipoAssociado,
       t.numAssociado,
       t.Nome,
       t.Contrato,
       t.Desconto   
--order by 1, 2, 3, 4, 5, 8, 9 desc, 14
