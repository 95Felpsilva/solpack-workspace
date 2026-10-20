#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

/*/{Protheus.doc} getOperadorTurno
Retorna qual operador esta na máquina com base no cadastro de turno
@author Tiago Faria
@since 16/07/2019
@version 1.0
@return character, retorna o código do operador cadastro no turno

@type function
/*/
user function getOperadorTurno(cHora,cMaquina)
	local cQuery 	:= ""
	local cAlias 	:= ""
	local aArea	 	:= Lj7GetArea({"SZ2"})
	local cOperador := ""
	default cHora 	:= ""
	default cMaquina:= ""

	if funname() == "MATA682"
		return M->H6_ZZOPER
	endif

	if isInCallStack("U_APCODBAR") .and. type("M->H6_ZZOPER") == "C" .and. !empty(M->H6_ZZOPER)
		return M->H6_ZZOPER
	endif

	cQuery += "SELECT" + CRLF
	cQuery += "	Z2_OPERADO" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT" + CRLF
	cQuery += "	DISTINCT" + CRLF
	cQuery += "	Z2_TURNO AS TURNO," + CRLF
	cQuery += "	CONVERT(time,Z2_HORAINI) AS HRINI,	" + CRLF
	cQuery += "	CASE WHEN CONVERT(TIME,Z2_HORAFIM) < CONVERT(TIME,Z2_HORAINI) THEN convert(time,'23:59:59') ELSE CONVERT(TIME,Z2_HORAFIM) END AS HRFIM" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SZ2") + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SZ2") + CRLF
	cQuery += "	AND " + retSqlDel("SZ2") + CRLF
	cQuery += "UNION ALL" + CRLF
	cQuery += "SELECT" + CRLF
	cQuery += "	DISTINCT" + CRLF
	cQuery += "	Z2_TURNO," + CRLF
	cQuery += "	CONVERT(time,'00:00') AS HRINI," + CRLF
	cQuery += "	CONVERT(time,Z2_HORAFIM) AS HRFIM" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SZ2") + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SZ2") + CRLF
	cQuery += "	AND " + retSqlDel("SZ2") + CRLF
	cQuery += "	AND CONVERT(TIME,Z2_HORAFIM) < CONVERT(TIME,Z2_HORAINI)" + CRLF
	cQuery += ") TURNO" + CRLF
	cQuery += "INNER JOIN " + CRLF
	cQuery += "	" + retSqlTab("SZ2") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SZ2") + CRLF
	cQuery += "	AND Z2_TURNO = TURNO" + CRLF
	cQuery += "	AND convert(time,'" + cHora + "') BETWEEN HRINI AND HRFIM" + CRLF
	cQuery += "	AND Z2_MAQUINA = '" + cMaquina + "'" + CRLF
	cQuery += "	AND " + retSqlDel("SZ2") + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	cOperador := (cAlias)->(Z2_OPERADO)

	(cAlias)->(dbCloseArea())

	Lj7RestArea(aArea)
return cOperador
