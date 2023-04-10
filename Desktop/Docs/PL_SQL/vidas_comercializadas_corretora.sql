select a.cod_corretora,
       a.corretora,
       a.filial,
			 --a.porte,
			 --a.vigencia,
       sum(a.ativos) ativos,
			 sum(a.excluidos_suspensos) excluidos_suspensos,
			 count(1) vidas_total,
			 CONCAT(TO_CHAR((100/nullif(count(1)/nullif(sum(a.excluidos_suspensos), 0), 0)), '99999999.99'), '%') percentual_excluidos,
--			 (100/(count(1)/sum(a.excluidos_suspensos))) percentual_excluidos1,
			 sum(a.valor) valor
from
(select distinct cv.cod_corretor cod_corretora,
       es.nome_entidade corretora,
			 s.nome_sucursal filial,
			 --porte.nome_tipo_empresa porte,
			 b.data_inclusao vigencia,
			 case when b.ind_situacao = 'A' then 1 else 0 end as ativos,
			 case when b.ind_situacao NOT IN ('A') then 1 else 0 end as excluidos_suspensos,
			 (select sys_get_vlr_cont_fe_fnc(2, b.cod_ts_contrato, b.cod_plano, b.tipo_associado, 
			             SYS_GET_IDADE_FNC(be.data_nascimento, b.data_inclusao), b.data_inclusao) from dual) valor
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.ppf_proposta p on p.num_seq_proposta_ts = b.num_seq_proposta_ts
		 join ts.corretor_venda cv on cv.cod_corretor_ts = p.cod_produtor_ts
		 join ts.entidade_sistema es on es.cod_entidade_ts = cv.cod_entidade_ts
		 join ts.sucursal s on s.cod_sucursal = cv.cod_sucursal
		 --join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
		 --join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
where b.data_inclusao between to_date('01/01/2022', 'dd/mm/yyyy') and last_day('01/06/2022')
			--and es.nome_entidade like '%PLANSCOOP%'
			--and (b.data_exclusao is null or b.data_exclusao > sysdate)

union all

select distinct cv.cod_corretor cod_corretora,
       es.nome_entidade corretora,
			 s.nome_sucursal filial,
			 --porte.nome_tipo_empresa porte,
       b.data_inclusao vigencia,
			 case when b.ind_situacao = 'A' then 1 else 0 end as ativos,
			 case when b.ind_situacao NOT IN ('A') then 1 else 0 end as excluidos_suspensos,
       (select sys_get_vlr_cont_fe_fnc(2, b.cod_ts_contrato, b.cod_plano, b.tipo_associado, 
                   SYS_GET_IDADE_FNC(be.data_nascimento, b.data_inclusao), b.data_inclusao) from dual) valor
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
		 join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.pj_proposta pj on pj.num_seq_proposta_pj_ts = ce.num_seq_proposta_pj_ts
     join ts.corretor_venda cv on cv.cod_corretor_ts = pj.cod_produtor_ts
     join ts.entidade_sistema es on es.cod_entidade_ts = cv.cod_entidade_ts
		 join ts.sucursal s on s.cod_sucursal = cv.cod_sucursal
		 --join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
		 --join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
where b.data_inclusao between to_date('01/01/2022', 'dd/mm/yyyy') and last_day('01/06/2022'))
      --and es.nome_entidade like '%PLANSCOOP%')
			--and (b.data_exclusao is null or b.data_exclusao > sysdate))
 a
group by a.cod_corretora,
       a.corretora,
			 a.filial/*,
			 a.porte,
			 a.vigencia*/
order by 2, 3, 7 
