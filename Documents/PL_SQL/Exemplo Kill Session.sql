--Exemplo Kill Session 

select  'alter system kill session ''' 

         || s.sid 

         || ',' 

         || s.SERIAL# 

         || ',@' 

         || s.inst_id 

         || ''';' script, s.* from gv$session s 

         where s.sid = 5290
				 --osuser = 'claudio.mattei'
