SELECT ROW_NUMBER() OVER (ORDER BY t.nome_cad) KEY_ROW,
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
                      AS "#NOME_CAD_ENT" , pd.cod_cad_dep as "#COD_CAD_DEP",
                  INITCAP (t.NOME_CAD) AS "#NOME_CAD_DEP",
                  pd.cod_prop_dep as "#COD_PROP_DEP",
                  '' AS "#CAMPO_EXTRA_1",
                  '' AS "#CAMPO_EXTRA_2",
                  '' AS "#CAMPO_EXTRA_3",
                  '' AS "#CAMPO_EXTRA_4",
                  '' AS "#CAMPO_EXTRA_5",
                  '' AS "#ANEXO_MSG"
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
                  INNER JOIN
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
                  INNER JOIN alt_cad_mail cm
                      ON     cm.cod_cad = rmail.cod_cad
                         AND cm.cod_tipo_cad = rmail.cod_tipo_cad
                         AND cm.cod_cad_mail = rmail.cod_cad_mail
                         AND 1 = 1
                  LEFT JOIN
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
                  LEFT JOIN alt_cad_tel ct
                      ON     ct.cod_cad = rtel.cod_cad
                         AND ct.cod_tipo_cad = rtel.cod_tipo_cad
                         AND ct.cod_cad_tel = rtel.cod_cad_tel
                         AND ct.chk_cel_tel = -1
                         AND ct.num_cad_tel IS NOT NULL
                         AND ct.num_cad_tel != 0
                         AND 2 = 1
                  WHERE     e.cod_cad_end =
                      (SELECT MAX (xe.cod_cad_end)
                         FROM alt_cad_end xe
                        WHERE     xe.cod_tipo_cad = t.cod_tipo_cad
                              AND xe.cod_cad = t.cod_cad)
                  AND pd.cod_grau_par = 1
                   AND TRUNC(pd.dt_exc_prop_dep) >= TRUNC(SYSDATE)  AND TRUNC(pd.dt_exc_prop_dep) > TRUNC(pd.dt_adm_prop_dep)
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
                   and ac.num_cont in (26263,26266,26267,26268,26269,26276,26285,26290,26438,26272,26277,26279,26282,26287,26295,26439,26298,26302,26304,26307,26319,26322,26329,26335,26340,26448,26299,26315,26441,26442,26443,26444,26445,26446,26447,26449,26657) and not exists (select * from sys_send_msg ssm
                               where ssm.cod_tipo_cad = t.cod_tipo_cad
                                 and ssm.cod_cad = t.cod_cad
                                 and ssm.cod_prop = pd.cod_prop
                                 and ssm.cod_prop_dep =  pd.cod_prop_dep 
                                 and ssm.cod_fila_msg != 0
                                 and ssm.cod_mala = 362) GROUP BY t.cod_tipo_cad,
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
                  ct.num_cad_tel,
                  pd.cod_cad_dep,
                  pd.cod_prop_dep
         ORDER BY t.nome_cad
