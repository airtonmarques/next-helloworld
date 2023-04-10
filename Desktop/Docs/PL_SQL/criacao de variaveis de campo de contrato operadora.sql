
select   distinct
       'insert into ts.contrato_campos_operadora(cod_operadora, cod_ts_contrato, cod_campo, val_campo, dt_atu, cod_usuario, num_seq_cont_camp) values(' ||
       ce.cod_operadora_contrato || ', ' || ce.cod_ts_contrato || ', ''NOME_MIGRACAO'', ''PROJETO MORUMBI'', sysdate, ''RAFAQUESI'', ass_cont_campos_operadora_seq.nextval);'
     
from ts.contrato_empresa ce 
     join ts.entidade_sistema es on es.cod_entidade_ts = ce.cod_titular_contrato
		 join ts.pm_contrato c on c.cnpj_cpf_subcontrato = es.num_cgc
where exists (select 1
                  from ts.contrato_campos_operadora co
									where co.cod_ts_contrato = ce.cod_ts_contrato
									      and co.cod_operadora = ce.cod_operadora_contrato
												and co.cod_campo = 'NOME_MIGRACAO')
      and c.operadora like '%BRADESCO ADES%'
			and ce.data_inicio_vigencia >= to_date('01/03/2023', 'dd/mm/yyyy')
												
--IND_MIGRADO S
--NOME_MIGRACAO PROJETO MORUMBI
