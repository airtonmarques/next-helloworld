select *
from JIRA_WORKLOG_VIEW j
where j.AUTHOR like 'gleice%'
      and j.RELATED_DAY between to_date('29/11/2021', 'dd/mm/yyyy') 
                                and to_date('14/12/2021', 'dd/mm/yyyy')
order by 2
--'alan.santos'
--'narjara.paes'
--'luciano.targino'
--'renan.claro'
--'gleice.esclapes'
