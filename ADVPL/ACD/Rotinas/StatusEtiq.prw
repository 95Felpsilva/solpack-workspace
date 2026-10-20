#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc}	StatusEtiq
Rotina que ativa e inativa etiquetas

@author			Julio Lisboa - FSW TOTVS IP Campinas
@since				10/08/2015
@return			nil
/*/
User Function StatusEtiq()

	Local 		aParambox	:= {}
	Private	aOpc		:= {}

	//Monta as Opções do motivo
	montaOpc()

	Aadd(aParambox,{2,"Função","1",{"INATIVAR","ATIVAR"},50,,.T.})// MV_PAR01
	Aadd(aParambox,{1,"Etiqueta"	,Space(TamSX3("CB0_CODETI")[1]),"","","CB0","",50,.T.})// MV_PAR02
	Aadd(aParambox,{2,"Observação","1",aOpc,90,,.T.})// MV_PAR03

	If ParamBox(aParambox,"INATIV ETIQU",,,,,,,,"INATETQ",.T.,.T.)
		Processa({|| trataEtiq()})
	EndIf

Return

/*/{Protheus.doc}	trataEtiq
Trata as etiquetas selecionadas

@author			Julio Lisboa - FSW TOTVS IP Campinas
@since				10/08/2015
@return			nil
/*/
Static Function trataEtiq()

	Local aAreaCB0	:= CB0->(GetArea())
	Local cQuery		:= ""
	Local cTexto		:= ""
	Local cMsg			:= ""
	Local cObserv		:= ""
	Local cStatus		:= IIF(AllTrim(MV_PAR01) == "INATIVAR","1","")
	Local cAlias		:= GetNextAlias()
	Local nCont		:= 0
	Local nRegs		:= 0

	cQuery := "SELECT " + CRLF
	cQuery += "	CB0_CODETI" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + RetSqlName("CB0") + " AS CB0 " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "	CB0_FILIAL = '" + xFilial("CB0") + "' AND " + CRLF
	cQuery += "	CB0_CODETI = '" + MV_PAR02 + "' AND " + CRLF
	cQuery += "	CB0.D_E_L_E_T_ = ' ' " + CRLF

	TcQuery cQuery New Alias &cAlias
	Count to nRegs
	(cAlias)->(DbGoTop())

	If (cAlias)->(!Eof())
		While (cAlias)->(!Eof())

			CB0->(DbSetOrder(1))
			If CB0->(DbSeek(xFilial("CB0") + (cAlias)->CB0_CODETI))

				//Observação da baixa
				cObserv := DTOC(dDataBase) + " - " + Time() + " - " + AllTrim(MV_PAR03) + " - " + AllTrim(UsrRetName(__cUserID))

				RecLock("CB0",.F.)
				CB0->CB0_STATUS 	:= cStatus
				CB0->CB0_ZZOBS	:= cObserv
				CB0->(MsUnlock())
				nCont ++
				cMsg += "Etiqueta " + AllTrim((cAlias)->CB0_CODETI) + " processada." + CRLF
			EndIf

			IncProc()
			(cAlias)->(DbSkip())
		EndDo

		cTexto := "[" + DTOC(dDataBase) + "] " + Time() + " - " + cValToChar(nCont) + " etiquetas " + IIF(AllTrim(MV_PAR01)=="INATIVAR","INATIVADAS","ATIVADAS") + CRLF + CRLF
		cTexto += cMsg

		Aviso("Processo Finalizado",cTexto,{"OK"},3)
	EndIf

	(cAlias)->(DbCloseArea())
	RestArea(aAreaCB0)

Return

Static Function montaOpc()
	local aZ1			:= FWGetSX5("Z1")
	local nZ1			:= 0
	local cDescricao 	:= ""

	for nZ1 := 1 to len(aZ1)
		cDescricao := alltrim(aZ1[nZ1,4])
		Aadd(aOpc,cDescricao)
	next nZ1
Return
