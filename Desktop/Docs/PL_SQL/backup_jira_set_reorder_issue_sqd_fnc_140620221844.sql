CREATE OR REPLACE FUNCTION jira_set_reorder_issue_sqd_fnc (
    IssueId             NUMBER,
    SquadNumber         NUMBER,
    AcaoMove            NUMBER,
    PosicaoEspecifica   NUMBER)
    RETURN VARCHAR
IS
    --AcaoMove
    -- 1-Mover para cima
    -- 2-Mover para baixo
    -- 3-Priorizar para o topo
    -- 4-Priorizar como último
    -- 5-Posição específica

    iCount          NUMBER;
    sRowid          VARCHAR (30);
    sRowid2         VARCHAR (30);
    iNumberValue    NUMBER;
    iIssueType      NUMBER;
    iSetor          NUMBER;

    iPosicaoAtual   NUMBER;
    iSeqPosicao     NUMBER;

    PRAGMA AUTONOMOUS_TRANSACTION;

    -- Cursor reorder - pega todos abaixo e reordena
    CURSOR cursorReorder IS
          SELECT c.ROWID
            FROM customfieldvalue c, customfieldvalue cs, jiraissue ji
           WHERE     c.customfield = 12500                            -- Ordem
                 AND cs.customfield = 12501                           -- Setor
                 AND cs.stringvalue = iSetor
                 AND cs.issue = c.issue
                 AND CASE
                         WHEN LENGTH (c.numbervalue) < 3
                         THEN
                             TO_NUMBER (
                                 SquadNumber || LPAD (c.numbervalue, 2, '0'))
                         WHEN     LENGTH (c.numbervalue) = 3
                              AND (   c.numbervalue NOT LIKE SquadNumber || '%'
                                   OR c.numbervalue NOT LIKE '9%')
                         THEN
                             TO_NUMBER (SquadNumber ||LPAD (SUBSTR (c.numbervalue, -2), 2, '0'))
                         ELSE
                             c.numbervalue
                     END >=
                     iPosicaoAtual
                 AND NOT c.ROWID = sRowid
                 AND NOT c.numbervalue = 999
                 AND ji.id = c.issue
                 AND ji.issuetype NOT IN (10104)
                 AND JIRA_GET_SQUAD_NUMBER_FNC (ji.id) = SquadNumber
        ORDER BY CASE
                        WHEN LENGTH (c.numbervalue) < 3
                        THEN
                            TO_NUMBER (
                                SquadNumber || LPAD (c.numbervalue, 2, '0'))
                        WHEN     LENGTH (c.numbervalue) = 3
                             AND (   c.numbervalue NOT LIKE SquadNumber || '%'
                                  OR c.numbervalue NOT LIKE '9%')
                        THEN
                            TO_NUMBER (SquadNumber ||LPAD (SUBSTR (c.numbervalue, -2), 2, '0'))
                        ELSE
                            c.numbervalue
                 END;

    -- Cursor acima - pega a demanda acima pra trocar de ordem
    CURSOR cursorAcima IS
          SELECT c.ROWID, c.numbervalue
            FROM customfieldvalue c, customfieldvalue cs, jiraissue ji
           WHERE     c.customfield = 12500                            -- Ordem
                 AND cs.customfield = 12501                           -- Setor
                 AND cs.stringvalue = iSetor
                 AND cs.issue = c.issue
                 AND CASE
                         WHEN LENGTH (c.numbervalue) < 3
                         THEN
                             TO_NUMBER (
                                 SquadNumber || LPAD (c.numbervalue, 2, '0'))
                         WHEN     LENGTH (c.numbervalue) = 3
                              AND (   c.numbervalue NOT LIKE SquadNumber || '%'
                                   OR c.numbervalue NOT LIKE '9%')
                         THEN
                             TO_NUMBER (SquadNumber ||LPAD (SUBSTR (c.numbervalue, -2), 2, '0'))
                         ELSE
                             c.numbervalue
                     END <=
                     iPosicaoAtual
                 AND NOT c.ROWID = sRowid
                 AND NOT c.numbervalue = 999
                 AND ji.id = c.issue
                 AND ji.issuetype NOT IN (10104)
                 AND JIRA_GET_SQUAD_NUMBER_FNC (ji.id) = SquadNumber
        ORDER BY CASE
                        WHEN LENGTH (c.numbervalue) < 3
                        THEN
                            TO_NUMBER (
                                SquadNumber || LPAD (c.numbervalue, 2, '0'))
                        WHEN     LENGTH (c.numbervalue) = 3
                             AND (   c.numbervalue NOT LIKE SquadNumber || '%'
                                  OR c.numbervalue NOT LIKE '9%')
                        THEN
                            TO_NUMBER (SquadNumber ||LPAD (SUBSTR (c.numbervalue, -2), 2, '0'))
                        ELSE
                            c.numbervalue
                 END DESC;

    -- Cursor acima - pega a demanda acima pra trocar de ordem
    CURSOR cursorAbaixo IS
          SELECT c.ROWID, c.numbervalue
            FROM customfieldvalue c, customfieldvalue cs, jiraissue ji
           WHERE     c.customfield = 12500                            -- Ordem
                 AND cs.customfield = 12501                           -- Setor
                 AND cs.stringvalue = iSetor
                 AND cs.issue = c.issue
                 AND CASE
                         WHEN LENGTH (c.numbervalue) < 3
                         THEN
                             TO_NUMBER (
                                 SquadNumber || LPAD (c.numbervalue, 2, '0'))
                         WHEN     LENGTH (c.numbervalue) = 3
                              AND (   c.numbervalue NOT LIKE SquadNumber || '%'
                                   OR c.numbervalue NOT LIKE '9%')
                         THEN
                             TO_NUMBER (SquadNumber ||LPAD (SUBSTR (c.numbervalue, -2), 2, '0'))
                         ELSE
                             c.numbervalue
                     END >=
                     iPosicaoAtual
                 AND NOT c.ROWID = sRowid
                 AND NOT c.numbervalue = 999
                 AND ji.id = c.issue
                 AND ji.issuetype NOT IN (10104)
                 AND JIRA_GET_SQUAD_NUMBER_FNC (ji.id) = SquadNumber
        ORDER BY CASE
                        WHEN LENGTH (c.numbervalue) < 3
                        THEN
                            TO_NUMBER (
                                SquadNumber || LPAD (c.numbervalue, 2, '0'))
                        WHEN     LENGTH (c.numbervalue) = 3
                             AND (   c.numbervalue NOT LIKE SquadNumber || '%'
                                  OR c.numbervalue NOT LIKE '9%')
                        THEN
                            TO_NUMBER (SquadNumber ||LPAD (SUBSTR (c.numbervalue, -2), 2, '0'))
                        ELSE
                            c.numbervalue
                 END;
BEGIN
    -- Verifica entrada
    IF AcaoMove = 5
    THEN
        IF PosicaoEspecifica IS NULL
        THEN
            ROLLBACK;
            RETURN 'Return|False|Error|Defina a posição para mover para um posição específica.';
        END IF;

        IF NOT PosicaoEspecifica BETWEEN 1 AND 999
        THEN
            ROLLBACK;
            RETURN 'Return|False|Error|A posição específica deve ser algo entre 1 e 999.';
        END IF;

        iPosicaoAtual := PosicaoEspecifica;
    END IF;

    -- Verifica se o custom field ordem existe
    SELECT COUNT (1),
           MAX (c.ROWID),
           MAX (c.numbervalue),
           MAX (ji.issuetype)
      INTO iCount,
           sRowId,
           iNumberValue,
           iIssueType
      FROM customfieldvalue c, jiraissue ji
     WHERE c.customfield = 12500 AND c.issue = IssueId AND ji.id = c.issue;

    IF iCount <> 1
    THEN
            ROLLBACK;
        RETURN 'Return|False|Error|Campo de ordenação não encontrado. É necessário ter uma ordenção inicial para alterá-la.';
    END IF;

    IF iIssueType = 10104
    THEN
            ROLLBACK;
        RETURN 'Return|False|Error|Campo de ordenação não pode ser aplicado para Problema.';
    END IF;

    -- Verifica o setor
    SELECT COUNT (1), MAX (c.stringvalue)
      INTO iCount, iSetor
      FROM customfieldvalue c, jiraissue ji
     WHERE c.customfield = 12501 AND c.issue = IssueId AND ji.id = c.issue;

    IF iCount <> 1
    THEN
        RETURN 'Return|False|Error|Campo de setor não encontrado. O setor é necessário estar cadastrado para reordenação das demandas.';
    END IF;

    -- Define ação
    IF AcaoMove = 1
    THEN
        iPosicaoAtual := iNumberValue;

        IF iPosicaoAtual = 1
        THEN
            ROLLBACK;
            RETURN 'Return|False|Error|Esse item já é prioridade 1.';
        END IF;
    ELSIF AcaoMove = 2
    THEN
        iPosicaoAtual := iNumberValue;

        IF iPosicaoAtual = 999
        THEN
            ROLLBACK;
            RETURN 'Return|False|Error|Esse item já é prioridade 999.';
        END IF;
    ELSIF AcaoMove = 3
    THEN
        iPosicaoAtual := TO_NUMBER (SquadNumber || '01');
    ELSIF AcaoMove = 4
    THEN
        iPosicaoAtual := 999;
    ELSIF AcaoMove = 5
    THEN
        iPosicaoAtual := PosicaoEspecifica;
    END IF;

    --DEFINI POSICIONAMENTO POR SQUAD
    IF iPosicaoAtual < 999 AND SquadNumber < 5
    THEN
        IF LENGTH (iPosicaoAtual) < 3
        THEN
            iPosicaoAtual :=
                TO_NUMBER (SquadNumber || LPAD (iPosicaoAtual, 2, '0'));
        END IF;
    END IF;

    -- Coloca o item na posição indicada e ajusta os demais
    IF AcaoMove IN (3, 4, 5)
    THEN
        -- Edita o registro
        UPDATE customfieldvalue c
           SET c.numbervalue = iPosicaoAtual
         WHERE c.ROWID = sRowId;

        --rollback;
        --return 'Return|False|Error|' || sRowid || iPosicaoAtual;

        -- Ajusta registros restantes
        IF iPosicaoAtual <> 999
        THEN
            iSeqPosicao := iPosicaoAtual + 1;
        ELSE
            iSeqPosicao := TO_NUMBER (SquadNumber || '01');
        END IF;

        OPEN cursorReorder;

        LOOP
            FETCH cursorReorder INTO sRowid2;

            EXIT WHEN cursorReorder%NOTFOUND;

            --rotina do looping
            UPDATE customfieldvalue c
               SET c.numbervalue = iSeqPosicao
             WHERE c.ROWID = sRowid2;

            iSeqPosicao := iSeqPosicao + 1;
        END LOOP;
    ELSE
        -- Inverte a posição de 2 itens
        -- Localiza item acima
        IF AcaoMove = 1
        THEN
            OPEN cursorAcima;

            FETCH cursorAcima INTO sRowid2, iSeqPosicao;

            IF cursorAcima%NOTFOUND
            THEN
            ROLLBACK;
                RETURN 'Return|False|Error|Esse item já é prioridade máxima.';
            END IF;
        ELSIF AcaoMove = 2
        THEN
            OPEN cursorAbaixo;

            FETCH cursorAbaixo INTO sRowid2, iSeqPosicao;

            IF cursorAbaixo%NOTFOUND
            THEN
            ROLLBACK;
                RETURN 'Return|False|Error|Esse item já é prioridade mínima.';
            END IF;
        END IF;

        --Edita o encontrado
        UPDATE customfieldvalue c
           SET c.numbervalue = iPosicaoAtual
         WHERE c.ROWID = sRowId2;

        --Edita item
        UPDATE customfieldvalue c
           SET c.numbervalue = iSeqPosicao
         WHERE c.ROWID = sRowId;
    END IF;

    COMMIT;

    RETURN 'Return|True|Msg|' || iSeqPosicao;
END;
/
