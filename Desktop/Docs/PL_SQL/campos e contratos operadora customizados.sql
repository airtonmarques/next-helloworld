select 
      /* 'insert into campos_operadora(num_seq_campo_operadora, cod_operadora, cod_campo, cod_tabela_campo, descricao_campo, ind_ativo, ind_obrigatorio, dt_atu, cod_usuario, ind_habilitado, ind_tipo_preenchimento) values(' ||
       campos_operadora_seq.nextval || ', ' || o.cod_operadora || ', ''NOME_PROJETO'', ''C'', ''Nome do Projeto'', ''S'', ''N'', sysdate, ''RAFAQUESI'', ''S'', ''M'');' */
			 
			 'insert into ts.contrato_campos_operadora(cod_operadora, cod_ts_contrato, cod_campo, val_campo, dt_atu, cod_usuario, num_seq_cont_camp) values(' || ce.cod_operadora_contrato || ', ' || ce.cod_ts_contrato  || ', ''NOME_PROJETO'', ''SISDF - SOLUTIONS'', ' ||
			 'sysdate, ''RAFAQUESI'', ' || ass_cont_campos_operadora_seq.nextval || ');'
from ts.contrato_empresa ce
where ce.num_contrato IN ('47690',
'47691',
'47693',
'47685',
'47658',
'47651',
'47744',
'47689',
'47653',
'47687',
'47645',
'47648',
'47656',
'47660',
'47655',
'47688',
'47647',
'47671',
'47649',
'47644',
'47650',
'47642',
'47646',
'47623',
'47624',
'47625',
'47626',
'47677',
'47657',
'47652')
