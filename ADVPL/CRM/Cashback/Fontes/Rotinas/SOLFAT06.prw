#include "TOTVS.CH"
#include "topconn.ch"
#include "SOLFAT04.ch"

/*/{Protheus.doc} SOLFAT06
    Workflow de notificação de vencimento próximo de cashback
    
    @author Gabriel Pereira Santos
    @since 26/04/2023
    @version P12
/*/ 
User Function SOLFAT06(cParIDCash, cParCliente, cParLoja)
    Local cTitulo       := "Notificação Vencimento de Cashback Solpack"
    Local cQuery        := ""
    Local cAlias        := ""
    Local cCliente      := ""
    Local cLoja         := ""
    Local cEmail        := ""
    Local aDados        := {}
    Local nRecord       := 0
    Local nDados        := 0

    cQuery := getQryVencimento(cParIDCash, cParCliente, cParLoja)

    TcQuery cQuery New Alias (cAlias:=GetNextAlias())

    If (cAlias)->(!Eof())
        While (cAlias)->(!Eof())
            cCliente := Alltrim((cAlias)->CLIENTE)
            cLoja := Alltrim((cAlias)->LOJA)
            cEmail := Alltrim((cAlias)->EMAIL)

            nRecord := AScan(aDados,{|x| Alltrim(x[1]) == cCliente .And. Alltrim(x[2]) == cLoja})

            If (nRecord > 0)
                aAdd(aDados[3], {(cAlias)->PRODUTO, (cAlias)->DESCRICAO, dToc(sToD((cAlias)->DTVENCIMENTO)), cValToChar((cAlias)->VALOR)})
            Else
                aAdd(aDados, {cCliente, cLoja, cEmail, {{Alltrim((cAlias)->PRODUTO), Alltrim((cAlias)->DESCRICAO), dToc(sToD((cAlias)->DTVENCIMENTO)), cValToChar((cAlias)->VALOR)}}, ""})
            EndIf

            (cAlias)->(DBSkip())
        EndDo
        
        If (Len(aDados) > 0) 
            montaHTML(@aDados, cTitulo)

            For nDados := 1 To Len(aDados)
                If (!Empty(EncodeUTF8(aDados[nDados, 5])) .And. !Empty(aDados[nDados, 3]))
                    sendMailProtheus(cTitulo,EncodeUTF8(aDados[nDados, 5]),aDados[nDados, 3])
                EndIf
            Next nDados
        EndIf
    EndIf

    (cAlias)->(DBCloseArea())
Return

/*
    Monta query de consulta dos produtas a serem notificados
*/
Static Function getQryVencimento(cParIDCash, cParCliente, cParLoja)
    Local cQuery            := ""
    Local cAlias0Grid	    := ALIAS_GRID0
    Local cAlias1Grid	    := ALIAS_GRID1
	Local cPref0Grid	    := PREFIXO_ALIAS_GRID0
	Local cPref1Grid	    := PREFIXO_ALIAS_GRID1
    Local nDiasAviso        := GetNewPar("ES_DAVCASH", 2)
    Local nDiasVencimento   := GetNewPar("ES_DVCCASH", 365)

    cQuery += " SELECT " + CRLF
    cQuery += "     SUBQRY.* " + CRLF
    cQuery += "     ,format(DATEADD(DAY, " + ValToSql(nDiasVencimento) + ", SUBQRY.ULTIMOMOV),'yyyyMMdd') DTVENCIMENTO " + CRLF
    cQuery += " FROM " + CRLF
    cQuery += "     ( " + CRLF
    cQuery += "     SELECT  " + CRLF
    cQuery += "         " + cPref1Grid + "_FILIAL FILIAL " + CRLF
    cQuery += "         ," + cPref1Grid + "_IDCASH IDCASH " + CRLF
    cQuery += "         ," + cPref1Grid + "_PRODUT PRODUTO " + CRLF
    cQuery += "         ,B1_DESC DESCRICAO " + CRLF
    cQuery += "         ," + cPref1Grid + "_CLIENT CLIENTE " + CRLF
    cQuery += "         ," + cPref1Grid + "_LOJA LOJA " + CRLF
    cQuery += "         ,A1_EMAIL EMAIL " + CRLF
    cQuery += "         ," + cPref0Grid + "_VALOR VALOR " + CRLF
    cQuery += "         ,MAX(" + cPref1Grid + "_DATA) ULTIMOMOV " + CRLF
    cQuery += "     FROM  " + CRLF
    cQuery += "         " + RetSqlTab(cAlias1Grid) + CRLF
    cQuery += "         INNER JOIN " + RetSqlTab("SB1") + " ON 1 = 1 " + CRLF
    cQuery += "             AND SB1.B1_FILIAL = ' ' " + CRLF
    cQuery += "             AND SB1.B1_COD = " + cAlias1Grid + "." + cPref1Grid + "_PRODUT " + CRLF
    cQuery += "             AND" + RetSqlDel("SB1") + CRLF
    cQuery += "         INNER JOIN " + RetSqlTab(cAlias0Grid) + " ON 1 = 1 " + CRLF
    cQuery += "             AND " + cAlias0Grid + "." + cPref0Grid + "_FILIAL = " + cAlias1Grid + "." + cPref1Grid + "_FILIAL " + CRLF
    cQuery += "             AND " + cAlias0Grid + "." + cPref0Grid + "_IDCASH = " + cAlias1Grid + "." + cPref1Grid + "_IDCASH " + CRLF
    cQuery += "             AND " + cAlias0Grid + "." + cPref0Grid + "_PRODUT = " + cAlias1Grid + "." + cPref1Grid + "_PRODUT " + CRLF
    cQuery += "             AND" + RetSqlDel(cAlias0Grid) + CRLF
    cQuery += "         INNER JOIN " + RetSqlTab("SA1") + " ON 1 = 1 " + CRLF
    cQuery += "             AND SA1.A1_FILIAL = ' ' " + CRLF
    cQuery += "             AND SA1.A1_COD = " + cAlias1Grid + "." + cPref1Grid + "_CLIENT " + CRLF
    cQuery += "             AND SA1.A1_LOJA = " + cAlias1Grid + "." + cPref1Grid + "_LOJA " + CRLF
    cQuery += "             AND" + RetSqlDel("SA1") + CRLF
    cQuery += "     WHERE " + CRLF
    cQuery += "         1 = 1 " + CRLF
    cQuery += "         AND " + cAlias1Grid + "." + cPref1Grid + "_TPMOV = '1' " + CRLF
    cQuery += "         AND " + cAlias0Grid + "." + cPref0Grid + "_VALOR > 0 " + CRLF
    cQuery += "         AND" + RetSqlDel(cAlias1Grid) + CRLF
    cQuery += "     GROUP BY " + CRLF
    cQuery += "         " + cPref1Grid + "_FILIAL " + CRLF
    cQuery += "         ," + cPref1Grid + "_IDCASH " + CRLF
    cQuery += "         ," + cPref1Grid + "_CLIENT " + CRLF
    cQuery += "         ," + cPref1Grid + "_LOJA " + CRLF
    cQuery += "         ," + cPref1Grid + "_PRODUT " + CRLF
    cQuery += "         ,B1_DESC " + CRLF
    cQuery += "         ,A1_EMAIL " + CRLF
    cQuery += "         ," + cPref0Grid + "_VALOR " + CRLF
    cQuery += "     ) SUBQRY " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += "     1 = 1 " + CRLF
    cQuery += "     AND DATEDIFF(DAY, CONVERT(date, SUBQRY.ULTIMOMOV), GETDATE()) >= " + ValToSql(nDiasAviso) + CRLF
    If !Empty(cParIDCash)
        cQuery += "     AND SUBQRY.IDCASH = " + ValToSql(cParIDCash) + CRLF
    EndIf
    If !Empty(cParCliente)
        cQuery += "     AND SUBQRY.CLIENTE = " + ValToSql(cParCliente) + CRLF
    EndIf
    If !Empty(cParLoja)
        cQuery += "     AND SUBQRY.LOJA = " + ValToSql(cParLoja) + CRLF
    EndIf
    cQuery += " ORDER BY " + CRLF
    cQuery += "     SUBQRY.FILIAL " + CRLF
    cQuery += "     ,SUBQRY.IDCASH " + CRLF

Return cQuery

/*
    Função para montar HTML de notificação
*/
Static Function montaHTML(aDados, cTitulo)
    Local cHtml     := ""
    Local cItem     := ""
    Local nRecord   := 0
    
    For nRecord := 1 To Len(aDados)
        cHtml := ""
        cItem := ""

        If (ValType(aDados[nRecord,4]) == "A")
            cItem := montaItemHTML(aDados[nRecord,4])
        EndIf

        If !Empty(cItem)
            cHtml += ' <!DOCTYPE html>'
            cHtml += ' <html lang="en">'
            cHtml += ' <head>'
            cHtml += ' <meta charset="UTF-8">'
            cHtml += ' <meta http-equiv="X-UA-Compatible" content="IE=edge">'
            cHtml += ' <meta name="viewport" content="width=device-width, initial-scale=1.0">'
            cHtml += ' <style type="text/css">'
            cHtml += ' .table  { border :1px solid #999; margin:1em auto; }'
            cHtml += ' .form1  { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 11px; color: #000000; text-decoration: none; padding: 20px 0 20px; display: flex;}'
            cHtml += ' .top_bg {  background-color: #0E849C; margin:0; padding:0; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; text-decoration: none; font-weight: bold; text-align:center; color:#FFF}'
            cHtml += ' </style>'
            cHtml += ' <title>Notificação</title>'
            cHtml += ' </head>'
            cHtml += ' <body>'
            cHtml += ' <table width="90%" class="table">'
            cHtml += ' <tr>'
            cHtml += ' <td width="85%" align="center" class="top_bg" height="50px">Notifica&ccedil;&atilde;o Vencimento de Cashback Solpack</td>'
            cHtml += ' </tr>'
            cHtml += ' </table>'
            cHtml += ' <table width="90%" class="table" cellspacing="5">'
            cHtml += ' <tr class="form1">'
            cHtml += ' <td width="100%">'

            cHtml += ' <div style="width: 98%; margin: 0px auto; ">'
            cHtml += ' <img src="https://solpack.com.br/wp-content/uploads/2023/03/logo-nova.png" width="200px">'
            cHtml += ' <h6 style="font-family: ' + "'Calibri'" + ', sans-serif; font-size: 16px; margin-bottom: 30px;">Prezado(a), essa &eacute; uma notifica&ccedil;&atilde;o autom&aacute;tica, para informar o vencimento de cr&eacute;dito cashback do(s) seguinte(s) produto(s):</h6>'
            cHtml += ' <table style="font-family: ' + "'Calibri'" + ', sans-serif; width: 100%;font-size: 16px">'
            cHtml += ' <thead>'
            cHtml += ' <tr style="text-align: center;">'
            cHtml += ' <th width="20%" style="border-bottom: 1px solid black;">Produto</th>'
            cHtml += ' <th width="35%" style="border-bottom: 1px solid black;">Descri&ccedil;&atilde;o</th>'
            cHtml += ' <th width="15%" style="border-bottom: 1px solid black;">Data Vencimento</th>'
            cHtml += ' <th width="10%" style="border-bottom: 1px solid black;">Valor (R$)</th>'
            cHtml += ' </tr>'
            cHtml += ' </thead>'
            cHtml += ' </table>'

            cHtml += cItem       
            
            cHtml += ' <br>'
            cHtml += ' <h6 style="margin-bottom: 30px; font-weight:900 ; font-size: 11px;">Atualizado em: ' + dtoc(date()) + '</h6>'
            cHtml += ' </div>'

            cHtml += ' </td>'
            cHtml += ' </table>'
            cHtml += ' <table width="90%" class="table">'
            cHtml += ' <tr>'
            cHtml += ' <td width="85%" align="center" class="top_bg" height="50px">Copyright '+Year2Str(Date())+'. Todos os direitos reservados.</td>'
            cHtml += ' </tr>'
            cHtml += ' </table>'
            cHtml += ' </tr>'
            cHtml += ' </body>'
            cHtml += ' </html>'
        EndIf

        If !Empty(cHtml)
            aDados[nRecord, 5] := cHtml
        EndIf
    Next nRecord

Return

/*
    Monta tabela de itens do workflow
*/
Static Function montaItemHTML(aItens)
    Local nItem     := 0
    Local cItem     := ""

    For nItem := 1 To Len(aItens)
        cItem += ' <table style="font-family: ' + "'Calibri'" + ', sans-serif; width: 100%;font-size: 14px;font-weight: 500;">'
        cItem += ' <tbody style="border-bottom: solid gray 2px;">'
        
        cItem += ' <tr style="text-align: center;">'
        cItem += ' <td width="20%">' + aItens[nItem, 1] + '</td>'
        cItem += ' <td width="35%">' + aItens[nItem, 2] + '</td>'
        cItem += ' <td width="15%">' + aItens[nItem, 3] + '</td>'
        cItem += ' <td width="10%">' + aItens[nItem, 4] + '</td>'
        cItem += ' </tr>

        cItem += ' </tbody>'
        cItem += ' </table>'
        cItem += ' <hr>'
    Next nItem

Return cItem

/*
    Rotina para disparar email
*/
Static Function sendMailProtheus(cAssunto,cHTML,cEmail,cEmailCC,cEmailBCC,aAnexos)
	Local oServer 		:= Nil
	Local oMessage  	:= Nil  
	Local cSMTPAddr 	:= "mail.solpack.com.br"//GetMV("MV_RELSERV")
	Local nSMTPPort 	:= GetMV("MV_PORSMTP")
	Local cFrom			:= GetMV("MV_RELFROM")
	Local cUser     	:= GetMV("MV_RELACNT")
	Local cPass     	:= GetMV("MV_RELAPSW")
	Local nSMTPTime 	:= GetMV("MV_RELTIME")
	Local UseSSL		:= GetMV("MV_RELSSL")
	Local UseTLS		:= GetMV("MV_RELTLS")
	Local lAuth			:= GetMV("MV_RELAUTH")
	Local cAnexo		:= ""
	Local cMsg			:= ""
	Local nFile			:= 0
	Local nRet			:= 0
	Local lRet			:= .F.

	Default cAssunto	:= "SEM ASSUNTO"
	Default cHTML		:= ""
	Default cEmail		:= ""
	Default cEmailCC	:= ""
	Default cEmailBCC	:= ""
	Default aAnexos		:= {}

	If !Empty(cHTML)
		//Cria o Objeto para Envio de Emails
		oServer := tMailManager():NEW()
		
		//Define Propriedades Adicionais de Conexão	
		oServer:setUseSSL(UseSSL)	//Usa SSL na conexao 
		oServer:setUseTLS(UseTLS)	//Usa TLS na conexao
		                                    
		//Inicializa o Servidor de Conexão SMTP
		oServer:Init(cSMTPAddr, cSMTPAddr, cUser, cPass , 0 , nSMTPPort)
		         
		//Define o TimeOut               
		If nSMTPTime > 0               
			showLogInConsole("[TIMEOUT] ENABLE")		
			nRet := oServer:SetSmtpTimeOut( nSMTPTime )
			If ( nRet <> 0 )				
				cMsg := "[TIMEOUT][ERROR] Fail to set - " + str(nRet,6) + " - " + oServer:GetErrorString(nRet)
				saveError(cMsg)
				Return .F.		
			EndIf
		Else
			showLogInConsole("[TIMEOUT] DISABLE")
		Endif
		
		//Realiza a conexão SMTP
		showLogInConsole( "[SMTPCONNECT] connecting ..." )	
		nRet := oServer:SmtpConnect()
		If ( nRet <> 0 )			
			cMsg := "[SMTPCONNECT][ERROR] Fail to connect - " + str(nRet,6) + " - " + oServer:GetErrorString(nRet)
			saveError(cMsg)
			Return .F.
		Else
			showLogInConsole( "[SMTPCONNECT] Sucess ao conectar" )
		EndIf
		
		If lAuth
			showLogInConsole("[AUTH] ENABLE")		
			showLogInConsole("[AUTH] TRY with ACCOUNT() and PASS()")
			
			nRet := oServer:SMTPAuth(cUser, cPass)		
			If ( nRet <> 0 )
				cMsg := "[AUTH][ERROR] FAIL TRY with USER() and PASS() - " + str(nRet,6) + " - " + oServer:GetErrorString(nRet)
				saveError(cMsg)
				Return .F.
			Else				
				showLogInConsole("[AUTH] SUCEEDED TRY with USER() and PASS()")			
			Endif	
		Else		
			showLogInConsole("[AUTH] DISABLE")	
		Endif
			
		//Apos a conexão, cria o objeto da mensagem	
		showLogInConsole("[MESSAGE] Criando mail message com TMailMessage().")
		oMessage := TMailMessage():New()	
	
		//Limpa o objeto	
		oMessage:Clear()

		//Popula com os dados de envio	
		oMessage:cFrom 		:= cFrom
		oMessage:cTo 		:= StrTran(cEmail,",",";")
		oMessage:cCc 		:= StrTran(cEmailCC,",",";")
		oMessage:cBcc 		:= StrTran(cEmailBCC,",",";")
		oMessage:cSubject 	:= cAssunto	
		oMessage:cBody 		:= cHTML
		oMessage:MsgBodyType("text/html")
			
		//Adiciona um anexo
		For nFile:=1 to Len(aAnexos)
			cAnexo := aAnexos[nFile]
			If !Empty(cAnexo)
				If oMessage:AttachFile( cAnexo ) < 0
					cMsg := "Erro ao anexar o arquivo"					
					saveError(cMsg)
					Return .F.	
				Else
					//adiciona uma tag informando que é um anexo e o nome do arq		
					oMessage:AddAtthTag( "Content-Disposition: attachment; filename=" + cAnexo )	
				EndIf
			Endif
		Next nFile
		
		//Adiciona um anexo, nesse caso a imagem esta no root
		//oMessage:AttachFile( '\siga.jpg' )
	
		//Essa tag, é a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML      
		//oMessage:AddAttHTag( 'Content-ID: <ID_siga.jpg>' )            	
		
		// Para solicitar confimação de envio      
		//oMessage:SetConfirmRead( .T. )	
	
		showLogInConsole("[SEND] Sending ...")	
		nRet := oMessage:Send( oServer )	
		If ( nRet <> 0 )			
			cMsg := "[SEND][ERROR] Fail to send message - " + str(nRet,6) + " - " + oServer:GetErrorString(nRet)			
			saveError(cMsg)
		Else		
			showLogInConsole( "[SEND] Sucess to send message" )
			lRet := .T.	
		EndIf	
		
		showLogInConsole("[DISCONNECT] SMTP disconnecting ... ")	
		nRet := oServer:SmtpDisconnect()	
		If ( nRet <> 0 )			
			cMsg := "[DISCONNECT][ERROR] Fail SMTP disconnecting - " + str(nRet,6) + " - " + oServer:GetErrorString(nRet)
			saveError(cMsg)
		Else		
			showLogInConsole("[DISCONNECT] Sucess SMTP disconnecting ... ")	
		EndIf
	Endif
	
Return lRet

/*
	Mostra o Erro no Console e grava no Help da função do Protheus
*/
Static Function saveError(cMsg)

	showLogInConsole(cMsg)

	If IsBlind()
		Help(,,"HELP",,cMsg,1,0)
	Endif
	
Return

/*
    exibe uma mensagem no console
*/
Static Function showLogInConsole(cTexto)
    Local aArea    := GetArea()
    Default cTexto := ""
     
    FWLogMsg("INFO",,"showLogInConsole",,,,cTexto,,,) 
     
    RestArea(aArea)
Return
