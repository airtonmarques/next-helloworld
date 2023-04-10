---Nome da Mãe e Estado Civil
update ts.beneficiario_entidade be set be.nome_mae, be.ind_estado_civil =  where be.cod_entidade_ts = (select b.cod_entidade_ts from ts.beneficiario b where b.cod_ts =
--Telefone Celular
update ts.beneficiario_contato bc set bc.num_ddd = , bc.num_telefone =  where bc.ind_class_contato = 'C' and bc.cod_entidade_ts = (select b.cod_entidade_ts from ts.beneficiario b where b.cod_ts = 
--Endereço
update ts.beneficiario_endereco be set be.nom_logradouro = '', be.num_endereco = '', be.txt_complemento = '', be.num_cep = where be.cod_entidade_ts = (select b.cod_entidade_ts from ts.beneficiario b where b.cod_ts = 
--Email 
update ts.beneficiario_contato bc set bc.end_email = '' where bc.ind_class_contato = 'E' and bc.cod_entidade_ts = (select b.cod_entidade_ts from ts.beneficiario b where b.cod_ts = 
