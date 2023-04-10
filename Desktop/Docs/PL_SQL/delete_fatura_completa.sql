delete from fat_log_faturamento
where cod_ts in ();
commit;
----

delete from fat_emissao_cancelada
where cod_ts in ();
commit;
----

update cobranca set NUM_SEQ_FATURA_TS = null
where cod_ts in ();
commit;
----

delete from fatura
where cod_ts in ();
commit;
----
         
delete from cobranca_comissao
where num_seq_cobranca in (select num_seq_cobranca from cobranca where dt_baixa is null and cod_ts in ());
commit;
----
         
delete fat_envio_alteracao_cnab f 
where f.num_seq_cobranca IN (select num_seq_cobranca from cobranca where dt_baixa is null and cod_ts in ());
commit;
----
         
delete fat_emissao_cancelada ec
where ec.num_seq_cobranca IN (select num_seq_cobranca from cobranca where dt_baixa is null and cod_ts in ());
commit;
----

delete from ocorrencia_alocacao_sur
where num_seq_cobranca in (select num_seq_cobranca from cobranca where dt_baixa is null and cod_ts in ());
commit;
----

update credito_recebido_sur
set num_seq_controle_recbto = null,
    num_seq_cobranca = null
where num_seq_cobranca in (select num_seq_cobranca from cobranca where dt_baixa is null and cod_ts in ());
commit;
------

delete from credito_recebido_sur
where num_seq_cobranca in (select num_seq_cobranca from cobranca where dt_baixa is null and cod_ts in ());
commit;
------


delete from cobranca
where dt_baixa is null and cod_ts in ();
commit;
----

delete from itens_cobranca
where cod_ts in ();
commit;
----
