--Checagem Beneficiário Com ID_Cont = 0
select 'update ts.beneficiario b set b.id_cont = ' || p.id_cont || ' where  b.cod_ts = ' || b.cod_ts || ';'
from ts.beneficiario b
     join alt_cont_prod_ben@prod_alltech p on replace(p.cod_mig_prod_ben, 'BEN|', '') = to_char(b.cod_ts)
where b.id_prod_ben is not null
      and b.id_cont = 0
			--55650
------------------------------------------------------------------			
-- Checagem sem o id_prod_ben na Aditivo 
select 'update ts.associado_aditivo b set b.ID_PROD_BEN = ' || ab.ID_PROD_BEN || ', b.dth_update_alltech = sysdate, b.dth_update_allsys = sysdate where b.cod_ts = ' || b.cod_ts || ' and b.cod_aditivo = ' || b.cod_aditivo || ';'
from ts.associado_aditivo b
     join Alt_Cont_Prod_Ben@Prod_Alltech ab on ab.cod_mig_prod_ben = 'ADIT|' || b.cod_ts || '.' ||
                                     b.cod_aditivo || '.' || case
                                       when b.dt_ini_vigencia >
                                            b.dt_fim_vigencia then
                                        to_char(b.dt_fim_vigencia, 'DD/MM/YY')
                                       else
                                        to_char(b.dt_ini_vigencia, 'DD/MM/YY') end
where (b.ID_PROD_BEN is null or b.ID_PROD_BEN = 0)
-------------------------------------------------------
--Checagem Beneficiário sem id_prod_ben
select 'update ts.beneficiario b set b.id_prod_ben = ' || p.id_prod_ben || ', b.id_cont = ' || p.id_cont || ', b.DTH_UPDATE_CONT_ALLSYS = sysdate, b.DTH_UPDATE_CONT_ALLTECH = sysdate, b.dth_update_ben_alltech = sysdate, b.dth_update_ben_allsys = sysdate where  b.cod_ts = ' || b.cod_ts || ';'
from ts.beneficiario b
     join alt_cont_prod_ben@prod_alltech p on replace(p.cod_mig_prod_ben, 'BEN|', '') = to_char(b.cod_ts)
where (b.id_prod_ben is null or b.id_prod_ben = 0)

----------------------------------------------------------
												


