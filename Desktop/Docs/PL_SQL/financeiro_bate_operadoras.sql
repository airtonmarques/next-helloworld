select distinct
       adm.nom_operadora Administradora,
       op.nom_operadora Operadora,
       ce.num_contrato ContratoInterno,
       ce.num_contrato_operadora ContratoOperadora,
       lpad(es.num_cgc, 14, '0') CNPJ,
       es.nome_entidade EmpresaEntidade,
       ce.data_inicio_vigencia VigenciaContrato,
       porte.nome_tipo_empresa Porte,
       filial.nome_sucursal Filial,
       prop.num_proposta_adesao numeroProposta,
       lpad(entCorretora.Num_Cgc, 14, '0') CNPJCorretora,
       entCorretora.Nome_Razao_Social Corretora,
       bc.data_adesao dataAdesaoBeneficiario,
       b.data_exclusao dataExcBeneficiario,
       b.cod_ts_tit codigoFamiliaInterno,
       b.num_associado numAssociado,
       b.num_associado_operadora MO,
       b.tipo_associado tipoAssociado,
       b.nome_associado Nome,
       lpad(be.num_cpf, 14, '0') CPF,
       be.data_nascimento dataNascimento,
       sys_get_idade_fnc(be.data_nascimento, sysdate) idade,
       
       (select LPAD(es2.NUM_CPF, 11, '0')
                     from ts.beneficiario_entidade@prod_allsys es2
                     where es2.cod_entidade_ts = beneficiario.cod_entidade_ts_tit) CPFTitular,

                    (select b2.nome_associado
                     from ts.beneficiario@prod_allsys b2
                     where b2.cod_ts = beneficiario.cod_ts_tit) nomeTitular
                     
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.beneficiario_contrato bc on bc.cod_ts = b.cod_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.regra_empresa porte porte.tipo_empresa = ce.tipo_empresa
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
          and (b.cod_empresa is null OR ec.cod_entidade_ts = b.cod_empresa)
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
     left join ts.ppf_proposta prop on prop.num_seq_proposta_ts = b.num_seq_proposta_ts
     left join ts.sucursal filial on filial.cod_sucursal = prop.cod_sucursal
     left join ts.corretor_venda corretora on corretora.cod_corretor_ts = prop.cod_produtor_ts
     left join ts.entidade_sistema entCorretora on entCorretora.Cod_Entidade_Ts = corretora.cod_entidade_ts
where op.cod_operadora IN (97)     
order by bc.data_adesao,
         b.cod_ts_tit,
         b.tipo_associado desc
