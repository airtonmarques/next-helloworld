select lower((substr(bc.end_email, instr (bc.end_email,'@',1)+1 ))) email,
       count(1) qtd
from ts.beneficiario_contato bc
     join ts.beneficiario b on b.cod_entidade_ts = bc.cod_entidade_ts
		 join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
where bc.end_email is not null
      and b.data_exclusao is null
      and b.tipo_associado IN ('T', 'P')
			and ce.tipo_empresa IN (1, 12)
group by lower((substr(bc.end_email, instr (bc.end_email,'@',1)+1 )))
order by 2 desc

---------------------------------------
---------------------------------------

select distinct 
       substr(b.nome_associado, 1, instr(b.nome_associado, ' ') - 1) Nome,
			 b.nome_associado,
       lower(bc.end_email)--, bc.*
from ts.beneficiario_contato bc
     join ts.beneficiario b on b.cod_entidade_ts = bc.cod_entidade_ts
		 join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
where bc.end_email is not null
      and b.data_exclusao is null 
      and b.tipo_associado IN ('T', 'P')
			and ce.tipo_empresa IN (1, 12)
      --and b.nome_associado = 'ABADIA HELENA RESENDE RODRIGUES'
      /*and bc.num_seq_contato = (select max(bc1.num_seq_contato)
                                from ts.beneficiario_contato bc1
                                where bc1.cod_entidade_ts = bc.cod_entidade_ts)*/
order by 1      

