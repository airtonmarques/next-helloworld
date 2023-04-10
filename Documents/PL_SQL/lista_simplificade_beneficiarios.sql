--numero da proposta , 
--nome , 
--ano de entrada de 2019 para tr�s , 
--estado do Brasil foi feito essa proposta
--Data inclusao,
--Data Exclusao

select distinct 
       filial.nome_sucursal Estado,
       p.num_proposta_adesao Proposta,
       b.cod_ts_tit Familia,
       b.nome_associado Nome,
       b.tipo_associado Tipo_Associado,
       b.data_inclusao Adesao,
       b.ind_situacao Situacao,
       b.data_exclusao Exclusao
from ts.beneficiario b
     join ts.sucursal filial on filial.cod_sucursal = b.cod_sucursal
     left join ts.ppf_proposta p on p.num_seq_proposta_ts = b.num_seq_proposta_ts
where b.data_inclusao <= to_date('31/12/2019', 'dd/mm/yyyy')
order by 1, 2, 3, 5 desc
