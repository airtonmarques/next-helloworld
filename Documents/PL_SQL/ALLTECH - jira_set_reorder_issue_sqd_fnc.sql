create or replace function                     jira_set_reorder_issue_sqd_fnc(IssueId  number,
                                                      SquadNumber number,
                                                      AcaoMove number,
                                                      PosicaoEspecifica number,
                                                      Setor varchar2
                                                      )
  return varchar is

  --AcaoMove
  -- 1-Mover para cima
  -- 2-Mover para baixo
  -- 3-Priorizar para o topo
  -- 4-Priorizar como último
  -- 5-Posição específica
  
  /***********************************************************************************
  *Function: JIRA_SET_REORDER_ISSUE_SQD_FNC                                          *
  *Objetivo: Gerar a reordenaçao esquad e setor                                      *
  *Autor:   Gleice Esclapes                                                          *
  *Data:    10/06/2022                                                               *
  *Alt:     ALT-10269                                                                *
  ***********************************************************************************/
  
  iCodSetor number;
  
Begin
 
  --GLEICE ALT-10269
  select distinct cfo.customfield
    into iCodSetor
    from customfieldvalue@jira_homolog cfv, customfieldoption@jira_homolog cfo
   where cfo.customvalue = Trim(Setor) 
     and cfv.issue = IssueId
     and cfv.parentkey is null
     and cfo.customfield = cfv.customfield
     and cfo.id = cfv.stringvalue
     and cfv.customfield = 12501;
    
  
  return jira_set_reorder_issue_sqd_fnc@jira_homolog(IssueId, SquadNumber, AcaoMove, PosicaoEspecifica, iCodSetor);
end;