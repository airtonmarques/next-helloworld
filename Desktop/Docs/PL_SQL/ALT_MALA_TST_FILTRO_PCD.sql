CREATE OR REPLACE PROCEDURE ALT_MALA_TST_FILTRO_PCD(cod_mala     IN NUMBER,
                                                    tipoquery    IN NUMBER,
                                                    qtde_max     in number,
                                                    MsgError     OUT VARCHAR2,
                                                    cursorReturn OUT SYS_REFCURSOR) AS
  rAltMala      alt_mala%ROWTYPE;
  cursorString  CLOB;
  depSysSendMsg VARCHAR2(100);

  --tipoquery
  --1 - Envio e Teste de Filtro
  --2 - Envio e Teste de Filtro(Enviados)
  --3 - Detalhes

  invalid_date EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_date, -20302);
BEGIN
  rAltMala.cod_mala := cod_mala;

  SELECT a.*
    INTO rAltMala
    FROM alt_mala a
   WHERE a.cod_mala = rAltMala.cod_mala;

  IF rAltMala.ftr_cod_uf IS NULL AND rAltMala.ftr_cod_operadora IS NULL AND
     rAltMala.ftr_cod_contrato IS NULL AND rAltMala.cod_carga IS NULL THEN
    MsgError := 'Ao menos um filtro deve ser preenchido';

    OPEN cursorReturn FOR
      SELECT * FROM DUAL;

    RETURN;
  END IF;

  IF rAltMala.cod_carga IS NULL THEN
    depSysSendMsg := ' pd.cod_prop_dep ';
  ELSE
    depSysSendMsg := ' pdc.cod_prop_dep ';
  END IF;

  IF tipoquery IN (1, 2) THEN
    cursorString := 'WITH
    beneficiarios
    AS
        (  SELECT ROW_NUMBER() OVER (ORDER BY t.nome_cad) KEY_ROW,
                  t.cod_tipo_cad "#COD_TIPO_CAD_BEN",
                  t.cod_cad
                      AS "#COD_CAD_BEN",
                  INITCAP (t.nome_cad)
                      AS "#NOME_CAD_BEN",
                  t.nome_cad
                      AS "#NOME_CAD_BEN_M",
                  INITCAP (t.cod_tratamento)
                      AS "#COD_TRATAMENTO",
                  t.cod_tipo_pessoa
                      AS "#COD_TIPO_PESSOA",
                  TRUNC (t.dt_nasc_cad)
                      AS "#DT_NASC_CAD",
                  sys_format_tel_fnc (ct.pais_cad_tel,
                                      ct.ddd_cad_tel,
                                      ct.num_cad_tel)
                      AS "#NUM_TEL",
                  LOWER (cm.mail_cad_mail)
                      AS "#MAIL",
                  tc.cod_uf
                      AS "#COD_UF",
                  ac.num_cont
                      AS "#COD_CONT",
                  alt_get_nome_cad_fnc (p.cod_tipo_cad_oper, p.cod_cad_oper)
                      AS "#NOME_CAD_OPER",
                  p.cod_prop
                      AS "#COD_PROP",
                  ac.dia_venc_cont 
                      AS "#DIA_VENC_CONT",
                  alt_get_nome_cad_fnc (p.cod_tipo_cad_ent, p.cod_cad_ent)
                      AS "#NOME_CAD_ENT" ';

    IF rAltMala.cod_carga IS NOT NULL THEN
      cursorString := cursorString ||
                      ', pdc.cod_cad_dep as "#COD_CAD_DEP",
                  INITCAP (acd.NOME_CAD) AS "#NOME_CAD_DEP",
                  pdc.cod_prop_dep as "#COD_PROP_DEP",
                  mcd.CAMPO_EXTRA_CARGA_DET_1 AS "#CAMPO_EXTRA_1",
                  mcd.CAMPO_EXTRA_CARGA_DET_2 AS "#CAMPO_EXTRA_2",
                  mcd.CAMPO_EXTRA_CARGA_DET_3 AS "#CAMPO_EXTRA_3",
                  mcd.CAMPO_EXTRA_CARGA_DET_4 AS "#CAMPO_EXTRA_4",
                  mcd.CAMPO_EXTRA_CARGA_DET_5 AS "#CAMPO_EXTRA_5",
                  mcd.ANEXO_MSG AS "#ANEXO_MSG"';
    ELSE
      cursorString := cursorString ||
                      ', pd.cod_cad_dep as "#COD_CAD_DEP",
                  INITCAP (t.NOME_CAD) AS "#NOME_CAD_DEP",
                  pd.cod_prop_dep as "#COD_PROP_DEP",
                  '''' AS "#CAMPO_EXTRA_1",
                  '''' AS "#CAMPO_EXTRA_2",
                  '''' AS "#CAMPO_EXTRA_3",
                  '''' AS "#CAMPO_EXTRA_4",
                  '''' AS "#CAMPO_EXTRA_5",
                  '''' AS "#ANEXO_MSG"';
    END IF;
  ELSIF tipoquery = 3 THEN
    cursorString := 'WITH
    beneficiarios
    AS
        (   SELECT t.cod_tipo_cad || ''.'' || t.cod_cad     key_row,
                  t.cod_cad                              AS "#COD_CAD_BEN",
                  INITCAP (t.nome_cad)                   AS "#NOME_CAD_BEN",
                  LOWER (MAIL_CAD_MAIL)                  AS "#MAIL",
                  SYS_FORMAT_TEL_FNC (ct.PAIS_CAD_TEL,
                                      ct.DDD_CAD_TEL,
                                      ct.NUM_CAD_TEL)    AS "#NUM_TEL",
                  DECODE (ssm.cod_sts_msg,
                          NULL, ''Não Enviado'',
                          1, ''Pendente'',
                          2, ''Enviado'',
                          9, ''Erro'')                     Status
                          ';
  END IF;

  cursorString := cursorString || '
             FROM alt_cad t
                  INNER JOIN alt_cad_end e
                      ON     e.cod_tipo_cad = t.cod_tipo_cad
                         AND e.cod_cad = t.cod_cad
                  INNER JOIN td_alt_bairro b ON b.cod_bairro = e.cod_bairro
                  INNER JOIN td_alt_cidade tc ON b.cod_cidade = tc.cod_cidade
                  INNER JOIN alt_prop_dep pd
                      ON     pd.cod_tipo_cad_dep = t.cod_tipo_cad
                         AND pd.cod_cad_dep = t.cod_cad
                  INNER JOIN alt_prop p ON p.cod_prop = pd.cod_prop
--                         and p.cod_sts_prop = 26
                  INNER JOIN alt_cont ac ON ac.cod_cont = p.cod_cont
                  INNER JOIN alt_prop_dep_prod pdp
                      ON     pd.cod_prop = pdp.cod_prop
                         AND pd.cod_prop_dep = pdp.cod_prop_dep
                  $mail JOIN
                  (SELECT COD_PROP,
                          COD_CAD_MAIL,
                          COD_CAD,
                          COD_TIPO_CAD
                     FROM alt_prop_mail_func pmf
                    WHERE alt_get_cod_chk_mail_mala_fnc (pmf.cod_prop,
                                                         pmf.cod_tipo_cad,
                                                         pmf.cod_cad) =
                          1
                   UNION ALL
                   SELECT ijp.COD_PROP,
                          ijm.COD_CAD_MAIL,
                          ijm.COD_CAD,
                          ijm.COD_TIPO_CAD
                     FROM alt_prop ijp, alt_cad_mail ijm
                    WHERE     ijp.cod_cad_resp = ijm.cod_cad
                          AND ijp.cod_tipo_cad_resp = ijm.cod_tipo_cad
                          AND ijm.chk_prefer_cad_mail = -1
                          AND alt_get_cod_chk_mail_mala_fnc (
                                  ijp.cod_prop,
                                  ijp.cod_tipo_cad_resp,
                                  ijp.cod_cad_resp) =
                              2
                   UNION ALL
                   SELECT ijp.COD_PROP,
                          ijm.COD_CAD_MAIL,
                          ijm.COD_CAD,
                          ijm.COD_TIPO_CAD
                     FROM alt_prop ijp, alt_cad_mail ijm
                    WHERE     ijp.cod_cad_resp = ijm.cod_cad
                          AND ijp.cod_tipo_cad_resp = ijm.cod_tipo_cad
                          AND alt_get_cod_chk_mail_mala_fnc (
                                  ijp.cod_prop,
                                  ijp.cod_tipo_cad_resp,
                                  ijp.cod_cad_resp) =
                              3) rmail
                      ON     rmail.cod_cad = p.cod_cad_resp
                         AND rmail.cod_tipo_cad = p.cod_tipo_cad_resp
                         AND rmail.cod_prop = p.cod_prop
                  $mail JOIN alt_cad_mail cm
                      ON     cm.cod_cad = rmail.cod_cad
                         AND cm.cod_tipo_cad = rmail.cod_tipo_cad
                         AND cm.cod_cad_mail = rmail.cod_cad_mail
                         AND 1 = '||rAltMala.cod_tipo_msg||'
                  $tel JOIN
                  (SELECT ptf.COD_PROP,
                          ct.COD_CAD_TEL,
                          ct.COD_CAD,
                          ct.COD_TIPO_CAD
                     FROM alt_prop_tel_func ptf, alt_cad_tel ct
                    WHERE     ptf.cod_cad = ct.cod_cad
                          AND ptf.cod_tipo_cad = ct.cod_tipo_cad
                          AND LENGTH (NUM_CAD_TEL) = 9
                          AND alt_get_cod_chk_cel_mala_fnc (ptf.cod_prop,
                                                             ptf.cod_tipo_cad,
                                                             ptf.cod_cad) =
                              1
                   UNION ALL
                   SELECT ijp.COD_PROP,
                          ijm.COD_CAD_TEL,
                          ijm.COD_CAD,
                          ijm.COD_TIPO_CAD
                     FROM alt_prop ijp, alt_cad_tel ijm
                    WHERE     ijp.cod_cad_resp = ijm.cod_cad
                          AND ijp.cod_tipo_cad_resp = ijm.cod_tipo_cad
                          AND LENGTH (NUM_CAD_TEL) = 9
                          AND ijm.chk_prefer_cad_tel = -1
                          AND alt_get_cod_chk_cel_mala_fnc (
                                  ijp.cod_prop,
                                  ijp.cod_tipo_cad_resp,
                                  ijp.cod_cad_resp) =
                              2
                   UNION ALL
                   SELECT ijp.COD_PROP,
                          ijm.COD_CAD_TEL,
                          ijm.COD_CAD,
                          ijm.COD_TIPO_CAD
                     FROM alt_prop ijp, alt_cad_tel ijm
                    WHERE     ijp.cod_cad_resp = ijm.cod_cad
                          AND ijp.cod_tipo_cad_resp = ijm.cod_tipo_cad
                          AND LENGTH (NUM_CAD_TEL) = 9
                          AND alt_get_cod_chk_cel_mala_fnc (
                                  ijp.cod_prop,
                                  ijp.cod_tipo_cad_resp,
                                  ijp.cod_cad_resp) =
                              3) rtel
                      ON     rtel.cod_cad = p.cod_cad_resp
                         AND rtel.cod_tipo_cad = p.cod_tipo_cad_resp
                         AND rtel.cod_prop = p.cod_prop
                  $tel JOIN alt_cad_tel ct
                      ON     ct.cod_cad = rtel.cod_cad
                         AND ct.cod_tipo_cad = rtel.cod_tipo_cad
                         AND ct.cod_cad_tel = rtel.cod_cad_tel
                         AND ct.chk_cel_tel = -1
                         AND ct.num_cad_tel IS NOT NULL
                         AND ct.num_cad_tel != 0
                         AND 2 = '||rAltMala.cod_tipo_msg;

  IF rAltMala.cod_carga IS NOT NULL THEN
    cursorString := cursorString || '
                  INNER JOIN alt_mala_carga_det mcd
                      ON mcd.cod_prop = p.cod_prop
                      AND COD_CARGA = ' ||
                    rAltMala.cod_carga || '
                  INNER JOIN alt_prop_dep pdc
                      ON pdc.cod_prop = mcd.cod_prop
                      AND pdc.cod_prop_dep = mcd.cod_prop_dep
                      AND NVL(pdc.chk_exc_allsys, 0) = 0
                  INNER JOIN alt_cad acd
                      ON acd.cod_cad = pdc.cod_cad_dep
                      AND acd.cod_tipo_cad = pdc.cod_tipo_cad_dep';
  END IF;

  IF tipoquery = 3 THEN
    cursorString := cursorString || '
                      LEFT JOIN sys_send_msg ssm
                          ON     ssm.cod_tipo_cad = t.cod_tipo_cad
                             AND ssm.cod_prop = p.cod_prop
                             and ssm.cod_prop_dep = ' ||
                    depSysSendMsg || '
                             AND ssm.cod_cad = t.cod_cad
                             AND ssm.cod_mala = ' ||
                    rAltMala.cod_mala;
  END IF;

  cursorString := cursorString || '
                  WHERE     e.cod_cad_end =
                      (SELECT MAX (xe.cod_cad_end)
                         FROM alt_cad_end xe
                        WHERE     xe.cod_tipo_cad = t.cod_tipo_cad
                              AND xe.cod_cad = t.cod_cad)
                  AND pd.cod_grau_par = 1
                   AND TRUNC(pd.dt_exc_prop_dep) >= TRUNC(SYSDATE) ' ||
                   --AND TRUNC(pd.dt_adm_prop_dep) < TRUNC(SYSDATE)
                  ' AND TRUNC(pd.dt_exc_prop_dep) > TRUNC(pd.dt_adm_prop_dep)
                  AND TRUNC (pdp.dt_fim_prop_dep) >= TRUNC (SYSDATE)
                  AND TRUNC (pdp.dt_fim_prop_dep) > TRUNC (pdp.dt_ini_prop_dep)
                  AND p.cod_sts_prop IN (14, 26)
                  AND NVL(pd.chk_exc_allsys, 0) = 0
                       -- Verifica se existe ação judicial para o beneficiário
--                 and (select count(1)
--                        from TS.ACAO_JUD_PGTO@allsys aja
--                       where aja.cod_ts = pd.cod_mig
--                         and sysdate between aja.dt_ini_acao and
--                             nvl(aja.dt_fim_acao, sys_get_data_fim_fnc)) = 0
                  ';

  IF rAltMala.ftr_cod_uf IS NOT NULL THEN
    rAltMala.ftr_cod_uf := CHR(39) ||
                           REPLACE(rAltMala.ftr_cod_uf,
                                   ', ',
                                   CHR(39) || ',' || CHR(39)) || CHR(39);
    cursorString        := cursorString || ' and tc.cod_uf in (' ||
                           rAltMala.ftr_cod_uf || ')';
  END IF;

  IF rAltMala.ftr_cod_operadora IS NOT NULL THEN
    cursorString := cursorString || ' and p.cod_cad_oper in (' ||
                    rAltMala.ftr_cod_operadora ||
                    ') and p.cod_tipo_cad_oper = 2';
  END IF;

  IF rAltMala.ftr_cod_contrato IS NOT NULL THEN
    cursorString := cursorString || ' and ac.num_cont in (' ||
                    rAltMala.ftr_cod_contrato || ')';
  END IF;

  IF rAltMala.dt_adm_prop_ini IS NOT NULL OR
     rAltMala.dt_adm_prop_fin IS NOT NULL THEN
    cursorString := cursorString || ' and p.dt_adm_prop between to_date(''' ||
                    TO_CHAR(NVL(rAltMala.dt_adm_prop_ini,
                                sys_get_data_ini_fnc),
                            'DD/MM/YYYY') ||
                    ''', ''DD/MM/YYYY'') and to_date(''' ||
                    TO_CHAR(NVL(rAltMala.dt_adm_prop_fin,
                                sys_get_data_fim_fnc),
                            'DD/MM/YYYY') || ''', ''DD/MM/YYYY'')';
  END IF;

  IF tipoquery = 2 THEN
    cursorString := cursorString ||
                    ' and exists (select * from sys_send_msg ssm
                               where ssm.cod_tipo_cad = t.cod_tipo_cad
                                 and ssm.cod_cad = t.cod_cad
                                 and ssm.cod_prop = pd.cod_prop
                                 and ssm.cod_prop_dep = ' ||
                    depSysSendMsg || '
                                 and ssm.cod_fila_msg != 0
                                 and ssm.cod_mala = ' ||
                    rAltMala.cod_mala || ')';
  ELSIF tipoquery = 1 THEN
    cursorString := cursorString ||
                    ' and not exists (select * from sys_send_msg ssm
                               where ssm.cod_tipo_cad = t.cod_tipo_cad
                                 and ssm.cod_cad = t.cod_cad
                                 and ssm.cod_prop = pd.cod_prop
                                 and ssm.cod_prop_dep = ' ||
                    depSysSendMsg || '
                                 and ssm.cod_fila_msg != 0
                                 and ssm.cod_mala = ' ||
                    rAltMala.cod_mala || ')';
  END IF;

  cursorString := cursorString || ' GROUP BY t.cod_tipo_cad,
                  t.cod_cad,
                  t.nome_cad,
                  t.cod_tratamento,
                  t.cod_tipo_pessoa,
                  t.dt_nasc_cad,
                  t.cod_cad,
                  tc.cod_uf,
                  ac.num_cont,
                  p.cod_tipo_cad_oper,
                  p.cod_cad_oper,
                  p.cod_prop,
                  ac.dia_venc_cont,
                  p.cod_tipo_cad_ent,
                  p.cod_cad_ent,
                  cm.mail_cad_mail,
                  ct.pais_cad_tel,
                  ct.ddd_cad_tel,
                  ct.num_cad_tel,';

  IF rAltMala.cod_carga IS NOT NULL THEN
    cursorString := cursorString ||
                    'pdc.cod_cad_dep,
                  acd.nome_cad,
                  pdc.cod_prop_dep,
                  mcd.CAMPO_EXTRA_CARGA_DET_1,
                  mcd.CAMPO_EXTRA_CARGA_DET_2,
                  mcd.CAMPO_EXTRA_CARGA_DET_3,
                  mcd.CAMPO_EXTRA_CARGA_DET_4,
                  mcd.CAMPO_EXTRA_CARGA_DET_5,
                  mcd.ANEXO_MSG';
  ELSE
    cursorString := cursorString || '
                  pd.cod_cad_dep,
                  pd.cod_prop_dep';
  END IF;

  IF tipoquery IN (1, 2) THEN
    cursorString := cursorString || '
         ORDER BY t.nome_cad)
SELECT key_row,
       "#COD_TIPO_CAD_BEN",
       "#COD_CAD_BEN",
       "#NOME_CAD_BEN",
       "#NOME_CAD_BEN_M",
       "#COD_TRATAMENTO",
       "#COD_TIPO_PESSOA",
       "#DT_NASC_CAD",
       "#NUM_TEL",
       "#MAIL",
       "#COD_UF",
       "#COD_CONT",
       "#NOME_CAD_OPER",
       "#COD_PROP",
       "#DIA_VENC_CONT",
       "#NOME_CAD_ENT",
       "#COD_CAD_DEP",
       "#NOME_CAD_DEP",
       "#COD_PROP_DEP",
       "#CAMPO_EXTRA_1",
       "#CAMPO_EXTRA_2",
       "#CAMPO_EXTRA_3",
       "#CAMPO_EXTRA_4",
       "#CAMPO_EXTRA_5",
       "#ANEXO_MSG"';

    cursorString := cursorString || 'FROM beneficiarios a';
  ELSIF tipoquery = 3 THEN
    cursorString := cursorString || '
         ,ssm.cod_sts_msg
         ORDER BY t.nome_cad)
SELECT key_row,
       "#COD_CAD_BEN" AS "Código Beneficiário",
       "#NOME_CAD_BEN" AS "Nome Beneficiário",
       "#MAIL" AS "E-Mail",
       "#NUM_TEL" AS "Telefone",
       Status as "Status"
  FROM beneficiarios a';
  END IF;


  IF rAltMala.cod_tipo_msg = 1 THEN
    cursorString := REPLACE(REPLACE(cursorString, '$mail', 'INNER'),
                            '$tel',
                            'LEFT');
  ELSIF rAltMala.cod_tipo_msg = 2 THEN
    cursorString := REPLACE(REPLACE(cursorString, '$tel', 'INNER'),
                            '$mail',
                            'LEFT');
  END IF;

  alt_msg.set_log('Debug', rAltMala.cod_cad_usu_update, rAltMala.cod_tipo_cad_usu_update, 'alt_mala_tst_filtro_pcd', cursorString);

  DBMS_OUTPUT.PUT_LINE('cursorString = ' || cursorString);

  OPEN cursorReturn FOR cursorString;

  MsgError := ' ';
  COMMIT;
  RETURN;
END;
