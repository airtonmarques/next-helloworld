select 
       distinct
       filial.nom_razao_social administradora,
       corretor.cod_corretor cod_corretora,
       es.nome_entidade corretora,
       lpad(es.num_cgc, 14, '0') cnpj,
       insp.cod_inspetoria cod_filial_fiscal,
       insp.nome_inspetoria filial_fiscal,
       filial.nome_sucursal filial,
       ec.dt_ini_periodo inicio_apuracao,
       ec.dt_corte fim_apuracao,
       ec.num_pgto_comissao numero_extrato,
       ec.num_nota_fiscal,
       ec.val_pgto val_apurado,
       ec.dt_recebimento data_previsto,
       ec.dt_pgto data_pagamento,
       ce.num_contrato contrato,
       ce.num_contrato_operadora contrato_operadora,
       empresa.nome_entidade entidade_ou_empresa,
       porte.nome_tipo_empresa porte,
       op.nom_operadora operadora,
       ce.data_inicio_vigencia data_inicio_vigencia,
       f.num_fatura fatura,
       case when iv.num_seq_proposta_ts is not null
         then (select p.num_proposta_adesao from ts.ppf_proposta p where p.num_seq_proposta_ts = iv.num_seq_proposta_ts) 
       else (select pj.num_proposta from ts.pj_proposta pj where pj.num_seq_proposta_pj_ts = ce.num_seq_proposta_pj_ts) end proposta,
       case when iv.cod_ts is not null
         then (select b.nome_associado from ts.beneficiario b where b.cod_ts = iv.cod_ts) end nome,
       case when iv.cod_ts is not null
         then (select b.num_associado_operadora from ts.beneficiario b where b.cod_ts = iv.cod_ts) end marca_otica,
       case when iv.cod_ts is not null
         then (select lpad(be.num_cpf, 11, '0')
               from ts.beneficiario_entidade be
               where be.cod_entidade_ts = (select b.cod_entidade_ts_tit 
                                           from ts.beneficiario b 
                                           where b.cod_ts = iv.cod_ts)) end cpf_titular,
       iv.num_mensalidade parcela,
       iv.mes_ano_ref referencia,
       iv.val_base_calc valor_fatura,
       decode(ce.ind_tipo_produto, 1, 'Médico', 2, 'Dental', ' - ') produto,
       iv.numero_vidas_contrato vidas,
       f.dt_vencimento vencimento,
       iv.dt_baixa_pgto data_operacao,
       fv.nom_funcao funcao_venda,
       rub.nom_rubrica_comissao rubrica,
       iv.pct_parcela percentual,
       iv.val_base_calc base_calculo,
       iv.val_item_pgto comissao,
       ec.ind_tipo_pessoa,
       tprod.nome_tipo_produtor tipo_produtor
from EXTRATO_COMISSAO ec
     join ts.cms_item_venda iv on iv.num_extrato_produtor = ec.num_pgto_comissao
                               and iv.cod_corretor_ts = ec.cod_corretor_ts
     join ts.corretor_venda corretor on corretor.cod_corretor_ts = ec.cod_corretor_ts  
     join ts.tipo_produtor_vendas tprod on tprod.cod_tipo_produtor = corretor.cod_tipo_produtor                             
     join ts.entidade_sistema es on es.cod_entidade_ts = corretor.cod_entidade_ts
     join ts.sucursal filial on filial.cod_sucursal = ec.cod_sucursal
     join ts.inspetoria insp on insp.cod_inspetoria_ts = ec.cod_inspetoria_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = iv.cod_ts_contrato
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
     join ts.entidade_sistema empresa on empresa.cod_entidade_ts = ec.cod_entidade_ts
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.fatura f on f.num_seq_fatura_ts = iv.num_seq_fatura_ts
     --join ts.ppf_proposta p on p.num_seq_proposta_ts = iv.num_seq_proposta_ts
     --join ts.beneficiario b on b.cod_ts = iv.cod_ts
     join ts.funcao_venda fv on fv.cod_funcao = iv.cod_funcao
     join ts.cms_tipo_rubrica rub on rub.cod_rubrica_comissao = iv.cod_rubrica_comissao
where /*ec.cod_corretor_ts IN (73656)
      and ec.num_pgto_comissao IN (77)
      and*/ ec.dt_ini_periodo between to_date('01/03/2021', 'dd/mm/yyyy') and last_day('01/03/2022')
      and ce.cod_operadora_contrato IN (2, 67)
order by 1, 2, 3, 8
