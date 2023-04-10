DECLARE
    rAltProp      alt_proP%ROWTYPE;
    rAltPropCom   alt_prop_com%ROWTYPE;
    MsgError      VARCHAR2 (4000);
    iCountHrqa    NUMBER;
    iCodProdutorTs number;
BEGIN
    FOR P
        IN (  SELECT *
                FROM ppf_proposta@allsys
               WHERE     COD_USUARIO_INCLUSAO = 'RAFAQUESI'
                     AND TRUNC (DT_INCLUSAO_PROPOSTA) BETWEEN TO_DATE (
                                                                  '24/09/2021',
                                                                  'DD/MM/YYYY')
                                                          AND TO_DATE (
                                                                  '29/09/2021',
                                                                  'DD/MM/YYYY')
                     AND cod_produtor_ts IS NULL
            ORDER BY DT_INCLUSAO_PROPOSTA DESC)
    LOOP
        BEGIN
            iCountHrqa := 0;

            SELECT a.*
              INTO rAltProp
              FROM alt_prop a
             WHERE a.cod_prop_allsys = p.num_proposta_adesao;

            SELECT *
              INTO rAltPropCom
              FROM alt_prop_com
             WHERE     cod_prop = rAltProp.cod_prop
                   AND cod_perfil = 4
                   AND ROWNUM = 1;

            SELECT COUNT (*)
              INTO iCountHrqa
              FROM alt_prop_com
             WHERE cod_prop = rAltProp.cod_prop AND cod_perfil = 3;

            IF iCountHrqa <= 0
            THEN
                alt_vendas_insere_hierarq_pcd (rAltProp.cod_prop,
                                               rAltProp.cod_equipe,
                                               rAltPropCom.cod_tipo_cad,
                                               rAltPropCom.cod_cad,
                                               MsgError);

                IF MsgError != '-1'
                THEN
                    ROLLBACK;
                    DBMS_OUTPUT.PUT_LINE ('PROP:'||rAltProp.cod_prop||' MsgError = ' || MsgError);
                    CONTINUE;
                END IF;
            END IF;

            iCountHrqa := 0;

            SELECT COUNT (*)
              INTO iCountHrqa
              FROM alt_prop_com
             WHERE cod_prop = rAltProp.cod_prop AND cod_perfil = 3;

            IF iCountHrqa <= 0
            THEN
                    ROLLBACK;
                DBMS_OUTPUT.PUT_LINE (
                       'PROP:'
                    || rAltProp.cod_prop
                    || ' sem corretora, hierarquia falhou');
                    CONTINUE;
            END IF;


            SELECT MAX (cod_cad)
              INTO iCodProdutorTs
              FROM alt_prop_com
             WHERE cod_prop =  rAltProp.cod_prop AND cod_tipo_cad = 3 AND cod_perfil = 3;


             update ppf_proposta@allsys pf
             set cod_produtor_ts = iCodProdutorTs
             where pf.num_proposta_adesao = p.num_proposta_adesao;

            COMMIT;
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE ('PROP:' || rAltProp.cod_prop);
                DBMS_OUTPUT.PUT_LINE ('SQMERRM:' || SQLERRM);
                DBMS_OUTPUT.PUT_LINE ('BACKTRACE:' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        END;
    END LOOP;
END;