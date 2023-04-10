select distinct adm.nom_operadora Adm,
       ce.data_inicio_vigencia,
       ce.data_fim_vigencia,
       o.nom_operadora Operadora,
       porte.nome_tipo_empresa Porte,
       es.nome_entidade Entidade,
       ce.num_contrato,
       (select cv.dia_vencimento from ts.contrato_vencimentos cv 
               where cv.cod_ts_contrato = ce.cod_ts_contrato
                     and cv.ind_tipo_dia_vencimento = 'B') vencimento_boleto, 
       (select cv.dia_vencimento from ts.contrato_vencimentos cv 
               where cv.cod_ts_contrato = ce.cod_ts_contrato
                     and cv.ind_tipo_dia_vencimento = 'D') vencimento_debito,
       ce.dia_pagamento,
       tf.nom_tipo_fat,
			 cc.mes_fixo_reajuste,
       --cc.dt_ini_cobranca,
       cc.dia_ini_periodo_fat,
       cc.val_taxa_associativa,
      decode(ce.qtd_meses_desloc_fat, 0, 'Atual', -1, 'Anterior', 1, 'Subsequente') mesCobertura,
      nvl(ce.dia_processar_faturamento, '10') faturarDias,
       (select count(1) from ts.beneficiario b
               where b.cod_ts_contrato = ce.cod_ts_contrato
                     and (b.data_exclusao is null OR b.data_exclusao > last_day(sysdate))) vidas_ativas,
										 
			(select cco.val_campo
                  from ts.contrato_campos_operadora cco
                  where cco.cod_operadora = ce.cod_operadora_contrato
                        and cco.cod_ts_contrato = ce.cod_ts_contrato
                        and cco.cod_campo = 'NOME_MIGRACAO') nome_migracao,
												
			(select cco.val_campo
                  from ts.contrato_campos_operadora cco
                  where cco.cod_operadora = ce.cod_operadora_contrato
                        and cco.cod_ts_contrato = ce.cod_ts_contrato
                        and cco.cod_campo = 'NOME_PROJETO') nome_projeto
from ts.contrato_empresa ce
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
     join ts.ppf_operadoras o on o.cod_operadora = ce.cod_operadora_contrato
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.contrato_cobranca cc on cc.cod_ts_contrato = ce.cod_ts_contrato
     join ts.tipo_faturamento tf on tf.cod_tipo_fat = cc.cod_tipo_fat
		 join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
where 1 = 1
      /*and ce.num_contrato IN ('08039')*/
			and (cc.dt_ultimo_reajuste is null OR
			     cc.dt_ultimo_reajuste = (select max(cc1.dt_ultimo_reajuste)
                                   from ts.contrato_cobranca cc1
                                   where cc1.cod_ts_contrato = ce.cod_ts_contrato))
			/*and exists (select 1
			            from ts.contrato_campos_operadora cco
									where cco.cod_operadora = ce.cod_operadora_contrato
									      and cco.cod_ts_contrato = ce.cod_ts_contrato
												and cco.cod_campo = 'NOME_MIGRACAO'
												and cco.val_campo = 'PROJETO MORUMBI')*/
order by 1, 4, 5, 6, 2
