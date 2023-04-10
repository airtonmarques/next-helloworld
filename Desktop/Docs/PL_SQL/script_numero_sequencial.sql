declare
   v_seq   number(4);
begin
   for cur1 in ( select cod_ts
                   from beneficiario
                  where tipo_associado = 'T'   
                  order by cod_ts )
   loop
      v_seq := 0;



    for cur2 in ( select cod_ts, tipo_associado
                      from beneficiario
                     where cod_ts_tit = cur1.cod_ts
                     order by tipo_associado desc, cod_ts )
      loop
         update beneficiario ass
            set ass.num_seq_matric_empresa = v_seq
          where ass.cod_ts = cur2.cod_ts
					      and num_seq_matric_empresa is null;
					
          
        v_seq := v_seq + 1;
      end loop;



    commit;
   end loop;
end;
