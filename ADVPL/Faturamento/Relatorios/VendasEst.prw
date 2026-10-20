#Include "Protheus.ch"
#Include "Topconn.ch"

#DEFINE TABLE_DEV			"Resumo de Devoluções Por Estado"
#DEFINE TABLE_FAT			"Resumo de Faturamento Por Estado"
#DEFINE WORKSH_DEV			"Devoluções"
#DEFINE WORKSH_FAT			"Res. Faturamento Estado"

/*/{Protheus.doc}	VendasEst
Relatório de Vendas por Estado

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					18/08/2015
@return				nil
/*/
User Function VendasEst()
	
	Local aParamBox		:= {}
	
	AADD(aParamBox,{1,"Emissão de"	,STOD(""),	"",	"",,".T.",50, .f.})// MV_PAR01
	AADD(aParamBox,{1,"Emissão Ate"	,STOD(""),	"",	"",,".T.",50, .f.})// MV_PAR02

	Aadd(aParambox,{2,"Inclui Devolução"	,"1",{"1-Sim","2-Nao"},50,,.f.})// MV_PAR03
	
	If ParamBox(aParamBox,"VENDAS ESTADO",,,,,,,,"VendasEst",.T.,.T.)
		MV_PAR03 := Iif(type("MV_PAR03")=="N",alltrim(str(MV_PAR03)),substr(MV_PAR03,1,1))
		
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
	
	Private nQuant		:= 0
	Private oExcel		:= FWMsExcel():New()
	
	//1 - Nome da Coluna | 2 - Alinhamento | 3 - Formatação | 4 - Deve ser totalizada
	Aadd(aColumns,{"Estado",1,1,.F.})
	Aadd(aColumns,{"Nome Estado",1,1,.F.})
	Aadd(aColumns,{"Grupo",1,1,.F.})
	Aadd(aColumns,{"Descrição Grupo",1,1,.F.})
	Aadd(aColumns,{"SubGrupo",1,1,.F.})
	Aadd(aColumns,{"Descrição SubGrupo",1,1,.F.})
	Aadd(aColumns,{"Valor Total",1,3,.F.})
	
	oExcel:AddWorkSheet(WORKSH_FAT)
	oExcel:AddTable(WORKSH_FAT,TABLE_FAT)
	
	//Percorre as colunas para inserir na planilha
	For nI := 1 To Len(aColumns)
		oExcel:AddColumn(WORKSH_FAT,TABLE_FAT,aColumns[nI,1],aColumns[nI,2],aColumns[nI,3],aColumns[nI,4])
	Next
	
	if MV_PAR03 == "1"
		oExcel:AddWorkSheet(WORKSH_DEV)
		oExcel:AddTable(WORKSH_DEV,TABLE_DEV)
		
		//Percorre as colunas para inserir na planilha
		For nI := 1 To Len(aColumns)
			oExcel:AddColumn(WORKSH_DEV,TABLE_DEV,aColumns[nI,1],aColumns[nI,2],aColumns[nI,3],aColumns[nI,4])
		Next
	endif
	
	buscaDados()
	
Return

/*/{Protheus.doc}	buscaDados
Realiza a busca dos dados conforme parâmetros selecionados

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					18/08/2015
@return				nil
/*/
Static Function buscaDados()
	
	Local nW		:= 0
	Local cQuery 	:= ""
	Local nTotalReg	:= 0
	Local nContador	:= 0
	Local cAlias	:= GetNextAlias()
	Local aLinTmp	:= {}
	
	Local cEstado	:= ""
	Local cDescEst	:= ""
	Local cGrupo	:= ""
	Local cDescGrupo:= ""
	Local nValGrupo	:= 0
	Local nValEst	:= 0
	Local nTOTValor	:= 0

	Local aTipos		:= Iif(MV_PAR03 == "1",{"FAT","DEV"},{"FAT"})
	
	For nW := 1 to Len(aTipos)
		nValGrupo := 0
		nValEst   := 0
		nTOTValor := 0
		
		If aTipos[nW] == "FAT"
			cWorkSheet		:= WORKSH_FAT
			cTable			:= TABLE_FAT
		ElseIf aTipos[nW] == "DEV"
			cWorkSheet		:= WORKSH_DEV
			cTable			:= TABLE_DEV
		EndIf

		cQuery := MontaQuerys(aTipos[nW])
		memowrite("\sql\vendas_est_" + aTipos[nW]+".sql",cQuery)
		TcQuery cQuery New Alias &cAlias
		
		Count to nTotalReg
		(cAlias)->(DbGoTop())
		
		If (cAlias)->(!Eof())
			cEstado	:= (cAlias)->UF
			cDescEst	:= (cAlias)->NOME_EST
			cGrupo		:= (cAlias)->COD_GRUPO
			cDescGrupo	:= (cAlias)->DESC_GRUPO
	
			While (cAlias)->(!Eof())
			
				nTOTValor	+= (cAlias)->VALOR_TOTAL
				
				//Imprime o totalizador dos grupos
				If cEstado == (cAlias)->UF
					If cGrupo <> (cAlias)->COD_GRUPO
						Aadd(aLinTmp, cEstado)
						Aadd(aLinTmp, cDescEst)
						Aadd(aLinTmp, cGrupo)
						Aadd(aLinTmp, cDescGrupo)
						Aadd(aLinTmp, "")
						Aadd(aLinTmp, "")
						Aadd(aLinTmp,	nValGrupo)
						oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
						aLinTmp := {}
						
						cEstado	:= (cAlias)->UF
						cDescEst	:= (cAlias)->NOME_EST
						cGrupo		:= (cAlias)->COD_GRUPO
						cDescGrupo	:= (cAlias)->DESC_GRUPO
						nValGrupo	:= (cAlias)->VALOR_TOTAL
					Else
						nValGrupo += (cAlias)->VALOR_TOTAL
					EndIf
				Else
					//Imprime o totalizador do ultimo grupo
					Aadd(aLinTmp, cEstado)
					Aadd(aLinTmp, cDescEst)
					Aadd(aLinTmp, cGrupo)
					Aadd(aLinTmp, cDescGrupo)
					Aadd(aLinTmp, "")
					Aadd(aLinTmp, "")
					Aadd(aLinTmp,	nValGrupo)
					oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
					aLinTmp := {}
					
					//Imprime o totalizador do estado
					Aadd(aLinTmp, cEstado)
					Aadd(aLinTmp, cDescEst)
					Aadd(aLinTmp, "TOTAL ESTADO")
					Aadd(aLinTmp, "")
					Aadd(aLinTmp, "")
					Aadd(aLinTmp, "")
					Aadd(aLinTmp,	nValEst)
					oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
					nValEst := 0
					aLinTmp := {}
					
					cEstado	:= (cAlias)->UF
					cDescEst	:= (cAlias)->NOME_EST
					cGrupo		:= (cAlias)->COD_GRUPO
					cDescGrupo	:= (cAlias)->DESC_GRUPO
					nValGrupo	:= (cAlias)->VALOR_TOTAL
				EndIf
				
				Aadd(aLinTmp, (cAlias)->UF)
				Aadd(aLinTmp, (cAlias)->NOME_EST)
				Aadd(aLinTmp, (cAlias)->COD_GRUPO)
				Aadd(aLinTmp, (cAlias)->DESC_GRUPO)
				Aadd(aLinTmp, (cAlias)->COD_SUBGRUPO)
				Aadd(aLinTmp, (cAlias)->DESC_SUBGRUPO)
				Aadd(aLinTmp,	(cAlias)->VALOR_TOTAL)
				nValEst += (cAlias)->VALOR_TOTAL
				oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
				
				aLinTmp := {}
				nContador++
				IncProc("Processando registro " + cValToChar(nContador) + " de " + cValToChar(nTotalReg) + "...")
				(cAlias)->(DbSkip())
			EndDo
		Else
			return
		EndIf
		
		//Ultimo registro da tabela
		Aadd(aLinTmp, cEstado)
		Aadd(aLinTmp, cDescEst)
		Aadd(aLinTmp, cGrupo)
		Aadd(aLinTmp, cDescGrupo)
		Aadd(aLinTmp, "")
		Aadd(aLinTmp, "")
		Aadd(aLinTmp,	nValGrupo)
		oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
		aLinTmp := {}
		
		//Imprime o totalizador do estado
		Aadd(aLinTmp, cEstado)
		Aadd(aLinTmp, cDescEst)
		Aadd(aLinTmp, "TOTAL ESTADO")
		Aadd(aLinTmp, "")
		Aadd(aLinTmp, "")
		Aadd(aLinTmp, "")
		Aadd(aLinTmp,	nValEst)
		oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
		aLinTmp := {}	
		
		//Totalizador Final
		Aadd(aLinTmp, "TOTAL")
		Aadd(aLinTmp, "")
		Aadd(aLinTmp, "")
		Aadd(aLinTmp, "")
		Aadd(aLinTmp, "")
		Aadd(aLinTmp, "")
		Aadd(aLinTmp,	nTOTValor)	
		oExcel:AddRow(cWorkSheet,cTable,aLinTmp)

		(cAlias)->(DbCloseArea())
		aLinTmp := {}
		nContador := 1
	Next nW

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

static function MontaQuerys(cTipo)
	local cQuery := ""
	
	if cTipo == "FAT"
		cQuery += "SELECT " + CRLF
		cQuery += "	UF," + CRLF
		cQuery += "	NOME_EST," + CRLF
		cQuery += "	COD_GRUPO," + CRLF
		cQuery += "	DESC_GRUPO," + CRLF
		cQuery += "	COD_SUBGRUPO," + CRLF
		cQuery += "	DESC_SUBGRUPO," + CRLF
		cQuery += "	SUM(VALOR_TOTAL) AS VALOR_TOTAL" + CRLF
		cQuery += "FROM (" + CRLF
	
		cQuery += "SELECT" + CRLF
		cQuery += "	A1_EST AS UF," + CRLF
		cQuery += "	X5_DESCRI AS NOME_EST," + CRLF
		cQuery += "	BM_GRUPO AS COD_GRUPO," + CRLF
		cQuery += "	BM_DESC AS DESC_GRUPO," + CRLF
		cQuery += "	B1_ZZSUBGR AS COD_SUBGRUPO," + CRLF
		cQuery += "	B1_ZZDESCS AS DESC_SUBGRUPO," + CRLF
		cQuery += "	SUM(D2_TOTAL) AS VALOR_TOTAL" + CRLF
		cQuery += "FROM" + CRLF
		cQuery += "	" + RetSqlName("SD2") + " AS SD2" + CRLF
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
		cQuery += "	" + RetSqlName("SA1") + " AS SA1" + CRLF
		cQuery += "ON" + CRLF
		cQuery += "	A1_FILIAL = '" + xFilial("SA1") + "' AND" + CRLF
		cQuery += "	A1_COD = D2_CLIENTE AND" + CRLF
		cQuery += "	A1_LOJA = D2_LOJA AND" + CRLF
		cQuery += "	SA1.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "INNER JOIN" + CRLF
		cQuery += "	" + RetSqlName("SX5") + " AS SX5" + CRLF
		cQuery += "ON" + CRLF
		cQuery += "	X5_FILIAL = '" + xFilial("SX5") + "' AND" + CRLF
		cQuery += "	X5_TABELA = '12' AND" + CRLF
		cQuery += "	X5_CHAVE = A1_EST AND" + CRLF
		cQuery += "	SX5.D_E_L_E_T_ = ' '" + CRLF
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
		cQuery += "	D2_TIPO = 'N' AND" + CRLF //ADICIONADO POR JONI
		cQuery += "	D2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND" + CRLF
		cQuery += "	B1_ZZSUBGR <> ' ' AND" + CRLF
		cQuery += "	SD2.D_E_L_E_T_ = ' '" + CRLF
		
		cQuery += "GROUP BY" + CRLF
		cQuery += "	A1_EST, X5_DESCRI, BM_GRUPO," + CRLF
		cQuery += "	BM_DESC, B1_ZZSUBGR, B1_ZZDESCS" + CRLF
	
		//inclui devolução
		if MV_PAR03 == "1"
			cQuery += "UNION ALL" + CRLF
			cQuery += "SELECT" + CRLF
			cQuery += "	A1_EST AS UF," + CRLF
			cQuery += "	X5_DESCRI AS NOME_EST," + CRLF
			cQuery += "	BM_GRUPO AS COD_GRUPO," + CRLF
			cQuery += "	BM_DESC AS DESC_GRUPO," + CRLF
			cQuery += "	B1_ZZSUBGR AS COD_SUBGRUPO," + CRLF
			cQuery += "	B1_ZZDESCS AS DESC_SUBGRUPO," + CRLF
			cQuery += "	SUM(D1_TOTAL-D1_VALDESC) * -1 AS VALOR_TOTAL" + CRLF
			cQuery += "FROM" + CRLF
			cQuery += "	" + RetSqlName("SD1") + " AS SD1" + CRLF
			cQuery += "INNER JOIN" + CRLF
			cQuery += "	" + RetSqlName("SB1") + " AS SB1" + CRLF
			cQuery += "ON" + CRLF
			cQuery += "	B1_FILIAL = '" + xFilial("SB1") + "' AND" + CRLF
			cQuery += "	B1_COD = D1_COD AND" + CRLF
			cQuery += "	SB1.D_E_L_E_T_ = ' '" + CRLF
			cQuery += "INNER JOIN" + CRLF
			cQuery += "	" + RetSqlName("SBM") + " AS SBM" + CRLF
			cQuery += "ON" + CRLF
			cQuery += "	BM_FILIAL = '" + xFilial("SBM") + "' AND" + CRLF
			cQuery += "	BM_GRUPO = B1_GRUPO AND" + CRLF
			cQuery += "	SBM.D_E_L_E_T_ = ' '" + CRLF
			cQuery += "INNER JOIN" + CRLF
			cQuery += "	" + RetSqlName("SA1") + " AS SA1" + CRLF
			cQuery += "ON" + CRLF
			cQuery += "	A1_FILIAL = '" + xFilial("SA1") + "' AND" + CRLF
			cQuery += "	A1_COD = D1_FORNECE AND" + CRLF
			cQuery += "	A1_LOJA = D1_LOJA AND" + CRLF
			cQuery += "	SA1.D_E_L_E_T_ = ' '" + CRLF
			cQuery += "INNER JOIN" + CRLF
			cQuery += "	" + RetSqlName("SX5") + " AS SX5" + CRLF
			cQuery += "ON" + CRLF
			cQuery += "	X5_FILIAL = '" + xFilial("SX5") + "' AND" + CRLF
			cQuery += "	X5_TABELA = '12' AND" + CRLF
			cQuery += "	X5_CHAVE = A1_EST AND" + CRLF
			cQuery += "	SX5.D_E_L_E_T_ = ' '" + CRLF
			cQuery += "INNER JOIN" + CRLF
			cQuery += "	" + RetSqlName("SF4") + " AS SF4" + CRLF
			cQuery += "ON" + CRLF
			cQuery += "	F4_FILIAL = '" + xFilial("SF4") + "' AND" + CRLF
			cQuery += "	F4_CODIGO = D1_TES AND" + CRLF
			cQuery += "	F4_DUPLIC = 'S' AND" + CRLF
			cQuery += "	F4_ESTOQUE = 'S' AND" + CRLF
			cQuery += "	SF4.D_E_L_E_T_ = ' '" + CRLF
			cQuery += "WHERE" + CRLF
			cQuery += "	D1_FILIAL = '" + xFilial("SD1") + "' AND" + CRLF
			cQuery += "	D1_TIPO = 'D' AND" + CRLF
			cQuery += "	(B1_UM = 'KG' OR B1_SEGUM = 'KG') AND " + CRLF
			cQuery += "	D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND" + CRLF
			cQuery += "	B1_ZZSUBGR <> ' ' AND" + CRLF
			cQuery += "	SD1.D_E_L_E_T_ = ' '" + CRLF
		
			cQuery += "GROUP BY" + CRLF
			cQuery += "	A1_EST, X5_DESCRI, BM_GRUPO," + CRLF
			cQuery += "	BM_DESC, B1_ZZSUBGR, B1_ZZDESCS" + CRLF
		endif
	
		cQuery += ") SUBQRY" + CRLF
		cQuery += "GROUP BY " + CRLF
		cQuery += "	UF," + CRLF
		cQuery += "	NOME_EST," + CRLF
		cQuery += "	COD_GRUPO," + CRLF
		cQuery += "	DESC_GRUPO," + CRLF
		cQuery += "	COD_SUBGRUPO," + CRLF
		cQuery += "	DESC_SUBGRUPO" + CRLF
		cQuery += "ORDER BY" + CRLF
		cQuery += "	UF," + CRLF
		cQuery += "	COD_GRUPO," + CRLF
		cQuery += "	COD_SUBGRUPO" + CRLF
	elseif cTipo == "DEV"
		cQuery += "SELECT " + CRLF
		cQuery += "	UF," + CRLF
		cQuery += "	NOME_EST," + CRLF
		cQuery += "	COD_GRUPO," + CRLF
		cQuery += "	DESC_GRUPO," + CRLF
		cQuery += "	COD_SUBGRUPO," + CRLF
		cQuery += "	DESC_SUBGRUPO," + CRLF
		cQuery += "	SUM(VALOR_TOTAL) AS VALOR_TOTAL" + CRLF
		cQuery += "FROM (" + CRLF
	
		cQuery += "SELECT" + CRLF
		cQuery += "	A1_EST AS UF," + CRLF
		cQuery += "	X5_DESCRI AS NOME_EST," + CRLF
		cQuery += "	BM_GRUPO AS COD_GRUPO," + CRLF
		cQuery += "	BM_DESC AS DESC_GRUPO," + CRLF
		cQuery += "	B1_ZZSUBGR AS COD_SUBGRUPO," + CRLF
		cQuery += "	B1_ZZDESCS AS DESC_SUBGRUPO," + CRLF
		cQuery += "	SUM(D1_TOTAL-D1_VALDESC) AS VALOR_TOTAL" + CRLF
		cQuery += "FROM" + CRLF
		cQuery += "	" + RetSqlName("SD1") + " AS SD1" + CRLF
		cQuery += "INNER JOIN" + CRLF
		cQuery += "	" + RetSqlName("SB1") + " AS SB1" + CRLF
		cQuery += "ON" + CRLF
		cQuery += "	B1_FILIAL = '" + xFilial("SB1") + "' AND" + CRLF
		cQuery += "	B1_COD = D1_COD AND" + CRLF
		cQuery += "	SB1.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "INNER JOIN" + CRLF
		cQuery += "	" + RetSqlName("SBM") + " AS SBM" + CRLF
		cQuery += "ON" + CRLF
		cQuery += "	BM_FILIAL = '" + xFilial("SBM") + "' AND" + CRLF
		cQuery += "	BM_GRUPO = B1_GRUPO AND" + CRLF
		cQuery += "	SBM.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "INNER JOIN" + CRLF
		cQuery += "	" + RetSqlName("SA1") + " AS SA1" + CRLF
		cQuery += "ON" + CRLF
		cQuery += "	A1_FILIAL = '" + xFilial("SA1") + "' AND" + CRLF
		cQuery += "	A1_COD = D1_FORNECE AND" + CRLF
		cQuery += "	A1_LOJA = D1_LOJA AND" + CRLF
		cQuery += "	SA1.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "INNER JOIN" + CRLF
		cQuery += "	" + RetSqlName("SX5") + " AS SX5" + CRLF
		cQuery += "ON" + CRLF
		cQuery += "	X5_FILIAL = '" + xFilial("SX5") + "' AND" + CRLF
		cQuery += "	X5_TABELA = '12' AND" + CRLF
		cQuery += "	X5_CHAVE = A1_EST AND" + CRLF
		cQuery += "	SX5.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "INNER JOIN" + CRLF
		cQuery += "	" + RetSqlName("SF4") + " AS SF4" + CRLF
		cQuery += "ON" + CRLF
		cQuery += "	F4_FILIAL = '" + xFilial("SF4") + "' AND" + CRLF
		cQuery += "	F4_CODIGO = D1_TES AND" + CRLF
		cQuery += "	F4_DUPLIC = 'S' AND" + CRLF
		cQuery += "	F4_ESTOQUE = 'S' AND" + CRLF
		cQuery += "	SF4.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "WHERE" + CRLF
		cQuery += "	D1_FILIAL = '" + xFilial("SD1") + "' AND" + CRLF
		cQuery += "	D1_TIPO = 'D' AND" + CRLF
		cQuery += "	(B1_UM = 'KG' OR B1_SEGUM = 'KG') AND " + CRLF
		cQuery += "	D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND" + CRLF
		cQuery += "	B1_ZZSUBGR <> ' ' AND" + CRLF
		cQuery += "	SD1.D_E_L_E_T_ = ' '" + CRLF
	
		cQuery += "GROUP BY" + CRLF
		cQuery += "	A1_EST, X5_DESCRI, BM_GRUPO," + CRLF
		cQuery += "	BM_DESC, B1_ZZSUBGR, B1_ZZDESCS" + CRLF
	
		cQuery += ") SUBQRY" + CRLF
		cQuery += "GROUP BY " + CRLF
		cQuery += "	UF," + CRLF
		cQuery += "	NOME_EST," + CRLF
		cQuery += "	COD_GRUPO," + CRLF
		cQuery += "	DESC_GRUPO," + CRLF
		cQuery += "	COD_SUBGRUPO," + CRLF
		cQuery += "	DESC_SUBGRUPO" + CRLF
		cQuery += "ORDER BY" + CRLF
		cQuery += "	UF," + CRLF
		cQuery += "	COD_GRUPO," + CRLF
		cQuery += "	COD_SUBGRUPO" + CRLF
	endif
return cQuery
