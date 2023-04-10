--Criar acl para APIs
BEGIN
  DBMS_NETWORK_ACL_ADMIN.create_acl (
    acl          => 'acl_api_prod.xml', 
    description  => 'ACL xml para conectar a API',
    principal    => 'ALT_PRODUCAO',
    is_grant     => TRUE, 
    privilege    => 'connect',
    start_date   => SYSTIMESTAMP,
    end_date     => NULL);

  COMMIT;
END;
/

--Grant para acessar o acl
BEGIN
    DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(
        acl         => 'acl_api.xml',
        principal   => 'ALT_DESENVOLVIMENTO',
        is_grant    =>  TRUE,
        privilege   => 'resolve');
        
    DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (
        acl => 'acl_api.xml',
        principal => 'ALT_DESENVOLVIMENTO',
        is_grant => TRUE,
        privilege => 'use-client-certificates');
        
    DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (
        acl => 'acl_api.xml',
        principal => 'ALT_DESENVOLVIMENTO',
        is_grant => TRUE,
        privilege => 'connect');
  COMMIT;
END;

--Vincular ACL criado com a Wallet de certificados
BEGIN
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_WALLET_ACL(
    acl         => 'acl_api_prod.xml', 
    wallet_path => 'file:/u01/app/oracle/admin/ALTPD/wallet');
    COMMIT;
END;

--Atribuir dominio ao ACL
BEGIN
  DBMS_NETWORK_ACL_ADMIN.assign_acl (
    acl         => 'acl_api.xml',
    host        => '*.rd.services', 
    lower_port  => NULL,
    upper_port  => NULL);
  COMMIT;
END;
/

--Remover dominio do ACL
BEGIN
  DBMS_NETWORK_ACL_ADMIN.unassign_acl (
    acl         => 'acl_api.xml',
    host        => '*apialltech.allcare.com.br*', 
    lower_port  => 1,
    upper_port  => 9090); 

  COMMIT;
END;
/

--exportar em excel
SELECT *
FROM   dba_network_acls;

SELECT *
FROM   dba_network_acl_privileges;


SELECT DECODE(
         DBMS_NETWORK_ACL_ADMIN.check_privilege('acl_api.xml', 'ALT_DESENVOLVIMENTO', 'connect'),
         1, 'GRANTED', 0, 'DENIED', NULL) privilege 
FROM dual;

SELECT DECODE(
         DBMS_NETWORK_ACL_ADMIN.check_privilege('acl_api.xml', 'ALT_DESENVOLVIMENTO', 'use-client-certificates'),
         1, 'GRANTED', 0, 'DENIED', NULL) privilege 
FROM dual;

SELECT DECODE(
         DBMS_NETWORK_ACL_ADMIN.check_privilege('acl_api.xml', 'ALT_DESENVOLVIMENTO', 'resolve'),
         1, 'GRANTED', 0, 'DENIED', NULL) privilege 
FROM dual;
