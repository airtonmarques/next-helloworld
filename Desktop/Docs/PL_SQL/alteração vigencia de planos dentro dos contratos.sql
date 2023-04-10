select distinct 
       -- extract(day from c.inicio_de_vigencia),
       --ce.cod_ts_contrato,
			/* 'update ts.contrato_empresa ce set ce.data_inicio_vigencia = to_date(''' || lpad(extract(day from c.inicio_de_vigencia), 2, '0') || 
			 '/03/2023'', ''dd/mm/yyyy'') where ce.cod_ts_contrato = ' || ce.cod_ts_contrato || ';' */
			 
			  /*'update ts.contrato_empresa ce set ce.data_fim_vigencia = null ' || 
			  'where ce.cod_ts_contrato = ' || ce.cod_ts_contrato || ';'*/
				
				/*'update ts.contrato_cobranca cc set cc.dt_ini_cobranca = to_date(''' || lpad(extract(day from c.inicio_de_vigencia), 2, '0') || 
			 '/03/2023'', ''dd/mm/yyyy'') where cc.cod_ts_contrato = ' || ce.cod_ts_contrato || ';'*/
			 
			 'update ts.contrato_plano cp set cp.dt_ini_vigencia = to_date(''' || lpad(extract(day from c.inicio_de_vigencia), 2, '0') || 
			 '/03/2023'', ''dd/mm/yyyy'') where cp.cod_ts_contrato = ' || ce.cod_ts_contrato || ';',
			 
			 'update ts.contrato_adesao_plano cp set cp.dt_ini_vigencia = to_date(''' || lpad(extract(day from c.inicio_de_vigencia), 2, '0') || 
			 '/03/2023'', ''dd/mm/yyyy''), cp.dt_ini_validade = to_date(''' || lpad(extract(day from c.inicio_de_vigencia), 2, '0') || 
			 '/03/2023'', ''dd/mm/yyyy'')where cp.cod_ts_contrato = ' || ce.cod_ts_contrato || ';',
			 
			 'update ts.VALOR_FE_CONTRATO cp set cp.dt_ini_vigencia = to_date(''' || lpad(extract(day from c.inicio_de_vigencia), 2, '0') || 
			 '/03/2023'', ''dd/mm/yyyy'') where cp.cod_ts_contrato = ' || ce.cod_ts_contrato || ';'
			 
			 /*'update ts.contrato_plano_dependencia cp set cp.dt_ini_vigencia = to_date(''' || lpad(extract(day from c.inicio_de_vigencia), 2, '0') || 
			 '/03/2023'', ''dd/mm/yyyy''), cp.dt_ini_validade = to_date(''' || lpad(extract(day from c.inicio_de_vigencia), 2, '0') || 
			 '/03/2023'', ''dd/mm/yyyy'')where cp.cod_ts_contrato = ' || ce.cod_ts_contrato || ';'*/
			  
			 /*'update ts.beneficiario b set b.data_inclusao = to_date(''' || lpad(extract(day from c.inicio_de_vigencia), 2, '0') || 
			 '/03/2023'', ''dd/mm/yyyy'') where b.cod_ts = ' || b.cod_ts || ';'*/
from pm_contrato c
     join ts.entidade_sistema es on es.num_cgc = c.cnpj_cpf_subcontrato
		 join ts.contrato_empresa ce on ce.cod_titular_contrato = es.cod_entidade_ts
		 --join ts.beneficiario b on b.cod_ts_contrato = ce.cod_ts_contrato
where exists (select 1
              from ts.contrato_cobranca cc
							where cc.cod_ts_contrato = ce.cod_ts_contrato
							      and cc.dt_ini_cobranca >= to_date('01/02/2023', 'dd/mm/yyyy'))
/*and not exists (select 1
                from ts.cobranca co
								where co.cod_ts = b.cod_ts_tit
								      and co.dt_cancelamento is null
											and co.dt_emissao is not null)*/
