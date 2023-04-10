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
nvl(b.data_exclusao, '31/12/3000'),
b.data_inclusao,--aa.dt_ini_vigencia,
nvl(b.data_exclusao, '31/12/3000') as fim_vigencia,--aa.dt_fim_vigencia,
--(select ALL_GET_TIPO_PRECIFICACAO_FNC(1) from dual) as PRECIFICACAO,
'' as PRECIFICACAO,
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
(select sys_get_vlr_cont_fe_fnc(2, ce.cod_ts_contrato, p.cod_plano, b.tipo_associado, SYS_GET_IDADE_FNC(be.data_nascimento, to_date('28/02/2021', 'dd/mm/yyyy')), to_date('28/02/2021', 'dd/mm/yyyy')) from dual) as VALOR_COMERCIAL,
(select sys_get_vlr_cont_fe_fnc(1, ce.cod_ts_contrato, p.cod_plano, b.tipo_associado, SYS_GET_IDADE_FNC(be.data_nascimento, to_date('28/02/2021', 'dd/mm/yyyy')), to_date('28/02/2021', 'dd/mm/yyyy')) from dual) as VALOR_NET
(select bend.sgl_uf from ts.beneficiario_endereco bend where bend.num_seq_end = 1 and bend.cod_entidade_ts = b.cod_entidade_ts_tit) uf_endereco_beneficiario

 -- Informa proposta de migração
 /*(select m.cod_ts_adm
    from all_ben_mig m
   where m.cod_ts_exc = b.cod_ts
     and m.dt_exc = b.data_exclusao
     and m.origem_produto = 1
     and m.cod_tipo_plano = p.cod_tipo_plano) cod_ts_mig_destino,
     
     (select m.cod_ts_exc
    from all_ben_mig m
   where m.cod_ts_adm = b.cod_ts
     and m.dt_adm = b.data_inclusao
     and m.origem_produto = 1
     and m.cod_tipo_plano = p.cod_tipo_plano) cod_ts_mig_origem*/

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
     --ts.associado_aditivo@prod_allsys     aa,
     --ts.aditivo@prod_allsys               ad,
     ts.sucursal              su,
     ts.municipio             mu,
     ts.sucursal              suc
     --ts.acao_jud_pgto@prod_allsys         ac

 where

-- Critério de não contagem (exclusão menor ou igual a inclusão)
 nvl(b.data_exclusao, to_date('31/12/3000', 'DD/MM/YYYY')) >
 b.data_inclusao

-- Exclusão
/*
and b.data_exclusao >= to_date('01/02/2021', 'dd/mm/yyyy')
and nvl(b.data_exclusao, to_date('31/12/3000', 'DD/MM/YYYY')) <=
last_day('01/02/2021')
*/

-- Inclusão
and b.data_inclusao >= '01/02/2021'
and nvl(b.data_inclusao, to_date('31/12/3000', 'DD/MM/YYYY')) <=
last_day('01/02/2021')
--and b.cod_ts = 1162003
-- Vidas Ativas Real
 /*and b.data_inclusao <= last_day('01/11/2019')
 and all_get_dt_exc_mig_fnc(1,
                        p.cod_tipo_plano,
                        b.cod_ts,
                        b.data_exclusao,
                        last_day('01/10/2019')) > last_day('01/10/2019')*/

 and p.cod_tipo_plano = 1
 and b.tipo_associado NOT IN ('P')
 --and b.cod_ts = 1117645
-- Vidas Ativas
/*
and b.data_inclusao <= last_day('01/02/2021')
--and b.data_inclusao between to_date('01/10/2020', 'dd/mm/yyyy') and last_day('01/10/2020')
and nvl(b.data_exclusao, to_date('31/12/3000', 'DD/MM/YYYY')) >
last_day('01/02/2021')
*/

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
 --and b.num_associado = 13655213
 --and b.cod_ts = aa.cod_ts 
 --and ad.cod_aditivo(+) = aa.cod_aditivo
 and be.cod_sucursal = su.cod_sucursal
 and mu.cod_municipio = su.cod_municipio
 and suc.cod_sucursal = ce.cod_sucursal
 --and ce.num_contrato = 13080
 --and ac.cod_ts = b.cod_ts (+)
 order by 6, 25 desc 
