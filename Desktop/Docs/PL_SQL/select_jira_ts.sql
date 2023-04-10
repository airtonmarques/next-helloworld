select l.AUTHOR,--18416 => AULUS, l.AUTHOR,18700 => Douglas, 19101 => Carl Machadoos
       l.RELATED_DAY Dia,
       l.WEEK_DAY Dia_Semana,
       to_char(l.START_1, 'hh24:mi:ss') Entrada,
       to_char(l.EXIT_2, 'hh24:mi:ss') Saida/*,
       l.WORKED_TIME Tempo_Trabalhado*/
from jira_worklog_view l
where lower(l.AUTHOR) like '%19101%'
      and l.RELATED_DAY between to_date('16/02/2023', 'dd/mm/yyyy') and to_date('13/03/2023', 'dd/mm/yyyy')
order by 2
--Aulus Pinheiro
