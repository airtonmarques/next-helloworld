insert into ALT_INADIMP_GENESYS 
select null idCont, --number(8)
       null idContParent, --number(8)
			 c.num_seq_cobranca idTitulo, --number(10)
			 null idCad, --number(8)
			 null accountId, --varchar2(20)
			 null contactId, --varchar2(20)
			 null serviceContractId, --varchar2(20)
			 null parentServiceContractId, --varchar2(20)
       be.num_cpf cnpj_cpf,--number(14)
			 b.nome_associado nomeCad,
			 op.nom_operadora operadora,
			 es.nome_entidade entidade,
			 nvl(p.num_proposta_adesao, b.num_proposta) proposta,
			 c.dt_vencimento dt_vencimento,
			 (trunc(sysdate) - c.dt_vencimento) diasEmAtraso,
			 porte.nome_tipo_empresa porte,
       c.val_a_pagar vlrMensAtraso,
			 null qtsMensAtraso,
			 null celular1,
			 null celular2,
			 null celular3,
			 null residencial1,
			 null residencial2,
			 null residencial3
from ts.cobranca c
     join ts.beneficiario b on b.cod_ts = c.cod_ts
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
		 join ts.contrato_empresa ce on ce.cod_ts_contrato = b.cod_ts_contrato
		 join ts.empresa_contrato ec on ec.cod_ts_contrato = ce.cod_ts_contrato
                              	 and (b.cod_empresa is null OR ec.cod_entidade_ts = b.cod_empresa)
		 join ts.regra_empresa porte on porte.tipo_empresa = ce.tipo_empresa
		 join ts.entidade_sistema es on es.cod_entidade_ts = ec.cod_entidade_ts
		 join ts.ppf_operadoras op on op.cod_operadora = ce.cod_operadora_contrato
		 left join ts.ppf_proposta p on p.num_seq_proposta_ts = b.num_seq_proposta_ts
where c.dt_cancelamento is null
      and c.dt_emissao is not null
			and c.dt_baixa is null
			and c.dt_vencimento < trunc(sysdate)
			and b.ind_situacao IN ('A', 'S');
commit;			
