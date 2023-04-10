select g.nom_grupo_rubrica Grupo,
       r.cod_tipo_rubrica Codigo,
       r.nom_tipo_rubrica Rubrica,
       decode(r.ind_forma_lancamento,
              'A', 'Automático', 'M', 'Manual') Lancamento,
       r.nom_boleto DescricaoBoleto,
       r.ind_incide_comissao Incide_Comissao,
       ra.nome_ans_ra ANS_RA, 
       (select r2.nom_tipo_rubrica from ts.tipo_rubrica_cobranca r2 where r2.cod_tipo_rubrica = r.cod_tipo_rubrica_restituicao) rubrica_restituicao,
       r.ind_particularidade_dvp particularidade_ir,
       r.ind_tratar_restituicao tratar_restituicao,
       decode(r.ind_grupo_dvp,
              'M', 'Mensalidade', 'C', 'Coparticipação') grupo_demonstrativo,
       r.txt_fluxo_caixa fluxo_caixa
       
from ts.tipo_rubrica_cobranca r
     left join ts.grupo_rubrica_cobranca g on g.cod_grupo_rubrica = r.cod_grupo_rubrica
     left join ts.ANS_TIPO_CONTRATO_RA ra on ra.cod_ans_ra = r.cod_ans_ra
order by 1, 3
