--adm/ filial/ operadora/ titulares e patrocinadores/ 
--tipo de cobrança boleto/ plano sem coparticipação;

select distinct
       adm.nom_operadora Adm,
       porte.nome_tipo_empresa Porte,
       filial.nome_sucursal Filial,
       op.nom_operadora Operadora,
       b.nome_associado Beneficiario,
       b.tipo_associado Tipo_Associado,
       pm.nome_plano Plano,
       ce.num_contrato Contrato,
       tf.nom_tipo_fat Faturamento,
       nvl(decode(cc.tipo_mes_pagamento, 1, 'Faturamento', 2, 'Anterior/Sub', 3, 'Emissão'), 'Sem Configuração') Tipo_Mes, 
       cv.dia_vencimento Dia_Vencimento
from ts.beneficiario b
     join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
     join ts.contrato_cobranca cc on cc.cod_ts_contrato = ce.cod_ts_contrato
     join ts.tipo_faturamento tf on tf.cod_tipo_fat = cc.cod_tipo_fat
     join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
     join ts.operadora adm on adm.cod_operadora = b.cod_operadora
     join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
     join ts.sucursal filial on filial.cod_sucursal = ce.cod_sucursal
     join ts.plano_medico pm on pm.cod_plano = b.cod_plano 
          and pm.cod_operadora = ce.cod_operadora_contrato
     left join ts.beneficiario_faturamento bf on bf.cod_ts = b.cod_ts
     left join ts.contrato_vencimentos cv on cv.cod_ts_contrato = ce.cod_ts_contrato
where b.tipo_associado IN ('P', 'T')     
      and bf.cod_tipo_cobranca = 2
      and b.data_exclusao is null
      and cv.ind_tipo_dia_vencimento = 'B'
      and (pm.ind_participacao is null OR pm.ind_participacao = 'N')
      and cc.dt_ini_cobranca = (select max(cc2.dt_ini_cobranca) 
                                from ts.contrato_cobranca cc2
                                where cc2.cod_ts_contrato = cc.cod_ts_contrato)
order by 1, 2, 4, 3, 8, 5, 7      
      
