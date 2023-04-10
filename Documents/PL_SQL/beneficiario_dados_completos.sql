select distinct 
       b.nome_associado,
       lpad(be.num_cpf, 11, '0') CPF,
       pm.nome_plano,
       pm.cod_registro_ans,
       decode(pm.ind_participacao, 'S', 'Sim', 'Não') Copart,
       p.num_proposta_adesao,
       b.ind_situacao,
       nvl(decode(bc.ind_tipo_carencia, 1, 'Sujeito a Carência', 9, 'Isento de Carência'), '-') Carencia,
       bc.cod_grupo_carencia,
       porte.nome_tipo_empresa,
       bc.data_adesao,
       b.num_associado_operadora,
       opp.nom_operadora Operadora,
       es.nome_entidade,
       nvl(dep.nome_dependencia, 'Titular') Dependencia,
       be.data_nascimento,
       sys_get_idade_fnc(be.data_nascimento, sysdate) idade,
       bcontato.num_ddd, 
       bcontato.num_telefone,
       bcontato.end_email,
       bend.num_cep,
       bend.nom_logradouro,
       bend.num_endereco,
       bend.txt_complemento,
       cidade.nom_municipio,
       cidade.sgl_uf
from ts.beneficiario b
     join ts.beneficiario_contrato bc on bc.cod_ts = b.cod_ts
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.ppf_operadoras opp on opp.cod_operadora = ce.cod_operadora_contrato
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
     join ts.sucursal filial on filial.cod_sucursal = ce.cod_sucursal
     left join ts.beneficiario_contato bcontato on bcontato.cod_entidade_ts = be.cod_entidade_ts
     left join ts.beneficiario_endereco bend on bend.cod_entidade_ts = be.cod_entidade_ts
     left join ts.municipio cidade on cidade.cod_municipio = bend.cod_municipio
     left join ts.ppf_proposta p on p.num_seq_proposta_ts = b.num_seq_proposta_ts
     left join ts.tipo_dependencia dep on dep.cod_dependencia = b.cod_dependencia    
where b.num_associado = 137715455
