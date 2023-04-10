select 
       'fat_cancela_fatura(p_num_seq_fatura_ts => ' || f.num_seq_fatura_ts || ', ' ||
       'p_txt_motivo_cancelamento => ''Reajuste 09.20 desfeito devido determinação ANS'', ' ||
       'p_cod_usuario => ''VCGAMAS'', ' ||
       'p_ind_erro_out => p_ind_erro_out, ' ||
       'p_msg_retorno_out => p_msg_retorno_out, ' ||
       'p_commit => ''S'', ' ||
       'p_versao => ''N'', ' ||
       'p_ind_trata_inadimplencia => ''N'', ' ||
       'p_ind_desfaz_faturamento => ''S''); '
from ts.fatura f
where f.num_fatura IN
()

-----------------------------------
declare p_ind_erro_out varchar2(4000) default ''; 
p_msg_retorno_out varchar2(4000) default ''; 
begin 

end;
