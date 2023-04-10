select distinct 
       b.cod_ts_tit Familia,
       b.tipo_associado,
       b.num_associado,
       (select be1.nome_entidade from ts.beneficiario_entidade be1 where be1.cod_entidade_ts = b.cod_entidade_ts_tit) Responsavel, 
       lpad(be.num_cpf, 11, '0') cpf,
       b.nome_associado,
       be.data_nascimento,
       be.ind_sexo sexo,
       b.data_inclusao,
       b.data_exclusao,
       aa.dt_ini_vigencia,
       aa.dt_fim_vigencia,
       ce.num_contrato,
       es.nome_razao_social Contrato
      
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
                              and (b.cod_empresa is null OR ec.cod_entidade_ts = b.cod_empresa)
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.associado_aditivo aa on aa.cod_ts = b.cod_ts
where aa.cod_aditivo IN (35)
      and (b.data_exclusao is null OR b.data_exclusao > last_day('01/09/2022'))
order by 1, 2 desc      
