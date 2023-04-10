------------
--**
-- HOTMAIL.COM.BR
--**
------------
update ts.beneficiario_contato bc
set bc.end_email = replace(lower(bc.end_email),
                           'hotmail.com.br',
                           'hotmail.com')
where lower(bc.end_email) like '%hotmail.com.br'; 
commit;

------------
--**
-- GMAI.COM
--**
------------

update ts.beneficiario_contato bc
set bc.end_email = replace(lower(bc.end_email),
                           'gmai.com',
                           'gmail.com')
where lower(bc.end_email) like '%gmai.com';  
commit;

------------
--**
-- GMAI.COM.BR
--**
------------
update ts.beneficiario_contato bc
set bc.end_email = replace(lower(bc.end_email), 
                           'gmai.com.br',
                           'gmail.com.')
where lower(bc.end_email) like '%gmai.com.br';
commit;

------------
--**
-- GMAIL.COM.BR
--** 
------------
update ts.beneficiario_contato bc
set bc.end_email = replace(lower(bc.end_email),
                           'gmail.com.br',
                           'gmail.com')
where lower(bc.end_email) like '%gmail.com.br';
commit;

------------   
--**
-- .BR.BR 
--** 
------------
update ts.beneficiario_contato bc
set bc.end_email = replace(lower(bc.end_email),
                           '.br.br',
                           '.br')
where lower(bc.end_email) like '%.br.br'; 
commit;

------------ 
--** 
-- .com.com
--**
------------
update ts.beneficiario_contato bc
set bc.end_email = replace(lower(bc.end_email),
                           '.com.com',
                           '.com')
where lower(bc.end_email) like '%.com.com%';   
commit;

------------
--**
-- GAMIL.COM.BR
--**
------------
update ts.beneficiario_contato bc
set bc.end_email = replace(lower(bc.end_email),
                           'gamil.com.br',
                           'gmail.com')
where lower(bc.end_email) like '%gamil.com.br';
commit;

------------
--**
-- GAMIL.COM
--**
------------
update ts.beneficiario_contato bc
set bc.end_email = replace(lower(bc.end_email),
                           'gamil.com',
                           'gmail.com')
where lower(bc.end_email) like '%gamil.com'; 
commit;

------------
--**
-- Tirar todo o texto apÛs o ponto e virgula;
--**
------------
update ts.beneficiario_contato bc
set bc.end_email = substr(bc.end_email, 1, instr(bc.end_email, ';') -1)
where lower(bc.end_email) like '%;%'; 
commit;


------------
--**
-- Tirar todo o texto apÛs a virgula;
--**
------------
update ts.beneficiario_contato bc
set bc.end_email = substr(bc.end_email, 1, instr(bc.end_email, ',') -1)
where lower(bc.end_email) like '%,%'; 
commit;


------------
--**
-- Tirar todo o texto apÛs a barra;
--**
------------
update ts.beneficiario_contato bc
set bc.end_email = substr(bc.end_email, 1, instr(bc.end_email, ',') -1)
where lower(bc.end_email) like '%/%'; 
commit;

------------
--**
-- Tirar todo o texto apÛs a barra;
--**
------------
update ts.beneficiario_contato bc
set bc.end_email = substr(bc.end_email, 1, instr(bc.end_email, ',') -1)
where lower(bc.end_email) like '%\%'; 
commit;

------------
--**
-- Tirar todo o texto apÛs @.;
--**
------------
update ts.beneficiario_contato bc
set bc.end_email = replace(lower(bc.end_email),
                           '@.',
                           '@')
where lower(bc.end_email) like '%@.%'; 
commit;

------------
--**
-- Tirar todo o texto iniciado com @.;
--**
------------
update ts.beneficiario_contato bc
set bc.end_email = replace(lower(bc.end_email),
                           '@',
                           '')
where lower(bc.end_email) like '@%'; 
commit;

update ts.beneficiario_contato bc
set bc.end_email = replace(lower(bc.end_email),
                           'ø',
                           '')
where lower(bc.end_email) like 'ø%';
commit;
---------------------------------

update ts.beneficiario_contato bc
set bc.end_email = replace(lower(bc.end_email),
                           '°',
                           '')
where lower(bc.end_email) like '°%';
commit;

update ts.beneficiario_contato bc
set bc.end_email = substr(bc.end_email, 1, instr(bc.end_email, ';') -1)
where lower(bc.end_email) like '%;%';
commit;
------------
--**
-- Tirar todo o texto iniciado com @.;
--**
------------
/*select *
from ts.beneficiario_contato bc
where lower(bc.end_email) like '%udipsr@outlook.com%' for update; 
commit;
*/
--------------------------
/*update ts.beneficiario_contato bc
  set bc.end_email = translate(bc.end_email,
                         '¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸',
                         'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu')   
where bc.end_email is not null;
commit;*/
 
------------
--**
-- Deletar com @com.
--**
------------
--delete ts.beneficiario_contato bc
--where lower(bc.end_email) like '%@com.%'

/*
UPDATE TS.beneficiario_entidade be
set be.ind_sexo = 'M'
where be.Nome_Entidade LIKE --'%MURILO%' --'%DANIELA%'--'%PRISCILLA%'--'%PRISCILA%'--'%NATALIA%'
--'%TALITA%'--'%THALITA%'--'%AMANDA%'--'%JAQUELINE%'--'%PATRICIA%'--'%BARBARA%'
--'%CAMILLA%'--'%CAMILA%' --'%NADIA%'--'%CYNTIA%'--'%NAZARE%'--'%ALESSANDRA%'
--'%DANIELY%'--'%DANIELE%'--'%DANIELLE%'--'%DANIELLY%'--'%DANIELA%'--'%LIVIA%'--'%BRUNA%'
      and be.ind_sexo = 'F'
--105897  
*/
