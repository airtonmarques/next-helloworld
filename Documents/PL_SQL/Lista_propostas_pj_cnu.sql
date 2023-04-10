select distinct su.nome_sucursal Filial,
       prop.dt_inicio_vigencia Vigencia,
       prop.dt_venda Venda,
       es.nome_razao_social Empresa,
       es.num_cgc CNPJ,
       prop.val_total_geral Valor,
       op.nom_operadora Operadora,
       porte.nome_tipo_empresa Porte,
       tv.nom_tipo_venda tipoVenda,
       prop.qtd_beneficiarios vidas,
       ce.cod_operadora,
       prop.num_proposta,
       ce.num_contrato num_contrato_interno,
       ce.num_contrato_operadora num_contrato_operadora,
       ce.ind_situacao
from ts.contrato_empresa ce
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.sucursal su on su.cod_sucursal = ce.cod_sucursal
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     left join ts.pj_proposta prop on prop.num_seq_proposta_pj_ts = ce.num_seq_proposta_pj_ts
     left join ts.tipo_venda tv on tv.cod_tipo_venda = prop.cod_tipo_venda
where ce.cod_operadora_contrato = 67
order by 1, 2
