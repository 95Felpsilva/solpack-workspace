#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc}	MT680VAL
É chamado na confirmação da inclusão das produções PCP, modelo I e II (função A680TudoOk()).
É utilizado para validar a inclusão do apontamento das produções PCP.
f
@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					06/07/2015
@return				lRet
/*/
User Function MT680VAL()
	Local lRet		:= .T.
	local cTipPro	:= ""
	local aAux		:= {}

	if funname() == "MATA682"
		lRet := u_apParada()
	else
		If isLastOp()
			If ExistBlock("TelaReqMan")
				FWMsgRun( ,{ || lRet := U_TelaReqMan() } ,"TELAREQMAN", "Aguarde realizando a requisição manual"  )
			EndIf
		EndIf

		if lRet .and. u_isImpEtq(M->H6_OP,M->H6_PRODUTO,M->H6_OPERAC)
			FWMsgRun( ,{ || lRet := u_ApApara() } ,"AP APARA", "Aguarde realizando o apontamento de apara"  )
		endif
	endif
	//chama as validacoes dos campos H6_DATAINI e H6_HORAINI pois há casos em que o sistema não está validando a data e hora inicial/final
	//deixando a data inicial maior que a data final por exemplo
	if lRet
		lRet := a680Data() .and. a680Hora()
	endif

	if lRet
		if ExistBlock("AppVldSaldo") .and. FwIsInCallStack("ApontaOrdem")
			cTipPro := Posicione("SB1", 1, FWxFilial("SB1") + M->H6_PRODUTO, "B1_TIPO")

			// Só faz a validação de saldo para os produtos do tipo PA.
			if cTipPro == "PA"
				lRet := u_AppVldSaldo(M->H6_OP, M->H6_PRODUTO, M->H6_OPERAC, M->H6_QTDPROD)

				if FwIsInCallStack("ApontaOrdem")
					lSaldo := lRet
				endif
			endif
		endif
	endif

	if lRet
		if ExistBlock("GrvCpoOP1")
			u_GrvCpoOP1(M->H6_OP, M->H6_QTDPROD, .f., M->H6_OPERAC)
		endif

		if Empty(M->H6_XOPERA)
			M->H6_XOPERA := AllTrim(Posicione("SZZ", 1, FWxFilial("SZZ") + M->H6_ZZOPER, "ZZ_NOME"))
		endif

		if FwIsInCallStack("ApontaCodBar")
			aAux := GetHoras()

			M->H6_HORAINI := aAux[1]
			M->H6_HORAFIN := aAux[2]
		endif
	endif
Return (lRet)

static function GetHoras()
	local cAlias 	:= ""
	local cQuery 	:= ""
	local aRet		:= {}

	cQuery += "SELECT " + CRLF
    cQuery += "		ZZ7_ID," + CRLF
    cQuery += "		RTRIM(LTRIM(ZZ7_HORAIN)) AS HORA_INI," + CRLF
    cQuery += "		RTRIM(LTRIM(ZZ7_HORAFI)) AS HORA_FIM" + CRLF

    cQuery += "FROM " + RetSqlTab("ZZ7") + "" + CRLF

    cQuery += "WHERE" + CRLF
    cQuery += "		1 = 1" + CRLF
    cQuery += "		AND ZZ7.ZZ7_FILIAL = '" + FWxFilial("ZZ7") + "'" + CRLF
    cQuery += "		AND ZZ7.ZZ7_MSBLQL <> '1'" + CRLF
	cQuery += "		AND CONVERT(time,'" + M->H6_HORAINI + "') BETWEEN CONVERT(time,ZZ7_HORAIN) AND CONVERT(TIME,ZZ7_HORAFI)"
    cQuery += "		AND ZZ7.D_E_L_E_T_ = ' '" + CRLF

	TcQuery cQuery new alias (cAlias := GetNextAlias())

	if (cAlias)->(!Eof())
		aAdd(aRet, (cAlias)->HORA_INI)
		aAdd(aRet, (cAlias)->HORA_FIM)
	endif

	(cAlias)->(DbCloseArea())
return aRet

/*/{Protheus.doc}	isLastOp
Função que valida se a operação em que o usuário realizou o
apontamento é a Ultima operação do produto

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					07/12/2015
@return				lRet
/*/
Static Function isLastOp()

	Local lRet			:= .F.
	Local cQuery		:= ""
	Local cAlias		:= GetNextAlias()
	Local aAreaAtu	:= GetArea()

	cQuery += "SELECT " + CRLF
	cQuery += "	MAX(G2_OPERAC) AS OPERAC" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + RetSqlName("SG2") + " AS SG2" + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "	G2_FILIAL = '" + xFilial("SG2") + "' AND" + CRLF
	cQuery += "	G2_PRODUTO = '" + M->H6_PRODUTO + "' AND" + CRLF
	cQuery += "	SG2.D_E_L_E_T_ = ' '" + CRLF

	TcQuery cQuery New Alias &cAlias

	If (cAlias)->(!Eof())
		(cAlias)->(DbGoTop())
		//Verifica para ver se foi encontrado registro
		If !Empty((cAlias)->OPERAC)
			If (cAlias)->OPERAC == M->H6_OPERAC
				lRet := .T.
			EndIf
		EndIf
	EndIf

	(cAlias)->(DbCloseArea())

	RestArea(aAreaAtu)

Return (lRet)
