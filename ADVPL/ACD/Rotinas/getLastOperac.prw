#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc}	getLastOperac
Retorna a ultima operação do produto selecionado

@author			Julio Lisboa - FSW TOTVS IP Campinas
@since				27/07/2015
@return			cRet
/*/
User Function getLastOperac(cProduto)
	
	Local cRet			:= ""
	Local cQuery		:= ""
	Local cAlias		:= GetNextAlias()
	
	Default cProduto	:= ""
	
	If !Empty(cProduto)
		cQuery += "SELECT " + CRLF
		cQuery += "	MAX(G2_OPERAC) AS OPERAC" + CRLF
		cQuery += "FROM " + CRLF
		cQuery += "	" + RetSqlName("SG2") + " AS SG2" + CRLF
		cQuery += "WHERE " + CRLF
		cQuery += "	G2_FILIAL = '" + xFilial("SG2") + "' AND" + CRLF
		cQuery += "	G2_PRODUTO = '" + cProduto + "' AND" + CRLF
		cQuery += "	SG2.D_E_L_E_T_ = ' '" + CRLF
	
		TcQuery cQuery New Alias &cAlias
	
		If (cAlias)->(!Eof())
			cRet := (cAlias)->OPERAC
		EndIf
	
		(cAlias)->(DbCloseArea())
	EndIf

Return (cRet)

