select distinct op.nom_operadora Operadora,
       es.nome_entidade Entidade,
       banco.nome_banco Banco,
       b.cod_ts_tit,
       b.num_associado,
       b.nome_associado,
       b.tipo_associado,
       c.num_seq_cobranca, 
       c.dt_vencimento Vencimento,
       case b.tipo_associado 
         when 'T'
         then c.val_a_pagar
       else 0 end Valor  --, c.*
from ts.cobranca c
     join ts.beneficiario b on b.cod_ts_tit = c.cod_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
          and (b.cod_empresa is null or b.cod_empresa = ec.cod_entidade_ts)
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.banco banco on banco.cod_banco = c.cod_banco_dcc
where c.cod_tipo_cobranca = 3
      --and c.dt_competencia = to_date('01/03/2021', 'dd/mm/yyyy')
      --and c.num_controle_arq is null     
      and c.dt_emissao is not null
      and c.dt_cancelamento is null
      and not exists (select 1
                      from ts.controle_cobranca_reg r 
                      where r.num_seq_cobranca = c.num_seq_cobranca)
      --and c.num_seq_cobranca = 13853415
      and c.dt_vencimento between to_date('20/07/2021', 'dd/mm/yyyy')
                                  and to_date('16/08/2021', 'dd/mm/yyyy')
order by 1, 2, 3, 4, 7 desc
--select * from ts.tipo_cobranca
