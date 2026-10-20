#include 'protheus.ch'
#include 'topconn.ch'

User Function MT107QRY 
Local cQuery := ""
Local cAdmin := '000000'

If !__cUserId$cAdmin //!(FWIsAdmin(__cUserID ))
	cQuery += " EXISTS (	" + CRLF
	cQuery += "	SELECT *    " + CRLF
	cQuery += "	FROM "+ retSqlTab("SDW") + " " + CRLF
	cQuery += "	WHERE 1=1 " + CRLF
	cQuery += "	AND " + retSqlDel("SDW") + CRLF
	cQuery += "	AND " + retSqlFil("SDW") + " " + CRLF
	cQuery += "	AND DW_USER = CP_USER " + CRLF
	cQuery += "	AND DW_DOC = 'MTA105' " + CRLF
	cQuery += " AND DW_ZZAPROV ='" + RetCodUsr() + "' " + CRLF
	cQuery += "	) "
Endif

Return cQuery