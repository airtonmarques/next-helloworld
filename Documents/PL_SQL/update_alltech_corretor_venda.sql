select  'update ts.corretor_venda s set s.id_cad_alt = ' || co.id_cad || ', s.dth_update_allsys = sysdate, s.dth_update_alltech = sysdate where s.cod_corretor_ts = ' || s.cod_corretor_ts || ';'
from ts.corretor_venda s
     join alt_cad_mig2@Prod_Alltech co on replace(co.id_cad_mig, 'CORR|', '') = to_char(s.cod_corretor_ts)
where s.id_cad_alt is null


-------------------------------------------

select 'update ts.contrato_empresa ce set ce.id_cont = ' || co.id_cont || ', ce.dth_update_allsys = sysdate, ce.dth_update_alltech = sysdate where ce.cod_ts_contrato = ' || ce.cod_ts_contrato || ';'
from ts.contrato_empresa ce
     join alt_cont2@Prod_Alltech co on replace(co.cod_cont_mig, 'CONT|', '') = to_char(ce.cod_ts_contrato)
where ce.id_cont is null

-----------------------------

select 'update beneficiario_entidade be set be.id_cad_alt = ' || mig.id_cad || ', be.dth_update_allsys = sysdate, be.dth_update_alltech = sysdate where be.cod_entidade_ts = ' || be.cod_entidade_ts || ';'
from ts.beneficiario_entidade be
     join alt_cad_mig2@Prod_Alltech mig on replace(mig.id_cad_mig, 'BEN|', '') = to_char(be.cod_entidade_ts)
where be.id_cad_alt is null
      and exists (select 1
                  from ts.beneficiario b
                  where b.cod_entidade_ts = be.cod_entidade_ts
                        --and b.data_exclusao is null)
                        and b.data_exclusao between to_date('01/06/2015', 'dd/mm/yyyy') and last_day('01/12/2022'))



---------------------------------------------------------------

select 'update ts.beneficiario be set be.id_cad_alt = ' || cad.id_cad || ' where be.cod_entidade_ts = ' || be.cod_entidade_ts || ';'
from alt_cad_mig2@prod_alltech cad
     join ts.beneficiario_entidade be on be.cod_entidade_ts = cad.pk_mig
where be.id_cad_alt is null
      and cad.tab_mig = 'BENEFICIARIO_ENTIDADE'
			
			
			
---------------------------------------------------------------

/*select 'update ts.beneficiario b set b.id_cont = ' || p.id_cont || ' where b.cod_ts = ' || b.cod_ts || ';'
from ts.beneficiario b
     join alt_cont2@prod_alltech p on replace(p.cod_cont_mig, 'PROP|', '') = to_char(b.cod_ts)
where b.data_exclusao is null
      and b.id_cont is null*/
      --55650
      
select 'update ts.associado_aditivo b set b.ID_PROD_BEN = ' || ab.ID_PROD_BEN || ', b.dth_update_alltech = sysdate, b.dth_update_allsys = sysdate where b.cod_ts = ' || b.cod_ts || ' and b.cod_aditivo = ' || b.cod_aditivo || ';'
from ts.associado_aditivo b
     join Alt_Cont_Prod_Ben@Prod_Alltech ab on ab.cod_mig_prod_ben = 'ADIT|' || b.cod_ts || '.' ||
                                     b.cod_aditivo || '.' || case
                                       when b.dt_ini_vigencia >
                                            b.dt_fim_vigencia then
                                        to_char(b.dt_fim_vigencia, 'DD/MM/YY')
                                       else
                                        to_char(b.dt_ini_vigencia, 'DD/MM/YY') end
where b.ID_PROD_BEN is null
      --and b.dt_fim_vigencia is null
                        
			
