create or replace procedure ALL_DISCAD_FULL_PCD is

  iCount               number;
  iCountTel            number;
  num_seq_proposta_ts  number;
  num_ddd_telefone_1   varchar2(4);
  num_telefone_1       varchar2(15);
  num_ddd_telefone_2   varchar2(4);
  num_telefone_2       varchar2(15);
  num_ddd_telefone_3   varchar2(4);
  num_telefone_3       varchar2(15);
  ddd_celular_1        varchar2(4);
  num_celular_1        varchar2(15);
  ddd_celular_2        varchar2(4);
  num_celular_2        varchar2(15);
  ddd_celular_3        varchar2(4);
  num_celular_3        varchar2(15);
  num_proposta_adesao  varchar2(50);
  nome_associado       varchar2(120);
  nom_operadora        varchar2(50);
  txt_situacao         varchar2(100);
  nome_sucursal        varchar2(100);
  dt_inicio_vigencia   date;

  cursor cBeneficiarios is
    select distinct p.num_seq_proposta_ts,
       b.num_ddd_telefone_1,
       b.num_telefone_1,
       b.num_ddd_telefone_2,
       b.num_telefone_2,
       b.num_ddd_telefone_3,
       b.num_telefone_3,
       b.ddd_celular_1,
       b.num_celular_1,
       b.ddd_celular_2,
       b.num_celular_2,
       b.ddd_celular_3,
       b.num_celular_3,
       p.num_proposta_adesao,
       (select b2.nome_associado
        from ts.MC_ASSOCIADO_MOV b2
             join ts.ppf_proposta p2 on p2.num_seq_proposta_ts = b2.num_seq_proposta_ts
        where p2.num_seq_proposta_ts = p.num_seq_proposta_ts
              and b2.tipo_associado = 'T') as nome_associado,
       op.nom_operadora,
       sit.txt_situacao,
       suc.nome_sucursal,
       p.dt_inicio_vigencia
from ts.MC_ASSOCIADO_MOV b
     join ts.ppf_proposta p on p.num_seq_proposta_ts = b.num_seq_proposta_ts
     join ts.ppf_operadoras op on op.cod_operadora = p.cod_operadora_contrato
     join ts.ppf_situacao_proposta sit on sit.cod_situacao_proposta = p.cod_situacao_proposta
     join ts.sucursal suc on suc.cod_sucursal = p.cod_sucursal
where
      -- Valida��es B�sicas
      p.cod_situacao_proposta in (7)
      and b.cod_situacao_analise IN (1, 11)
      --and b.tipo_associado IN ('T', 'P')
      and p.dt_inicio_vigencia >= to_date('01/06/2021', 'dd/mm/yyyy')
      and b.peso is not null
      and b.altura is not null
      -- F I M Valida��es B�sicas

      -- Valida��o AMIL
      and ((op.cod_operadora = 1 and
           (p.qtd_beneficiarios < 2 or

           exists (select 1
                   from ts.ass_declaracao_saude ds
                   where ds.Num_Seq_Associado_Mov = b.Num_Seq_Associado_Mov
                         and ds.ind_resposta = 'S')

           or (sys_get_idade_fnc(b.data_nascimento, sysdate) >= 59)
           or (SYS_GET_IMC_FNC(b.peso, b.altura) > 35))
          )
      -- F I M Valida��o Amil

      -- Valida��o CNU
      OR (op.cod_operadora = 2 and
           (p.qtd_beneficiarios < 2 or

           exists (select 1
                   from ts.ass_declaracao_saude ds
                   where ds.Num_Seq_Associado_Mov = b.Num_Seq_Associado_Mov
                         and ds.ind_resposta = 'S')

           or (sys_get_idade_fnc(b.data_nascimento, sysdate) >= 59)
           or (SYS_GET_IMC_FNC(b.peso, b.altura) > 35))
          )
      -- F I M Valida��o CNU

      -- Valida��o S1
      OR (op.cod_operadora = 232 and
           (p.qtd_beneficiarios < 2 or

           exists (select 1
                   from ts.ass_declaracao_saude ds
                   where ds.Num_Seq_Associado_Mov = b.Num_Seq_Associado_Mov
                         and ds.ind_resposta = 'S')

           or (sys_get_idade_fnc(b.data_nascimento, sysdate) >= 59)
           or (SYS_GET_IMC_FNC(b.peso, b.altura) > 35))
          )
      -- F I M Valida��o S1

      -- Valida��o S�o Crist�v�o
      OR (op.cod_operadora = 8 and
           (p.qtd_beneficiarios < 2 or

           exists (select 1
                   from ts.ass_declaracao_saude ds
                   where ds.Num_Seq_Associado_Mov = b.Num_Seq_Associado_Mov
                         and ds.ind_resposta = 'S')

           or (sys_get_idade_fnc(b.data_nascimento, sysdate) >= 59)
           or (SYS_GET_IMC_FNC(b.peso, b.altura) > 35))
          )
      -- F I M Valida��o S�o Crist�v�o

      -- Valida��o Unimed Campina Grande
      OR (op.cod_operadora = 238 and
           (p.qtd_beneficiarios < 2 or

           exists (select 1
                   from ts.ass_declaracao_saude ds
                   where ds.Num_Seq_Associado_Mov = b.Num_Seq_Associado_Mov
                         and ds.ind_resposta = 'S')

           or (sys_get_idade_fnc(b.data_nascimento, sysdate) >= 59)
           or (SYS_GET_IMC_FNC(b.peso, b.altura) > 35))
          )
      -- F I M Valida��o unimed Campina Grande

      -- Valida��o Unimed Imperatriz
      OR (op.cod_operadora = 231 and

           (p.qtd_beneficiarios < 2 or
           exists (select 1
                   from ts.ass_declaracao_saude ds
                   where ds.Num_Seq_Associado_Mov = b.Num_Seq_Associado_Mov
                         and ds.ind_resposta = 'S')

           or (sys_get_idade_fnc(b.data_nascimento, sysdate) >= 59)
           or (SYS_GET_IMC_FNC(b.peso, b.altura) > 35))
          )
      -- F I M Valida��o Unimed Imperatriz

      -- Valida��o GNDI
      OR (op.cod_operadora = 3 and

           (exists (select 1
                   from ts.ass_declaracao_saude ds
                   where ds.Num_Seq_Associado_Mov = b.Num_Seq_Associado_Mov
                         and ds.ind_resposta = 'S')

           or (SYS_GET_IMC_FNC(b.peso, b.altura) > 29.9))
          )
      -- F I M Valida��o GNDI

      -- Valida��o ASSIM
      OR (op.cod_operadora = 20 and

           (exists (select 1
                   from ts.ass_declaracao_saude ds
                   where ds.Num_Seq_Associado_Mov = b.Num_Seq_Associado_Mov
                         and ds.ind_resposta = 'S')

           or (SYS_GET_IMC_FNC(b.peso, b.altura) > 35))
          )
      -- F I M Valida��o ASSIM

      -- Valida��o Next
      OR (op.cod_operadora = 4 and

           (exists (select 1
                   from ts.ass_declaracao_saude ds
                   where ds.Num_Seq_Associado_Mov = b.Num_Seq_Associado_Mov
                         and ds.ind_resposta = 'S')

           or (SYS_GET_IMC_FNC(b.peso, b.altura) > 35))
          )
      -- F I M Valida��o Next

      -- Valida��o SAMP ES
      OR (op.cod_operadora = 17 and

           (exists (select 1
                   from ts.ass_declaracao_saude ds
                   where ds.Num_Seq_Associado_Mov = b.Num_Seq_Associado_Mov
                         and ds.ind_resposta = 'S')

           or (SYS_GET_IMC_FNC(b.peso, b.altura) > 35))
          )
      -- F I M Valida��o SAMP

      -- Valida��o UNIHOSP SAUDE
      OR (op.cod_operadora = 233 and

           (exists (select 1
                   from ts.ass_declaracao_saude ds
                   where ds.Num_Seq_Associado_Mov = b.Num_Seq_Associado_Mov
                         and ds.ind_resposta = 'S')

           or (SYS_GET_IMC_FNC(b.peso, b.altura) > 35))
          )
      -- F I M Valida��o UNIHOSP SAUDE

      -- Valida��o Unimed BH
      OR (op.cod_operadora = 63 and

           (exists (select 1
                   from ts.ass_declaracao_saude ds
                   where ds.Num_Seq_Associado_Mov = b.Num_Seq_Associado_Mov
                         and ds.ind_resposta = 'S')

           or (SYS_GET_IMC_FNC(b.peso, b.altura) > 35))
          )
      -- F I M Valida��o Unimed BH

      -- Valida��o Unimed Natal
      OR (op.cod_operadora = 134 and

           (exists (select 1
                   from ts.ass_declaracao_saude ds
                   where ds.Num_Seq_Associado_Mov = b.Num_Seq_Associado_Mov
                         and ds.ind_resposta = 'S')

           or (SYS_GET_IMC_FNC(b.peso, b.altura) > 35))
          )
      -- F I M Valida��o Unimed Natal

      -- Valida��o Unimed Rio
      OR (op.cod_operadora = 12 and

           (exists (select 1
                   from ts.ass_declaracao_saude ds
                   where ds.Num_Seq_Associado_Mov = b.Num_Seq_Associado_Mov
                         and ds.ind_resposta = 'S')

           or (SYS_GET_IMC_FNC(b.peso, b.altura) > 35))
          )
      -- F I M Valida��o Unimed Rio

      -- Valida��o Unimed Uberl�ndia
      OR (op.cod_operadora = 236 and

           (exists (select 1
                   from ts.ass_declaracao_saude ds
                   where ds.Num_Seq_Associado_Mov = b.Num_Seq_Associado_Mov
                         and ds.ind_resposta = 'S')

           or (SYS_GET_IMC_FNC(b.peso, b.altura) > 35))
          )
      -- F I M Valida��o Unimed Uberl�ndia

      -- Valida��o Vitallis Sa�de S.A.
      OR (op.cod_operadora = 11 and

           (exists (select 1
                   from ts.ass_declaracao_saude ds
                   where ds.Num_Seq_Associado_Mov = b.Num_Seq_Associado_Mov
                         and ds.ind_resposta = 'S')

           or (SYS_GET_IMC_FNC(b.peso, b.altura) > 35))
          )
      -- F I M Valida��o Vitallis Sa�de S.A.

      -- Outras Operadoras sem crit�rios (Bradesco, Integral, Klini, Slam, Unimed Recife)
      OR op.cod_operadora IN (14, 239, 245, 32, 97)
      )
order by 1;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

begin

    --Deleta todos os registros da tabela utilizada para criar em tempo real os benefici�rios do discador
      delete from ALL_DISCAD_FULL;

    --Contador que contabiliza o index de cada linha;
    iCount := 0;


  open cBeneficiarios;
  loop
    fetch cBeneficiarios
      into num_seq_proposta_ts,
           num_ddd_telefone_1,
           num_telefone_1,
           num_ddd_telefone_2,
           num_telefone_2,
           num_ddd_telefone_3,
           num_telefone_3,
           ddd_celular_1,
           num_celular_1,
           ddd_celular_2,
           num_celular_2,
           ddd_celular_3,
           num_celular_3,
           num_proposta_adesao,
           nome_associado,
           nom_operadora,
           txt_situacao,
           nome_sucursal,
           dt_inicio_vigencia;
    exit when cBeneficiarios%NOTFOUND;

    iCountTel := 0;

    -- Telefone 1
    if num_ddd_telefone_1 is not null then
      iCountTel := iCountTel + 1;
      iCount := iCount + 1;

      insert into ALL_DISCAD_FULL(id,
                   count_tels,
                   num_seq_proposta_ts,
                   tipo_tel,
                   num_ddd_telefone,
                   num_telefone,
                   num_proposta_adesao,
                   nome_associado,
                   nom_operadora,
                   txt_situacao,
                   nome_sucursal,
                   dt_inicio_vigencia,
                   dth_insert)
      values(iCount,
             iCountTel,
             num_seq_proposta_ts,
             'T',
             num_ddd_telefone_1,
             num_telefone_1,
             num_proposta_adesao,
             nome_associado,
             nom_operadora,
             txt_situacao,
             nome_sucursal,
             dt_inicio_vigencia,
             sysdate);

    end if;

    --Telefone 2
    if num_ddd_telefone_2 is not null then
      iCountTel := iCountTel + 1;
      iCount := iCount + 1;

      insert into ALL_DISCAD_FULL(id,
                   count_tels,
                   num_seq_proposta_ts,
                   tipo_tel,
                   num_ddd_telefone,
                   num_telefone,
                   num_proposta_adesao,
                   nome_associado,
                   nom_operadora,
                   txt_situacao,
                   nome_sucursal,
                   dt_inicio_vigencia,
                   dth_insert)
      values(iCount,
             iCountTel,
             num_seq_proposta_ts,
             'T',
             num_ddd_telefone_2,
             num_telefone_2,
             num_proposta_adesao,
             nome_associado,
             nom_operadora,
             txt_situacao,
             nome_sucursal,
             dt_inicio_vigencia,
             sysdate);

    end if;


    --Telefone 3
    if num_ddd_telefone_3 is not null then
      iCountTel := iCountTel + 1;
      iCount := iCount + 1;

      insert into ALL_DISCAD_FULL(id,
                   count_tels,
                   num_seq_proposta_ts,
                   tipo_tel,
                   num_ddd_telefone,
                   num_telefone,
                   num_proposta_adesao,
                   nome_associado,
                   nom_operadora,
                   txt_situacao,
                   nome_sucursal,
                   dt_inicio_vigencia,
                   dth_insert)
      values(iCount,
             iCountTel,
             num_seq_proposta_ts,
             'T',
             num_ddd_telefone_3,
             num_telefone_3,
             num_proposta_adesao,
             nome_associado,
             nom_operadora,
             txt_situacao,
             nome_sucursal,
             dt_inicio_vigencia,
             sysdate);

    end if;

    --Celular 1
    if ddd_celular_1 is not null then
      iCountTel := iCountTel + 1;
      iCount := iCount + 1;

      insert into ALL_DISCAD_FULL(id,
                   count_tels,
                   num_seq_proposta_ts,
                   tipo_tel,
                   num_ddd_telefone,
                   num_telefone,
                   num_proposta_adesao,
                   nome_associado,
                   nom_operadora,
                   txt_situacao,
                   nome_sucursal,
                   dt_inicio_vigencia,
                   dth_insert)
      values(iCount,
             iCountTel,
             num_seq_proposta_ts,
             'C',
             ddd_celular_1,
             num_celular_1,
             num_proposta_adesao,
             nome_associado,
             nom_operadora,
             txt_situacao,
             nome_sucursal,
             dt_inicio_vigencia,
             sysdate);

    end if;

    --Celular 2
    if ddd_celular_2 is not null then
      iCountTel := iCountTel + 1;
      iCount := iCount + 1;

      insert into ALL_DISCAD_FULL(id,
                   count_tels,
                   num_seq_proposta_ts,
                   tipo_tel,
                   num_ddd_telefone,
                   num_telefone,
                   num_proposta_adesao,
                   nome_associado,
                   nom_operadora,
                   txt_situacao,
                   nome_sucursal,
                   dt_inicio_vigencia,
                   dth_insert)
      values(iCount,
             iCountTel,
             num_seq_proposta_ts,
             'C',
             ddd_celular_2,
             num_celular_2,
             num_proposta_adesao,
             nome_associado,
             nom_operadora,
             txt_situacao,
             nome_sucursal,
             dt_inicio_vigencia,
             sysdate);

    end if;


    --Celular 3
    if ddd_celular_3 is not null then
      iCountTel := iCountTel + 1;
      iCount := iCount + 1;

      insert into ALL_DISCAD_FULL(id,
                   count_tels,
                   num_seq_proposta_ts,
                   tipo_tel,
                   num_ddd_telefone,
                   num_telefone,
                   num_proposta_adesao,
                   nome_associado,
                   nom_operadora,
                   txt_situacao,
                   nome_sucursal,
                   dt_inicio_vigencia,
                   dth_insert)
      values(iCount,
             iCountTel,
             num_seq_proposta_ts,
             'C',
             ddd_celular_3,
             num_celular_3,
             num_proposta_adesao,
             nome_associado,
             nom_operadora,
             txt_situacao,
             nome_sucursal,
             dt_inicio_vigencia,
             sysdate);

    end if;

    commit;

  end loop;
  close cBeneficiarios;

  commit;

  exception
    when others then
      rollback;
end;
