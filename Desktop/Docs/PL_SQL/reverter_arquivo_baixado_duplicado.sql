 select rec.num_seq_credito_recebido
from ts.credito_recebido_sur rec
     join ts.controle_recebimento_sur crec on crec.num_seq_controle_recbto = rec.num_seq_controle_recbto
where rec.num_seq_cobranca IN () --and rec.ind_estado_credito = 2

select rec.*
from ts.credito_recebido_sur rec
     join ts.controle_recebimento_sur crec on crec.num_seq_controle_recbto = rec.num_seq_controle_recbto
where rec.num_seq_cobranca = 12971908 --and rec.ind_estado_credito = 2

--Del
select * 
from 
--delete
ts.ocorrencia_alocacao_sur oa
where oa.num_seq_credito_recebido = 12619421

--Del
select * 
from 
--delete
ts.credito_recebido_sur ss
where ss.num_seq_credito_recebido = 12619421

select *
from ts.cobranca c
where c.num_seq_cobranca = 12971908 for update
