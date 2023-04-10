select distinct b.num_associado,
       b.num_associado_operadora,
       b.nome_associado,
       b.tipo_associado,
       b.data_inclusao,
       ce.qtd_laminas_grande_emissao,
       decode(pm.ind_participacao, 'S', 'Copart', 'N', 'Sem Copart') Copart,
       bf.dia_vencimento,
       (select count(1)
        from ts.cobranca c
        where c.cod_ts = b.cod_ts
              and c.dt_emissao is not null
              and c.dt_competencia >= to_date('01/08/2021', 'dd/mm/yyyy')) boletos_emitidos
from ts.beneficiario b
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
     join ts.beneficiario_faturamento bf on bf.cod_ts = b.cod_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.contrato_cobranca cc on cc.cod_ts_contrato = ce.cod_ts_contrato
where cc.cod_tipo_fat = 5
      and b.data_exclusao is null
      and b.tipo_associado IN ('T', 'P')
      and bf.cod_tipo_cobranca = 2
      and ce.tipo_empresa in (1)
