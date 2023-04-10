select e.destino email,
       e.assunto assunto,
       e.retorno,
       e.dat_envio data_envio
from com_email e
where upper(e.destino) = upper('gilrgalvao@hotmail.com')
order by 4, 2

select s.dat_envio,
       s.ddd,
       s.numero,
       s.corpo
from com_sms s
where s.ddd = 83
      and s.numero = 993449810
order by 1      
