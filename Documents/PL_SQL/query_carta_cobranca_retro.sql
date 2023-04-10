select t.*,
       'Carta_Cob_Ret_2020_' || t.cod_ts_tit || '_' || t.nome_associado ||
       '_2020.pdf' nome_arq
  from alt_cob_ret_2020_view t
 where t.cod_tipo_fat = 5
   and t.is_perc_reaj = -1
 order by t.cod_ts_tit