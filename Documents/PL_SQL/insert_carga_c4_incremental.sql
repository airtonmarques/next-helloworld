select *
from alt_inadimplentes_fin_c4 c
where not exists (select 1
                  from carga_c4_incr c4
									where c4.cobranca = c.cobranca)
      and c.tipo_pessoa = 'PJ'									
      --and c.tipo_pessoa = 'PJ' --'PF' Ser�o 2 arquivos, um para PF e outro PJ
			--Padr�o do nome do arquivo: cobranca_c4_pf_DDMMYYYY.csv; cobranca_c4_pj_DDMMYYYY.csv
-----------------------

insert into carga_c4_incr c
select distinct c.cobranca, c.tipo_pessoa, sysdate
from alt_inadimplentes_fin_c4 c
where not exists (select 1
                  from carga_c4_incr c4
									where c4.cobranca = c.cobranca)
