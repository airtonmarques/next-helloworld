select 
'' sequencial,
ce.num_contrato_operadora num_contrato_operadora,
'' vazio,
'' vazio,
'' vazio,
b.tipo_associado,
to_char(b.data_inclusao, 'DDMMYYYY') dt_inclusao,
translate((upper(be.nome_entidade)),'��������������������','ACEIOUAEIOUAEIOUAOEU') nome_associado,
be.ind_sexo,


nvl(nvl(decode(td.cod_dependencia, 1, 'P',
       2, 'C',
			 3, 'F',
			 5, 'I',
			 6, 'A',
			 11, 'F',
			 22, 'F',
			 16, 'S'), td.nome_dependencia), 'T') parentesco,



decode(be.ind_estado_civil, 1, 'S',
       2, 'C',
			 3, 'V',
			 4, 'A',
			 5, 'D', 
			 6, 'S',
			 7, 'C', be.ind_estado_civil) estado_civil,



to_char(be.data_nascimento, 'DDMMYYYY') dt_nascimento,
lpad(be.num_cpf, 11, '0') cpf,
'01' nacionalidade,
translate((upper(be.nome_mae)),'��������������������','ACEIOUAEIOUAEIOUAOEU') nome_mae,
'' vazio,
bend.num_cep cep,
translate((upper(bend.nom_logradouro)),'��������������������','ACEIOUAEIOUAEIOUAOEU') logradouro,
trim(REGEXP_REPLACE(bend.num_endereco, '[[:alpha:]]')) numero,
bend.txt_complemento complemento,
bend.nome_bairro bairro,
bend.nome_cidade cidade,
bend.sgl_uf uf,
(select bc1.num_ddd || bc1.num_telefone from ts.beneficiario_contato bc1 where bc1.ind_class_contato = 'T' and rownum = 1 and bc1.cod_entidade_ts = b.cod_entidade_ts_tit) telefone,--ddd,
(select bc1.num_ddd || bc1.num_telefone from ts.beneficiario_contato bc1 where bc1.ind_class_contato = 'C' and rownum = 1 and bc1.cod_entidade_ts = b.cod_entidade_ts_tit) celular,--ddd,
--(select bc1.num_telefone from ts.beneficiario_contato bc1 where bc1.ind_class_contato = 'C' and rownum = 1 and bc1.cod_entidade_ts = b.cod_entidade_ts_tit) celular,
(select bc1.end_email from ts.beneficiario_contato bc1 where bc1.end_email is not null and bc1.ind_class_contato = 'E' and rownum = 1 and bc1.cod_entidade_ts = b.cod_entidade_ts_tit) email,
      case
         when bm.cod_plano_novo is not null then
          pmf.cod_plano_operadora
         else
          pm.cod_plano_operadora
       end cod_plano_operadora,

b.cod_ts,
b.cod_ts_tit,
(select a.nom_aditivo
 from ts.associado_aditivo aa
      join ts.aditivo a on aa.cod_aditivo = a.cod_aditivo
 where aa.cod_ts = b.cod_ts
       and rownum = 1) aditivo,			 

-- Data ocorrencia Inclus�o			 
(select oa.dt_ocorrencia
 from ts.ocorrencia_associado oa
 where oa.cod_ts = b.cod_ts and oa.cod_ocorrencia = 1 and rownum = 1) dth_oco_inclusao,

-- Mensagem ocorrencia Inclus�o 
(select oa.txt_obs
 from ts.ocorrencia_associado oa
 where oa.cod_ts = b.cod_ts and oa.cod_ocorrencia = 1 and rownum = 1) msg_inclusao, 
 
-- Data ocorrencia Troca de Plano			 
(select oa.dt_ocorrencia
 from ts.ocorrencia_associado oa
 where oa.cod_ts = b.cod_ts and oa.cod_ocorrencia = 51 and rownum = 1) dth_oco_troca_plano,

-- Mensagem ocorrencia Troca de Plano	 
(select oa.txt_obs
 from ts.ocorrencia_associado oa
 where oa.cod_ts = b.cod_ts and oa.cod_ocorrencia = 51 and rownum = 1) msg_troca_plano,
 
 -- Data ocorrencia Altera��o Nome			 
(select oa.dt_ocorrencia
 from ts.ocorrencia_associado oa
 where oa.cod_ts = b.cod_ts and oa.cod_ocorrencia = 24 and rownum = 1) dth_oco_alt_nome,

-- Mensagem ocorrencia Altera��o Nome	 
(select oa.txt_obs 
 from ts.ocorrencia_associado oa
 where oa.cod_ts = b.cod_ts and oa.cod_ocorrencia = 24 and rownum = 1) msg_alt_nome,
 
 -- Data ocorrencia Altera��o Data Nascimento			 
(select oa.dt_ocorrencia
 from ts.ocorrencia_associado oa
 where oa.cod_ts = b.cod_ts and oa.cod_ocorrencia = 22 and rownum = 1) dth_oco_alt_dt_nasc,

-- Mensagem ocorrencia Altera��o Data Nascimento	 
(select oa.txt_obs
 from ts.ocorrencia_associado oa
 where oa.cod_ts = b.cod_ts and oa.cod_ocorrencia = 22 and rownum = 1) msg_alt_dt_nasc,
 
 -- Data ocorrencia Transfer�cia de Contrato			 
(select oa.dt_ocorrencia
 from ts.ocorrencia_associado oa
 where oa.cod_ts = b.cod_ts and oa.cod_ocorrencia = 166 and rownum = 1) dth_oco_alt_transf_cont,

-- Mensagem ocorrencia Transfer�cia de Contrato	 
(select oa.txt_obs
 from ts.ocorrencia_associado oa
 where oa.cod_ts = b.cod_ts and oa.cod_ocorrencia = 166 and rownum = 1) msg_alt_transf_cont,
 
b.num_associado_operadora matricula 
 
  
from beneficiario           b,
       beneficiario_movimento bm,
       plano_medico           pm,
       plano_medico           pmf,
       beneficiario_entidade  be,
       contrato_empresa       ce,
       tipo_dependencia       td,
       beneficiario_endereco  bend
 where --b.cod_ts = 1428183
--and
 bm.cod_ts(+) = b.cod_ts
-- and be.nome_entidade = 'WALMIR NAZARETH DA SILVA'
 and pm.cod_plano = b.cod_plano
 and pmf.cod_plano(+) = bm.cod_plano_novo
 and b.cod_ts_contrato = ce.cod_ts_contrato
 and be.cod_entidade_ts = b.cod_entidade_ts
 and b.data_exclusao is null
 and td.cod_dependencia(+) = b.cod_dependencia
 and bend.cod_entidade_ts(+) = b.cod_entidade_ts_tit
 --and (bend.ind_residencia = 'S' or bend.ind_corresp = 'S' or bend.ind_cobranca = 'S')
 and ce.num_contrato in ('42997', '43012', '43015', '43018', '43033', '43042', '43087', '43090', 
                         '43591', '43593', '43595', '43597', '43034', '43044', '43088', '43091', 
												 '43592', '43594', '43596', '43598', '43035', '43055', '43089', '43092')
 and b.data_inclusao = to_date('20/09/2022', 'dd/mm/yyyy')
 --and b.data_inclusao = to_date('20/09/2022', 'dd/mm/yyyy')
--and b.num_associado = 142070920
 order by b.cod_ts_tit, b.tipo_associado desc
