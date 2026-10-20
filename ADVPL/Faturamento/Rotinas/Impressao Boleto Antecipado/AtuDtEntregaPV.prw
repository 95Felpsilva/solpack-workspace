#include 'totvs.ch'
#include 'FWMVCDEF.ch'
#include 'TOPCONN.ch'
/*/{Protheus.doc} AtuDtEntregaPV
Atualiza data de entrega do Pedido de Vendas
@type function
@version 12.1.33
@author Tiago Faria
@since 06/12/2021
/*/
user function AtuDtEntregaPV()
	private cIDModel          := "PE_AtuDtEntregaPV"
	private cIDGrid           := "MODEL_GRID"
	private cIDView           := "VIEW_GRID"
	private cIDProgram        := "GRIDMVC"
	private cGrupo            := ""
	private cSubGrupo         := ""
	private nPrazoEntrega     := 0
	private nNovoPrazoEntrega := 0

	if ask()

		oGrid := GridMVCSQL():New(/*cID*/cIDModel,cIDProgram/*cIDProgram*/,cIDGrid/*cIdModel*/,cIDView/*cIDView*/)
		oGrid:setMarkField("MARK")

		oGrid:addTypeField("C6_ENTREG","D",8,0)
		oGrid:addTypeField("C5_EMISSAO","D",8,0)

		oGrid:setQuery(getQuery())
		oGrid:setShowMarkAll(.t.)
		oGrid:setModelDef({|oModel| modifyModel(oModel)})
		oGrid:setViewDef({|oView| modifyView(oView)})

		oGrid:activate(/*nOperation*/,/*aEnableButtons*/,/*nPercReducao*/,"Atualiza Dt Entrega PV"/*cTitle*/,/*bCloseOnOK*/,/*bOk*/,/*bCancel*/)
	endif

return

static function modifyModel(oModel)
	oModel:SetCommit({|oModel| myCommit(oModel)})
return oModel

static function modifyView(oView)
	local aView      := oView:GetViewObj(cIDView)
	local oGrid      := aView[3]
	local oStruct    := oGrid:getStruct()
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty("*", "GRIDSEEK",{.t.})

	oStruct:setProperty( '*'	    	,MVC_VIEW_CANCHANGE,.F.)
	oStruct:setProperty( 'MARK'	    	,MVC_VIEW_CANCHANGE,.T.)

	oStruct:RemoveField("C6RECNO")
	oStruct:RemoveField("B1RECNO")

	oView:addUserButton("Exportar Excel", "MAGIC_BMP"/*<cResource >*/, {|oView| FwMsgRun( ,{ || exportExcel() }, "SOLPACK", "Exportando Dados para o Excel..." )}/*<bBloco >*/, ""/*[ cToolTip ]*/, /*nShortCut*/, /*[ aOptions ]*/, .t./*[lShowBar]*/)

return oView

static function myCommit(oModel)

	local lRet     := .t.

	FWMsgRun( ,{||lRet := updDados(oModel)},"ATUDTENTREGAPV", "Aguarde gravando os dados..."  )
return lRet

static function updDados(oModel)
	local lRet      := .t.
	local oGrid     := oModel:getModel(cIDGrid)
	local nLine     := 0
	local aArea     := Lj7GetArea({"SC5", "SC6", "SB1", "SC9"})
	local nRecnoB1  := 0
	local cAliasC9  := ""
	local cProdutos := ""
	local cQuery    := ""
	local cAlias    := ""

	BEGIN TRANSACTION
		for nLine := 1 to oGrid:length()
			oGrid:goLine(nLine)

			if oGrid:isDeleted() .or. !oGrid:getValue("MARK")
				loop
			endif

			nRecnoB1 := oGrid:getValue("B1RECNO")

			if nRecnoB1 <> SB1->(recno())
				SB1->(dbGoTo(nRecnoB1))
				recLock("SB1",.f.)
				SB1->B1_ZZPE := nNovoPrazoEntrega
				SB1->(msUnlock())
			endif

			cProdutos += SB1->B1_COD + ","

			if oGrid:getValue("C6RECNO") > 0
				SC6->(dbGoTo(oGrid:getValue("C6RECNO")))
				recLock("SC6",.f.)
				SC6->C6_ENTREG := oGrid:getValue("C5_EMISSAO") + nNovoPrazoEntrega
				SC6->(msUnlock())

				cAliasC9 := getSC9()

				while (cAliasC9)->(!Eof())
					SC9->(dbGoTo((cAliasC9)->(C9RECNO)))
					if SC9->(!Eof())
						recLock("SC9",.f.)
						SC9->C9_DATENT := oGrid:getValue("C5_EMISSAO") + nNovoPrazoEntrega
						SC9->(msUnlock())
					endif
					(cAliasC9)->(dbSkip())
				enddo
				(cAliasC9)->(dbCloseArea())
			endif
		next nLine
	END TRANSACTION

	cQuery := getQryPV(cProdutos)

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	if (cAlias)->(!Eof())
		oSql := SQL():new()
		oSql:setQuery(cQuery)
		MsgRun('Gerando EXCEL','Aguarde...',	{||oSQL:showExcel("Pedidos não atualizado data de entrega")})
		oSql:destroy()
		msgInfo("Excel com a lista de pedidos gerado com sucesso!")
	endif

	(cAlias)->(dbCloseArea())

	Lj7RestArea(aArea)
return lRet

static function getSC9()
	local cAlias := ''
	local cQuery := ''

	cQuery += "SELECT" + CRLF
	cQuery += "	SC9.R_E_C_N_O_ AS C9RECNO" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + RetSqlTab('SC9') + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + RetSqlFil('SC9') + CRLF
	cQuery += "	AND C9_PEDIDO = '" + SC6->C6_NUM + "'" + CRLF
	cQuery += "	AND C9_ITEM = '" + SC6->C6_ITEM + "'" + CRLF
	cQuery += "	AND C9_NFISCAL = ' '" + CRLF
	cQuery += "	AND " + RetSqlDel('SC9') + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())
return cAlias

static function ask()
	local lRet          := .f.
	local oParam        := nil
	local oParamBox     := IpParamBoxObject():newIpParamBoxObject("ATUDTENTREGAPV")

	oParamBox:setTitle("Atualiza Dt Entrega PV")
	oParamBox:setUserSave(.f.)
	oParamBox:setCanSave(.f.)

	oParam := IpParamObject():newIpParamObject("GRUPO", "get", "Grupo", "C", 60,getSX3Cache("B1_GRUPO","X3_TAMANHO"))
	oParam:setPicture("@!")
	oParam:setRequired(.T.)
	oParam:setValidation("Vazio() .or. ExistCpo('SBM')")
	oParam:setF3("SBM")
	oParamBox:addParam(oParam)

	oParam := IpParamObject():newIpParamObject("SUBGRUPO", "get", "Sub-Grupo", "C", 60,getSX3Cache("B1_ZZSUBGR","X3_TAMANHO"))
	oParam:setPicture("@!")
	oParam:setRequired(.T.)
	oParam:setValidation("Vazio() .or. ExistCpo('ZB7',MV_PAR02+MV_PAR01,1)")
	//oParam:setF3("ZB7")
	oParamBox:addParam(oParam)


	oParam := IpParamObject():newIpParamObject("PRAZOENTREGA", "get", "Prazo de Entrega Atual", "N", 60,getSX3Cache("B1_ZZGRUPO","X3_TAMANHO"))
	oParam:setPicture(getSX3Cache("B1_ZZPE","X3_PICTURE"))
	oParam:setValidation("Positivo()")
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)

	oParam := IpParamObject():newIpParamObject("NOVOPRAZOENTREGA", "get", "Novo Prazo de Entrega", "N", 60,getSX3Cache("B1_ZZGRUPO","X3_TAMANHO"))
	oParam:setPicture(getSX3Cache("B1_ZZPE","X3_PICTURE"))
	oParam:setValidation("Positivo()")
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)

	if oParamBox:show()
		lRet             := .t.
		cGrupo            := alltrim(oParamBox:getValue("GRUPO"))
		cSubGrupo         := alltrim(oParamBox:getValue("SUBGRUPO"))
		nPrazoEntrega     := oParamBox:getValue("PRAZOENTREGA")
		nNovoPrazoEntrega := oParamBox:getValue("NOVOPRAZOENTREGA")
	endif

return lRet

static function getQuery()
	local cQuery := ""

	cQuery += "SELECT" + CRLF
	cQuery += "	'T' AS MARK," + CRLF
	cQuery += "	C6_NUM + '-' + C6_ITEM AS PEDIDO," + CRLF
	cQuery += "	RTRIM(B1_COD) +'-'+ B1_DESC AS PRODUTO," + CRLF
	cQuery += "	C5_EMISSAO," + CRLF
	cQuery += "	C6_ENTREG," + CRLF
	cQuery += "	DATEDIFF(DAY, CAST(C5_EMISSAO AS DATETIME), CAST(C6_ENTREG AS DATETIME)) AS DIAS_ENTREGA_EMISSAO," + CRLF
	cQuery += "	" + u_regraSituacao()
	cQuery += "	C5_CLIENTE+'-'+C5_LOJACLI+'-'+A1_NOME AS CLIENTE," + CRLF
	cQuery += "	SB1.R_E_C_N_O_ AS B1RECNO," + CRLF
	cQuery += "	C6RECNO," + CRLF
	cQuery += "	CAST(C5_EMISSAO AS DATETIME) + " + cValToChar(nNovoPrazoEntrega) + " AS NOVA_DATA_ENTREGA," + CRLF
	cQuery += "	" + cValToChar(nNovoPrazoEntrega) +  " AS NOVO_PRAZO_ENTREGA" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SB1") + CRLF

	cQuery += "OUTER APPLY" + CRLF
	cQuery += "(" + CRLF
	cQuery += getQryPV()
	cQuery += ") AS PV" + CRLF

	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SB1") + CRLF
	cQuery += "	AND B1_GRUPO = '" + cGrupo + "'" + CRLF
	cQuery += "	AND B1_ZZSUBGR = '" + cSubGrupo + "'" + CRLF
	cQuery += "	AND B1_ZZPE = " + cValToChar(nPrazoEntrega) + CRLF
	cQuery += "	AND " + retSqlDel("SB1") + CRLF
	cQuery += "	ORDER BY B1_COD,C6_NUM,C6_ITEM " + CRLF

	memoWrite("\sql\AtuDtEntregaPV.sql",cQuery)
return cQuery

static function getQryPV(cProdutos)
	local cQuery := ""
	default cProdutos := ""

	cQuery += "SELECT" + CRLF
	cQuery += "	C6_NUM," + CRLF
	cQuery += "	C6_ITEM," + CRLF
	cQuery += "	C5_EMISSAO," + CRLF
	cQuery += "	C6_ENTREG," + CRLF
	cQuery += "	C9_BLEST," + CRLF
	cQuery += "	C9_BLCRED," + CRLF
	cQuery += "	QTDLIB," + CRLF
	cQuery += "	C5_CLIENTE," + CRLF
	cQuery += "	C5_LOJACLI," + CRLF
	cQuery += "	A1_NOME," + CRLF
	cQuery += "	SC6.R_E_C_N_O_ AS C6RECNO" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SC6") + CRLF

	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("SC5") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SC5") + CRLF
	cQuery += "	AND C5_NUM = C6_NUM" + CRLF
	cQuery += "	AND C5_ZZLEGBA IN ('1','2','')" + CRLF
	cQuery += "	AND DATEDIFF(DAY, CAST(C5_EMISSAO AS DATETIME), CAST(C6_ENTREG AS DATETIME)) = " + cValToChar(nPrazoEntrega) + CRLF
	cQuery += "	AND " + retSqlDel("SC5") + CRLF

	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("SA1") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SA1") + CRLF
	cQuery += "	AND A1_COD = C5_CLIENTE" + CRLF
	cQuery += "	AND A1_LOJA = C5_LOJACLI" + CRLF
	cQuery += "	AND " + retSqlDel("SA1") + CRLF

	cQuery += "LEFT JOIN" + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT" + CRLF
	cQuery += "	C9_FILIAL," + CRLF
	cQuery += "	C9_PEDIDO," + CRLF
	cQuery += "	C9_ITEM," + CRLF
	cQuery += "	SUM(C9_QTDLIB) AS QTDLIB," + CRLF
	cQuery += "	MAX(C9_BLCRED) AS C9_BLCRED," + CRLF
	cQuery += "	MAX(C9_BLEST) AS C9_BLEST" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SC9") + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SC9") + CRLF
	cQuery += "	AND SC9.C9_NFISCAL = ' '" + CRLF
	cQuery += "	AND C9_BLEST = ' '" + CRLF
	cQuery += "	AND C9_BLCRED = ' '" + CRLF
	cQuery += "	AND " + retSqlDel("SC9") + CRLF
	cQuery += "GROUP BY" + CRLF
	cQuery += "	C9_FILIAL," + CRLF
	cQuery += "	C9_PEDIDO," + CRLF
	cQuery += "	C9_ITEM" + CRLF
	cQuery += ") SC9" + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "AND C9_FILIAL = C6_FILIAL" + CRLF
	cQuery += "AND C9_PEDIDO = C6_NUM" + CRLF
	cQuery += "AND C9_ITEM = C6_ITEM" + CRLF

	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SC6") + CRLF
	if !empty(cProdutos)
		cQuery += "	AND C6_PRODUTO IN " + formatIn(cProdutos,",") + CRLF
	else
		cQuery += "	AND C6_PRODUTO = B1_COD" + CRLF
	endif
	cQuery += "	AND C6_QTDVEN - C6_QTDENT > 0" + CRLF
	cQuery += "	AND " + retSqlDel("SC6") + CRLF
return cQuery

static function exportExcel()
	local oView      := FwViewActive()
	local aViewGrid  := oView:GetViewObj("VIEW_GRID")
	local oGrid      := aViewGrid[3]
	local oGridModel := oView:getModel("MODEL_GRID")
	local nLine      := 0
	local oStruct    := oGrid:getStruct()
	local oStructModel := oGridModel:getStruct()
	local nFields    := 0
	local aFields    := oStruct:GetFields()
	local nQtdFields := len(aFields)
	local cId        := ""
	local cTitulo    := ""
	local cTipo      := ""
	local nTamanho   := 0
	local nDecimal   := 0
	local aItem      := {}
	local oExcel     := FWMsExcel():New()
	local cTable	:= "ATU DT ENTREGA PV"
	local cWorkSheet:= cTable
	local aRows      := FwSaveRows()
	oExcel:AddWorkSheet(cWorkSheet)
	oExcel:AddTable(cWorkSheet,cTable)

	for nLine := 1 to oGridModel:length()
		oGridModel:goLine(nLine)

		for nFields := 1 to nQtdFields
			cId      := aFields[nFields][MVC_VIEW_IDFIELD]
			cTitulo  := aFields[nFields][MVC_VIEW_TITULO]
			cTipo    := oStructModel:getProperty(cId,MODEL_FIELD_TIPO)
			nTamanho := oStructModel:getProperty(cId,MODEL_FIELD_TAMANHO)
			nDecimal := oStructModel:getProperty(cId,MODEL_FIELD_DECIMAL)

			if nLine == 1
				oExcel:AddColumn(cWorkSheet,cTable,cTitulo,1/*nAlign*/,1/*nFormat*/,.f./*lTotaliza*/)
			endif

			aAdd(aItem,oGridModel:getValue(cId))
		next nFields

		oExcel:AddRow(cWorkSheet,cTable,aItem)

		aItem := {}
	next nLine
	FwRestRows(aRows)
	FwMsgRun( ,{ || geraPlan(oExcel) }, "SOLPACK", "Exportando Dados para o Excel..." )
return

Static Function geraPlan(oExcel)
	Local cDiretorio	:= ""
	Local cExtensao	:= ".XML"
	Local cTexto		:= ""
	Local cTitle		:= "Planilha Gerada com Sucesso !"
	Local oExcelApp := MSExcel():New()

	cDiretorio := cGetFile("Arquivos (*" + Upper(cExtensao) + ") | *" + Upper(cExtensao) + " |","Selecione o Local de Destino",,,.F., GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE)
	If !Empty(cDiretorio)
		cDiretorio += "atu_dt_entrega_pv_" + fwTimeStamp()
		oExcel:Activate()
		oExcel:GetXMLFile(cDiretorio + cExtensao)

		cTexto += "Planilha gerada em: " + CRLF
		cTexto += cDiretorio + cExtensao

		If File(cDiretorio + cExtensao)
			oExcelApp:WorkBooks:Open(cDiretorio + cExtensao)
			oExcelApp:setVisible(.T.)
			Aviso(cTitle,cTexto,{"OK"},3)
		Else
			Aviso("Erro","Não foi possível gerar a planilha em " + cDiretorio,{"OK"},3)
		EndIf
	EndIf
Return
