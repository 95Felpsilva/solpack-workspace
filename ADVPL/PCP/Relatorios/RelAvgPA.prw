#include 'Totvs.ch'
/*/{Protheus.doc} RelAvgPA
Relatório com a média do PA
@type function
@version  1.0
@author Tiago Faria
@since 23/07/2021
/*/
user function RelAvgPA(lPI,cTitulo)
	local oSql 			:= nil
	private dEmissaoAte := stod("")
	private dEmissaoDe  := stod("")
	private lPA			:= .t.
	default lPI 		:= .f.
	default cTitulo 	:= "Média consumo de bobina"

	lPA := !lPI

	if ask()
		oSql := SQL():new()
		oSql:setQuery(getQuery())
		MsgRun('Gerando EXCEL','Aguarde...',	{||oSQL:showExcel(cTitulo)})
		oSql:destroy()
		msgInfo("Excel gerado com sucsso!")
	endif
return

static function getQuery()
	local cQuery := ""

	cQuery += "SELECT" + CRLF
	cQuery += "	SD3REQ.D3_OP," + CRLF
	cQuery += "	C2_PRODUTO," + CRLF
	cQuery += "	B1_DESC," + CRLF
	cQuery += "	B1_UM," + CRLF
	if lPA
		cQuery += "	B1_PESO," + CRLF
	endif
	cQuery += "	SUM(SD3OP.D3_QUANT) QTD_PRODUZIDO," + CRLF
	cQuery += "	AVG(SD3REQ.D3_QUANT) QTD_" + if(lPA,"BOBINA","MP") + "," + CRLF
	cQuery += "	(AVG(SD3REQ.D3_QUANT)/ SUM(SD3OP.D3_QUANT)) AS PESO_MEDIO_CONSUMIDO" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlName("SD3") + " SD3OP (NOLOCK)" + CRLF
	cQuery += "JOIN " + retSqlName("SC2") + " SC2 (NOLOCK) ON" + CRLF
	cQuery += "	" + retSqlFil("SC2") + CRLF
	cQuery += "	AND C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD = SD3OP.D3_OP" + CRLF
	cQuery += "	AND SC2.D_E_L_E_T_ = ''" + CRLF
	cQuery += "JOIN " + retSqlName("SB1") + " SB1 (NOLOCK) ON" + CRLF
	cQuery += "	" + retSqlFil("SB1") + CRLF
	cQuery += "	AND B1_COD = C2_PRODUTO" + CRLF
	cQuery += "	AND SB1.D_E_L_E_T_ = ''" + CRLF
	cQuery += "JOIN " + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT" + CRLF
	cQuery += "	D3_FILIAL," + CRLF
	cQuery += "	D3_OP," + CRLF
	cQuery += "	SUM(D3_QUANT) AS D3_QUANT" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + retSqlName("SD3") + " (NOLOCK) SD3REQ" + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SD3") + CRLF
	cQuery += "	AND SD3REQ.D3_ESTORNO = ''" + CRLF
	cQuery += "	AND SD3REQ.D3_CF LIKE 'RE%'" + CRLF
	if lPA
		cQuery += "	AND SD3REQ.D3_TIPO = 'PI'" + CRLF
	else
		cQuery += "	AND SD3REQ.D3_COD NOT LIKE 'MOD%'" + CRLF
	endif
	cQuery += "	AND SD3REQ.D3_EMISSAO BETWEEN '" + dTos(dEmissaoDe) + "' AND '" + dTos(dEmissaoAte) + "'" + CRLF
	cQuery += "	AND SD3REQ.D3_QUANT <> 0" + CRLF
	cQuery += "	AND D3_OP <> ' '" + CRLF
	cQuery += "	AND SD3REQ.D_E_L_E_T_ = ''" + CRLF
	cQuery += "GROUP BY" + CRLF
	cQuery += "	D3_FILIAL," + CRLF
	cQuery += "	D3_OP" + CRLF
	cQuery += ")SD3REQ " + CRLF
	cQuery += "ON SD3OP.D3_FILIAL = SD3REQ.D3_FILIAL" + CRLF
	cQuery += "AND SD3OP.D3_OP = SD3REQ.D3_OP" + CRLF
	cQuery += "WHERE" + CRLF
	cQuery += "	1 = 1" + CRLF
	cQuery += "	AND SD3OP.D3_EMISSAO BETWEEN '" + dTos(dEmissaoDe) + "' AND '" + dTos(dEmissaoAte) + "'" + CRLF
	cQuery += "	AND SD3OP.D3_CF LIKE 'PR%'" + CRLF
	if lPA
		cQuery += "	AND SD3OP.D3_TIPO = 'PA'" + CRLF
	else
		cQuery += "	AND SD3OP.D3_TIPO = 'PI'" + CRLF
	endif
	cQuery += "	AND SD3OP.D3_QUANT <> 0" + CRLF
	cQuery += "	AND SD3OP.D3_ESTORNO = ''" + CRLF
	cQuery += "	AND SD3OP.D_E_L_E_T_ = ''" + CRLF
	cQuery += "GROUP BY" + CRLF
	cQuery += "	SD3REQ.D3_OP," + CRLF
	cQuery += "	C2_PRODUTO," + CRLF
	cQuery += "	B1_DESC," + CRLF
	cQuery += "	B1_UM," + CRLF
	cQuery += "	B1_PESO" + CRLF

	memowrite("\sql\RelAVG" + if(lPA,"PA","PI") + ".sql",cQuery)

return cQuery

static function ask(lPerg)
	local lRet 		:= .t.
	local aParamBox := {}
	local nI		:= 0
	default lPerg 	:= .t.

	aadd(aParamBox, {1, "Emissao De" , stod("")                , "", "", ""   , "", 50, .F.})
	aadd(aParamBox, {1, "Emissao Ate", stod("")                , "", "", ""   , "", 50, .t.})

	if lPerg
		lRet := ParamBox(aParamBox,"Média PA",NIL,,,,,,,"_RelAvgPA",.T.,.t.)
	else
		for nI := 1 to len(aParambox)
			&("MV_PAR"+strzero(nI,2)) := ParamLoad(__cUserID+"_RelAvgPA",aParamBox,nI,aParamBox[nI,3])
		next nI
	endif

	dEmissaoDe  := MV_PAR01
	dEmissaoAte := MV_PAR02
return lRet
