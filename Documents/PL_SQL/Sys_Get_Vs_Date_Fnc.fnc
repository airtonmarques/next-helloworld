CREATE OR REPLACE Function Sys_Get_Vs_Date_Fnc(Variavelstring In Varchar2,
                                               Nomecampo      In Varchar2)
  Return Date Is

  sReturn          Varchar2(4000);
  sFormaToDate     Varchar2(20) := 'dd/mm/yyyy';
  sFormatodatehora Varchar2(40) := 'dd/mm/yyyy hh24:mi:ss';
  dDate            Date;
Begin
  -- Carrega variaveis
  Sreturn := Sys_Get_Vs_Str_Fnc(Variavelstring, Nomecampo);
  If Length(Sreturn) = 10 Then
    Ddate := To_Date(Sreturn, Sformatodate);
  Elsif Length(Sreturn) = 19 Then
    Ddate := To_Date(Sreturn, Sformatodatehora);
  Else Return Sys_Get_Data_Ini_Fnc;  
  End If;

  Return Ddate;
Exception
  When Others Then
    Return Sys_Get_Data_Ini_Fnc;
End;
/
