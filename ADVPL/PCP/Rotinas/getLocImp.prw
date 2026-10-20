#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.ch'

/*/{Protheus.doc} getLocImp
Retorna o local de impressão
@author Tiago Faria
@since 15/07/2019
@version 1.0
@return cLocImp, caracter, retorna o id da CB5

@type function
/*/
user function getLocImp()
	local cLocImp 		:= ""
	local cServerIni 	:= getNewPar("ZZ_SPOOL","c:\mscbspool.ini")
	local cSecao		:= "setup"´
	local cChave		:= "fila"
	local cDefault		:= ""
	
	if file(cServerIni)
		cLocImp := GetPvProfString(cSecao, cChave, cDefault, cServerIni)
		if !empty(cLocImp)
			cLocImp := getCodCB5(cLocImp)
		endif
	else
		cLocImp := Space(TamSX3("CB5_CODIGO")[1])
	endif
return cLocImp

static function getCodCB5(cDescCB5)
	local cAlias 		:= ""
	local cQuery 		:= ""
	local cLocImp 		:= ""
	local aArea			:= Lj7GetArea({"CB5"})
	default cDescCB5 	:= ""
	
	cQuery += "SELECT" + CRLF
	cQuery += "	CB5_CODIGO" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("CB5") + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("CB5") + CRLF
	cQuery += "	AND CB5_DESCRI LIKE '%" + cDescCB5 + "%'" + CRLF
	cQuery += "	AND " + retSqlDel("CB5") + CRLF
	
	TcQuery cQuery new Alias (cAlias := getNextAlias())
	
	cLocImp := (cAlias)->(CB5_CODIGO)
	
	(cAlias)->(dbCloseArea())
	
	Lj7RestArea(aArea)
return cLocImp