select  
  a.data_adesao Vigencia,  
  a.cod_ts_tit Familia,
  a.num_matric_empresa Matricula,
  a.ind_situacao situacao,
  A.nome_associado Nome,
  be.data_nascimento,
  sys_get_idade_fnc(be.data_nascimento, sysdate) idade,
  BE.NUM_CPF CPF,
  case when a.cod_dependencia is null then 'Titular'
    else dep.nome_dependencia 
  end as Parentesco,
  case when itens.cod_aditivo is null then pm.nome_plano 
    else ad.nom_aditivo 
  end as Produto,
  op.nom_operadora Operadora,
  extract(month from c.dt_competencia) as Competencia,
  f.dt_vencimento Vencimento,
  c.dt_baixa Pagamento,
  c.val_pago Valor_Pago,
  itens.val_item_cobranca Valor_Mensalidade,
  f.val_fatura Valor_Familia,
  pm.cod_registro_ans ANS,
  a.data_exclusao,
  exc.nome_motivo_exc_assoc
from ts.associado a
join ts.contrato_empresa ce on ce.cod_ts_contrato = a.cod_ts_contrato
join ts.entidade_sistema es on es.cod_entidade_ts = ce.cod_titular_contrato
join ts.beneficiario_entidade be on be.cod_entidade_ts = a.cod_entidade_ts
join ts.cobranca c on c.cod_ts = a.cod_ts_tit
join ts.fatura f on f.num_seq_fatura_ts = c.num_seq_fatura_ts
join ts.itens_cobranca itens on itens.num_seq_cobranca = c.num_seq_cobranca and itens.Cod_Ts = a.cod_ts
join TS.PLANO_MEDICO pm on pm.cod_plano = a.cod_plano
join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
left join ts.tipo_dependencia dep on dep.cod_dependencia = a.cod_dependencia
left join ts.aditivo ad on ad.cod_aditivo = itens.cod_aditivo
left join ts.motivo_exclusao_assoc exc on exc.cod_motivo_exc_assoc = a.cod_motivo_exclusao
where c.dt_cancelamento is null
  and c.dt_emissao is not null
  and c.dt_baixa BETWEEN to_date('18/02/2022', 'dd/mm/yyyy') AND  to_date('18/03/2022', 'dd/mm/yyyy')  
  and (ce.num_contrato = 24397) 
  and itens.cod_tipo_rubrica not in (16, 100) --Exclui os itens de mensalidade
  and (a.tipo_associado = 'T' OR a.cod_dependencia NOT IN (3, 21, 20, 35, 29) OR
      (sys_get_idade_fnc(be.data_nascimento, last_day(c.dt_baixa))) <= 24 and a.cod_dependencia IN (3, 21, 20, 35, 29)) --Dependentes apenas menores de 24 anos
order by 2, 9 desc
