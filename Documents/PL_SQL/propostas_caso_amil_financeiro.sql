select distinct a.nome,
       b.num_associado,
       b.num_associado_operadora MO,
       b.num_proposta,
       p.num_proposta_adesao
from amil_sem_contrato_02122020 a
     left join ts.beneficiario b on b.nome_associado = a.nome
     left join ts.ppf_proposta p on p.num_seq_proposta_ts = b.num_seq_proposta_ts
order by 1     
