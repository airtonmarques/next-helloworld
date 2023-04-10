select 'fat_cancela_fatura(p_num_seq_fatura_ts => ' || f.num_seq_fatura_ts || ', ' ||
                   'p_txt_motivo_cancelamento => ''Correção BUG no AllSys 06/04/2021'', ' ||
                   'p_cod_usuario             => ''RAFAQUESI'', ' ||
                   'p_ind_erro_out            => p_ind_erro_out, ' ||
                   'p_msg_retorno_out         => p_msg_retorno_out, ' ||
                   'p_commit                  => ''S'', ' ||
                   'p_versao                  => ''N'', ' ||
                   'p_ind_desfaz_faturamento  =>  ''S'');'
                   
from ts.fatura f
     join ts.cobranca c on c.num_seq_fatura_ts = f.num_seq_fatura_ts
where c.num_seq_cobranca IN ()     
