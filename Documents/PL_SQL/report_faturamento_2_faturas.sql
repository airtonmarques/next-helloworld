select b.cod_ts_tit,
       b.cod_ts,
       adm.nom_operadora adm,
       ce.num_contrato contrato,
			 es.nome_entidade entidade,
			 b.num_associado,
			 b.nome_associado,
			 (select count(1)
			  from ts.cobranca c1
				where c1.cod_ts = b.cod_ts_tit
				      and c1.dt_baixa is null
							and c1.dt_cancelamento is null
							and c1.dt_emissao is not null) qtd_cob_Aberto,
			 tc.nom_tipo_ciclo ciclo,
			 c.dt_competencia competencia,
			 nvl(c.dt_vencimento_orig, c.dt_vencimento) dt_vencimento_original,
			 c.dt_vencimento dt_vencimento,
			 c.num_seq_cobranca,
			 (select f.num_fatura from ts.fatura f where f.num_seq_fatura_ts = c.num_seq_fatura_ts) fatura,
			 (trunc(sysdate) - c.dt_vencimento) dias_atraso,
			 b.data_exclusao dt_exclusao,
			 exc.nome_motivo_exc_assoc motivo_exclusao,
			 b.tipo_associado,

       (SELECT nvl(max(continad.qtd_dias_atraso), max(sitinad.qtd_dias_atraso)) dias
        FROM ts.situacao_inadimplencia sitinad
             left join ts.situacao_inadimpl_contrato continad on continad.cod_inadimplencia = sitinad.cod_inadimplencia
       WHERE sitinad.ind_tipo_regra = 1
             and sitinad.ind_situacao_associado = 'S'
             and continad.cod_ts_contrato = ce.cod_ts_contrato
             and continad.dt_validade > sysdate) dias_suspensao,
								 
			 (SELECT nvl(max(continad.qtd_dias_atraso), max(sitinad.qtd_dias_atraso)) dias
        FROM ts.situacao_inadimplencia sitinad
             left join ts.situacao_inadimpl_contrato continad on continad.cod_inadimplencia = sitinad.cod_inadimplencia
       WHERE sitinad.ind_tipo_regra = 1
             and sitinad.ind_situacao_associado = 'E'
             and continad.cod_ts_contrato = ce.cod_ts_contrato
             and continad.dt_validade > sysdate) regra_exclusao,					 
								 
			 (select sum(ic.val_item_cobranca) 
			  from ts.itens_cobranca ic 
				where ic.num_seq_cobranca = c.num_seq_cobranca
              and ic.num_ciclo_ts = c.num_ciclo_ts
							and ic.cod_tipo_rubrica IN (1,
																							2,
																							8,
																							9,
																							10,
																							13,
																							14,
																							17,
																							18,
																							19,
																							20,
																							45,
																							50,
																							177,
																							178,
																							179,
																							203,
																							46)) valor_itens_somados,
			 c.val_a_pagar valor_boleto,
			 (SELECT TRUNC(MAX(OCO.DT_OCORRENCIA))
          FROM TS.OCORRENCIA_ASSOCIADO OCO
          WHERE OCO.COD_TS = b.COD_TS
          AND OCO.COD_OCORRENCIA IN (8, 54)) dt_ultima_suspensao,

          (SELECT MAX(TRUNC(OA.DT_OCORRENCIA))
           FROM TS.OCORRENCIA_ASSOCIADO OA
           WHERE OA.COD_TS = b.COD_TS
                 AND OA.COD_OCORRENCIA IN (186, 19)) dt_reativacao,
			 
			 ce.cod_ts_contrato,
			 ce.cod_operadora_contrato,
			 DECODE((SELECT COUNT(1)
                                               FROM ts.acao_jud_pgto a
                                               WHERE a.cod_ts IN (b.cod_ts, b.cod_ts_tit)
                                                     AND SYSDATE BETWEEN a.DT_INI_ACAO AND
                                                         NVL(a.DT_FIM_ACAO, to_date('31/12/3000', 'DD/MM/YYYY'))),
                  0,
                  'NÃO POSSUI',
                  'POSSUI') acao_judicial
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.beneficiario_contrato bc on bc.cod_ts = b.cod_ts
     join ts.beneficiario_faturamento bf on bf.cod_ts = b.cod_ts_tit
     join ts.cobranca c on c.cod_ts = b.cod_ts_tit
		 join ts.ciclo_faturamento cf on cf.num_ciclo_ts = c.num_ciclo_ts
		 join ts.tipo_ciclo tc on tc.cod_tipo_ciclo = cf.cod_tipo_ciclo                              
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
          and (b.cod_empresa is null OR ec.cod_entidade_ts = b.cod_empresa)
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
     join ts.sucursal filial on filial.cod_sucursal = ce.cod_sucursal
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
     join ts.motivo_exclusao_assoc exc on exc.cod_motivo_exc_assoc = bc.cod_motivo_exclusao

where c.dt_cancelamento is null
      and c.dt_baixa is null
      and c.dt_emissao is not null
      and c.num_seq_fatura_ts is not null
			and c.dt_vencimento < trunc(sysdate)
			and b.data_exclusao is not null
			and exists (select 1
			            from ts.beneficiario b1
									where b1.cod_ts = b.cod_ts_tit
									      and b1.data_exclusao is not null)
			and c.dt_competencia between to_date('01/09/2022', 'dd/mm/yyyy') and last_day('01/11/2022')
			--and b.num_associado = '137512767'
			--and b.nome_associado = 'AIRTON MARQUES DA SILVA JUNIOR'

			and (select count(1) 
        from ts.cobranca c1
        where c1.cod_ts = b.cod_ts_tit
              and c1.dt_baixa is null
              and c1.dt_cancelamento is null
              and c1.dt_emissao is not null
							and c1.dt_vencimento < trunc(sysdate)
							and exists (select 1
                  from ts.itens_cobranca ic1 
                  where ic1.num_seq_cobranca = c1.num_seq_cobranca
                        and ic1.num_ciclo_ts = c1.num_ciclo_ts
                        and ic1.cod_tipo_rubrica IN (1,
                                              2,
                                              8,
                                              9,
                                              10,
                                              13,
                                              14,
                                              17,
                                              18,
                                              19,
                                              20,
                                              45,
                                              50,
                                              177,
                                              178,
                                              179,
                                              203,
                                              46))) > 1

      and exists (select 1
                  from ts.itens_cobranca ic 
                  where ic.num_seq_cobranca = c.num_seq_cobranca
                        and ic.num_ciclo_ts = c.num_ciclo_ts
                        and ic.cod_tipo_rubrica IN (1,
                                              2,
                                              8,
                                              9,
                                              10,
                                              13,
                                              14,
                                              17,
                                              18,
                                              19,
                                              20,
                                              45,
                                              50,
                                              177,
                                              178,
                                              179,
                                              203,
                                              46))							
      
order by 1
