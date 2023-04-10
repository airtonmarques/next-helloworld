/* Formatted on 04/02/2021 13:22:48 (QP5 v5.360) */
DECLARE
    codContModelo        NUMBER := 21941; --COD_TS_CONTRATO do Contrato Modelo
    msgerror             VARCHAR2 (4000);
    codTsContrato        NUMBER;
    numContratoNew       VARCHAR2 (10);
    dtFimImplantação   DATE := TO_DATE ('30/04/2021', 'DD/MM/YYYY'); --Data fim da implantação
    codGrupoEmpresa      NUMBER := 30221; --Código do grupo de empresas
BEGIN
    --> Carrega dados para insert da Empresa no AllSys
    FOR emp
        IN (SELECT ts_entidade_seq.NEXTVAL@allsys_dbl
                       cod_entidade_ts,
                   ts_cod_empresa_seq.NEXTVAL@allsys_dbl
                       cod_empresa,
                   a.razao
                       nome_razao_social,
                   a.razao
                       nome_entidade,
                   'J'
                       ind_tipo_pessoa,
                   SYSDATE
                       dt_inclusao,
                   SYSDATE
                       dt_atu,
                   REGEXP_REPLACE (a.cnpj, '[^0-9]', '')
                       num_cgc,
                   NULL
                       num_inscr_estadual,
                   NULL
                       num_insc_muni,
                   'RAFAQUESI'
                       cod_usuario_atu,
                   'N'
                       ind_titular,
                   'N'
                       ind_dependente,
                   'N'
                       ind_produtor,
                   'S'
                       ind_contrato,
                   'N'
                       Ind_Prestador,
                   CURRENT_TIMESTAMP
                       ctr_optlock,
                   1
                       num_seq_end,
                   NULL
                       cod_municipio,
                   a.ENDERECO
                       nom_logradouro,
                   a.NUMERO
                       num_endereco,
                   NULL
                       txt_complemento,
                   NULL
                       cod_bairro,
                   REGEXP_REPLACE (a.cep, '[^0-9]', '')
                       num_cep,
                   A.DDD
                       num_ddd_telefone_1,
                   REGEXP_REPLACE (A.TELEFONE, '[^0-9]', '')
                       num_telefone_1,
                   NULL
                       num_ddd_telefone_2,
                   NULL
                       num_telefone_2,
                   NULL
                       num_ddd_telefone_3,
                   NULL
                       num_telefone_3,
                   NULL
                       num_celular,
                   'N'
                       ind_residencia,
                   'S'
                       ind_corresp,
                   'S'
                       ind_cobranca,
                   a.bairro
                       nome_bairro,
                   a.UF
                       sgl_uf,
                   'S'
                       ind_end_ok,
                   NULL
                       num_ramal_1,
                   NULL
                       num_ramal_2,
                   NULL
                       num_ramal_3,
                   NULL
                       ddd_celular,
                   'N'
                       ind_exterior,
                   A.EMAIL
                       end_email,
                   a.cidade,
                   A.CNPJ,
                   codGrupoEmpresa
                       cod_grupo_empresa 
              FROM ALL_EMP_DEMANDA_4608_TEMP a
             WHERE NVL (IMPORTADO, 0) = 0 AND ROWNUM <= 200)
    LOOP
        BEGIN
            INSERT INTO ts.entidade_sistema@allsys_dbl (
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
                         NULL,
                         NULL,
                         emp.dt_inclusao,
                         NULL,
                         NULL,
                         NULL,
                         emp.num_insc_muni,
                         emp.dt_atu,
                         emp.cod_entidade_ts,
                         emp.cod_empresa,
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
                         emp.cod_grupo_empresa,
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
        EXCEPTION
            WHEN OTHERS
            THEN
                BEGIN
                    alt_msg.set_log (
                        'Debug',
                        46,
                        0,
                        'Nome:' || EMP.nome_razao_social,
                        'MigCad:' || EMP.cod_entidade_ts,
                        'SQLERRM: ' || SQLERRM,
                        'SQLCODE: ' || SQLCODE,
                        SUBSTR ('STACK: ' || DBMS_UTILITY.format_call_stack,
                                1,
                                4000));

                    msgerror := SYS_RETURN_ERROR (SQLERRM);
                    DBMS_OUTPUT.PUT_LINE ('msgerror = ' || msgerror);
                    RETURN;
                END;
        END;

        --> -> Carrega dados para insert do endereço da Empresa no AllSys
        DECLARE
            codMunicipio   NUMBER;
        BEGIN
            BEGIN
                SELECT cod_municipio
                  INTO codMunicipio
                  FROM ts.municipio@allsys_dbl
                 WHERE UPPER (NOM_MUNICIPIO) LIKE UPPER (emp.cidade)
                   and upper(SGL_UF) = upper(emp.sgl_uf);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    codMunicipio := NULL;
            END;



            INSERT INTO ts.enderecos@allsys_dbl (cod_entidade_ts,
                                                 num_seq_end,
                                                 cod_municipio,
                                                 nom_logradouro,
                                                 num_endereco,
                                                 txt_complemento,
                                                 cod_bairro,
                                                 num_cep,
                                                 num_telefones,
                                                 num_fax,
                                                 end_email,
                                                 num_bip,
                                                 dt_atu,
                                                 num_celular,
                                                 ind_residencia,
                                                 ind_corresp,
                                                 ind_cobranca,
                                                 nome_bairro,
                                                 nome_cidade,
                                                 sgl_uf,
                                                 ind_end_ok,
                                                 ind_origem_atualizacao,
                                                 cod_tipo_logr,
                                                 num_ddd_telefone_1,
                                                 num_telefone_1,
                                                 num_ddd_telefone_2,
                                                 num_telefone_2,
                                                 num_ddd_telefone_3,
                                                 num_telefone_3,
                                                 num_ddd_fax,
                                                 cod_usuario_atu,
                                                 num_ramal_1,
                                                 num_ramal_2,
                                                 num_ramal_3,
                                                 ddd_celular,
                                                 num_caixa_postal,
                                                 num_sac,
                                                 txt_end_completo,
                                                 cod_pais,
                                                 ind_exterior,
                                                 ind_envia_sms,
                                                 ind_envia_mms,
                                                 ind_envia_email,
                                                 ctr_optlock,
                                                 num_telefone_4,
                                                 num_telefone_5,
                                                 num_ddd_telefone_4,
                                                 num_ddd_telefone_5,
                                                 num_ramal_4,
                                                 num_ramal_5,
                                                 nom_contato_1,
                                                 nom_contato_2,
                                                 nom_contato_3,
                                                 nom_contato_4,
                                                 nom_contato_5,
                                                 end_email_2,
                                                 end_email_3,
                                                 mig_seq_end,
                                                 ind_email_efaturamento,
                                                 ind_reembolso,
                                                 ind_pagamento)
                 VALUES (emp.cod_entidade_ts,
                         emp.num_seq_end,
                         codMunicipio,
                         emp.nom_logradouro,
                         emp.num_endereco,
                         emp.txt_complemento,
                         emp.cod_bairro,
                         emp.num_cep,
                         NULL,
                         NULL,
                         emp.end_email,
                         NULL,
                         emp.dt_atu,
                         emp.num_celular,
                         emp.ind_residencia,
                         emp.ind_corresp,
                         emp.ind_cobranca,
                         emp.nome_bairro,
                         NULL,
                         emp.sgl_uf,
                         emp.ind_end_ok,
                         NULL,
                         NULL,
                         emp.num_ddd_telefone_1,
                         emp.num_telefone_1,
                         emp.num_ddd_telefone_2,
                         emp.num_telefone_2,
                         emp.num_ddd_telefone_3,
                         emp.num_telefone_3,
                         NULL,
                         emp.cod_usuario_atu,
                         emp.num_ramal_1,
                         emp.num_ramal_2,
                         emp.num_ramal_3,
                         emp.ddd_celular,
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
                         NULL);
        EXCEPTION
            WHEN OTHERS
            THEN
                BEGIN
                    alt_msg.set_log (
                        'Debug',
                        46,
                        0,
                        'Nome:' || EMP.nome_razao_social,
                        'MigCad:' || EMP.cod_entidade_ts,
                        'SQLERRM: ' || SQLERRM,
                        'SQLCODE: ' || SQLCODE,
                        SUBSTR ('STACK: ' || DBMS_UTILITY.format_call_stack,
                                1,
                                4000));
                    msgerror := SYS_RETURN_ERROR (SQLERRM);
                    DBMS_OUTPUT.PUT_LINE ('msgerror = ' || msgerror);
                    RETURN;
                END;
        END;

        DECLARE
            rAltCont              alt_cont%ROWTYPE;
            sNumContAllsys        VARCHAR2 (20);
            dDtIniVigContAllsys   DATE;
            sCodCadMigEmp         VARCHAR2 (200);
            iCodSucursal          NUMBER;
            iCodInspetoria        NUMBER;
            ReturnPcd             VARCHAR2 (4000) := NULL;
        BEGIN
            BEGIN
                SELECT cod_entidade_ts
                  INTO sCodCadMigEmp
                  FROM ts.ENTIDADE_SISTEMA@allsys_dbl
                 WHERE cod_entidade_ts = emp.cod_entidade_ts;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    ROLLBACK;
                    ReturnPcd :=
                        SYS_RETURN_ERROR (
                            'Empresa não localizada no sistema AllSys.');
                    RETURN;
            END;

            BEGIN
                SELECT num_contrato,
                       data_inicio_vigencia,
                       cod_sucursal,
                       cod_inspetoria_ts
                  INTO sNumContAllsys,
                       dDtIniVigContAllsys,
                       iCodSucursal,
                       iCodInspetoria
                  FROM ts.contrato_empresa@allsys_dbl a
                 WHERE a.cod_ts_contrato = codContModelo;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    ROLLBACK;
                    ReturnPcd :=
                        SYS_RETURN_ERROR (
                            'Contrato modelo não encontrado no sistema AllSys');
                    RETURN;
            END;

            DECLARE
                v_nome_entidade          VARCHAR2 (4000);
                v_dt_ini_vigencia_out    DATE;
                v_ind_erro_out           VARCHAR2 (4000);
                v_msg_retorno_out        VARCHAR2 (4000);
                v_cod_titular_contrato   NUMBER;
                v_cod_ts_contrato_novo   VARCHAR2 (400);
            BEGIN
                ts.con_copia_contrato@allsys_dbl (
                    p_cod_ts_contrato        => codContModelo,
                    p_num_contrato           => sNumContAllsys,
                    p_dt_ini_vigencia        => dDtIniVigContAllsys,
                    p_cod_entidade_ts        => sCodCadMigEmp,
                    p_dt_ini_vigencia_nova   => NULL,
                    p_cod_usuario            => 'RAFAQUESI',
                    p_cod_sucursal           => iCodSucursal,
                    p_cod_inspetoria_ts      => iCodInspetoria,
                    p_endereco_ip            => '10.203.92.12',
                    p_cod_ts_contrato_novo   => v_cod_ts_contrato_novo,
                    p_nome_entidade          => v_nome_entidade,
                    p_cod_titular_contrato   => v_cod_titular_contrato,
                    p_dt_ini_vigencia_out    => v_dt_ini_vigencia_out,
                    p_ind_erro_out           => v_ind_erro_out,
                    p_msg_retorno_out        => v_msg_retorno_out,
                    p_commit                 => 'N',
                    p_versao                 => '1');
                codTsContrato := NULL;
                codTsContrato := v_cod_ts_contrato_novo;

                IF v_ind_erro_out != 0
                THEN
                    alt_msg.set_log (
                        'Debug',
                        46,
                        0,
                        'Indicador:' || v_ind_erro_out,
                        'MsgRetorno:' || v_msg_retorno_out,
                        'VigInicialOut:' || v_dt_ini_vigencia_out,
                        'CodTitularContrato:' || v_cod_titular_contrato,
                        'NomeEntidade^:' || v_nome_entidade);
                    ROLLBACK;

                    ReturnPcd :=
                        SYS_RETURN_ERROR (
                            'Não foi possível copiar o contrato.');
                    RETURN;
                ELSE
                    UPDATE ts.empresa_contrato@allsys_dbl
                       SET NOM_EMPRESA_CARTAO = emp.nome_razao_social,
                           COD_ENTIDADE_TS = emp.cod_entidade_ts,
                           COD_EMPRESA_CONTRATO = emp.cod_empresa
                     WHERE COD_TS_CONTRATO = codTsContrato;

                    UPDATE ts.contrato_empresa@allsys_dbl
                       SET DT_FIM_IMPLANTACAO = dtFimImplantação
                     WHERE COD_TS_CONTRATO = codTsContrato;
                END IF;
            END;

            DECLARE
                v_msg_retorno_out   VARCHAR2 (4000);
                v_ind_erro_out      VARCHAR2 (4000);
                v_num_contrato      VARCHAR2 (4000);
            BEGIN
                TS.CON_FINALIZA_IMPLANTACAO@allsys_dbl (
                    p_cod_ts_contrato   => codTsContrato,
                    p_cod_usuario       => 'RAFAQUESI',
                    p_endereco_ip       => '10.203.92.12',
                    p_num_contrato      => v_num_contrato,
                    p_ind_erro_out      => v_ind_erro_out,
                    p_msg_retorno_out   => v_msg_retorno_out,
                    p_commit            => 'N',
                    p_versao            => 'N');

                numContratoNew := v_num_contrato;

                IF v_ind_erro_out != 0
                THEN
                    alt_msg.set_log ('Debug',
                                     46,
                                     0,
                                     'Indicador:' || v_ind_erro_out,
                                     'MsgRetorno:' || v_msg_retorno_out,
                                     'codTsContrato:' || codTsContrato);
                    ROLLBACK;

                    ReturnPcd :=
                        SYS_RETURN_ERROR (
                            'Não foi possível copiar o contrato.');
                    RETURN;
                END IF;
            END;

            IF ReturnPcd IS NOT NULL
            THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE (
                    'ReturnPcd = ' || ReturnPcd || 'Erro para: ' || EMP.CNPJ);
            ELSE
                UPDATE ALL_EMP_DEMANDA_4608_TEMP
                   SET IMPORTADO = -1,
                       cod_entidade_ts = sCodCadMigEmp,
                       cod_ts_contrato = codTsContrato,
                       num_contrato = numContratoNew
                 WHERE CNPJ = EMP.CNPJ;

                COMMIT;
            END IF;
        END;
    END LOOP;
END;
/