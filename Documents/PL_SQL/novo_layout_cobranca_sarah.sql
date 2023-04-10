select 'PERNR;LGART;ANZHL;BETRG;ZUORD;BLANK;BLANK;BLANK;BEGDA'
from dual

union all

select '' || lpad(b.num_matric_empresa, 9, '0') || ';' ||
       case when cf.cod_tipo_ciclo IN (1)
				 then '4200' else '4208' end  || ';' ||
			 lpad(' ', 7, ' ') || ';' ||
			 lpad(replace(replace(to_char(c.val_a_pagar, '99999.99'), '.', ','), ' ', ''), 13, '0')  || ';' ||
			 lpad(regexp_replace(LPAD(be.num_cpf, 11, '0'),'([0-9]{3})([0-9]{3})([0-9]{3})','\1.\2.\3-'), 20, ' ')  || ';' ||
			 ';' || ';' || ';' ||
			 to_char(add_months(c.dt_competencia, -1), 'DD.MM.YYYY')
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
		 join ts.cobranca c on c.cod_ts = b.cod_ts
		 join ts.ciclo_faturamento cf on cf.num_ciclo_ts = c.num_ciclo_ts
		 /*join ts.itens_cobranca ic on ic.cod_ts = b.cod_ts
		                           and ic.num_seq_cobranca = c.num_seq_cobranca*/
where ce.num_contrato IN ('02260', '02071', '01888', '04775', '01741', '02299', '01744', 
                          '05070', '05155', '05066', '05520', '02529', '03918', '01743', '45620', '45657')		 
and c.dt_competencia = to_date('01/04/2023', 'dd/mm/yyyy')	

    and b.tipo_associado = 'T'
		and b.num_matric_empresa is not null
		and cf.cod_tipo_ciclo NOT IN (1) --COPART
		--and cf.cod_tipo_ciclo IN (1) --NAO COPART
		--and b.cod_ts = 16366
    --and b.num_matric_empresa like '%6576%'
		and exists (select 1
                from ts.beneficiario_faturamento bf
								where bf.cod_ts = b.cod_ts_tit
								      and bf.cod_tipo_cobranca = 1) --tipo cobran�a debito 
order by 1
