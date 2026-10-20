#INCLUDE "protheus.ch"

User Function MT241TOK()
	Local nI		:= 0
	Local nPosNumOP	:= 	aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D3_OP"})
	Local lRet		:= .T.

	for nI := 1 to len(aCols)
		if empty(cCC)
			if empty(aCols[nI, nPosNumOP])						// Os dois campos vazios nao podem.
				alert("Atenção," + CRLF + CRLF + 'Centro de Custo "D3_CC" sem conteúdo e Número da OP "D3_OP" do item ' + strZero(nI, 2) + ' não informado.' + CRLF + 'Verifique!')
				lRet := .F.
				Exit
			endIf
		else
			if !Empty(aCols[nI, nPosNumOP])						// Os dois campos preenchidos nao podem.
				alert("Atenção," + CRLF + CRLF + 'Centro de Custo "D3_CC" com conteúdo e Número da OP "D3_OP" do item ' + strZero(nI, 2) + ' também informado.' + CRLF + 'Verifique!')
				lRet := .F.
				Exit
			endIf
		endIf
	next nI
Return(lRet)
