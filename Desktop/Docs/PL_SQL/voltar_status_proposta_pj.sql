
update ts.pj_proposta p 
set cod_situacao_proposta_pj = 17,  
    cod_motivo_canc = null,
    cod_usuario_canc = null,
    dt_canc = null,
    txt_motivo_canc = null,
    dt_atu = sysdate,
    cod_usuario_atu = 'RAFAQUESI'
where p.num_proposta IN
('24680003343')
