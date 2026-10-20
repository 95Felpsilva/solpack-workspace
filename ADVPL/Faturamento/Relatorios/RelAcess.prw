#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc}	RelAcess
Planilha dos acessórios

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					27/07/2015
@return				nil
/*/
User Function RelAcess()
	
	Local aParamBox		:= {}
	
	AADD(aParamBox,{1,"Emissão de"	,STOD(""),	"",	"",,".T.",50, .f.})// MV_PAR03
	AADD(aParamBox,{1,"Emissão Ate"	,STOD(""),	"",	"",,".T.",50, .f.})// MV_PAR04

	If ParamBox(aParamBox,"ITENS ACESSORIOS",,,,,,,,"ITACESSOR",.T.,.T.)
		Processa({||impDados()},"Gerando Planilha")
	EndIf
	
Return

/*/{Protheus.doc}	impDados
Rotina que gera a planilha de Resumo de Faturamento em KG por Grupo de Estoque

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					27/07/2015
@return				nil
/*/
Static Function impDados()

	Local nI			:= 0
	Local aColumns	:= {}
	
	Private cTable		:= "Resumo de Faturamento do Grupo de Estoque ACESSORIOS De: " + DTOC(MV_PAR01) + " até " + DTOC(MV_PAR02) 
	Private cWorkSheet	:= "Res. Faturamento Acessorios"
	Private nQuant		:= 0	
	Private oExcel		:= FWMsExcel():New()
	
	//1 - Nome da Coluna | 2 - Alinhamento | 3 - Formatação | 4 - Deve ser totalizada
	Aadd(aColumns,{"Grupo",1,1,.F.})
	Aadd(aColumns,{"SubGrupo",1,1,.F.})
	Aadd(aColumns,{"Descrição Grupo",1,1,.F.})
	Aadd(aColumns,{"Valor",1,3,.F.})
	Aadd(aColumns,{"Qtd. Venda",1,3,.F.})
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
@since					27/07/2015
@return				nil
/*/
Static Function buscaDados()

	Local cQuery 		:= ""
	Local cGrupo		:= ""
	Local cDescGrupo	:= ""
	Local nTotalReg	:= 0
	Local nContador	:= 0
	Local cAlias		:= GetNextAlias()
	Local aLinTmp		:= {}
	
	Local nPeso		:= 0
	Local nValGrupo	:= 0
	Local nPesoGrupo	:= 0
	Local nPrecoMedio	:= 0
	
	Local nTOTValor	:= 0
	Local nTOTPeso	:= 0
	
	Local cSeparador	:= ";"
	Local cGrpRestr	:= StrTran(GetNewPar("MV_ZZFATPE",""),cSeparador,"','")
	
	cQuery += "SELECT" + CRLF
	cQuery += "	SUBQRY.BM_GRUPO," + CRLF
	cQuery += "	SUBQRY.BM_DESC," + CRLF
	cQuery += "	SUBQRY.B1_ZZSUBGR," + CRLF
	cQuery += "	SUBQRY.B1_ZZDESCS," + CRLF
	cQuery += "	SUM(SUBQRY.D2_QUANT) AS D2_QUANT," + CRLF
	cQuery += "	SUM(SUBQRY.D2_TOTAL) AS D2_TOTAL " + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	(" + CRLF
	cQuery += "		SELECT" + CRLF
	cQuery += "			BM_GRUPO, BM_DESC," + CRLF
	cQuery += "			B1_ZZDESCS, B1_ZZSUBGR," + CRLF
	cQuery += "          SUM(D2_QUANT) AS D2_QUANT," + CRLF
	cQuery += "          SUM(D2_TOTAL) AS D2_TOTAL" + CRLF
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
	cQuery += "			F4_DUPLIC = 'S' AND" + CRLF
	cQuery += "			F4_ESTOQUE = 'S' AND" + CRLF
	cQuery += "			SF4.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "		WHERE" + CRLF
	cQuery += "			D2_FILIAL = '" + xFilial("SD2") + "' AND " + CRLF
	cQuery += "			(B1_UM = 'KG' OR B1_SEGUM = 'KG') AND " + CRLF
	cQuery += "          B1_ZZSUBGR <> ' ' AND" + CRLF
	cQuery += "			F2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND " + CRLF
	cQuery += "			D2_TIPO = 'N' AND" + CRLF //ADICIONADO POR JONI
	cQuery += "			SD2.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "		GROUP BY" + CRLF
	cQuery += "			BM_GRUPO, BM_DESC, B1_ZZSUBGR, B1_ZZDESCS, B1_UM" + CRLF
	cQuery += "		) AS SUBQRY" + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "	SUBQRY.BM_GRUPO IN ('" + cGrpRestr + "')" + CRLF
	cQuery += "GROUP BY" + CRLF
	cQuery += "	SUBQRY.BM_GRUPO," + CRLF
	cQuery += "	SUBQRY.BM_DESC," + CRLF
	cQuery += "	SUBQRY.B1_ZZSUBGR," + CRLF
	cQuery += "	SUBQRY.B1_ZZDESCS" + CRLF
	cQuery += "ORDER BY " + CRLF
	cQuery += "	SUBQRY.BM_GRUPO, SUBQRY.B1_ZZSUBGR" + CRLF
	
	TcQuery cQuery New Alias &cAlias
	
	Count to nTotalReg
	(cAlias)->(DbGoTop())
	
	If (cAlias)->(!Eof())
		
		cGrupo 		:= (cAlias)->BM_GRUPO
		cDescGrupo		:= (cAlias)->BM_DESC
		
		While (cAlias)->(!Eof())
			//Quebra por grupo
			If cGrupo <> (cAlias)->BM_GRUPO
				Aadd(aLinTmp,cGrupo)
				Aadd(aLinTmp,cGrupo)
				Aadd(aLinTmp,cDescGrupo)
				Aadd(aLinTmp,nValGrupo)
				Aadd(aLinTmp,nPesoGrupo)
				Aadd(aLinTmp,nValGrupo / nPesoGrupo)
				
				//Adiciona a Linha na planilha
				oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
				cGrupo 		:= (cAlias)->BM_GRUPO
				cDescGrupo		:= (cAlias)->BM_DESC
				
				//Zera as variáveis
				aLinTmp := {}
				nValGrupo := nPesoGrupo := 0
			EndIf
				
			nPeso 			:= (cAlias)->D2_QUANT
			nPrecoMedio	:= (cAlias)->D2_TOTAL / nPeso
			
			Aadd(aLinTmp, (cAlias)->BM_GRUPO)
			Aadd(aLinTmp, (cAlias)->B1_ZZSUBGR)
			Aadd(aLinTmp, (cAlias)->B1_ZZDESCS)
			Aadd(aLinTmp, (cAlias)->D2_TOTAL)
			Aadd(aLinTmp, nPeso)
			Aadd(aLinTmp, nPrecoMedio)
			
			//Adiciona a Linha na planilha
			oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
			
			//Totalizadores por grupo
			nValGrupo 		+= (cAlias)->D2_TOTAL
			nPesoGrupo		+= nPeso
			
			//Totalizadores finais
			nTOTValor		+= (cAlias)->D2_TOTAL
			nTOTPeso		+= nPeso
			
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
	Aadd(aLinTmp, cGrupo)
	Aadd(aLinTmp, cGrupo)
	Aadd(aLinTmp, cDescGrupo)
	Aadd(aLinTmp, nValGrupo)
	Aadd(aLinTmp, nPesoGrupo)
	Aadd(aLinTmp, nValGrupo / nPesoGrupo)
	oExcel:AddRow(cWorkSheet,cTable,aLinTmp)
	aLinTmp := {}
	
	//Totalizador Final
	Aadd(aLinTmp, "")
	Aadd(aLinTmp, "")
	Aadd(aLinTmp, "")
	Aadd(aLinTmp, nTOTValor)
	Aadd(aLinTmp, nTOTPeso)
	Aadd(aLinTmp, nTOTValor / nTOTPeso)
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
