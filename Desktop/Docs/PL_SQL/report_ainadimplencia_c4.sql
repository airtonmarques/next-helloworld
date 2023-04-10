--create table alt_inadimplentes_fin as 
--create table alt_inadimplentes_fin as
--create table alt_inadimplentes_fin_c4 as
begin

  delete alt_inadimplentes_fin_c4;
commit;

insert into alt_inadimplentes_fin_c4
select distinct 
       null acao_judicial, --Deve ser feito update ap�s inclus�o na tabela
       adm.nom_operadora administradora,
       ce.num_contrato contrato,
       ce.num_contrato_operadora contrato_operadora,
       be.num_cpf cpf_cnpj,
       trunc(b.data_inclusao) data_inclusao,
       trunc(be.data_nascimento) data_nascimento,
       ce.data_inicio_vigencia data_inicio_vigencia,
       bc.data_adesao data_adesao,
       b.data_exclusao data_exclusao,
       es.nome_entidade entidade,
       null fatura,
       filial.nome_sucursal filial,
       trunc(months_between(sysdate, be.data_nascimento) / 12) idade,
       b.num_associado_operadora mo_medico,
       null mo_dental,
       to_char(c.dt_competencia, 'MM/YYYY') mes_referencia,
       exc.nome_motivo_exc_assoc motivo_exclusao,
       b.nome_associado nome_beneficiario,
       pm.nome_plano nome_plano_medico,
       null nome_plano_dental,
       b.num_associado numero_beneficiario,
       op.nom_operadora operadora,
       null periodo_cobertura_inicial,
       null periodo_cobertura_final,
       porte.nome_tipo_empresa porte_contrato,
       b.ind_situacao situacao_beneficiario,
       ce.ind_situacao situacao_contrato,
       b.tipo_associado tipo_beneficiario,
       decode(ce.ind_tipo_produto, 1, 'M�dico', 2, 'Dental') tipo_produto,
       ic.num_item_cobranca_ts id_item_cobranca,
       rub.nom_tipo_rubrica nome_rubrica,
       ic.val_item_cobranca valor_comercial,
       be.ind_sexo sexo,
       es.num_cgc cnpj_entidade,
       c.dt_vencimento vencimento,
       CASE
         WHEN C.DT_VENCIMENTO_ORIG IS null THEN C.DT_VENCIMENTO
         ELSE C.DT_VENCIMENTO_ORIG
       END AS VENCIMENTO_ORIGINAL,
       c.dt_emissao data_emissao,
       c.num_seq_cobranca cobranca,
       c.num_seq_fatura_ts,
       DECODE(BE.IND_ESTADO_CIVIL,1,'Solteiro',
                                  2,'Casado',
                                  3,'Viuvo',
                                  4,'Separado',
                                  5,'Divorciado',
                                  6,'Outros',
                                  7,'Uni�o est�vel',
                                  BE.IND_ESTADO_CIVIL) ESTADO_CIVIL,
       null data_ultimo_pagamento,
       null data_ultima_competencia_paga,
       null boletos_atrasados_total,
       null telefone_contato,
       null email,
       trunc(sysdate - c.dt_vencimento) dias_atraso,  
       bf.nome_resp_reemb nome_responsavel,
       bf.num_cpf_resp_reemb cpf_cnpj_responsavel,
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
       be.ind_nacionalidade nacionalidade,
       TO_CHAR(SYSDATE, 'DDMMYYYY') DATA_FILE,
       'PF' TIPO_PESSOA,
       b.cod_ts cod_ts,
       b.cod_ts_tit cod_ts_tit,
       b.cod_entidade_ts_tit cod_entidade_ts_tit,
       ce.cod_ts_contrato,
       null   

from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.beneficiario_contrato bc on bc.cod_ts = b.cod_ts
     join ts.beneficiario_faturamento bf on bf.cod_ts = b.cod_ts_tit
     join ts.cobranca c on c.cod_ts = b.cod_ts_tit
     join ts.itens_cobranca ic on ic.cod_ts = b.cod_ts
                               and ic.num_seq_cobranca = c.num_seq_cobranca
                               and ic.num_ciclo_ts = c.num_ciclo_ts 
     join ts.tipo_rubrica_cobranca rub on rub.cod_tipo_rubrica = ic.cod_tipo_rubrica                               
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
          and (b.cod_empresa is null OR ec.cod_entidade_ts = b.cod_empresa)
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
     join ts.sucursal filial on filial.cod_sucursal = ce.cod_sucursal
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
     left join ts.motivo_exclusao_assoc exc on exc.cod_motivo_exc_assoc = bc.cod_motivo_exclusao

where c.dt_cancelamento is null
      and c.dt_baixa is null
      and c.dt_emissao is not null
      and c.dt_vencimento < TRUNC (SYSDATE - 90)--120)
      --and b.cod_ts_tit IN (66168)
      and c.num_seq_fatura_ts is not null
      --and b.num_associado_operadora is not null
      --and ce.num_contrato IN ('15254', '15255', '15256', '15258');
      --------- REGRAS ------------------
			and not exists (select 1
                  from ts.cobranca c2
                  where c2.cod_ts = b.cod_ts_tit
                         and c2.dt_cancelamento is null
                         and c2.dt_baixa is null
                         and c2.dt_emissao is not null
                         and to_char(c2.dt_competencia, 'MM/YYYY') = to_char(b.data_inclusao , 'MM/YYYY'))
      and b.data_exclusao is not null
      --TER PAGO PELO MENOS UMA FATURA
      and c.dt_competencia >= to_date('01/01/2016', 'dd/mm/yyyy')
      and (op.cod_operadora not in (106) or (c.dt_competencia >= to_date('01/01/2018', 'dd/mm/yyyy')));

commit;

end;

