select p.num_proposta_adesao,        
       lpad(be.num_cpf, 11, '0') CPF,
       b.tipo_associado,
       b.nome_associado,
       be.data_nascimento,
       p.nom_contratante,
       lpad(p.num_cpf_resp, 11, '0') CPF
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.ppf_proposta p on p.num_seq_proposta_ts = b.num_seq_proposta_ts
where b.nome_associado = 'CLARA DE LIMA ROCHA'
order by 1, 3 desc
--1206504
