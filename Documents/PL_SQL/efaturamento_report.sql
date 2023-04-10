select
  x.num_associado,
  x.nome,
  x.telefone1,
  x.telefone2,
  x.telefone3,
  x.operadora,
  x.porte,
  x.dia_vencimento,
  x.email,
  x.dt_ultimo_envio
from(  
  select distinct
      be.num_associado,
      be.nome_associado nome,
      telefone."1" telefone1,
      telefone."2" telefone2,
      telefone."3" telefone3,
      oper.nom_operadora operadora,
      re.nome_tipo_empresa porte,
      bf.dia_vencimento,
      email."1"  email,
      (select MAX(dt_fato) 
       from ts.ocorrencia_associado
       where cod_ocorrencia = 190
         and cod_ts = be.cod_ts
       ) as dt_ultimo_envio,
      bf.dt_ini_efaturamento 
  from ts.beneficiario be
  join ts.beneficiario_faturamento bf on bf.cod_ts = be.cod_ts
  left join ts.contrato_empresa ce on ce.cod_ts_contrato = be.cod_ts_contrato
  left join ts.regra_empresa re on re.tipo_empresa = ce.tipo_empresa
  left join ts.ppf_operadoras oper on oper.cod_operadora = ce.cod_operadora_contrato
  left join (
      select
        *
      from (
        select distinct
          contato.cod_entidade_ts,
          row_number() over(partition by contato.cod_entidade_ts order by contato.cod_entidade_ts) indice,
          '('|| num_ddd ||') '|| num_telefone as telefone
        from ts.beneficiario_contato contato
        where num_telefone is not null
      )
        pivot
      (
        max(telefone)
        for indice in (1,2,3)
      )
      order by 1 asc
  ) telefone on telefone.cod_entidade_ts = be.cod_entidade_ts
  left join (
      select
        *
      from (
        select distinct
          contato.cod_entidade_ts,
          row_number() over(partition by contato.cod_entidade_ts order by contato.cod_entidade_ts) indice,
          end_email as email
        from ts.beneficiario_contato contato
        where contato.ind_email_efaturamento = 'S'
      )
        pivot
      (
        max(email)
        for indice in (1,2)
      )
      order by 1 asc
  ) email on email.cod_entidade_ts = be.cod_entidade_ts
  where be.ind_situacao = 'A'
    and be.data_exclusao is null
    and bf.cod_tipo_cobranca = 2
    and bf.ind_efaturamento = 'S'

  union 

  select distinct
      null as num_associado,
      ec.nom_empresa_cartao nome,
      telefone."1" telefone1,
      telefone."2" telefone2,
      telefone."3" telefone3,
      oper.nom_operadora operadora,
      re.nome_tipo_empresa porte,
      nvl(venc.dia_vencimento, ce.dia_pagamento) dia_vencimento,
      email."1" as "e-mail",
      (select MAX(dt_fato) 
       from ts.ocorrencia_contrato
       where cod_ocorrencia = 190
         and cod_ts_contrato = ce.cod_ts_contrato
       ) as dt_ultimo_envio,
      ce.dt_ini_efaturamento   
  from ts.contrato_empresa ce
  join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
  left join ts.regra_empresa re on re.tipo_empresa = ce.tipo_empresa
  left join ts.ppf_operadoras oper on oper.cod_operadora = ce.cod_operadora_contrato
  left join ts.contrato_vencimentos venc on venc.cod_ts_contrato = ce.cod_ts_contrato and venc.ind_tipo_dia_vencimento = 'B'
  left join (
      select
        *
      from (
        select distinct
          contato.cod_ts_contrato,
          row_number() over(partition by contato.cod_ts_contrato order by contato.num_seq_contato) indice,
          '('|| num_ddd ||') '|| num_telefone as telefone
        from ts.contrato_contato contato
        where num_telefone is not null
      )
        pivot
      (
        max(telefone)
        for indice in (1,2,3)
      )
      order by 1 asc
  ) telefone on telefone.cod_ts_contrato = ce.cod_ts_contrato
  left join (
      select
        *
      from (
        select distinct
          contato.cod_ts_contrato,
          row_number() over(partition by contato.cod_ts_contrato order by contato.num_seq_contato) indice,
          contato.txt_email_contato as email
        from ts.contrato_contato contato
        where contato.txt_email_contato is not null
      )
        pivot
      (
        max(email)
        for indice in (1,2)
      )
      order by 1 asc
  ) email on email.cod_ts_contrato = ce.cod_ts_contrato
  where ce.ind_efaturamento = 'S'
    and ce.ind_situacao = 'A' 
)x    
