delete alt_infraero where pensionista not in ('P');
commit;

insert into alt_infraero  
select (select bb.num_matric_empresa
          from ts.beneficiario bb
         where bb.cod_ts = b.cod_ts_tit) MATRICULA_TITULAR,
       (select substr(bb.nome_associado, 0, 100)
          from ts.beneficiario bb
         where bb.cod_ts = b.cod_ts_tit) NOME_TITULAR,
       (select lpad(bbe.num_cpf, 11, '0')
          from ts.beneficiario_entidade bbe
         where bbe.cod_entidade_ts = b.cod_entidade_ts_tit) CPF_TITULAR,
       /*  CASE b.tipo_associado
       WHEN 'T' THEN ''
        ELSE to_char(lpad(b.num_cco_dv, 2, '0'))
       END  COD_DEP,*/
       CASE b.tipo_associado
         WHEN 'T' THEN
          ''
         ELSE
          b.nome_associado
       END NOME_DEP,
       CASE b.tipo_associado
         WHEN 'T' THEN
          ''
         ELSE
          lpad(be.num_cpf, 11, '0')
       END CPF_DEP,
       to_char(c.dt_competencia, 'MM') MES,
       to_char(c.dt_competencia, 'YYYY') ANO,
       to_char(SUM(ic.val_item_cobranca), '99999999999.99') VALOR,
       '1' COD_ADMINISTRADORA,
       CASE b.cod_unimed_lcat
         WHEN 1 THEN
          'S'
       END PENSIONISTA,
			 b.cod_empresa,
			 ce.num_contrato,
			 null,
			 '010420231100'
  from ts.beneficiario b
  join ts.beneficiario_entidade be
    on be.cod_entidade_ts = b.cod_entidade_ts
  join ts.contrato_empresa ce
    on ce.cod_ts_contrato = b.cod_ts_contrato
  join ts.cobranca c
    on c.cod_ts = b.cod_ts_tit
  join ts.itens_cobranca ic
    on ic.num_seq_cobranca = c.num_seq_cobranca
   and ic.cod_ts = b.cod_ts

 where ce.num_contrato IN (15277, 33283, 35697) 
	 and c.dt_baixa between to_date('01/03/2023', 'DD/MM/YYYY') and last_day('01/03/2023')
    and ic.cod_tipo_rubrica not in (16, 100)
		--and b.nome_associado = 'AURENIA DE SOUZA DE CARVALHO'
	 --and b.num_matric_empresa = '506742'
   --and b.cod_empresa in (:COD_EMPR)

 group by b.cod_ts_tit,
          b.cod_entidade_ts_tit,
          b.num_cco_dv,
          b.nome_associado,
          be.num_cpf,
          c.dt_competencia,
          c.dt_baixa,
          b.tipo_associado,
          b.cod_unimed_lcat,
					b.cod_empresa,
			    ce.num_contrato;
commit;					

--Atualizar a ordem de exibição
update alt_infraero inf
set inf.ordem = 2
where inf.lote = '010420231100'
      and inf.nome_dep is null  
			and (inf.pensionista is null or inf.pensionista not in ('P'));
commit;			

--Atualizar a ordem de exibição
update alt_infraero inf
       set inf.ordem = 3 
where inf.lote = '010420231100'
      and inf.nome_dep is not null
			and (inf.pensionista is null or inf.pensionista not in ('P'));
commit;

--SEMPRE EXECUTAR O ABAIXO
-----Atualizar o ano e mes do PAgador
/*select 'update alt_infraero a set a.mes = ''' || a.mes || ''', a.ano = ''' || a.ano || ''' where a.pensionista = ''P'' and a.matricula_titular = ''' || a.matricula_titular || ''';'
from alt_infraero a
where a.lote = '010420231100'
      and a.nome_dep is null 
      and exists (select 1
                  from alt_infraero a1
                  where a1.pensionista = 'P'
                        and a1.matricula_titular = a.matricula_titular);											
*/
