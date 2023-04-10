select p.num_seq_proposta_ts,
       
       'record_id=' || row_number() over (order by p.num_seq_proposta_ts) || 
       '|contact_info=' || case when b.num_ddd_telefone_1 = 11 
                                     then '911' || b.num_telefone_1 
                                       else '911012' || b.num_ddd_telefone_1 || b.num_telefone_1
                                     end ||
       '|contact_info_type=' || --decode(b.num_celular_1, 'C', 'Mobile', 'T', 'Phone') ||
       '|record_type=General' ||
       '|record_status=Ready' ||
       '|call_result=Unknown Call Result' ||
       '|attempt=0' ||
       '|dial_sched_time=' ||
       '|call_time=' ||
       '|daily_from=08:00:00' ||
       '|daily_till=19:00:00' ||
       '|tz_dbid=BET' ||
       '|campaign_id=' ||
       '|agent_id=' ||
       '|chain_id=' || p.num_proposta_adesao ||
       '|chain_n=' || --ROW_NUMBER() OVER (PARTITION BY p.num_proposta_adesao ORDER BY bc.num_seq_contato) ||
       '|group_id=' ||
       '|app_id=' ||
       '|treatments=' ||
       '|media_ref=' ||
       '|email_subject=' ||
       '|email_template_id=' ||
       '|switch_id=' ||
       '|NUM_CPF_1=' || p.num_proposta_adesao ||
       '|NOME_ASSOCIADO_1=' || b.nome_associado ||
       '|NUM_ASSOCIADO_1=' ||
       '|WF_1=' ||
       '|TXT_DESCRICAO_1=' || op.nom_operadora ||
       '|NOM_SITUACAO_1=' || sit.txt_situacao ||
       '|AREA_DESTINO_1=An�lise T�cnica' ||
       '|W_STR1_1=' || suc.nome_sucursal ||
       '|W_STR2_1=' || p.dt_inicio_vigencia ||
       '|W_STR3_1='
       
from ts.MC_ASSOCIADO_MOV b
     join ts.ppf_proposta p on p.num_seq_proposta_ts = b.num_seq_proposta_ts
     join ts.ppf_operadoras op on op.cod_operadora = p.cod_operadora_contrato
     join ts.ppf_situacao_proposta sit on sit.cod_situacao_proposta = p.cod_situacao_proposta
     join ts.sucursal suc on suc.cod_sucursal = p.cod_sucursal
where 
      -- Valida��es B�sicas
      p.cod_situacao_proposta in (7)
      and b.cod_situacao_analise IN (1, 11)
      and b.tipo_associado IN ('T', 'P')
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
order by 1      
      
