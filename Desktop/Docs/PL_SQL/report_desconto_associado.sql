select distinct 
       adm.nom_operadora adm,
       s.nome_sucursal filial,
       op.nom_operadora operadora,
       b.num_associado cod_beneficiario,
       b.cod_ts_tit cod_familia_interno,
       b.nome_associado nome,
       b.tipo_associado tipo,
       ad.dt_ini_vigencia inicio_desconto,
       ad.dt_fim_vigencia fim_desconto,
       ad.pct_desconto,
       ad.val_desconto,
       ad.txt_observacao observacao,
       ad.cod_usuario_inc usuario_inclusao
       
from ts.associado_desconto ad
     join ts.beneficiario b on b.cod_ts = ad.cod_ts
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.sucursal s on s.cod_sucursal = ce.cod_sucursal
     join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
where ad.dt_ini_vigencia >= to_date('01/12/2020', 'dd/mm/yyyy')
      and ad.cod_usuario_inc <> 'RAFAQUESI'
order by 1, 3, 2, 5, 7 desc      
