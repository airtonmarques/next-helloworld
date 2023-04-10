--Boleto para Titular
select distinct
       adm.nom_operadora administradora,
			 filial.nome_sucursal filial,
			 ce.num_contrato contrato,
       ce.num_contrato_operadora contrato_operadora,
			 op.nom_operadora Operadora,
			 b.cod_plano codigo_plano_medico,	
			 pm.nome_plano nome_plano_medico,
			 CASE WHEN ce.ind_tipo_produto = 1 
						THEN 'Médico'
            WHEN ce.ind_tipo_produto = 2
             THEN 'Dental'
       END AS tipo_produto,
			 es.nome_entidade entidade,	
		   b.num_associado numero_beneficiario,
			 be.nome_entidade nome_beneficiario,
			 b.ind_situacao situacao_beneficiario,
			 ce.ind_situacao situacao_contrato,
			 porte.nome_tipo_empresa porte_contrato,
			 f.num_fatura,
			 f.mes_ano_ref,
			 case when c.dt_vencimento_orig is null
              then c.dt_vencimento
            else c.dt_vencimento_orig
       end as vencimento_original,
			 c.dt_vencimento vencimento,
       c.dt_baixa data_pagamento,
			 (select sum(ic.val_item_cobranca) from ts.itens_cobranca ic 
			               where  ic.num_seq_cobranca = c.num_seq_cobranca and ic.num_ciclo_ts = c.num_ciclo_ts) valor_comercial,
       (select sum(ic.val_item_pagar) from ts.itens_cobranca ic 
			               where  ic.num_seq_cobranca = c.num_seq_cobranca and ic.num_ciclo_ts = c.num_ciclo_ts) valor_net,
       c.val_a_pagar,
			c.val_pago     
from ts.cobranca c
     join ts.fatura f on f.num_seq_fatura_ts = c.num_seq_fatura_ts
     join ts.beneficiario b on b.cod_ts = c.cod_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.sucursal filial on filial.cod_sucursal = ce.cod_sucursal
     join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
          and (b.cod_empresa is null OR ec.cod_entidade_ts = b.cod_empresa)
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
where f.mes_ano_ref between to_date('01/10/2022', 'dd/mm/yyyy') and last_day('01/12/2022')
      and c.cod_ts is not null
			and c.dt_cancelamento is null
      and c.dt_emissao is not null

union all
--Boleto para Empresa
select distinct
       adm.nom_operadora administradora,
       filial.nome_sucursal filial,
       ce.num_contrato contrato,
       ce.num_contrato_operadora contrato_operadora,
       op.nom_operadora Operadora,
       ' ' codigo_plano_medico, 
       ' ' nome_plano_medico,
       CASE WHEN ce.ind_tipo_produto = 1 
            THEN 'Médico'
            WHEN ce.ind_tipo_produto = 2
             THEN 'Dental'
       END AS tipo_produto,
       es.nome_entidade entidade, 
       ' ' numero_beneficiario,
       es.nome_razao_social nome_beneficiario,
       ' ' situacao_beneficiario,
       ce.ind_situacao situacao_contrato,
       porte.nome_tipo_empresa porte_contrato,
       f.num_fatura,
       f.mes_ano_ref,
       case when c.dt_vencimento_orig is null
              then c.dt_vencimento
            else c.dt_vencimento_orig
       end as vencimento_original,
       c.dt_vencimento vencimento,
       c.dt_baixa data_pagamento,
       (select sum(ic.val_item_cobranca) from ts.itens_cobranca ic 
                     where  ic.num_seq_cobranca = c.num_seq_cobranca and ic.num_ciclo_ts = c.num_ciclo_ts) valor_comercial,
       (select sum(ic.val_item_pagar) from ts.itens_cobranca ic 
                     where  ic.num_seq_cobranca = c.num_seq_cobranca and ic.num_ciclo_ts = c.num_ciclo_ts) valor_net,
			c.val_a_pagar,
			c.val_pago
            
from ts.cobranca c
     join ts.fatura f on f.num_seq_fatura_ts = c.num_seq_fatura_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = c.cod_ts_contrato
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.sucursal filial on filial.cod_sucursal = ce.cod_sucursal
     join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
     join ts.entidade_sistema es on es.cod_entidade_ts = ce.cod_titular_contrato
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
where f.mes_ano_ref between to_date('01/10/2022', 'dd/mm/yyyy') and last_day('01/12/2022')
      and c.dt_cancelamento is null
      and c.dt_emissao is not null
      and c.cod_ts is null
