select tc.txt_nome_comunicacao tipo_comunicacao,
       e.destino email_destino,
       e.assunto assunto,
       e.ctr_optlock registro_envio,
       e.dat_envio data_envio,
       e.retorno retorno,
       b.num_associado num_beneficiario,
       b.nome_associado nome_beneficiario
from com_email e
     join ts.com_registro reg on reg.seq_comunicacao = e.seq_comunicacao
     join ts.tipo_comunicacao tc on tc.cod_tipo_comunicacao = reg.cod_tipo_comunicacao
     left join ts.beneficiario_contato bc on upper(bc.end_email) = e.destino
     left join ts.beneficiario b on b.cod_entidade_ts = bc.cod_entidade_ts
where e.ctr_optlock >= to_date('01/08/2021 00:00:00', 'dd/mm/yyyy hh24:mi:ss') 
      --and to_date('16/10/2020 23:59:00', 'dd/mm/yyyy hh24:mi:ss')
      and e.ind_situacao not in (2)
      and e.dat_envio is not null
/*select * 
from TS_TOP.COM_REGISTRO r
where r.seq_comunicacao IN (13226866, 13191674)*/
