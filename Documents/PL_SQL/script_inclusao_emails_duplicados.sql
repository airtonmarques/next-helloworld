declare
 vOcorrencia PLS_INTEGER := 1;
    vPosicao PLS_INTEGER := 0;
    vPosicaoAnt PLS_INTEGER := 1;
		
		CURSOR emails IS  select e.cod_entidade_ts,
														 e.end_email
											from ts.enderecos e
											where instr(e.end_email, ';') > 0;
		
		r_emails emails%ROWTYPE;

begin

OPEN emails;	
LOOP
    FETCH  emails  INTO r_emails;
    EXIT WHEN emails%NOTFOUND;

   LOOP
        vPosicao := INSTR(r_emails.end_email , ';' , 1 , vOcorrencia );
				EXIT WHEN nvl(vPosicao,0) = 0;
        --
        insert into all_enderecos_duplicados(cod_ts_entidade, email) values(r_emails.cod_entidade_ts, TRIM(SUBSTR(r_emails.end_email , vPosicaoAnt , vPosicao - vPosicaoAnt )));
				commit; 
				--
        vPosicaoAnt := vPosicao + LENGTH(';') ;
        vOcorrencia := vOcorrencia + 1;
        --
								
    END LOOP;
		
		insert into all_enderecos_duplicados(cod_ts_entidade, email) values(r_emails.cod_entidade_ts, TRIM(SUBSTR(r_emails.end_email, vPosicaoAnt , length(r_emails.end_email) - vPosicaoAnt + 1 )));
		commit; 
		
		vOcorrencia := 1;
    vPosicao := 0;
    vPosicaoAnt := 1;
		
	end loop;
	
CLOSE emails;

end;

