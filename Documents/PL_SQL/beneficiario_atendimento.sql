select atd.num_atendimento_ts,
       atd.data_inicio_atendimento,
       atd.data_fim_atendimento,
       sit.txt_situacao,
       atd.cod_usuario,
       atd.sgl_area,
       atd.ind_origem_atendimento,  
       motAtd.txt_motivo_atendimento,
       atd.txt_obs
from ts.beneficiario b
     join ts.atd_controle atd on atd.cod_ts = b.cod_ts
     join ts.atd_situacao sit on sit.ind_situacao = atd.ind_situacao
     left join ts.atd_motivo mot on mot.num_atendimento_ts = atd.num_atendimento_ts
     left join ts.atd_motivo_atendimento motAtd on motAtd.Cod_Motivo_Atendimento = mot.cod_motivo
where b.num_associado = 137715455
      --and atd.num_atendimento_ts = '41728920210811003291'
      --and atd.data_inicio_atendimento = to_date('04/08/2021 18:40:42', 'dd/mm/yyyy hh24:mi:ss')
