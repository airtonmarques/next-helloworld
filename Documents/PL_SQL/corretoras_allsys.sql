select filial.nome_sucursal filial,
       es.nome_razao_social Razao,
       es.nome_entidade Nome,
       es.num_cgc CNPJ,
       cv.num_celular Telefone,
       cv.end_email Email,
       cv.data_inclusao Inclusao,
       cv.cod_corretor, 
       cv.ind_situacao/*,   
       (select (sum(pp.qtd_vidas_plano_medico) + sum(pp.qtd_vidas_plano_odonto))
        from ts.PROTOCOLO_PROPOSTA pp
        where pp.cod_corretor_ts = cv.cod_corretor_ts
        and pp.mes_ano_venda between to_date('01/01/2019','dd/mm/yyyy') and to_date('31/12/2019','dd/mm/yyyy')) Vidas_Protocoladas,
       (select sum(pp.val_total)
        from ts.PROTOCOLO_PROPOSTA pp
        where pp.cod_corretor_ts = cv.cod_corretor_ts
        and pp.mes_ano_venda between to_date('01/01/2019','dd/mm/yyyy') and to_date('31/12/2019','dd/mm/yyyy')) Valor_Pago*/
from ts.corretor_venda cv
join ts.entidade_sistema es on es.cod_entidade_ts = cv.cod_entidade_ts
join ts.sucursal filial on filial.cod_sucursal = cv.cod_sucursal
where cv.cod_tipo_produtor IN (4)
      and cv.data_exclusao is null
order by 1, 2
--and es.nome_entidade like '%NOVA AFFINITY%'

--1.089.879,62
