select op.nom_operadora,
       pm.cod_plano,
       pm.nome_plano,
       ce.num_contrato_operadora,
       ic.mes_ano_ref,
      SUM(ic.val_item_cobranca) itemCobranca,
      SUM(ic.val_item_pagar) itemPagar
from ts.itens_cobranca ic
     join ts.beneficiario b on b.cod_ts = ic.cod_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
where ce.cod_operadora_contrato IN (97)--(11, 3, 5)
      --and b.nome_associado = 'AIRTON MARQUES DA SILVA JUNIOR'
      and ic.cod_tipo_rubrica IN (14,
8,
9,
10,
13,
17,
18,
19,
20,
2,
1,
177,
178,
179)
      and ic.mes_ano_ref between to_date('01/02/2021', 'dd/mm/yyyy') AND last_day('01/01/2022')
group by op.nom_operadora,
       pm.cod_plano,
       pm.nome_plano,
       ce.num_contrato_operadora,
       ic.mes_ano_ref
order by 1, 2, 3, 5, 4
