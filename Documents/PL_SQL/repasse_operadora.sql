CREATE VIEW REPASSE_OP_VIEW

AS
select distinct acao.cod_ts acao_judicial, 
       adm.nom_operadora administradora,
       aa.cod_aditivo codigo_plano_dental,
       b.cod_plano codigo_plano_medico,
       ce.num_contrato contrato,
       ce.num_contrato_operadora contrato_operadora,
       lpad(be.num_cpf, 11, '0') CPF,
       b.data_fim_suspensao data_ultima_reativacao,
       b.data_inclusao data_inclusao,
       be.data_nascimento,
       b.data_inclusao data_vigencia,
       b.data_exclusao data_exclusao,
       b.data_suspensao data_suspensao,
       es.nome_entidade entidade,
       f.num_fatura fatura,
       filial.nome_sucursal filial,
       sys_get_idade_fnc(be.data_nascimento, sysdate) idade,
       aa.num_associado_operadora mo_dental,
       b.num_associado_operadora mo_medico,
       f.mes_ano_ref mes_ano,
       exc.nome_motivo_exc_assoc motivo_exclusao,
       be.nome_entidade nome_beneficiario,
       ad.nom_aditivo nome_plano_dental,
       pm.nome_plano nome_plano_medico,
       b.num_associado numero_beneficiario,
       op.nom_operadora Operadora,
       ciclo.dt_ini_vigencia periodo_cobertura_inicial,
       ciclo.dt_fim_vigencia periodo_cobertura_final,
       porte.nome_tipo_empresa porte_contrato,
       b.ind_situacao situacao,
       ce.ind_situacao situacao_contrato,
       tipociclo.nom_tipo_ciclo ciclo,
       b.tipo_associado tipo_beneficiario,
       '' tipo_produto,
       (select sum(ic.val_item_cobranca) from ts.itens_cobranca ic where ic.cod_ts = b.cod_ts and ic.cod_tipo_rubrica IN (50) and ic.mes_ano_ref = ciclo.mes_ano_ref and ic.num_seq_cobranca = c.num_seq_cobranca) as valor_comercial_dental,
       (select sum(ic.val_item_cobranca) from ts.itens_cobranca ic where ic.cod_ts = b.cod_ts and ic.cod_tipo_rubrica IN (8, 14, 2, 13, 18, 19) and ic.mes_ano_ref = ciclo.mes_ano_ref and ic.num_seq_cobranca = c.num_seq_cobranca) as valor_comercial_medico,
       (select sum(ic.val_item_pagar) from ts.itens_cobranca ic where ic.cod_ts = b.cod_ts and ic.cod_tipo_rubrica IN (50) and ic.mes_ano_ref = ciclo.mes_ano_ref and ic.num_seq_cobranca = c.num_seq_cobranca) as valor_net_dental,
       (select sum(ic.val_item_pagar) from ts.itens_cobranca ic where ic.cod_ts = b.cod_ts and ic.cod_tipo_rubrica IN (8, 14, 2, 13, 18, 19) and ic.mes_ano_ref = ciclo.mes_ano_ref and ic.num_seq_cobranca = c.num_seq_cobranca) as valor_net_medico,
       b.data_inclusao Vigencia,
       dep.nome_dependencia Dependencia,
       be.ind_sexo
from ts.beneficiario b
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.sucursal filial on filial.cod_sucursal = ce.cod_sucursal
     join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.fatura f on f.cod_ts_contrato = ce.cod_ts_contrato and f.cod_ts = b.cod_ts
     join ts.cobranca c on c.num_seq_fatura_ts = f.num_seq_fatura_ts
     join ts.ciclo_faturamento ciclo on ciclo.num_ciclo_ts = f.num_ciclo_ts
     join ts.tipo_ciclo tipociclo on tipociclo.cod_tipo_ciclo = f.cod_tipo_ciclo
     join ts.beneficiario_contrato bc on bc.cod_ts = b.cod_ts
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
     left join ts.tipo_dependencia dep on dep.cod_dependencia = b.cod_dependencia
     left join ts.acao_jud_pgto acao on acao.cod_ts = b.cod_ts
     left join ts.associado_aditivo aa on aa.cod_ts = b.cod_ts
     left join ts.aditivo ad on ad.cod_aditivo = aa.cod_aditivo
     left join ts.motivo_exclusao_assoc exc on exc.cod_motivo_exc_assoc = bc.cod_motivo_exclusao
where c.dt_emissao is not null
      and c.dt_cancelamento is null
      and f.dt_emissao is not null
      and f.dt_cancelamento is null
ORDER BY  f.mes_ano_ref      
      ;
