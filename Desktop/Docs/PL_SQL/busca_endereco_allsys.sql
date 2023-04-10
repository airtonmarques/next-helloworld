select distinct t.cod_ts_tit,
       'Carta_Cob_Ret_2020_' || t.cod_ts_tit || '_' || t.nome_associado ||
       '_2020.pdf' nome_arq,
       
       CASE WHEN be.num_seq_end is not null then be.nom_logradouro else 
         (select be2.nom_logradouro from ts.beneficiario_endereco@prod_allsys be2 
                 where be2.cod_entidade_ts = b.cod_entidade_ts
                 and be2.ind_residencia = 'S') end as Logradouro,
       
       CASE WHEN be.num_seq_end is not null then be.num_endereco else 
         (select be2.num_endereco from ts.beneficiario_endereco@prod_allsys be2 
                 where be2.cod_entidade_ts = b.cod_entidade_ts
                 and be2.ind_residencia = 'S') end as Numero,
                 
       CASE WHEN be.num_seq_end is not null then be.txt_complemento else 
         (select be2.txt_complemento from ts.beneficiario_endereco@prod_allsys be2 
                 where be2.cod_entidade_ts = b.cod_entidade_ts
                 and be2.ind_residencia = 'S') end as Complemento,   
                 
       CASE WHEN be.nome_bairro is not null then be.nome_bairro else 
         (select ba2.nom_bairro from ts.beneficiario_endereco@prod_allsys be2 
                 join ts.bairro@prod_allsys ba2 on ba2.cod_bairro = be2.cod_bairro
                 where be2.cod_entidade_ts = b.cod_entidade_ts
                 and be2.ind_residencia = 'S' and be2.num_seq_end = be.num_seq_end) end as Bairro,
                 
       CASE WHEN be.num_seq_end is not null then m.nom_municipio else 
         (select m2.nom_municipio from ts.beneficiario_endereco@prod_allsys be2 
                 join ts.municipio@prod_allsys m2 on m2.cod_municipio = be2.cod_municipio
                 where be2.cod_entidade_ts = b.cod_entidade_ts
                 and be2.ind_residencia = 'S') end as Cidade,
         
         CASE WHEN be.num_seq_end is not null then be.sgl_uf else 
         (select be2.sgl_uf from ts.beneficiario_endereco@prod_allsys be2 
                 where be2.cod_entidade_ts = b.cod_entidade_ts
                 and be2.ind_residencia = 'S') end as Estado,
                 
         CASE WHEN be.num_seq_end is not null then lpad(be.num_cep, 8, '0') else 
         (select lpad(be2.num_cep, 8, '0') from ts.beneficiario_endereco@prod_allsys be2 
                 where be2.cod_entidade_ts = b.cod_entidade_ts
                 and be2.ind_residencia = 'S') end as CEP              
        
  from alt_cob_ret_2020_view t
       join ts.beneficiario@prod_allsys b on t.cod_ts_tit = b.cod_ts
       left join ts.beneficiario_endereco@prod_allsys be 
                 on be.cod_entidade_ts = b.cod_entidade_ts 
                 --and be.ind_cobranca = 'S'
       left join ts.municipio@prod_allsys m on m.cod_municipio = be.cod_municipio
       left join ts.bairro@prod_allsys ba on ba.cod_bairro = be.cod_bairro
 where t.cod_tipo_fat = 5
   and t.is_perc_reaj = -1
   --and t.cod_ts_tit = 1177137
   --and b.num_associado = 12018422
 order by t.cod_ts_tit
 
 --is_perc_reaj = -1.... Anual e Faixa
 --is_perc_reaj = 0 - Somente faixa...
