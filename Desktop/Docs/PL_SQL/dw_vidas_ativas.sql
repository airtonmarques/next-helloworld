/*
select 'update TS_DW.VIDAS_ATIVAS set valor_comercial = (select sys_get_vlr_cont_fe_fnc(2, '
       || va.cod_ts_contrato || ', ''' || va.cod_plano || ''', ''' || va.tipo_associado || ''', ' ||
       'SYS_GET_IDADE_FNC(''' || va.data_nascimento || ''', to_date(''31/07/2020'', ''dd/mm/yyyy'')), 
       to_date(''31/07/2020'', ''dd/mm/yyyy'')) from dual) where cod_ts = ' || va.cod_ts || ';'
from TS_DW.VIDAS_ATIVAS va
*/

select 'update TS_DW.VIDAS_ATIVAS set valor_net = (select sys_get_vlr_cont_fe_fnc(1, '
       || va.cod_ts_contrato || ', ''' || va.cod_plano || ''', ''' || va.tipo_associado || ''', ' ||
       'SYS_GET_IDADE_FNC(''' || va.data_nascimento || ''', to_date(''31/07/2020'', ''dd/mm/yyyy'')), 
       to_date(''31/07/2020'', ''dd/mm/yyyy'')) from dual) where cod_ts = ' || va.cod_ts || ';'
from TS_DW.VIDAS_ATIVAS va
