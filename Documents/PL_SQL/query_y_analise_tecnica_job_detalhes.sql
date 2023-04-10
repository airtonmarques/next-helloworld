set echo off
set heading off
set pagesize 50000
set linesize 32767
set trims on

spool 'N:\\\\Shares\\\\EXTRACOES-JOBS\\\\Analise_Tecnica\\\\Propostas_Detalhes.csv'

select a.* from ( 
(select 'Operadora;Situacao;Numero_Proposta;Filial_Corretora;Titular;CPF_Titular;Nome;Tipo;CPF;Peso;Altura;Genero;Nascimento;Vigencia;Carencia;Telefone1;Telefone2;Telefone3;Celular1;Celular2;Celular3;Possui_DS;Empresa_participante;Situacao_analise_tecnica;Observacao_analise_tecnica'
 from dual) 
union all
select Operadora||';'||
       Situacao||';'||
	   Numero_Proposta||';'||
           Filial_Corretora||';'||
	   Titular||';'||
	   CPF_Titular||';'||
	   Nome||';'||
	   Tipo||';'||
	   CPF||';'||
	   Peso||';'||
	   Altura||';'||
	   Genero||';'||
	   Nascimento||';'||
	   Vigencia||';'||
	   Carencia||';'||
	   Telefone1||';'||
       Telefone2||';'||
       Telefone3||';'||
       Celular1||';'||
       Celular2||';'||
       Celular3||';'||
	Possui_DS||';'||
	Empresa_participante||';'||
	Situacao_analise_tecnica||';'||
        Observacao_analise_tecnica
	   from
	   (
select op.nom_operadora Operadora,
       status.txt_situacao Situacao,
       p.num_proposta_adesao Numero_Proposta,
      (select s.nome_sucursal
         from ts.sucursal s,
              ts.corretor_venda sup
        where sup.cod_corretor_ts = p.cod_produtor_ts 
          and s.cod_sucursal = sup.cod_sucursal) Filial_Corretora,
       p.nome_titular Titular,
       p.num_cpf_resp CPF_Titular,
       ass.nome_associado Nome,
       ass.tipo_associado Tipo,
       ass.num_cpf CPF,
       ass.peso Peso,
       ass.altura Altura,
       ass.ind_sexo Genero,
       to_date(ass.data_nascimento, 'dd/mm/yyyy') Nascimento,
       p.dt_inicio_vigencia Vigencia,
       ass.cod_grupo_carencia Carencia,
	   decode(ass.num_telefone_1, '','','+55')||ass.num_ddd_telefone_1||ass.num_telefone_1 Telefone1,
       decode(ass.num_telefone_2, '','','+55')||ass.num_ddd_telefone_2||ass.num_telefone_2 Telefone2,
       decode(ass.num_telefone_3, '','','+55')||ass.num_ddd_telefone_3||ass.num_telefone_3 Telefone3,
       decode(ass.num_celular_1, '','','+55')||ass.ddd_celular_1||ass.num_celular_1 Celular1,
       decode(ass.num_celular_2, '','','+55')||ass.ddd_celular_2||ass.num_celular_2 Celular2,
       decode(ass.num_celular_3, '','','+55')||ass.ddd_celular_3||ass.num_celular_3 Celular3,
	   case when (
     select count(1)
       from ts.ass_declaracao_saude ads
      where ads.num_seq_associado_mov = ass.num_seq_associado_mov
        and ads.ind_resposta = 'S') > 0 then 'S'
       else 'N' end Possui_DS,
	   (select nome_entidade
	      from ts.entidade_sistema e
         where e.cod_empresa = ass.cod_empresa
           and rownum = 1) Empresa_participante,
	  codmov.txt_descricao Situacao_analise_tecnica,
    replace(replace(trim(mhist.txt_obs_analise),';',''),CHR(10),'') Observacao_analise_tecnica,
    row_number() over (partition by mhist.num_seq_associado_mov order by mhist.dt_historico desc) as indice	   
from ts.ppf_proposta p
     join ts.ppf_operadoras op on op.cod_operadora = p.cod_operadora_contrato
     join ts.ppf_situacao_proposta status on status.cod_situacao_proposta = p.cod_situacao_proposta
     left join ts.mc_associado_mov ass on ass.num_seq_proposta_ts = p.num_seq_proposta_ts
	left join ts.cmc_situacao_analise_tecnica codmov on ass.cod_situacao_analise = codmov.cod_situacao_analise
	left join ts.mc_analise_tecnica_hist mhist on ass.num_seq_associado_mov = mhist.num_seq_associado_mov
where/* p.cod_operadora_contrato IN (3, 5)
      and*/ p.dt_inicio_vigencia >= to_date('01/01/2021', 'dd/mm/yyyy')
      --and status.cod_situacao_proposta in (14, 25, 26)
order by 1, 3, 5 desc
   ) aa where aa.indice = 1
   )a; 
   	 
 spool off
 spool out

quit      
