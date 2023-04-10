select sac.num_sac,
       sac.dt_registro,
       sac.num_protocolo_ans,
       b.num_associado,
       b.nome_associado,
       sit.nom_situacao,
       sac.dt_pretendido,
       sac.dt_leitura,
       orig.nom_origem_sac,
       tip.nom_solicitacao,
       sac.txt_assunto,
       sac.txt_descricao,
       sac.txt_encerramento
from ts.beneficiario b
     join ts.SAC_REGISTRO sac on sac.cod_ts = b.cod_ts
     join ts.sac_situacao sit on sit.cod_situacao = sac.cod_situacao
     join ts.sac_origem orig on orig.cod_origem_sac = sac.cod_origem_sac
     join ts.sac_tipo_solicitacao tip on tip.cod_tipo_solicitacao = sac.cod_tipo_solicitacao
where b.num_associado = 137715455
      --and sac.num_protocolo_ans = '41728920210804003759'
      --and atd.data_inicio_atendimento = to_date('04/08/2021 18:40:42', 'dd/mm/yyyy hh24:mi:ss')
