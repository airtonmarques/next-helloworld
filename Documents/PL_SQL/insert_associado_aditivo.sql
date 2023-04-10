insert into ts.associado_aditivo(cod_ts, cod_aditivo, dt_ini_vigencia,
        dt_atu, cod_ts_contrato, cod_usuario_atu, ind_forma_inclusao,
        num_associado_operadora) 

select b.cod_ts,
       '33',--b.cod_plano, 
			 to_date('01/04/2023' ,'dd/mm/yyyy'),
       sysdate, 
			 b.cod_ts_contrato, 
			 'RAFAQUESI', 
			 'M', 
			 ''--b.num_associado_operadora
from ts.beneficiario b
     --join ts.plano_medico pm on pm.cod_plano = b.cod_plano
     --join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     --join ts.cobranca c on c.cod_ts = b.cod_ts_tit
    /* join ts.beneficiario bb on trim(bb.nome_associado) = trim(b.nome_associado)
                                --and bb.ind_situacao = 'A'
                                --and b.data_inclusao >= to_date('01/12/2022', 'dd/mm/yyyy')
                                and bb.cod_ts <> b.cod_ts*/
where 1 = 1
    /*  and c.dt_baixa is not null
      and c.dt_emissao is not null
      and c.dt_cancelamento is null 
      and exists (select 1
                  from ts.contrato_aditivo ca
                  where ca.cod_aditivo = b.cod_plano
                        and ca.cod_ts_contrato = bb.cod_ts_contrato)
			and b.data_inclusao = to_date('01/12/2022', 'dd/mm/yyyy')
and ce.num_contrato IN ()*/
and b.cod_ts IN ()
and not exists (select 1
                  from ts.associado_aditivo aa
									where aa.cod_ts = b.cod_ts
									      and aa.cod_aditivo = '33') 
