select a.*
from
(select 'idcont' || ',' || 
       'idcontparent' || ',' || 
       'idtitulo' || ',' || 
       'idcad' || ',' ||
       'accountid' || ',' ||
       'contactid' || ',' || 
       'servicecontractid' || ',' ||
       'parentservicecontractid' || ',' || 
       'cnpj_cpf' || ',' || 
       'nomecad' || ',' || 
       'operadora' || ',' || 
       'entidade' || ',' || 
       'numproposta' || ',' || 
       'dtVencTitulo' || ',' || 
       'diasAtraso'  || ',' ||
       'porte' || ',' || 
       'vlrmensatraso' || ',' || 
       'qtdemensatraso' || ',' || 
       'celular1' || ',' || 
       'celular2' || ',' || 
       'celular3' || ',' || 
       'residencial1' || ',' || 
       'residencial2' || ',' || 
       'residencial3'  || ',' ||
       'pessoacobranca' || ',' || 
       'cod_ts_allsys'
from dual		 
union all
----------------------------------------------------------------
select idcont || ',' || 
       idcontparent || ',' || 
			 idtitulo || ',' || 
			 idcad || ',' ||
			 accountid || ',' ||
			 contactid || ',' || 
			 servicecontractid || ',' ||
			 parentservicecontractid || ',' || 
			 cnpj_cpf || ',' || 
			 nomecad || ',' || 
			 operadora || ',' || 
			 entidade || ',' || 
			 proposta || ',' || 
			 dt_vencimento || ',' || 
			 diasematraso  || ',' ||
			 porte || ',' || 
			 replace(vlrmensatraso, ',', '.') || ',' || 
			 qtsmensatraso || ',' || 
			 celular1 || ',' || 
			 celular2 || ',' || 
			 celular3 || ',' || 
			 residencial1 || ',' || 
			 residencial2 || ',' || 
			 residencial3  || ',' ||
			 pessoacobranca || ',' || 
			 cod_ts_allsys from alt_inadimp_genesys where cod_operadora_contrato = 1) a
