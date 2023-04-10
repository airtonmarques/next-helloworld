

select distinct 
       opp.nom_operadora Operadora,
       b.cod_ts_tit, 
			 (select lpad(be1.num_cpf, 11, '0') from ts.beneficiario_entidade be1 where be1.cod_entidade_ts = b.cod_entidade_ts_tit) CPF_Titular,
			 (select b1.nome_associado from ts.beneficiario b1 where b1.cod_ts = b.cod_ts_tit) Nome_Titular,
       ce.num_contrato,
       b.num_associado,
       p.num_proposta_adesao,
       b.num_proposta num_proposta_beneficiario,
       b.data_inclusao,
       b.data_exclusao,
       b.num_associado_operadora,
       lpad(be.num_cpf, 11, '0') CPF,
       b.nome_associado,
       b.tipo_associado,
       pm.cod_plano,
       pm.nome_plano,
       b.data_suspensao,
       b.data_fim_suspensao,
       ce.num_contrato_operadora Numero_entidade,
       es.nome_entidade Entidade,
       filial.nome_sucursal Filial,
       porte.nome_tipo_empresa Porte,
       esCorretora.Num_Cgc CNPJ,
       esCorretora.Nome_Entidade Corretora,
       (select 'SIM' from ts.acao_jud_pgto acao where acao.cod_ts = b.cod_ts and acao.cod_acao_ts = (select max(cod_acao_ts) from ts.acao_jud_pgto where cod_ts = b.cod_ts)) acao_judicial,
       (select oa.num_associado_ant 
        from ts.ocorrencia_associado oa 
        where oa.cod_ocorrencia = 166 
              and oa.num_associado_ant is not null
              and oa.cod_ts = b.cod_ts) num_associado_ant,
       (select aa.num_associado_operadora
               from ts.associado_aditivo aa 
                    join ts.aditivo ad on ad.cod_aditivo = aa.cod_aditivo
               where aa.cod_ts = b.cod_ts           
                     and ad.cod_tipo_rubrica = 50
                     and aa.num_associado_operadora is not null
                     and aa.dt_atu = (select max(aa1.dt_atu)
                                               from ts.associado_aditivo aa1
                                               where aa1.cod_ts = aa.cod_ts 
                                                     and aa1.cod_aditivo = aa.cod_aditivo
                                                     and aa1.num_associado_operadora is not null)
                                                     and rownum = 1) MO_Odonto,
       (select aa.dt_ini_vigencia
               from ts.associado_aditivo aa 
                    join ts.aditivo ad on ad.cod_aditivo = aa.cod_aditivo
               where aa.cod_ts = b.cod_ts           
                     and ad.cod_tipo_rubrica = 50
                     and aa.num_associado_operadora is not null
                     and aa.dt_atu = (select max(aa1.dt_atu)
                                               from ts.associado_aditivo aa1
                                               where aa1.cod_ts = aa.cod_ts 
                                                     and aa1.cod_aditivo = aa.cod_aditivo
                                                     and aa1.num_associado_operadora is not null)
                                                     and rownum = 1) Vigencia_Odonto,
       (select aa.dt_fim_vigencia
               from ts.associado_aditivo aa 
                    join ts.aditivo ad on ad.cod_aditivo = aa.cod_aditivo
               where aa.cod_ts = b.cod_ts           
                     and ad.cod_tipo_rubrica = 50
                     and aa.num_associado_operadora is not null
                     and aa.dt_atu = (select max(aa1.dt_atu)
                                               from ts.associado_aditivo aa1
                                               where aa1.cod_ts = aa.cod_ts 
                                                     and aa1.cod_aditivo = aa.cod_aditivo
                                                     and aa1.num_associado_operadora is not null)
                                                     and rownum = 1) Exclusao_Odonto,
       (select ad.nom_aditivo
               from ts.associado_aditivo aa 
                    join ts.aditivo ad on ad.cod_aditivo = aa.cod_aditivo
               where aa.cod_ts = b.cod_ts           
                     and ad.cod_tipo_rubrica = 50
                     and aa.num_associado_operadora is not null
                     and aa.dt_atu = (select max(aa1.dt_atu)
                                               from ts.associado_aditivo aa1
                                               where aa1.cod_ts = aa.cod_ts 
                                                     and aa1.cod_aditivo = aa.cod_aditivo
                                                     and aa1.num_associado_operadora is not null)
                                                     and rownum = 1) Plano_Odonto
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.ppf_operadoras opp on opp.cod_operadora = ce.cod_operadora_contrato
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
     join ts.sucursal filial on filial.cod_sucursal = ce.cod_sucursal
     left join ts.ppf_proposta p on p.num_seq_proposta_ts = b.num_seq_proposta_ts
     left join ts.corretor_venda cv on  cv.cod_corretor_ts = p.cod_produtor_ts
     left join ts.entidade_sistema esCorretora on esCorretora.Cod_Entidade_Ts = cv.cod_entidade_ts

where ce.cod_operadora_contrato IN (246) --4 next
      --and nvl(b.data_exclusao, to_date('31/12/3000', 'DD/MM/YYYY')) > last_day('01/06/2020')
      --and (nvl(b.data_exclusao, to_date('31/12/3000', 'DD/MM/YYYY')) > to_date('dd/mm/yyyy', '01/06/2020') 
      --    OR b.data_inclusao > to_date('dd/mm/yyyy', '01/06/2020'))
      --and b.nome_associado = upper('Samuel Vitor da Silva')
      --and b.num_associado_operadora like '%076385164%'
      --and b.data_exclusao is  null
      --and exists (select 1 from ts.itens_cobranca ic where ic.cod_ts = b.cod_ts 
      --            and ic.mes_ano_ref between to_date('01/06/2020', 'dd/mm/yyyy') and to_date('30/09/2020', 'dd/mm/yyyy'))
order by 1, 2, 14 desc

--select * from ts.ppf_operadoras opp where upper(opp.nom_operadora) like '%RECIFE%'
--7594, 7193 - cod_vendedor_ts
--37775, 40340 cod_produtor_ts
--select * from ts.corretor_venda cv where cv.cod_corretor_ts IN (7594, 7193, 37775, 40340)
--12460613
--select * from ts.ppf_operadoras o
--where upper(o.nom_operadora) like '%SMILE%'
