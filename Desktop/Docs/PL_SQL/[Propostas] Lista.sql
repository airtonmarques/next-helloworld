select op.nom_operadora Operadora,
       status.txt_situacao Situacao,
       p.num_proposta_adesao Numero_Proposta,
       p.nome_titular Titular,
       p.num_cpf_resp CPF_Titular,
       ass.nome_associado Nome,
       ass.tipo_associado Tipo,
       ass.num_cpf CPF,
       ass.peso Peso,
       ass.altura Altura,
       ass.ind_sexo Genero,
       to_date(ass.data_nascimento, 'dd/mm/yyyy') Nascimento,
       p.dt_inicio_vigencia Vigencia,
       ass.cod_grupo_carencia Carencia
from ts.ppf_proposta p
     join ts.ppf_operadoras op on op.cod_operadora = p.cod_operadora_contrato
     join ts.ppf_situacao_proposta status on status.cod_situacao_proposta = p.cod_situacao_proposta
     left join ts.mc_associado_mov ass on ass.num_seq_proposta_ts = p.num_seq_proposta_ts
where/* p.cod_operadora_contrato IN (3, 5)
      and*/ p.dt_inicio_vigencia >= to_date('15/11/2020', 'dd/mm/yyyy')
      --and status.cod_situacao_proposta in (14, 25, 26)

order by 1, 3, 5 desc      
