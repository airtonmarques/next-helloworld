(select 'C�d. Contrato;N�mero Do Contrato;Nome Contrato;C�digo Na Operadora;Qtde Downloads;Operadora;In�cio Contrato;Fim Contrato;Download Rob�'
from dual)
union all
(select c.cod_cont || ';' ||
       c.num_cont || ';' ||
       c.nome_cont || ';' ||
       c.cod_cont_for || ';' ||
       (select count(1)
          from alt_fin@altprod f
         where f.cod_tipo_cad_clifor = c.cod_tipo_cad_for
           and f.cod_cad_clifor = c.cod_cad_for
           and f.num_doc_fin = sys_get_number_fnc@altprod(c.cod_cont_for)) || ';' ||
       alt_get_fant_cad_fnc@altprod(2, c.cod_cad_for) || ';' ||
       to_char(c.dt_ini_cont, 'dd/mm/yyyy') || ';' ||
       to_char(c.dt_fim_cont, 'dd/mm/yyyy') || ';' ||
       decode(c.chk_down_robo_cont, -1, 'Sim', 0, 'N�o')
			 
  from alt_cont@altprod c
where c.cod_cad_for IN (1, 3, 4, 5, 7, 11, 17, 54, 70, 97, 134, 231, 237)	--Operadoras espec�ficas
      and c.chk_down_robo_cont = -1 -- Downloads 'SIM'
			and INSTR(c.cod_cont_for, '_') = 0 --Codigo do Contrato/Operadora sem o caractere _
			) 
 
