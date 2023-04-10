select a.* from
(
select 'Operadora;Filial;Filial_Corretora;Data_Vigencia;Numero_Proposta;Situacao_Proposta;Data_Situacao_Analise;Situacao_Analise;Usuario_Analise;Nome_Beneficiario;Tipo_Beneficiario;Data_Nascimento_Beneficiario;Porte;Obs_Analise'
from dual

union all

select op.nom_operadora || ';' ||
       f.nome_sucursal || ';' ||
			 (select s.nome_sucursal
         from ts.sucursal s,
              ts.corretor_venda sup
        where sup.cod_corretor_ts = p.cod_produtor_ts 
          and s.cod_sucursal = sup.cod_sucursal) || ';' ||
			 p.dt_inicio_vigencia || ';' ||
			 p.num_proposta || ';' ||
			 sp.txt_situacao || ';' ||
			 a.dt_situacao_analise || ';' ||
			 sit.txt_descricao || ';' ||
			 a.cod_usuario_analise || ';' ||
			 aa.nome_associado || ';' ||
     decode(aa.tipo_associado,'T','Titular','D','Dependente','N') || ';' || 
     to_date(aa.data_nascimento,'dd/mm/yyyy') || ';' ||
		 porte.nome_tipo_empresa || ';' ||
		 '"' || a.txt_obs_analise || '"'
from ts.MC_ANALISE_TECNICA_HIST a
     join ts.mc_associado_mov aa on aa.num_seq_associado_mov = a.num_seq_associado_mov
		 join ts.cmc_situacao_analise_tecnica sit on sit.cod_situacao_analise = a.cod_situacao_analise
		 join ts.pj_proposta p on p.num_seq_proposta_pj_ts = aa.num_seq_proposta_pj_ts
		 join ts.ppf_operadoras op on op.cod_operadora = p.cod_operadora_contrato
		 join ts.sucursal f on f.cod_sucursal = p.cod_sucursal
		 join ts.pj_situacao_proposta sp on sp.cod_situacao_proposta_pj = p.cod_situacao_proposta_pj
		 left join ts.regra_empresa porte on porte.tipo_empresa = p.tipo_empresa
where aa.tipo_associado = 'T'
      and p.dt_inicio_vigencia >= to_date('01/01/2022', 'dd/mm/yyyy')

union all

select op.nom_operadora || ';' ||
       f.nome_sucursal || ';' ||
       (select s.nome_sucursal
         from ts.sucursal s,
              ts.corretor_venda sup
        where sup.cod_corretor_ts = p.cod_produtor_ts 
          and s.cod_sucursal = sup.cod_sucursal) || ';' ||
       p.dt_inicio_vigencia || ';' ||
       p.num_proposta || ';' ||
       sp.txt_situacao || ';' ||
       aa.dt_situacao_analise || ';' ||
       sit.txt_descricao || ';' ||
       aa.cod_usuario_analise || ';' ||
       aa.nome_associado || ';' ||
     decode(aa.tipo_associado,'T','Titular','D','Dependente','N') || ';' || 
     to_date(aa.data_nascimento,'dd/mm/yyyy') || ';' ||
		 porte.nome_tipo_empresa || ';' ||  
    '"' || aa.txt_obs_analise || '"'
from  ts.mc_associado_mov aa 
     join ts.cmc_situacao_analise_tecnica sit on sit.cod_situacao_analise = aa.cod_situacao_analise
     join ts.pj_proposta p on p.num_seq_proposta_pj_ts = aa.num_seq_proposta_pj_ts
     join ts.ppf_operadoras op on op.cod_operadora = p.cod_operadora_contrato
     join ts.sucursal f on f.cod_sucursal = p.cod_sucursal
     join ts.pj_situacao_proposta sp on sp.cod_situacao_proposta_pj = p.cod_situacao_proposta_pj
		 left join ts.regra_empresa porte on porte.tipo_empresa = p.tipo_empresa
where aa.tipo_associado = 'T'			
			and p.dt_inicio_vigencia >= to_date('01/01/2022', 'dd/mm/yyyy')
)	a
