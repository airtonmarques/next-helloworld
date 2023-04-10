select distinct tc.nome_tipo_cad "Tipo Cadastro",
       lpad(doc.num_cad_doc, 11, '0') CPF,
       --c.cod_cad,
       --c.cod_tipo_cad,
       c.nome_cad "Nome",
alt_get_nome_cad_fnc(e.cod_tipo_cad_adm,e.cod_cad_adm) "Filial",
 (select alt_get_nome_cad_fnc(c.cod_tipo_cad,c.cod_cad)
   from alt_equipe_cad c where c.cod_perfil = 3
    and c.cod_equipe = e.cod_equipe and rownum = 1) "Corretora a qual pertence",
    m.mail_cad_mail "Ultimo e-mail cadastrado",
  '('||t.ddd_cad_tel||') '||t.num_cad_tel "Ultimo telefone cadastrado",
  (select nome_sit_cad
     from td_alt_sit_cad
     where cod_sit_cad = c.cod_sit_cad) "Situação"
 from alt_cad c,
      alt_equipe_cad ec,
      alt_equipe e,
      alt_cad_tel t,
      alt_cad_mail m,
      alt_cad_doc doc,
      td_alt_tipo_cad tc
where c.cod_tipo_cad = ec.cod_equipe_cad(+)
  and c.cod_cad = ec.cod_cad(+)
  and ec.cod_equipe = e.cod_equipe(+)
  and t.cod_tipo_cad(+) = c.cod_tipo_cad
  and t.cod_cad(+) = c.cod_cad
  and m.cod_tipo_cad(+) = c.cod_tipo_cad
  and m.cod_cad(+) = c.cod_cad
  and doc.cod_tipo_cad(+) = c.cod_tipo_cad
  and doc.cod_cad(+) = c.cod_cad
  and doc.cod_cad_doc(+) in (2)
  and c.cod_tipo_cad = tc.cod_tipo_cad
  and c.cod_tipo_cad in (3,4)

  and (t.chk_prefer_cad_tel = -1
      or t.cod_cad_tel = (select max(cod_cad_tel)
                            from alt_cad_tel
                           where cod_tipo_cad = t.cod_tipo_cad
                             and cod_cad = t.cod_cad) and rownum = 1)
  and (m.chk_prefer_cad_mail = -1
      or m.cod_cad_mail = (select max(cod_cad_mail)
                            from alt_cad_mail
                           where cod_tipo_cad = m.cod_tipo_cad
                             and cod_cad = m.cod_cad) and rownum = 1)
