#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc}	valDatHr
Rotina que busca a hora final do ultimo apontamento da OP
Chamado no gatilho da Operaçao no apontamento MOD 2

@author			Julio Lisboa - FSW TOTVS IP Campinas
@since				24/06/2015
@return			nil
/*/
User Function valDatHr()

	Local aAreaAtu		:= GetArea()
	Local aAreaSH6		:= SH6->(GetArea())
	Local cRet				:= ""

	Private cUlHrFim		:= ""

	if isInCallStack("U_APCODBAR")
		cRet := M->H6_HORAINI
	else
		If buscaUltHora()
			cRet := cUlHrFim
		EndIf
	endif

	RestArea(aAreaSH6)
	RestArea(aAreaAtu)

Return (cRet)

/*/{Protheus.doc}	buscaUltHora
Busca hora final do ultimo apontamento

@author			Julio Lisboa - FSW TOTVS IP Campinas
@since				24/06/2015
@return			lRet
/*/
Static Function buscaUltHora()

	Local cQuery 		:= ""
	Local cAlias		:= GetNextAlias()
	Local lRet			:= .F.

	cQuery += "SELECT " + CRLF
	cQuery += "	TOP 1" + CRLF
	cQuery += "	MAX(H6_DATAFIN) AS H6_DATAFIN," + CRLF
	cQuery += "	SH6.H6_OP," + CRLF
	cQuery += "	SH6.H6_OPERAC," + CRLF
	cQuery += "	(" + CRLF
	cQuery += "		SELECT" + CRLF
	cQuery += "			MAX(H6_HORAFIN)" + CRLF
	cQuery += "		FROM" + CRLF
	cQuery += "			" + RetSqlName("SH6") + " AS SH6TMP" + CRLF
	cQuery += "		WHERE" + CRLF
	cQuery += "			SH6TMP.H6_FILIAL = '" + xFilial("SH6") + "' AND " + CRLF
	cQuery += "			SH6TMP.H6_OP = SH6.H6_OP AND " + CRLF
	cQuery += "			SH6TMP.H6_OPERAC = SH6.H6_OPERAC AND " + CRLF
	cQuery += "			SH6TMP.H6_DATAFIN = SH6.H6_DATAFIN AND " + CRLF
	cQuery += "			SH6TMP.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	) AS ULTHORA," + CRLF
	cQuery += "	(" + CRLF
	cQuery += "		SELECT" + CRLF
	cQuery += "			MAX(H6_RECURSO)" + CRLF
	cQuery += "		FROM" + CRLF
	cQuery += "			" + RetSqlName("SH6") + " AS SH6TMP" + CRLF
	cQuery += "		WHERE" + CRLF
	cQuery += "			SH6TMP.H6_FILIAL = '" + xFilial("SH6") + "' AND " + CRLF
	cQuery += "			SH6TMP.H6_OP = SH6.H6_OP AND " + CRLF
	cQuery += "			SH6TMP.H6_OPERAC = SH6.H6_OPERAC AND " + CRLF
	cQuery += "			SH6TMP.H6_DATAFIN = SH6.H6_DATAFIN AND " + CRLF
	cQuery += "			SH6TMP.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	) AS ULTRECURSO" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + RetSqlName("SH6") + " AS SH6 " + CRLF
	cQuery += "	WHERE " + CRLF
	cQuery += "	H6_FILIAL = '" + xFilial("SH6") + "' AND " + CRLF
	cQuery += "	H6_OP = '" + M->H6_OP + "  ' AND " + CRLF
	cQuery += "	H6_OPERAC = '" + M->H6_OPERAC + "' AND " + CRLF
	cQuery += "	SH6.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "GROUP BY" + CRLF
	cQuery += "	SH6.H6_OP," + CRLF
	cQuery += "	SH6.H6_OPERAC," + CRLF
	cQuery += "	SH6.H6_DATAFIN" + CRLF
	cQuery += "ORDER BY" + CRLF
	cQuery += "   SH6.H6_DATAFIN DESC" + CRLF

	TcQuery cQuery New Alias &cAlias

	If (cAlias)->(!Eof())
		lRet 		:= .T.
		cUlHrFim	:= (cAlias)->ULTHORA
		if empty(M->H6_RECURSO) .and. !empty((cAlias)->ULTRECURSO)
			M->H6_RECURSO := (cAlias)->ULTRECURSO
		endif

		M->H6_ZZOPER := u_getOperadorTurno(cUlHrFim,M->H6_RECURSO)
	EndIf

	(cAlias)->(DbCloseArea())

Return (lRet)
