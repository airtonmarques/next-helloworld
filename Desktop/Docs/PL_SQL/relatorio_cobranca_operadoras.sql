select op.nom_operadora Operadora,
       ce.num_contrato_operadora,
       b.cod_ts_tit,
       b.tipo_associado,
       b.num_associado_operadora MO,
       (select ad1.num_associado_operadora 
               from ts.associado_aditivo ad1
                    join ts.aditivo a on a.cod_aditivo = ad1.cod_aditivo 
               where ad1.cod_ts = b.cod_ts
                     and a.cod_tipo_rubrica IN (50)
                     and ad1.dt_ini_vigencia = (select max(ad2.dt_ini_vigencia)
                                                from ts.associado_aditivo ad2
                                                where ad2.cod_ts = ad1.cod_ts
                                                      and ad2.cod_aditivo = ad1.cod_aditivo)
                     and rownum = 1) mo_dental,
       es.nome_entidade Entidade,
       ce.data_inicio_vigencia,
       ce.data_fim_vigencia,
       b.data_inclusao,
       bc.data_adesao,
       b.data_exclusao,
       prop.num_proposta proposta_pj,
       propAd.Num_Proposta_Adesao,
       b.nome_associado,
       lpad(be.num_cpf, 9) cpf,
       be.data_nascimento,
       trunc(months_between(sysdate,be.data_nascimento)/12) idade,
       s.nome_sucursal filial_corretora_proposta_pj,
       sAd.Nome_Sucursal filial_corretora_proposta_ad,
       (select lpad(be1.num_cpf, 9) from ts.beneficiario_entidade be1 where be1.cod_entidade_ts = b.cod_entidade_ts_tit) cpf_titular,
       (select b1.nome_associado from ts.beneficiario b1 where b1.cod_ts = b.cod_ts_tit) nome_titular,
       (select ad1.num_associado_operadora 
               from ts.associado_aditivo ad1
                    join ts.aditivo a on a.cod_aditivo = ad1.cod_aditivo 
               where ad1.cod_ts = b.cod_ts_tit
                     and a.cod_tipo_rubrica IN (50)
                     and ad1.dt_ini_vigencia = (select max(ad2.dt_ini_vigencia)
                                                from ts.associado_aditivo ad2
                                                where ad2.cod_ts = ad1.cod_ts
                                                      and ad2.cod_aditivo = ad1.cod_aditivo)
                     and rownum = 1) mo_dental_titular
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.beneficiario_contrato bc on bc.cod_ts = b.cod_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
                              		 and (b.cod_empresa is null OR ec.cod_entidade_ts = b.cod_empresa)
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     left join ts.pj_proposta prop on prop.num_seq_proposta_pj_ts = ce.num_seq_proposta_pj_ts
     left join ts.corretor_venda cv on cv.cod_corretor_ts = prop.cod_produtor_ts
     left join ts.sucursal s on s.cod_sucursal = cv.cod_sucursal
     left join ts.ppf_proposta propAd on propAd.num_seq_proposta_ts = b.num_seq_proposta_ts
     left join ts.corretor_venda cvAd on cvAd.cod_corretor_ts = propAd.cod_produtor_ts
     left join ts.sucursal sAd on sAd.cod_sucursal = cvAd.cod_sucursal
where ce.cod_operadora_contrato in (246)--(63, 239)   
order by 1, 2, 3, 4 desc    
     
