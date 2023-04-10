--create table alt_tabela_precos as
--delete alt_tabela_precos;
--commit;
insert into alt_tabela_precos  
select * from
(select distinct
  sysdate data_geracao,
  oper.nom_operadora,
  ce.ind_situacao as situacao_contrato,
  ce.cod_ts_contrato,
  ce.num_contrato,
  ce.num_contrato_operadora,
  ce.data_inicio_vigencia,
  pm.cod_plano,
  pm.nome_plano_cartao,
  tab.dt_ini_vigencia as data_ultima_negociacao,
  cp.pct_indice_reajuste,
  case when tab.ind_momento = 'I' then 'Implanta��o' else 'P�s-Implanta��o' end as momento,
  case when tab.tipo_associado = 'T' then 'Titular'
            when tab.tipo_associado = 'D' then 'Dependente'
              else 'Agregado' end as Tipo_associado,
  faixa.cod_faixa_etaria,
  faixa.desc_faixa,
  tab.val_faixa as val_cobrar,
  tab.val_faixa_pagar as valor_pagar,
  auxPenultma.val_faixa as val_cobrar_anterior,
  auxPenultma.val_faixa_pagar as valor_pagar_anterior,
  null cod_aditivo,--ca.cod_aditivo,
  null nom_aditivo,--ad.nom_aditivo,
  null val_aditivo_tit,--ca.val_aditivo_tit,
  null val_aditivo_dep--ca.val_aditivo_dep
from ts.valor_fe_contrato tab
join ts.faixa_etaria faixa on
  faixa.cod_faixa_etaria = tab.cod_faixa_etaria and
  faixa.tipo_faixa = tab.tipo_faixa
join ts.contrato_empresa ce on ce.cod_ts_contrato = tab.cod_ts_contrato
join ts.ppf_operadoras oper on oper.cod_operadora = ce.cod_operadora_contrato
join ts.plano_medico pm on pm.cod_plano = tab.cod_plano
left join ts.CONTRATO_PLANO cp on
  cp.cod_ts_contrato = tab.cod_ts_contrato and
  cp.cod_plano = tab.cod_plano and
  cp.mes_inicio_aplicacao_rpc = tab.dt_ini_vigencia
/*left join ts.CONTRATO_ADITIVO ca on
  ca.cod_ts_contrato = ce.cod_ts_contrato and
  ca.dt_ini_vigencia = tab.dt_ini_vigencia
left join ts.aditivo ad on
  ad.cod_aditivo = ca.cod_aditivo*/
join (
  select
    tab.COD_TS_CONTRATO,
    tab.COD_PLANO,
    tab.IND_MOMENTO,
    tab.TIPO_ASSOCIADO,
    tab.TIPO_FAIXA,
    tab.COD_FAIXA_ETARIA,
    max(tab.dt_ini_vigencia) as dt_ini_vigencia
  from ts.valor_fe_contrato tab
  where tab.tipo_associado in ('T','D','A')
--    and tab.cod_ts_contrato = 1572
--    and tab.cod_plano = 323
  group by
    tab.COD_TS_CONTRATO,
    tab.COD_PLANO,
    tab.IND_MOMENTO,
    tab.TIPO_ASSOCIADO,
    tab.TIPO_FAIXA,
    tab.COD_FAIXA_ETARIA
)auxTab on
  auxTab.COD_TS_CONTRATO = tab.COD_TS_CONTRATO and
  auxTab.COD_PLANO       = tab.COD_PLANO       and
  auxTab.IND_MOMENTO     = tab.IND_MOMENTO     and
  auxTab.TIPO_ASSOCIADO  = TAB.TIPO_ASSOCIADO  and
  auxTab.TIPO_FAIXA      = tab.TIPO_FAIXA      and
  auxTab.dt_ini_vigencia = tab.dt_ini_vigencia
left join (
    select distinct
      auxPen.COD_TS_CONTRATO,
      auxPen.COD_PLANO,
      auxPen.IND_MOMENTO,
      auxPen.TIPO_ASSOCIADO,
      auxPen.TIPO_FAIXA,
      auxPen.COD_FAIXA_ETARIA,
      auxPen.dt_ini_vigencia,
      auxPen.val_faixa,
      auxPen.val_faixa_pagar
    from(
    select
      row_number() over(partition by tab.COD_TS_CONTRATO,
      tab.COD_PLANO,
      tab.IND_MOMENTO,
      tab.TIPO_ASSOCIADO,
      tab.TIPO_FAIXA,
      tab.COD_FAIXA_ETARIA order by dt_ini_vigencia desc) as indice,
      tab.COD_TS_CONTRATO,
      tab.COD_PLANO,
      tab.IND_MOMENTO,
      tab.TIPO_ASSOCIADO,
      tab.TIPO_FAIXA,
      tab.COD_FAIXA_ETARIA,
      tab.dt_ini_vigencia,
      tab.val_faixa,
      tab.val_faixa_pagar
    from ts.valor_fe_contrato tab
    where tab.tipo_associado in ('T','D','A')
      --and tab.cod_ts_contrato = 34
      --and tab.cod_plano = 58750
  )auxPen
  join ts.valor_fe_contrato tab2 on
    auxPen.COD_TS_CONTRATO = tab2.COD_TS_CONTRATO and
    auxPen.COD_PLANO       = tab2.COD_PLANO       and
    auxPen.IND_MOMENTO     = tab2.IND_MOMENTO     and
    auxPen.TIPO_ASSOCIADO  = TAB2.TIPO_ASSOCIADO  and
    auxPen.TIPO_FAIXA      = tab2.TIPO_FAIXA      and
    auxPen.dt_ini_vigencia = tab2.dt_ini_vigencia and
    auxPen.COD_FAIXA_ETARIA = tab2.COD_FAIXA_ETARIA
  where auxPen.indice = 2
)auxPenultma on
  auxPenultma.COD_TS_CONTRATO = tab.COD_TS_CONTRATO and
  auxPenultma.COD_PLANO       = tab.COD_PLANO       and
  auxPenultma.IND_MOMENTO     = tab.IND_MOMENTO     and
  auxPenultma.TIPO_ASSOCIADO  = TAB.TIPO_ASSOCIADO  and
  auxPenultma.TIPO_FAIXA      = tab.TIPO_FAIXA and
  auxPenultma.COD_FAIXA_ETARIA = tab.COD_FAIXA_ETARIA
where 1 = 1
      and exists (select 1
			            from ts.contrato_campos_operadora cco
									where cco.cod_ts_contrato = ce.cod_ts_contrato
									      and cco.cod_operadora = ce.cod_operadora_contrato
												and cco.cod_campo = 'NOME_MIGRACAO'
												and cco.val_campo = 'PROJETO MORUMBI')
    /*and ce.cod_operadora_contrato in (14)
      and ce.tipo_empresa in (1)
			and ce.ind_situacao = 'A'
			--and ce.num_contrato = '31884'
      and exists (select 1
			            from ts.contrato_cobranca cc
									where cc.cod_ts_contrato = ce.cod_ts_contrato
									      and cc.dt_ultimo_reajuste between to_date('01/01/2023', 'dd/mm/yyyy') and last_day('01/12/2023'))*/
)
      --and ce.data_fim_vigencia is null
-- and ce.cod_ts_contrato = 34
--  and pm.cod_plano = '58750'
  -- ce.num_contrato = 01662
  --and cp.cod_plano = 96183
/*order by
  oper.nom_operadora,
  ce.num_contrato,
  pm.cod_plano,
  pm.nome_plano_cartao,
  case when tab.ind_momento = 'I' then 'Implanta��o' else 'P�s-Implanta��o' end,
   case when tab.tipo_associado = 'T' then 'Titular'
            when tab.tipo_associado = 'D' then 'Dependente'
              else 'Agregado' end desc,
  pm.cod_plano,
  faixa.cod_faixa_etaria*/;
commit;  
