
create or replace view vw_prop_vendedores as
select distinct 
       opp.nom_operadora Operadora,
       b.cod_ts_tit, --42378
       ce.num_contrato,
       b.num_associado,
       p.num_proposta_adesao,
       b.num_proposta num_proposta_beneficiario,
       b.data_inclusao,
       b.data_exclusao,
       b.num_associado_operadora,
       lpad(be.num_cpf, 11, '0') CPF,
       b.nome_associado,
       b.tipo_associado,
       pm.cod_plano,
       pm.nome_plano,
       b.data_suspensao,
       b.data_fim_suspensao,
       ce.num_contrato_operadora Numero_entidade,
       es.nome_entidade Entidade,
       filial.nome_sucursal Filial,
       porte.nome_tipo_empresa Porte,
       lpad(esVendedor.Num_Cpf, 11, '0') CPF_Vendedor,
       esVendedor.Nome_Entidade Vendedor,
       esCorretora.Num_Cgc CNPJ,
       esCorretora.Nome_Entidade Corretora      
       
       
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.ppf_operadoras opp on opp.cod_operadora = ce.cod_operadora_contrato
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
     join ts.sucursal filial on filial.cod_sucursal = ce.cod_sucursal
     left join ts.ppf_proposta p on p.num_seq_proposta_ts = b.num_seq_proposta_ts
     left join ts.corretor_venda cvVendedor on cvVendedor.Cod_Corretor_Ts = p.cod_vendedor_ts
     left join ts.entidade_sistema esVendedor on esVendedor.Cod_Entidade_Ts = cvVendedor.Cod_Entidade_Ts
     left join ts.corretor_venda cv on  cv.cod_corretor_ts = p.cod_produtor_ts
     left join ts.entidade_sistema esCorretora on esCorretora.Cod_Entidade_Ts = cv.cod_entidade_ts

--where --ce.cod_operadora_contrato IN (1, 4) --4 next
      --and nvl(b.data_exclusao, to_date('31/12/3000', 'DD/MM/YYYY')) > last_day('01/06/2020')
      --and b.nome_associado = upper('Samuel Vitor da Silva')
      --and b.num_associado_operadora like '%076385164%'
      --and b.data_exclusao is  null
      --and exists (select 1 from ts.itens_cobranca ic where ic.cod_ts = b.cod_ts 
      --            and ic.mes_ano_ref between to_date('01/06/2020', 'dd/mm/yyyy') and to_date('30/09/2020', 'dd/mm/yyyy'))
order by 1, 2, 11 desc;

