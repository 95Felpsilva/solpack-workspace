#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

/*/{Protheus.doc} vldPendenciaOP
Valida se há pendencias no apontamento da OP
@author Tiago Faria
@since 18/10/2019
@version 1.0
@return lRet, logico, se true a pendencias se false nao há

@type function
/*/
user function vldPendenciaOP(cOP)
	local lRet 		:= .t.
	local cQuery 	:= ""
	local cAlias	:= ""
	default cOP 	:= ""
	
	cQuery += "SELECT" + CRLF
	cQuery += "	SH6.H6_FILIAL," + CRLF
	cQuery += "	SH6.H6_OP," + CRLF
	cQuery += "	SUM(SH6.H6_QTDPROD-SH6.H6_QTDPERD) AS QTDPROD01," + CRLF
	cQuery += "	COALESCE(SUM(H6OPER2.H6_QTDPROD),0)  AS QTDPROD02," + CRLF
	cQuery += "	SUM(CASE WHEN SH6.H6_ZZREVIS = 'T' THEN SH6.H6_QTDPROD-SH6.H6_QTDPERD ELSE 0 END + COALESCE(QTD_PENDENCIA,0)) AS PENDENCIA" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SH6") + CRLF
	cQuery += "LEFT JOIN" + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT" + CRLF
	cQuery += "	SH6.H6_FILIAL," + CRLF
	cQuery += "	SH6.H6_OP," + CRLF
	cQuery += "	SH6.H6_OPERAC," + CRLF
	cQuery += "	SUM(H6_QTDPROD-H6_QTDPERD) AS H6_QTDPROD," + CRLF
	cQuery += "	SUM(CASE WHEN H6_ZZREVIS = 'T' THEN H6_QTDPROD-H6_QTDPERD ELSE 0 END) AS QTD_PENDENCIA" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SH6") + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND SH6.H6_FILIAL = '" + xFilial("SH6") + "'" + CRLF
	cQuery += "	AND SH6.H6_OP = '" + cOP + "'" + CRLF
	cQuery += "	AND SH6.H6_OPERAC = '02'" + CRLF
	cQuery += "	AND " + retSqlDel("SH6") + CRLF
	cQuery += "GROUP BY" + CRLF
	cQuery += "	SH6.H6_FILIAL," + CRLF
	cQuery += "	SH6.H6_OP," + CRLF
	cQuery += "	SH6.H6_OPERAC" + CRLF
	cQuery += ") H6OPER2 " + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND H6OPER2.H6_FILIAL = SH6.H6_FILIAL" + CRLF
	cQuery += "	AND H6OPER2.H6_OP = SH6.H6_OP" + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND SH6.H6_FILIAL = '" + xFilial("SH6") + "'" + CRLF
	cQuery += "	AND SH6.H6_OP = '" + cOP + "'" + CRLF
	cQuery += "	AND SH6.H6_OPERAC = '01'" + CRLF
	cQuery += "	AND " + retSqlDel("SH6") + CRLF
	cQuery += "GROUP BY" + CRLF
	cQuery += "	SH6.H6_FILIAL," + CRLF
	cQuery += "	SH6.H6_OP," + CRLF
	cQuery += "	SH6.H6_OPERAC" + CRLF
	cQuery += "ORDER BY H6_OP DESC" + CRLF
	
	TcQuery cQuery new Alias (cAlias := getNextAlias())
	
	if (cAlias)->(!Eof()) .and. (cAlias)->(PENDENCIA) > 0
		u_myHelp("A OP " + cOP + " esta com apontamentos em revisão!")
		lRet := .f.
	endif
	
return lRet