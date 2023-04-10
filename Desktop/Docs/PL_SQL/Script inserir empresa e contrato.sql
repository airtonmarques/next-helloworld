﻿BEGIN

declare
  iCodEmpresa       NUMBER;
  ICodEntidadeTs    NUMBER;
	iContratoModelo   number;
	idSubContratante  VARCHAR2 (4000);
	vSql              CLOB;
	sReturn           VARCHAR2 (4000);
	operadora         VARCHAR2(500);
	existePlano       number;
	valor             NUMBER(38,2);
	planosEncontrados varchar2(500);
	
  sNumContAllsys      VARCHAR2(20);
  dDtIniVigContAllsys DATE;
	dtIniVigencia DATE;
  iCodSucursal        NUMBER;
  iCodInspetoria      NUMBER;
	
	
	--Variáveis de Retorno
	  v_nome_entidade        VARCHAR2(4000);
    v_dt_ini_vigencia_out  DATE;
    v_ind_erro_out         VARCHAR2(4000);
    v_msg_retorno_out      VARCHAR2(4000);
    v_cod_titular_contrato NUMBER;
    v_cod_ts_contrato_novo VARCHAR2(400);
		

begin
  iContratoModelo := 44423;	
	--idSubContratante := '1734136, 1734137, 1702232, 1702233, 1702234, 1701162, 1701167, 1770901, 1985174, 1985175, 1985176, 1985177, 1985178, 1985179, 1985180, 1985181, 1985182, 1985183, 2003755, 2003756, 2003757, 1771251, 1937767, 1716575, 1753766, 772557, 813984, 1900063, 1900068, 1919489, 1921423, 1935266, 1935267, 1935268, 1935270, 1935271, 1935274, 2003964, 1764207, 804779, 804781, 804777, 2024453, 1112469, 874734, 814042, 845647, 862953, 888665, 888668, 888672, 1295066, 866791, 1750246, 1986084, 874976, 885561, 901935, 895239, 901994, 921831, 1074469, 1031996, 983802, 986900, 1117662, 1031997, 1031998, 1035453, 1040847, 1040850, 1040853, 1108021, 1759444, 1759509, 1767991, 1767993, 1767994, 1767995, 1767996, 1767997, 1702224, 1702225, 1702226, 1772083, 1703253, 1703254, 1722898, 1991267, 1991268, 1991269, 1991270, 1702261, 1917905, 1937754, 1967959, 1967968, 1967969, 1977001, 1978359, 1980928, 1980930, 1934019, 1934020, 1980931, 1980932, 1980933, 1980934, 1980938, 1980940, 1980942, 1980944, 1980945, 1980947, 1980948, 1980949, 1980950, 1980951, 1980953, 1980954, 1980955, 1980956, 1980957, 1980958, 1980959, 1980962, 1980963, 1980968, 1980972, 1980973, 1980976, 1980979, 1980982, 1980983, 1980984, 1980985, 1980990, 1980992, 1980993, 1980994, 1994882, 1995528, 1998503, 2026041, 2026042, 2026572, 2022730, 2022731, 2022732, 2022733, 2022734, 2022735, 2023195, 1980999, 1988407, 2011313';
	--operadora := 'METLIFE';
	dtIniVigencia := '01/03/2023';
	
	
----------------------------------------------------------
-- Insere na Entidade Sistema
--> Carrega dados para insert da Empresa no AllSys
        FOR emp
            IN (SELECT c.razao_social_subcontrato nome_razao_social,
                       c.nome_fantasia_subcontrato nome_entidade,
                       'J' ind_tipo_pessoa,
                       sysdate dt_inclusao,
                       sysdate dt_atu,
                       c.cnpj_cpf_subcontrato num_cgc,
                       '0' num_inscr_estadual,
                       '0' num_insc_muni,
                       'RAFAQUESI' cod_usuario_atu,
                       'N' ind_titular,
                       'N' ind_dependente,
                       'N' ind_produtor,
                       'S' ind_contrato,
                       'N' Ind_Prestador,
                       CURRENT_TIMESTAMP ctr_optlock,
                       'M' ind_sexo,
											 c.inicio_de_vigencia
                  FROM pm_contrato c
                 WHERE c.id_subcontrato IN (752033, 830104, 960754, 1163670, 1411923, 1543392, 1638507, 1649994, 1799450, 754541, 1026997, 920355, 762610, 755098, 760111, 1052139, 755109, 1123456, 759424, 763226, 831484, 754534, 918525, 754104, 1431713))--ID DO CONTRATANTE DA EMPRESA
								       --and c.operadora like '%' || operadora || '%')--OPERADORA 
        LOOP
            BEGIN
							
  --> Obtem Novo c�digo de Empresa
  vSql := 'SELECT ts_cod_empresa_seq.NEXTVAL from dual';
  EXECUTE IMMEDIATE vSql INTO iCodEmpresa;

  --> Obtem o novo c�digo da entidade
  vSql := 'SELECT ts_entidade_seq.NEXTVAL from dual';
  EXECUTE IMMEDIATE vSql INTO ICodEntidadeTs;			
						
INSERT INTO ts.entidade_sistema ( 
                                ind_tipo_pessoa,
                                num_cgc,
                                nome_razao_social,
                                nome_entidade,
                                data_nascimento,
                                ind_sexo,
                                num_cpf,
                                dt_inclusao,
                                ind_origem_inclusao,
                                nome_mae,
                                ind_estado_civil,
                                num_insc_muni,
                                dt_atu,
                                cod_entidade_ts,
                                cod_empresa,
                                num_pis,
                                num_unico_saude,
                                txt_obs,
                                ult_nome_entidade,
                                num_identidade,
                                cod_pais_emissor,
                                ind_nacionalidade,
                                cod_cnae,
                                cod_cbo,
                                num_cei,
                                num_inscr_estadual,
                                nome_pai,
                                cod_escolaridade,
                                dt_fundacao,
                                dt_falecimento,
                                dt_formatura,
                                cod_usuario_atu,
                                naturalidade_pf,
                                cod_tipo_atividade,
                                ind_estrangeiro,
                                cod_grupo_empresa,
                                ind_titular,
                                ind_dependente,
                                ind_produtor,
                                ind_contrato,
                                ind_prestador,
                                ind_exporta_cliente_erp,
                                dt_exporta_cliente_erp,
                                nome_entidade_pesquisa,
                                ind_exportacao_erp,
                                dt_exportacao_erp,
                                num_nit,
                                cod_orgao_emissor,
                                cod_cbo_s,
                                cod_cliente_erp,
                                cod_sistema_origem,
                                num_inss,
                                num_classe_inss,
                                num_ccm,
                                ctr_optlock,
                                ind_benef_interc_titular,
                                ind_benef_interc_dependente,
                                swp_cod_cbo,
                                swp_cod_cbo_s,
                                cod_unimed,
                                num_autoid_cliente_logix,
                                xxx,
                                mig_cod_prestador,
                                nom_logo_entidade,
                                cod_sgec,
                                ind_existe_pasta,
                                num_caepf)
                     VALUES (emp.ind_tipo_pessoa,
                             emp.num_cgc,
                             emp.nome_razao_social,
                             emp.nome_entidade,
                             NULL,
                             emp.ind_sexo, --NULL,
                             NULL,
                             emp.dt_inclusao,
                             NULL,
                             NULL,
                             NULL,
                             emp.num_insc_muni,
                             emp.dt_atu,
                             ICodEntidadeTs,
                             iCodEmpresa,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             emp.num_inscr_estadual,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             emp.cod_usuario_atu,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             emp.ind_titular,
                             emp.ind_dependente,
                             emp.ind_produtor,
                             emp.ind_contrato,
                             emp.ind_prestador,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             emp.ctr_optlock,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             NULL);
														 
														 
------------------------------------------------------------------------------------
 SELECT  num_contrato,
           data_inicio_vigencia,
           cod_sucursal,
           cod_inspetoria_ts
      INTO sNumContAllsys,
           dDtIniVigContAllsys,
           iCodSucursal,
           iCodInspetoria
      FROM ts.contrato_empresa a
     WHERE a.cod_ts_contrato = iContratoModelo; --Contrato Modelo			
		 
------------------------------------------------------------------------------------		

--COPIA O CONTRATO
ts.con_copia_contrato (p_cod_ts_contrato      => iContratoModelo,
                                 p_num_contrato         => sNumContAllsys,
                                 p_dt_ini_vigencia      => dDtIniVigContAllsys,
                                 p_cod_entidade_ts      => ICodEntidadeTs,
                                 p_dt_ini_vigencia_nova => dtIniVigencia,
                                 p_cod_usuario          => 'RAFAQUESI',
                                 p_cod_sucursal         => iCodSucursal,
                                 p_cod_inspetoria_ts    => iCodInspetoria,
                                 p_endereco_ip          => '10.203.92.12',
                                 p_cod_ts_contrato_novo => v_cod_ts_contrato_novo,
                                 p_nome_entidade        => v_nome_entidade,
                                 p_cod_titular_contrato => v_cod_titular_contrato,
                                 p_dt_ini_vigencia_out  => v_dt_ini_vigencia_out,
                                 p_ind_erro_out         => v_ind_erro_out,
                                 p_msg_retorno_out      => v_msg_retorno_out,
                                 p_commit               => 0,
                                 p_versao               => '1');
																 
-----------------------------------------------------------------------------------
--updates necessários

update ts.contrato_empresa ce
set ce.cod_grupo_empresa = null
where ce.cod_ts_contrato = v_cod_ts_contrato_novo;
----------------------------------------------------

commit;

end;
end loop;

--dbms_output.put_line(v_cod_ts_contrato_novo);

end;
END;  
