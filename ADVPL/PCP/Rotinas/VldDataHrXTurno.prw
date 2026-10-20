#include 'totvs.ch'
#include 'topconn.ch'
/*/{Protheus.doc} vldDataHrXTurno
Valdia se a hora digitada esta dentro do horario definido nos turnos
Função chamada da validação de campo, dos campos
H6_HORAINI
H6_HORAFIN
@type function
@version 
@author Tiago Faria
@since 04/12/2020
@param dDataIni, date, Data inicio do apontametno
@param cHoraIni, character, Hora inicio do apontamento
@param dDataFim, date, Data Fim do apontamento
@param cHoraFim, character, Hora fim do apontamento
@return logico, se true os dados estao validos se false não estao
/*/
user function vldDataHrXTurno(dDataIni,cHoraIni,dDataFim,cHoraFim)
	local cAlias := ""
	local cQuery := ""
	local lret   := .t.
	default dDataIni := M->H6_DATAINI
	default cHoraIni := M->H6_HORAINI
	default cDataFim := M->H6_DATAFIN
	default cHoraFim := M->H6_HORAFIN

	if funName() <> "MATA682"
		cQuery += "SELECT DISTINCT" + CRLF
		cQuery += "    Z2_FILIAL," + CRLF
		cQuery += "    Z2_TURNO," + CRLF
		cQuery += "    Z2_HORAINI," + CRLF
		cQuery += "    Z2_HORAFIM " + CRLF
		cQuery += "FROM " + CRLF
		cQuery += "    " + retSqlTab("SZ2") + CRLF
		cQuery += "WHERE 1=1" + CRLF
		cQuery += "    AND " + retSqlFil("SZ2") + CRLF
		cQuery += "    AND ('" + cHoraIni + "' >= Z2_HORAINI AND '" + cHoraIni + "' <= Z2_HORAFIM)" + CRLF
		cQuery += "    AND ('" + cHoraFim + "' <= Z2_HORAFIM AND '" + cHoraFim + "' >= Z2_HORAINI)" + CRLF
		cQuery += "    AND " + retSqlDel("SZ2") + CRLF
		if !empty(strtran(cHoraIni,":")) .and. !empty(strtran(cHoraFim,":"))
			TcQuery cQuery new Alias (cAlias := getNextAlias())

			if (cAlias)->(eof())
				lRet := .f.
				u_myHelp("Horário digitado ultrapassa o horário do turno")
			endif
		endif
		if lRet .and. !empty(dDataIni) .and. !empty(dDataFim) .and. dDataIni <> dDataFim
			lRet := .f.
			u_myHelp("A data de inicio do apontamento não pode ser diferente a data fim do apontamento")
		endif
	endif
return lRet
