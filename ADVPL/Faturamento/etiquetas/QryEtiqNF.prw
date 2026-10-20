#include 'totvs.ch'
#include 'TopConn.ch'
/*/{Protheus.doc} QryEtiqNF
Query para realizar a impressão das etiquetas
@type function
@author Tiago Faria
@since 25/05/2021
@param lRetquery, logical, se true retorna query se false retorna o alias
@return character, retorna o alias da query
/*/
user function QryEtiqNF(lRetQuery,cRecnos,lMark)
	local cQuery := ""
	local cAlias := ""
	default lMark := .f.

	cQuery += "SELECT" + CRLF
	if lMark
		cQuery += "	'CHECKED' AS MARKCOL," + CRLF
	else
		cQuery += "	'UNCHECKED' AS MARKCOL," + CRLF
	endif
	
	cQuery += "	D2_DOC AS DOC," + CRLF
	cQuery += "	D2_SERIE AS SERIE," + CRLF
	cQuery += "	D2_ITEM AS ITEM," + CRLF
	cQuery += "	B1_COD AS PRODUTO," + CRLF
	cQuery += "	B1_DESC AS DESCRICAO," + CRLF
	cQuery += "	CASE" + CRLF
	cQuery += "		WHEN B1_QE <> 0 THEN D2_QUANT / B1_QE" + CRLF
	cQuery += "		ELSE 1" + CRLF
	cQuery += "	END AS QTD_ETIQUETA," + CRLF
	cQuery += "	B1_CODBAR AS EAN," + CRLF
	cQuery += "	SB1.R_E_C_N_O_ AS B1RECNO," + CRLF
	cQuery += "	SD2.R_E_C_N_O_ AS D2RECNO," + CRLF
	cQuery += "	CASE" + CRLF
	cQuery += "		WHEN B1_QE <> 0 THEN D2_QUANT / B1_QE" + CRLF
	cQuery += "		ELSE 1" + CRLF
	cQuery += "	END AS QTD_ORIGINAL," + CRLF
	cQuery += "	COALESCE(B1_CODBAR,'') AS EAN_ORIGINAL," + CRLF
	cQuery += "	D2_CLIENTE AS CLIENTE," + CRLF
	cQuery += "	D2_LOJA AS LOJA" + CRLF

	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SD2") + CRLF

	cQuery += "INNER JOIN " + CRLF
	cQuery += "	" + retSqlTab("SB1") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SB1") + CRLF
	cQuery += "	AND B1_COD = D2_COD" + CRLF
	cQuery += "	AND " + retSqlDel("SB1") + CRLF

	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SD2") + CRLF
	cQuery += "	AND D2_DOC = '" + SF2->F2_DOC + "'" + CRLF
	cQuery += "	AND D2_SERIE = '" + SF2->F2_SERIE + "'" + CRLF
	cQuery += "	AND D2_TIPO = 'N'" + CRLF

	if !empty(cRecnos)
		cQuery += "	AND SD2.R_E_C_N_O_ IN (" + cRecnos +")" + CRLF
	endif

	cQuery += "	AND " + retSqlDel("SD2") + CRLF
	cQuery += "ORDER BY D2_FILIAL,D2_DOC,D2_SERIE,D2_ITEM" + CRLF

	if lRetQuery
		return cQuery
	endif

	TcQuery cQuery new Alias (cAlias := getNextAlias())

return cAlias
