#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc}	VendasVen
Relatório de Vendas por Vendedor
@type function
@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					18/08/2015
/*/
User Function VendasVen()
	
	Local aParamBox		:= {}
	
	AADD(aParamBox,{1,"Vendedor De"		,Space(TamSx3("A3_COD")[1]),	"",	"",	"SA3",	"",40, .f.})// MV_PAR01
	AADD(aParamBox,{1,"Vendedor Ate"	,Space(TamSx3("A3_COD")[1]),	"",	"",	"SA3",	"",40, .f.})// MV_PAR02
	AADD(aParamBox,{1,"Emissão de"	,STOD(""),	"",	"",,".T.",50, .f.})// MV_PAR03
	AADD(aParamBox,{1,"Emissão Ate"	,STOD(""),	"",	"",,".T.",50, .f.})// MV_PAR04
	
	If ParamBox(aParamBox,"VENDAS VENDEDOR",,,,,,,,"VendasVen",.T.,.T.)
		Processa({||impDados()},"Gerando Planilha")
	EndIf
	
Return

/*/{Protheus.doc}	impDados
Rotina que gera a planilha

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					18/08/2015
@return				nil
/*/
Static Function impDados()
	
	Local nI			:= 0
	Local aColumns	:= {}
	
	Private cTable		:= "Resumo de Faturamento Por Vendedor x Item De: " + DTOC(MV_PAR03) + " até " + DTOC(MV_PAR04)
	Private cWorkSheet	:= "Res. Faturamento"
	Private nQuant		:= 0
	Private oExcel		:= FWMsExcel():New()
	
	//1 - Nome da Coluna | 2 - Alinhamento | 3 - Formatação | 4 - Deve ser totalizada
	Aadd(aColumns,{"Cod. Vendedor",1,1,.F.})
	Aadd(aColumns,{"Nome Vendedor",1,1,.F.})
	Aadd(aColumns,{"Grupo",1,1,.F.})
	Aadd(aColumns,{"Descrição Grupo",1,1,.F.})
	Aadd(aColumns,{"SubGrupo",1,1,.F.})
	Aadd(aColumns,{"Descrição SubGrupo",1,1,.F.})
	Aadd(aColumns,{"Peso em KG",1,3,.F.})
	Aadd(aColumns,{"Valor Total",1,3,.F.})
	Aadd(aColumns,{"Preço Médio",1,3,.F.})
	
	oExcel:AddWorkSheet(cWorkSheet)
	oExcel:AddTable(cWorkSheet,cTable)
	
	//Percorre as colunas para inserir na planilha
	For nI := 1 To Len(aColumns)
		oExcel:AddColumn(cWorkSheet,cTable,aColumns[nI,1],aColumns[nI,2],aColumns[nI,3],aColumns[nI,4])
	Next
	
	buscaDados()
	
Return

/*/{Protheus.doc}	buscaDados
Realiza a busca dos dados conforme parâmetros selecionados

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					18/08/2015
@return				nil
/*/
Static Function buscaDados()
	
	Local cQuery 		:= ""
	Local nTotalReg	:= 0
	Local nContador	:= 0
	Local cAlias		:= GetNextAlias()
	Local aLinTmp		:= {}
	
	Local cVendedor	:= ""
	Local cNomeVend	:= ""
	Local cGrupo		:= ""
	Local cDescGrupo	:= ""
	
	//Quantidades
	Local nQtdGrupo	:= 0
	Local nQtdVend	:= 0
	Local nTOTQuant	:= 0
	
	//Valores
	Local nValGrupo	:= 0
	Local nValVend	:= 0
	Local nTOTValor	:= 0
	
	Local cSeparador	:= ";"
	Local cGrpRestr	:= StrTran(GetNewPar("MV_ZZFATPE",""),cSeparador,"','")
	
	cQuery += "SELECT" + CRLF
	cQuery += "	C5_VEND1 AS COD_VEND," + CRLF
	cQuery += "	A3_NOME AS NOME_VEND," + CRLF
	cQuery += "	BM_GRUPO AS COD_GRUPO," + CRLF
	cQuery += "	BM_DESC AS DESC_GRUPO," + CRLF
	cQuery += "	B1_ZZSUBGR AS COD_SUBGRUPO," + CRLF
	cQuery += "	B1_ZZDESCS AS DESC_SUBGRUPO," + CRLF
	cQuery += "	SUM(CASE WHEN BM_GRUPO IN ('" + cGrpRestr + "') THEN D2_QUANT ELSE CASE WHEN D2_UM = 'KG' THEN D2_QUANT ELSE D2_ZZPESLI * D2_QUANT END END) AS QUANT_TOTAL," + CRLF
	cQuery += "	SUM(D2_TOTAL) AS VALOR_TOTAL" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + RetSqlName("SD2") + " AS SD2" + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlName("SC5") + " AS SC5" + CRLF
	cQuery += "ON" + CRLF
	cQuery += "	C5_FILIAL = '" + xFilial("SC5") + "' AND" + CRLF
	cQuery += "	C5_NUM = D2_PEDIDO AND" + CRLF
	cQuery += "	SC5.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlName("SA3") + " AS SA3" + CRLF
	cQuery += "ON" + CRLF
	cQuery += "	A3_FILIAL = '" + xFilial("SA3") + "' AND" + CRLF
	cQuery += "	A3_COD = C5_VEND1 AND" + CRLF
	cQuery += "	SA3.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlName("SB1") + " AS SB1" + CRLF
	cQuery += "ON" + CRLF
	cQuery += "	B1_FILIAL = '" + xFilial("SB1") + "' AND" + CRLF
	cQuery += "	B1_COD = D2_COD AND" + CRLF
	cQuery += "	SB1.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlName("SBM") + " AS SBM" + CRLF
	cQuery += "ON" + CRLF
	cQuery += "	BM_FILIAL = '" + xFilial("SBM") + "' AND" + CRLF
	cQuery += "	BM_GRUPO = B1_GRUPO AND" + CRLF
	cQuery += "	SBM.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlName("SF4") + " AS SF4" + CRLF
	cQuery += "ON" + CRLF
	cQuery += "	F4_FILIAL = '" + xFilial("SF4") + "' AND" + CRLF
	cQuery += "	F4_CODIGO = D2_TES AND" + CRLF
	cQuery += "	F4_DUPLIC = 'S' AND" + CRLF
	cQuery += "	F4_ESTOQUE = 'S' AND" + CRLF
	cQuery += "	SF4.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "WHERE" + CRLF
	cQuery += "	D2_FILIAL = '" + xFilial("SD2") + "' AND" + CRLF
	cQuery += "	D2_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' AND" + CRLF
	cQuery += "	D2_TIPO ='N' AND " + CRLF //ADICIONADO POR JONI
	cQuery += "	A3_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND " + CRLF
	cQuery += "	B1_ZZSUBGR <> ' ' AND" + CRLF
	cQuery += "	((B1_UM = 'KG' OR B1_SEGUM = 'KG') OR BM_GRUPO IN ('" + cGrpRestr + "')) AND" + CRLF
	cQuery += "	SD2.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "GROUP BY" + CRLF
	cQuery += "	C5_VEND1, A3_NOME, BM_GRUPO, " + CRLF
	cQuery += "	BM_DESC, B1_ZZSUBGR, B1_ZZDESCS" + CRLF
	cQuery += "ORDER BY" + CRLF
	cQuery += "	C5_VEND1, BM_GRUPO, B1_ZZSUBGR" + CRLF
	
	TcQuery cQuery New Alias &cAlias
	
	Count to nTotalReg
	(cAlias)->(DbGoTop())
	
	If (cAlias)->(!Eof())
		cVendedor	:= (cAlias)->COD_VEND
		cNomeVend	:= (cAlias)->NOME_VEND
		cGrupo		:= (cAlias)->COD_GRUPO
		cDescGrupo	:= (cAlias)->DESC_GRUPO

		While (cAlias)->(!Eof())
		
			nTOTQuant	+= (cAlias)->QUANT_TOTAL
			nTOTValor	+= (cAlias)->VALOR_TOTAL
			
			//Imprime o totalizador dos grupos
			If cVendedor == (cAlias)->COD_VEND
				If cGrupo <> (cAlias)->COD_GRUPO
					Aadd(aLinTmp, cVendedor)
					Aadd(aLinTmp, cNomeVend)
					Aadd(aLinTmp, cGrupo)
					Aadd(aLinTmp, cDescGrupo)
					Aadd(aLinTmp, "")
					Aadd(aLinTmp, "")
					Aadd(aLinTmp,	nQtdGrupo)
					Aadd(aLinTmp,	nValGrupo)
					Aadd(aLinTmp,	nValGrupo / nQtdGrupo)
					oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
					aLinTmp := {}
					
					cVendedor	:= (cAlias)->COD_VEND
					cNomeVend	:= (cAlias)->NOME_VEND
					cGrupo		:= (cAlias)->COD_GRUPO
					cDescGrupo	:= (cAlias)->DESC_GRUPO
					nQtdGrupo	:= (cAlias)->QUANT_TOTAL
					nValGrupo	:= (cAlias)->VALOR_TOTAL
				Else
					nQtdGrupo += (cAlias)->QUANT_TOTAL
					nValGrupo += (cAlias)->VALOR_TOTAL
				EndIf
			Else
				//Imprime o totalizador do ultimo grupo
				Aadd(aLinTmp, cVendedor)
				Aadd(aLinTmp, cNomeVend)
				Aadd(aLinTmp, cGrupo)
				Aadd(aLinTmp, cDescGrupo)
				Aadd(aLinTmp, "")
				Aadd(aLinTmp, "")
				Aadd(aLinTmp,	nQtdGrupo)
				Aadd(aLinTmp,	nValGrupo)
				Aadd(aLinTmp,	nValGrupo / nQtdGrupo)
				oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
				aLinTmp := {}
				
				//Imprime o totalizador do estado
				Aadd(aLinTmp, cVendedor)
				Aadd(aLinTmp, cNomeVend)
				Aadd(aLinTmp, "TOTAL VENDEDOR")
				Aadd(aLinTmp, "")
				Aadd(aLinTmp, "")
				Aadd(aLinTmp, "")
				Aadd(aLinTmp, nQtdVend)
				Aadd(aLinTmp,	nValVend)
				Aadd(aLinTmp,	nValVend / nQtdVend)
				oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
				nQtdVend := 0
				nValVend := 0
				aLinTmp := {}
				
				cVendedor	:= (cAlias)->COD_VEND
				cNomeVend	:= (cAlias)->NOME_VEND
				cGrupo		:= (cAlias)->COD_GRUPO
				cDescGrupo	:= (cAlias)->DESC_GRUPO
				nQtdGrupo	:= (cAlias)->QUANT_TOTAL
				nValGrupo	:= (cAlias)->VALOR_TOTAL
			EndIf
			
			Aadd(aLinTmp, (cAlias)->COD_VEND)
			Aadd(aLinTmp, (cAlias)->NOME_VEND)
			Aadd(aLinTmp, (cAlias)->COD_GRUPO)
			Aadd(aLinTmp, (cAlias)->DESC_GRUPO)
			Aadd(aLinTmp, (cAlias)->COD_SUBGRUPO)
			Aadd(aLinTmp, (cAlias)->DESC_SUBGRUPO)
			Aadd(aLinTmp,	(cAlias)->QUANT_TOTAL)
			Aadd(aLinTmp,	(cAlias)->VALOR_TOTAL)
			Aadd(aLinTmp,	(cAlias)->VALOR_TOTAL / (cAlias)->QUANT_TOTAL)
			nQtdVend += (cAlias)->QUANT_TOTAL
			nValVend += (cAlias)->VALOR_TOTAL
			oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
			
			aLinTmp := {}
			nContador++
			IncProc("Processando registro " + cValToChar(nContador) + " de " + cValToChar(nTotalReg) + "...")
			(cAlias)->(DbSkip())
		EndDo
	Else
		MsgAlert("Não foram encontrados dados com os parametros informados.")
		return
	EndIf
	
	//Ultimo registro da tabela
	Aadd(aLinTmp, cVendedor)
	Aadd(aLinTmp, cNomeVend)
	Aadd(aLinTmp, cGrupo)
	Aadd(aLinTmp, cDescGrupo)
	Aadd(aLinTmp, "")
	Aadd(aLinTmp, "")
	Aadd(aLinTmp,	nQtdGrupo)
	Aadd(aLinTmp,	nValGrupo)
	Aadd(aLinTmp,	nValGrupo / nQtdGrupo)
	oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
	aLinTmp := {}
	
	//Imprime o totalizador do estado
	Aadd(aLinTmp, cVendedor)
	Aadd(aLinTmp, cNomeVend)
	Aadd(aLinTmp, "TOTAL VENDEDOR")
	Aadd(aLinTmp, "")
	Aadd(aLinTmp, "")
	Aadd(aLinTmp, "")
	Aadd(aLinTmp,	nQtdVend)
	Aadd(aLinTmp,	nValVend)
	Aadd(aLinTmp,	nValVend / nQtdVend)
	oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
	aLinTmp := {}	
	
	//Totalizador Final
	Aadd(aLinTmp, "TOTAL")
	Aadd(aLinTmp, "")
	Aadd(aLinTmp, "")
	Aadd(aLinTmp, "")
	Aadd(aLinTmp, "")
	Aadd(aLinTmp, "")
	Aadd(aLinTmp,	nTOTQuant)
	Aadd(aLinTmp,	nTOTValor)
	Aadd(aLinTmp,	nTOTValor / nTOTQuant)
	oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
	
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
