declare p_ind_erro_out varchar2(4000) default ''; 
        p_msg_retorno_out varchar2(4000) default ''; 
        v_ind_erro_out varchar2(4000) default ''; 
        v_msg_retorno_out varchar2(4000) default ''; 
begin 

sur_altera_dtvencimento(15996830, '30/05/2022', 0, 0, 1, 'Prorrogação de Boletos', 'ACFARANIO', 'S', v_ind_erro_out, v_msg_retorno_out, 'N', 'N', 'N');
end;
