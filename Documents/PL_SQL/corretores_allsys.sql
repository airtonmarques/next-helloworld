select filial.nome_sucursal filial,
       lpad(cv.cod_corretor, 11, '0') CPF,
       trim(es.nome_entidade) Nome,
       es.data_nascimento Nascimento,
       ('(' || cv.ddd_celular || ') ' || cv.num_celular) Telefone,
       cv.end_email,
       cv.ind_situacao,
       cv.data_inclusao,
       cv.data_exclusao
from ts.corretor_venda cv
     join ts.entidade_sistema es on es.cod_entidade_ts = cv.cod_entidade_ts
     join ts.sucursal filial on filial.cod_sucursal = cv.cod_sucursal
where cv.data_exclusao is null
      and cv.cod_tipo_produtor IN (7)
			 and cv.cod_sucursal = 4
order by 3, 7, 8


--"Precisamos de um relat�rio que tenha as informa��es do corretor (cpf) , data de aniversario , telefone , 
--cpf e se poss�vel a corretora tamb�m ."

/*select * from ts.tipo_produtor_vendas tpv
where tpv.cod_tipo_produtor IN (21, 4, 7, 3, 10)*/
