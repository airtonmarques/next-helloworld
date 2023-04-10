select ff.acao_judicial,
       ff.administradora,
       ff.contrato,
       ff.contrato_operadora,
       ff.cpf,
       ff.data_inclusao,
       ff.data_nascimento,
       ff.dia_vigencia,
       ff.data_adesao,
       ff.data_exclusao,
       ff.entidade,
       ff.fatura,
       ff.filial,
       ff.idade,
       ff.mo_dental,
       ff.mo_medico,
       ff.mes_ano,
       ff.motivo_exclusao,
       ff.nome_beneficiario,
       ff.nome_plano_dental,
       ff.nome_plano_medico,
       ff.numero_beneficiario,
       ff.operadora,
       ff.periodo_cobertura_inicial,
       ff.periodo_cobertura_final,
       ff.porte_contrato,
       ff.situacao_beneficiario,
       ff.situacao_contrato,
       ff.tipo_beneficiario,
       ff.tipo_produto,
       ff.nome_rubrica,
       ff.valor_comercial,
       ff.sexo,
       ff.cnpj_entidade,
       ff.vencimento,
       ff.vencimento_original,
       ff.data_emissao,
       ff.cobranca,
       ff.vidas,
       be.ind_estado_civil estado_civil,
       be.num_identidade,
       
       (select max(c1.dt_baixa)
        from ts.cobranca c1
        where c1.cod_ts = b.cod_ts_tit
              and c1.cod_ts not in (ff.cobranca)) data_ultimo_pagamento,
       
       (select c2.dt_competencia
        from ts.cobranca c2
        where c2.cod_ts = b.cod_ts_tit
              and c2.cod_ts not in (ff.cobranca)
              and c2.dt_baixa = (select max(c1.dt_baixa)
                                 from ts.cobranca c1
                                 where c1.cod_ts = b.cod_ts_tit
                                       and c1.cod_ts not in (ff.cobranca))) data_comp_ultimo_pagamento,
        
       (select count(1)
        from ts.cobranca c3
        where c3.cod_ts IN (b.cod_ts_tit)
              and c3.dt_emissao is not null
              and c3.dt_cancelamento is null
              and c3.dt_baixa is null
              and c3.dt_vencimento < trunc(sysdate)) boletos_atrasados,

       (select '(' || bc.num_ddd || ')' || bc.num_telefone 
        from ts.beneficiario_contato bc
        where bc.cod_entidade_ts = b.cod_entidade_ts_tit
              and bc.ind_tipo_contato in ('R')
              and bc.ind_class_contato in ('C')
              and bc.num_seq_contato = (select max(bc1.num_seq_contato)
                                        from ts.beneficiario_contato bc1
                                        where bc1.cod_entidade_ts = b.cod_entidade_ts_tit
                                              and bc1.ind_tipo_contato in ('R')
                                              and bc1.ind_class_contato in ('C'))) telefone_contato,
       
       (select bc.end_email
        from ts.beneficiario_contato bc
        where bc.cod_entidade_ts = b.cod_entidade_ts_tit
              and bc.ind_tipo_contato is null
              and bc.ind_class_contato in ('E')
              and bc.num_seq_contato = (select max(bc1.num_seq_contato)
                                        from ts.beneficiario_contato bc1
                                        where bc1.cod_entidade_ts = b.cod_entidade_ts_tit
                                              and bc1.ind_tipo_contato is null
                                              and bc1.ind_class_contato in ('E'))) email,
                                              
       cob.qtd_dias_atraso dias_atraso, 
       cob.num_parcela,
       cob.nome_contato_ac,
       bf.nome_resp_reemb nome_responsavel,
       cob.nom_logradouro logradouro,
       cob.num_endereco numero_endereco,
       cob.txt_complemento complemento,
       cob.nome_bairro bairro,
       cob.num_cep cep,
       cob.nome_cidade municipio,
       cob.sgl_uf uf,
       
       (select '(' || bc.num_ddd || ')' || bc.num_telefone 
        from ts.beneficiario_contato bc
        where bc.cod_entidade_ts = b.cod_entidade_ts_tit
              and bc.ind_tipo_contato in ('R')
              and bc.ind_class_contato in ('T')
              and bc.num_seq_contato = (select max(bc1.num_seq_contato)
                                        from ts.beneficiario_contato bc1
                                        where bc1.cod_entidade_ts = b.cod_entidade_ts_tit
                                              and bc1.ind_tipo_contato in ('R')
                                              and bc1.ind_class_contato in ('T'))) telefone_residencial,
                                              
       (select '(' || bc.num_ddd || ')' || bc.num_telefone 
        from ts.beneficiario_contato bc
        where bc.cod_entidade_ts = b.cod_entidade_ts_tit
              and bc.ind_tipo_contato in ('C')
              and bc.num_seq_contato = (select max(bc1.num_seq_contato)
                                        from ts.beneficiario_contato bc1
                                        where bc1.cod_entidade_ts = b.cod_entidade_ts_tit
                                              and bc1.ind_tipo_contato in ('C'))) telefone_comercial,
                                              
        (select '(' || bc.num_ddd || ')' || bc.num_telefone 
        from ts.beneficiario_contato bc
        where bc.cod_entidade_ts = b.cod_entidade_ts_tit
              and bc.ind_tipo_contato in ('B')
              and bc.num_seq_contato = (select max(bc1.num_seq_contato)
                                        from ts.beneficiario_contato bc1
                                        where bc1.cod_entidade_ts = b.cod_entidade_ts_tit
                                              and bc1.ind_tipo_contato in ('B'))) telefone_cobranca,                                                                                            
       
       
       be.ind_nacionalidade nacionalidade,
       cc.nom_cargo profissao
       
       /*(select count(1) + 1
        from ts.cobranca c4
             join ts.ciclo_faturamento cf on cf.num_ciclo_ts = c4.num_ciclo_ts
        where c4.cod_ts IN (b.cod_ts_tit)
              and c4.dt_emissao is not null
              and c4.dt_cancelamento is null 
              and cf.cod_tipo_ciclo = 1 --Mensalidade
              and c4.num_seq_cobranca < ff.cobranca) num_parcela*/
              
            
        
        
              
from fin_fech ff
     join ts.beneficiario b on b.cod_ts = ff.codigo_unico_beneficiario
     join ts.beneficiario_contrato bc on bc.cod_ts = b.cod_ts_tit
     join ts.beneficiario_faturamento bf on bf.cod_ts = b.cod_ts_tit
     join ts.contrato_cargo cc on cc.cod_ts_contrato = b.cod_ts_contrato
                                 and cc.cod_cargo = bc.cod_cargo
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.estado_civil ec on ec.ind_estado_civil = be.ind_estado_civil
     join ts.cobranca cob on cob.num_seq_cobranca = ff.cobranca
     
where ff.mes_ano between to_date('01/09/2021', 'dd/mm/yyyy') and last_day('01/09/2021')
--ff.nome_beneficiario = 'AIRTON MARQUES DA SILVA JUNIOR'     
