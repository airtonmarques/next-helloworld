#Include "Protheus.ch"
#Include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ACRENVWF    บAutor  ณMarcus Ferraz    บ Data ณ  28/07/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Rotina para reenviar worklofw de compras nใo aprovados    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Allcare                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                               	
User Function ACRENVWF()

Local cQuery     := ""
Local aPedido    := {}
Local cQryApv    := ""
Local _cStatus   := ""  
Local aAprvAnt   := {}
Local eMail      := ""
Local aSolic     := {}      
Local _lRejeit   := .F.    
Local _cSc       := ""
Local _lEnvia    := .F.
Local cEmp 	     := ""
Local cFil 	     := ""
Local cEmaiAudit := ""
Local aFilial    := {"0101","0102","0105","0201"}
               
Private _lReenvio := .T. //Variavel importante utilizada no fonte WFW120P()

For _nEmp := 1 To Len(aFilial)

	cEmp := Substr(aFilial[_nEmp],1,2)
	cFil := Substr(aFilial[_nEmp],3,2)
	
	aPedido := {}
	                          
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,"COM",,)
	FreeUsedCode()
	
	//Email para auditoria                  
	cEmaiAudit := GetNewPar("MV_XEMAIAD","marcus.ferraz@dfssistemas.com.br")      
	
	//Filtra os pedidos pendentes de aprova็ใo.
	cQuery := " SELECT DISTINCT CR_TIPO, CR_NUM, CR_NIVEL FROM "+RetSqlName("SCR")+" 
	cQuery += " WHERE CR_DATALIB = '' "
	cQuery += " AND D_E_L_E_T_ <> '*'  "
	cQuery += " AND CR_STATUS = '02' "
	cQuery += " AND CR_WF = 'S' "    
	cQuery += " AND CR_FILIAL = '"+xFilial("SCR")+"' "
	
	ChangeQuery(cQryApv)
	
	If Select("TSQL") > 0
		TSQL->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "TSQL",.T.,.T.)
	
	dbSelectArea("TSQL")               
	TSQL->(dbGotop())
	
	While TSQL->(!Eof())
	    
	    _lEnvia := .T.
	    
	    dbSelectArea("SCR")
	    dbSetOrder(1)
	    If MsSeek(xFilial("SCR")+TSQL->CR_TIPO+TSQL->CR_NUM+TSQL->CR_NIVEL)
	    	While SCR->(!Eof()) .And. SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL) ==;
	    								xFilial("SCR")+TSQL->CR_TIPO+TSQL->CR_NUM+TSQL->CR_NIVEL
				
				//Verifica se existe alguma rejeicao no nivel, se existir nใo envia workflow    								
				If SCR->CR_STATUS == "04"
				    _lEnvia := .F.
				    Exit
				EndIf
	    	
	    		SCR->(dbSkip())
	    	EndDo
	    EndIf
		
		//Funcao para fazer o reenvio do workflow de compras            
		If _lEnvia	
			dbSelectArea("SC7")
			dbSetOrder(1)
		
			If MsSeek(xFilial("SC7")+PADR( TSQL->CR_NUM, TamSx3("C7_NUM")[1] ))
				AADD(aPedido, SC7->C7_NUM)		
				u_WFW120P()
			EndIf
		EndIf
	
		TSQL->(dbSkip())
	EndDo
	
	//Envia e-mail de status para os aprovadores
	If Len(aPedido) > 0
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณBusca os usuarios solicitantes da SC7ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nX := 1 To Len(aPedido)
		                   
			aSolic 		:= {}
			_cSc   		:= "" 
			aAprvAnt 	:= {}   
			cNumPed     := aPedido[nX]
				
			dbSelectArea("SC7")
			dbSetOrder(1)
			MsSeek(xFilial("SC7")+cNumPed)	
		
			While SC7->(!Eof()) .And. xFilial("SC7")+cNumPed == SC7->C7_FILIAL+SC7->C7_NUM
				
				If !Empty(SC7->C7_NUMSC)
					
					_cSc += SC7->C7_NUMSC + " / "
				
					dbSelectArea("SC1")
					dbSetOrder(1)
					If MsSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC)
						If Ascan( aSolic, SC1->C1_USER ) == 0    
							AADD(aSolic, SC1->C1_USER)
						EndIf
					EndIf
				EndIf
				SC7->(dbSkip())
			EndDo
			                  		     
			//Busca informa็๕es dos aprovadores anteriores
			cQryApv := " SELECT CR_APROV, CR_STATUS, CR_DATALIB, CR_USER, R_E_C_N_O_  AS RECSCR "
			cQryApv += " FROM "+RetSqlName("SCR")+"  "
			cQryApv += " WHERE CR_NUM = '"+aPedido[nX]+"' "
			cQryApv += " AND CR_FILIAL = '"+xFilial("SCR")+"' "
			cQryApv += " AND CR_STATUS = '02' "
			cQryApv += " AND CR_WF = 'S' "
			cQryApv += " AND D_E_L_E_T_ <> '*' "
			
			ChangeQuery(cQryApv)
			
			If Select("TAPV") > 0
				TAPV->(dbCloseArea())
			EndIf
				
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryApv), "TAPV",.T.,.T.)
			        
			dbSelectArea("TAPV")
			TAPV->(dbGotop())
			
			While TAPV->(!Eof())   
			
				//Ajustado para versใo 12 - 07/08/2017 
				dbSelectArea("SCR")
				SCR->(dbGoto( TAPV->RECSCR ))		   	    
			   	            
				Do Case
					Case TAPV->CR_STATUS == "01"                                                
					   	_cStatus := "Bloqueado p/ sistema"
					Case TAPV->CR_STATUS == "02"                                                
					   	_cStatus := "Aguardando Liberacao do usuario"
					Case TAPV->CR_STATUS == "03"                                                
					   	_cStatus := "Pedido Liberado"
					Case TAPV->CR_STATUS == "04"
					   	_cStatus := "Pedido Bloqueado pelo usuario"
					   	_lRejeit := .T.
					Case TAPV->CR_STATUS == "05"
					   	_cStatus := "Nivel Liberado por outro usuario"
				End Case
				
				DBSelectArea("SAK")
				DBSetOrder(2)
				DBSeek(xFilial("SAK")+TAPV->CR_USER)
									
				AADD( aAprvAnt, {SAK->AK_NOME, Alltrim(_cStatus), SCR->CR_OBS, DTOC(STOD(TAPV->CR_DATALIB)), TAPV->CR_USER } )		   			     
				
				dbSelectArea("TAPV")
				TAPV->(dbSkip())
			
			EndDo             
			
			//Funcao que da o Start no Workflow
			oProcess := TWFProcess():New( "PEDCOM2", "WF de Aprova็ใo de Pedido de Compras" )
			//Funcao que busca o Modelo do HTML
			oProcess:NewTask( "000001", "\workflow\PEDCOM2.htm" )
			//Subject do Email
			oProcess:cSubject := "Reenvio do Pedido de Compras "+cNumPed + " - " + ALLTRIM( FWFilName ( fwCodEmp() , xFilial("SC7")  ) )
			
			oProcess:fDesc := "Pedido de Compras No "+cNumPed
			
			oHTML := oProcess:oHTML
			
			If !Empty(_cSc)
				oHTML:ValByName('CNUMPED'," REENVIO DO PEDIDO DE COMPRA " + cNumPed + SPACE(06)+ "  - SCs: " + _cSc + " - " + Alltrim(FWFilialName()) )
			Else
				oHTML:ValByName('CNUMPED'," REENVIO DO PEDIDO DE COMPRA " + cNumPed  + " - " + Alltrim(FWFilialName()) )
			EndIf
	  		
	  		//Monta Tag do HTML      
			For nApv := 1 To Len(aAprvAnt)
				aadd((oHtml:ValByName( 'CR.USER' )),aAprvAnt[nApv][1])
				aadd((oHtml:ValByName( 'CR.STATUS' )),aAprvAnt[nApv][2])
				aadd((oHtml:ValByName( 'CR.OBS' )),aAprvAnt[nApv][3])
				aadd((oHtml:ValByName( 'CR.DATALIB' )),aAprvAnt[nApv][4])	
			next nApv
	
			_lFirst := .T.   // Primeiro e-mail???
			
			dbSelectArea("SC7")
			dbSetOrder(1)
			MsSeek(xFilial("SC7")+cNumPed)
			
			_xEmail := Alltrim(USRRETMAIL(SC7->C7_USER))
			
			eMail  := ""
			
			If AT(_xEmail,eMail) == 0   // Se jแ existir o e-mail na lista nใo hแ necessidade de acrescentar novamente
				eMail += Iif(_lFirst,_xEmail,";" + _xEmail)
				_lFirst := .F.
			EndIf
			
			//Adiciona e-mail do solicitante 
			If Len(aSolic) > 0
				For _nSol := 1 To Len(aSolic)
					If !Empty(aSolic[_nSol])
						_xEmail := Alltrim(USRRETMAIL(aSolic[_nSol]))
						If AT(_xEmail,eMail) == 0   // Se jแ existir o e-mail na lista nใo hแ necessidade de acrescentar novamente
							eMail += Iif(_lFirst,_xEmail,";" + _xEmail)
							_lFirst := .F.
						EndIf
					EndIf			
				Next _nSol	
			EndIf
			                       
			//Utilizado para auditoria - 20/05/2016
			If !Empty(cEmaiAudit) 
				eMail += ";"+cEmaiAudit
			EndIf
			
			//eMail := "marcus.ferraz@dfssistemas.com.br"
				
			oProcess:cTo := eMail
			oProcess:Start()
	    
		Next 
	
	EndIf
	
	RpcClearEnv()
	
Next
	
Return