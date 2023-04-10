select distinct 
       ce.num_contrato Contrato,       
       ec.nom_empresa_cartao Empresa,
       op.nom_operadora Operadora,
       porte.nome_tipo_empresa Porte,
       ce.ind_situacao Status,
       decode(ce.ind_tipo_produto, 1, 'Médico', 2, 'Dental') Produto,
       ce.data_inicio_vigencia Vigencia,
       ce.mes_aniversario_contrato Reajuste,
       ce.num_contrato_operadora Contrato_Operadora,
       b.cod_ts_tit Familia,
       b.tipo_associado Dependencia,
       (select b1.num_matric_empresa 
        from ts.beneficiario b1 
        where b1.cod_ts = b.cod_ts_tit) Matricula_Funcional,
       b.nome_associado Nome,
       lpad(be.num_cpf, 11, '0') CPF,
       be.data_nascimento Nascimento,
       SYS_GET_IDADE_FNC(be.data_nascimento, sysdate) Idade,
       
       (select distinct max(fe.desc_faixa) 
        from ts.faixa_etaria fe
        where fe.tipo_faixa = 2
              and fe.cod_faixa_etaria = ts_obtem_faixa_etaria(be.data_nascimento, sysdate) Faixa_Etária,
              
       be.ind_sexo Sexo,
       pm.nome_plano Plano,
       bc.data_adesao Vigencia_Beneficiario,
       b.data_exclusao Data_Exclusao,
       (select sys_get_vlr_cont_fe_fnc(2, ce.cod_ts_contrato, pm.cod_plano, 
                                       b.tipo_associado, 
                                       SYS_GET_IDADE_FNC(be.data_nascimento, 
                                       sysdate), sysdate) from dual) as Valor
       
              
from ts.beneficiario b
     join ts.beneficiario_contrato bc on bc.cod_ts = b.cod_ts
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
                                 and ec.cod_entidade_ts = b.cod_empresa
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa

where ce.num_contrato IN (15277) 
      and (b.data_exclusao is null or b.data_exclusao > trunc(sysdate))
/*
ce.num_contrato IN (23753,
23754,
23762,
23831,
23832,
23839,
23845,
23847,
23848,
23853,
23857,
23859,
23860,
23945,
23946,
23947,
23948,
23981,
24964,
24965,
24971,
24972,
24974,
24976,
25702,
25704,
25705,
25706,
25710,
25711,
25712,
25834,
25836,
25837,
26930,
25890,
25891,
25892,
25893,
25894,
25895,
25896,
25897,
25898,
25899,
26937,
27431)
*/
order by 1, 3, 2, 10, 11 desc
