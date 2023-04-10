declare
  -- Local variables here
  i integer;

  indAcao      number;
  ReturnPcd    varchar2(4000);
  Pcod_Retorno number;
begin

  -- Test statements here
/*  
  begin

indAcao := 1;

 for cont in (select cod_ts_contrato 
               from la_contrato_empresa
               where cod_ts_contrato in (10621)) loop
  --> Migração individual
 alt_mig_cad_cont_pkg.importar (cont.cod_ts_contrato,indAcao, ReturnPcd);

 dbms_output.put_line(cont.cod_ts_contrato ||' ==> '||ReturnPcd);
 end loop;
end; 
*/  
  for be in (select b.cod_ts, pf.num_proposta_adesao 
               from la_beneficiario b, la_ppf_proposta pf
              where b.tipo_associado in ('T','P')
                and b.num_seq_proposta_ts = pf.num_seq_proposta_ts(+)
                and b.cod_ts in
               (select cod_cad 
                  from alt_mig_log_det 
                 where msg_retorno like '%ERRO%'  
                 and nome_jog in ( 'ALT_MIG_CAD_PROP_PKG.MIGRACAOFULL','ALT_MIG_CAD_PROP_PKG.MIGRACAOUNICA','ALT_MIG_CAD_PROP_PKG.IMPORTAR')) 
            ) loop        

    -- Atualiza Cadastro
    alt_mig_cad_benef_pkg.migracaounica(be.cod_ts);                

    --- Atualiza contrato - proposta
    alt_mig_cad_prop_pkg.importar(be.cod_ts, 
                                  be.num_proposta_adesao,
                                  indAcao,
                                  pcod_retorno);

    dbms_output.put_line(be.cod_ts || ' ==> ' || pcod_retorno);

  end loop;

end;
