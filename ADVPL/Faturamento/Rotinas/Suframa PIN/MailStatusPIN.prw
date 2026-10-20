#include 'totvs.ch'

user function tstMailStatusPIN()
	posicione("SF2",1,xFilial("SF2")+"0000924071","!Eof()")
	u_mailStatusPIN()
return

/*/{Protheus.doc} MailStatusPIN
Envia E-mail avisando o usuario que a NF emitida tem que ser gerado PIN
@type function
@version 12.1.27
@author Tiago Faria
@since 14/10/2021
/*/
user function MailStatusPIN()
	local cSubject := "CADASTRAR PIN SUFRAMA NF " + SF2->(F2_DOC+"/"+F2_SERIE)
	local cBody    := "EFETUAR CADASTRO PIN SUFRAMA PARA NF " + SF2->(F2_DOC+"/"+F2_SERIE) + " CLIENTE " + SF2->(F2_CLIENTE+"/" +F2_LOJA)

	posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"!Eof()")
	cBody += ":" + SA1->A1_NOME
	
    if u_IsClienteSuframa(SF2->F2_CLIENTE,SF2->F2_LOJA)
		sendMail(cSubject,cBody)
	endif
return

static function sendMail(cSubject,cBody,cTo)
	local oMailManager 	:= TMailManager():new()
	local oMailMessage	:= TMailMessage():new()
	local lISS			:= GetMV("MV_RELSSL")
	local cServer 		:= GetMV("MV_RELSERV")
	local cAccount    	:= GetMV("MV_RELACNT")
	local cPassword		:= alltrim(GetMV("MV_RELPSW"))
	local cFrom			:= GetMV("MV_RELFROM")
	local lAuthenticate := GetMV("MV_RELAUTH")
	//local lSSL			:= GetMV("MV_RELSSL")
	local lTLS			:= GetMV("MV_RELTLS")
	local nTimeOut		:= GetMV("MV_RELTIME")
	local nLastError	:= 0
	local lSendOk		:= .F.
	local nPort			:= 0
	local lAuthOK		:= .F.
	default cTo 		:= getNewPar("ZZ_MAILPIN","suframa@solpack.com.br")
	default cBody		:= ""

	if (":" $ cServer)
		cStrPort:= SubStr(cServer, At(":", cServer))
		cServer := StrTran(cServer, cStrPort, "")
		nPort 	:= Val(StrTran(cStrPort, ":", ""))
	endIf

	oMailManager:setUseSSL(lISS)
	oMailManager:setUseTLS(lTLS)
	oMailManager:setSmtpTimeOut(nTimeOut)
	oMailManager:init("", cServer, cAccount, cPassword, 0, nPort)

	oMailMessage:clear()

	if connect(@oMailManager)
		if lAuthenticate
			lAuthOk  := oMailManager:smtpAuth(cAccount, cPassword) == 0
		else
			lAuthOk := .t.
		endIf
		if lAuthOk
			oMailMessage:cFrom 		:= cFrom
			oMailMessage:cTo 		:= cTo
			oMailMessage:cSubject 	:= cSubject
			oMailMessage:cBody 		:= cBody

			nLastError := oMailMessage:send(oMailManager)
			lSendOk := (nLastError == 0)
			if !lSendOk
				conout( "[MAILSTATUSPIN] Erro ao enviar e-mail para o usuário")
			endif
		endif
		myDisconnect(@oMailManager)
	endif
return lSendOk .and. lAuthOk

static function connect(oMailManager)
	local nLastError := oMailManager:smtpConnect()
	local lRet		 := .t.

	if (nLastError <> 0)
		conout( "[MAILSTATUSPIN] Falha ao conectar ao Servidor de Email")
		lRet := .f.
	endIf
return lRet

static function myDisconnect(oMailManager)
	local lRet			:= .t.

	if oMailManager:smtpDisconnect() <> 0
		conout( "[MAILSTATUSPIN] Falha ao desconectar do Servidor de Email")
		lRet := .f.
	endIf
return lRet
