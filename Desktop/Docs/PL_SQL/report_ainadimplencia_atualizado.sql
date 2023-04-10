--create table alt_inadimplentes_fin as 
--create table alt_inadimplentes_fin as
insert into alt_inadimplentes_fin
select distinct 
       adm.nom_operadora administradora,
       es.nome_entidade entidade,
       porte.nome_tipo_empresa porte,
       op.nom_operadora operadora,
       ce.num_contrato_operadora num_contrato_operadora,
       ce.num_contrato num_contrato_allcare,
       b.cod_ts cod_ts,
       b.cod_ts_tit cod_ts_tit,
       b.cod_entidade_ts_tit cod_entidade_ts_tit,
       b.cod_mig_tit familia_gndi, -- Dúvida
       decode(b.tipo_associado, 'T', 'Titular', 'P', 'Patrocinador', 'Dependente') tipo_associado,
       b.num_associado num_associado,
       b.num_associado_operadora marca_otica,
       null marca_otica_dental, --Deve ser feito update após inclusão na tabela
       (select b1.nome_associado from ts.beneficiario b1 where b1.cod_ts = b.cod_ts_tit) nome_titular,
       b.nome_associado nome_associado,
       be.nome_mae nome_mae,
       be.ind_sexo sexo,
       estcivil.nome_estado_civil estado_civil,
       lpad(be.num_cpf, 11, '0') cpf,
       be.num_identidade rg,
       be.data_nascimento data_nascimento,
       trunc(months_between(sysdate, be.data_nascimento) / 12) idade,
       p.dt_venda data_venda,
       b.data_inclusao data_inclusao,
       bc.data_adesao data_adesao,
       b.data_exclusao data_exclusao,
       exc.nome_motivo_exc_assoc motivo_exclusao,
       pm.nome_plano plano,
       decode(ce.ind_tipo_produto, 1, 'Médico', 2, 'Dental') tipo_produto,
       null acao_judicial, --Deve ser feito update após inclusão na tabela
       null data_ultima_suspensao, --Deve ser feito update após inclusão na tabela
       null data_reativacao, --Deve ser feito update após inclusão na tabela
       null data_envio_exclusao, --Deve ser feito update após inclusão na tabela
       null data_envio_suspensao, --Deve ser feito update após inclusão na tabela
       (select sum(ic.val_item_cobranca)
        from ts.itens_cobranca ic
        where ic.num_seq_cobranca = c.num_seq_cobranca
              and ic.cod_ts = b.cod_ts
              and ic.cod_aditivo is null
              and ic.val_item_pagar is not null) valor_comercial,
       (select sum(ic.val_item_pagar)
        from ts.itens_cobranca ic
        where ic.num_seq_cobranca = c.num_seq_cobranca
              and ic.cod_ts = b.cod_ts
              and ic.cod_aditivo is null
              and ic.val_item_pagar is not null) valor_net,
        null data_ultimo_pagamento, --Deve ser feito update após inclusão na tabela      
        to_char(c.dt_competencia, 'MM/YYYY') mes_referencia,
        decode(b.ind_situacao, 'A', 'Ativo','S', 'Suspenso', 'E', 'Excluído') AS Situacao,
        decode(b.ind_situacao,'A','1','S','2','E','3') ordem_situacao,
        bf.dia_vencimento dia_vencimento,
        ce.cod_operadora_contrato cod_operadora,
        ec.cod_entidade_ts cod_entidade_ts,
        ce.cod_sucursal cod_sucursal,
        nvl(td.nome_dependencia, 'Titular') parentesco,
        null data_inicio_aditivo, --Deve ser feito update após inclusão na tabela
        null data_fim_aditivo, --Deve ser feito update após inclusão na tabela
        null nome_aditivo, --Deve ser feito update após inclusão na tabela
        null valor_aditivo_titular, --Deve ser feito update após inclusão na tabela
        null valor_aditivo_dependente, --Deve ser feito update após inclusão na tabela
        null qtd_boletos_atraso,--Deve ser feito update após inclusão na tabela
        null status_financeiro, --Deve ser feito update após inclusão na tabela DECODE(QTDE_PARCELAS_ATRASO, 0, 'Adimplente', 'Inadimplente')
        DECODE(pm.ind_acomodacao, 'A', 'Apartamento', 'E', 'Enfermaria') Acomodacao,
        null telefone_contato,--Deve ser feito update após inclusão na tabela
       be.num_unico_saude cartao_nacional_saude,
       null cid,--Deve ser feito update após inclusão na tabela
       --null endereco_residencial,--Deve ser feito update após inclusão na tabela
       bc.cod_grupo_carencia grupo_carencia,
       ce.data_inicio_vigencia data_inicio_vigencia,
       null valor_comercial_odonto,--Deve ser feito update após inclusão na tabela
       null valor_net_odonto,--Deve ser feito update após inclusão na tabela
       null email,--Deve ser feito update após inclusão na tabela
       decode(pm.ind_participacao, 'S', 'Sim', 'Não') coparticipacao,
       null competencia_exclusao_suspensao,--Deve ser feito update após inclusão na tabela
       null data_ultimo_competecia_paga,--Deve ser feito update após inclusão na tabela
       p.num_proposta_adesao num_proposta,
       b.data_registro_inclusao data_registro_inclusao,
       null regra_suspensao_dias,--Deve ser feito update após inclusão na tabela
       null regra_exclusao_dias,--Deve ser feito update após inclusão na tabela
       (select count(1) from ts.beneficiario b1 where b1.cod_ts_tit = b.cod_ts_tit and b1.ind_situacao in ('A','S')) qtd_vidas, 
       null maior_idade,--Deve ser feito update após inclusão na tabela
       pm.cod_produto_ans cod_produto_ans,
       (select max(cc1.dt_proximo_reajuste) from ts.contrato_cobranca cc1 where cc1.cod_ts_contrato = ce.cod_ts_contrato) data_proximo_reajuste,
       c.dt_vencimento data_vencimento,
       trunc(sysdate - c.dt_vencimento) dias_atraso,
       null aviso_cancelamento,--Deve ser feito update após inclusão na tabela
       null num_parcela,--Deve ser feito update após inclusão na tabela
       corretorvenda.cod_corretor cod_corretor,
       corretor.nome_entidade nome_corretor,
       bf.num_cpf_resp_reemb cpf_responsavel_financeiro,
       bf.nome_resp_reemb nome_responsavel_financeiro,
       null cep,
       null municipio,
       null uf,
       null num_fatura,
       c.dt_vencimento_orig vencimento_original,
       c.val_a_pagar valor_fatura,
       corretoravenda.cod_corretor cod_corretora,
       corretora.nome_entidade nome_corretora,
       null telefone_residencial,
       null telefone_cobranca,
       null ciclo,
       c.num_seq_cobranca,
       c.num_seq_fatura_ts
       
    

from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.beneficiario_contrato bc on bc.cod_ts = b.cod_ts
     join ts.beneficiario_faturamento bf on bf.cod_ts = b.cod_ts_tit
     join ts.estado_civil estcivil  on estcivil.ind_estado_civil = be.ind_estado_civil
     join ts.cobranca c on c.cod_ts = b.cod_ts_tit
     join ts.ppf_proposta p on p.num_seq_proposta_ts = b.num_seq_proposta_ts
     join ts.situacao_cobranca sit on sit.ind_estado_cobranca = c.ind_estado_cobranca
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
          and (b.cod_empresa is null OR ec.cod_entidade_ts = b.cod_empresa)
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
     join ts.sucursal filial on filial.cod_sucursal = ce.cod_sucursal
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
     join ts.corretor_venda corretorvenda on corretorvenda.cod_corretor_ts = p.cod_vendedor_ts
     join ts.entidade_sistema corretor on corretor.cod_entidade_ts = corretorvenda.cod_entidade_ts
     join ts.corretor_venda corretoravenda on corretoravenda.cod_corretor_ts = p.cod_produtor_ts
     join ts.entidade_sistema corretora on corretora.cod_entidade_ts = corretoravenda.cod_entidade_ts     
     left join ts.tipo_dependencia td on td.cod_dependencia = b.cod_dependencia
     left join ts.motivo_exclusao_assoc exc on exc.cod_motivo_exc_assoc = bc.cod_motivo_exclusao

where b.tipo_associado in ('T')
      and c.dt_cancelamento is null
      and c.dt_baixa is null
      and c.dt_vencimento <= TRUNC (SYSDATE - 3);
