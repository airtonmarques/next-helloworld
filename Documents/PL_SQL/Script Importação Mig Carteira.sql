/* Formatted on 19/04/2022 10:25:41 (QP5 v5.381) */
DECLARE
    sCodUsuAllsys   VARCHAR2 (30) := 'ADMIN';
    nSeqCont        NUMBER;
    nCountAux       NUMBER := 0;
BEGIN
    FOR c
        IN (SELECT I.COD_TS,
                   I.EMAIL,
                   I.LOGRADOURO,
                   I.NUMERO,
                   I.TELEFONE,
                   B.COD_ENTIDADE_TS,
                   B.COD_TS_CONTRATO,
                   SUBSTR (REGEXP_REPLACE (I.TELEFONE, '[^[:digit:]]'), 0, 2)
                       DDD,
                   SUBSTR (REGEXP_REPLACE (I.TELEFONE, '[^[:digit:]]'), 3)
                       NUMERO_CEL
              FROM IMPORTACAO_GENERICA_TEMP I, BENEFICIARIO B
             WHERE I.COD_TS = B.COD_TS)
    LOOP
        BEGIN
            nSeqCont := NULL;

            IF c.email IS NOT NULL
            THEN
                SELECT COUNT (*)
                  INTO nCountAux
                  FROM BENEFICIARIO_CONTATO
                 WHERE     COD_ENTIDADE_TS = C.COD_ENTIDADE_TS
                       AND LOWER (end_email) = LOWER (c.email);

                IF nCountAux = 0
                THEN
                    INSERT INTO BENEFICIARIO_CONTATO (num_seq_contato,
                                                      cod_entidade_ts,
                                                      ind_class_contato,
                                                      end_email,
                                                      ind_envia_email,
                                                      ind_email_efaturamento,
                                                      dt_atu,
                                                      cod_usuario_atu)
                         VALUES (ts_beneficiario_contato_seq.NEXTVAL,
                                 c.cod_entidade_ts,
                                 'E',
                                 c.email,
                                 'S',
                                 'S',
                                 SYSDATE,
                                 'ADMIN')
                      RETURNING NUM_SEQ_CONTATO
                           INTO nSeqCont;
                END IF;
            END IF;

            nCountAux := 0;

            IF C.LOGRADOURO IS NOT NULL
            THEN
                SELECT COUNT (*)
                  INTO nCountAux
                  FROM BENEFICIARIO_ENDERECO
                 WHERE     COD_ENTIDADE_TS = C.COD_ENTIDADE_TS
                       AND LOWER (nom_logradouro) != LOWER (c.logradouro);

                IF nCountAux = 1
                THEN
                    UPDATE BENEFICIARIO_ENDERECO
                       SET nom_logradouro = c.logradouro,
                           NUM_ENDERECO = C.NUMERO
                     WHERE COD_ENTIDADE_TS = C.COD_ENTIDADE_TS;
                END IF;
            END IF;

            IF c.TELEFONE IS NOT NULL
            THEN
                SELECT MAX (NUM_SEQ_CONTATO)
                  INTO nCountAux
                  FROM BENEFICIARIO_CONTATO
                 WHERE     COD_ENTIDADE_TS = C.COD_ENTIDADE_TS
                       AND LOWER (NUM_TELEFONE) = LOWER (c.NUMERO_CEL);

                IF nCountAux IS NULL OR nCountAux = 0
                THEN
                    INSERT INTO BENEFICIARIO_CONTATO (num_seq_contato,
                                                      cod_entidade_ts,
                                                      ind_class_contato,
                                                      num_ddd,
                                                      num_telefone,
                                                      ind_envia_email,
                                                      ind_email_efaturamento,
                                                      dt_atu,
                                                      cod_usuario_atu)
                         VALUES (ts_beneficiario_contato_seq.NEXTVAL,
                                 c.cod_entidade_ts,
                                 'C',
                                 c.DDD,
                                 c.NUMERO_CEL,
                                 'N',
                                 'N',
                                 SYSDATE,
                                 'ADMIN')
                      RETURNING NUM_SEQ_CONTATO
                           INTO nSeqCont;
                ELSIF nCountAux IS NOT NULL
                THEN
                    UPDATE BENEFICIARIO_CONTATO
                       SET num_telefone = c.NUMERO_CEL, num_ddd = c.DDD
                     WHERE num_seq_contato = nCountAux;
                END IF;
            END IF;

            -- Begin E-Faturamento
            -- Gerar ocorrência
            --            IF nSeqCont IS NOT NULL
            --            THEN
            --                INSERT INTO OCORRENCIA_CONTRATO (COD_TS_CONTRATO,
            --                                                 COD_OCORRENCIA,
            --                                                 DT_OCORRENCIA,
            --                                                 DT_FATO,
            --                                                 TXT_OBS,
            --                                                 COD_USUARIO_ATU,
            --                                                 DT_ATU)
            --                         VALUES (
            --                                    c.cod_ts_contrato,
            --                                    51,
            --                                    SYSDATE,
            --                                    TRUNC (SYSDATE),
            --                                    DECODE (
            --                                        'S',
            --                                        'S',    'Adesão ao eFaturamento em '
            --                                             || TO_CHAR (
            --                                                    SYSDATE,
            --                                                    'dd/mm/RRRR hh24:mi')
            --                                             || ' por '
            --                                             || sCodUsuAllsys,
            --                                           'Cancelamento do eFaturamento '
            --                                        || TO_CHAR (SYSDATE,
            --                                                    'dd/mm/RRRR hh24:mi')
            --                                        || ' por '
            --                                        || sCodUsuAllsys),
            --                                    sCodUsuAllsys,
            --                                    SYSDATE);
            --
            --                INSERT INTO OCORRENCIA_ASSOCIADO (COD_TS,
            --                                                  COD_OCORRENCIA,
            --                                                  DT_OCORRENCIA,
            --                                                  TXT_OBS,
            --                                                  DT_FATO,
            --                                                  COD_USUARIO_ATU)
            --                         VALUES (
            --                                    c.cod_ts,
            --                                    203,
            --                                    SYSDATE,
            --                                       'Adesão ao eFaturamento em '
            --                                    || TO_CHAR (SYSDATE,
            --                                                'dd/mm/RRRR hh24::mi')
            --                                    || ' por '
            --                                    || sCodUsuAllsys,
            --                                    TRUNC (SYSDATE),
            --                                    sCodUsuAllsys);
            --
            --                UPDATE BENEFICIARIO_FATURAMENTO
            --                   SET IND_EFATURAMENTO = 'S',
            --                       DT_INI_EFATURAMENTO = TRUNC (SYSDATE)
            --                 WHERE cod_ts = c.cod_ts;
            --
            --                --
            --                -- Persistir contrato
            --
            --                UPDATE CONTRATO_EMPRESA
            --                   SET IND_EFATURAMENTO = 'S',
            --                       DT_INI_EFATURAMENTO = TRUNC (SYSDATE),
            --                       DT_ATU = SYSDATE,
            --                       COD_USUARIO_ATU = sCodUsuAllsys
            --                 WHERE COD_TS_CONTRATO = c.cod_ts_contrato;
            --            -- End E-Faturamento
            --            END IF;

            COMMIT;
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE (
                       'COD_TS:'
                    || c.cod_ts
                    || ' ERRO:'
                    || SQLERRM
                    || ' BACKTRACE:'
                    || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        END;
    END LOOP;
END;