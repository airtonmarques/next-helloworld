update ts.campanha_vendas cv
set cv.ind_situacao = 1,
    cv.dt_fim_cadastro = null,
    cv.cod_usuario_fim_cadastro = null
where cv.cod_campanha IN (326)    
