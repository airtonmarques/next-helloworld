//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
 
#Define STR_PULA    Chr(13)+Chr(10)
 
/*/{Protheus.doc} ALLRPC02
Relatorio Suprimentos
/*/
 
User Function ALLRPC02()

    Local cPerg       := "ALLRPC0201"
    Local nRecs       := 0
 
    If Pergunte(cPerg, .T.)
        MsgRun("Consultando Informacoes...","Aguarde",{|| nRecs := fQuery() })
        Processa({|| fGeraExcel(nRecs) })
    Endif    

Return

/*
 query para consulta das informacoes
*/
Static Function fQuery()
Local nRecs := 0
Local cQuery:=""

    cQuery := ""
    cQuery += " SELECT " + STR_PULA
    cQuery += " SUBSTR(SC7.C7_EMISSAO,5,2) AS MES," + STR_PULA
    cQuery += " SC7.C7_NUMSC," + STR_PULA
    cQuery += " SC1.C1_EMISSAO," + STR_PULA
    cQuery += " SCR1.CR_EMISSAO AS ENVIOAPROV," + STR_PULA
    cQuery += " SCR1.CR_DATALIB  AS DATALIB," + STR_PULA
    cQuery += " SUBSTR(SC7.C7_EMISSAO,1,4) AS ANO," + STR_PULA
    cQuery += " SY1.Y1_NOME," + STR_PULA
    cQuery += " SC1.C1_SOLICIT," + STR_PULA
    cQuery += " SC7.C7_PRODUTO," + STR_PULA
    cQuery += " SC7.C7_DESCRI," + STR_PULA
    cQuery += " SC7.C7_FORNECE," + STR_PULA
    cQuery += " SA2.A2_NOME," + STR_PULA
    cQuery += " SC7.C7_TOTAL," + STR_PULA
    cQuery += " SC7.C7_NUM," + STR_PULA
    cQuery += " SCR1.STATUS " + STR_PULA
    cQuery += " FROM "+RetSqlName("SC7")+" SC7 " + STR_PULA
    cQuery += " LEFT JOIN (" + STR_PULA
    cQuery += " SELECT " + STR_PULA
    cQuery += " SCR.CR_FILIAL," + STR_PULA
    cQuery += " SCR.CR_NUM," + STR_PULA
    cQuery += " SCR.CR_EMISSAO," + STR_PULA
    cQuery += " SCR.CR_DATALIB," + STR_PULA
    cQuery += " SCR.CR_APROV," + STR_PULA
    cQuery += " CASE SCR.CR_STATUS " + STR_PULA
    cQuery += " WHEN '01' THEN 'Aguardando nivel anterior' " + STR_PULA
    cQuery += " WHEN '02' THEN 'Pendente' " + STR_PULA
    cQuery += " WHEN '03' THEN 'Liberado' " + STR_PULA
    cQuery += " WHEN '04' THEN 'Bloqueado' " + STR_PULA
    cQuery += " WHEN '05' THEN 'Liberado outro aprov.' " + STR_PULA
    cQuery += " WHEN '06' THEN 'Rejeitado' " + STR_PULA
    cQuery += " WHEN '07' THEN 'Rej/Bloq outro aprov' " + STR_PULA
    cQuery += " END AS STATUS " + STR_PULA
    cQuery += " FROM "+RetSqlName("SCR")+" SCR " + STR_PULA
    cQuery += " WHERE  " + STR_PULA
    cQuery += " SCR.CR_TIPO IN ('PC','IP')" + STR_PULA
    cQuery += " AND SCR.D_E_L_E_T_ = ' ' " + STR_PULA
    cQuery += " GROUP BY SCR.CR_FILIAL, SCR.CR_NUM, SCR.CR_EMISSAO, SCR.CR_DATALIB, SCR.CR_APROV, SCR.CR_STATUS )  " + STR_PULA
    cQuery += " SCR1 ON SC7.C7_FILIAL = SCR1.CR_FILIAL AND SC7.C7_NUM = SCR1.CR_NUM " + STR_PULA
    cQuery += " INNER JOIN "+RetSqlName("SC1")+" SC1 ON SC7.C7_FILIAL = SC1.C1_FILIAL AND SC7.C7_NUMSC = SC1.C1_NUM AND SC7.C7_ITEMSC = SC1.C1_ITEM " + STR_PULA
    cQuery += " INNER JOIN "+RetSqlName("SY1")+" SY1 ON SC7.C7_USER = SY1.Y1_USER " + STR_PULA
    cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 ON SC7.C7_FORNECE = SA2.A2_COD AND SC7.C7_LOJA = SA2.A2_LOJA " + STR_PULA
    cQuery += " WHERE  " + STR_PULA
    cQuery += " SC1.C1_FILIAL       >= '"+MV_PAR01+"'"          + STR_PULA
    cQuery += " AND SC1.C1_FILIAL   <= '"+MV_PAR02+"'"          + STR_PULA
    cQuery += " AND SY1.Y1_USER     >= '"+MV_PAR03+"'"          + STR_PULA
    cQuery += " AND SY1.Y1_USER     <= '"+MV_PAR04+"'"          + STR_PULA
    cQuery += " AND SC1.C1_EMISSAO  >= '"+dTos(MV_PAR05)+"'"    + STR_PULA
    cQuery += " AND SC1.C1_EMISSAO  <= '"+dTos(MV_PAR06)+"'"    + STR_PULA
    cQuery += " AND SC7.D_E_L_E_T_ = ' ' AND SC1.D_E_L_E_T_ = ' ' AND SY1.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' '  " + STR_PULA
    cQuery += " ORDER BY  SC1.C1_FILIAL, SC1.C1_NUM, SC1.C1_ITEM, SCR1.CR_APROV " + STR_PULA
   
    cQuery := changequery(cQuery) 

    TCQuery cQuery New Alias "QRYPRO"

    QRYPRO->(dbGotop())

    Count To nRecs
    
Return nRecs

/*
  Funcao para gerar o Excel
*/
Static Function fGeraExcel(nRecs)

    Local aArea        := GetArea()
    Local oFWMsExcel
    Local oExcel
    Local cArquivo    := GetTempPath()+'zTstExc1.xml'

    ProcRegua(nRecs)
        
    oFWMsExcel := FWMSExcel():New()
    oFWMsExcel:AddworkSheet("Aba Solicitacao/Pedido") //Não utilizar número junto com sinal de menos. Ex.: 1-
    oFWMsExcel:AddTable("Aba Solicitacao/Pedido","Tabela de Informacoes de Compras")
    oFWMsExcel:AddColumn("Aba Solicitacao/Pedido","Tabela de Informacoes de Compras","MES",1,1)  //1 = Modo Texto
    oFWMsExcel:AddColumn("Aba Solicitacao/Pedido","Tabela de Informacoes de Compras","SOLICITACAO",1,1)  //1 = Modo Texto
    oFWMsExcel:AddColumn("Aba Solicitacao/Pedido","Tabela de Informacoes de Compras","INSERCAO_DA_SOLICITACAO",1)  
    oFWMsExcel:AddColumn("Aba Solicitacao/Pedido","Tabela de Informacoes de Compras","ENVIO_DO_PEDIDO_APROVACAO",1)  
    oFWMsExcel:AddColumn("Aba Solicitacao/Pedido","Tabela de Informacoes de Compras","DATA_LIBERACAO_PEDIDO",1)  
    oFWMsExcel:AddColumn("Aba Solicitacao/Pedido","Tabela de Informacoes de Compras","ANO",1,1)  //1 = Modo Texto
    oFWMsExcel:AddColumn("Aba Solicitacao/Pedido","Tabela de Informacoes de Compras","COMPRADOR",1,1)  //1 = Modo Texto
    oFWMsExcel:AddColumn("Aba Solicitacao/Pedido","Tabela de Informacoes de Compras","SOLICITANTE",1,1)  //1 = Modo Texto
    oFWMsExcel:AddColumn("Aba Solicitacao/Pedido","Tabela de Informacoes de Compras","PRODUTO",1,1)  //1 = Modo Texto
    oFWMsExcel:AddColumn("Aba Solicitacao/Pedido","Tabela de Informacoes de Compras","FORNECEDOR",1,1) //1 = Modo Texto
    oFWMsExcel:AddColumn("Aba Solicitacao/Pedido","Tabela de Informacoes de Compras","VALOR_TOTAL_DO_ITEM_NO_PEDIDO",3,3) //1 = Modo Valor Com R$
    oFWMsExcel:AddColumn("Aba Solicitacao/Pedido","Tabela de Informacoes de Compras","NUMERO_PEDIDO",1,1) //1 = Modo Texto
    oFWMsExcel:AddColumn("Aba Solicitacao/Pedido","Tabela de Informacoes de Compras","STATUS",1,1) //1 = Modo Texto

        //Criando as Linhas... Enquanto não for fim da query\
        QRYPRO->(dbGotop())
        While !(QRYPRO->(EoF()))
            
            IncProc("Gerando Planilha Excel, aguarde...")

            oFWMsExcel:AddRow("Aba Solicitacao/Pedido","Tabela de Informacoes de Compras",{;
                                                                    QRYPRO->MES               ,;
                                                                    QRYPRO->C7_NUMSC          ,;
                                                                    STOD(QRYPRO->C1_EMISSAO)  ,; //20220531
                                                                    STOD(QRYPRO->ENVIOAPROV)  ,;
                                                                    STOD(QRYPRO->DATALIB)     ,;
                                                                    QRYPRO->ANO               ,;
                                                                    Upper(QRYPRO->Y1_NOME)    ,;
                                                                    QRYPRO->C1_SOLICIT  ,;
                                                                    Alltrim(QRYPRO->C7_PRODUTO) +'-' + Alltrim(QRYPRO->C7_DESCRI),;
                                                                    QRYPRO->C7_FORNECE+'-'+QRYPRO->A2_NOME,;
                                                                    QRYPRO->C7_TOTAL,;
                                                                    QRYPRO->C7_NUM,;
                                                                    QRYPRO->STATUS })

            //Pulando Registro
            QRYPRO->(DbSkip())
        EndDo
     
    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()              //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)        //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()                       //Encerra o processo do gerenciador de tarefas
     
    QRYPRO->(DbCloseArea())
    RestArea(aArea)

Return    
