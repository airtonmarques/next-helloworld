select distinct 'update ts.beneficiario b set b.ind_situacao = ''E'', b.data_exclusao = to_date(''31/03/2023'', ''dd/mm/yyyy''), b.data_registro_exclusao = sysdate where b.cod_ts = ' || b.cod_ts || ';',
       'update ts.beneficiario_contrato bc set bc.cod_motivo_exclusao = 80, bc.txt_motivo_exclusao = ''Beneficiário cancelado na antiga administradora'' where bc.cod_ts = ' || b.cod_ts || ';'/*,
       b.cod_ts_tit,
       b.num_seq_matric_empresa,
       b.ind_situacao,
       b.cod_ts,
			 b.num_associado,
			 b.data_inclusao,
			 b.data_exclusao,
			 b.data_registro_exclusao,
			 bc.cod_motivo_exclusao,
			 bc.txt_motivo_exclusao*/
from ts.beneficiario b
   /* join ts.beneficiario_contrato bc on bc.cod_ts = b.cod_ts
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.cobranca c on c.cod_ts = b.cod_ts_tit*/
where 1 = 1
    /*and c.dt_baixa is null
      and c.dt_emissao is not null
      --and c.dt_cancelamento is null 
     and b.data_inclusao = to_date('16/12/2022', 'dd/mm/yyyy')*/
		 and b.ind_situacao = 'A'
    --and ce.num_contrato IN ()
		and b.cod_ts IN ()
--order by 3
