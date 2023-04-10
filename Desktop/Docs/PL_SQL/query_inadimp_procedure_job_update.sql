select 'update alt_inadimplentes a set a.telefone_contato = ''' || 
        SYS_GET_TEL_FNC(b.cod_entidade_ts_tit, 'C') || '''' ||
        ', a.telefone_cobranca = ''' || SYS_GET_TEL_FNC(b.cod_entidade_ts_tit, 'B') || '''' ||
        ', a.email = ''' || ts_consulta.all_get_mail_fnc(b.cod_entidade_ts_tit) || ''
        || ''' where a.cod_ts = ' || a.cod_ts || ';' --count(1)302.534
from alt_inadimplentes a
     join ts.beneficiario b on b.cod_ts = a.cod_ts
