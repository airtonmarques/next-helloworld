--------
--Envio das informa��es quando uma proposta sair do Venda online para o Allsys
--------

idAlltech   int; --ID interno do sistema Allcare
prop        string; --N�mero da Proposta
totVidas    int; --Total de Vidas por proposta
numCpf      int; --N�mero do CPF
nome        string; --Nome
dtNasc      date; --Data de Nascimento
idade       int; --Idade
sexo        string; --Sexo
oper        string; --Nome da Operadora
plano       string; --Nome do Plano M�dico
prof        string; --Profiss�o
entidade    string --Entidade
email       string; --Email
dddTel      int; --DDD do Telefone
numTel      int; --N�mero do Telefone
estCivil    int; --Estado Civil (1 - Solteiro; 2 - Casado; 3 - Vi�vo; 4 - Separado; 5 - Divorciado; 6 - Outros; 7 - Eni�o Est�vel)
redCaren    string; --Grupo de Redu��o de Car�ncia
nomeResp    string; --Nome do Respns�vel
numCpfResp  int; --N�mero do CPF do Respons�vel
dtNascResp  date; --Data de Nascimento do Respons�vel
idadeResp   int; --Idade do Respons�vel
grauParResp int; --Grau de Parentesco do Respons�vel (1 - Titular; 2 - Pai/M�e; 3 - C�njuge; 4 - Filho(a); 5 - Irm�/Irm�o; 6 - Neto(a); 7 - Agregado; 8 - Outros; 9 - Sobrinho(a); 10 - Patrocinador)
grauPar     int; --Grau de Parentesco (1 - Titular; 2 - Pai/M�e; 3 - C�njuge; 4 - Filho(a); 5 - Irm�/Irm�o; 6 - Neto(a); 7 - Agregado; 8 - Outros; 9 - Sobrinho(a); 10 - Patrocinador)
dtVig       date; --Vig�ncia da Proposta
equipeVend  string; --Equipe/Canal de Vendas
hasProp     boolean; --Teve propostas anteriormente?
hasCPFRest  boolean; --CPF Restrito?
nomTit      string; --Nome do Titular (para casos de Movimenta��o)

-----------------------------------------------------------------------------------
--------
--Depois que a carteirinha for implantada no Allsys
--------

idAlltech   int; --ID interno do sistema Allcare
prop        string; --N�mero da Proposta
numCpf      int; --N�mero do CPF
idCart      string; --Carteirinha
hasRet      boolean; --Teve Retifica��o?
numCont     string; --Numero do Contrato Allsys (string pois h� zeros � esquerda)
numContOper string; --Numero do Contrato Operadora (string pois h� zeros � esquerda)
numMesReaj  int; --M�s de Reajuste do Contrato
