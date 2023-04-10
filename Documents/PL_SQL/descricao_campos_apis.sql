--------
--Envio das informações quando uma proposta sair do Venda online para o Allsys
--------

idAlltech   int; --ID interno do sistema Allcare
prop        string; --Número da Proposta
totVidas    int; --Total de Vidas por proposta
numCpf      int; --Número do CPF
nome        string; --Nome
dtNasc      date; --Data de Nascimento
idade       int; --Idade
sexo        string; --Sexo
oper        string; --Nome da Operadora
plano       string; --Nome do Plano Médico
prof        string; --Profissão
entidade    string --Entidade
email       string; --Email
dddTel      int; --DDD do Telefone
numTel      int; --Número do Telefone
estCivil    int; --Estado Civil (1 - Solteiro; 2 - Casado; 3 - Viúvo; 4 - Separado; 5 - Divorciado; 6 - Outros; 7 - Enião Estável)
redCaren    string; --Grupo de Redução de Carência
nomeResp    string; --Nome do Respnsável
numCpfResp  int; --Número do CPF do Responsável
dtNascResp  date; --Data de Nascimento do Responsável
idadeResp   int; --Idade do Responsável
grauParResp int; --Grau de Parentesco do Responsável (1 - Titular; 2 - Pai/Mãe; 3 - Cônjuge; 4 - Filho(a); 5 - Irmã/Irmão; 6 - Neto(a); 7 - Agregado; 8 - Outros; 9 - Sobrinho(a); 10 - Patrocinador)
grauPar     int; --Grau de Parentesco (1 - Titular; 2 - Pai/Mãe; 3 - Cônjuge; 4 - Filho(a); 5 - Irmã/Irmão; 6 - Neto(a); 7 - Agregado; 8 - Outros; 9 - Sobrinho(a); 10 - Patrocinador)
dtVig       date; --Vigência da Proposta
equipeVend  string; --Equipe/Canal de Vendas
hasProp     boolean; --Teve propostas anteriormente?
hasCPFRest  boolean; --CPF Restrito?
nomTit      string; --Nome do Titular (para casos de Movimentação)

-----------------------------------------------------------------------------------
--------
--Depois que a carteirinha for implantada no Allsys
--------

idAlltech   int; --ID interno do sistema Allcare
prop        string; --Número da Proposta
numCpf      int; --Número do CPF
idCart      string; --Carteirinha
hasRet      boolean; --Teve Retificação?
numCont     string; --Numero do Contrato Allsys (string pois há zeros à esquerda)
numContOper string; --Numero do Contrato Operadora (string pois há zeros à esquerda)
numMesReaj  int; --Mês de Reajuste do Contrato
