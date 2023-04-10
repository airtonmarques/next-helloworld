select distinct adm.nom_operadora Administradora,
       op.Nom_Operadora Operadora,
       es.nome_entidade Entidade,
       su.nome_sucursal Filial,
       '08/2021' Competencia,
       b.cod_ts_tit codigoFamilia,
       b.cod_ts,
       b.tipo_associado,
       b.num_associado,
       b.nome_associado,
       bc.data_adesao,
       bf.dia_vencimento,
       tc.nome_tipo_cobranca,
       ce.num_contrato Contrato,
       tipo.nome_tipo_empresa Porte,
       ce.qtd_laminas_grande_emissao,
       decode(pm.ind_participacao, 'S', 'Copart', 'Sem Copart') Copart,
       ce.ind_situacao situacaoContrato,
       case when b.num_associado_operadora is null then
         'M.O Não informada'
            when (select 1
                  from ts.acao_jud_pgto acao
                  where acao.cod_ts = b.cod_ts_tit
                  group by acao.cod_ts) = 1 then
         'Ação Judicial'
       when (select count(1)
             from ts.acao_jud_pgto acao1
             where acao1.cod_ts = b.cod_ts_tit) >= 2 then
         'Ação Judicial Duplicada'
       else 'ND' end Motivo,
       (select count(1)
        from ts.cobranca c
        where c.dt_competencia between to_date('01/08/2021', 'dd/mm/yyyy') 
              and last_day('01/08/2021')
              and c.dt_emissao is null
              and ((cc.cod_tipo_fat in (5) and c.cod_ts = b.cod_ts_tit) 
                  OR (cc.cod_tipo_fat not in (5) and c.cod_ts_contrato = ce.cod_ts_contrato))) previas 
       
      /* ,
       (select sys_get_vlr_cont_fe_fnc(2, ce.cod_ts_contrato, pl.cod_plano, 
               b.tipo_associado, SYS_GET_IDADE_FNC(be.data_nascimento, last_day('01/08/2021')), last_day('01/08/2021')) from dual) as VALOR_COMERCIAL
            */
from ts.contrato_empresa ce 
     join ts.beneficiario b on b.cod_ts_contrato = ce.cod_ts_contrato
     join ts.beneficiario_contrato bc on bc.cod_ts = b.cod_ts
     join ts.beneficiario_faturamento bf on bf.cod_ts = b.cod_ts
     join ts.tipo_cobranca tc on tc.cod_tipo_cobranca = bf.cod_tipo_cobranca
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.plano_medico pl on pl.cod_plano = b.cod_plano
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
     join ts.sucursal su on su.cod_sucursal = ce.cod_sucursal
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
          and (b.cod_empresa is null OR ec.cod_entidade_ts = b.cod_empresa)
     join ts.regra_empresa tipo on tipo.tipo_empresa = ce.tipo_empresa
     join ts.contrato_cobranca cc on cc.cod_ts_contrato = ce.cod_ts_contrato
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
where not exists (select 1
                  from ts.cobranca c
                  where c.dt_competencia between to_date('01/08/2021', 'dd/mm/yyyy') 
                        and last_day('01/08/2021')
                        and c.dt_emissao is not null
                        and ((cc.cod_tipo_fat in (5) and c.cod_ts = b.cod_ts_tit) 
                            OR (cc.cod_tipo_fat not in (5) and c.cod_ts_contrato = ce.cod_ts_contrato)))
      and (b.data_exclusao is null or b.data_exclusao > last_day('01/08/2021'))
      and b.data_inclusao <= last_day('01/08/2021')   
      --and b.num_associado_operadora is not null                     
order by 1, 2, 6, 8 desc
