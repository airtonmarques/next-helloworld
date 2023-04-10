select distinct
       ce.num_contrato contrato,
       adm.nom_operadora administradora,
			 f.nome_sucursal filial,
			 es.nome_entidade entidade,
			 op.nom_operadora operadora,
			 porte.nome_tipo_empresa porte,
			 ce.ind_situacao status,
			 decode(ce.ind_tipo_produto, 1, 'M�dico', 'Dental') tipo,
			 ce.data_inicio_vigencia vigencia,
			 ce.cod_operadora produto,
			 'allcaregestora.com.br' dominio,
			 'ALLCARE ADMINISTRADORA DE BENEFICIOS LTDA - CNPJ/MF: 07.674.593/0001-10 AL SANTOS 1357 2 E 7 ANDAR - CERQUEIRA CESAR - SP CEP: 1419001' beneficiario,
			 (select count(1)
			  from ts.beneficiario b
				where b.ind_situacao in ('A', 'S')
				      and b.cod_ts_contrato = ce.cod_ts_contrato) vidas
from ts.contrato_empresa ce
     join ts.entidade_sistema es on es.cod_entidade_ts = ce.cod_titular_contrato
		 join ts.sucursal f on f.cod_sucursal = ce.cod_sucursal
		 join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
		 join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
		 join ts.operadora adm on adm.cod_operadora = ce.cod_operadora
where 1 = 1
      and exists (select 1 from ts.contrato_campos_operadora cco
                  where cco.cod_ts_contrato = ce.cod_ts_contrato
                        and cco.cod_campo = 'NOME_MIGRACAO'
                        and cco.val_campo = 'GEST�O SA�DE') 
			
order by 5, 6, 3, 4
