update alt_inadimplentes_fin inad
       set inad.telefone_contato = SYS_GET_TEL_FNC(inad.cod_entidade_ts_tit, 'C'),
           inad.telefone_cobranca = SYS_GET_TEL_FNC(inad.cod_entidade_ts_tit, 'B'),
           inad.email = ts_consulta.all_get_mail_fnc(inad.cod_entidade_ts_tit),
           inad.acao_judicial = DECODE((SELECT COUNT(1)
                    FROM ts.acao_jud_pgto a
                   WHERE a.cod_ts IN (inad.cod_ts, inad.cod_ts_tit)
                     AND SYSDATE BETWEEN a.DT_INI_ACAO AND
                         NVL(a.DT_FIM_ACAO, to_date('31/12/3000', 'DD/MM/YYYY'))),
                  0,
                  'NÃO POSSUI',
                  'POSSUI');
-------------------------------------------------------------------------------------------

update alt_inadimplentes_fin inad
set inad.data_ultima_suspensao = (select trunc(max(oco.dt_ocorrencia))
                              from ts.ocorrencia_associado oco
                              where oco.cod_ts = inad.cod_ts
                                    and oco.cod_ocorrencia in (8, 54))  
-------------------------------------------------------------------------------------------

update alt_inadimplentes_fin inad       
set inad.logradouro = (select distinct en.nom_logradouro 
                       from TS.BENEFICIARIO_ENDERECO EN 
                 where en.cod_entidade_ts = inad.cod_entidade_ts_tit
                       and en.num_seq_end = (select max(en1.num_seq_end)
                                             from ts.beneficiario_endereco en1
                                             where en1.cod_entidade_ts = en.cod_entidade_ts))
                                             
-------------------------------------------------------------------------------------------------

update alt_inadimplentes_fin inad       
set inad.numero_endereco = (select distinct en.num_endereco 
                       from TS.BENEFICIARIO_ENDERECO EN 
                 where en.cod_entidade_ts = inad.cod_entidade_ts_tit
                       and en.num_seq_end = (select max(en1.num_seq_end)
                                             from ts.beneficiario_endereco en1
                                             where en1.cod_entidade_ts = en.cod_entidade_ts))   
                                             
--------------------------------------------------------------------------------------------------

update alt_inadimplentes_fin inad       
set inad.complemento = (select distinct en.txt_complemento 
                       from TS.BENEFICIARIO_ENDERECO EN 
                 where en.cod_entidade_ts = inad.cod_entidade_ts_tit
                       and en.num_seq_end = (select max(en1.num_seq_end)
                                             from ts.beneficiario_endereco en1
                                             where en1.cod_entidade_ts = en.cod_entidade_ts))   
                                             
-----------------------------------------------------------------------------------------------------

update alt_inadimplentes_fin inad       
set inad.cep = (select distinct en.num_cep 
                       from TS.BENEFICIARIO_ENDERECO EN 
                 where en.cod_entidade_ts = inad.cod_entidade_ts_tit
                       and en.num_seq_end = (select max(en1.num_seq_end)
                                             from ts.beneficiario_endereco en1
                                             where en1.cod_entidade_ts = en.cod_entidade_ts))     
                                             
-----------------------------------------------------------------------------------------------------

update alt_inadimplentes_fin inad       
set inad.uf = (select distinct en.sgl_uf 
                       from TS.BENEFICIARIO_ENDERECO EN 
                 where en.cod_entidade_ts = inad.cod_entidade_ts_tit
                       and en.num_seq_end = (select max(en1.num_seq_end)
                                             from ts.beneficiario_endereco en1
                                             where en1.cod_entidade_ts = en.cod_entidade_ts))  
                                             
-----------------------------------------------------------------------------------------------------

update alt_inadimplentes_fin inad       
set inad.uf = (select distinct en.sgl_uf 
                       from TS.BENEFICIARIO_ENDERECO EN 
                 where en.cod_entidade_ts = inad.cod_entidade_ts_tit
                       and en.num_seq_end = (select max(en1.num_seq_end)
                                             from ts.beneficiario_endereco en1
                                             where en1.cod_entidade_ts = en.cod_entidade_ts))    
                                             
-----------------------------------------------------------------------------------------------------

update alt_inadimplentes_fin inad       
set inad.cod_bairro = (select distinct en.cod_bairro 
                       from TS.BENEFICIARIO_ENDERECO EN 
                 where en.cod_entidade_ts = inad.cod_entidade_ts_tit
                       and en.num_seq_end = (select max(en1.num_seq_end)
                                             from ts.beneficiario_endereco en1
                                             where en1.cod_entidade_ts = en.cod_entidade_ts)) 
                                             
-----------------------------------------------------------------------------------------------------

update alt_inadimplentes_fin inad       
set inad.cod_municipio = (select distinct en.cod_municipio 
                       from TS.BENEFICIARIO_ENDERECO EN 
                 where en.cod_entidade_ts = inad.cod_entidade_ts_tit
                       and en.num_seq_end = (select max(en1.num_seq_end)
                                             from ts.beneficiario_endereco en1
                                             where en1.cod_entidade_ts = en.cod_entidade_ts))    
                                             
-----------------------------------------------------------------------------------------------------

update alt_inadimplentes_fin inad       
set inad.bairro = (select distinct b.nom_bairro 
                       from TS.Bairro b 
                 where b.cod_bairro = inad.cod_bairro)         
                 
-----------------------------------------------------------------------------------------------------

update alt_inadimplentes_fin inad       
set inad.municipio = (select distinct m.nom_municipio
                       from TS.municipio m 
                 where m.cod_municipio = inad.cod_municipio)        
                 
-----------------------------------------------------------------------------------------------------

update alt_inadimplentes_fin inad       
set inad.num_fatura = (select distinct f.num_fatura
                       from TS.fatura f 
                 where f.num_seq_fatura_ts = inad.num_seq_fatura_ts)                                                                                                                                                                                                                                                                                                                                                                                         











                   
                                                    
