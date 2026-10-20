#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc}	reImpEtq
Rotina que reimprime as etiquetas

@author			Julio Lisboa - FSW TOTVS IP Campinas
@since				14/07/2015
@return			nil
/*/
User Function reImpEtq()
	
	Local aAreaAtu		:= GetArea()
	Local aAreaCB0		:= CB0->(GetArea())
	Local aAreaSH6		:= SH6->(GetArea())
	Local aParambox		:= {}
	
	Private aDados		:= {}
	
	msgAlert("Rotina descontinuada!!!")
	return
	
	Aadd(aParambox,{2,"Imp. dados da empresa","1",{"SIM","NAO"},50,,.T.})// MV_PAR01
	Aadd(aParambox,{1,"Etiqueta De"	,Space(TamSX3("CB0_CODETI")[1]),"","","CB0","",50,.F.})// MV_PAR02
	Aadd(aParambox,{1,"Etiqueta Ate"	,Space(TamSX3("CB0_CODETI")[1]),"","","CB0","",50,.F.})// MV_PAR03
	Aadd(aParambox,{1,"Produto De"	,Space(TamSX3("CB0_CODPRO")[1]),"","","SB1","",55,.F.})// MV_PAR04
	Aadd(aParambox,{1,"Produto Ate"	,Space(TamSX3("CB0_CODPRO")[1]),"","","SB1","",55,.F.})// MV_PAR05
	Aadd(aParambox,{1,"Local De"	,Space(TamSX3("CB0_LOCAL")[1]),"","","NNR","",40,.F.})// MV_PAR06
	Aadd(aParambox,{1,"Local Ate"	,Space(TamSX3("CB0_LOCAL")[1]),"","","NNR","",40,.F.})// MV_PAR07
	Aadd(aParambox,{1,"Local de Impressao"	,Space(TamSX3("CB5_CODIGO")[1]),"","",	"CB5","",60,.T.})// MV_PAR08
	Aadd(aParambox,{2,"Etiquetas Validas","1",{"SIM","NAO"},50,,.T.})// MV_PAR09
	
	If ParamBox(aParambox,"REIMPRESSÃO ETIQUETA",,,,,,,,"REIMP",.T.,.T.)
		Processa({|| imprime()})
	EndIf
	
	RestArea(aAreaSH6)
	RestArea(aAreaCB0)
	RestArea(aAreaAtu)
	
Return

/*/{Protheus.doc}	imprime
Realiza a impressão das etiquetas

@author			Julio Lisboa - FSW TOTVS IP Campinas
@since				14/07/2015
@return			nil
/*/
Static Function imprime()
	
	Local nI				:= 0
	Local lImpCabec		:= IIF(MV_PAR01 == "SIM",.T.,.F.)
	Local cQuery			:= ""
	Local cAlias			:= GetNextAlias()
	Local nQtdReg			:= 0
	Local nTipo			:= 0
	Local nQuantEtq		:= 0
	
	//Seleciona o local de impressão
	If !CB5SetImp(MV_PAR08)
		MsgStop("Problemas no local de impressão!")
		return
	EndIf
	
	cQuery += "SELECT " + CRLF
	cQuery += "	*" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + RetSqlName("CB0") + " AS CB0 " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "	CB0_FILIAL = '" + xFilial("CB0") + "' AND " + CRLF
	cQuery += "	CB0_CODETI BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' AND " + CRLF
	cQuery += "	CB0_CODPRO BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' AND " + CRLF
	cQuery += "	CB0_LOCAL BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' AND " + CRLF
	
	If AllTrim(MV_PAR09) == "SIM"
		//cQuery += "	(CB0_STATUS = ' ' AND CB0_OPREQ = ' ' AND CB0_NFSAI = ' ') AND " + CRLF 
		cQuery += "	(CB0_STATUS = ' ' AND CB0_OPREQ = ' ' AND CB0_NFSAI = ' ' AND CB0_NUMSEQ <> ' ') AND " + CRLF // alterado em 20/08/2015 - Cristiano Pedroni
	EndIf
	
	//cQuery += "	CB0_NUMSEQ <> ' ' AND " + CRLF
	cQuery += "	CB0.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY" + CRLF
	cQuery += "	CB0_CODETI" + CRLF
	
	TcQuery cQuery New Alias &cAlias
	Count to nQtdReg
	(cAlias)->(DbGoTop())
	
	If (cAlias)->(!Eof())
		While (cAlias)->(!Eof())
			
			CB0->(DbSetOrder(1)) //CB0_FILIAL+CB0_CODETI
			If CB0->(DbSeek(xFilial("CB0") + (cAlias)->CB0_CODETI))
				
				//ETIQUETA QUE VEM DE APONTAMENTO DE OP
				If (cAlias)->CB0_ZZREC > 0
					SH6->(DbSetOrder(1))
					SH6->(DbGoTo((cAlias)->CB0_ZZREC))
					nTipo := 1
					nQuantEtq := 1
				
				//ETIQUETA QUE TEM OP MAS NÃO TEM APONTAMENTO
				ElseIf !Empty((cAlias)->CB0_OP)
					SC2->(DbSetOrder(1))
					If SC2->(DbSeek(xFilial("SC2") + (cAlias)->CB0_OP))
						nTipo := 3
						nQuantEtq := 1
					EndIf
					
				//ETIQUETA SEM ORDEM DE PRODUÇÃO
				ElseIf Empty((cAlias)->CB0_OP)
					nTipo 		:= 4
					nQuantEtq 	:= 1
				EndIf
				
				If nTipo > 0
					U_valImpEt(AllTrim((cAlias)->CB0_CODETI),nQuantEtq,lImpCabec,nTipo)
				EndIf
			EndIf
			
			nTipo := 0
			IncProc()
			(cAlias)->(DbSkip())
		EndDo
	Else
		MsgAlert("Não foram encontrados dados com os parâmetros informados.")
	EndIf
	
	(cAlias)->(DbCloseArea())
	
Return
