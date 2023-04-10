select distinct 
       '1' || --1 fixo
       lpad(op.num_cnpj, 14, '0') || --14 cnpj operadora
       lpad(op.nom_razao_social, 100, '') || --100 Nome Operadora
       to_char(sysdate, 'mmyyyy') || --6 Compet�ncia
       (select lpad(b1.num_matric_empresa, 14, '0') 
        from ts.beneficiario b1 
        where b1.cod_ts = b.cod_ts_tit) || --9 Matricula
       (select lpad(be1.num_cpf, 11, '0') 
        from ts.beneficiario b2 
             join ts.beneficiario_entidade be1 on be1.cod_entidade_ts = b2.cod_entidade_ts
        where b2.cod_ts = b.cod_ts_tit) || --11 CPF Titular
       lpad(be.num_cpf, 11, '0') || --11 CPF Benefici�rio
       ''--1 Tipo dependente
       
       
       
       
       
       ce.num_contrato Contrato,       
       ec.nom_empresa_cartao Empresa,
       op.nom_operadora Operadora,
       porte.nome_tipo_empresa Porte,
       ce.ind_situacao Status,
       decode(ce.ind_tipo_produto, 1, 'M�dico', 2, 'Dental') Produto,
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
              and fe.cod_faixa_etaria = ts_obtem_faixa_etaria(be.data_nascimento, sysdate)) Faixa_Et�ria,
              
       be.ind_sexo Sexo,
       td.nome_dependencia Dependencia,
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
                                 and (b.cod_empresa is null OR ec.cod_entidade_ts = b.cod_empresa)
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     left join ts.tipo_dependencia td on td.cod_dependencia = b.cod_dependencia

where  ce.num_contrato in ('24397')

--ce.num_contrato IN (15277) 
      
/*ce.num_contrato IN (23753,
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
27431)*/
and (b.data_exclusao is null or b.data_exclusao > trunc(sysdate))
order by 1, 3, 2, 10, 11 desc
