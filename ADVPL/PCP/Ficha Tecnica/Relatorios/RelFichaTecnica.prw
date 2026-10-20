#include "totvs.ch"
#include "topconn.ch"
/*/{Protheus.doc} RelFichaTecnica
Relatório Ficha Técnica - TELAS
@type function
@author Tiago Faria
@since 19/01/2021
/*/
user function RelFichaTecnica(oReport)
	local cUserFunction := alltrim(getUserFunction())
	private oRpt := oReport

    if empty(cUserFunction)
        msgAlert("Não existe a função de usuário cadastrada no Template [CZD]")
    else
        if valType(oReport) == "O"
			oRpt := oReport
			cUserFunction := strTran(cUserFunction,"()","")
			cUserFunction += "(@oRpt)"
			&(cUserFunction)
			oReport := oRpt
		else
			&(cUserFunction)
		endif
    endif
return

static function getUserFunction(cIDs)
	local cAlias        := ""
	local cQuery        := ""
	local cUserFunction := ""

	cQuery += "SELECT " + CRLF
	cQuery += "	TOP 1 CZD_ZZFUNC" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("CZG") + CRLF

	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("CZD") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("CZD") + CRLF
	cQuery += "	AND CZD_CDMD = CZG_CDMD" + CRLF
	cQuery += "	AND " + retSqlDel("CZD") + CRLF

	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("CZG") + CRLF
	cQuery += "	AND CZG_CDAC = '" + CZG->CZG_CDAC + "'" + CRLF
	cQuery += "	AND CZG_CDMD = '" + CZG->CZG_CDMD + "'" + CRLF
	cQuery += "	AND CZG_VRFH = '" + CZG->CZG_VRFH + "'" + CRLF
	cQuery += "	AND " + retSqlDel("CZG") + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	cUserFunction := (cAlias)->(CZD_ZZFUNC)

	(cAlias)->(dbCloseArea())
return cUserFunction
