#include 'totvs.ch'
#include 'topconn.ch'

user function MTAREMOD()
	local cMOD      := ""

	cMOD := getNewMOD()

return cMOD

static function getNewMOD()
	local cQuery 	:= ""
	local cAlias 	:= ""
	local aArea  	:= Lj7GetArea({"SZ2"})
	local cRecurso  := PARAMIXB[1]
	local cHora		:= ""
	local cMOD		:= ""
	cQuery += "SELECT " + CRLF
	cQuery += "	Z2_TURNO, " + CRLF
	cQuery += "	HB_ZZMODT1, " + CRLF
	cQuery += "	HB_ZZMODT2, " + CRLF
	cQuery += "	HB_ZZMODT3, " + CRLF
	cQuery += "	HB_ZZMODT4 " + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT" + CRLF
	cQuery += "	DISTINCT" + CRLF
	cQuery += "	Z2_TURNO," + CRLF
	cQuery += "	CONVERT(TIME,'20200101 ' + Z2_HORAINI) AS HORAINI," + CRLF
	cQuery += "	CONVERT(TIME,'20200101 ' + Z2_HORAFIM) AS HORAFIM" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SZ2") + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SZ2") + CRLF
	cQuery += "	AND " + retSqlDel("SZ2") + CRLF
	cQuery += ") SZ2" + CRLF

	cQuery += "INNER JOIN " + CRLF
	cQuery += "	" + retSqlTab("SH1") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SH1") + CRLF
	cQuery += "	AND SH1.H1_CODIGO = '" + cRecurso + "'" + CRLF
	cQuery += "	AND " + retSqlDel("SH1") + CRLF

	cQuery += "INNER JOIN " + CRLF
	cQuery += "	" + retSqlTab("SHB") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SHB") + CRLF
	cQuery += "	AND HB_COD = H1_CTRAB" + CRLF
	cQuery += "	AND " + retSqlDel("SHB") + CRLF

	cQuery += "WHERE 1=1" + CRLF

	if Type("M->H6_HORAINI") == "C"
		cHora := M->H6_HORAINI
	else
		cHora := SH6->H6_HORAINI
	endif

	cQuery += "AND CONVERT(time,'" + cHora + "') BETWEEN HORAINI AND HORAFIM" + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())
	if (cAlias)->(!Eof())
		cMOD := (cAlias)->&("HB_ZZMODT" + (cAlias)->(Z2_TURNO))
	endif
	(cAlias)->(dbCloseArea())

	Lj7RestArea(aArea)
return cMOD
