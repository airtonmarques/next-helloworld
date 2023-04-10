select  
  distinct 
       '1' || --1 fixo
       lpad(op.num_cnpj, 14, '0') || --14 cnpj operadora
       lpad(op.nom_operadora, 100, ' ') || --100 Nome Operadora
       to_char(f.mes_ano_ref, 'mmyyyy') || --6 Competência
       (select lpad(b1.num_matric_empresa, 9, '0') 
        from ts.beneficiario b1 
        where b1.cod_ts = a.cod_ts_tit) || --9 Matricula
       (select lpad(be1.num_cpf, 11, '0') 
        from ts.beneficiario b2 
             join ts.beneficiario_entidade be1 on be1.cod_entidade_ts = b2.cod_entidade_ts
        where b2.cod_ts = a.cod_ts_tit) || --11 CPF Titular
       lpad(be.num_cpf, 11, '0') || --11 CPF Beneficiário

       case a.cod_dependencia 
           when 2 then '1'--Conjugue
           when 3 then '2'--Filho
       else '0' end  ||--1 Tipo dependente 

       to_char(a.data_adesao, 'ddmmyyyy') || --8 Data de Adesão
       to_char(f.dt_vencimento, 'ddmmyyyy') || --8 Data de Vencimento
       to_char(c.dt_baixa, 'ddmmyyyy') || --8 Data de Pagamento
       '9' ||--1 Fixo codigo plano de saúde
       lpad(replace(c.val_pago, ',', ''), 13, '0') || --13 Valor Pago
       nvl(to_char(a.data_exclusao, 'ddmmyyyy'), lpad(' ', 8, ' ')) || --8 Data de Cancelamento do Plano
       lpad(' ', 55, ' ') || --55 em branco
       'F', --1 fim do arquivo
      (select c1.val_pago frselect *
from ts.lancamento_manual lm
where lm.num_item_cobranca_ts is null
      and lm.cod_tipo_rubrica >= 250
      and lm.cod_ts IN (select b.cod_ts
                        from ts.beneficiario b
                             join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
                             join ts.beneficiario b1 on trim(b1.nome_associado) = trim(b.nome_associado)
                                                     and b1.data_inclusao >= to_date('01/10/2021', 'dd/mm/yyyy')
                        where ce.Cod_Operadora_Contrato = 73);om ts.cobranca c1 where c1.cod_ts = a.cod_ts)
from ts.associado a
join ts.contrato_empresa ce on ce.cod_ts_contrato = a.cod_ts_contrato
join ts.entidade_sistema es on es.cod_entidade_ts = ce.cod_titular_contrato
join ts.beneficiario_entidade be on be.cod_entidade_ts = a.cod_entidade_ts
join ts.cobranca c on c.cod_ts = a.cod_ts_tit
join ts.fatura f on f.num_seq_fatura_ts = c.num_seq_fatura_ts
join ts.itens_cobranca itens on itens.num_seq_cobranca = c.num_seq_cobranca and itens.Cod_Ts = a.cod_ts
join TS.PLANO_MEDICO pm on pm.cod_plano = a.cod_plano
join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
left join ts.tipo_dependencia dep on dep.cod_dependencia = a.cod_dependencia
left join ts.aditivo ad on ad.cod_aditivo = itens.cod_aditivo
left join ts.motivo_exclusao_assoc exc on exc.cod_motivo_exc_assoc = a.cod_motivo_exclusao
where c.dt_cancelamento is null
  and c.dt_emissao is not null
  and c.dt_baixa BETWEEN to_date('18/08/2021', 'dd/mm/yyyy') AND  to_date('18/09/2021', 'dd/mm/yyyy')  
  and (ce.num_contrato = 24397) 
  and itens.cod_tipo_rubrica not in (16, 100) --Exclui os itens de mensalidade
  and (a.tipo_associado = 'T' OR a.cod_dependencia NOT IN (3, 21, 20, 35, 29) OR
      (sys_get_idade_fnc(be.data_nascimento, last_day(c.dt_baixa))) < 24 and a.cod_dependencia IN (3, 21, 20, 35, 29)) --Dependentes apenas menores de 24 anos
--order by 2, 9 desc
