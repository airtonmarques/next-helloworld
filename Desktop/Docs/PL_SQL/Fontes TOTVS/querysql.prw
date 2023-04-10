#Include 'RwMake.ch'            
#Include 'TopConn.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QuerySQL �Autor  �Sergio Celestino    � Data �  14/08/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Executa query como o Query Analyser.                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Sergio                                                           ���
����������������������������������� ��������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function QuerySQL()

Private cQuery  := ""
Private aCols   := {}
Private aHeader := {}
Private cTmp    := Space(02)
Private lTstQry := .t.
cTexto  := ""
cFOpen  := ""

If __cUserid<>"000000"
  Alert("Usuario sem acesso a rotina")
  Return
Endif  


aHeader := {{"   ","cTmp"  ,""  ,2 , 0,"","","C","",""}} 
aCols   := {{"  ",.f.}}

@ 110,000 To 655,890 Dialog oDlgQuery Title "Query Analyser Para Protheus."
@ 002,005 Say OemToAnsi("Arquivo: <SEM NOME>"+Space(100)) Object oNome
@ 010,005 Get cQuery Size 420,230 MEMO Object oMemo
@ 250,005 CHECKBOX "Testa Query Antes de Executar." VAR lTstQry 
@ 257,005 Button OemToAnsi("_Consultar...")     Size 36,16 Action fExecQuery("Cons")
@ 257,055 Button OemToAnsi("_Executar...")      Size 36,16 Action fExecQuery("Exec")
@ 257,105 Button OemToAnsi("_Abrir...")         Size 36,16 Action FRAbre()
@ 257,155 Button OemToAnsi("_Fechar")           Size 36,16 Action FRFecha()
@ 257,205 Button OemToAnsi("_Salvar")           Size 36,16 Action FRSalva()
@ 257,255 Button OemToAnsi("_Salvar Como...")   Size 36,16 Action FRSalvaComo()
@ 257,305 Button OemToAnsi("_Gerar Planilha")   Size 36,16 Action FRGerPlan()
@ 257,355 Button OemToAnsi("_Executar Arquivo") Size 56,16 Action FRExecArq()
@ 257,420 BmpButton Type 1 Action Close(oDlgQuery)

Activate Dialog oDlgQuery

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fExecQuery�Autor  �Sergio Celestino    � Data �  15/08/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Executa a Query e monta o MultiLine com o Resultado         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fExecquery(cModo)

Local aStru    := {}
Local aColsTmp := {}
Local cQryAtu  
Local i

                   
//cQryAtu := ChangeQuery(cQuery)
cQryAtu := cQuery

If cModo = "Cons"
   //�������������������������������Ŀ
   //� Testa Query antes de Executar �
   //���������������������������������
   If lTstQry
      nRet := TcSqlExec(cQryAtu) 
      If nRet#0
         cRet := TCSQLError()
	     APMsgAlert(AllTrim(cRet),"Erro do SQL")
         Return
      Endif   
   Endif
   
   //��������������������������Ŀ
   //� Zera Variaveis do Browse �
   //����������������������������
   aCols   := {}
   aHeader := {}

   //�������������������������������Ŀ
   //� Fecha Alias se estiver em Uso �
   //���������������������������������
   If !Empty(Select("TRB"))
      dbSelectArea("TRB")
      dbCloseArea()
   Endif   

   //���������������������������������������������
   //� Monta Area de Trabalho executando a Query �
   //���������������������������������������������
   TCQUERY cQryAtu New Alias "TRB"
   dbSelectArea("TRB")
   dbGoTop()

   //���������������Ŀ
   //� Monta aHeader �
   //�����������������
   aStru := dbStruct()
   aAdd(aStru,{"","C",1,0})       
   
   For i:=1 to Len(aStru)
      If "USERLGI" $ aStru[i][1]
         aStru[i][3]:= 27
      Endif   

      If "USERLGA" $ aStru[i][1]
         aStru[i][3]:= 30
      Endif   
   Next
   
   //������������������������������Ŀ
   //� Declara Variaveis do aHeader �
   //��������������������������������
   For i:=1 to Len(aStru)
      cVar  := "Var"+AllTrim(Str(i))+" := "+fGetResult(aStru,i)
      (&(cVar))  
   Next

   For i:=1 to Len(aStru)
      aAdd(aHeader,{aStru[i][1],"Var"+AllTrim(Str(i)),"",aStru[i][3],aStru[i][4],"","",aStru[i][2],"",""})
   Next

   //�������������Ŀ
   //� Monta aCols �
   //���������������
   dbGoTop()
   While !EOF()
      aColsTmp := Array(Len(aStru)+1)
      For i:=1 to Len(aStru)
         If "USERLG"$aStru[i][1]
            cUser  := Embaralha(&(aStru[i][1]),1)
            aColsTmp[i]:= Substr(cUser,1,15)+"-"+IIF(!Empty(cUser),DTOC(CTOD("01/01/96") + Load2in4(Substr(cUser,16))),DTOC(CTOD("//")))
         Else
            aColsTmp[i]:=FieldGet(i)
         Endif   
      Next
      aColsTmp[Len(aStru)+1] := .f.
   
      aAdd(aCols,aColsTmp)
      dbSkip()
   End                               
   
   //����������������������������������������������Ŀ
   //� Monta outra janela para o resultado da Query �
   //������������������������������������������������
   @ 000,000 TO 550,795 DIALOG oResultQry TITLE "Resultado da Query..."
   @ 005,005 TO 270,395 MULTILINE FREEZE 1
   ACTIVATE DIALOG oResultQry 
Elseif cModo = "Exec"
   If MsgBox("Deseja realmente executar os comandos acima???","SQL Query","YESNO")
      nRet := TcSqlExec(cQuery) 
      If nRet#0
   	     cRet = TCSQLError()
		 APMsgAlert(AllTrim(cRet),"Erro do SQL")
      Else
         Alert("Comando Executado...")
      Endif   
   Endif
Endif   

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fGetResult�Autor  �Sergio Celestino    � Data �  19/08/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Busca Texto para Final da Declaracao das variaveis do       ���
���          �aHeader.                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fGetResult(aStru,i)
Local cRet
          
If aStru[i][2]=="C"
   cRet := "Space("+AllTrim(Str(aStru[i][3]))+")"
Elseif aStru[i][2]=="N"
   cRet := "0"   
Elseif aStru[i][2]=="D"   
   cRet := 'CTOD("//")'
Else
   Alert("Tipo de dado nao Tratado aStru[i][2] = "+aStru[i][2])
   cRet := ""
Endif   

Return(cRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � fRAbre   � Autor �Sergio Celestino    � Data �  15/08/2003 ���
�������������������������������������������������������������������������͹��
���Descri��o � Rotina para a abertura do arquivo texto na FunMEMO         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fRAbre()

cFOpen := cGetFile("Sql Query|*.SQL|Arquivos Texto|*.TXT|Todos os Arquivos|*.*",OemToAnsi("Abrir Arquivo..."))
If !Empty(cFOpen)
    cQuery := MemoRead(cFOpen)
    ObjectMethod(oMemo,"Refresh()")
    ObjectMethod(oNome,"SetText('Arquivo: '+cFOpen)")
Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � fRFecha  � Autor �Sergio Celestino     � Data �  15/08/2003 ���
�������������������������������������������������������������������������͹��
���Descri��o � Rotina para fechamento do arquivo texto em FunMEMO         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function fRFecha()
    cQuery := ""
    cFOpen := ""
    ObjectMethod(oMemo,"Refresh()")
    ObjectMethod(oNome,"SetText('Arquivo: <SEM NOME>')")
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � fRSalva  � Autor �Sergio Celestino    � Data � 15/08/2003  ���
�������������������������������������������������������������������������͹��
���Descri��o � Rotina para salvar o arquivo texto em FunMEMO              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fRSalva()
If !Empty(cFOpen)
    MemoWrit(cFOpen,cQuery)
Endif
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o   �fRSalvaComo� Autor �Sergio Celestino    � Data � 15/08/2003  ���
�������������������������������������������������������������������������͹��
���Descri��o� Rotina para salvar arquivo texto com outro nome em FunMEMO  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fRSalvaComo()
cAux   := cFOpen
cFOpen := cGetFile("Arquivos Texto|*.TXT|Todos os Arquivos|*.*",OemToAnsi("Salvar Arquivo Como..."))
If !Empty(cFOpen)
    MemoWrit(cFOpen,cQuery)
    ObjectMethod(oNome,"SetText('Arquivo: '+cFOpen)")
Else
    cFOpen := cAux
Endif
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FRGerPlan �Autor  �Sergio Celestino    � Data �  08/08/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Gerar planilha com resultado da query                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FRGerPlan()
  DlgToExcel({ {"ARRAY","Resultado da Query", aHeader, aCols} })
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FRGerPlan �Autor  �Sergio Celestino    � Data �  08/08/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Gerar planilha com resultado da query                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
static Function FRExecArq

Local _aFiles 	:= {}
Local aStruct	:= {}
Local nK		:= 1
Local cFolder	:= cGetFile( '*.*|*.*' , 'Selecione o arquivo' , 1 ,  , .F. , nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY ,GETF_NETWORKDRIVE ) , .F.) 	

FWMsgRun(, {|oSay| Execupdt(oSay,cFolder) }, "Processando", "executando comandos") 

RETURN

static function Execupdt(oSay,cFolder)
FT_FUSE(cFolder)
FT_FGOTOP()

While !FT_FEOF()
	cSql := FT_FREADLN()
   If (TcSqlExec(cSql) < 0)
		MsgStop("TCSQLError() " + TCSQLError())
	EndIf
	FT_FSKIP()
Enddo

FT_FUSE()

Return
