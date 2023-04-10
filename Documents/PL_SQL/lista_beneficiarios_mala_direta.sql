select distinct 
       mala.nome_mala,
       send.destino_msg,
       send.titulo_msg,
       send.dth_envio_msg,
       send.retorno_msg,
       cad.nome_cad,
       decode(dep.dt_exc_prop_dep, to_date('31/12/3000', 'dd;mm/yyyy'), 'Ativo', 'Excluído') Status,
       dep.dt_exc_prop_dep,
       cid.cod_uf UF
from alt_mala mala
     join SYS_SEND_MSG send on send.cod_mala = mala.cod_mala
     join alt_cad cad on cad.cod_cad = send.cod_cad and cad.cod_tipo_cad = send.cod_tipo_cad
     join alt_prop_dep dep on dep.cod_cad_dep = cad.cod_cad and dep.cod_tipo_cad_dep = cad.cod_tipo_cad
     join alt_cad_end ende on ende.cod_tipo_cad = cad.cod_tipo_cad and ende.cod_cad = cad.cod_cad
     join td_alt_bairro bai on bai.cod_bairro = ende.cod_bairro 
     join td_alt_cidade cid on cid.cod_cidade = bai.cod_cidade
where mala.cod_mala IN (370, 371, 372, 373, 374, 380, 381, 382, 383, 384)
order by 1, 9, 6
