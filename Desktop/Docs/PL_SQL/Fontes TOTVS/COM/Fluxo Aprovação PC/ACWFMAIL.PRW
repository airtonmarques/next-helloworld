#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "ap5mail.ch"
#INCLUDE "TBICONN.CH"

User Function ACWFMAIL(_cRecebe,_cAssunto,_cMensagem,_cCC,_cBCC,_aAnexos,_lJob)

// Parâmetros da Função
// 1 - e-mail do Destinatário
// 2 - Assunto (Subject)
// 3 - Mensagem (Body)
// 4 - e-Mail para Destinatário Com Cópía
// 5 - e-Mail para Destinatário Com Cópía Oculta
// 6 - Array com arquivos que deverão ser enviados como Anexo
// 7 - Indica se a função foi acionada por um Job

DEFAULT _cRecebe   := ""
DEFAULT _cAssunto  := ""
DEFAULT _cMensagem := ""
DEFAULT _cCC       := ""
DEFAULT _cBCC      := ""
DEFAULT _aAnexos   := {}
DEFAULT _lJob      := .F.

_lRet := .T.

_cNSrvIMAP := GetNewPar("VT_WFIMAP","smtp.office365.com")
_cNSrvSMTP := GetNewPar("VT_WFSMTP","smtp.office365.com")
_cNUsuario := GetNewPar("VT_WFUSER","workflow@vyttra.com")
_cPassword := GetNewPar("VT_WFPASS","TesPax@3")
_nPortaPOP := GetNewPar("VT_WFPIMAP",995)
_nPortSMTP := GetNewPar("VT_WFPSMTP",587)
_lUsaSSL   := GetNewPar("VT_WFUSSL",.F.)
_lUsaTLS   := GetNewPar("VT_WFUTLS",.T.)

_lConectou 	  := .F.
_lDisconectou := .F.

If Empty(_cRecebe)
    
	_cMsg := "ACWFMAIL Error: E-mail sem Destinatario, verifique!" + Iif(Empty(_cAssunto),""," - Assunto: " + Alltrim(_cAssunto))
	_lRet := .F.
	If _lJob
		CONOUT(_cMsg)
	Else	
		MsgAlert(_cMsg)
	EndIf

Else

	oServer := TMailManager():New()
	oServer:SetUseSSL(_lUsaSSL)
	oServer:SetUseTLS(_lUsaTLS)
	_nConexao := oServer:Init(_cNSrvIMAP,_cNSrvSMTP,_cNUsuario,_cPassword,_nPortaPOP,_nPortSMTP)
	
	If _nConexao == 0
		_cMsg := "ACWFMAIL - Conectado ao servidor de E-Mail - " + _cNSrvSMTP
		If _lJob
			CONOUT(_cMsg)
		EndIf
		
		_nConexao := oServer:SMTPConnect()
		
		If _nConexao == 0
	
			_nConexao := oServer:SMTPAuth(_cNUsuario,_cPassword)
	
			If _nConexao == 0
	
				oMessage := TMailMessage():New()
				oMessage:Clear()
		
				oMessage:cDate    := cValToChar(Date())
				oMessage:cFrom    := _cNUsuario
				oMessage:cTo      := _cRecebe
				oMessage:cSubject := _cAssunto
				oMessage:cBody    := _cMensagem
				oMessage:cCC      := _cCC
				oMessage:cBCC     := _cBCC
		
				For _nCnt := 1 To Len(_aAnexos)
					_nRet := oMessage:AttachFile(_aAnexos[_nCnt])
					If _nRet >= 0
						oMessage:AddAtthTag('Content-Disposition: attachment; filename=' + _aAnexos[_nCnt])
					Else
					 	_lRet := .F.
						_cMsg := "ACWFMAIL Error: Inclusao de anexo nao realizado! ERRO[" + Str(_nCnt,4) + ']: ' + oServer:GetErrorString(_nRet)
						If _lJob
							CONOUT(_cMsg)
						Else
						 	MsgAlert(_cMsg)
						EndIf
					EndIf
				Next _nCnt
				
				If _lRet

					_nConexao := oMessage:Send(oServer)
			
					If _nConexao == 0
						_cMsg := "ACWFMAIL - e-mail enviado com Sucesso - para " + Alltrim(_cRecebe) + " - Assunto: " + Alltrim(_cAssunto)
						If _lJob
							CONOUT(_cMsg)
						Else
							MsgAlert(_cMsg)
						EndIf
					Else
						_lRet := .F.
						_cMsg := "ACWFMAIL Error: Para " + Alltrim(_cRecebe) + " - Assunto: " + Alltrim(_cAssunto) + " - " + oServer:GetErrorString(_nConexao)
						If _lJob
							CONOUT(_cMsg)
						Else
							MsgAlert(_cMsg)
						EndIf
					Endif
					
				EndIf
			
				_nConexao := oServer:SMTPDisconnect()
			
				If _nConexao == 0
					_cMsg := "ACWFMAIL - Desconectado do Servidor de e-mail"
					If _lJob
						CONOUT(_cMsg)
					EndIf
				Else
					_cMsg := "ACWFMAIL Error: Para " + Alltrim(_cRecebe) + " - Assunto: " + Alltrim(_cAssunto) + " - " + oServer:GetErrorString(_nConexao)
					If _lJob
						CONOUT(_cMsg)
					Else
						MsgAlert(_cMsg)
					EndIf
				EndIf
	
			Else
				
				_lRet := .F.
				_cMsg := "ACWFMAIL Error: Para " + Alltrim(_cRecebe) + " - Assunto: " + Alltrim(_cAssunto) + " - " + oServer:GetErrorString(_nConexao)
				If _lJob
					CONOUT(_cMsg)
				Else
					MsgAlert(_cMsg)
				EndIf
		
			Endif
	
		Else
	
			_lRet := .F.
			_cMsg := "ACWFMAIL Error: Para " + Alltrim(_cRecebe) + " - Assunto: " + Alltrim(_cAssunto) + " - " + oServer:GetErrorString(_nConexao)
			If _lJob
				CONOUT(_cMsg)
			Else
				MsgAlert(_cMsg)
			EndIf
		
		EndIf
	
	Else
	
		_lRet := .F.
		_cMsg := "ACWFMAIL Error: Para " + Alltrim(_cRecebe) + " - Assunto: " + Alltrim(_cAssunto) + " - " + oServer:GetErrorString(_nConexao)
		If _lJob
			CONOUT(_cMsg)
		Else
			MsgAlert(_cMsg)
		EndIf
	
	EndIf	

EndIf

Return(_lRet)