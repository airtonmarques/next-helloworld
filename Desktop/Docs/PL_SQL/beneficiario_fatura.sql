select f.mes_ano_ref,
       tc.nom_tipo_ciclo,
       f.num_fatura,
       f.dt_vencimento,
       c.num_seq_cobranca,
       f.val_fatura,
       c.val_a_pagar,
       c.dt_baixa,
       c.val_pago,
       c.num_linha_digitavel,
       rub.nom_tipo_rubrica,
       ic.val_item_cobranca,
       f.dt_ini_periodo,
       f.dt_fim_periodo,
       tcob.nome_tipo_cobranca
from ts.beneficiario b
     join ts.cobranca c on c.cod_ts = b.cod_ts_tit
     join ts.fatura f on f.num_seq_fatura_ts = c.num_seq_fatura_ts
     join ts.itens_cobranca ic on ic.num_seq_cobranca = c.num_seq_cobranca 
     join ts.tipo_rubrica_cobranca rub on rub.cod_tipo_rubrica = ic.cod_tipo_rubrica
     join ts.tipo_ciclo tc on tc.cod_tipo_ciclo = f.cod_tipo_ciclo
     join ts.tipo_cobranca tcob on tcob.cod_tipo_cobranca = c.cod_tipo_cobranca
where b.num_associado = 137715455     
order by 1      
     
