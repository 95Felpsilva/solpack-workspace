#Include "Protheus.ch"
#Include "Topconn.ch"

User Function SldPedido()
	
	Local nQtdPed	:= 0
	Local nRet		:= 0
	Local cQuery	:= ""
	Local cAlias	:= GetNextAlias()	
	
	cQuery := "SELECT" + CRLF
	cQuery += "	SUM(C6_QTDVEN - C6_QTDENT) AS QUANT" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + RetSqlName("SC6") + " AS SC6" + CRLF
	cQuery += "WHERE" + CRLF
	cQuery += "	C6_FILIAL = '" + xFilial("SC6") + "' AND" + CRLF
	cQuery += "	C6_PRODUTO = '" + SB8->B8_PRODUTO + "' AND" + CRLF
	cQuery += "	C6_LOCAL = '" + SB8->B8_LOCAL + "' AND" + CRLF
	cQuery += "	C6_LOTECTL = '" + SB8->B8_LOTECTL + "' AND" + CRLF
	cQuery += "	(C6_QTDVEN - C6_QTDENT) > 0 AND" + CRLF
	cQuery += "	SC6.D_E_L_E_T_ = ' '" + CRLF
	
	TcQuery cQuery New Alias &cAlias
	
	If (cAlias)->(!Eof())
		nQtdPed := (cAlias)->QUANT
	EndIf
	
	nRet := SB8->B8_SALDO - nQtdPed
	
	(cAlias)->(DbCloseArea())
	
Return (nRet)
