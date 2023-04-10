select t.rowid,
       t.cod_ts_contrato,
       t.cod_ts_tit,
       t.cod_ts,
       t.num_contrato,
       t.cod_operadora_contrato,
       c.fant_cad nome_operadora,
       t.mes_reaj_cont,
       t.mes_reaj_cont_ajustado,
       t.dt_geracao,
       
       t.num_ciclo_ts,
       t.num_seq_cobranca,
       t.num_item_cobranca_ts,
       t.cod_tipo_rubrica,
       t.nom_tipo_rubrica,
       
       t.cod_plano,
       t.tipo_faixa,
       t.cod_faixa_etaria,
       t.cod_faixa_etaria_ajustado,
       
       t.dt_competencia,
       t.val_item_cobranca vlr_item,
       t.val_item_cobranca_desc vlr_desc,
       --t.val_item_cobranca_desc_conf vlr_desc_fonf,
       t.val_item_cobranca + t.val_item_cobranca_desc vlr_item_final,
       t.val_item_cobranca_ajustado vlr_item_ajustado,
       (t.val_item_cobranca_ajustado - t.val_item_cobranca -
       t.val_item_cobranca_desc) saldo,
       
       t.val_item_pagar,
       t.val_item_pagar_ajustado,
       (t.val_item_pagar_ajustado - t.val_item_pagar) saldo_pagar,
       
       t.val_item_cobranca + t.val_item_cobranca_desc - t.val_item_pagar vlr_over,
       t.val_item_cobranca_ajustado - t.val_item_pagar_ajustado vlr_over_ajustado,
       
       case
         when t.val_item_pagar <> 0 then
         
          trim(to_char(((t.val_item_cobranca + t.val_item_cobranca_desc -
                       t.val_item_pagar) / (t.val_item_pagar)) * 100,
                       '999990d99')) || ' %'
       
         else
          '0 %'
       end perc_over_conf,
       
       
       
       case
         when t.val_item_pagar_ajustado <> 0 then
          trim(to_char(((t.val_item_cobranca_ajustado -
                       t.val_item_pagar_ajustado) /
                       (t.val_item_pagar_ajustado)) * 100,
                       '999990d99')) || ' %'
         else
          '0 %'
       end perc_over_conf_ajustado,
       
       atencao,
       
       --       t.val_item_pagar2 vlr_pagar2,
       --     t.val_item_pagar_ajustado2 vlr_pagar_ajustado2,
       --   (t.val_item_pagar_ajustado2 - t.val_item_pagar2) saldo_pagar2,
       
       --  t.val_item_cobranca + t.val_item_cobranca_desc - t.val_item_pagar2 vlr_over2,
       
       t.dt_ref_tabela,
       
       t.tipo_associado,
       t.num_associado,
       t.nome_entidade,
       t.data_nascimento,
       t.num_cpf,
       t.num_associado_operadora,
       t.data_exclusao,
       
       (select max(m.nome_motivo_acao)
          from ts.acao_jud_pgto@allsys aj, ts.motivo_acao_jud@allsys m
         where aj.dt_fim_acao is null
           and aj.cod_ts = t.cod_ts
           and m.cod_motivo_acao = aj.cod_motivo_acao) nome_motivo_acao,
           
        (select max(adm.nom_operadora)
         from ts.contrato_empresa@allsys ce 
              join ts.operadora@allsys adm on adm.cod_operadora = ce.cod_operadora
              join ts.sucursal@allsys su on su.cod_sucursal = ce.cod_sucursal
         where ce.cod_ts_contrato = t.cod_ts_contrato) Administradora,
        
        (select max(su.nome_sucursal)
         from ts.contrato_empresa@allsys ce 
              join ts.operadora@allsys adm on adm.cod_operadora = ce.cod_operadora
              join ts.sucursal@allsys su on su.cod_sucursal = ce.cod_sucursal
         where ce.cod_ts_contrato = t.cod_ts_contrato) Filial
        

  from ALL_COB_RET_112020 t, alt_cad c
 where c.cod_cad = t.cod_operadora_contrato
   and c.cod_tipo_cad = 2

-- and t.num_contrato in (05488,05489,05490) -- Fesp
-- and t.num_contrato in (19103,19106,19107,05488,05489,05490) -- Ascap
-- and t.cod_ts_contrato in (5504)
-- and t.nome_entidade = 'ELIANE FELIPE DA SILVA'
-- and t.num_associado = 138271402
-- and t.cod_ts_tit in (893149)
-- and t.num_item_cobranca_ts in (select e.num_item_cobranca_ts from all_cob_ret_112020_exc e where e.tipo_exc in (15))
-- and t.cod_ts = 922625
-- and t.cod_operadora_contrato in (7,70,62,72,54,89,5,57,234,71) -- Operadoras Pequenas
-- and t.cod_operadora_contrato in (6,8,14,20,32,233,9,12,27,58,63,231,237) -- Operadoras Médias
--   and t.cod_operadora_contrato = 1 -- Amil
--   and t.dt_competencia between '01/05/2020' and '01/08/2020'
--   and t.cod_operadora_contrato = 2 -- CNU
--   and t.cod_operadora_contrato = 3 -- GNDI
--   and t.cod_operadora_contrato = 4 -- Amil Next
--   and t.cod_operadora_contrato = 11 -- Vitallis
--   and t.cod_operadora_contrato = 17 -- Samp
--   and t.cod_operadora_contrato = 67 -- CNU Brasilia

--   and t.cod_operadora_contrato = 97 -- Unimed Recife
--   and t.cod_operadora_contrato = 236 -- Unimed Uberlândia                

-- and t.num_item_cobranca_ts in (45739585,45739005,44440745,44753313,44366203,44319788)

--and t.data_exclusao <> sys_get_data_fim_fnc
--and t.nome_entidade like 'DANIELA CRIS%'
--and t.data_exclusao  = '31/12/3000'

and t.cod_ts_tit  in (select c.cod_ts_tit from all_cob_ret_112020_cob_3012 c where c.cod_operadora_contrato = 97 and trunc(c.dt_lanc) = '28/12/2020')

and t.cod_ts_tit in (1061802,1134983,1141116,1144721)

/*

select t.cod_ts_tit, t.nome_associado from alt_cob_ret_2020_view t where t.cod_ts_tit in (select c.cod_ts_tit from alt_producao.all_cob_ret_112020_cob c where c.cod_operadora_contrato = 97 and trunc(c.dt_insert) = '30/12/2020')
and t.cod_ts_tit not in (1061802,1134983,1141116,1144721)


1061802,1134983,1141116,1144721

   1 AMIL ASSISTÊNCIA MÉDICA INTERNACIONAL S.A.   
OK 2 CENTRAL NACIONAL UNIMED
   3 INTERMÉDICA SISTEMA DE SAÚDE S.A.            
OK 4 AMIL NEXT                                    
OK 11  VITALLIS SAÚDE S.A.                        
OK 17  SAMP ASSISTÊNCIA MÉDICA - ES               
OK 67  CNU BRASILIA
OK 97  UNIMED RECIFE                              
OK 134 UNIMED NATAL                               
OK 135 UNIMED NATAL 2                             
OK 230 UNIMED NATAL MIGRAÇÃO                      
OK 235 UNIMED NATAL MIGRAÇÃO 2                    
OK 232 S1 SAÚDE
OK 236 UNIMED UBERLÂNDIA


 59  PRODENT
XXX 85  UNIODONTO
XXX 87  BB DENTAL
XXX 106 UNIMED NORTE NORDESTE
XXX 133 VIVAMED
XXX 136 GOODLIFE SAÚDE
XXX 151 UNIODONTO PAULISTA
XXX 239 INTEGRAL SAÚDE

delete from ALL_COB_RET_112020 t where t.cod_operadora_contrato in (232) 
delete from ALL_COB_RET_112020_err t where t.cod_operadora_contrato in (232) 

select c.cod_cad, c.fant_cad, 
     sum(t.val_item_cobranca) vlr_cob,
     sum(t.val_item_cobranca_desc) vlr_desc,
     sum(t.val_item_cobranca_ajustado) vlr_cob_ajustado,
     sum(t.val_item_cobranca_ajustado) -
     sum(t.val_item_cobranca) - sum(t.val_item_cobranca_desc) vlr_saldo,
--     sum(t.val_item_pagar) vlr_pagar,
--     sum(t.val_item_pagar_ajustado) vlr_pagar,
--     sum(t.val_item_pagar_ajustado) - sum(t.val_item_pagar) vlr_saldo_pagar,

--     sum(t.val_item_pagar_ajustado2) - sum(t.val_item_pagar2) vlr_saldo_pagar2,
     count(1)
     
from ALL_COB_RET_112020 t, ALT_CAD C
where c.cod_cad = t.cod_operadora_contrato (+)
and c.cod_tipo_cad = 2
and t.tipo_faixa <> 13
--and c.cod_cad in (1,2,3,4,6,7,8,9,11,12,14,17,20,32,54,58,59,60,63,67,70,97,134,135,230,231,232,235,236,237)
--and t.data_exclusao <> '31/12/3000'
group by c.cod_cad, c.fant_cad


select e.cod_ts_contrato, e.num_contrato, e.error from ALL_COB_RET_112020_err e where e.cod_operadora_contrato in (6,8,14) 



and t.cod_ts_contrato = '1500'

where t.cod_ts_contrato in (select t2.cod_ts_contrato from ALL_COB_RET_112020_back t2)

   1 AMIL ASSISTÊNCIA MÉDICA INTERNACIONAL S.A.   
OK 2 CENTRAL NACIONAL UNIMED
   3 INTERMÉDICA SISTEMA DE SAÚDE S.A.            
OK 4 AMIL NEXT                                    
OK 11  VITALLIS SAÚDE S.A.                        
OK 17  SAMP ASSISTÊNCIA MÉDICA - ES               
OK 67  CNU BRASILIA
OK 97  UNIMED RECIFE                              
OK 134 UNIMED NATAL                               
OK 135 UNIMED NATAL 2                             
OK 230 UNIMED NATAL MIGRAÇÃO                      
OK 235 UNIMED NATAL MIGRAÇÃO 2                    
OK 232 S1 SAÚDE
OK 236 UNIMED UBERLÂNDIA

134,135,230,235 - UNIMEDS NATAIS


6,8,14  20,32,233 9,12,27,58 63,231,237 - OPERADORAS MÉDIAS

6 PROMED BRASIL ASSISTÊNCIA MÉDICA LTDA
8 SÃO CRISTOVÃO
14  BRADESCO

20  ASSIM SAUDE
32  SLAM
233 UNIHOSP SAUDE

9 UNIMED FESP
12  UNIMED RIO
27  UNIMED FORTALEZA
58  UNIMED SEGUROS

63  UNIMED BH
231 UNIMED IMPERATRIZ
237 UNIMED PALMAS

XXX 29  CAIXA SEGURADORA
XXX 60  UNIMED ODONTO

7,70,62,72,54,89,5,57,234,71 - OPERADORAS PEQUENAS
5 NOTRE DAME SEGURO SAÚDE S.A.
7 SANTAMÁLIA SAÚDE
54  HAPVIDA
57  AGEMED SAUDE
62  UNIMED CONSELHEIRO LAFAIETE
70  DIX
71  UNIMED ITAJUBA
72  PROMED
89  UNIÃO MEDICA
234 UNIMED SÃO JOSÉ DO RIO PRETO

XXX 59  PRODENT
XXX 85  UNIODONTO
XXX 87  BB DENTAL
XXX 106 UNIMED NORTE NORDESTE
XXX 133 VIVAMED
XXX 136 GOODLIFE SAÚDE
XXX 151 UNIODONTO PAULISTA
XXX 239 INTEGRAL SAÚDE


1,97,3,134,2,4,11,135,17,67,230,235,232



='10592'

10621 - 1 1169269,75  -66473,4  1231301,02  128504,67 1052360,13  1450171,17  397811,04 150289,5
10621 - 1 1169269,75  -66473,4  1231301,02  128504,67 1052360,13  1108006,52  55646,39  115563,04
        1 1169269,75  -66473,4  1231301,02  128504,67 1052360,13  1108006,52  55646,39  115563,04



1 30835316,78 -1585761,2  32249163,83 2999608,25  23111624,35 29637300,33 6525675,98  2666648,92
1 30244188,33 -1551827,97 31631069,22 2938708,86  27533862,06 41595159,74 14061297,68 3848599,34


-- 10184: 1 676607,08 -38438,65 710217,18 72048,75  550471,83 621421,93 70950,1 63042,4
--        1 676420,79 -38417,13 710030,89 72027,23  0         899618,3  899618,3  0

-- 10592_: 1  560959,17 -32745,68 588122,72 59909,23  474573,35 535876,99 61303,64  54588,86


1   198306
97  151261
3   142877
134  72063
2    70068
4    43620
11   41403
135  29846
17   27712
67   21724
230  17425
235  15639
232  12713
58    9241
12    8246
63    7530
20    5912
32    5572
231   4900
237   4822
9     4456
14    4174
29    3427
236   2732
60    2656
8     2396
233   1495
6     1254
27    1163
7      972
85     894
70     652
59     610
62     551
72     293
87     232
106    164
54     138
239     50
89      36
136     27
151     18
133     10
5       10
57      10
234      8
71       3



select c.cod_cad, c.nome_cad from alt_cad c where c.cod_tipo_cad = 2 and c.cod_cad in (7,85,70,59,62,72,87,106,54,239,89,136,151,133,5,57,234,71)


*/
