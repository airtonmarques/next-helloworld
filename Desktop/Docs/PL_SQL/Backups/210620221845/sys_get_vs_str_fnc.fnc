create or replace function sys_get_vs_str_fnc(VariavelString in varchar2,
                                              NomeCampo      in varchar2,
                                              Tamanho        in number default 4000)

 return varchar2 is

  sVariavelString clob;
  sNomeCampo      varchar2(500);
  iIndexOf        number;
  sReturn         clob;

BEGIN
  -- Carrega variaveis
  sVariavelString := '|' || trim(upper(VariavelString)) || '|';
  sNomeCampo      := '|' || trim(upper(NomeCampo)) || '|';

  iIndexOf := instr(sVariavelString, sNomeCampo);

  if iIndexOf = 0 then
    return '';
  else
    sReturn := substr('|' || VariavelString, iIndexOf + length(sNomeCampo));
    if not instr(sReturn, '|') = 0 then
      sReturn := substr(sReturn, 0, instr(sReturn, '|') - 1);
    end if;
    if length(sReturn) > Tamanho then
      sReturn := substr(sReturn, 1, Tamanho);
    end if;

    return sReturn;
  end if;
end;
/
