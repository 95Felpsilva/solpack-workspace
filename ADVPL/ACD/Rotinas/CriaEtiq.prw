#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} CriaEtiq
Rotina com o objetivo de gerar as etiquetas baseadas na
tabela SBF

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			21/07/2015
@return 		nil
/*/
User Function CriaEtiq()
	
	Local cMsgAviso		:= ""
	
	cMsgAviso += "Essa rotina tem como objetivo gerar as etiquetas de produto acabado." + CRLF
	cMsgAviso += "Deseja continuar ? "
	
	If MsgNoYes(cMsgAviso)
		Processa({||iniGeracaoEtiq()})
	EndIf
	
Return

/*/{Protheus.doc} iniGeracaoEtiq
Função que gera as etiquetas

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			21/07/2015
@return 		nil
/*/
Static Function iniGeracaoEtiq()
	
	Local aAreaAtu		:= GetArea()
	Local cQuery			:= ""
	Local cTexto			:= ""
	Local nCont			:= 0
	
	Private nContaReg		:= 0
	Private nContaEtiq	:= 0
	
	Private cOp			:= ""
	Private cNumSeq		:= ""
	Private nRecnoSH6		:= 0
	
	cQuery := "SELECT " + CRLF
	cQuery += "	BF_PRODUTO, BF_LOCAL, BF_LOCALIZ, DB_NUMSEQ," + CRLF
	cQuery += "	BF_LOTECTL, BF_QUANT, B1_QE, BF_DATAVEN" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + RetSqlName("SBF") + " AS SBF " + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlName("SB1") + " AS SB1 " + CRLF
	cQuery += "ON " + CRLF
	cQuery += "	B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
	cQuery += "	B1_COD = BF_PRODUTO AND " + CRLF
	cQuery += "	B1_LOCALIZ = 'S' AND " + CRLF
	cQuery += "	SB1.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "INNER JOIN " + CRLF
	cQuery += "	" + RetSqlName("SB5") + " AS SB5 " + CRLF
	cQuery += "ON " + CRLF
	cQuery += "	B5_FILIAL = '" + xFilial("SB5") + "' AND " + CRLF
	cQuery += "	B5_COD = B1_COD AND " + CRLF
	cQuery += "	B5_IMPETI = '1' AND " + CRLF
	cQuery += "	SB5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + CRLF
	cQuery += "	" + RetSqlName("SDB") + " AS SDB " + CRLF
	cQuery += "ON " + CRLF
	cQuery += "	DB_FILIAL = '" + xFilial("SDB") + "' AND " + CRLF
	cQuery += "	DB_PRODUTO = BF_PRODUTO AND " + CRLF
	cQuery += "	DB_LOCAL = BF_LOCAL AND " + CRLF
	cQuery += "	DB_LOCALIZ = BF_LOCALIZ AND " + CRLF
	cQuery += "	DB_LOTECTL = BF_LOTECTL AND "
	cQuery += "	SDB.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "	BF_FILIAL = '" + xFilial("SBF") + "' AND "
	cQuery += "	BF_QUANT > 0 AND " + CRLF
	cQuery += "	SBF.D_E_L_E_T_ = ' ' " + CRLF
	
	If Select("TMP") > 0
		TMP->(DbCloseArea())
	EndIf
	
	TcQuery cQuery New Alias "TMP"
	
	Count to nCont
	ProcRegua(nCont)
	
	TMP->(DbGoTop())
	
	If TMP->(!Eof())
		TMP->(DbGoTop())
		While TMP->(!Eof())
			//cOp := findLastOp(TMP->BF_PRODUTO,TMP->BF_LOCAL)
			
			//Se foi localizado a OP, continua o processamento
			//If !Empty(cOp)
			//nRecnoSH6 := findLastAppoinment(TMP->BF_PRODUTO)
			//If nRecnoSH6 > 0
			//Chama a rotina de criação das etiquetas
			
			cNumSeq 	:= TMP->DB_NUMSEQ
			nRecnoSH6	:= 0 
			
			cOp := findLastOp(TMP->BF_PRODUTO)
			If !Empty(cOp)
				nRecnoSH6 := findLastAppoinment(TMP->BF_PRODUTO)
			EndIf
			
			//Rotina que gera as etiquetas
			U_GravaEtique("01",TMP->BF_PRODUTO,cOp,TMP->BF_QUANT,TMP->B1_QE,TMP->BF_LOCAL,TMP->BF_LOCALIZ,TMP->BF_LOTECTL,SToD(TMP->BF_DATAVEN),nRecnoSH6,@nContaEtiq)
			
			//Limpa as variáveis
			cNumSeq := cOp := ""
			nRecnoSH6 := 0
			
			nContaReg++
			IncProc()
			TMP->(DbSkip())
		EndDo
	EndIf
	
	cTexto += "Foram Gerados: " + CRLF
	cTexto += cValToChar(nContaReg) + " Registros Da SBF" + CRLF
	cTexto += cValToChar(nContaEtiq) + " Etiquetas" + CRLF
	
	Aviso("Geração de Etiquetas",cTexto,{"Ok"},3)
	
	TMP->(DbCloseArea())
	
	RestArea(aAreaAtu)
	
Return

/*/{Protheus.doc} findLastOp
Busca a ordem de produção da
ultima movimentação de estoque

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			21/07/2015
@return 		cOp
/*/
Static Function findLastOp(cProduto)
	
	Local cQuery			:= ""
	Local cRet				:= ""
	Local cAlias			:= GetNextAlias()
	Local aArea			:= SD3->(GetArea())
	
	cQuery += "SELECT " + CRLF
	cQuery += "	MAX(D3_OP) AS D3_OP " + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + RetSqlName("SD3") + " AS SD3 " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "	D3_FILIAL = '" + xFilial("SD3") + "' AND " + CRLF
	cQuery += "	D3_COD = '" + cProduto + "' AND " + CRLF
	cQuery += "	D3_TM = '010' AND " + CRLF
	cQuery += "	D3_CF = 'PR0' AND " + CRLF
	cQuery += "	SD3.D_E_L_E_T_ = ' '" + CRLF
	
	TcQuery cQuery New Alias &cAlias
	
	If (cAlias)->(!Eof())
		(cAlias)->(DbGoTop())
		
		//Captura a ultima OP
		cRet 		:= (cAlias)->D3_OP
	EndIf
	
	(cAlias)->(DbCloseArea())
	
	RestArea(aArea)
	
Return (cRet)

/*/{Protheus.doc} findLastAppoinment
Busca o ultimo apontamento da OP para
pegar o RECNO utilizado na reimpressão da etiqueta

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			21/07/2015
@return 		nRecnoSH6
/*/
Static Function findLastAppoinment(cProduto)
	
	Local nRecno			:= 0
	Local cQuery			:= ""
	Local cAlias			:= GetNextAlias()
	Local aArea			:= SH6->(GetArea())
	
	cQuery += "SELECT " + CRLF
	cQuery += "	MAX(H6_DATAFIN) AS H6_DATAFIN," + CRLF
	cQuery += "	R_E_C_N_O_ " + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + RetSqlName("SH6") + " AS SH6 " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "	H6_FILIAL = '" + xFilial("SH6") + "' AND " + CRLF
	cQuery += "	H6_OP = '" + cOp + "' AND " + CRLF
	cQuery += "	H6_PRODUTO = '" + cProduto + "' AND " + CRLF
	cQuery += "	H6_OPERAC = '" + lastOperacao(cProduto) + "' AND " + CRLF
	cQuery += "	SH6.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "GROUP BY " + CRLF
	cQuery += "	R_E_C_N_O_" + CRLF
	
	TcQuery cQuery New Alias &cAlias
	
	If (cAlias)->(!Eof())
		(cAlias)->(DbGoTop())
		
		nRecno := (cAlias)->R_E_C_N_O_
		
	EndIf
	
	(cAlias)->(DbCloseArea())
	
	RestArea(aArea)
	
Return (nRecno)

/*/{Protheus.doc} lastOperacao
Busca a ultima operação da OP

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			21/07/2015
@return 		cRet
/*/
Static Function lastOperacao(cProduto)
	
	Local cRet			:= ""
	Local cQuery		:= ""
	Local cAlias		:= GetNextAlias()
	
	cQuery += "SELECT " + CRLF
	cQuery += "	MAX(G2_OPERAC) AS OPERAC" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + RetSqlName("SG2") + " AS SG2" + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "	G2_FILIAL = '" + xFilial("SG2") + "' AND" + CRLF
	cQuery += "	G2_PRODUTO = '" + cProduto + "' AND" + CRLF
	cQuery += "	SG2.D_E_L_E_T_ = ' '" + CRLF
	
	TcQuery cQuery New Alias &cAlias
	
	If (cAlias)->(!Eof())
		cRet := (cAlias)->OPERAC
	EndIf
	
	(cAlias)->(DbCloseArea())
	
Return (cRet)
