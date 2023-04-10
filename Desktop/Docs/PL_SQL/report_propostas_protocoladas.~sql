select porte.nome_tipo_empresa porte,
       p.dt_inicio_vigencia vigencia,
			 es.nome_entidade entidade,
			 p.num_proposta_adesao proposta,
			 ass.tipo_associado tipo,
       p.nome_titular nome_titular,
			 --p.nu
			 ass.num_cpf cpf,
			 to_date(ass.data_nascimento, 'dd/mm/yyyy') nascimento,
			 ass.nome_associado,
			 sit.txt_situacao
from  ts.ppf_proposta p
      join ts.regra_empresa porte on porte.tipo_empresa = p.tipo_empresa
			join ts.mc_associado_mov ass on ass.num_seq_proposta_ts = p.num_seq_proposta_ts
			join ts.ppf_situacao_proposta sit on sit.cod_situacao_proposta = p.cod_situacao_proposta
			join ts.entidade_sistema es on es.cod_entidade_ts = p.cod_ent_contrato_adesao_ts
			--join ts.CMS_CONTRATO_ADESAO cca on cca.num_seq_proposta_ts = p.num_seq_proposta_ts
where 1 = 1
      --and p.num_proposta_adesao IN ('23280005658')
      and p.cod_operadora_contrato IN (232)
      and p.cod_situacao_proposta IN (1, 6, 7, 13, 17, 24)
			and p.dt_vigencia_proposta >= to_date('15/04/2023', 'dd/mm/yyyy')
			--and p.num_proposta_adesao like '%23280005608%'

union all
			
select porte.nome_tipo_empresa porte,
       p.dt_inicio_vigencia vigencia,
       nom_razao_social entidade,
       p.num_proposta proposta,
       ass.tipo_associado tipo,
       (select assT.Nome_Associado from ts.mc_associado_mov assT where assT.Num_Seq_Proposta_Pj_Ts = ass.num_seq_proposta_pj_ts and assT.Tipo_Associado = 'T' and rownum = 1) nome_titular,
       ass.num_cpf cpf,
       to_date(ass.data_nascimento, 'dd/mm/yyyy') nascimento,
       ass.nome_associado,
       sit.txt_situacao
from  ts.pj_proposta p
      join ts.regra_empresa porte on porte.tipo_empresa = p.tipo_empresa
      join ts.mc_associado_mov ass on ass.num_seq_proposta_pj_ts = p.num_seq_proposta_pj_ts
      join ts.pj_situacao_proposta sit on sit.cod_situacao_proposta_pj = p.cod_situacao_proposta_pj
      --join ts.entidade_sistema es on es.cod_entidade_ts = p.cod_ent_contrato_adesao_ts
      --join ts.CMS_CONTRATO_ADESAO cca on cca.num_seq_proposta_ts = p.num_seq_proposta_ts
where 1 = 1
      --and p.num_proposta_adesao IN ('23280005658')
      and p.cod_operadora_contrato IN (232)
      and p.cod_situacao_proposta_pj IN (1, 6, 7, 4, 17, 24)
      and p.dt_inicio_vigencia >= to_date('15/04/2023', 'dd/mm/yyyy')


order by 1, 2, 3, 4, 5 desc
