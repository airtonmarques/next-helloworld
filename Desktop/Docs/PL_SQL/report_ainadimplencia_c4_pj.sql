--create table alt_inadimplentes_fin as 
--create table alt_inadimplentes_fin as
--create table alt_inadimplentes_fin_c4 as
insert into alt_inadimplentes_fin_c4
select distinct 
       null acao_judicial, --Deve ser feito update ap�s inclus�o na tabela
       adm.nom_operadora administradora,
       ce.num_contrato contrato,
       ce.num_contrato_operadora contrato_operadora,
       es.num_cgc cpf_cnpj,
       null data_inclusao,
       null data_nascimento,
       ce.data_inicio_vigencia data_inicio_vigencia,
       null data_adesao,
       null data_exclusao,
       es.nome_entidade entidade,
       null fatura,
       filial.nome_sucursal filial,
       null idade,
       null mo_medico,
       null mo_dental,
       to_char(c.dt_competencia, 'MM/YYYY') mes_referencia,
       null motivo_exclusao,
       null nome_beneficiario,
       null nome_plano_medico,
       null nome_plano_dental,
       null numero_beneficiario,
       op.nom_operadora operadora,
       null periodo_cobertura_inicial,
       null periodo_cobertura_final,
       porte.nome_tipo_empresa porte_contrato,
       null situacao_beneficiario,
       ce.ind_situacao situacao_contrato,
       null tipo_beneficiario,
       decode(ce.ind_tipo_produto, 1, 'M�dico', 2, 'Dental') tipo_produto,
       0 id_item_cobranca,
       null nome_rubrica,
       c.val_a_pagar valor_comercial,
       null sexo,
       es.num_cgc cnpj_entidade,
       c.dt_vencimento vencimento,
       CASE
         WHEN C.DT_VENCIMENTO_ORIG IS null THEN C.DT_VENCIMENTO
         ELSE C.DT_VENCIMENTO_ORIG
       END AS VENCIMENTO_ORIGINAL,
       c.dt_emissao data_emissao,
       c.num_seq_cobranca cobranca,
       c.num_seq_fatura_ts,
       null ESTADO_CIVIL,
       null data_ultimo_pagamento,
       null data_ultima_competencia_paga,
       null boletos_atrasados_total,
       null telefone_contato,
       null email,
       trunc(sysdate - c.dt_vencimento) dias_atraso,  
       null nome_responsavel,
       null cpf_cnpj_responsavel,
       c.nom_logradouro logradouro,
       c.num_endereco numero_endereco,
       c.txt_complemento complemento,
       c.nome_bairro bairro,
       c.cod_bairro,
       c.num_cep cep,
       c.nome_cidade municipio,
       c.cod_municipio,
       c.sgl_uf uf,
       null telefone_residencial,
       null telefone_comercial,
       null telefone_cobranca,
       null nacionalidade,
       TO_CHAR(SYSDATE, 'DDMMYYYY') DATA_FILE,
       'PJ' TIPO_PESSOA,
       null cod_ts,
       null cod_ts_tit,
       es.cod_entidade_ts cod_entidade_ts_tit,
       ce.cod_ts_contrato,
       null   

from ts.cobranca c 
     join ts.contrato_empresa ce on ce.cod_ts_contrato = c.cod_ts_contrato
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts    
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
     join ts.sucursal filial on filial.cod_sucursal = ce.cod_sucursal
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato   

where ce.tipo_empresa not in (1)
      and c.dt_cancelamento is null
      and c.dt_baixa is null
      and c.dt_emissao is not null
			and c.cod_ts is null
      and c.dt_vencimento < TRUNC (SYSDATE - 90)--120)
      and c.num_seq_fatura_ts is not null
			
			and not exists (select 1
                  from ts.cobranca c2
                  where c2.cod_ts_contrato = ce.cod_ts_contrato
									      and c2.cod_ts is null
                         and c2.dt_cancelamento is null
                         and c2.dt_baixa is null
                         and c2.dt_emissao is not null
                         and to_char(c2.dt_competencia, 'MM/YYYY') = to_char(ce.data_inicio_vigencia , 'MM/YYYY'))
      
       --------- REGRAS ------------------
      and ce.data_fim_vigencia is not null
      --TER PAGO PELO MENOS UMA FATURA
      and c.dt_competencia >= to_date('01/01/2016', 'dd/mm/yyyy')
      and (op.cod_operadora not in (106) or (c.dt_competencia >= to_date('01/01/2018', 'dd/mm/yyyy')));
			
			-----------------
			-----------------

commit;
