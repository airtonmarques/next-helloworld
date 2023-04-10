--Verificar Locks em Geral 

SELECT se.inst_id, 

       lk.SID, 

       se.username, 

       TO_SINGLE_BYTE (se.OSUSER)                              AS OSUSER, 

       TO_SINGLE_BYTE (se.MACHINE)                             AS MACHINE, 

       DECODE (lk.TYPE, 

               'TX', 'Transaction', 

               'TM', 'DML', 

               'UL', 'PL/SQL User Lock', 

               lk.TYPE)                                        lock_type, 

       DECODE (lk.lmode, 

               0, 'None', 

               1, 'Null', 

               2, 'Row-S (SS)', 

               3, 'Row-X (SX)', 

               4, 'Share', 

               5, 'S/Row-X (SSX)', 

               6, 'Exclusive', 

               TO_CHAR (lk.lmode))                             mode_held, 

       DECODE (lk.request, 

               0, 'None', 

               1, 'Null', 

               2, 'Row-S (SS)', 

               3, 'Row-X (SX)', 

               4, 'Share', 

               5, 'S/Row-X (SSX)', 

               6, 'Exclusive', 

               TO_CHAR (lk.request))                           mode_requested, 

       TO_CHAR (lk.id1)                                        lock_id1, 

       TO_CHAR (lk.id2)                                        lock_id2, 

       ob.owner, 

       ob.object_type, 

       ob.object_name, 

       DECODE (lk.Block,  0, 'No',  1, 'Yes',  2, 'Global')    block, 

       se.lockwait 

  FROM GV$lock  lk 

       JOIN gv$session se ON (lk.inst_id = se.inst_id AND lk.SID = se.SID) 

       LEFT JOIN dba_objects ob ON (ob.object_id = lk.id1) 

-- WHERE lk.TYPE IN ('TX', 'TM', 'UL') 

WHERE     (lk.TYPE) IN (SELECT TYPE 

                           FROM gv$lock 

                          WHERE TYPE IN ('TX', 'TM', 'UL')) 

--       AND lk.SID IN (SELECT session_id 

--                        FROM dba_ddl_locks dd 

--                       WHERE dd.name IN ('ALT_CAD', 

--                                         'ALT_PROD', 

--                                         'ALT_PROD_TAB', 

--                                         'ALT_PROD_VIG'))
