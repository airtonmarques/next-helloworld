select b.num_associado_operadora,
       b.cod_ts_tit,
       b.tipo_associado,
       b.nome_associado,
       lpad(be.num_cpf, 11, '0') CPF,
       pm.cod_plano,
       pm.nome_plano,
       pm.ind_participacao copart,
       sys_get_idade_fnc(be.data_nascimento, sysdate) idade,
       (select fe.desc_faixa from ts.faixa_etaria fe 
               where fe.tipo_faixa = 2 
                     and sys_get_idade_fnc(be.data_nascimento, sysdate) between fe.idade_inicial and fe.idade_final) faixa,
       (select td.nome_dependencia 
           from ts.tipo_dependencia td
           where td.cod_dependencia = b.cod_dependencia) Dependencia,
       b.data_inclusao,
       rub.nom_tipo_rubrica,
       ic.val_item_cobranca,
       ic.val_item_pagar,
       (ic.val_item_cobranca - ic.val_item_pagar) spread
from ts.beneficiario b
     join ts.beneficiario_entidade be on be.cod_entidade_ts = b.cod_entidade_ts
     join ts.itens_cobranca ic on ic.cod_ts = b.cod_ts
     join ts.tipo_rubrica_cobranca rub on rub.cod_tipo_rubrica = ic.cod_tipo_rubrica
     join ts.plano_medico pm on pm.cod_plano = ic.cod_plano
where b.cod_ts_contrato IN (9166)  
      and ic.num_ciclo_ts IN (709)  
order by 2, 3 desc     
