--PerÍodo: Março até a data atual 
--NUM. PROPOSTA / VIGÊNCIA / TITULAR / VENDEDOR/ UF/ CPF/ OPERADORA/ PLANO/ FORMA PAGAMENTO/ DATA CADASTRO/  QNT DE VIDAS
--saude_id = 77 (Hapvida), 54 (CNU) 

--select *
--from public.saudes s
--where upper(s.titulo) like '%INFRA%'

select distinct
c.id,
c.a Proposta,
c.vigencia Vigencia,
c.nome Titular,
v.nome Vendedor,
uf.titulo UF,
c.cpf CPF,
o.abreviacao Operadora,
pl.titulo Plano,
pg.titulo Pagamento,
c.created Cadastro,
(select 1 + count(1) from public.dependentes d where d.cliente_id = c.id) Vidas
from public.clientes c
	join public.ufs uf on uf.id = c.uf_id
	join public.saudes s on s.id = c.saude_id
	join public.operadoras o on o.id = s.operadora_id
	join public.planosaudes pl on pl.id = c.planosaude_id
	join public.fpagamentos pg on pg.id = c.fpagamento_id
	left join public.vendedors v on v.id = c.vendedor_id
where c.saude_id IN (54, 77)
	and c.vigencia >= to_date('01/03/2020', 'dd/mm/yyyy')
order by 3, 5, 4	