select distinct listagg(pm.id_subcontrato, ', ')
from pm_contrato pm
where upper(pm.operadora) like '%BRADESCO ADES%'
      and pm.nome_fantasia_subcontrato is not null
      --and pm.tipo_subcontrato = 'PF'
			--and pm.id_subcontrato IN (1468690,2013568,2013569,1991038,1991039,1993230,1111180,1197821,1288751,1366053,1383390,1383394,2019353,1983480,1991582,1980540,1993560,1992491,1993558,1994868,1999895,1997754,1980456,1983576,1984223,1983583,1983639,1983631,1987577,1991006,2017392,2016258,2015461,2016725,2019434,2018175,2018176,2018177,2018178,2018179,2018180,2018181,2018182,2018183,2018184,2018185,2018186,2018187,2018188,2018189,2018190,2020689,2022325,2023293,2026438,2025269,2025314,2027268,2026965,2031591,1989584,1993719,2018285,1998891,1998990,1999787,1999785,2000293,1999789,2000819,2001429,2003781,2003779,2012529,2010992,2011315,2010910,2010911,2010912,2010406,2011565,2011567,2011568,2011569,2011570,2011571,2027055,2027056,2012659,2012792,2012790,2015855,2015689,2015690,2015493,2015966,2015967,2014064,2016280,2016281,2016282,2016283,2022055,2014586,2014169)
