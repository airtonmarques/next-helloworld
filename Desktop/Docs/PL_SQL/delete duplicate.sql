DELETE FROM contrato_campos_operadora cco
WHERE cco.cod_campo = 'NOME_MIGRACAO' 
and rowid not in
(SELECT MIN(rowid)
FROM contrato_campos_operadora  cco1
WHERE cco1.cod_campo = 'NOME_MIGRACAO'
GROUP BY cco1.cod_ts_contrato,
         cco1.cod_operadora,
				 cco1.cod_campo);
