select 'update alt_cont_prod_ben set DTH_UPDATE = sysdate, DT_INI_PROD_BEN = ''' || b.data_inclusao || ''' where id_prod_ben = ' || b.id_prod_ben || ';'
from alt_cont_prod_ben @Prod_Alltech ab
     join ts.beneficiario b on b.id_prod_ben = ab.id_prod_ben
where --b.num_associado_operadora <> ab.id_dep_for
 --nvl(b.data_exclusao, '31/12/3000') <> ab.dt_fim_prod_ben
 nvl(b.data_inclusao, '01/01/1900') <> ab.dt_ini_prod_ben
