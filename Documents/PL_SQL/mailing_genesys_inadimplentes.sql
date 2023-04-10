create or replace procedure ALL_CARGA_INAD_GENES is

begin

  delete from alt_inadimp_genesys;

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
       null residencial3,
       'PF' pessoaCobranca,
			 b.cod_ts,
			 ce.cod_operadora_contrato
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

--deletar quem possui ação judicial
-------------------------------
delete alt_inadimp_genesys g
where exists (SELECT 1
                  FROM ts.acao_jud_pgto a
                  WHERE a.cod_ts = g.cod_ts_allsys
                        AND SYSDATE BETWEEN a.DT_INI_ACAO AND
                        NVL(a.DT_FIM_ACAO, to_date('31/12/3000', 'DD/MM/YYYY')))
      and g.pessoacobranca = 'PF';
commit;

--Deixar apenas o último título
-------------------------------
update alt_inadimp_genesys g1
set g1.todelete = 1
where g1.cod_ts_allsys IN (select g.cod_ts_allsys
                           from alt_inadimp_genesys g
                           where g.pessoacobranca = 'PF'
                           group by g.cod_ts_allsys having count(1) > 1)
      and g1.dt_vencimento = (select max(g2.dt_vencimento)
                              from alt_inadimp_genesys g2
                              where g2.cod_ts_allsys = g1.cod_ts_allsys);
commit;
                              
delete alt_inadimp_genesys g
where g.todelete = 1;
commit;


--Update na tabela para considerar apenas uma linha com valor pago
/*update alt_inadimp_genesys g
set (g.idcont, g.Idcontparent, g.Idcad, 
     g.accountid, g.contactid, g.servicecontractid,
     g.parentservicecontractid) = (select c.id_cont,
                                         c.id_cont_parent,
                                         cr.id_cad,
                                         cr.id_sf,
                                         c.id_contato_sf,
                                         c.id_sf,
                                         cp.id_sf
from alt_cont2@prod_alltech c
     join alt_cont2@prod_alltech cp on cp.id_cont = c.id_cont_parent
     join alt_cont_cad2@prod_alltech ccr on  ccr.id_cont = c.id_cont
     join alt_cad2@prod_alltech cr on cr.id_cad = ccr.id_cad
where ccr.cod_vinc_cad = 71  
      and c.id_sf is not null
      --and cr.nome_cad = g.nomecad
      and g.cod_ts_allsys = to_number(substr(c.cod_cont_mig, 'PROP|', '')))
where g.pessoacobranca = 'PF';
commit;*/

--Update de numero de mensalidades em atraso
update alt_inadimp_genesys g
       set g.qtsmensatraso = (select count(1)
			                        from ts.cobranca c
															where c.cod_ts = g.cod_ts_allsys
															      and c.dt_baixa is null
																		and c.dt_cancelamento is null
																		and c.dt_emissao is not null
																		and c.dt_vencimento < trunc(sysdate))
where g.pessoacobranca = 'PF';
commit;


--Update de telefones
update alt_inadimp_genesys g
       set g.Residencial1 = SYS_GET_TEL_FNC2(g.cod_ts_allsys, 'T', 1),
           g.Residencial2 = SYS_GET_TEL_FNC2(g.cod_ts_allsys, 'T', 2),
           g.Residencial3 = SYS_GET_TEL_FNC2(g.cod_ts_allsys, 'T', 3),
           g.Celular1 = SYS_GET_TEL_FNC2(g.cod_ts_allsys, 'C', 1),
           g.Celular2 = SYS_GET_TEL_FNC2(g.cod_ts_allsys, 'C', 2),
           g.Celular3 = SYS_GET_TEL_FNC2(g.cod_ts_allsys, 'C', 3)
           
where g.pessoacobranca = 'PF';
commit;

--tratar acentuação
update alt_inadimp_genesys g
  set g.nomecad = translate(g.nomecad,
                         'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëü',
                         'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu'),
      g.operadora = translate(g.operadora,
                         'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëü',
                         'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu'),
			g.entidade = translate(g.entidade,
                         'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëü',
                         'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu'),
			g.porte = translate(g.porte,
                         'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëü',
                         'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu');                              
  commit;

DBMS_STATS.UNLOCK_TABLE_STATS('TS','alt_inadimp_genesys');
DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=>'TS',TABNAME=>'alt_inadimp_genesys');

  exception
    when others then
      rollback;
end;
