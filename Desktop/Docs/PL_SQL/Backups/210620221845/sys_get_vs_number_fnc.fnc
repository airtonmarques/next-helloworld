create or replace function sys_get_vs_number_fnc(VariavelString in varchar2,
                                                 NomeCampo      in varchar2)

 return number is

  sReturn varchar2(4000);

BEGIN
  -- Carrega variaveis
  sReturn := sys_get_vs_str_fnc(VariavelString, NomeCampo);

  if sReturn is null then
    return - 1;
  end if;

  sReturn := replace(sReturn, '.', ',');

  if sys_is_number_fnc(sReturn) = -1 then
    return to_number(sReturn);
  else
    return - 1;
  end if;
end;
/
