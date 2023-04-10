
select distinct 
       ce.num_contrato,
			 b.cod_ts_tit familia,
       b.num_seq_matric_empresa seq,
			 b.data_inclusao,
			 b.tipo_associado,
       b.nome_associado,
			 lpad(be.num_cpf, 11, '0') cpf,
			 b.cod_plano,
			 b.num_associado_operadora,
			 c.val_a_pagar,
			 c.dt_emissao,
			 c.dt_vencimento,
			 c.dt_baixa,
			 c.dt_cancelamento
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.cobranca c on c.cod_ts = b.cod_ts_tit
where c.dt_baixa is null
      and c.dt_emissao is not null
      --and c.dt_cancelamento is null 
			and b.data_inclusao between to_date('01/12/2022', 'dd/mm/yyyy') and to_date('10/12/2022', 'dd/mm/yyyy')
      --and b.num_associado IN ('142280852')
and ce.num_contrato IN ('44789',
'44790',
'44791',
'44792',
'44793',
'44794',
'44795',
'44796',
'44797',
'44798',
'44799',
'44800',
'44801',
'44803',
'44804',
'44805',
'44806',
'44807',
'44808',
'44809',
'44810',
'44811',
'44812',
'44813',
'44814',
'44815',
'44816',
'44817',
'44818',
'44819',
'44820',
'44821',
'44822',
'44823',
'44824',
'44825',
'44826',
'44827',
'44828',
'44829',
'44788')
 
order by 1, 4, 2, 3
