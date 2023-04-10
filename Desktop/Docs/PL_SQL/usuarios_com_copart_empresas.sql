update ts.usuario u1
set u1.txt_senha = 'INI123'
where u1.cod_usuario IN
(select distinct u.cod_usuario, u.txt_senha
from ts.extrato_coparticipacao cop
     join ts.beneficiario b on b.cod_ts = cop.cod_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.usuario u on u.cod_identificacao_ts = ce.cod_ts_contrato
where cop.dt_realizacao >= to_date('01/01/2021', 'dd/mm/yyyy')
      and ce.tipo_empresa IN (2)
      and u.cod_tipo_usuario IN (6)
      and u.ind_troca_senha = 'N'
      and u.ind_bloqueio = 'N')
     
