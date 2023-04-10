--HEADER
select '0' || --1 Fixo
       '092021' || --4 Competência
       lpad(a.num_cnpj, 14, '0') || --CNPJ Allcare
       lpad(a.nom_razao_social, 100, ' ') || --Nome Allcare
       lpad(' ', 133, ' ') || --133 Brancos
       'F'  --1 Fixo F
       
from ts.operadora a
where a.cod_operadora = 3


--=========================================
--TRAILER
select '9' || --1 Fixo
       '00001264' || --8 Qtd Registros 
       '0000000185792977' || --16 valor total
       lpad(' ', 229, ' ') || --133 Brancos
       'F'  --1 Fixo F
from dual
