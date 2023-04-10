select 'Benef',count(1)
      from la_beneficiario_entidade a,
           la_beneficiario          b
       Where a.cod_entidade_Ts = b.cod_entidade_ts
       and a.dth_update_allsys > a.dth_update_alltech
Union
 select 'La_Corretor', count(1)
      from la_corretor_venda a,
           la_entidade_sistema  e
     Where a.cod_entidade_ts = e.cod_entidade_ts
       and e.num_cpf IS NOT NULL
       and a.cod_tipo_produtor IN (7, 10)
       and a.data_registro_Exclusao IS Null
       and a.dth_update_allsys > a.dth_update_Alltech
union
    select 'La_Entidade', count(1)
      from la_entidade_sistema a,
           la_corretor_venda c
     Where a.dth_update_allsys > a.dth_update_Alltech
       and c.cod_tipo_produtor IN (1, 3, 4, 8)
       and a.cod_entidade_Ts = c.cod_entidade_Ts
union
select 'Operadora', count(1) from La_Operadora a
       Where a.dth_update_allsys > a.dth_update_Alltech
union
select 'La_PPF_Operadora', count(1) from La_Ppf_Operadoras a
       Where a.dth_update_allsys > a.dth_update_Alltech
union
select 'La_Sucursal', count(1) from La_Sucursal a
       Where a.dth_update_allsys > a.dth_update_Alltech
union
select 'Filial', count(1) from La_Filial_Fiscal a
       Where a.dth_update_allsys > a.dth_update_Alltech;
