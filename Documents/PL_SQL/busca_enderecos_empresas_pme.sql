select distinct ce.num_contrato,
                lpad(es.num_cgc, 14) CNPJ,
                es.nome_razao_social razao,
                e.num_seq_end,
                e.num_cep,
                e.nom_logradouro,
                e.num_endereco,
                e.txt_complemento,
                bairro.nom_bairro,
                cidade.nom_municipio,
                cidade.sgl_uf
from ts.contrato_empresa ce
     join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
     join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
     join ts.enderecos e on e.cod_entidade_ts = ec.cod_entidade_ts
     left join ts.bairro bairro on bairro.cod_bairro = e.cod_bairro
     left join ts.municipio cidade on cidade.cod_municipio = e.cod_municipio
where ce.num_contrato IN ()
order by 3, 4
