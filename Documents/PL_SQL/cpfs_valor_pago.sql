select a.num_contrato,
       a.nome_entidade,
       a.nom_operadora,
       a.cod_ts_tit,
       a.tipo_associado,
       a.beneficiario,
       a.CPF,
       a.data_nascimento,
       sum(a.valor) valor,
       sum(a.valor_net) valor_net,
       nvl(a.dependencia, 'Titular') Dependencia
from (select  
       ce.num_contrato,
       es.nome_entidade,
       op.nom_operadora,
       b.cod_ts_tit,
       b.tipo_associado,
       be.nome_entidade beneficiario,
       lpad(be.num_cpf,
            11,
            '0') CPF,
       be.data_nascimento,
       c.dt_competencia,
       ic.val_item_cobranca valor,
       ic.val_item_pagar valor_net,
       dep.nome_dependencia Dependencia
from ts.contrato_empresa ce
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.cobranca c on c.cod_ts_contrato = ce.cod_ts_contrato
     join ts.itens_cobranca ic on ic.num_ciclo_ts = c.num_ciclo_ts 
          and ic.num_seq_cobranca = c.num_seq_cobranca
     join ts.beneficiario b on b.cod_ts = ic.cod_ts
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     left join ts.tipo_dependencia dep on dep.cod_dependencia = b.cod_dependencia
where ce.num_contrato IN ('08407')--('08857', '14625')
      and c.dt_emissao is not null
      and c.dt_cancelamento is null
      and c.dt_baixa between to_date('01/01/2019', 'dd/mm/yyyy') and to_date('30/06/2019', 'dd/mm/yyyy')) a
group by a.num_contrato,
       a.nome_entidade,
       a.nom_operadora,
       a.cod_ts_tit,
       a.tipo_associado,
       a.beneficiario,
       a.CPF,
       a.data_nascimento,
       a.dependencia           
order by 1, 4, 5 desc
