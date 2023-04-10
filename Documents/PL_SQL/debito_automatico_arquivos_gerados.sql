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
       else 0 end Valor,
      cc.dt_geracao,
      cc.usuario_geracao,
      cc.qtd_registros_gerados,
      cc.val_total_geracao,
      cc.nom_arq_gerado,
      tac.nom_tipo_arq_cob,
      sac.nom_situacao_arq_cob
from ts.cobranca c
     join ts.beneficiario b on b.cod_ts_tit = c.cod_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.banco banco on banco.cod_banco = c.cod_banco_dcc
     join ts.controle_cobranca_reg r on r.num_seq_cobranca = c.num_seq_cobranca
     join ts.controle_cobranca cc on cc.num_seq_controle_cob = r.num_seq_controle_cob
     join ts.tipo_arquivo_cobranca tac on tac.cod_tipo_arq_cob = cc.cod_tipo_arq_cob
     join ts.situacao_arquivo_cobranca sac on sac.cod_situacao_arq_cob = cc.cod_situacao_arq_cob
where c.cod_tipo_cobranca = 3
      --and c.dt_competencia = to_date('01/03/2021', 'dd/mm/yyyy')
      --and c.num_controle_arq is null     
      and c.dt_emissao is not null
      and c.dt_cancelamento is null
      --and c.num_seq_cobranca = 13853415
      and c.dt_vencimento between to_date('01/05/2021', 'dd/mm/yyyy')
                                  and to_date('12/05/2021', 'dd/mm/yyyy')
order by 1, 2, 3, 4, 7 desc
--select * from ts.tipo_cobranca
