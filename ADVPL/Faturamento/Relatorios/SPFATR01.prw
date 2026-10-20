#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc}	SPFATR01
Relatório de Faturamento por Representante

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					04/09/2015
@return				nil
/*/
User Function SPFATR01()
	
	Local cPerg			:= "FATURAMENTO REPRESENTANTE"
	Local aParBox			:= {}
	
	Private oReport		:= nil
	Private oSection01	:= nil
	Private oSection02	:= nil
	Private oSection03	:= nil
	Private oSection04	:= nil

	Aadd(aParBox,{1,"Vendedor De"			,Space(TamSX3("A3_COD")[1]),	"",	"",	"SA3",	"",TamSX3("A3_COD")[1], .f.})// MV_PAR01
	Aadd(aParBox,{1,"Vendedor Ate"			,Space(TamSX3("A3_COD")[1]),	"",	"",	"SA3",	"",TamSX3("A3_COD")[1], .f.})// MV_PAR02
	Aadd(aParBox,{1,"Data Emissão De"	,STOD(""),	"",	"",,".T.",50, .f.})// MV_PAR03
	Aadd(aParBox,{1,"Data Emissão Ate"	,STOD(""),	"",	"",,".T.",50, .f.})// MV_PAR04	
	Aadd(aParBox,{2,"TES qto faturamento"	,"1",{"1=GERA FINANCEIRO","2=NÃO GERA","3=AMBAS"},80,,.T.})// MV_PAR01
	Aadd(aParBox,{2,"TES qto estoque"		,"3",{"1=MOVIMENTA","2=NÃO MOVIMENTA","3=AMBAS"},80,,.T.})// MV_PAR01
	
	If ParamBox(aParBox,"FATURAMENTO REPRESENTANTE",,,,,,,,cPerg,.T.,.T.)
		oReport	:= MontEstr()
		oReport:PrintDialog()
	EndIf
	
Return

Static Function MontEstr()
	
	Local cReport			:= "FATURAMENTO REPRESENTANTE"
	Local cTitulo			:= "Faturamento Representante"
	
	//Nome Relatorio ; Titulo ; Parametros ; Code-block executado ao confirmar
	oReport := TReport():New( cReport , cTitulo , {||}, {|oReport| BuscaDad(oReport)} )
	
	//Impressão em Retrato
	oReport:SetLandscape()

	//Define Seção do Cabeçalho
	oSection01 := TRSection():New(oReport,"CABEC")
	oSection02 := TRSection():New(oReport,"Faturamento")
	oSection03 := TRSection():New(oReport,"Devolução")
	oSection04 := TRSection():New(oReport,"Comissão")
	
	oSection04:SetLineStyle()
	
	// Células do Cabeçalho
	TRCell():New(oSection01,"C_COD_VEND"				,"","Representante"						,PesqPict("CT1","CT1_DESC01")	,TamSX3("CT1_DESC01")[1])
	TRCell():New(oSection01,"C_NOME_VEND"				,"","Nome Representante"				,PesqPict("CT1","CT1_DESC01")	,TamSX3("CT1_DESC01")[1])
	TRCell():New(oSection01,"N_COMISSAO"				,"","% Comissão"						,PesqPict("CT1","CT1_DESC01")	,TamSX3("CT1_DESC01")[1],.f.,,"LEFT",,"LEFT")
	
	// Células dos Detalhes Faturamento
	TRCell():New(oSection02,"C_TIPO"					,"","Tipo"								,""								,10)
	TRCell():New(oSection02,"C_FILIAL"					,"","Filial"							,PesqPict("SD2","D2_FILIAL")	,TamSX3("D2_FILIAL")[1])
	TRCell():New(oSection02,"D_DATAEMISSAO"				,"","Data de Emissão"					,PesqPict("SD2","D2_EMISSAO")	,TamSX3("D2_EMISSAO")[1])
	TRCell():New(oSection02,"C_NOTA"					,"","Nota Fiscal"						,PesqPict("SD2","D2_DOC")		,TamSX3("D2_DOC")[1])
	TRCell():New(oSection02,"C_SERIE"					,"","Serie"								,PesqPict("SD2","D2_SERIE")		,TamSX3("D2_SERIE")[1])
	TRCell():New(oSection02,"C_PEDIDO"					,"","Pedido"							,PesqPict("SD2","D2_PEDIDO")	,TamSX3("D2_PEDIDO")[1])
	TRCell():New(oSection02,"C_CLIENTE"					,"","Cod.Cliente"						,PesqPict("SA1","A1_COD")		,TamSX3("A1_COD")[1])
	TRCell():New(oSection02,"C_LOJA"					,"","Loja.Cliente"						,PesqPict("SA1","A1_LOJA")		,TamSX3("A1_LOJA")[1])
	TRCell():New(oSection02,"C_NOMECLI"					,"","Nome Cliente"						,PesqPict("SA1","A1_NOME")		,TamSX3("A1_NOME")[1])
	TRCell():New(oSection02,"V_VALOR_MERCADORIA"		,"","Vlr Fat. Mercadoria "				,PesqPict("SD2","D2_TOTAL")		,TamSX3("D2_TOTAL")[1])
	TRCell():New(oSection02,"V_COMISSAO"				,"","Vlr Fat. Comissão   "				,PesqPict("SD2","D2_TOTAL")		,TamSX3("D2_TOTAL")[1])
	
	// Células dos Detalhes Devolução
	TRCell():New(oSection03,"C_TIPO"					,"","Tipo"								,""								,10)
	TRCell():New(oSection03,"C_FILIAL"					,"","Filial"							,PesqPict("SD1","D1_FILIAL")	,TamSX3("D1_FILIAL")[1])
	TRCell():New(oSection03,"D_DATAEMISSAO"				,"","Data de Emissão"					,PesqPict("SD1","D1_DTDIGIT")	,TamSX3("D1_DTDIGIT")[1])
	TRCell():New(oSection03,"C_NOTA"					,"","Nota Fiscal"						,PesqPict("SD1","D1_DOC")		,TamSX3("D1_DOC")[1])
	TRCell():New(oSection03,"C_SERIE"					,"","Serie"								,PesqPict("SD1","D1_SERIE")		,TamSX3("D1_SERIE")[1])
	TRCell():New(oSection03,"C_PEDIDO"					,"","Pedido"							,PesqPict("SD2","D2_PEDIDO")	,TamSX3("D2_PEDIDO")[1])
	TRCell():New(oSection03,"C_CLIENTE"					,"","Cod.Cliente"						,PesqPict("SA1","A1_COD")		,TamSX3("A1_COD")[1])
	TRCell():New(oSection03,"C_LOJA"					,"","Loja.Cliente"						,PesqPict("SA1","A1_LOJA")		,TamSX3("A1_LOJA")[1])
	TRCell():New(oSection03,"C_NOMECLI"					,"","Nome Cliente"						,PesqPict("SA1","A1_NOME")		,TamSX3("A1_NOME")[1])
	TRCell():New(oSection03,"V_VALOR_MERCADORIA"		,"","Vlr Dev. Devolução  "				,PesqPict("SD1","D1_TOTAL")		,TamSX3("D1_TOTAL")[1])
	TRCell():New(oSection03,"V_COMISSAO"				,"","Vlr Dev. Comissão   "				,PesqPict("SD1","D1_TOTAL")		,TamSX3("D1_TOTAL")[1])
	
	// Células dos Totais Comissão
	TRCell():New(oSection04,"V_VALOR_MERCADORIA"		,"","Vlr Liq. Faturamento"				,PesqPict("SD1","D1_TOTAL")		,TamSX3("D1_TOTAL")[1])
	TRCell():New(oSection04,"V_COMISSAO"				,"","Vlr Liq. Comissão   "				,PesqPict("SD1","D1_TOTAL")		,TamSX3("D1_TOTAL")[1])
	
	oSection04:Cell("V_VALOR_MERCADORIA"):SetCellBreak()
	oSection04:Cell("V_COMISSAO"):SetCellBreak()

	TRFunction():New(oSection02:Cell("V_VALOR_MERCADORIA")	,,"SUM")
	TRFunction():New(oSection02:Cell("V_COMISSAO")			,,"SUM")
	
	TRFunction():New(oSection03:Cell("V_VALOR_MERCADORIA")	,,"SUM")
	TRFunction():New(oSection03:Cell("V_COMISSAO")			,,"SUM")

	TRFunction():New(oSection04:Cell("V_VALOR_MERCADORIA")	,,"SUM",,,,,.f.,.t.)
	TRFunction():New(oSection04:Cell("V_COMISSAO")			,,"SUM",,,,,.f.,.t.)
Return oReport

Static Function BuscaDad(oReport)
	
	Local cQuery		:= ""
	Local cVend			:= ""
	Local cAlias		:= GetNextAlias()
	Local nQtdReg		:= 0
	Local nCont			:= 1
	Local nVlrMerc      := 0
	Local nComis        := 0
	
	cQuery += "SELECT * FROM (" + CRLF
	
	cQuery += "SELECT" + CRLF
	cQuery += "	'1' AS N_TIPO," + CRLF	
	cQuery += "	'FAT' AS C_TIPO," + CRLF
	cQuery += "	A3_COD AS C_COD_VEND," + CRLF
	cQuery += "	A3_NOME AS C_NOME_VEND," + CRLF
	cQuery += "	A3_COMIS AS N_COMISSAO," + CRLF
	cQuery += "	D2_FILIAL AS C_FILIAL," + CRLF
	cQuery += "	D2_EMISSAO AS D_DATAEMISSAO," + CRLF
	cQuery += "	D2_DOC AS C_NOTA," + CRLF
	cQuery += "	D2_SERIE AS C_SERIE," + CRLF
	cQuery += "	D2_PEDIDO AS C_PEDIDO," + CRLF
	cQuery += "	D2_CLIENTE AS C_CLIENTE," + CRLF
	cQuery += "	D2_LOJA AS C_LOJA," + CRLF
	cQuery += "	A1_NOME AS C_NOMECLI," + CRLF
	cQuery += "	SUM(D2_TOTAL) AS V_VALOR_MERCADORIA," + CRLF
	cQuery += "	(SUM(D2_TOTAL) * (A3_COMIS / 100)) AS V_COMISSAO" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + RetSqlName("SD2") + " AS SD2" + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlName("SF2") + " AS SF2" + CRLF
	cQuery += "ON" + CRLF
	cQuery += "	F2_FILIAL = D2_FILIAL AND" + CRLF
	cQuery += "	F2_DOC = D2_DOC  AND" + CRLF
	cQuery += "	F2_SERIE = D2_SERIE AND" + CRLF
	cQuery += "	F2_CLIENTE = D2_CLIENTE AND" + CRLF
	cQuery += "	F2_LOJA = D2_LOJA AND" + CRLF
	cQuery += "	SF2.D_E_L_E_T_ = ' '" + CRLF	
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlName("SA1") + " AS SA1" + CRLF
	cQuery += "ON" + CRLF
	cQuery += "	A1_FILIAL = '" + xFilial("SA1") + "' AND" + CRLF
	cQuery += "	A1_COD = D2_CLIENTE AND" + CRLF
	cQuery += "	A1_LOJA = D2_LOJA AND" + CRLF
	cQuery += "	SA1.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlName("SA3") + " AS SA3" + CRLF
	cQuery += "ON" + CRLF
	cQuery += "	A3_FILIAL = '" + xFilial("SA3") + "' AND" + CRLF
	cQuery += "	A3_COD = F2_VEND1 AND" + CRLF
	cQuery += "	SA3.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlName("SF4") + " AS SF4" + CRLF
	cQuery += "ON" + CRLF
	cQuery += "	F4_FILIAL = D2_FILIAL AND" + CRLF
	cQuery += "	F4_CODIGO = D2_TES AND" + CRLF
	
	if MV_PAR05 == '1'
		cQuery += "	F4_DUPLIC = 'S' AND" + CRLF
	elseif MV_PAR05 == '2'
		cQuery += "	F4_DUPLIC = 'N' AND" + CRLF
	endif

	if MV_PAR06 == '1'
		cQuery += "	F4_ESTOQUE = 'S' AND" + CRLF
	elseif MV_PAR06 == '2'
		cQuery += "	F4_ESTOQUE = 'N' AND" + CRLF
	endif

	cQuery += "	SF4.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "WHERE" + CRLF
	cQuery += "	D2_TIPO NOT IN ('D','B') AND" + CRLF
	cQuery += "	A3_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND" + CRLF
	cQuery += "	D2_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' AND" + CRLF
	cQuery += "	SD2.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "GROUP BY" + CRLF
	cQuery += "	A3_COD, A3_NOME, A3_COMIS, D2_FILIAL, D2_EMISSAO, D2_DOC, D2_SERIE, D2_PEDIDO, D2_CLIENTE, D2_LOJA, A1_NOME" + CRLF
	
	cQuery += "" + CRLF
	cQuery += " UNION ALL " + CRLF
	cQuery += "" + CRLF
	
	cQuery += "SELECT" + CRLF
	cQuery += "	'2' AS N_TIPO," + CRLF
	cQuery += "	'DEV' AS C_TIPO," + CRLF
	cQuery += "	A3_COD AS C_COD_VEND," + CRLF
	cQuery += "	A3_NOME AS C_NOME_VEND," + CRLF
	cQuery += "	A3_COMIS AS N_COMISSAO," + CRLF
	cQuery += "	D1_FILIAL AS C_FILIAL," + CRLF
	cQuery += "	D1_DTDIGIT AS D_DATAEMISSAO," + CRLF
	cQuery += "	D1_DOC AS C_NOTA," + CRLF
	cQuery += "	D1_SERIE AS C_SERIE," + CRLF
	cQuery += "	D2_PEDIDO AS C_PEDIDO," + CRLF
	cQuery += "	D1_FORNECE AS C_CLIENTE," + CRLF
	cQuery += "	D1_LOJA AS C_LOJA," + CRLF
	cQuery += "	A1_NOME AS C_NOMECLI," + CRLF
	cQuery += "	(SUM(D1_TOTAL-D1_VALDESC) * -1) AS V_VALOR_MERCADORIA," + CRLF
	cQuery += "	((SUM(D1_TOTAL-D1_VALDESC) * (A3_COMIS / 100)) * -1) AS V_COMISSAO" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + RetSqlName("SD1") + " AS SD1" + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlName("SA1") + " AS SA1" + CRLF
	cQuery += "ON" + CRLF
	cQuery += "	A1_COD = D1_FORNECE AND" + CRLF
	cQuery += "	A1_LOJA = D1_LOJA AND" + CRLF
	cQuery += "	SA1.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlName("SD2") + " AS SD2" + CRLF
	cQuery += "ON" + CRLF
	cQuery += "	D2_DOC = D1_NFORI AND" + CRLF
	cQuery += "	D2_SERIE = D1_SERIORI AND" + CRLF
	cQuery += "	D2_ITEM = D1_ITEMORI AND" + CRLF
	cQuery += "	SD2.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlName("SF2") + " AS SF2" + CRLF
	cQuery += "ON" + CRLF
	cQuery += "	F2_FILIAL = D2_FILIAL AND" + CRLF
	cQuery += "	F2_DOC = D2_DOC  AND" + CRLF
	cQuery += "	F2_SERIE = D2_SERIE AND" + CRLF
	cQuery += "	F2_CLIENTE = D2_CLIENTE AND" + CRLF
	cQuery += "	F2_LOJA = D2_LOJA AND" + CRLF
	cQuery += "	SF2.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlName("SA3") + " AS SA3" + CRLF
	cQuery += "ON" + CRLF
	cQuery += "	A3_COD = F2_VEND1 AND" + CRLF
	cQuery += "	SA3.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlName("SF4") + " AS SF4" + CRLF
	cQuery += "ON" + CRLF
	cQuery += "	F4_FILIAL = D1_FILIAL AND" + CRLF
	cQuery += "	F4_CODIGO = D1_TES AND" + CRLF

	if MV_PAR05 == '1'
		cQuery += "	F4_DUPLIC = 'S' AND" + CRLF
	elseif MV_PAR05 == '2'
		cQuery += "	F4_DUPLIC = 'N' AND" + CRLF
	endif

	if MV_PAR06 == '1'
		cQuery += "	F4_ESTOQUE = 'S' AND" + CRLF
	elseif MV_PAR06 == '2'
		cQuery += "	F4_ESTOQUE = 'N' AND" + CRLF
	endif

	cQuery += "	SF4.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "WHERE" + CRLF
	cQuery += "	D1_TIPO = 'D' AND" + CRLF
	cQuery += "	A3_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND" + CRLF
	cQuery += "	D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' AND" + CRLF	
	cQuery += "	SD1.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "GROUP BY" + CRLF
	cQuery += "	A3_COD, A3_NOME, A3_COMIS, D1_FILIAL, D1_DTDIGIT, D1_DOC, D1_SERIE, D2_PEDIDO, D1_FORNECE, D1_LOJA, A1_NOME" + CRLF
	
	cQuery += ") AS QUERY ORDER BY C_COD_VEND, N_TIPO, C_NOME_VEND, C_FILIAL, D_DATAEMISSAO, C_NOTA, C_SERIE, C_PEDIDO, C_CLIENTE, C_LOJA " + CRLF
		           	
	TcQuery cQuery New Alias &cAlias
	
	TCSetField(cAlias,"V_VALOR_MERCADORIA" ,"N", GetSx3Cache("D2_TOTAL", "X3_TAMANHO"), GetSx3Cache("D2_TOTAL", "X3_DECIMAL"))
	TCSetField(cAlias,"V_COMISSAO"		   ,"N", GetSx3Cache("D2_TOTAL", "X3_TAMANHO"), GetSx3Cache("D2_TOTAL", "X3_DECIMAL"))
	
	Count to nQtdReg
	oReport:SetMeter(nQtdReg)
	(cAlias)->(DbGoTop())
	
	If (cAlias)->(!Eof())
		While (cAlias)->(!Eof())
			oReport:IncMeter()
			
			If cVend <> (cAlias)->C_COD_VEND
				If nCont > 1
					oSection02:Finish()
					oSection03:Finish()

					oReport:SkipLine()
					oReport:PrintText("Totais Comissão")
					oReport:ThinLine()
					
					oSection04:Cell("V_VALOR_MERCADORIA"):SetValue(nVlrMerc)
					oSection04:Cell("V_COMISSAO"):SetValue(nComis)
					oSection04:PrintLine()
					
					oSection04:Finish()
					oSection01:Finish()
				EndIf

				oReport:IncRow(150)
				
				oSection01:Init()
				oSection02:Init()
				oSection03:Init()
				oSection04:Init()
				oSection01:Cell("C_COD_VEND"):SetValue((cAlias)->C_COD_VEND)
				oSection01:Cell("C_NOME_VEND"):SetValue((cAlias)->C_NOME_VEND)
				oSection01:Cell("N_COMISSAO"):SetValue((cAlias)->N_COMISSAO)
				oSection01:PrintLine()
				
				cVend    := (cAlias)->C_COD_VEND
				nVlrMerc := 0
				nComis   := 0
			EndIf
			
			If (cAlias)->C_TIPO == "FAT"
				oSection02:Cell("C_TIPO"):SetValue((cAlias)->C_TIPO)
				oSection02:Cell("C_FILIAL"):SetValue((cAlias)->C_FILIAL)
				oSection02:Cell("D_DATAEMISSAO"):SetValue(STOD((cAlias)->D_DATAEMISSAO))
				oSection02:Cell("C_NOTA"):SetValue((cAlias)->C_NOTA)
				oSection02:Cell("C_SERIE"):SetValue((cAlias)->C_SERIE)
				oSection02:Cell("C_PEDIDO"):SetValue((cAlias)->C_PEDIDO)
				oSection02:Cell("C_CLIENTE"):SetValue((cAlias)->C_CLIENTE)
				oSection02:Cell("C_LOJA"):SetValue((cAlias)->C_LOJA)
				oSection02:Cell("C_NOMECLI"):SetValue((cAlias)->C_NOMECLI)
				oSection02:Cell("V_VALOR_MERCADORIA"):SetValue((cAlias)->V_VALOR_MERCADORIA)
				oSection02:Cell("V_COMISSAO"):SetValue((cAlias)->V_COMISSAO)
				oSection02:PrintLine()
			ElseIf (cAlias)->C_TIPO == "DEV"
				oSection03:Cell("C_TIPO"):SetValue((cAlias)->C_TIPO)
				oSection03:Cell("C_FILIAL"):SetValue((cAlias)->C_FILIAL)
				oSection03:Cell("D_DATAEMISSAO"):SetValue(STOD((cAlias)->D_DATAEMISSAO))
				oSection03:Cell("C_NOTA"):SetValue((cAlias)->C_NOTA)
				oSection03:Cell("C_SERIE"):SetValue((cAlias)->C_SERIE)
				oSection03:Cell("C_PEDIDO"):SetValue((cAlias)->C_PEDIDO)
				oSection03:Cell("C_CLIENTE"):SetValue((cAlias)->C_CLIENTE)
				oSection03:Cell("C_LOJA"):SetValue((cAlias)->C_LOJA)
				oSection03:Cell("C_NOMECLI"):SetValue((cAlias)->C_NOMECLI)
				oSection03:Cell("V_VALOR_MERCADORIA"):SetValue((cAlias)->V_VALOR_MERCADORIA)
				oSection03:Cell("V_COMISSAO"):SetValue((cAlias)->V_COMISSAO)
				oSection03:PrintLine()
			EndIf
				
			nVlrMerc += (cAlias)->V_VALOR_MERCADORIA
			nComis   += (cAlias)->V_COMISSAO
			
			If oReport:nDevice == 4 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
				oSection01:lHeaderSection := .F.
				oSection02:lHeaderSection := .F.
				oSection03:lHeaderSection := .F.
				oSection04:lHeaderSection := .F.
			EndIf
			
			nCont++
			(cAlias)->(DbSkip())
		EndDo

		oSection02:Finish()
		oSection03:Finish()

		oReport:SkipLine()
		oReport:PrintText("Totais Comissão")
		oReport:ThinLine()

		oSection04:Cell("V_VALOR_MERCADORIA"):SetValue(nVlrMerc)
		oSection04:Cell("V_COMISSAO"):SetValue(nComis)
		oSection04:PrintLine()
					
		oSection04:Finish()
		oSection01:Finish()
	EndIf
	
	(cAlias)->(DbCloseArea())
	
Return
