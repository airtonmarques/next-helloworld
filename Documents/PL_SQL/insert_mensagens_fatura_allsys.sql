
insert into ts.mensagens_fatura(num_seq_fatura_ts,
                                ind_tipo_mensagem,
                                num_seq_item,
                                txt_descricao,
                                val_item,
                                ind_exibe_mensagem_rps,
                                ind_msg_inadimplencia,
                                data_inicio_vigencia)

select f.num_seq_fatura_ts,
       'D',
       (select 1 + max(mf.num_seq_item) 
        from ts.mensagens_fatura mf 
        where mf.num_seq_fatura_ts = f.num_seq_fatura_ts),
       '                         Coparticipação-' || b.nome_associado,
       ic.val_item_cobranca,
       'S',
       'N',
       b.data_inclusao 
from ts.fatura f
     join ts.cobranca c on c.num_seq_fatura_ts = f.num_seq_fatura_ts
     join ts.itens_cobranca ic on ic.num_seq_cobranca = c.num_seq_cobranca and ic.cod_tipo_rubrica = 100
     join ts.beneficiario b on b.cod_ts = ic.cod_ts
where c.num_seq_cobranca IN (13733221)
      and not exists (select 1
                      from ts.mensagens_fatura mf1 
                      where mf1.num_seq_fatura_ts = f.num_seq_fatura_ts
                            and upper(mf1.txt_descricao) like '%COPARTICIPAÇÃO-%')
