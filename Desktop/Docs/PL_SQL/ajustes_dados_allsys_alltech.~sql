select 'update alt_cont2 c set c.dt_ini_cont = ''' || b.data_inclusao || ''', c.dth_update = sysdate where c.id_cont = ' || c.id_cont || ';'
  from alt_cont2 c, la_beneficiario b
 where c.id_cont = b.id_cont
   and c.dt_ini_cont <> nvl(b.data_inclusao, sys_get_data_ini_fnc)
   and b.tipo_associado in ('T');
---------------------------------------------------------------------------------------------	 -- Divergência de exclusão de contrato
select 'update alt_cont2 c set c.dt_fim_cont = ''' || b.data_exclusao || ''', c.dth_update = sysdate where c.id_cont = ' || c.id_cont || ';'
  from alt_cont2 c, la_beneficiario b
 where c.id_cont = b.id_cont
   and c.dt_fim_cont <> nvl(b.data_exclusao, sys_get_data_fim_fnc)
   and b.tipo_associado in ('T')
	 and b.data_exclusao > b.data_inclusao;
---------------------------------------------------------------------------------------------------
-- Divergência de inclusão de beneficiário
select 'update alt_cont_prod_ben pb set pb.dt_ini_prod_ben = ''' || b.data_inclusao || ''', pb.dth_update = sysdate where pb.id_prod_ben = ' || pb.id_prod_ben || ';'
  from alt_cont_prod_ben pb, la_beneficiario b
 where pb.id_prod_ben = b.id_prod_ben
   and pb.dt_ini_prod_ben <> b.data_inclusao;
---------------------------------------------------------------------------------------------------
-- Divergência de exclusão de beneficiário
select 'update alt_cont_prod_ben pb set pb.id_dep_for = ''' || b.num_associado_operadora || ''', pb.dth_update = sysdate where pb.id_prod_ben = ' || pb.id_prod_ben || ';'
  from alt_cont_prod_ben pb, la_beneficiario b
 where pb.id_prod_ben = b.id_prod_ben
       and to_char(pb.id_dep_for) <> b.num_associado_operadora
			 and b.num_associado_operadora is not null;	 
