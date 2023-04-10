insert into FIN_FECH  
select distinct
       CASE WHEN acao.cod_ts IS NULL THEN 'Não' ELSE 'Sim' END AS acao_judicial,
       adm.nom_operadora administradora,
       
       (select distinct aa.cod_aditivo 
       from ts.associado_aditivo aa 
            join ts.aditivo ad on ad.cod_aditivo = aa.cod_aditivo
       where aa.cod_ts = b.cod_ts 
             and aa.dt_fim_vigencia is null
             and ad.cod_grupo_aditivo = 1) codigo_plano_dental,
       
       b.cod_plano codigo_plano_medico,
       ce.num_contrato contrato,
       ce.num_contrato_operadora contrato_operadora,
       lpad(be.num_cpf, 11, '0') CPF,
       trunc(bc.data_adesao) data_adesao,
       be.data_nascimento data_nascimento,
       extract(day from f.dt_ini_periodo) dia_vigencia,
       b.data_inclusao data_inclusao,
       b.data_exclusao data_exclusao,
       
        (SELECT TRUNC(MAX(OCO.DT_OCORRENCIA))
          FROM TS.OCORRENCIA_ASSOCIADO OCO
          WHERE OCO.COD_TS = b.COD_TS
          AND OCO.COD_OCORRENCIA IN (8, 54)) DATA_ULTIMA_SUSPENSAO,

          (SELECT MAX(TRUNC(OA.DT_OCORRENCIA))
           FROM TS.OCORRENCIA_ASSOCIADO OA
           WHERE OA.COD_TS = b.COD_TS
                 AND OA.COD_OCORRENCIA IN (186, 19)) DATA_REATIVACAO,
                 
       es.nome_entidade entidade,
       f.num_fatura fatura,                            
                                  
       filial.nome_sucursal filial,
       sys_get_idade_fnc(be.data_nascimento, sysdate) idade,
       
       (select distinct aa.num_associado_operadora 
       from ts.associado_aditivo aa 
            join ts.aditivo ad on ad.cod_aditivo = aa.cod_aditivo
       where aa.cod_ts = b.cod_ts 
             and aa.dt_fim_vigencia is null
             and ad.cod_grupo_aditivo = 1) mo_dental,
       
       b.num_associado_operadora mo_medico,
       f.mes_ano_ref mes_ano,
       exc.nome_motivo_exc_assoc motivo_exclusao,
       be.nome_entidade nome_beneficiario,
      
       (select distinct  ad.nom_aditivo 
       from ts.associado_aditivo aa 
            join ts.aditivo ad on ad.cod_aditivo = aa.cod_aditivo
       where aa.cod_ts = b.cod_ts 
             and aa.dt_fim_vigencia is null
             and ad.cod_grupo_aditivo = 1) nome_plano_dental,
       
       pm.nome_plano nome_plano_medico,
       b.num_associado numero_beneficiario,
       op.nom_operadora Operadora,
       f.dt_ini_periodo periodo_cobertura_inicial,
       f.dt_fim_periodo periodo_cobertura_final,
       porte.nome_tipo_empresa porte_contrato,
       b.ind_situacao situacao_beneficiario,
       ce.ind_situacao situacao_contrato,
       CASE WHEN c.dt_baixa is null AND c.dt_vencimento < sysdate AND c.dt_cancelamento is null
             THEN 'Vencida' 
            WHEN c.dt_baixa is null AND c.dt_vencimento > sysdate AND c.dt_cancelamento is null
             THEN 'Vincenda' 
            WHEN c.dt_baixa is not null AND c.dt_cancelamento is null
             THEN 'Paga'
            WHEN c.dt_cancelamento is not null 
             THEN 'Cancelada'
       END AS situacao_fatura,
       
       tipociclo.nom_tipo_ciclo ciclo,
       b.tipo_associado tipo_beneficiario,
       
       CASE WHEN ce.ind_tipo_produto = 1 AND rubrica.cod_tipo_rubrica <> 50 
             THEN 'Médico' 
            WHEN ce.ind_tipo_produto = 1 AND rubrica.cod_tipo_rubrica = 50
             THEN 'Dental' 
            WHEN ce.ind_tipo_produto = 2 
             THEN 'Dental'
       END AS tipo_produto,
       rubrica.cod_tipo_rubrica codigo_rubrica,  
       rubrica.nom_tipo_rubrica nome_rubrica,
       ic.val_item_cobranca valor_comercial,
       ic.val_item_pagar valor_net,
       b.data_inclusao Vigencia,
       dep.nome_dependencia Dependencia,
       be.ind_sexo sexo,
       b.cod_ts_tit codigo_familia_allsys,
       b.cod_ts codigo_unico_beneficiario,
       es.num_cgc cnpj_entidade,
       c.dt_vencimento vencimento,
       case when c.dt_vencimento_orig is null
              then c.dt_vencimento
            else c.dt_vencimento_orig
       end as vencimento_original,
       c.dt_emissao data_emissao,
       c.dt_baixa data_pagamento,
       c.dt_registro_baixa data_liquidacao,
       c.num_seq_cobranca cobranca,
       baixa.nome_tipo_baixa tipo_baixa,
       --c.val_pago valor_pago,
       0 as valor_pago,
       case when ic.val_item_pagar is not null and ic.val_item_pagar > 0
                 then (ic.val_item_cobranca - ic.val_item_pagar) 
            else 0 end as valor_over
       , sysdate as data_geracao, 0 as id,
       (select count(1)
        from ts.beneficiario b1
        where b1.cod_ts = b.cod_ts_tit
              and (b1.data_exclusao is null or b1.data_exclusao >= last_day(f.mes_ano_ref))) vidas
from ts.cobranca c 
     join ts.itens_cobranca ic on ic.num_seq_cobranca = c.num_seq_cobranca and ic.num_ciclo_ts = c.num_ciclo_ts
     join ts.fatura f on f.num_seq_fatura_ts = c.num_seq_fatura_ts
     join ts.situacao_fatura sf on sf.ind_situacao_fatura = f.ind_situacao
     join ts.tipo_rubrica_cobranca rubrica on rubrica.cod_tipo_rubrica = ic.cod_tipo_rubrica
     join ts.ciclo_faturamento ciclo on ciclo.num_ciclo_ts = f.num_ciclo_ts
     join ts.tipo_ciclo tipociclo on tipociclo.cod_tipo_ciclo = f.cod_tipo_ciclo
     join ts.beneficiario b on b.cod_ts = ic.cod_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.sucursal filial on filial.cod_sucursal = ce.cod_sucursal
     join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
          and (b.cod_empresa is null OR ec.cod_entidade_ts = b.cod_empresa)
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.beneficiario_contrato bc on bc.cod_ts = b.cod_ts
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
     left join ts.tipo_baixa baixa on baixa.ind_tipo_baixa = c.ind_tipo_baixa
     left join ts.tipo_dependencia dep on dep.cod_dependencia = b.cod_dependencia
     left join ts.acao_jud_pgto acao on acao.cod_ts = b.cod_ts
     left join ts.motivo_exclusao_assoc exc on exc.cod_motivo_exc_assoc = bc.cod_motivo_exclusao
where c.dt_emissao is not null
      --c.dt_emissao >= to_date('01/01/2020', 'dd/mm/yyyy')
      --and f.dt_emissao is not null
      --and b.num_associado = 1026540
      --and f.mes_ano_ref between to_date('01/01/2021', 'dd/mm/yyyy') and last_day('01/07/2021')   
      --and c.dt_baixa between to_date('01/07/2021', 'dd/mm/yyyy') and last_day('01/07/2021')
      --and (c.dt_baixa is null or c.dt_baixa >= last_day('01/07/2021'))   
      --and ce.cod_operadora = 3
      --and ce.cod_operadora_contrato = 232
      --and rubrica.cod_tipo_rubrica IN (250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263)
--2814
------------------------------------------------------------------------------------
/*
update fin_fech ff 
       set ff.valor_pago = (select c.val_pago from ts.cobranca c where c.num_seq_cobranca = ff.cobranca)
where ff.id = (select min(ff2.id) from fin_fech ff2 where ff2.fatura = ff.fatura)
*/


/*
delete fin_fech
*/
