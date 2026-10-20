#Include "Protheus.ch"
#Include "Topconn.ch"

#DEFINE TABLE_DEV			"Resumo de Devoluções em KG por Grupo de Estoque"
#DEFINE TABLE_FAT			"Resumo de Faturamento em KG por Grupo de Estoque"
#DEFINE WORKSH_DEV			"Devoluções em KG"
#DEFINE WORKSH_FAT			"Faturamentos em KG"

/*/{Protheus.doc}	planItVen
Planilha de Resumo de Faturamento em KG por Grupo de Estoque
@type function
@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					27/07/2015
/*/
User Function planItVen()

	Local aParamBox		:= {}
	Private oExcel		:= FWMsExcel():New()
	Private cTable		:= ""
	Private cWorkSheet	:= ""

	AADD(aParamBox,{1,"Grupo de"			,Space(TamSx3("BM_GRUPO")[1]),	"",	"",	"SBM",	"",40, .f.})// MV_PAR01
	AADD(aParamBox,{1,"Grupo Ate"			,Space(TamSx3("BM_GRUPO")[1]),	"",	"",	"SBM",	"",40, .f.})// MV_PAR02

	AADD(aParamBox,{1,"Emissão de"	,STOD(""),	"",	"",,".T.",50, .f.})// MV_PAR03
	AADD(aParamBox,{1,"Emissão Ate"	,STOD(""),	"",	"",,".T.",50, .f.})// MV_PAR04

	Aadd(aParambox,{2,"Inclui Devolução"	,"1",{"1-Sim","2-Nao"},50,,.f.})// MV_PAR05
	Aadd(aParambox,{2,"Inclui Venda Futura"	,"2",{"1-Sim","2-Nao"},50,,.f.})// MV_PAR06

	If ParamBox(aParamBox,"ITENS VENDAS",,,,,,,,"ITVEND01",.T.,.T.)
		MV_PAR05 := Iif(type("MV_PAR05")=="N",alltrim(str(MV_PAR05)),substr(MV_PAR05,1,1))
		MV_PAR06 := Iif(type("MV_PAR06")=="N",alltrim(str(MV_PAR06)),substr(MV_PAR06,1,1))

		planFat()	// Monta estrutura da Planilha de Faturamento

		if MV_PAR05 == "1"
			planDev()	// Monta estrutura da Planilha de Devoluções
		endif

		Processa({||buscaDados()},"Gerando Planilha")
		//Processa({||buscaDados(.t.)},"Gerando Planilha Polimeros")

		//Gera o planilha em XML
		geraPlan()
	EndIf

Return

/*/{Protheus.doc}	impDados
Rotina que gera a planilha de Resumo de Faturamento em KG por Grupo de Estoque
@type staticfunction
@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					27/07/2015
/*/
Static Function planFat()

	Local nI			:= 0
	Local aColumns		:= {}

	//1 - Nome da Coluna | 2 - Alinhamento | 3 - Formatação | 4 - Deve ser totalizada
	Aadd(aColumns,{"Grupo",1,1,.F.})
	Aadd(aColumns,{"SubGrupo",1,1,.F.})
	Aadd(aColumns,{"Descrição Grupo",1,1,.F.})
	Aadd(aColumns,{"Valor",1,3,.F.})
	Aadd(aColumns,{"Peso em KG",1,3,.F.})
	Aadd(aColumns,{"Preço Médio",1,3,.F.})

	oExcel:AddWorkSheet(WORKSH_FAT)
	oExcel:AddTable(WORKSH_FAT,TABLE_FAT)

	//Percorre as colunas para inserir na planilha
	For nI := 1 To Len(aColumns)
		oExcel:AddColumn(WORKSH_FAT,TABLE_FAT,aColumns[nI,1],aColumns[nI,2],aColumns[nI,3],aColumns[nI,4])
	Next

Return

/*/{Protheus.doc}	planDev
Configura a planilha de devoluções

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since				03/02/2015
@return				nil
/*/
Static Function planDev()

	Local nI			:= 0
	Local aColumns		:= {}

	//1 - Nome da Coluna | 2 - Alinhamento | 3 - Formatação | 4 - Deve ser totalizada
	Aadd(aColumns,{"Grupo",1,1,.F.})
	Aadd(aColumns,{"SubGrupo",1,1,.F.})
	Aadd(aColumns,{"Descrição Grupo",1,1,.F.})
	Aadd(aColumns,{"Valor",1,3,.F.})
	Aadd(aColumns,{"Peso em KG",1,3,.F.})
	Aadd(aColumns,{"Preço Médio",1,3,.F.})

	oExcel:AddWorkSheet(WORKSH_DEV)
	oExcel:AddTable(WORKSH_DEV,TABLE_DEV)

	//Percorre as colunas para inserir na planilha
	For nI := 1 To Len(aColumns)
		oExcel:AddColumn(WORKSH_DEV,TABLE_DEV,aColumns[nI,1],aColumns[nI,2],aColumns[nI,3],aColumns[nI,4])
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
	Local cGrupo		:= ""
	Local cDescGrupo	:= ""
	Local nTotalReg		:= 0
	Local nContador		:= 0
	Local cAlias		:= GetNextAlias()
	Local aLinTmp		:= {}

	Local nPeso			:= 0
	Local nValGrupo		:= 0
	Local nPesoGrupo	:= 0
	Local nPrecoMedio	:= 0

	Local nTOTValor		:= 0
	Local nTOTPeso		:= 0
	local bChave        := {|| (cAlias)->BM_GRUPO }
	local cChave  		:= ""
	Local aTipos		:= Iif(MV_PAR05 == "1",{"FAT","DEV"},{"FAT"})

	For nW := 1 to Len(aTipos)
		nTOTValor		:= 0
		nTOTPeso		:= 0
		nPesoGrupo      := 0
		nValGrupo 	    := 0

		If aTipos[nW] == "FAT"
			cWorkSheet		:= WORKSH_FAT
			cTable			:= TABLE_FAT
		ElseIf aTipos[nW] == "DEV"
			cWorkSheet		:= WORKSH_DEV
			cTable			:= TABLE_DEV
		EndIf

		cQuery := MontaQuerys(aTipos[nW])
		memowrite("\sql\plantiven_" + aTipos[nW]+".sql",cQuery)
		TcQuery cQuery New Alias &cAlias

		Count to nTotalReg
		(cAlias)->(DbGoTop())

		While (cAlias)->(!Eof())
			//Quebra por grupo
			cGrupo 			:= (cAlias)->BM_GRUPO
			cDescGrupo		:= (cAlias)->BM_DESC
			cChave := eval(bChave)

			While (cAlias)->(!Eof()) .and. cChave == eval(bChave)
				nPeso 			:= (cAlias)->QUANT
				nPrecoMedio		:= (cAlias)->TOTAL / nPeso

				Aadd(aLinTmp, (cAlias)->BM_GRUPO)
				Aadd(aLinTmp, (cAlias)->B1_ZZSUBGR)
				Aadd(aLinTmp, (cAlias)->B1_ZZDESCS)
				Aadd(aLinTmp, (cAlias)->TOTAL)
				Aadd(aLinTmp, nPeso)
				Aadd(aLinTmp, nPrecoMedio)

				//Adiciona a Linha na planilha
				oExcel:AddRow(cWorkSheet,cTable,aLinTmp)

				//Totalizadores por grupo
				nValGrupo 		+= (cAlias)->TOTAL
				nPesoGrupo		+= nPeso

				//Totalizadores finais
				nTOTValor		+= (cAlias)->TOTAL
				nTOTPeso		+= nPeso

				aLinTmp := {}
				(cAlias)->(DbSkip())
			enddo

			Aadd(aLinTmp,cChave)
			Aadd(aLinTmp,cChave)
			Aadd(aLinTmp,cDescGrupo)
			Aadd(aLinTmp,nValGrupo)
			Aadd(aLinTmp,nPesoGrupo)
			Aadd(aLinTmp,nValGrupo / nPesoGrupo)

			//Adiciona a Linha na planilha
			oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
			//addLinhaVazia()

			//Zera as variáveis
			aLinTmp 	:= {}
			nValGrupo 	:= 0
			nPesoGrupo 	:= 0

			nContador++
			IncProc("[" + aTipos[nW] + "] - Processando registro " + cValToChar(nContador) + " de " + cValToChar(nTotalReg) + "...")

		EndDo

		//Totalizador Final
		Aadd(aLinTmp, "")
		Aadd(aLinTmp, "")
		Aadd(aLinTmp, "TOTAL GERAL")
		Aadd(aLinTmp, nTOTValor)
		Aadd(aLinTmp, nTOTPeso)
		Aadd(aLinTmp, nTOTValor / nTOTPeso)
		oExcel:AddRow(cWorkSheet,cTable,aLinTmp)

		(cAlias)->(DbCloseArea())
		aLinTmp := {}
		nContador := 1
	Next
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
	Local oExcelApp := MSExcel():New()

	cDiretorio := cGetFile("Arquivos (*" + Upper(cExtensao) + ") | *" + Upper(cExtensao) + " |","Selecione o Local de Destino",,,.F., GETF_LOCALHARD)

	If !Empty(cDiretorio)
		oExcel:Activate()
		oExcel:GetXMLFile(cDiretorio + cExtensao)

		cTexto += "Planilha gerada em: " + CRLF
		cTexto += cDiretorio + cExtensao

		If File(cDiretorio + cExtensao)
			Aviso(cTitle,cTexto,{"OK"},3)
			oExcelApp:WorkBooks:Open(cDiretorio + cExtensao)
			oExcelApp:setVisible(.T.)
		Else
			Aviso("Erro","Não foi possível gerar a planilha em " + cDiretorio,{"OK"},3)
		EndIf
	EndIf

Return

Static Function MontaQuerys(cTipo)

	Local cSeparador	:= ";"
	Local cGrpRestr		:= StrTran(GetNewPar("MV_ZZFATPE",""),cSeparador,"','")
	local lVendaFutura	:= MV_PAR06 == "1"
	local cVendaFutura	:= ""
	Local cQuery		:= ""

	if lVendaFutura
		cVendaFutura := " OR F4_ZZVDFUT = '1'" + CRLF
	endif


	If cTipo == "FAT"
		cQuery += "SELECT" + CRLF
		cQuery += "	SUBQRY.BM_GRUPO," + CRLF
		cQuery += "	SUBQRY.BM_DESC," + CRLF
		cQuery += "	SUBQRY.B1_ZZSUBGR," + CRLF
		cQuery += "	SUBQRY.B1_ZZDESCS," + CRLF
		cQuery += "	SUM(SUBQRY.QUANT) AS QUANT," + CRLF
		cQuery += "	SUM(SUBQRY.TOTAL) AS TOTAL " + CRLF
		cQuery += "FROM" + CRLF
		cQuery += "	(" + CRLF
		cQuery += "		SELECT" + CRLF
		cQuery += "			BM_GRUPO, BM_DESC," + CRLF
		cQuery += "			B1_ZZDESCS, B1_ZZSUBGR," + CRLF
		cQuery += "          CASE" + CRLF
		cQuery += "          WHEN D2_UM = 'KG' THEN SUM(D2_QUANT)" + CRLF
		cQuery += "          ELSE SUM(D2_ZZPESLI * D2_QUANT) END AS QUANT," + CRLF
		cQuery += "          SUM(D2_TOTAL) AS TOTAL" + CRLF
		cQuery += "		FROM" + CRLF
		cQuery += "			" + RetSqlName("SD2") + " AS SD2" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "			" + RetSqlName("SB1") + " AS SB1" + CRLF
		cQuery += "		ON" + CRLF
		cQuery += "			B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
		cQuery += "			B1_COD = D2_COD AND" + CRLF
		cQuery += "			SB1.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "			" + RetSqlName("SBM") + " AS SBM" + CRLF
		cQuery += "		ON" + CRLF
		cQuery += "			BM_FILIAL = '" + xFilial("SBM") + "' AND " + CRLF
		cQuery += "			BM_GRUPO = B1_GRUPO AND" + CRLF
		cQuery += "			SBM.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "			" + RetSqlName("SF2") + " AS SF2" + CRLF
		cQuery += "		ON" + CRLF
		cQuery += "			F2_FILIAL = '" + xFilial("SF2") + "' AND " + CRLF
		cQuery += "			F2_DOC = D2_DOC AND" + CRLF
		cQuery += "			F2_SERIE = D2_SERIE AND" + CRLF
		cQuery += "			F2_CLIENTE = D2_CLIENTE AND" + CRLF
		cQuery += "			F2_LOJA = D2_LOJA AND" + CRLF
		cQuery += "			SF2.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "       	" + RetSqlName("SF4") + " AS SF4" + CRLF
		cQuery += "		ON" + CRLF
		cQuery += "			F4_FILIAL = '" + xFilial("SF4") + "' AND" + CRLF
		cQuery += "			F4_CODIGO = D2_TES AND" + CRLF
		cQuery += "			(( F4_DUPLIC = 'S' AND F4_ESTOQUE = 'S' AND F4_ZZVDFUT <> '1')"+cVendaFutura+" ) AND"+CRLF
		cQuery += "			SF4.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		WHERE" + CRLF
		cQuery += "			D2_FILIAL = '" + xFilial("SD2") + "' AND " + CRLF
		cQuery += "			(D2_UM = 'KG' OR D2_SEGUM = 'KG') AND " + CRLF
		cQuery += "          B1_ZZSUBGR <> ' ' AND" + CRLF
		cQuery += "			BM_GRUPO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND " + CRLF
		cQuery += "			F2_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' AND " + CRLF
		cQuery += "			D2_TIPO = 'N' AND" + CRLF //ADICIONADO POR JONI
		cQuery += "			SD2.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		GROUP BY" + CRLF
		cQuery += "			BM_GRUPO, BM_DESC, B1_ZZSUBGR, B1_ZZDESCS, D2_UM" + CRLF

		//inclui devolução
		if MV_PAR05 == "1"
			cQuery += "		UNION ALL" + CRLF
			cQuery += "		SELECT" + CRLF
			cQuery += "			BM_GRUPO, BM_DESC," + CRLF
			cQuery += "			B1_ZZDESCS, B1_ZZSUBGR," + CRLF
			cQuery += "          CASE" + CRLF
			cQuery += "          WHEN D2_UM = 'KG' THEN SUM(D1_QUANT) * -1" + CRLF
			cQuery += "          ELSE SUM(D2_ZZPESLI * D1_QUANT) * -1 END AS QUANT," + CRLF
			cQuery += "          SUM(D1_TOTAL-D1_VALDESC) * -1 AS TOTAL" + CRLF
			cQuery += "		FROM" + CRLF
			cQuery += "			" + RetSqlName("SD1") + " AS SD1" + CRLF
			cQuery += "		INNER JOIN" + CRLF
			cQuery += "			" + RetSqlName("SD2") + " AS SD2" + CRLF
			cQuery += "		ON 1=1" + CRLF
			cQuery += "			AND D1_FILIAL = D2_FILIAL" + CRLF
			cQuery += "			AND D1_NFORI = D2_DOC" + CRLF
			cQuery += "			AND D1_SERIORI = D2_SERIE" + CRLF
			cQuery += "			AND (D1_ITEMORI = D2_ITEM OR (D1_ITEMORI = ' ' AND CONVERT(INT,D2_ITEM) = CONVERT(INT,D1_ITEM)))" + CRLF
			cQuery += "			AND D1_COD = D2_COD" + CRLF
			cQuery += "			AND SD2.D_E_L_E_T_ = ' '" + CRLF
			cQuery += "		INNER JOIN" + CRLF
			cQuery += "			" + RetSqlName("SB1") + " AS SB1" + CRLF
			cQuery += "		ON" + CRLF
			cQuery += "			B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
			cQuery += "			B1_COD = D1_COD AND" + CRLF
			cQuery += "			SB1.D_E_L_E_T_ = ' '" + CRLF
			cQuery += "		INNER JOIN" + CRLF
			cQuery += "			" + RetSqlName("SBM") + " AS SBM" + CRLF
			cQuery += "		ON" + CRLF
			cQuery += "			BM_FILIAL = '" + xFilial("SBM") + "' AND " + CRLF
			cQuery += "			BM_GRUPO = B1_GRUPO AND" + CRLF
			cQuery += "			SBM.D_E_L_E_T_ = ' '" + CRLF
			cQuery += "		INNER JOIN" + CRLF
			cQuery += "			" + RetSqlName("SF1") + " AS SF1" + CRLF
			cQuery += "		ON" + CRLF
			cQuery += "			F1_FILIAL = '" + xFilial("SF1") + "' AND " + CRLF
			cQuery += "			F1_DOC = D1_DOC AND" + CRLF
			cQuery += "			F1_SERIE = D1_SERIE AND" + CRLF
			cQuery += "			F1_FORNECE = D1_FORNECE AND" + CRLF
			cQuery += "			F1_LOJA = D1_LOJA AND" + CRLF
			cQuery += "			SF1.D_E_L_E_T_ = ' '" + CRLF
			cQuery += "		INNER JOIN" + CRLF
			cQuery += "       	" + RetSqlName("SF4") + " AS SF4" + CRLF
			cQuery += "		ON" + CRLF
			cQuery += "			F4_FILIAL = '" + xFilial("SF4") + "' AND" + CRLF
			cQuery += "			F4_CODIGO = D1_TES AND" + CRLF
			cQuery += "			(( F4_DUPLIC = 'S' AND F4_ESTOQUE = 'S' AND F4_ZZVDFUT <> '1')"+cVendaFutura+" ) AND"+CRLF
			cQuery += "			SF4.D_E_L_E_T_ = ' '" + CRLF
			cQuery += "		WHERE" + CRLF
			cQuery += "			D1_FILIAL = '" + xFilial("SD1") + "' AND " + CRLF
			cQuery += "			D1_TIPO = 'D' AND " + CRLF
			cQuery += "			(D2_UM = 'KG' OR D2_SEGUM = 'KG') AND " + CRLF
			cQuery += "          B1_ZZSUBGR <> ' ' AND" + CRLF
			cQuery += "			BM_GRUPO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND " + CRLF
			cQuery += "			D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' AND " + CRLF
			cQuery += "			SD1.D_E_L_E_T_ = ' '" + CRLF
			cQuery += "		GROUP BY" + CRLF
			cQuery += "			BM_GRUPO, BM_DESC, B1_ZZSUBGR, B1_ZZDESCS, D2_UM" + CRLF
		endif

		cQuery += "		) AS SUBQRY" + CRLF
		cQuery += "WHERE 1=1" + CRLF
		cQuery += "	AND SUBQRY.BM_GRUPO NOT IN ('" + cGrpRestr + "')" + CRLF
		cQuery += "GROUP BY" + CRLF
		cQuery += "	SUBQRY.BM_GRUPO," + CRLF
		cQuery += "	SUBQRY.BM_DESC," + CRLF
		cQuery += "	SUBQRY.B1_ZZSUBGR," + CRLF
		cQuery += "	SUBQRY.B1_ZZDESCS" + CRLF

		cQuery += "" + CRLF
		cQuery += "UNION ALL " + CRLF
		cQuery += "" + CRLF

		cQuery += "SELECT" + CRLF
		cQuery += "	SUBQRY.BM_GRUPO," + CRLF
		cQuery += "	SUBQRY.BM_DESC," + CRLF
		cQuery += "	SUBQRY.B1_ZZSUBGR," + CRLF
		cQuery += "	SUBQRY.B1_ZZDESCS," + CRLF
		cQuery += "	SUM(SUBQRY.QUANT) AS QUANT," + CRLF
		cQuery += "	SUM(SUBQRY.TOTAL) AS TOTAL " + CRLF
		cQuery += "FROM" + CRLF
		cQuery += "	(" + CRLF
		cQuery += "		SELECT" + CRLF
		cQuery += "			BM_GRUPO, BM_DESC," + CRLF
		cQuery += "			B1_ZZDESCS, B1_ZZSUBGR," + CRLF
		cQuery += "          SUM(D2_QUANT) AS QUANT," + CRLF
		cQuery += "          SUM(D2_TOTAL) AS TOTAL" + CRLF
		cQuery += "		FROM" + CRLF
		cQuery += "			" + RetSqlName("SD2") + " AS SD2" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "			" + RetSqlName("SB1") + " AS SB1" + CRLF
		cQuery += "		ON" + CRLF
		cQuery += "			B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
		cQuery += "			B1_COD = D2_COD AND" + CRLF
		cQuery += "			SB1.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "			" + RetSqlName("SBM") + " AS SBM" + CRLF
		cQuery += "		ON" + CRLF
		cQuery += "			BM_FILIAL = '" + xFilial("SBM") + "' AND " + CRLF
		cQuery += "			BM_GRUPO = B1_GRUPO AND" + CRLF
		cQuery += "			SBM.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "			" + RetSqlName("SF2") + " AS SF2" + CRLF
		cQuery += "		ON" + CRLF
		cQuery += "			F2_FILIAL = '" + xFilial("SF2") + "' AND " + CRLF
		cQuery += "			F2_DOC = D2_DOC AND" + CRLF
		cQuery += "			F2_SERIE = D2_SERIE AND" + CRLF
		cQuery += "			F2_CLIENTE = D2_CLIENTE AND" + CRLF
		cQuery += "			F2_LOJA = D2_LOJA AND" + CRLF
		cQuery += "			SF2.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "       	" + RetSqlName("SF4") + " AS SF4" + CRLF
		cQuery += "		ON" + CRLF
		cQuery += "			F4_FILIAL = '" + xFilial("SF4") + "' AND" + CRLF
		cQuery += "			F4_CODIGO = D2_TES AND" + CRLF
		cQuery += "			(( F4_DUPLIC = 'S' AND F4_ESTOQUE = 'S' AND F4_ZZVDFUT <> '1')"+cVendaFutura+" ) AND"+CRLF
		cQuery += "			SF4.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		WHERE" + CRLF
		cQuery += "			D2_FILIAL = '" + xFilial("SD2") + "' AND " + CRLF
		cQuery += "			(D2_UM = 'KG' OR D2_SEGUM = 'KG') AND " + CRLF
		cQuery += "          B1_ZZSUBGR <> ' ' AND" + CRLF
		cQuery += "			BM_GRUPO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND " + CRLF
		cQuery += "			F2_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' AND " + CRLF
		cQuery += "			D2_TIPO = 'N' AND" + CRLF //ADICIONADO POR JONI
		cQuery += "			SD2.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		GROUP BY" + CRLF
		cQuery += "			BM_GRUPO, BM_DESC, B1_ZZSUBGR, B1_ZZDESCS, D2_UM" + CRLF

		//inclui devolução
		if MV_PAR05 == "1"
			cQuery += "		UNION ALL" + CRLF
			cQuery += "		SELECT" + CRLF
			cQuery += "			BM_GRUPO, BM_DESC," + CRLF
			cQuery += "			B1_ZZDESCS, B1_ZZSUBGR," + CRLF
			cQuery += "          SUM(D1_QUANT) * -1 AS QUANT," + CRLF
			cQuery += "          SUM(D1_TOTAL-D1_VALDESC) * -1 AS TOTAL" + CRLF
			cQuery += "		FROM" + CRLF
			cQuery += "			" + RetSqlName("SD1") + " AS SD1" + CRLF
			cQuery += "		INNER JOIN" + CRLF
			cQuery += "			" + RetSqlName("SD2") + " AS SD2" + CRLF
			cQuery += "		ON 1=1" + CRLF
			cQuery += "			AND D1_FILIAL = D2_FILIAL" + CRLF
			cQuery += "			AND D1_NFORI = D2_DOC" + CRLF
			cQuery += "			AND D1_SERIORI = D2_SERIE" + CRLF
			cQuery += "			AND (D1_ITEMORI = D2_ITEM OR (D1_ITEMORI = ' ' AND CONVERT(INT,D2_ITEM) = CONVERT(INT,D1_ITEM)))" + CRLF
			cQuery += "			AND D1_COD = D2_COD" + CRLF
			cQuery += "			AND SD2.D_E_L_E_T_ = ' '" + CRLF
			cQuery += "		INNER JOIN" + CRLF
			cQuery += "			" + RetSqlName("SB1") + " AS SB1" + CRLF
			cQuery += "		ON" + CRLF
			cQuery += "			B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
			cQuery += "			B1_COD = D1_COD AND" + CRLF
			cQuery += "			SB1.D_E_L_E_T_ = ' '" + CRLF
			cQuery += "		INNER JOIN" + CRLF
			cQuery += "			" + RetSqlName("SBM") + " AS SBM" + CRLF
			cQuery += "		ON" + CRLF
			cQuery += "			BM_FILIAL = '" + xFilial("SBM") + "' AND " + CRLF
			cQuery += "			BM_GRUPO = B1_GRUPO AND" + CRLF
			cQuery += "			SBM.D_E_L_E_T_ = ' '" + CRLF
			cQuery += "		INNER JOIN" + CRLF
			cQuery += "			" + RetSqlName("SF1") + " AS SF1" + CRLF
			cQuery += "		ON" + CRLF
			cQuery += "			F1_FILIAL = '" + xFilial("SF1") + "' AND " + CRLF
			cQuery += "			F1_DOC = D1_DOC AND" + CRLF
			cQuery += "			F1_SERIE = D1_SERIE AND" + CRLF
			cQuery += "			F1_FORNECE = D1_FORNECE AND" + CRLF
			cQuery += "			F1_LOJA = D1_LOJA AND" + CRLF
			cQuery += "			SF1.D_E_L_E_T_ = ' '" + CRLF
			cQuery += "		INNER JOIN" + CRLF
			cQuery += "       	" + RetSqlName("SF4") + " AS SF4" + CRLF
			cQuery += "		ON" + CRLF
			cQuery += "			F4_FILIAL = '" + xFilial("SF4") + "' AND" + CRLF
			cQuery += "			F4_CODIGO = D1_TES AND" + CRLF
			cQuery += "			(( F4_DUPLIC = 'S' AND F4_ESTOQUE = 'S' AND F4_ZZVDFUT <> '1')"+cVendaFutura+" ) AND"+CRLF
			cQuery += "			SF4.D_E_L_E_T_ = ' '" + CRLF
			cQuery += "		WHERE" + CRLF
			cQuery += "			D1_FILIAL = '" + xFilial("SD2") + "' AND " + CRLF
			cQuery += "			D1_TIPO = 'D' AND " + CRLF
			cQuery += "			(D2_UM = 'KG' OR D2_SEGUM = 'KG') AND " + CRLF
			cQuery += "          B1_ZZSUBGR <> ' ' AND" + CRLF
			cQuery += "			BM_GRUPO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND " + CRLF
			cQuery += "			D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' AND " + CRLF
			cQuery += "			SD1.D_E_L_E_T_ = ' '" + CRLF
			cQuery += "		GROUP BY" + CRLF
			cQuery += "			BM_GRUPO, BM_DESC, B1_ZZSUBGR, B1_ZZDESCS, D2_UM" + CRLF
		endif

		cQuery += "		) AS SUBQRY" + CRLF
		cQuery += "WHERE " + CRLF
		cQuery += "	SUBQRY.BM_GRUPO IN ('" + cGrpRestr + "')" + CRLF
		cQuery += "GROUP BY" + CRLF
		cQuery += "	SUBQRY.BM_GRUPO," + CRLF
		cQuery += "	SUBQRY.BM_DESC," + CRLF
		cQuery += "	SUBQRY.B1_ZZSUBGR," + CRLF
		cQuery += "	SUBQRY.B1_ZZDESCS" + CRLF

		memoWrite("\sql\PlanItVen_FAT.sql",cQuery)
	ElseIf cTipo == "DEV"
		cQuery += "SELECT" + CRLF
		cQuery += "	SUBQRY.BM_GRUPO," + CRLF
		cQuery += "	SUBQRY.BM_DESC," + CRLF
		cQuery += "	SUBQRY.B1_ZZSUBGR," + CRLF
		cQuery += "	SUBQRY.B1_ZZDESCS," + CRLF
		cQuery += "	SUM(SUBQRY.QUANT) AS QUANT," + CRLF
		cQuery += "	SUM(SUBQRY.TOTAL) AS TOTAL " + CRLF
		cQuery += "FROM" + CRLF
		cQuery += "	(" + CRLF
		cQuery += "		SELECT" + CRLF
		cQuery += "			BM_GRUPO, BM_DESC," + CRLF
		cQuery += "			B1_ZZDESCS, B1_ZZSUBGR," + CRLF
		cQuery += "          CASE" + CRLF
		cQuery += "          WHEN D2_UM = 'KG' THEN SUM(D1_QUANT)" + CRLF
		cQuery += "          ELSE SUM(D2_ZZPESLI * D1_QUANT) END AS QUANT," + CRLF
		cQuery += "          SUM(D1_TOTAL-D1_VALDESC) AS TOTAL" + CRLF
		cQuery += "		FROM" + CRLF
		cQuery += "			" + RetSqlName("SD1") + " AS SD1" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "			" + RetSqlName("SD2") + " AS SD2" + CRLF
		cQuery += "		ON 1=1" + CRLF
		cQuery += "			AND D1_FILIAL = D2_FILIAL" + CRLF
		cQuery += "			AND D1_NFORI = D2_DOC" + CRLF
		cQuery += "			AND D1_SERIORI = D2_SERIE" + CRLF
		cQuery += "			AND (D1_ITEMORI = D2_ITEM OR (D1_ITEMORI = ' ' AND CONVERT(INT,D2_ITEM) = CONVERT(INT,D1_ITEM)))" + CRLF
		cQuery += "			AND D1_COD = D2_COD" + CRLF
		cQuery += "			AND SD2.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "			" + RetSqlName("SB1") + " AS SB1" + CRLF
		cQuery += "		ON" + CRLF
		cQuery += "			B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
		cQuery += "			B1_COD = D1_COD AND" + CRLF
		cQuery += "			SB1.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "			" + RetSqlName("SBM") + " AS SBM" + CRLF
		cQuery += "		ON" + CRLF
		cQuery += "			BM_FILIAL = '" + xFilial("SBM") + "' AND " + CRLF
		cQuery += "			BM_GRUPO = B1_GRUPO AND" + CRLF
		cQuery += "			SBM.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "			" + RetSqlName("SF1") + " AS SF1" + CRLF
		cQuery += "		ON" + CRLF
		cQuery += "			F1_FILIAL = '" + xFilial("SF1") + "' AND " + CRLF
		cQuery += "			F1_DOC = D1_DOC AND" + CRLF
		cQuery += "			F1_SERIE = D1_SERIE AND" + CRLF
		cQuery += "			F1_FORNECE = D1_FORNECE AND" + CRLF
		cQuery += "			F1_LOJA = D1_LOJA AND" + CRLF
		cQuery += "			SF1.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "       	" + RetSqlName("SF4") + " AS SF4" + CRLF
		cQuery += "		ON" + CRLF
		cQuery += "			F4_FILIAL = '" + xFilial("SF4") + "' AND" + CRLF
		cQuery += "			F4_CODIGO = D1_TES AND" + CRLF
		cQuery += "			(( F4_DUPLIC = 'S' AND F4_ESTOQUE = 'S' AND F4_ZZVDFUT <> '1')"+cVendaFutura+" ) AND"+CRLF
		cQuery += "			SF4.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		WHERE" + CRLF
		cQuery += "			D1_FILIAL = '" + xFilial("SD1") + "' AND " + CRLF
		cQuery += "			D1_TIPO = 'D' AND " + CRLF
		cQuery += "			(D2_UM = 'KG' OR D2_SEGUM = 'KG') AND " + CRLF
		cQuery += "          B1_ZZSUBGR <> ' ' AND" + CRLF
		cQuery += "			BM_GRUPO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND " + CRLF
		cQuery += "			D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' AND " + CRLF
		cQuery += "			SD1.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		GROUP BY" + CRLF
		cQuery += "			BM_GRUPO, BM_DESC, B1_ZZSUBGR, B1_ZZDESCS, D2_UM" + CRLF
		cQuery += "		) AS SUBQRY" + CRLF
		cQuery += "WHERE " + CRLF
		cQuery += "	SUBQRY.BM_GRUPO NOT IN ('" + cGrpRestr + "')" + CRLF
		cQuery += "GROUP BY" + CRLF
		cQuery += "	SUBQRY.BM_GRUPO," + CRLF
		cQuery += "	SUBQRY.BM_DESC," + CRLF
		cQuery += "	SUBQRY.B1_ZZSUBGR," + CRLF
		cQuery += "	SUBQRY.B1_ZZDESCS" + CRLF

		cQuery += "" + CRLF
		cQuery += "UNION ALL " + CRLF
		cQuery += "" + CRLF

		cQuery += "SELECT" + CRLF
		cQuery += "	SUBQRY.BM_GRUPO," + CRLF
		cQuery += "	SUBQRY.BM_DESC," + CRLF
		cQuery += "	SUBQRY.B1_ZZSUBGR," + CRLF
		cQuery += "	SUBQRY.B1_ZZDESCS," + CRLF
		cQuery += "	SUM(SUBQRY.QUANT) AS QUANT," + CRLF
		cQuery += "	SUM(SUBQRY.TOTAL) AS TOTAL " + CRLF
		cQuery += "FROM" + CRLF
		cQuery += "	(" + CRLF
		cQuery += "		SELECT" + CRLF
		cQuery += "			BM_GRUPO, BM_DESC," + CRLF
		cQuery += "			B1_ZZDESCS, B1_ZZSUBGR," + CRLF
		cQuery += "          SUM(D1_QUANT) AS QUANT," + CRLF
		cQuery += "          SUM(D1_TOTAL-D1_VALDESC) AS TOTAL" + CRLF
		cQuery += "		FROM" + CRLF
		cQuery += "			" + RetSqlName("SD1") + " AS SD1" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "			" + RetSqlName("SD2") + " AS SD2" + CRLF
		cQuery += "		ON 1=1" + CRLF
		cQuery += "			AND D1_FILIAL = D2_FILIAL" + CRLF
		cQuery += "			AND D1_NFORI = D2_DOC" + CRLF
		cQuery += "			AND D1_SERIORI = D2_SERIE" + CRLF
		cQuery += "			AND (D1_ITEMORI = D2_ITEM OR (D1_ITEMORI = ' ' AND CONVERT(INT,D2_ITEM) = CONVERT(INT,D1_ITEM)))" + CRLF
		cQuery += "			AND D1_COD = D2_COD" + CRLF
		cQuery += "			AND SD2.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "			" + RetSqlName("SB1") + " AS SB1" + CRLF
		cQuery += "		ON" + CRLF
		cQuery += "			B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
		cQuery += "			B1_COD = D1_COD AND" + CRLF
		cQuery += "			SB1.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "			" + RetSqlName("SBM") + " AS SBM" + CRLF
		cQuery += "		ON" + CRLF
		cQuery += "			BM_FILIAL = '" + xFilial("SBM") + "' AND " + CRLF
		cQuery += "			BM_GRUPO = B1_GRUPO AND" + CRLF
		cQuery += "			SBM.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "			" + RetSqlName("SF1") + " AS SF1" + CRLF
		cQuery += "		ON" + CRLF
		cQuery += "			F1_FILIAL = '" + xFilial("SF1") + "' AND " + CRLF
		cQuery += "			F1_DOC = D1_DOC AND" + CRLF
		cQuery += "			F1_SERIE = D1_SERIE AND" + CRLF
		cQuery += "			F1_FORNECE = D1_FORNECE AND" + CRLF
		cQuery += "			F1_LOJA = D1_LOJA AND" + CRLF
		cQuery += "			SF1.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		INNER JOIN" + CRLF
		cQuery += "       	" + RetSqlName("SF4") + " AS SF4" + CRLF
		cQuery += "		ON" + CRLF
		cQuery += "			F4_FILIAL = '" + xFilial("SF4") + "' AND" + CRLF
		cQuery += "			F4_CODIGO = D1_TES AND" + CRLF
		cQuery += "			(( F4_DUPLIC = 'S' AND F4_ESTOQUE = 'S' AND F4_ZZVDFUT <> '1')"+cVendaFutura+" ) AND"+CRLF
		cQuery += "			SF4.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		WHERE" + CRLF
		cQuery += "			D1_FILIAL = '" + xFilial("SD2") + "' AND " + CRLF
		cQuery += "			D1_TIPO = 'D' AND " + CRLF
		cQuery += "			(D2_UM = 'KG' OR D2_SEGUM = 'KG') AND " + CRLF
		cQuery += "          B1_ZZSUBGR <> ' ' AND" + CRLF
		cQuery += "			BM_GRUPO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND " + CRLF
		cQuery += "			D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' AND " + CRLF
		cQuery += "			SD1.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		GROUP BY" + CRLF
		cQuery += "			BM_GRUPO, BM_DESC, B1_ZZSUBGR, B1_ZZDESCS, D2_UM" + CRLF
		cQuery += "		) AS SUBQRY" + CRLF
		cQuery += "WHERE " + CRLF
		cQuery += "	SUBQRY.BM_GRUPO IN ('" + cGrpRestr + "')" + CRLF
		cQuery += "GROUP BY" + CRLF
		cQuery += "	SUBQRY.BM_GRUPO," + CRLF
		cQuery += "	SUBQRY.BM_DESC," + CRLF
		cQuery += "	SUBQRY.B1_ZZSUBGR," + CRLF
		cQuery += "	SUBQRY.B1_ZZDESCS" + CRLF

		memoWrite("\sql\PlanItVen_DEV.sql",cQuery)
	EndIf


Return (cQuery)


static function addLinhaVazia()
	local aLinTmp := {}

	Aadd(aLinTmp,"")
	Aadd(aLinTmp,"")
	Aadd(aLinTmp,"")
	Aadd(aLinTmp,"")
	Aadd(aLinTmp,"")
	Aadd(aLinTmp,"")

	//Adiciona a Linha na planilha
	oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
return
