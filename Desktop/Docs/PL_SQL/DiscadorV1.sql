set echo off
set heading off
set pagesize 50000
set linesize 32767
set trims on

spool 'N:\\\\Shares\\\\EXTRACOES-JOBS\\\\Analise_Tecnica\\\\Discador\\\\ArquivoDiscadorDiario.rsl'

select a.txt
from
(select distinct d.id,
       'record_id=' || d.id || 
       '|contact_info=' || case when d.num_ddd_telefone = 11 
                                     then '911' || d.num_telefone 
                                       else '911012' || d.num_ddd_telefone || d.num_telefone
                                     end ||
       '|contact_info_type=' || d.tipo_tel ||
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
       '|chain_id=' || d.num_proposta_adesao ||
       '|chain_n=' || d.count_tels ||
       '|group_id=' ||
       '|app_id=' ||
       '|treatments=' ||
       '|media_ref=' ||
       '|email_subject=' ||
       '|email_template_id=' ||
       '|switch_id=' ||
       '|NUM_CPF_1=' || d.num_proposta_adesao ||
       '|NOME_ASSOCIADO_1=' || d.nome_associado ||
       '|NUM_ASSOCIADO_1=' ||
       '|WF_1=' ||
       '|TXT_DESCRICAO_1=' || d.nom_operadora ||
       '|NOM_SITUACAO_1=' || d.txt_situacao ||
       '|AREA_DESTINO_1=Análise Técnica' ||
       '|W_STR1_1=' || d.nome_sucursal ||
       '|W_STR2_1=' || d.dt_inicio_vigencia ||
       '|W_STR3_1=' as txt
from ALL_DISCAD_FULL d
order by 1) a;

   	 
 spool off
 spool out

quit      
