--Rotina Cancelamento de Associado
delete TS.CMS_CONTRATO_ADESAO ca
where ca.cod_ts in (1437436,
1437484,
1437438,
1437439,
1437485,
1437440,
1437441,
1437502,
1437442,
1437443,
1437444,
1437445,
1437446,
1437447,
1437448,
1437449,
1437450,
1437451,
1437487,
1437488,
1437452,
1437453,
1437454,
1437455,
1437456,
1437457,
1437489,
1437490,
1437458,
1437459,
1437460,
1437461,
1437462,
1437491,
1437463,
1437464,
1437492,
1437493,
1437465,
1437466,
1437467,
1437468,
1437469,
1437476,
1437477,
1437497,
1437498,
1437478,
1437479,
1437480,
1437499,
1437500,
1437481,
1437501,
1437486,
1437482,
1437483,
1437437,
1437496,
1437494,
1437470,
1437471,
1437472,
1437473,
1437495,
1437474,
1437475)
--------------------------------------
--ass_cancela_inclusao_ass(p_cod_ts => , p_cod_usuario => 'RAFAQUESI', p_endereco_ip => '', p_cod_retorno => p_ind_erro_out, p_msg_retorno => p_msg_retorno_out, p_commit => 'S', p_versao => 'N');
/*
select distinct b.cod_ts
from ts.beneficiario b
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
where ce.num_contrato IN ()		 */ 
		 

