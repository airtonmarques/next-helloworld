create or replace function alt_val_clube_vantagens_fnc(DataVs varchar2)
  return varchar2 as
  sEmail  varchar2(500);
  bReturn varchar2(10);

  iCodTipoCadUsu number;
  iCodCadUsu     number;
  iBeneficiario  number;
  iCorretor      number;
  iColaborador   number;
  
begin
  -- Verifica usuário logado
  iCodTipoCadUsu := sys_get_vs_number_fnc(DataVs, 'COD_TIPO_CAD_USU');
  iCodCadUsu     := sys_get_vs_number_fnc(DataVs, 'COD_CAD_USU');
  if sys_get_config_usu_fnc(111, iCodTipoCadUsu, iCodCadUsu) = 0 then
    return sys_return_error('Acesso negado.');
  end if;

  -- Executa a rotina
  sEmail := sys_get_vs_str_fnc(DataVs, 'Email');
  sEmail := trim(upper(sEmail));
  if sEmail is null then
    sEmail := sys_get_vs_str_fnc(DataVs, 'E-mail');
    sEmail := trim(upper(sEmail));
  end if;

  if sEmail is null then
    return sys_return_error('E-mail obrigatório.');
  else 
    
  --Validação de Beneficiários AllCare
    select 1 
           into iBeneficiario
    from alt_cad cad
         join alt_cad_mail mail on mail.cod_tipo_cad = cad.cod_tipo_cad 
                                and mail.cod_cad = cad.cod_cad
    where upper(mail.mail_cad_mail) = sEmail
          and cad.cod_sit_cad = 1
          and cad.cod_tipo_cad = 0;
          
    --Validação de Corretor AllCare
    select 1 
           into iCorretor
    from alt_cad cad
         join alt_cad_mail mail on mail.cod_tipo_cad = cad.cod_tipo_cad 
                                and mail.cod_cad = cad.cod_cad
    where upper(mail.mail_cad_mail) = sEmail
          and cad.cod_sit_cad = 1
          and cad.cod_tipo_cad = 4;
          
    --Validação de Colaborador AllCare
    select 1 
           into iColaborador
    from alt_cad cad
         join alt_cad_mail mail on mail.cod_tipo_cad = cad.cod_tipo_cad 
                                and mail.cod_cad = cad.cod_cad
    where upper(mail.mail_cad_mail) = sEmail
          and cad.cod_sit_cad = 1
          and cad.cod_tipo_cad = 0;
    
    if iBeneficiario = 1 OR iCorretor = 1 OR iColaborador = 1 then
      bReturn := 'True';
    else
      bReturn := 'False';
    end if;
  end if;

  return sys_return_true('') || '|JsonReturn|{"ValidacaoOk":"' || bReturn || '"}';
end;
/
