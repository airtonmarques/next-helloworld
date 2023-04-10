select 'insert into ts.cms_contrato_adesao(cod_ts_contrato, dt_ini_vigencia, cod_corretor_ts, cod_funcao, ind_tipo_regra, ind_tipo_valor, dt_atu, cod_usuario_atu, cod_ts) values (' ||
       ce.cod_ts_contrato || ', ''01/07/2022'', ' || '(select cv.cod_corretor_ts from ts.corretor_venda cv where cv.cod_corretor = ''070955''), 2, 2, 1, sysdate, ''RAFAQUESI'', ' ||
			 '(select b.cod_ts from ts.beneficiario b where b.num_associado = ''141157666''))'
from ts.cms_contrato_adesao ca
     join ts.contrato_empresa ce on ce.cod_ts_contrato = ca.cod_ts_contrato
where ce.num_contrato = '37138'

-------------------------------------------------------------------------------------------

select 'insert into ts.cms_contrato_adesao_per(cod_ts_contrato, cod_corretor_ts, cod_funcao, dt_ini_vigencia, ind_aplicacao, num_parcela_ini, num_parcela_fim, val_comissao, cod_usuario_atu, dt_atu, cod_ts) values (' ||
       ce.cod_ts_contrato || ', ' || '(select cv.cod_corretor_ts from ts.corretor_venda cv where cv.cod_corretor = ''070955''), 2, ''01/07/2022'', 3, 1, 999999999, 3.00, ''RAFAQUESI'', sysdate,  ' ||
			 '(select b.cod_ts from ts.beneficiario b where b.num_associado = ''141157666''))'
from ts.cms_contrato_adesao ca
     join ts.contrato_empresa ce on ce.cod_ts_contrato = ca.cod_ts_contrato
where ce.num_contrato = '37138'
 
--------------------------------------------------------------------------------------------
insert into ts.cms_contrato_adesao(cod_ts_contrato, dt_ini_vigencia, cod_corretor_ts, cod_funcao, ind_tipo_regra, ind_tipo_valor, dt_atu, cod_usuario_atu, cod_ts) values ((select c.cod_ts_contrato from ts.contrato_empresa c where c.num_contrato = ''), '01/01/2023', (select cv.cod_corretor_ts from ts.corretor_venda cv where cv.cod_corretor = ''), 2, 2, 1, sysdate, 'RAFAQUESI', );
insert into ts.cms_contrato_adesao_per(cod_ts_contrato, cod_corretor_ts, cod_funcao, dt_ini_vigencia, ind_aplicacao, num_parcela_ini, num_parcela_fim, val_comissao, cod_usuario_atu, dt_atu, cod_ts) values ((select c.cod_ts_contrato from ts.contrato_empresa c where c.num_contrato = ''), (select cv.cod_corretor_ts from ts.corretor_venda cv where cv.cod_corretor = ''), 2, '01/01/2023', 3, 1, 999999999, 3.00, 'RAFAQUESI', sysdate, );
-----------------------------------------------------------------------------------------------------------------------------------------------------
--===================================================================================================================================================
--===================================================================================================================================================
