select distinct 
			 TRIM(TO_CHAR(ES.NUM_CGC)) cnpj,
				ES.NOME_RAZAO_SOCIAL razao,
				to_char(CE.DATA_INICIO_VIGENCIA,'DD/MM/YYYY') vigencia,
				decode(CE.cod_operadora_contrato,3,'AMBOS',
				decode(CE.ind_tipo_produto,1,'MEDICO', 2,'DENTAL')) plano,
				nvl(ce.dia_pagamento,ce.dia_ini_periodo_fat) vencimento,
				op.nom_operadora operadora,
				ce.num_contrato num_contrato,
				ed.email,
				--e.end_email email,
				--instr(e.end_email, ';'),
				vd.vidas,
				tf.cod_tipo_fat,
				tf.nom_tipo_fat
from ts.CONTRATO_EMPRESA ce
			join ts.ENTIDADE_SISTEMA es ON ES.COD_ENTIDADE_TS = ce.COD_TITULAR_CONTRATO
			JOIN ts.PPF_OPERADORAS OP ON OP.COD_OPERADORA = ce.COD_OPERADORA_CONTRATO
			JOIN ts.enderecos e ON e.cod_entidade_ts = es.cod_entidade_ts AND e.end_email is Not Null
			join all_enderecos_duplicados ed on ed.cod_ts_entidade = es.cod_entidade_ts
			left join ts.contrato_cobranca cc on cc.cod_ts_contrato = ce.cod_ts_contrato
			left join tipo_faturamento tf on tf.cod_tipo_fat = cc.cod_tipo_fat
			LEFT JOIN (SELECT lb.COD_TS_CONTRATO COD_TS_CONTRATO,
									      COUNT(1) VIDAS
			           FROM ts.BENEFICIARIO lb
								 WHERE lb.IND_SITUACAO IN ('A','S')
								Group by lb.COD_TS_CONTRATO) vd on vd.COD_TS_CONTRATO = ce.COD_TS_CONTRATO
where 1 = 1
			and CE.IND_SITUACAO = 'A' 
			and ce.num_contrato is not null
			--and vd.vidas < 100
			--and vd.vidas >= 100
      --and es.num_cgc = '10268203000117'
			--and ce.num_contrato = '46333'
			and exists (select 1              from ts.contrato_campos_operadora cco
																	where cco.cod_ts_contrato = ce.cod_ts_contrato
																				and cco.cod_campo = 'NOME_MIGRACAO'
																				and cco.val_campo = 'PROJETO MORUMBI') 
			and tf.cod_tipo_fat not IN (5)
			and upper(op.nom_operadora) like '%BRADESCO%'  
      and ce.data_inicio_vigencia >= to_date('01/04/2023', 'dd/mm/yyyy') 
																				
     /* and (select count(1)
           from ts.contrato_empresa ce1
                join ts.entidade_sistema es1 on es1.cod_entidade_ts = ce1.cod_titular_contrato
           where es1.num_cgc = es.num_cgc
					       and CE1.IND_SITUACAO = 'A'
								   and exists (select 1 from ts.contrato_campos_operadora cco1
                               where cco1.cod_ts_contrato = ce1.cod_ts_contrato
                                     and cco1.cod_campo = 'NOME_MIGRACAO'
                                     and cco1.val_campo = 'PROJETO MORUMBI')) > 1
					--and instr(e.end_email, ';') = 0
          and instr(e.end_email, ';') > 0*/
order by 1,5,2

/*5	Boleto para Titular
1	Fatura e Boleto para Contratante
9	Fatura Contratante e Boleto Grupo*/
--aon_menos_100_vidas_fatura_bol_contr_240220231720
--aon_menos_100_vidas_fatura_contr_bol_grupo_240220231720
