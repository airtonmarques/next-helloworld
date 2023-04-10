--Codigo operadora e 
--nome contrato, 
--nome beneficiário / 
--código matricula/ 
--código cartão (sem ponto e traço) / 
--CPF / 
--CID

select op.nom_operadora Operadora,
       ce.num_contrato Num_Contrato,
       ce.num_contrato_operadora Num_contrato_operadora,
       es.nome_entidade Contrato,
       b.cod_ts_tit Familia,
       b.tipo_associado Dependencia,
       b.nome_associado Beneficiario,
       b.num_matric_empresa Matricula,
       b.num_associado_operadora MO,
       be.num_cpf CPF,
       ds.cods_cid CIDs,
       ds.txt_descricao Descricao    
from ASS_DECLARACAO_SAUDE ds
     join ts.beneficiario b on b.cod_ts = ds.cod_ts
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
where ds.cods_cid is not null
      and b.data_inclusao = to_date('01/05/2021', 'dd/mm/yyyy')
      and op.cod_operadora = 2
order by 1, 2, 5, 6 desc
