#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc}	gatDtIniOper
Função que gatilha o campo de data inicial do ultimo apontamento
buscando a data final da ultima operação

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					06/07/2015
@return				dRet
/*/
User Function gatDtIniOper()

	Local aAreaAtu	:= GetArea()
	Local aAreaSH6	:= SH6->(GetArea())
	Local cQuery		:= ""
	Local cAlias		:= GetNextAlias()
	Local dRet			:= dDataBase

	cQuery := "SELECT " + CRLF
	cQuery += "	MAX(H6_DATAFIN) AS DATAFIN" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + RetSqlName("SH6") + " AS SH6 " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "	H6_FILIAL = '" + xFilial("SH6") + "' AND " + CRLF
	cQuery += "	H6_OP = '" + M->H6_OP + "' AND " + CRLF
	cQuery += "	H6_OPERAC = '" + M->H6_OPERAC + "' AND " + CRLF
	cQuery += "	SH6.D_E_L_E_T_ = ' '" + CRLF

	TcQuery cQuery New Alias &cAlias
	
	If (cAlias)->(!Eof())
		If !Empty((cAlias)->DATAFIN)
			dRet := STOD((cAlias)->DATAFIN)
		EndIf
	EndIf

	(cAlias)->(DbCloseArea())

	RestArea(aAreaSH6)
	RestArea(aAreaAtu)

Return (dRet)
