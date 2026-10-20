#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} GeraSB5
Rotina que gera o complemento de produtos

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			24/07/2015
@return 		nil
/*/
User Function GeraSB5()
	
	Local cMsgAviso		:= ""
	
	cMsgAviso += "Essa rotina tem como objetivo gerar o complemento dos produtos (SB5) daqueles que ainda não possuem." + CRLF
	cMsgAviso += "Deseja continuar ? "
	
	If MsgNoYes(cMsgAviso)
		Processa({||geraComple()})
	EndIf	
	
Return

/*/{Protheus.doc} geraComple
Geração do complemento de produtos

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			24/07/2015
@return 		nil
/*/
Static Function geraComple()
	
	Local aAreaAtu		:= GetArea()
	Local aAreaSB1		:= SB1->(GetArea())
	Local aAreaSB5		:= SB5->(GetArea())
	
	Local cQuery			:= ""
	Local cTexto			:= ""
	Local cLog				:= ""
	Local nQtdReg			:= 0
	Local nQtdOK			:= 0
	Local aCab				:= {}
	
	Private lMsErroAuto	:= .F.
	
	cQuery += "SELECT" + CRLF
	cQuery += "	B1_COD, B1_DESC" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + RetSqlName("SB1") + " AS SB1" + CRLF
	cQuery += "LEFT JOIN" + CRLF
	cQuery += "	" + RetSqlName("SB5") + " AS SB5" + CRLF
	cQuery += "ON" + CRLF
	cQuery += "	B5_FILIAL = '" + xFilial("SB5") + "' AND" + CRLF
	cQuery += "	B5_COD = B1_COD AND" + CRLF
	cQuery += "	SB5.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "WHERE" + CRLF
	cQuery += "	B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
	cQuery += "	B1_MSBLQL = '2' AND " + CRLF
	cQuery += "	B5_COD IS NULL AND " + CRLF
	cQuery += "	SB1.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "ORDER BY" + CRLF
	cQuery += "	B1_COD" + CRLF
	
	If Select("TMPSB5") > 0
		TMPSB5->(DbCloseArea())
	EndIf
	
	TcQuery cQuery New Alias "TMPSB5"
	
	Count to nQtdReg
	ProcRegua(nQtdReg)
	
	TMPSB5->(DbGoTop())
	
	If TMPSB5->(!Eof())
		While TMPSB5->(!Eof())
			
			//Adiciona as informações no array
			aCab := {;
					{"B5_COD",			TMPSB5->B1_COD,		nil},;
					{"B5_CEME",		TMPSB5->B1_DESC,		nil},;
					{"B5_IMPETI",		"2",					nil}}
			
			//Chama a rotina automática
			MSExecAuto({|x,y| Mata180(x,y)},aCab,3)
			
			If lMsErroAuto	
				MostraErro()
			Else
				cLog += "[" + DTOC(dDataBase) + " - " + Time() + "] - Produto: " + AllTrim(TMPSB5->B1_COD) + CRLF
				nQtdOK++
			Endif  
			
			//Limpa o array da rotina automática
			aCab := {}
			
			IncProc()
			TMPSB5->(DbSkip())
		EndDo
	EndIf
	
	cTexto += "Produtos sem complementos: " + cValToChar(nQtdReg) + CRLF
	cTexto += "Produtos Gerados SB5: " + cValToChar(nQtdOK) + CRLF
	cTexto += CRLF
	cTexto += cLog
	
	Aviso("Geração de Etiquetas",cTexto,{"Ok"},3)
	
	TMPSB5->(DbCloseArea())
	
	RestArea(aAreaSB5)
	RestArea(aAreaSB1)
	RestArea(aAreaAtu)
	
Return
