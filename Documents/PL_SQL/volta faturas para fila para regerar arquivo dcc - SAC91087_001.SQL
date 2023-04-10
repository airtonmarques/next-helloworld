SET ECHO         ON
SET DEFINE       OFF
SET VERIFY       OFF
SET SERVEROUTPUT ON
SET FEEDBACK     OFF

---
---PROMPT
---PROMPT  *************************************************************************
---PROMPT  *** SCRIPT : SAC91087_001.SQL
---PROMPT  *************************************************************************
---PROMPT
---PROMPT |---> SVN: $Revision: 35187 $
---PROMPT
---
declare
  v_num_seq_controle_cob number(10);
begin
  --
  select cc.num_seq_controle_cob 
    into v_num_seq_controle_cob
    from controle_cobranca cc 
   where cc.nom_arq_gerado = '001_969.TXT';
  --
  update cobranca cob
     set cob.ind_estado_cobranca = '0'
   where cob.num_seq_cobranca in (select num_seq_cobranca
                                    from controle_cobranca_reg
                                   where num_seq_controle_cob = v_num_seq_controle_cob);
  --
  update controle_cobranca_reg ccr
     set ccr.cod_situacao_reg_arq_cob = 5
   where ccr.num_seq_controle_cob = v_num_seq_controle_cob;
  --
  update controle_cobranca cc
     set cc.cod_situacao_arq_cob = 4
   where cc.num_seq_controle_cob = v_num_seq_controle_cob;
  -- 
  commit;
  --
  dbms_output.put_line('Script executado com sucesso!!!');
  --
exception
  when others then
    rollback;
    dbms_output.put_line('ERRO: ' || sqlerrm);
end;
/
