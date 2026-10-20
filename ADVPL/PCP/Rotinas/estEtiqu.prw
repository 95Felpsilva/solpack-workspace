#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} estEtiqu
Rotina utilizado após o estorno do apontamento, para limpar
o NUMSEQ das etiquetas daquele apontamento

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			24/07/2015
@return 		lRet
/*/
User Function estEtiqu()
	
	Local aAreaAtu		:= GetArea()
	Local aAreaSH6		:= SH6->(GetArea())
	Local aAreaCB0		:= CB0->(GetArea())
	
	Local nRecnoSH6		:= SH6->(Recno())
	Local cQuery			:= ""
	Local cAliasCB0		:= GetNextAlias()
	
	cQuery += "SELECT " + CRLF
	cQuery += "	CB0_CODETI" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + RetSqlName("CB0") + " AS CB0 " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "	CB0_FILIAL = '" + xFilial("CB0") + "' AND " + CRLF
	cQuery += "	CB0_ZZREC = '" + cValToChar(nRecnoSH6) + "' AND " + CRLF
	cQuery += "	CB0.D_E_L_E_T_ = ' '" + CRLF
	
	TcQuery cQuery New Alias &cAliasCB0
	
	If (cAliasCB0)->(!Eof())
		While (cAliasCB0)->(!Eof())
			
			CB0->(DbSetOrder(1)) //CB0_FILIAL+CB0_CODETI
			If CB0->(DbSeek(xFilial("CB0") + (cAliasCB0)->CB0_CODETI))
				FwLogMsg("INFO", /*cTransactionId*/, "ESTETIQU", FunName(), "", "01", "Etiqueta: " + CB0->CB0_CODETI, 0, seconds() , {}) // nStart é declarada no inicio da função
				
				RecLock("CB0",.F.)
				CB0->CB0_NUMSEQ := ""
				CB0->CB0_STATUS := "9"
				CB0->(MsUnlock())
			EndIf
			
			(cAliasCB0)->(DbSkip())
		EndDo
	EndIf
	
	(cAliasCB0)->(DbCloseArea())
	
	RestArea(aAreaCB0)
	RestArea(aAreaSH6)
	RestArea(aAreaAtu)
	
Return
