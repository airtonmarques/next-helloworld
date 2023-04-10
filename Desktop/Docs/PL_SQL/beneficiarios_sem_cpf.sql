select distinct b.cod_ts_tit familia,
       b.num_seq_matric_empresa,
       b.tipo_associado,
			 (select lpad(be1.num_cpf, 11, '0') from ts.beneficiario_entidade be1 where be1.cod_entidade_ts = b.cod_entidade_ts_tit) cpf_titular,
       (select b1.nome_associado from ts.beneficiario b1 where b1.cod_ts = b.cod_ts_tit) nome_titular,
			 be.num_cpf,
			 b.num_associado,
			 b.nome_associado,
			 trunc(months_between(sysdate,be.data_nascimento)/12) idade,
			 b.data_exclusao,
			 c.num_seq_cobranca cobranca,
			 c.dt_competencia,
			 c.dt_baixa
from ts.cobranca c
     join ts.beneficiario b on b.cod_ts_tit = c.cod_ts
		 join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
where c.dt_baixa between to_date('01/01/2022', 'dd/mm/yyyy') and last_day('01/12/2022')
      and c.dt_cancelamento is null
			and c.dt_emissao is not null 
      and (be.num_cpf is null or length(be.num_cpf) < 2 )
			--and b.num_associado = '12018937'
			and exists (select 1
                  from ts.itens_cobranca ic
									where ic.num_seq_cobranca = c.num_seq_cobranca
									      and ic.cod_ts = b.cod_ts)
order by 1, 2, 10
