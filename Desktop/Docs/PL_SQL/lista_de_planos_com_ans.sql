select distinct
       op.nom_operadora Operadora,
       pm.cod_plano Codigo_Plano,
       pm.nome_plano Plano,
       pm.cod_registro_ans Numero_ANS,
       ans.nome_produto_ans Nome_ANS,
       decode(pm.ind_participacao, '', 'Não', 'S', 'Sim') Coparticipacao,
       decode(pm.cod_tipo_contratacao, 1, 'Individual', 2, 'Coletivo Emp', 3, 'Coletivo Adesao') Tipo_Contratacao,
       pm.ind_situacao Situacao,
       pm.data_criacao Comercializacao,
       pm.dt_cancelamento Cancelamento
from ts.plano_medico pm
     join ts.ppf_operadoras op on op.cod_operadora = pm.cod_operadora
     left join ts.PRODUTO_ANS ans on ans.cod_produto_ans = pm.cod_produto_ans
--where pm.cod_plano = '3020'     
order by 1, 3     
