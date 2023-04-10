--insert into cpf_tmp(cpf) values(
--update cpf_tmp set cpf = lpad(cpf, 11, '0') where length(cpf) < 11;
--delete cpf_tmp

------------------------------------------------------------------------

insert into cpf_com_restricao(num_seq_cpf_blacklist,
                              num_cpf,
                              ind_situacao,
                              cod_usuario_inc,
                              dt_inc,
                              cod_usuario_atu,
                              dt_atu) 
select seq_cmc_cpf_blacklist.nextval,
       c.cpf,
			 'A',
			 'RAFAQUESI',
			 sysdate,
			 'RAFAQUESI',
			 sysdate
from cpf_tmp c
where not exists (select 1 from cpf_com_restricao rc
                  where rc.num_cpf = c.cpf
									      and rc.ind_situacao = 'A')
