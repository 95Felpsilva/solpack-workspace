#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

/*/{Protheus.doc} getTurnoApontamento
Rotorna o turno com base na hora informada

@author Gabriel Pereira Santos
@since 08/05/2023
@version 1.0
@return character, retorna o código o turno

@type function
/*/
User Function getTurnoApontamento(cHora)
	local cQuery 	:= ""
	local cAlias 	:= ""
	local aArea	 	:= Lj7GetArea({"ZZ7"})
	local cTurno    := IIF(FwIsInCallStack("U_SolTurno"), "", "1")
	
    Default cHora 	:= "00:00"

    cQuery += " SELECT " + CRLF
    cQuery += " 	TOP 1 ZZ7_ID " + CRLF
    cQuery += " FROM " + CRLF
    cQuery += " 	" + RetSqlTab("ZZ7") + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += " 	1 = 1 " + CRLF
    cQuery += " 	AND " + RetSqlFil("ZZ7") + CRLF
    cQuery += " 	AND CONVERT(time,"+ValToSql(cHora)+") BETWEEN CONVERT(time,ZZ7_HORAIN) AND CONVERT(TIME,ZZ7_HORAFI) " + CRLF
    cQuery += " 	AND ZZ7_MSBLQL = '2' " + CRLF
    cQuery += " 	AND " + RetSqlDel("ZZ7") + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())

    If (cAlias)->(!Eof())
        cTurno := (cAlias)->(ZZ7_ID)
    EndIf    

	(cAlias)->(dbCloseArea())

	Lj7RestArea(aArea)
Return cTurno
