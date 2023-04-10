--select 'update alt_cont_prod_ben set DTH_UPDATE = sysdate, DT_FIM_PROD_BEN = ''' || b.data_inclusao || ''' where id_prod_ben = ' || b.id_prod_ben || ';'
select 'update alt_cont2 set DTH_UPDATE = sysdate, dt_fim_cont = ''' || b.data_exclusao || ''' where id_cont = ' || b.id_cont || ';'
from alt_cont2@Prod_Alltech ab
     join ts.beneficiario b on b.id_cont = ab.id_cont
where ab.dt_fim_cont <> nvl(b.data_exclusao, '31/12/3000')
   and b.tipo_associado in ('T')
	 and b.data_exclusao is not null
