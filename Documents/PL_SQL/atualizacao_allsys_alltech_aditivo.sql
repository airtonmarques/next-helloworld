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
                        
