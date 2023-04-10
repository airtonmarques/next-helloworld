create or replace function alt_desenvolvimento.alt_api_adt_carencia_fnc(Metodo       in varchar2,
                                              IdRequisicao in varchar,
                                              DataVs       in varchar2)
  return clob as
  sReturn clob;
  --v_json_list pljson_list;

  IdProdBen number;
  iCountProdBen number;
  sCodGrpCarDep varchar2(30);
  iCodTsAllsys number;
  
  iCodTipoCadUsu number;
  iCodCadUsu number;

begin
  --sDataVs := replace(DataVS, '|', ';');
  iCodTipoCadUsu := sys_get_vs_number_fnc (DataVs, 'COD_TIPO_CAD_USU');
  iCodCadUsu := sys_get_vs_number_fnc (DataVs, 'COD_CAD_USU');

  -- Verifica retorno
  if not IdRequisicao is null then
    
    -- Pesquisa detalhe
  
    -- Adiciona carencias ao array pois o detalhe e uma lista do grupo
                         
    /*sReturn := sReturn || '{
                          "CodGrpCarDep": 2047,
                          "Carencias" : [';
  
    sReturn := sReturn || '{
                          "Carencia": "Exames especiais",
                          "QtdDias": 180,
                          "DtInicio": "2022-02-01T00:00:00",
                          "DtFim": "2022-06-01T00:00:00",
                          "DescDtFim": "01/06/2022" 
                          },';
  
    sReturn := sReturn || '{
                          "Carencia": "Terapias simples",
                          "QntDias": 60,
                          "DtInicio": "2022-06-01T00:00:00",
                          "DtFim": "2022-04-01T00:00:00",
                          "DescDtFim": "Cumprida" 
                          },';
 
  
    sReturn := sReturn || ']
    }';*/
    
    --Verifica direito de acesso
    if sys_get_config_usu_fnc (142, iCodTipoCadUsu, iCodCadUsu) = 0 then
       return sys_return_error('Acesso negado.');
    end if;
    
    IdProdBen := nvl(regexp_replace(IdRequisicao, '[^0-9]', ''), 0);
    
    select count(1) into iCountProdBen from alt_cont_prod_ben where id_prod_ben = IdProdBen;
    
    if iCountProdBen = 0 then
      return sys_return_error('IdProdBen não localizado.');
    end if;
    
    select nvl(max(b.cod_grp_car_dep), '-1') into sCodGrpCarDep from alt_cont_prod_ben b where b.id_prod_ben = IdProdBen;
    
   /* if sCodGrpCarDep = '-1' then
      return sys_return_true('Aditivo de carência não localizado.') || '|JsonReturn|{}';
    end if;*/
     
    select sys_get_vs_number_fnc(max(mi.id_cad_mig), 'BEN')
        into iCodTsAllsys
        from alt_cont_prod_ben bc, alt_cad_mig2 mi
      where bc.id_prod_ben = IdProdBen
         and bc.id_cad = mi.id_cad
         and bc.cod_grau_par = 1;
    
    if iCodTsAllsys = -1 then
      return sys_return_error('CodTsAllsys não localizado.');
    end if;
    
    -- Detalhe
    
    for sListaCarencias in (
                           
    select
    initcap(cp.nom_carencia) DescCarencia,
    ca.qtd_dias_carencia QtdeDias,
    to_char(ca.data_base_carencia, 'yyyy-mm-dd') || 'T00:00:00' DtInicio,
    to_char(ca.data_fim_carencia, 'yyyy-mm-dd') || 'T00:00:00' DtFim,
    case
     when ca.data_fim_carencia <= sysdate then
      'Cumprida'
     else
      to_char(ca.data_fim_carencia, 'dd/mm/yyyy')
    end DescDtFim
    
    from la_carencia_padrao cp
    inner join la_carencia_associado ca
    on cp.cod_carencia_ts = ca.cod_carencia_ts
    where ca.cod_ts = iCodTsAllsys
                           
    ) loop
    
      --Monta Json      

      sReturn := sReturn || '{';
      sReturn := sReturn || '"DescCarencia": "' || sListaCarencias.DescCarencia || '",';
      sReturn := sReturn || '"QtdeDias": ' || sListaCarencias.QtdeDias || ',';
      sReturn := sReturn || '"DtInicio": "' || sListaCarencias.DtInicio || '",';
      sReturn := sReturn || '"DtFim": "' || sListaCarencias.DtFim || '",';
      sReturn := sReturn || '"DescDtFim": "' || sListaCarencias.DescDtFim || '"';
      sReturn := sReturn || '},';
      
        
    end loop;
    
    sReturn := substr(sReturn, 1, length(sReturn) - 1);
    
    sReturn := '[' || sReturn || ']';

    sReturn := '{ "CodGrpCarDep": "' || sCodGrpCarDep || '", "Carencias": ' || sReturn || '}';
    
  else
  
    --Lista
    return sys_return_error('Esta api não possui retorno do tipo lista.');
  end if;
  
  return sys_return_true('') || '|JsonReturn|' || sReturn;

end;
/
