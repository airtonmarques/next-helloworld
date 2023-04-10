select --*
       ic.cod_ts,
       ic.mes_ano_ref,
       ic.cod_tipo_rubrica,
       count(1)
from ts.itens_cobranca ic
where --ic.cod_ts = 17135 and 
      ic.mes_ano_ref = to_date('01/07/2020', 'dd/mm/yyyy')
      and ic.cod_tipo_rubrica not in (45, 46, 115, 50, 16, 1, 245, 13, 24)
      --45 Mensalidade Associativa; 46 Taxa Administrativa; 115 Juros 
      --50 ODONTO; 16 Coparticipação; 1 Mensalidade Plano Familiar; 245 Desconto
      --24 Restituição; 10 Mensalidade Opcionais; 12 Correção; 
      --23 Cobrança Retroativa; 100 Coparticipação; 244 Taxa de Implantação de Proposta
group by ic.cod_ts,
       ic.mes_ano_ref,
       ic.cod_tipo_rubrica
having count(1) > 1

--select * from ts.tipo_rubrica_cobranca
where cod_tipo_rubrica in (10, 100, 244, 12, 23)
