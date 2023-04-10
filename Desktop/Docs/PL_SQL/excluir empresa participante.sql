select  distinct
       'delete ts.empresa_contrato where cod_ts_contrato = ' || ec.cod_ts_contrato || ' and cod_entidade_ts = ' || ec.cod_entidade_ts || ';'  
from ts.entidade_sistema es
     join ts.contrato_empresa ce on ce.cod_titular_contrato = es.cod_entidade_ts
		 join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato 
where 1 = 1
      --ec.ind_tipo_participante = 'P'
      and ce.num_contrato is null
			and ce.data_inicio_vigencia = to_date('01/03/2023', 'dd/mm/yyyy')
			and not exists (select 1 from ts.beneficiario b
			                where b.cod_ts_contrato = ce.cod_ts_contrato)
			and exists (select 1
			            from ts.contrato_campos_operadora cco
									where cco.cod_operadora = ce.cod_operadora_contrato
									      and cco.cod_ts_contrato = ce.cod_ts_contrato
												and cco.cod_campo = 'NOME_MIGRACAO'
												and cco.val_campo = 'PROJETO MORUMBI')
			and es.num_cgc IN ()
