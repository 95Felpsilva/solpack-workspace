#Include "Protheus.ch"
#Include "Topconn.ch"

#DEFINE TABLE_QNEG			"Quantidade Negativa"
#DEFINE TABLE_VNEG			"Valor Negativo"
#DEFINE TABLE_QZERO			"Quantidade Sem Custo"
#DEFINE TABLE_VZERO			"Custo Sem Quantidade"

#DEFINE WORKSH_QNEG			"Quantidade Negativa"
#DEFINE WORKSH_VNEG			"Valor Negativo"
#DEFINE WORKSH_QZERO			"Quantidade Sem Custo"
#DEFINE WORKSH_VZERO			"Custo Sem Quantidade"

/*/{Protheus.doc}	planItVen
Planilha de Resumo de Faturamento em KG por Grupo de Estoque

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					27/07/2015
@return				nil
/*/
User Function relcusto()
	Private oExcel		:= FWMsExcel():New()
	Private cTable		:= ""
	Private cWorkSheet	:= ""
	private aColumns		:= getColumns()
	
	Plan1()			//"Quantidade Negativa"
	Plan2()			//"Valor Negativo"
	Plan3()			//"Quantidade Sem Custo"
	Plan4()			//"Custo Sem Quantidade"
		
	Processa({||buscaDados()},"Gerando Planilha")
Return

static function getColumns()
	local aColumns := {}	
	//1 - Nome da Coluna | 2 - Alinhamento | 3 - Formatação | 4 - Deve ser totalizada
	//Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
	Aadd(aColumns,{"CODIGO",1,1,.F.})
	Aadd(aColumns,{"DESCRICAO",1,1,.F.})
	Aadd(aColumns,{"TIPO",1,1,.F.})
	Aadd(aColumns,{"ARMAZEM",1,1,.F.})
	Aadd(aColumns,{"UNIDADE",1,1,.F.})
	Aadd(aColumns,{"MEDIO",1,3,.F.})
	Aadd(aColumns,{"QUANT_FINAL",1,2,.F.})
	Aadd(aColumns,{"VALOR_FINAL",1,3,.F.})
return aColumns

Static Function plan1() //planfat()
	Local nI			:= 0
	
	oExcel:AddWorkSheet(WORKSH_QNEG)
	oExcel:AddTable(WORKSH_QNEG,TABLE_QNEG)
	
	//Percorre as colunas para inserir na planilha
	For nI := 1 To Len(aColumns)
		oExcel:AddColumn(WORKSH_QNEG,TABLE_QNEG,aColumns[nI,1],aColumns[nI,2],aColumns[nI,3],aColumns[nI,4])
	Next

Return

/*/{Protheus.doc}	planDev
Configura a planilha de devoluções

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since				03/02/2015
@return				nil
/*/
Static Function plan2() //planDev()
	Local nI			:= 0

	oExcel:AddWorkSheet(WORKSH_VNEG)
	oExcel:AddTable(WORKSH_VNEG,TABLE_VNEG)
	
	//Percorre as colunas para inserir na planilha
	For nI := 1 To Len(aColumns)
		oExcel:AddColumn(WORKSH_VNEG,TABLE_VNEG,aColumns[nI,1],aColumns[nI,2],aColumns[nI,3],aColumns[nI,4])
	Next

Return

Static Function plan3() //planDev()
	Local nI			:= 0

	oExcel:AddWorkSheet(WORKSH_QZERO)
	oExcel:AddTable(WORKSH_QZERO,TABLE_QZERO)
	
	//Percorre as colunas para inserir na planilha
	For nI := 1 To Len(aColumns)
		oExcel:AddColumn(WORKSH_QZERO,TABLE_QZERO,aColumns[nI,1],aColumns[nI,2],aColumns[nI,3],aColumns[nI,4])
	Next

Return

Static Function plan4() //planDev()
	Local nI			:= 0
	
	oExcel:AddWorkSheet(WORKSH_VZERO)
	oExcel:AddTable(WORKSH_VZERO,TABLE_VZERO)
	
	//Percorre as colunas para inserir na planilha
	For nI := 1 To Len(aColumns)
		oExcel:AddColumn(WORKSH_VZERO,TABLE_VZERO,aColumns[nI,1],aColumns[nI,2],aColumns[nI,3],aColumns[nI,4])
	Next
Return

/*/{Protheus.doc}	buscaDados
Realiza a busca dos dados conforme parâmetros selecionados

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since				27/07/2015
@return				nil
/*/
Static Function buscaDados()
	Local nW			:= 0
	Local cQuery 		:= ""
	Local nTotalReg		:= 0
	Local nContador		:= 0
	Local cAlias		:= GetNextAlias()
	Local aLinTmp		:= {}
	
	Local aTipos		:= {"QNEG","VNEG","QZERO","VZERO"}
	
	For nW := 1 to Len(aTipos)
		If aTipos[nW] == "QNEG"
			cWorkSheet		:= WORKSH_QNEG
			cTable			:= TABLE_QNEG
		ElseIf aTipos[nW] == "VNEG"
			cWorkSheet		:= WORKSH_VNEG
			cTable			:= TABLE_VNEG
		ElseIf aTipos[nW] == "QZERO"
			cWorkSheet		:= WORKSH_QZERO
			cTable			:= TABLE_QZERO
		ElseIf aTipos[nW] == "VZERO"
			cWorkSheet		:= WORKSH_VZERO
			cTable			:= TABLE_VZERO
		EndIf
	
		cQuery := MontaQuerys(aTipos[nW])
		TcQuery cQuery New Alias &cAlias
	
		Count to nTotalReg
		(cAlias)->(DbGoTop())
	
		while (cAlias)->(!Eof())
			Aadd(aLinTmp, (cAlias)->CODIGO)
			Aadd(aLinTmp, (cAlias)->DESCRICAO)
			Aadd(aLinTmp, (cAlias)->TIPO)
			Aadd(aLinTmp, (cAlias)->ARMAZEM)
			Aadd(aLinTmp, (cAlias)->UNIDADE)
			Aadd(aLinTmp, (cAlias)->MEDIO)
			Aadd(aLinTmp, (cAlias)->QUANT_FINAL)
			Aadd(aLinTmp, (cAlias)->VALOR_FINAL)

				//Adiciona a Linha na planilha
			oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
			
			aLinTmp := {}
			
			nContador++
			IncProc("[" + aTipos[nW] + "] - Processando registro " + cValToChar(nContador) + " de " + cValToChar(nTotalReg) + "...")
			(cAlias)->(DbSkip())
		EndDo
		
		(cAlias)->(DbCloseArea())
		nContador := 1
	Next
	
	//Gera o planilha em XML
	geraPlan()
		
return

/*/{Protheus.doc}	geraPlan
Rotina que gera a planilha do excel

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					27/07/2015
@return				nil
/*/
Static Function geraPlan()
	Local cDiretorio	:= ""
	Local cExtensao	:= ".XML"
	Local cTexto		:= ""
	Local cTitle		:= "Planilha Gerada com Sucesso !"
	Local oExcelApp 	:= MSExcel():New()
	Local cFile		:= ""
	
	cDiretorio := cGetFile("Arquivos (*" + Upper(cExtensao) + ") | *" + Upper(cExtensao) + " |","Selecione o Local de Destino",,,.F., GETF_LOCALHARD)
	
	If !Empty(cDiretorio)
		cFile := cDiretorio + iif(len(strtokarr(cDiretorio,cExtensao))==1,cExtensao,"")
		oExcel:Activate()
		oExcel:GetXMLFile(cFile)

		cTexto += "Planilha gerada em: " + CRLF
		cTexto += cFile
		
		If File(cFile)
			Aviso(cTitle,cTexto,{"OK"},3)
			oExcelApp:WorkBooks:Open(cFile)
			oExcelApp:setVisible(.T.)
		Else
			Aviso("Erro","Não foi possível gerar a planilha em " + cDiretorio,{"OK"},3)
		EndIf
	EndIf

Return

Static Function MontaQuerys(cTipo)
	Local cQuery		:= ""

	cQuery += "SELECT " + CRLF
	cQuery += "B2_FILIAL AS COD_FILIAL, " + CRLF
	cQuery += "B2_COD AS CODIGO," + CRLF
	cQuery += "B1_DESC AS DESCRICAO," + CRLF
	cQuery += "B1_TIPO AS TIPO," + CRLF
	cQuery += "B2_LOCAL AS ARMAZEM," + CRLF
	cQuery += "B1_UM AS UNIDADE," + CRLF
	cQuery += "B2_CMFIM1 AS MEDIO," + CRLF
	cQuery += "B2_QFIM AS QUANT_FINAL," + CRLF
	cQuery += "B2_VFIM1 AS VALOR_FINAL" + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + "  SB2 " + CRLF
	cQuery += "JOIN  " + RetSqlName("SB1") + " SB1 " + CRLF
	cQuery += "ON B1_COD = B2_COD AND SB2.D_E_L_E_T_<> '*'" + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "AND SB1.D_E_L_E_T_<> '*' " +CRLF
	cQuery += "AND B1_FILIAL = '"+xFilial("SB1")+"' " +CRLF
	cQuery += "AND B2_FILIAL = '"+xFilial("SB2")+"' " +CRLF
	
	If cTipo == "QNEG"
		cQuery += "AND B2_QFIM < 0" + CRLF
	ElseIf cTipo == "VNEG"
		cQuery += "AND B2_VFIM1 < 0" + CRLF
	ElseIf cTipo == "VZERO"
		cQuery += "AND B2_QFIM = 0" + CRLF
		cQuery += "AND B2_VFIM1 <> 0" + CRLF
	ElseIf cTipo == "QZERO"
		cQuery += "AND B2_QFIM <> 0" + CRLF
		cQuery += "AND B2_VFIM1 = 0" + CRLF
	EndIf
	
	cQuery += "ORDER BY B2_COD, B1_DESC, B2_QFIM" + CRLF
Return (cQuery)