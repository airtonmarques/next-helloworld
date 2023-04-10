
delete ts.contrato_plano cp
where cp.cod_ts_contrato = 42696
      and cp.cod_plano IN ('COAPCPII', 'CORPSSSAPC', 'SSB', '83', '1737')
			
delete ts.valor_fe_contrato fe
where fe.cod_ts_contrato = 42696
      and fe.cod_plano IN ('COAPCPII', 'CORPSSSAPC', 'SSB', '83', '1737')
			
delete ts.CONTRATO_ADESAO_PLANO cap
where cap.cod_ts_contrato = 42696
      and cap.cod_plano IN ('COAPCPII', 'CORPSSSAPC', 'SSB', '83', '1737')
