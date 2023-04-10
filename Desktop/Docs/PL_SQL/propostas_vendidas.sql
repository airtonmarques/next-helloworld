select ent.nome_entidade,
       ent.nome_razao_social,
       cv.cod_corretor,
       eqp.nome_razao_social,
       count(1),
			 sum(p.qtd_beneficiarios)
from ts.ppf_proposta p
     join ts.corretor_venda cv on cv.cod_corretor_ts = p.cod_produtor_ts
     join ts.entidade_sistema eqp on eqp.cod_entidade_ts = cv.cod_entidade_ts
     join ts.beneficiario b on b.num_seq_proposta_ts = p.num_seq_proposta_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.entidade_sistema ent on ent.cod_entidade_ts = ce.cod_titular_contrato
where trunc(p.dt_venda) >= to_date('01/08/2022', 'dd/mm/yyyy')
      --and p.num_proposta_adesao = '09780021131'
      --and eqp.nome_razao_social like '%ALLTECH%'
group by ent.nome_entidade,
       ent.nome_razao_social,
       cv.cod_corretor,
       eqp.nome_razao_social
order by 5 desc, 4 
