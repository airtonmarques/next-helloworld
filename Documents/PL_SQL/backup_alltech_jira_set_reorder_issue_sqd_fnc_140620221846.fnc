create or replace function jira_set_reorder_issue_sqd_fnc(IssueId  number,
                                                      SquadNumber number,
                                                      AcaoMove number,
                                                      PosicaoEspecifica number)
  return varchar is

  --AcaoMove
  -- 1-Mover para cima
  -- 2-Mover para baixo
  -- 3-Priorizar para o topo
  -- 4-Priorizar como último
  -- 5-Posição específica
Begin
  return jira_set_reorder_issue_sqd_fnc@jira(IssueId, SquadNumber, AcaoMove, PosicaoEspecifica);
end;
/
