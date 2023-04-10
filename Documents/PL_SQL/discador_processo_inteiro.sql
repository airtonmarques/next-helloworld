-------- AMIL -------------
/*
select count(1)
from ALL_DISCAD_FULL d
     join ts.ppf_proposta p on p.num_seq_proposta_ts = d.num_seq_proposta_ts
where d.chk_random = -1
      and p.cod_operadora_contrato = 1
*/
----------------------------
DELETE ALL_DISCAD_FULL d 
WHERE d.id IN (SELECT d1.id
               FROM ALL_DISCAD_FULL d1
                    join ts.ppf_proposta p on p.num_seq_proposta_ts = d1.num_seq_proposta_ts
               WHERE p.cod_operadora_contrato = 1
                     and d1.chk_random = -1
                     and ROWNUM <= 6--500000
               ORDER BY DBMS_RANDOM.RANDOM);      
    
--------------------------------------------------------------------------           
/*
begin
ALL_DISCAD_FULL_PCD;
ALL_DISCAD_RAND_PCD;
end;
*/               
    
      
