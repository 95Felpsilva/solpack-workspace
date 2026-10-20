#INCLUDE "protheus.ch"

User Function MT240TOK()
	Local lRet	:= .T.
	
	if empty(M->D3_OP) .and. empty(M->D3_CC)			// Os dois campos vazios nao podem.
		Alert("Atenção," + CRLF + CRLF + 'Favor informar o Número da OP "D3_OP" ou o Centro de Custo "D3_CC".' + CRLF + 'Verifique!')
		lRet := .F.
	elseIf !empty(M->D3_OP) .and. !empty(M->D3_CC)		// Os dois campos preenchidos nao podem.
		Alert("Atenção," + CRLF + CRLF + 'Favor informar somente o Número da OP "D3_OP" ou o Centro de Custo "D3_CC".' + CRLF + 'Verifique!')
		lRet := .F.
	endIf
Return(lRet)
