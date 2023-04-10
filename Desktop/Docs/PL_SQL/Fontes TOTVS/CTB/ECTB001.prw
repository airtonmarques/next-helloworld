#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |ECTB001   ºAutor  |DFS Sistemas        º Data ³  26.11.2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Leitura e Importação de lançamentos contábeis de Planilha  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ EMEDE                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
Estrutura do arquivo delimitado
[LINHA][TIPO][DEBITO][CREDITO][VALOR][CCD][CCC][ITEMD][ITEMC][CLVLDB][CLVLCR][ORIGEM][HP][HIST][DATA][LOTE][SUBLOTE][DOC]
*/
User Function ECTB001()

	Private aPergs 		:= {}
	Private aRet 		:= {}
	Private cDelimit 	:= ';'
	Private cArquivo	:= ""
	Private cTipSaldo	:= "1"
	
	aAdd( aPergs ,{6,"Arquivo            	: ",cArquivo ,"@!",'.T.','.T.',80,.T.,"Arquivos CSV (*.CSV) | *.CSV","C:\"})
	aAdd( aPergs ,{1,"Caracter Delimitador 	: ",cDelimit ,"@!",'.T.',,'.T.',10,.T.})
	aAdd( aPergs ,{1,"Tipo de Saldo 	: ",cTipSaldo,"@!",'.T.',"SLW",'.T.',10,.T.})
	
	If !ParamBox(aPergs ,"Parâmetros ",aRet)
		Return Nil
	EndIf
	
	cArquivo	:= aRet[1]
	cDelimit	:= aRet[2]
	cTipSaldo	:= aRet[3]
	
	If !File(cArquivo)
		MsgAlert("Arquivo não encontrado! Favor Informar um Arquivo *.CSV válido!","Arquivo não encontrado")
		Return Nil
	EndIf
	
	If MsgYesNo("Confirma a Importação do Arquivo?","Confirmação")
		ZTXCTB2()
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |ZTXCTB2  ºAutor  |DFS Sistemas        º Data ³  26.11.2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamada do processamento                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ EMEDE                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ZTXCTB2()

//	Private _cFile := ""
//	Private _xFile := ""
//	Private _cType := ""
	Private _nTot   := 0
	Private _aCt1	:= {}
		
	nHdl := fopen(cArquivo,0)
	_nTot:= fSeek(nHdl,0,2)
	fClose(nHdl)
    
	// VERIFICA CONTAS CONTABEIS
	DbSelectArea("CT1")
	CT1->(DbGoTop())
	While CT1->(!Eof())
		If CT1->CT1_CLASSE=="2"
			aAdd(_aCt1,CT1->CT1_CONTA)
		Endif
		CT1->(DbSkip())
	End
	
	If _nTot > 0
		Processa({||ZTXCTB3(),,"Importando registros. Aguarde..."})
	EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |ZTXCTB3  ºAutor  |DFS Sistemas        º Data ³  26.11.2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processamento do arquivo                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³EMEDE                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ZTXCTB3()

	Local _cBuffer		:= ""
	Local _cTexto		:= ""
	Local aLinha 		:= {}
	Local _nTamLote 	:= TamSx3("CT2_LOTE"  )[1]
	Local _nTamSLot 	:= TamSx3("CT2_SBLOTE")[1]
	Local _nTamDoc  	:= TamSx3("CT2_DOC"   )[1]
	Local _cDocAnt		:= ""
	Local _nTotLin		:= 1
	Local aDatas		:= {}
	Local nX			:= 0
	Local nSaldo		:= 0
	Local cLinha		:= ''
	Local lOK			:= .F.
	
	Private aItens		:= {}
	Private aRegistro 	:= {}
	Private aErro 		:= {}
	Private nTotLinha	:= 0
	Private lMSErroAuto	:= .F.
	
	FT_FUSE(cArquivo)
	nTotLinha := FT_FLASTREC()
	FT_FGOTOP()

	_cBuffer := FT_FREADLN()
	_nLinhatxt :=0
	_cLinha := "000"
	_cDocAnt:= ""
	
	ProcRegua(nTotLinha)
	While !FT_FEOF()
		IncProc("Lendo Arquivo de Importação")
		aLinha := {}
		StrTran(_cBuffer,";","; ")		
		If Len(_cBuffer) >0
			_cTexto	:= ""
			For nX 	:= 1 to Len(_cBuffer)
				If Substr(_cBuffer,nX,1) == cDelimit
					aAdd(aLinha, _cTexto )
					_cTexto := ""
				Else
					_cTexto += Substr(_cBuffer,nX,1)
				Endif
			Next nX
			If !Empty(_cTexto)
				aAdd(aLinha, _cTexto )
			Else
				aAdd(aLinha, " " )
			Endif
		Endif
		_nLinhatxt++
		If Len(aLinha) == 18 //Padrão definido para 18 Colunas.
			If _cDocAnt <> Substr(aLinha[04],1,_nTamDoc)
				_cLinha := "000"
			EndIf
			_cDocAnt := Substr(aLinha[04],1,_nTamDoc)
			_cLinha := Soma1(Alltrim(_cLinha))
			aLinha[05] := _cLinha
			If At(",",aLinha[09])==0
				_cValor := aLinha[09]
			Else
				_cValor := StrTran(aLinha[09],".","")
				_cValor := StrTran(_cValor,",",".")
			Endif
			aLinha[09]	:= Alltrim(_cValor)	
			_dData		:= Ctod(aLinha[01])
			_cLote    	:= Substr(aLinha[02],1,_nTamLote)
			_cSublote 	:= Substr(aLinha[03],1,_nTamSLot)
			_cDoc     	:= Substr(aLinha[04],1,_nTamDoc)
			_cTipo    	:= aLinha[06]
			_cDebito  	:= Padr(if(Alltrim(aLinha[07])="0","",Alltrim(aLinha[07])),TamSx3("CT2_DEBITO"   )[1])
			_cCredito 	:= Padr(if(Alltrim(aLinha[08])="0","",Alltrim(aLinha[08])),TamSx3("CT2_CREDIT"   )[1])
			_nValor   	:= Val(aLinha[09])
			_cHp      	:= aLinha[10]
			_cHist    	:= aLinha[11]
			_cCcd     	:= if(Alltrim(aLinha[12])="0","",Alltrim(aLinha[12]))
			_cCcc     	:= if(Alltrim(aLinha[13])="0","",Alltrim(aLinha[13]))
			_cItemd   	:= if(Alltrim(aLinha[14])="0","",Alltrim(aLinha[14]))
			_cItemc   	:= if(Alltrim(aLinha[15])="0","",Alltrim(aLinha[15]))
			_cClvldb  	:= if(Alltrim(aLinha[16])="0","",Alltrim(aLinha[16]))
			_cClvlcr  	:= if(Alltrim(aLinha[17])="0","",Alltrim(aLinha[17]))
			_cOrigem  	:= aLinha[18]
			_cChave	  	:= Dtos(Ctod(aLinha[01]))+_cLote+_cSublote+_cDoc	
			If Ascan(aDatas,{|x| x==_dData})==0
				aAdd(aDatas,_dData)
			EndIf
			_cErro := ''
			Do case
				Case _cTipo $ '1/3' //Débito/Partida Dobrada
					If Alltrim(_cDebito) == ''
						_cErro += 'Movimento à debito mas conta débito não informada. '
					Else
						If Ascan(_aCT1,{|x| x==_cDebito})==0
							_cErro += 'Conta '+_cDebito+' informada não existe para essa empresa/filial. '
						Else
							lCCOBRG := Posicione("CT1",1,xFilial("CT1")+_cDebito,"CT1_CCOBRG") == '1'
							lITOBRG := Posicione("CT1",1,xFilial("CT1")+_cDebito,"CT1_ITOBRG") == '1'
							lCLOBRG := Posicione("CT1",1,xFilial("CT1")+_cDebito,"CT1_CLOBRG") == '1'
							lACCUST := Posicione("CT1",1,xFilial("CT1")+_cDebito,"CT1_ACCUST") == '1'
							lACITEM := Posicione("CT1",1,xFilial("CT1")+_cDebito,"CT1_ACITEM") == '1'
							lACCLVL := Posicione("CT1",1,xFilial("CT1")+_cDebito,"CT1_ACCLVL") == '1'
							If lCCOBRG .and. _cCcd == ''
								_cErro += 'Conta '+_cDebito+' exige centro de custo. '
							Endif
							If lITOBRG .and. _cItemd == ''
								_cErro += 'Conta '+_cDebito+' exige item contábil. '
							Endif
							If lCLOBRG .and. _cClvldb == ''
								_cErro += 'Conta '+_cDebito+' exige classe de valor. '
							Endif
							If !lACCUST .and. _cCcd <> ''
								_cErro += 'Conta '+_cDebito+' não permite centro de custo. '
							Endif
							If !lACITEM .and. _cItemd <> ''
								_cErro += 'Conta '+_cDebito+' não permite item contábil. '
							Endif
							If !lACCLVL .and. _cClvldb <> ''
								_cErro += 'Conta '+_cDebito+' não permite classe de valor. '
							Endif				
						Endif	
					Endif	
				Case _cTipo $ '2/3' //Crédito/Partida Dobrada
					If Alltrim(_cCredito) == ''
						_cErro += 'Movimento à crédito mas conta crédito não informada. '
					Else
						If Ascan(_aCT1,{|x| x==_cCredito})==0
							_cErro += 'Conta '+_cCredito+' informada não existe para essa empresa/filial. '
						Else
							lCCOBRG := Posicione("CT1",1,xFilial("CT1")+_cCredito,"CT1_CCOBRG") == '1'
							lITOBRG := Posicione("CT1",1,xFilial("CT1")+_cCredito,"CT1_ITOBRG") == '1'
							lCLOBRG := Posicione("CT1",1,xFilial("CT1")+_cCredito,"CT1_CLOBRG") == '1'
							lACCUST := Posicione("CT1",1,xFilial("CT1")+_cCredito,"CT1_ACCUST") == '1'
							lACITEM := Posicione("CT1",1,xFilial("CT1")+_cCredito,"CT1_ACITEM") == '1'
							lACCLVL := Posicione("CT1",1,xFilial("CT1")+_cCredito,"CT1_ACCLVL") == '1'

							If lCCOBRG .and. _cCcc == ''
								_cErro += 'Conta '+_cCredito+' exige centro de custo. '
							Endif
							If lITOBRG .and. _cItemc == ''
								_cErro += 'Conta '+_cCredito+' exige item contábil. '
							Endif
							If lCLOBRG .and. _cClvlcr == ''
								_cErro += 'Conta '+_cCredito+' exige classe de valor. '
							Endif
							If !lACCUST .and. _cCcc <> ''
								_cErro += 'Conta '+_cCredito+' não permite centro de custo. '
							Endif
							If !lACITEM .and. _cItemc <> ''
								_cErro += 'Conta '+_cCredito+' não permite item contábil. '
							Endif
							If !lACCLVL .and. _cClvlcr <> ''
								_cErro += 'Conta '+_cCredito+' não permite classe de valor. '
							Endif				
						Endif	
					Endif
			EndCase
			If _cTipo == '1' .and. Alltrim(_cCredito) <> ''
				_cErro += 'Movimento à debito mas conta crédito foi informada. '
			Endif		
			If _cTipo == '2' .and. Alltrim(_cDebito) <> ''
				_cErro += 'Movimento à crédito mas conta débito foi informada. '
			Endif
			iF Empty(_cErro)
				aAdd( aRegistro	, {_dData,_cLote,_cSublote,_cDoc,_cLinha,_cTipo,_cDebito,_cCredito,_nValor,_cHp,_cHist,_cCcd,_cCcc,_cItemd,_cItemc,_cClvldb,_cClvlcr,_cOrigem,_cChave} )
			Else
				aAdd( aErro		, {"Linha "+StrZero(_nLinhatxt,5)+" - "+_cErro} )
			Endif
		Else
			MsgAlert("A linha "+StrZero(_nLinhatxt,5)+ "do arquivo possui inconsistencias. Rotina Abortada!!!","Erro")
			Return Nil
		Endif
		FT_FSKIP()
		_cBuffer := FT_FREADLN()
	End
	FT_FUSE()

	If Len(aErro)>0
		MsgStop("Foram encontrados "+Strzero(Len(aErro),9)+" erros no arquivo e a importação não pode prosseguir. Ajuste os erros apontados e refaça a importação.","Dados inconsistentes")
		GeraExcel("Impctb",aErro)
		Return Nil
	Endif	

	aDatas 		:= Asort(aDatas,,,{|x,y| x<y })

	ProcRegua(Len(aRegistro))
	Begin Transaction
		If Len(aRegistro)>0
			aSort(aRegistro,,,{|x,y| x[19] < y[19]})
			_nY	:= 1
			While _nY<=Len(aRegistro)
				IncProc("Gravando Lançamentos Contábeis")
				_cQuebra := aRegistro[_nY,19]
				_nTotLin := 1
				aItens	 := {}
				aCab 	 :=	{;
				{'DDATALANC' 	,aRegistro[_nY,01]	,Nil},;
				{'CLOTE' 		,aRegistro[_nY,02]	,Nil},;
				{'CSUBLOTE' 	,aRegistro[_nY,03]	,Nil},;
				{'CPADRAO' 		,'' 				,Nil},;
				{'NTOTINF' 		,0 					,Nil},;
				{'NTOTINFLOT' 	,0 					,Nil};
				}
				nSaldo := 0

				cLinha := StrZero(1,TamSX3('CT2_LINHA')[1])						

				While _nY<=Len(aRegistro) .and. _cQuebra == aRegistro[_nY,19]
					DbSelectArea('CT2')
					DbSetOrder(1)

					Aadd( aItens, 	{ ;
					{"CT2_FILIAL"	,xFilial("CT2")		,Nil},;
					{"CT2_LINHA"	,cLinha				,Nil},;
					{"CT2_MOEDLC"	,"01"				,Nil},;
					{"CT2_DC"		,aRegistro[_nY,06]	,Nil},;
					{"CT2_TPSALD"	,cTipSaldo			,Nil},;
					{"CT2_DEBITO"	,aRegistro[_nY,07]	,Nil},;
					{"CT2_CREDIT"	,aRegistro[_nY,08]	,Nil},;
					{"CT2_VALOR"	,aRegistro[_nY,09]	,Nil},;
					{"CT2_HP"		,aRegistro[_nY,10]	,Nil},;
					{"CT2_HIST"		,aRegistro[_nY,11]	,Nil},;
					{"CT2_CCD"		,aRegistro[_nY,12]	,Nil},;
					{"CT2_CCC"		,aRegistro[_nY,13]	,Nil},;
					{"CT2_ITEMD"	,aRegistro[_nY,14]	,Nil},;
					{"CT2_ITEMC"	,aRegistro[_nY,15]	,Nil},;
					{"CT2_CLVLDB"	,aRegistro[_nY,16]	,Nil},;
					{"CT2_CLVLCR"	,aRegistro[_nY,17]	,Nil},;
					{"CT2_ORIGEM"	,aRegistro[_nY,18]	,Nil};
					})

					cLinha := Soma1(Alltrim(cLinha))
					
					If aRegistro[_nY,06] == '1'
						nSaldo += aRegistro[_nY,09]
					Elseif aRegistro[_nY,06] == '2'
						nSaldo -= aRegistro[_nY,09]
					Endif
					_nY++
					_nTotLin++
				EndDo
				

				lMSErroAuto := .F.
				MsExecAuto( { |x,y,z| Ctba102( x, y, z ) }, aCab, aItens, 3 )
				If lMSErroAuto
					MostraErro( )
					If nSaldo <> 0
						MsgAlert("Erro na inclusão do lote contábil em " + dtoc(aCab[1][2])+", lote "+aCab[2][2]+", sublote "+aCab[3][2]+", documento "+_cDocAnt+ ". Débito e crédito não conferem - diferença de R$ "+Alltrim(Transform(nSaldo,"@E 999,999,999.99"))+". Será realizado rollback de toda a importação","Erro")
					Else
						MsgAlert("Erro na inclusão do lote contábil em " + dtoc(aCab[1][2])+", lote "+aCab[2][2]+", sublote "+aCab[3][2]+", documento "+_cDocAnt+ ". Verifique as entidades contábeis. Será realizado rollback de toda a importação","Erro")
					Endif
					DisarmTransaction()
					lOK := .F.
					Exit
				Endif
				lOK := .T.
			EndDo
		Endif
	
	End Transaction
	If lOK
		MsgAlert("Contabilizações importadas com sucesso.","Processo finalizado")
	Else
		MsgAlert("Contabilizações não importadas.","Erro")
	Endif

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³GeraExcel º Autor ³ AP5 IDE            º Data ³  19/04/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Gera arquivo CSV para abertura                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function GeraExcel(_cArq,_aExcel)

Local cArq 		:= "\spool\"+_cArq+".csv"
Local nArq 		:= fCreate(cArq,0)
Local nLinExcel := 0
Local cLinha 	:= ""
Local IW 		:= 0

If File("C:\temp\"+_cArq+".csv")
	Ferase("C:\temp\"+_cArq+".csv")
EndIf

FWrite(nArq,cLinha,Len(cLinha))

For IW:= 1 to Len(_aExcel)
	
	cLinha := _aExcel[IW][1] + chr(13) + chr(10)
	
	FWrite(nArq,cLinha,Len(cLinha))
	
	nLinExcel ++
	
Next IW

fClose(nArq)
CpyS2T( cArq , "c:\temp\", .T. )

ShellExecute("open","C:\temp\"+_cArq+".csv","","",1)

Return()