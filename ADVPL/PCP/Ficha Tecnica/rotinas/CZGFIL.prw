#include 'totvs.ch'
#include 'topconn.ch'

static aMaxRecno := {}
static nSecUltExec := 0
/*/{Protheus.doc} CzGFil
Função para realizar filtro no browse para mostrar apenas o maior recno da 
@type function
@author Tiago Faria
@since 04/02/2021
/*/
User function CzGFil()
	local cRet := ""

    u_atuMaxRecno()

	cRet := "u_atuMaxRecno(),aScan(u_getMaxRecno(),{|nRecno| nRecno == CZG->(recno())}) > 0"
return cRet

user function getMaxRecno()
return aMaxRecno

user function atuMaxRecno()
	if (nSecUltExec - seconds()) <= 30 .or. nSecUltExec == 0
		aMaxRecno := {}
		getMaxRecno()
	endif
return

static function getMaxRecno()
	local cQuery := ""
	local cAlias := ""
	local aArea  := Lj7GetArea({"CZG"})

	cQuery += "SELECT" + CRLF
	cQuery += "	CZG_FILIAL," + CRLF
	cQuery += "	CZG_CDAC," + CRLF
	cQuery += "	CZG_CDRC," + CRLF
	cQuery += "	CZG_CDMD," + CRLF
	cQuery += "	CZG_VRFH," + CRLF
	cQuery += "	MAX(R_E_C_N_O_) AS RECNO" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + retSqlTab("CZG") + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("CZG") + CRLF
	cQuery += "	AND " + retSqlDel("CZG") + CRLF
	cQuery += "GROUP BY" + CRLF
	cQuery += "	CZG_FILIAL," + CRLF
	cQuery += "	CZG_CDAC," + CRLF
	cQuery += "	CZG_CDRC," + CRLF
	cQuery += "	CZG_CDMD," + CRLF
	cQuery += "	CZG_VRFH" + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	while (cAlias)->(!Eof())
		aAdd(aMaxRecno,(cAlias)->(RECNO))
		(cAlias)->(dbSkip())
	enddo

	(cAlias)->(dbCloseArea())
	Lj7RestArea(aArea)
	nSecUltExec := seconds()
return
