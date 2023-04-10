select i2.matricula_titular || '|' || i2.nome_titular || '|' ||
       lpad(i2.cpf_titular, 11) || '|' || i2.nome_dep || '|' ||
       i2.cpf_dep || '|' || i2.mes || '|' || i2.ano || '|' || i2.valor || '|' ||
       i2.cod_administradora || '|' || decode(i2.pensionista, 'S', 'S', 'P', '')
from (select i.*  
from alt_infraero i
where --i.matricula_titular = '0506742'--'1361051'
      /*i.ano = '2022' and i.mes = '06'
			and*/ i.lote = '010420231100'
			--and i.matricula_titular = '1361051'
			
union 			

select  i.* 
from alt_infraero i
where --i.matricula_titular = '0506742'--'1361051'
      /*i.ano = '2022' and i.mes = '06'
      and*/ 
			i.pensionista = 'P'
			--and i.lote = '010220231100'
      --and i.matricula_titular = '1361051'

) i2

order by i2.matricula_titular, i2.ano, i2.mes, i2.ordem, i2.nome_dep desc
