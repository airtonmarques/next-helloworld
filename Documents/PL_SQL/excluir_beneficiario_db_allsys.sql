delete ts.beneficiario_contato bc where bc.cod_entidade_ts IN (select cod_entidade_ts from ts.beneficiario where cod_ts_tit IN (select cod_ts_tit from ts.beneficiario where num_associado = '139116044'));

delete ts.beneficiario_empresa be where be.cod_ts IN (select cod_ts from ts.beneficiario where cod_ts_tit IN (select cod_ts_tit from ts.beneficiario where num_associado = '139116044'));

delete ts.beneficiario_faturamento be where be.cod_ts IN (select cod_ts from ts.beneficiario where cod_ts_tit IN (select cod_ts_tit from ts.beneficiario where num_associado = '139116044'));

delete ts.beneficiario_movimento be where be.cod_ts IN (select cod_ts from ts.beneficiario where cod_ts_tit IN (select cod_ts_tit from ts.beneficiario where num_associado = '139116044'));

delete ts.carencia_associado be where be.cod_ts IN (select cod_ts from ts.beneficiario where cod_ts_tit IN (select cod_ts_tit from ts.beneficiario where num_associado = '139116044'));

delete ts.ocorrencia_associado be where be.cod_ts IN (select cod_ts from ts.beneficiario where cod_ts_tit IN (select cod_ts_tit from ts.beneficiario where num_associado = '139116044'));

delete ts.posicao_cadastro be where be.cod_ts IN (select cod_ts from ts.beneficiario where cod_ts_tit IN (select cod_ts_tit from ts.beneficiario where num_associado = '139116044'));

delete ts.associado_sib be where be.cod_ts IN (select cod_ts from ts.beneficiario where cod_ts_tit IN (select cod_ts_tit from ts.beneficiario where num_associado = '139116044'));

delete ts.beneficiario be where be.cod_ts IN (select cod_ts from ts.beneficiario where cod_ts_tit IN (select cod_ts_tit from ts.beneficiario where num_associado = '139116044'));

ts.segunda_via_carteira
select * from 
