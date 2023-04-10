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
       
       decode(ds.ind_resposta,'N','Nao','S','Sim','Nulo') resposta
       , 
       
       (select b3.nome_associado from ts.beneficiario@prod_allsys b3 where b3.cod_ts = b.cod_ts_tit) nome_titular,
       b.nome_associado

  from ts.beneficiario@prod_allsys b 
       join ts.beneficiario_entidade@prod_allsys be on be.cod_entidade_ts = b.cod_entidade_ts
       join ts.ppf_proposta@prod_allsys allprop on allprop.num_seq_proposta_ts = b.num_seq_proposta_ts
       join ts.ass_declaracao_saude@prod_allsys ds on ds.cod_ts = b.cod_ts
       join ts.questionario_saude@prod_allsys qs on qs.cod_questionario = ds.cod_questionario
       join alt_oper_ds_det dsd on dsd.cod_cad_oper = qs.cod_operadora
            and dsd.cod_det_ds = ds.cod_condicao_saude
   
where --p.cod_prop = 500413 
qs.cod_operadora = 246     
and allprop.cod_situacao_proposta IN (14, 26, 27)
and b.data_inclusao = to_date('01/05/2021', 'dd/mm/yyyy')

--and b.cod_ts = 1232331
 order by 1, 2, 3 
