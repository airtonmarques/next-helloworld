
  insert into all_bene_saldo_partial 
select distinct
--count(1)/*,
b.cod_ts,
e.cod_entidade_ts,
b.cod_entidade_ts_tit,
be.ind_sexo,
ce.cod_ts_contrato,
b.cod_ts_tit,
--MES_REFERENCIA
b.data_inclusao,
nvl(b.data_exclusao, '31/12/3000') data_exclusao,
bc.data_adesao,--aa.dt_ini_vigencia,
nvl(b.data_exclusao, '31/12/3000') as fim_vigencia,--aa.dt_fim_vigencia,
--(select ALL_GET_TIPO_PRECIFICACAO_FNC(1) from dual) as PRECIFICACAO,
' ' as PRECIFICACAO,
su.nome_sucursal as FILIAL,
mu.sgl_uf,
upper(e.nome_entidade) nome_entidade,
ce.data_inicio_vigencia,
a.cod_operadora as cod_adm,
re.nome_tipo_empresa porte,
a.nom_operadora as administradora,
ce.num_contrato,
ce.num_contrato_operadora,
b.num_associado,
b.num_associado_operadora,
b.nome_associado,
lpad(be.num_cpf, 11, '0') CPF,
b.tipo_associado,
b.ind_situacao,
p.cod_plano,
upper(p.nome_plano) nome_plano,
upper(o.nom_operadora) nom_operadora,
be.data_nascimento,
p.cod_tipo_plano,
ce.mes_aniversario_contrato MES_REAJUSTE,
suc.nome_sucursal,

case when b.data_inclusao > to_date(sysdate, 'dd/mm/yyyy') then
     (select sys_get_vlr_cont_fe_fnc(2, ce.cod_ts_contrato, p.cod_plano, b.tipo_associado, SYS_GET_IDADE_FNC(be.data_nascimento, last_day('01/03/2023')), b.data_inclusao) from dual)
else 
		 (select sys_get_vlr_cont_fe_fnc(2, ce.cod_ts_contrato, p.cod_plano, b.tipo_associado, SYS_GET_IDADE_FNC(be.data_nascimento, last_day('01/03/2023')), last_day('01/03/2023')) from dual)
end as VALOR_COMERCIAL,

case when b.data_inclusao > to_date(sysdate, 'dd/mm/yyyy') then
     (select sys_get_vlr_cont_fe_fnc(1, ce.cod_ts_contrato, p.cod_plano, b.tipo_associado, SYS_GET_IDADE_FNC(be.data_nascimento, last_day('01/03/2023')), b.data_inclusao) from dual)
else 
		 (select sys_get_vlr_cont_fe_fnc(1, ce.cod_ts_contrato, p.cod_plano, b.tipo_associado, SYS_GET_IDADE_FNC(be.data_nascimento, last_day('01/03/2023')), last_day('01/03/2023')) from dual)
end as VALOR_NET,

(select bend.sgl_uf from ts.beneficiario_endereco bend where bend.num_seq_end = 1 and bend.cod_entidade_ts = b.cod_entidade_ts_tit) uf_endereco_beneficiario,
(select mu.nom_municipio
 from ts.beneficiario_endereco bend1
      left join ts.municipio mu on mu.cod_municipio = bend1.cod_municipio
 where bend1.num_seq_end = 1 and bend1.cod_entidade_ts = b.cod_entidade_ts_tit) municipio_beneficiario,
 m.nome_motivo_exc_assoc,

 (select max(b2.num_associado)
  from ts.beneficiario b2
  where b2.num_associado_operadora = b.num_associado_operadora
        and b2.cod_ts <> b.cod_ts
        and b2.data_exclusao <  b.data_inclusao) migrado,

  '050420230900' lote_inclusao,
null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 null,
 ce.cod_operadora_contrato,
 b.cod_empresa,
 null,
 sysdate,
 null

  from ts.beneficiario          b,
       ts.plano_medico          p,
       ts.tipo_plano            tp,
       ts.operadora             a,
       ts.beneficiario_entidade be,
       ts.beneficiario_contrato bc,
       ts.contrato_empresa      ce,
       ts.ppf_operadoras        o,
       ts.regra_empresa         re,
       ts.entidade_sistema      e,
       ts.motivo_exclusao_assoc m,
       ts.sucursal              su,
       ts.municipio             mu,
       ts.sucursal              suc


 where

-- Critério de não contagem (exclusão menor ou igual a inclusão)
 nvl(b.data_exclusao, to_date('31/12/3000', 'DD/MM/YYYY')) > b.data_inclusao

--and p.cod_tipo_plano = 1
and b.tipo_associado NOT IN ('P')


-- Vidas Ativas

and b.data_inclusao <= last_day('01/03/2023')
and nvl(b.data_exclusao, to_date('31/12/3000', 'DD/MM/YYYY')) > last_day('01/03/2023')


-- Concatenações
 and p.cod_plano = b.cod_plano
 and tp.cod_tipo_plano(+) = p.cod_tipo_plano
 and a.cod_operadora(+) = b.cod_operadora
 and bc.cod_ts(+) = b.cod_ts
 and be.cod_entidade_ts(+) = b.cod_entidade_ts
 and ce.cod_ts_contrato(+) = b.cod_ts_contrato
 and o.cod_operadora(+) = ce.cod_operadora_contrato
 and re.tipo_empresa(+) = ce.tipo_empresa
 and e.cod_entidade_ts(+) = ce.cod_titular_contrato
 and m.cod_motivo_exc_assoc(+) = bc.cod_motivo_exclusao
 and be.cod_sucursal = su.cod_sucursal
 and mu.cod_municipio = su.cod_municipio
 and suc.cod_sucursal = ce.cod_sucursal;
commit;

---------------------------------------------------------------------------------------
-- Update ultimo cod_ts para troca de contrato
update all_bene_saldo_partial bsp
set bsp.cod_ts_anterior = (select max(a.cod_ts)
                           from ts.associado a
                           where a.cod_ts_destino = bsp.cod_ts)
where bsp.lote_inclusao =  '050420230900';
commit;

--Update MO Dental

update all_bene_saldo_partial bsp
set (bsp.mo_dental, bsp.nome_plano_dental, bsp.cod_aditivo, bsp.dth_ini_vig_ad) = (select aa.num_associado_operadora,
                                                       a.nom_aditivo, aa.cod_aditivo, aa.dt_ini_vigencia
                                                from ts.associado_aditivo aa
                                                     join ts.aditivo a on a.cod_aditivo = aa.cod_aditivo
                                                where a.cod_tipo_rubrica IN (50)
                                                      and aa.num_associado_operadora is not null
                                                      and aa.cod_ts = bsp.cod_ts
                                                      and aa.dt_ini_vigencia = (select max(aa1.dt_ini_vigencia)
                                                                                from ts.associado_aditivo aa1
                                                                                where aa1.cod_ts = aa.cod_ts
                                                                                      and aa1.cod_aditivo = aa.cod_aditivo)
                                                      and rownum = 1)
where bsp.lote_inclusao =  '050420230900';
commit;
----------------------------------------------------------------------------------------

update all_bene_saldo_partial bsp
set bsp.data_exclusao_anterior = (select max(b.data_exclusao)
                                from ts.beneficiario b
                                     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts                                
                                where be.num_cpf = to_number(bsp.cpf)
                                      and b.nome_associado = bsp.nome_associado
                                      and b.cod_ts <> bsp.cod_ts)
where bsp.lote_inclusao =  '050420230900';

commit;

-------------------------------------------------------------------------------------      
update all_bene_saldo_partial bsp
set bsp.data_inclusao_futura = (select max(b.data_inclusao)
                                from ts.beneficiario b
                                     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts                                
                                where be.num_cpf = to_number(bsp.cpf)
                                      and b.nome_associado = bsp.nome_associado
                                      and b.cod_ts <> bsp.cod_ts
                                      and b.data_inclusao >= bsp.data_inclusao)
where bsp.lote_inclusao =  '050420230900';
commit;

-------------------------------------------------------------------------------------
update all_bene_saldo_partial bsp
set bsp.data_primeiro_pagamento = (select min(c.dt_baixa)
                                   from ts.cobranca c
                                   where c.cod_ts = bsp.cod_ts_tit
                                         and c.dt_cancelamento is null
                                         and c.dt_emissao is not null
                                         and c.dt_baixa is not null)
where bsp.lote_inclusao =  '050420230900';
commit;

-------------------------------------------------------------------------------------
update all_bene_saldo_partial bsp
set bsp.data_primeiro_pagamento = (select min(c.dt_baixa)
                                   from ts.cobranca c
                                   where c.cod_ts_contrato = bsp.cod_ts_contrato
                                         and c.dt_cancelamento is null
                                         and c.dt_emissao is not null
                                         and c.dt_baixa is not null
                                         and c.cod_ts is null)
where bsp.lote_inclusao =  '050420230900'
      and bsp.data_primeiro_pagamento is null;
commit;


-------------------------------------------------------------------------------------
update all_bene_saldo_partial bsp
set bsp.boletos_atrasado = (select count(1)
                            from ts.cobranca c
                            where c.cod_ts = bsp.cod_ts_tit
                                  and c.dt_cancelamento is null
                                  and c.dt_emissao is not null
                                  and c.dt_vencimento < trunc(sysdate)
                                  and c.dt_baixa is null)
where bsp.lote_inclusao =  '050420230900';
commit;
-------------------------------------------------------------------------------------

update all_bene_saldo_partial bsp
set bsp.boletos_atrasado = (select count(1)
                            from ts.cobranca c
                            where c.cod_ts_contrato = bsp.cod_ts_contrato
                                  and c.dt_cancelamento is null
                                  and c.dt_emissao is not null
                                  and c.dt_vencimento < trunc(sysdate)
                                  and c.dt_baixa is null
                                  and c.cod_ts is null)
where bsp.lote_inclusao =  '050420230900'
      and (bsp.boletos_atrasado is null or bsp.boletos_atrasado = 0);
commit;

-------------------------------------------------------------------------------------      

update all_bene_saldo_partial bsp
       set bsp.acao_judicial = DECODE((SELECT COUNT(1)
                                               FROM ts.acao_jud_pgto a
                                               WHERE a.cod_ts IN (bsp.cod_ts, bsp.cod_ts_tit)
                                                     AND SYSDATE BETWEEN a.DT_INI_ACAO AND
                                                         NVL(a.DT_FIM_ACAO, to_date('31/12/3000', 'DD/MM/YYYY'))),
                  0,
                  'NÃO POSSUI',
                  'POSSUI')
where bsp.lote_inclusao =  '050420230900';
commit;

------------------------------------------------------------
update all_bene_saldo_partial bsp
set (bsp.cod_corretora, bsp.nome_corretora) = (select cv.cod_corretor, es.nome_entidade
                                           from ts.entidade_sistema es
                                                join ts.corretor_venda cv on cv.cod_entidade_ts = es.cod_entidade_ts
                                                join ts.ppf_proposta p on p.cod_produtor_ts = cv.cod_corretor_ts
                                                join ts.beneficiario ben on ben.num_seq_proposta_ts = p.num_seq_proposta_ts
                                           where ben.cod_ts = bsp.cod_ts_tit)
where bsp.lote_inclusao =  '050420230900'
      and bsp.cod_corretora is null;
commit;

---------------------------------------------------------------
update all_bene_saldo_partial bsp
set (bsp.cod_corretora, bsp.nome_corretora) = (select cv.cod_corretor, es.nome_entidade
                                           from ts.entidade_sistema es
                                                join ts.corretor_venda cv on cv.cod_entidade_ts = es.cod_entidade_ts
                                                join ts.pj_proposta p on p.cod_produtor_ts = cv.cod_corretor_ts
                                                join ts.contrato_empresa ce on ce.num_seq_proposta_pj_ts = p.num_seq_proposta_pj_ts
                                           where ce.cod_ts_contrato = bsp.cod_ts_contrato)
where bsp.lote_inclusao =  '050420230900'
      and bsp.cod_corretora is null;
commit;

--P R O P O S T A
-------------------
------------------------------------------------------------
update all_bene_saldo_partial bsp
set (bsp.num_seq_proposta, bsp.num_proposta) = (select p.num_seq_proposta_ts, p.num_proposta_adesao
                              from ts.ppf_proposta p
                                   join ts.beneficiario ben on ben.num_seq_proposta_ts = p.num_seq_proposta_ts
                              where ben.cod_ts = bsp.cod_ts_tit)
where bsp.lote_inclusao = '050420230900'
      and bsp.num_seq_proposta is null;
commit;

---------------------------------------------------------------
update all_bene_saldo_partial bsp
set (bsp.num_seq_proposta, bsp.num_proposta) = (select p.num_seq_proposta_pj_ts, p.num_proposta
                              from ts.pj_proposta p
                                   join ts.contrato_empresa ce on ce.num_seq_proposta_pj_ts = p.num_seq_proposta_pj_ts
                              where ce.cod_ts_contrato = bsp.cod_ts_contrato)
where bsp.lote_inclusao = '050420230900'
      and bsp.num_seq_proposta is null;
commit;

--C O R R E T O R A
----------
-----------------------------------------------------------------
update all_bene_saldo_partial bsp
set (bsp.cod_corretora, bsp.nome_corretora) = (select cv.cod_corretor, es.nome_entidade
                                           from ts.entidade_sistema es
                                                join ts.corretor_venda cv on cv.cod_entidade_ts = es.cod_entidade_ts
                                                join ts.ppf_proposta p on p.cod_produtor_ts = cv.cod_corretor_ts
                                           where p.num_seq_proposta_ts = bsp.num_seq_proposta)
where bsp.lote_inclusao = '050420230900'
      and bsp.cod_corretora is null;
commit;

---------------------------------------------------------------
update all_bene_saldo_partial bsp
set (bsp.cod_corretora, bsp.nome_corretora) = (select cv.cod_corretor, es.nome_entidade
                                           from ts.entidade_sistema es
                                                join ts.corretor_venda cv on cv.cod_entidade_ts = es.cod_entidade_ts
                                                join ts.pj_proposta p on p.cod_produtor_ts = cv.cod_corretor_ts
                                           where p.num_seq_proposta_pj_ts = bsp.num_seq_proposta)
where bsp.lote_inclusao = '050420230900'
      and bsp.cod_corretora is null;
commit;
----------------------------------------------------------------

--C O R R E T O R
----------
-----------------------------------------------------------------
update all_bene_saldo_partial bsp
set (bsp.cod_corretor, bsp.nome_corretor) = (select cv.cod_corretor, es.nome_entidade
                                           from ts.entidade_sistema es
                                                join ts.corretor_venda cv on cv.cod_entidade_ts = es.cod_entidade_ts
                                                join ts.ppf_proposta p on p.cod_vendedor_ts = cv.cod_corretor_ts
                                           where p.num_seq_proposta_ts = bsp.num_seq_proposta)
where bsp.lote_inclusao = '050420230900'
      and bsp.cod_corretor is null;
commit;

---------------------------------------------------------------
update all_bene_saldo_partial bsp
set (bsp.cod_corretor, bsp.nome_corretor) = (select cv.cod_corretor, es.nome_entidade
                                           from ts.entidade_sistema es
                                                join ts.corretor_venda cv on cv.cod_entidade_ts = es.cod_entidade_ts
                                                join ts.pj_proposta p on p.cod_vendedor_ts = cv.cod_corretor_ts
                                           where p.num_seq_proposta_pj_ts = bsp.num_seq_proposta)
where bsp.lote_inclusao = '050420230900'
      and bsp.cod_corretor is null;
commit;
----------------------------------------------------------------


--S U P E R V I S O R
----------
-----------------------------------------------------------------
update all_bene_saldo_partial bsp
set (bsp.cod_supervisor, bsp.nome_supervisor) = (select cv.cod_corretor, es.nome_entidade
                                           from ts.entidade_sistema es
                                                join ts.corretor_venda cv on cv.cod_entidade_ts = es.cod_entidade_ts
                                                join ts.ppf_proposta p on p.cod_vendedor_contato_ts = cv.cod_corretor_ts
                                           where p.num_seq_proposta_ts = bsp.num_seq_proposta)
where bsp.lote_inclusao = '050420230900'
      and bsp.cod_supervisor is null;
commit;

---------------------------------------------------------------
update all_bene_saldo_partial bsp
set (bsp.cod_supervisor, bsp.nome_supervisor) = (select cv.cod_corretor, es.nome_entidade
                                           from ts.entidade_sistema es
                                                join ts.corretor_venda cv on cv.cod_entidade_ts = es.cod_entidade_ts
                                                join ts.pj_proposta p on p.cod_supervisor_ts = cv.cod_corretor_ts
                                           where p.num_seq_proposta_pj_ts = bsp.num_seq_proposta)
where bsp.lote_inclusao = '050420230900'
      and bsp.cod_supervisor is null;
commit;
----------------------------------------------------------------


--E Q U I P E   I N T E R N A
----------
-----------------------------------------------------------------
update all_bene_saldo_partial bsp
set (bsp.cod_equipe_interna, bsp.nome_equipe_interna) = (select cv.cod_corretor, es.nome_entidade
                                           from ts.entidade_sistema es
                                                join ts.corretor_venda cv on cv.cod_entidade_ts = es.cod_entidade_ts
                                                join ts.ppf_proposta p on p.cod_equipe_interna = cv.cod_corretor
                                           where p.num_seq_proposta_ts = bsp.num_seq_proposta)
where bsp.lote_inclusao = '050420230900'
      and bsp.cod_equipe_interna is null;
commit;

---------------------------------------------------------------
update all_bene_saldo_partial bsp
set (bsp.cod_equipe_interna, bsp.nome_equipe_interna) = (select cv.cod_corretor, es.nome_entidade
                                           from ts.entidade_sistema es
                                                join ts.corretor_venda cv on cv.cod_entidade_ts = es.cod_entidade_ts
                                                join ts.pj_proposta p on p.cod_equipe_interna = cv.cod_corretor
                                           where p.num_seq_proposta_pj_ts = bsp.num_seq_proposta)
where bsp.lote_inclusao = '050420230900'
      and bsp.cod_equipe_interna is null;
commit;
----------------------------------------------------------------


--E Q U I P E   E X T E R N A
----------
-----------------------------------------------------------------
update all_bene_saldo_partial bsp
set (bsp.cod_equipe_externa, bsp.nome_equipe_externa) = (select cv.cod_corretor, es.nome_entidade
                                           from ts.entidade_sistema es
                                                join ts.corretor_venda cv on cv.cod_entidade_ts = es.cod_entidade_ts
                                                join ts.ppf_proposta p on p.cod_equipe_externa = cv.cod_corretor
                                           where p.num_seq_proposta_ts = bsp.num_seq_proposta)
where bsp.lote_inclusao = '050420230900'
      and bsp.cod_equipe_externa is null;
commit;

---------------------------------------------------------------
update all_bene_saldo_partial bsp
set (bsp.cod_equipe_externa, bsp.nome_equipe_externa) = (select cv.cod_corretor, es.nome_entidade
                                           from ts.entidade_sistema es
                                                join ts.corretor_venda cv on cv.cod_entidade_ts = es.cod_entidade_ts
                                                join ts.pj_proposta p on p.cod_equipe_externa = cv.cod_corretor
                                           where p.num_seq_proposta_pj_ts = bsp.num_seq_proposta)
where bsp.lote_inclusao = '050420230900'
      and bsp.cod_equipe_externa is null;
commit;  

--VALOR ADITIVO DENTAL TITULAR---------------------------------------------------------------
update all_bene_saldo_partial bsp
set (bsp.valor_comercial_dental, bsp.valor_net_dental) = (select ca.val_aditivo_tit, ca.val_aditivo_tit_pagar
                                                          from ts.contrato_aditivo ca
                                                          where ca.cod_ts_contrato = bsp.cod_ts_contrato
                                                                and ca.cod_aditivo = bsp.cod_aditivo
                                                                and ca.dt_ini_vigencia = (select max(ca1.dt_ini_vigencia)
                                                                                          from ts.contrato_aditivo ca1
                                                                                          where ca1.cod_ts_contrato = ca.cod_ts_contrato
                                                                                                and ca1.cod_aditivo = ca.cod_aditivo)
                                                                and rownum = 1)
where bsp.lote_inclusao = '050420230900'
      and bsp.tipo_associado in ('T', 'P')
      and bsp.mo_dental is not null;
commit;
----------------------------------------------------------------

--VALOR ADITIVO DENTAL DEPENDENTE---------------------------------------------------------------
update all_bene_saldo_partial bsp
set (bsp.valor_comercial_dental, bsp.valor_net_dental) = (select ca.val_aditivo_tit, ca.val_aditivo_tit_pagar
                                                          from ts.contrato_aditivo ca
                                                          where ca.cod_ts_contrato = bsp.cod_ts_contrato
                                                                and ca.cod_aditivo = bsp.cod_aditivo
                                                                and ca.dt_ini_vigencia = (select max(ca1.dt_ini_vigencia)
                                                                                          from ts.contrato_aditivo ca1
                                                                                          where ca1.cod_ts_contrato = ca.cod_ts_contrato
                                                                                                and ca1.cod_aditivo = ca.cod_aditivo)
                                                                and rownum = 1)
where bsp.lote_inclusao = '050420230900'
      and bsp.tipo_associado not in ('T', 'P')
      and bsp.mo_dental is not null;
commit;
----------------------------------------------------------------
--EMPRESA PARTICIPANTE---------------------------------------------------------------
update all_bene_saldo_partial bsp
set bsp.empresa_participante = (select es.nome_entidade
                                from ts.empresa_contrato ec
                                     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
                                     where ec.cod_ts_contrato = bsp.cod_ts_contrato
                                           and ec.cod_entidade_ts = bsp.cod_empresa
                                           and rownum = 1)
where bsp.lote_inclusao = '050420230900'
      and bsp.cod_empresa is not null;
commit;
----------------------------------------------------------------
----------------------------------------------------------------
--NOME DA MIGRAÇÃO---------------------------------------------------------------
  update all_bene_saldo_partial bsp
     set bsp.nome_migracao =
         (select co.val_campo
                  from ts.contrato_campos_operadora co
                  where co.cod_ts_contrato = bsp.cod_ts_contrato
                        and co.cod_operadora = bsp.cod_operadora
                        and co.cod_campo = 'NOME_MIGRACAO'
             and rownum = 1)
   where bsp.lote_inclusao = '050420230900';
  commit;
