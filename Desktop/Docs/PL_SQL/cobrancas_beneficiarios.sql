--consegue uma extração de beneficiários 
--com data de exclusão mês 08/20 e que tenha mais de dois boletos em aberto? 
--ADM, Contrato, Operadora, Numero benef/ nome benef, fatura, cobrança, competência e valor?

select distinct  
       adm.nom_operadora,
       op.nom_operadora,
       ce.num_contrato,
       es.nome_entidade,
       b.num_associado,
       b.num_associado_operadora,
       b.nome_associado,
       f.num_fatura,
       c.num_seq_cobranca,
       f.mes_ano_ref,
       c.val_a_pagar
from ts.beneficiario b
     join ts.cobranca c on c.cod_ts = b.cod_ts
     join ts.fatura f on f.num_seq_fatura_ts = c.num_seq_fatura_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
where b.data_exclusao >= to_date('01/08/2020', 'dd/mm/yyyy') 
      and exists (select count(1) from ts.cobranca where cod_ts = b.cod_ts and dt_emissao is not null and dt_cancelamento is null and dt_baixa is null group by cod_ts having count(1) > 1)   
      and c.dt_emissao is not null
      and c.dt_cancelamento is null
      and c.dt_baixa is null
order by 1, 2, 4, 5, 8        
     

