-----Trazer esses dados + mailing qur a bruna enviou
select c.id_cont        IdCont,
       c.id_cont_parent IdContParent,
       123456           IdTitulo,
       cr.id_cad        IdCad,
       c.id_sf          ServiceContractId,
       cp.id_sf         ParentServiceContractId,       
       cr.id_sf         AccountId,
       c.id_contato_sf  ContactId,
       c.cod_prop_for_compl NumProposta,
	   (select min(dt_vencimento) 
          from la_cobranca co
         where co.cod_ts = TO_NUMBER(REPLACE(m.id_cad_mig,'BEN|',''))
           and co.dt_baixa is null
           and co.dt_cancelamento is null
           and co.dt_vencimento <= trunc(sysdate)) dtVencTitulo,
	   (select trunc(sysdate) - min(co.dt_vencimento) 
          from la_cobranca co
         where co.cod_ts = TO_NUMBER(REPLACE(m.id_cad_mig,'BEN|',''))
           and co.dt_baixa is null
           and co.dt_cancelamento is null
           and co.dt_vencimento <= trunc(sysdate)) DiasAtraso,
       p.nome_porte_cont Porte,
       alt_get_nome_cont_cad_fnc(c.id_cont,5) Entidade,
       alt_get_nome_cont_cad_fnc(c.id_cont,2) Operadora,
	   (select min(val_a_pagar) 
          from la_cobranca co
         where co.cod_ts = TO_NUMBER(REPLACE(m.id_cad_mig,'BEN|',''))
           and co.dt_baixa is null
           and co.dt_cancelamento is null
           and co.dt_vencimento <= trunc(sysdate)) VlrMensAtraso,
	   (select count(1) 
          from la_cobranca co
         where co.cod_ts = TO_NUMBER(REPLACE(m.id_cad_mig,'BEN|',''))
           and co.dt_baixa is null
           and co.dt_cancelamento is null
           and co.dt_vencimento <= trunc(sysdate)) QtdeMensAtraso,
       cr.nome_cad      NomeCad,    
       contatos.*
  from (select *
          from (select *
                  from (select ct.id_cont,
                               sys_format2_tel_fnc(t.pais_cad_tel,
                                                   t.ddd_cad_tel,
                                                   t.num_cad_tel) vlr_label,
                               'Celular' || rownum Label
                          from alt_cont_tel ct, alt_cad_tel2 t
                         where ct.id_cont = 1008
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
                         where ct.id_cont = 1008
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
                         where ct.id_cont = 1008
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
                         where cm.id_cont = 1008
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
       alt_cont_cad2 ccr,
       alt_cad_mig2 m,
       td_alt_porte_cont p
 where c.id_cont = 1008
   and cp.id_cont = c.id_cont_parent
   and ccr.id_cont = c.id_cont
   and ccr.cod_vinc_cad = 71
   and ccr.id_cad = cr.id_cad
   and ccr.id_cad = m.id_cad
   and c.id_porte_cont = p.cod_porte_cont;
