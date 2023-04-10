SELECT tc.txt_nome_comunicacao, tc.txt_desc_comunicacao, tc.cod_tipo_comunicacao,
       count(1)--mail.*
FROM COM_REGISTRO reg
     join ts.tipo_comunicacao tc on tc.cod_tipo_comunicacao = reg.cod_tipo_comunicacao
     join ts.com_email mail on mail.seq_comunicacao = reg.seq_comunicacao
where trunc(mail.dat_envio) = to_date('23/02/2021', 'dd/mm/yyyy') 
group by tc.txt_nome_comunicacao, tc.txt_desc_comunicacao, tc.cod_tipo_comunicacao  
