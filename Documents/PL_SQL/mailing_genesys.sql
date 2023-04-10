-----Trazer esses dados + mailing qur a bruna enviou
select cr.num_cpf_cnpj  cnpjcpf,
       c.id_cont        IdCont,
       c.id_cont_parent IdContParent,
       123456           IdTitulo,
       cr.id_cad        IdCad,
       cr.nome_cad      NomeCad,
       cr.id_sf         AccountId,
       c.id_contato_sf  ContactId,
       c.id_sf          ServiceContractId,
       cp.id_sf         ParentServiceContractId,
       contatos.*
  from (select *
          from (select *
                  from (select ct.id_cont,
                               sys_format2_tel_fnc(t.pais_cad_tel,
                                                   t.ddd_cad_tel,
                                                   t.num_cad_tel) vlr_label,
                               'Celular' || rownum Label
                          from alt_cont_tel ct, alt_cad_tel2 t
                         where ct.id_cont = 1227
                           and t.id_cad_tel = ct.id_cad_tel
                           and t.chk_cel_tel = -1
                         order by ct.dth_insert desc)
                union
                select *
                  from (select ct.id_cont,
                               sys_format2_tel_fnc(t.pais_cad_tel,
                                                   t.ddd_cad_tel,
                                                   t.num_cad_tel) vlr_label,
                               'Residencial' || rownum Label
                          from alt_cont_tel ct, alt_cad_tel2 t
                         where ct.id_cont = 1227
                           and t.id_cad_tel = ct.id_cad_tel
                           and t.chk_cel_tel = 0
                           and t.cod_tipo_tel > 1
                         order by ct.dth_insert desc)
                union
                select *
                  from (select ct.id_cont,
                               sys_format2_tel_fnc(t.pais_cad_tel,
                                                   t.ddd_cad_tel,
                                                   t.num_cad_tel) vlr_label,
                               'Comercial' || rownum Label
                          from alt_cont_tel ct, alt_cad_tel2 t
                         where ct.id_cont = 1227
                           and t.id_cad_tel = ct.id_cad_tel
                           and t.chk_cel_tel = 0
                           and t.cod_tipo_tel = 1
                         order by ct.dth_insert desc)
                union
                select *
                  from (select cm.id_cont,
                               lower(m.mail_cad_mail) vlr_label,
                               'Email' || rownum Label
                          from alt_cont_mail cm, alt_cad_mail2 m
                         where cm.id_cont = 1227
                           and m.id_cad_mail = cm.id_cad_mail
                         order by cm.dth_insert desc))
        pivot(max(vlr_label)
           for Label in('Celular1',
                       'Celular2',
                       'Celular3',
                       'Residencial1',
                       'Residencial2',
                       'Residencial3',
                       'Comercial1',
                       'Email1',
                       'Email2',
                       'Email3'))) contatos,
       alt_cont2 c,
       alt_cont2 cp,
       alt_cad2 cr,
       alt_cont_cad2 ccr
 where c.id_cont = 1227
   and cp.id_cont = c.id_cont_parent
   and ccr.id_cont = c.id_cont
   and ccr.cod_vinc_cad = 71
   and ccr.id_cad = cr.id_cad
