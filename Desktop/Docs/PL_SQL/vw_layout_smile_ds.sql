select  
       (select b2.num_associado from ts.beneficiario@prod_allsys b2 where b2.cod_ts = b.cod_ts_tit) num_associado_tit,
       b.num_associado,
       
       case 
         when be.ind_sexo = 'F' and dsd.cod_det_ds_oper NOT IN ('0') then dsd.cod_det_ds_oper
         when be.ind_sexo = 'F' and dsd.cod_det_ds_oper IN ('0') then dsd.cod_det_ds_oper_m
         when be.ind_sexo = 'M' and dsd.cod_det_ds_oper_m NOT IN ('0') then dsd.cod_det_ds_oper_m
         when be.ind_sexo = 'M' and dsd.cod_det_ds_oper_m IN ('0') then dsd.cod_det_ds_oper 
       end cod,
       
       --       be.ind_sexo,
  --     dsd.perg_det_ds pergunta   
 -- b.data_inclusao,       
       
       decode(ddd.chk_desc_ds,0,'Nao',-1,'Sim','Nulo') resposta
       , 
       
       (select b3.nome_associado from ts.beneficiario@prod_allsys b3 where b3.cod_ts = b.cod_ts_tit) nome_titular,
       b.nome_associado

  from alt_prop_dep d
       join ts.beneficiario@prod_allsys b on d.cod_mig = b.cod_ts
       join ts.beneficiario_entidade@prod_allsys be on be.cod_entidade_ts = b.cod_entidade_ts
       join ts.ppf_proposta@prod_allsys allprop on allprop.num_seq_proposta_ts = b.num_seq_proposta_ts
       join alt_prop p on d.cod_prop = p.cod_prop
  join alt_prop_dep_ds dd on d.cod_prop = dd.cod_prop
   and d.cod_prop_dep = dd.cod_prop_dep
   and p.cod_tipo_cad_oper = dd.cod_tipo_cad_oper
   and p.cod_cad_oper = dd.cod_cad_oper
  join alt_prop_dep_ds_det ddd on dd.cod_ds = ddd.cod_ds
   and dd.cod_prop = ddd.cod_prop
   and dd.cod_prop_dep = ddd.cod_prop_dep
   and dd.cod_prop_dep_ds = ddd.cod_prop_dep_ds
   and dd.cod_tipo_cad_oper = ddd.cod_tipo_cad_oper
   and dd.cod_cad_oper = ddd.cod_cad_oper
   and dd.cod_prop_dep_ds = ddd.cod_prop_dep_ds
  join alt_oper_ds ds on dd.cod_ds = ds.cod_ds
   and dd.cod_tipo_cad_oper = ds.cod_tipo_cad_oper
   and dd.cod_cad_oper = ds.cod_cad_oper
  join alt_oper_ds_det dsd on ds.cod_ds = dsd.cod_ds
   and ds.cod_tipo_cad_oper = dsd.cod_tipo_cad_oper
   and ds.cod_cad_oper = dsd.cod_cad_oper
   and ddd.cod_det_ds = dsd.cod_det_ds
where --p.cod_prop = 500413 
p.cod_cad_oper = 246
and allprop.cod_situacao_proposta IN (14, 26, 27)
and b.data_inclusao = to_date('16/04/2021', 'dd/mm/yyyy')
 order by 1, 2, 3 
