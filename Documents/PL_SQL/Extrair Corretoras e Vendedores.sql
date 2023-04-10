  SELECT DISTINCT
         tc.nome_tipo_cad
             "Tipo Cadastro",
         SYS_FORMAT_DOC_FNC(3,ALT_GET_DOC2_FNC(c.cod_tipo_cad, c.cod_cad, 3)) "CPF/CNPJ",
         c.nome_cad
             "Nome",
         NVL(REGEXP_REPLACE (
             LISTAGG (
                 alt_get_nome_cad_fnc (e.cod_tipo_cad_adm,
                                       e.cod_cad_adm),
                 ',')
             WITHIN GROUP (ORDER BY e.cod_cad_adm),
             '([^,]+)(,\1)+',
             '\1'), 'Sem Filial')
             "Filial",
         NVL(alt_get_nome_cad_fnc (ec.cod_tipo_cad, ec.cod_cad), 'Não Vinculado a Equipe')
             "Corretora a qual pertence",
         m.mail_cad_mail
             "Ultimo e-mail cadastrado",
         '(' || t.ddd_cad_tel || ') ' || t.num_cad_tel
             "Ultimo telefone cadastrado",
         (SELECT nome_sit_cad
            FROM td_alt_sit_cad
           WHERE cod_sit_cad = c.cod_sit_cad)
             "Situação"
    FROM alt_cad        c,
         td_alt_tipo_cad tc,
         alt_equipe_cad ec,
         alt_equipe     e,
         alt_cad_tel    t,
         alt_cad_mail   m
   WHERE     c.cod_tipo_cad = 3
         AND tc.cod_tipo_cad = c.cod_tipo_cad
         AND ec.cod_tipo_cad(+) = c.cod_tipo_cad
         AND ec.cod_cad(+) = c.cod_cad
         AND ec.cod_perfil(+) = 3
         AND e.cod_equipe(+) = ec.cod_equipe
         AND t.cod_tipo_cad(+) = c.cod_tipo_cad
         AND t.cod_cad(+) = c.cod_cad
         AND m.cod_tipo_cad(+) = c.cod_tipo_cad
         AND m.cod_cad(+) = c.cod_cad
         AND t.cod_tipo_cad = c.cod_tipo_cad
         AND t.cod_cad = c.cod_cad
         AND t.cod_cad_tel =
             (SELECT DISTINCT FIRST_VALUE (COD_CAD_TEL)
                                  OVER (
                                      ORDER BY
                                          (CASE
                                               WHEN act.dth_valida_cad_tel >
                                                    SYSDATE
                                               THEN
                                                   0
                                               ELSE
                                                   1
                                           END) ASC,
                                          (CASE
                                               WHEN act.chk_prefer_cad_tel =
                                                    -1
                                               THEN
                                                   0
                                               ELSE
                                                   1
                                           END) ASC,
                                          act.dth_valida_cad_tel DESC,
                                          act.dth_insert DESC)    AS cod_cad_tel
                FROM alt_cad_tel act
               WHERE     act.cod_cad = c.cod_cad
                     AND act.cod_tipo_cad = c.cod_tipo_cad)
         AND m.cod_tipo_cad = c.cod_tipo_cad
         AND m.cod_cad = c.cod_cad
         AND m.cod_cad_mail =
             (SELECT DISTINCT FIRST_VALUE (COD_CAD_TEL)
                                  OVER (
                                      ORDER BY
                                          (CASE
                                               WHEN acm.dth_valida_cad_mail >
                                                    SYSDATE
                                               THEN
                                                   0
                                               ELSE
                                                   1
                                           END) ASC,
                                          (CASE
                                               WHEN acm.chk_prefer_cad_mail =
                                                    -1
                                               THEN
                                                   0
                                               ELSE
                                                   1
                                           END) ASC,
                                          acm.dth_valida_cad_mail DESC,
                                          acm.dth_insert DESC)    AS cod_cad_tel
                FROM alt_cad_mail acm
               WHERE     acm.cod_cad = c.cod_cad
                     AND acm.cod_tipo_cad = c.cod_tipo_cad)
GROUP BY tc.nome_tipo_cad,
         c.nome_cad,
         m.mail_cad_mail,
         t.ddd_cad_tel,
         t.num_cad_tel,
         c.cod_sit_cad,
         ec.cod_tipo_cad,
         ec.cod_cad,
         c.cod_tipo_cad,
         c.cod_cad
union
  SELECT DISTINCT
         tc.nome_tipo_cad
             "Tipo Cadastro",
         SYS_FORMAT_DOC_FNC(2,ALT_GET_DOC2_FNC(c.cod_tipo_cad, c.cod_cad, 2)) "CPF/CNPJ",
         c.nome_cad
             "Nome",
         NVL(REGEXP_REPLACE (
             LISTAGG (
                 alt_get_nome_cad_fnc (e.cod_tipo_cad_adm,
                                       e.cod_cad_adm),
                 ',')
             WITHIN GROUP (ORDER BY e.cod_cad_adm),
             '([^,]+)(,\1)+',
             '\1'), 'Sem Filial')
             "Filial",
         REPLACE(NVL(REGEXP_REPLACE (LISTAGG (
             alt_get_nome_cad_fnc (ecc.cod_tipo_cad, ecc.cod_cad),
             ',')
         WITHIN GROUP (ORDER BY ecc.cod_cad),
             '([^,]+)(,\1)+',
             '\1'), 'Não Vinculado a Equipe'), ',', ', ')
             "Corretora a qual pertence",
         m.mail_cad_mail
             "Ultimo e-mail cadastrado",
         '(' || t.ddd_cad_tel || ') ' || t.num_cad_tel
             "Ultimo telefone cadastrado",
         (SELECT nome_sit_cad
            FROM td_alt_sit_cad
           WHERE cod_sit_cad = c.cod_sit_cad)
             "Situação"
    FROM alt_cad        c,
         td_alt_tipo_cad tc,
         alt_equipe_cad ec,
         alt_equipe     e,
         alt_cad_tel    t,
         alt_cad_mail   m,
         alt_equipe_cad ecc
   WHERE     c.cod_tipo_cad = 4
         AND tc.cod_tipo_cad = c.cod_tipo_cad
         AND ec.cod_tipo_cad(+) = c.cod_tipo_cad
         AND ec.cod_cad(+) = c.cod_cad
         AND e.cod_equipe(+) = ec.cod_equipe
         AND ecc.cod_equipe(+) = ec.cod_equipe
         AND ecc.cod_perfil(+) = 3
         AND t.cod_tipo_cad(+) = c.cod_tipo_cad
         AND t.cod_cad(+) = c.cod_cad
         AND m.cod_tipo_cad(+) = c.cod_tipo_cad
         AND m.cod_cad(+) = c.cod_cad
         AND t.cod_tipo_cad = c.cod_tipo_cad
         AND t.cod_cad = c.cod_cad
         AND t.cod_cad_tel =
             (SELECT DISTINCT FIRST_VALUE (COD_CAD_TEL)
                                  OVER (
                                      ORDER BY
                                          (CASE
                                               WHEN act.dth_valida_cad_tel >
                                                    SYSDATE
                                               THEN
                                                   0
                                               ELSE
                                                   1
                                           END) ASC,
                                          (CASE
                                               WHEN act.chk_prefer_cad_tel =
                                                    -1
                                               THEN
                                                   0
                                               ELSE
                                                   1
                                           END) ASC,
                                          act.dth_valida_cad_tel DESC,
                                          act.dth_insert DESC)    AS cod_cad_tel
                FROM alt_cad_tel act
               WHERE     act.cod_cad = c.cod_cad
                     AND act.cod_tipo_cad = c.cod_tipo_cad)
         AND m.cod_tipo_cad = c.cod_tipo_cad
         AND m.cod_cad = c.cod_cad
         AND m.cod_cad_mail =
             (SELECT DISTINCT FIRST_VALUE (COD_CAD_TEL)
                                  OVER (
                                      ORDER BY
                                          (CASE
                                               WHEN acm.dth_valida_cad_mail >
                                                    SYSDATE
                                               THEN
                                                   0
                                               ELSE
                                                   1
                                           END) ASC,
                                          (CASE
                                               WHEN acm.chk_prefer_cad_mail =
                                                    -1
                                               THEN
                                                   0
                                               ELSE
                                                   1
                                           END) ASC,
                                          acm.dth_valida_cad_mail DESC,
                                          acm.dth_insert DESC)    AS cod_cad_tel
                FROM alt_cad_mail acm
               WHERE     acm.cod_cad = c.cod_cad
                     AND acm.cod_tipo_cad = c.cod_tipo_cad)
GROUP BY tc.nome_tipo_cad,
         c.nome_cad,
         m.mail_cad_mail,
         t.ddd_cad_tel,
         t.num_cad_tel,
         c.cod_sit_cad,
         c.cod_cad,
         c.cod_tipo_cad