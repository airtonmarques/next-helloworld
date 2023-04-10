select distinct
       adm.nom_operadora administradora,
       porte.nome_tipo_empresa porte,
       op.nom_operadora operadora,
       es.nome_entidade entidade,
       ce.num_contrato,
       b.nome_associado titular,
       bc.end_email email,
       lpad(be.num_cpf, 11, '0') cpf,
       b.cod_ts 
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.entidade_sistema es on es.cod_entidade_ts = ce.cod_titular_contrato
     join ts.beneficiario_contato bc on bc.cod_entidade_ts = b.cod_entidade_ts
		                                    and bc.end_email is not null
where b.ind_situacao IN ('A', 'S')
      and b.tipo_associado = 'T'
      --and REGEXP_LIKE(bc.end_email, '^[0-9]')

