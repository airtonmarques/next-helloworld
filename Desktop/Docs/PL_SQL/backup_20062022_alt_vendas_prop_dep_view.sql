create or replace view alt_vendas_prop_dep_view as
with

/*--------------------------------------------
  Renato Franca / Narjara Paes - 23/12/2021
  Reestruturac?o Novo Modelo de Proposta
  Dados Gerais do(s) Dependente(s)
  --------------------------------------------*/

--query auxiliar para formar a repetic?o das linhas de acordo com a proposta, com o objetivo de montar os dependentes de forma dinamica no report
aux as
 (select to_number(to_char(d.dt_date, 'DD')) cod_linha, p.cod_prop
    from td_sys_date d, alt_prop p
   where d.dt_date between to_date('01/01/2000', 'DD/MM/YYYY') and
         to_date('06/01/2000', 'DD/MM/YYYY')),
--query para selecionar os dependentes da proposta
dep as
 (select dat.cod_prop,
         dat.cod_prop_dep,
         dat.ordem_prop_dep,
         case
           when dat.cod_grau_par != 1 then
            'Dependente'
           when dat.cod_grau_par is null then
            ''
         end grau_par_dep,
         dat.nome_dep,
         dat.dt_nasc_dep,
         dat.mae_dep,
         dat.pai_dep,
         dat.sexo_dep,
         dat.idade_dep,
         /*dat.altura_dep,
         dat.peso_dep,
         dat.imc_dep,*/
         dat.email_dep,
         dat.est_civil_dep,
         dat.profissao_dep,
         dat.cpf_dep,
         dat.cartao_sus_dep,
         dat.rg_dep,
         dat.matr_func,
         dat.org_cad_doc_dep,
         dat.cid_nasc_dep,
         dat.ddd_tel_res_dep,
         dat.tel_res_dep,
         dat.ddd_tel_cel_dep,
         dat.tel_cel_dep,
         dat.ddd_tel_com_dep,
         dat.tel_com_dep,
         dat.ramal_tel_com_dep,
         nvl(dat.vlr_plano_dep, 0) vlr_plano_dep,
         nvl(dat.vlr_dental_dep, 0) vlr_dental_dep,
         (nvl(vlr_plano_dep, 0) + nvl(vlr_dental_dep, 0)) vlr_total_dep
  --dat.medico_codigo,
  --dat.odon_codigo

    from ((select prop.cod_prop,
                  pd.cod_prop_dep,
                  pd.ordem_prop_dep,
                  prop.dt_adm_prop,
                  gp.cod_grau_par,
                  initcap(cd.nome_cad) nome_dep,
                  cd.dt_nasc_cad dt_nasc_dep,
                  initcap(cd.nome_mae_cad) mae_dep,
                  initcap(cd.nome_pai_cad) pai_dep,
                  cd.cod_sexo sexo_dep,
                  sys_get_idade_fnc(cd.dt_nasc_cad, sysdate) idade_dep,
                  /*dds.altura_prop_dep_ds altura_dep,
                  dds.peso_prop_dep_ds peso_dep,
                  round(dds.peso_prop_dep_ds /
                        (dds.altura_prop_dep_ds * dds.altura_prop_dep_ds),
                        1) imc_dep,*/
                  lower(sys_get_mail_fnc(cd.cod_tipo_cad, cd.cod_cad)) email_dep,
                  initcap(ec.nome_est_civil) est_civil_dep,

                  initcap((select c.nome_vinc
                            from alt_cad_cad c
                           where c.cod_vinc_cad = 75
                             and c.cod_cad_vinc = cd.cod_cad)) profissao_dep,
                  sys_format_doc_fnc(2,
                                     sys_return_doc_fnc(2,
                                                        cd.cod_tipo_cad,
                                                        cd.cod_cad)) cpf_dep,
                  sys_return_doc_fnc(4, cd.cod_tipo_cad, cd.cod_cad) cartao_sus_dep,
                  sys_return_doc_fnc(1, cd.cod_tipo_cad, cd.cod_cad) rg_dep,
                  prop.num_matr_func matr_func,
                  (select orgao_cad_doc
                     from alt_cad_doc d
                    where d.cod_tipo_cad = cd.cod_tipo_cad
                      and d.cod_cad = cd.cod_cad
                      and d.cod_tipo_doc = 1) org_cad_doc_dep,
                  alt_get_nome_cidade_fnc(cd.cod_cidade_nat_cad) cid_nasc_dep,
                  --telefone residencial
                  sys_get_tel_fnc(2, 1, cd.cod_tipo_cad, cd.cod_cad) ddd_tel_res_dep,
                  sys_format3_tel_fnc(sys_get_tel_fnc(2,
                                                      2,
                                                      cd.cod_tipo_cad,
                                                      cd.cod_cad)) tel_res_dep,
                  --telefone celular
                  sys_get_tel_fnc(4, 1, cd.cod_tipo_cad, cd.cod_cad) ddd_tel_cel_dep,
                  sys_format3_tel_fnc(sys_get_tel_fnc(4,
                                                      2,
                                                      cd.cod_tipo_cad,
                                                      cd.cod_cad)) tel_cel_dep,
                  --telefone comercial
                  sys_get_tel_fnc(1, 1, cd.cod_tipo_cad, cd.cod_cad) ddd_tel_com_dep,
                  sys_format3_tel_fnc(sys_get_tel_fnc(1,
                                                      2,
                                                      cd.cod_tipo_cad,
                                                      cd.cod_cad)) tel_com_dep,
                  sys_get_tel_fnc(1, 3, cd.cod_tipo_cad, cd.cod_cad) ramal_tel_com_dep,
                  --dados do produto
                  prod.cod_prod,
                  prod.cod_tipo_prod,
                  alt_get_vlr_prop_prod_fnc(3,
                                            pd.cod_prop,
                                            pd.cod_prop_dep,
                                            1,
                                            pd.dt_adm_prop_dep) vlr_plano_dep,
                  nvl(alt_get_vlr_prop_prod_fnc(3,
                                            pd.cod_prop,
                                            pd.cod_prop_dep,
                                            2,
                                            pd.dt_adm_prop_dep), 0) vlr_dental_dep
             from alt_prop prop
            inner join alt_prop_dep pd
               on prop.cod_prop = pd.cod_prop
              and pd.cod_grau_par <> 1
           --ds
             /*left join alt_prop_dep_ds dds
               on pd.cod_prop = dds.cod_prop
              and pd.cod_prop_dep = dds.cod_prop_dep*/
           --cadastro
             left join alt_cad cd
               on cd.cod_tipo_cad = pd.cod_tipo_cad_dep
              and cd.cod_cad = pd.cod_cad_dep
           --grau parentesco
            inner join td_alt_grau_par gp
               on pd.cod_grau_par = gp.cod_grau_par
           --estado civil
            inner join td_alt_est_civil ec
               on cd.cod_est_civil = ec.cod_est_civil
           --produto
            inner join alt_prop_dep_prod dp
               on pd.cod_prop = dp.cod_prop
              and pd.cod_prop_dep = dp.cod_prop_dep
              and dp.cod_tipo_prod =
                  alt_get_cod_tipo_prod_by_prop(pd.cod_prop,
                                                dp.cod_tipo_cad_for,
                                                dp.cod_cad_for)
            inner join alt_prod prod
               on dp.cod_tipo_cad_for = prod.cod_tipo_cad_for
              and dp.cod_cad_for = prod.cod_cad_for
              and dp.cod_tipo_prod = prod.cod_tipo_prod
              and dp.cod_prod = prod.cod_prod)
          pivot(max(cod_prod) codigo for
                cod_tipo_prod in (1 as medico, 2 as odon))) dat
   order by cod_prop_dep asc)

select aux.cod_linha,
       case
         when aux.cod_linha between 1 and 3 then
          '4'
         when aux.cod_linha between 4 and 6 then
          '5'
         else
          '5B'
       end num_folha,
       aux.cod_prop,
       dep.cod_prop_dep,
       dep.ordem_prop_dep,
       dep.grau_par_dep,
       dep.nome_dep,
       dep.dt_nasc_dep,
       dep.mae_dep,
       dep.pai_dep,
       dep.sexo_dep,
       dep.idade_dep,
       /*dep.altura_dep,
       dep.peso_dep,
       dep.imc_dep,*/
       dep.email_dep,
       dep.est_civil_dep,
       dep.profissao_dep,
       dep.cpf_dep,
       dep.cartao_sus_dep,
       dep.rg_dep,
       dep.matr_func,
       dep.org_cad_doc_dep,
       dep.cid_nasc_dep,
       dep.ddd_tel_res_dep,
       dep.tel_res_dep,
       dep.ddd_tel_cel_dep,
       dep.tel_cel_dep,
       dep.ddd_tel_com_dep,
       dep.tel_com_dep,
       dep.vlr_plano_dep,
       dep.vlr_dental_dep,
       dep.vlr_total_dep
  from aux, dep
 where aux.cod_linha = dep.ordem_prop_dep(+)
   and aux.cod_prop = dep.cod_prop(+)
 order by aux.cod_linha asc
;
