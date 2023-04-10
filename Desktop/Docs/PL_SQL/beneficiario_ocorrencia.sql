select oa.dt_ocorrencia,
       oa.txt_obs,
       oa.dt_fato,
       oa.cod_usuario_atu,
       oa.cod_ocorrencia,
       nvl(decode(sms.ind_situacao, 2, 'Enviado'), '-') Situacao,
       nvl((sms.ddd || '-' || sms.numero), '-') Destino,
       sms.dat_envio,
       sms.corpo,
       sms.retorno
from ts.beneficiario b
     join ts.ocorrencia_associado oa on oa.cod_ts = b.cod_ts
     left join ts.COM_SMS sms on sms.seq_comunicacao = oa.seq_comunicacao
where b.num_associado = 137715455
