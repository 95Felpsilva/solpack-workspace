#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} RelAcompProd
Relatorio acompanhamento de produção
@author Tiago Faria
@since 16/07/2019
@version 1.0
@return nil
@type function
/*/
user function TSTAcompProd()
	local cCodEmp   := "01"

    OpenSm0(, .t.)
    RpcClearEnv()
    RpcSetEnv(cCodEmp, "0101")

	//u_RelAcompProd()
	u_RelProdApontamento()
return

user function RelAcompProd()
	local oSql 			:= nil

	if ask()
		oSql := SQL():new()
		oSql:setQuery(getQuery())
		MsgRun('Gerando EXCEL','Aguarde...',	{||oSQL:showExcel("Acompanhamento de Produção")})
		oSql:destroy()
		msgInfo("Excel gerado com sucsso!")
	endif
return

static function getQuery()
	local cQuery := ""
	cQuery += "SELECT" + CRLF
	cQuery += "	C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD AS OP," + CRLF
	cQuery += "	C2_PRODUTO AS PRODUTO," + CRLF
	cQuery += "	C2_QUANT AS QUANTIDADE," + CRLF
	cQuery += "	SUM(CASE WHEN G2_OPERAC = '01' THEN QTDPROD ELSE 0 END) AS QTD_01_APONTADA," + CRLF
	cQuery += "	SUM(CASE WHEN G2_OPERAC = '01' THEN QTDREVISAO ELSE 0 END) AS QTD_01_REVISAO," + CRLF
	cQuery += "	SUM(CASE WHEN G2_OPERAC = '02' THEN QTDPROD ELSE 0 END) AS QTD_02_APONTADA," + CRLF
	cQuery += "	C2_QUANT-SUM(CASE WHEN G2_OPERAC = '02' THEN QTDPROD ELSE 0 END) AS FALTA_APONTAR_02" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SC2") + CRLF
	
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("SG2") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND G2_FILIAL = C2_FILIAL" + CRLF
	cQuery += "	AND G2_PRODUTO = C2_PRODUTO" + CRLF
	cQuery += "	AND G2_CODIGO = C2_ROTEIRO" + CRLF
	cQuery += "	AND (	1=1" + CRLF
	cQuery += "			AND (G2_DTINI = '        ' OR C2_EMISSAO >= G2_DTINI)" + CRLF
	cQuery += "			AND (G2_DTFIM = '        ' OR C2_EMISSAO <= G2_DTFIM)" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "	AND " + retSqlDel("SG2") + CRLF
	
	cQuery += "INNER JOIN" + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT " + CRLF
	cQuery += "	H6_FILIAL," + CRLF
	cQuery += "	H6_OP," + CRLF
	cQuery += "	H6_OPERAC," + CRLF
	cQuery += "	SUM(H6_QTDPROD-H6_QTDPERD) AS QTDPROD," + CRLF
	cQuery += "	SUM(CASE WHEN H6_ZZREVIS = 'F' THEN H6_QTDPROD-H6_QTDPERD ELSE 0 END) AS QTDOK," + CRLF
	cQuery += "	SUM(CASE WHEN H6_ZZREVIS = 'T' THEN H6_QTDPROD-H6_QTDPERD ELSE 0 END) AS QTDREVISAO" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + retSqlTab("SH6") + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SH6") + CRLF
	cQuery += "	AND " + retSqlDel("SH6") + CRLF
	cQuery += "GROUP BY" + CRLF
	cQuery += "	H6_FILIAL," + CRLF
	cQuery += "	H6_OP," + CRLF
	cQuery += "	H6_OPERAC" + CRLF
	cQuery += ") SH6" + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND H6_FILIAL = C2_FILIAL" + CRLF
	cQuery += "	AND H6_OP = C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD" + CRLF
	cQuery += "	AND H6_OPERAC = G2_OPERAC" + CRLF
	
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("SB1") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SB1") + CRLF
	cQuery += "	AND B1_COD = C2_PRODUTO" + CRLF
	cQuery += "	AND B1_TIPO NOT IN ('PI')" + CRLF
	cQuery += "	AND " + retSqlDel("SB1") + CRLF
	
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SC2") + CRLF
	cQuery += "	AND C2_TPOP = 'F'" + CRLF
	cQuery += "	AND C2_DATRF = '        '" + CRLF
	//cQuery += "	AND NOT C2_QUJE >= C2_QUANT" + CRLF
	cQuery += "	AND " + retSqlDel("SC2") + CRLF
	cQuery += "GROUP BY" + CRLF
	cQuery += "C2_FILIAL," + CRLF
	cQuery += "C2_NUM," + CRLF
	cQuery += "C2_ITEM," + CRLF
	cQuery += "C2_SEQUEN," + CRLF
	cQuery += "C2_ITEMGRD," + CRLF
	cQuery += "C2_PRODUTO," + CRLF
	cQuery += "C2_QUANT" + CRLF
	
return cQuery

static function ask(lPerg)
	local lRet 		:= .t.
	local aParamBox := {}
	local nI		:= 0
	default lPerg 	:= .t.

	return .t.
	/*
	aAdd(aParamBox,{1,"Competencia de"		,space(7)					,"@E 99/9999","","","",50,.t.})
	aAdd(aParamBox,{1,"Competencia Ate"		,space(7)					,"@E 99/9999","","","",50,.t.})

	if lPerg
	lRet := ParamBox(aParamBox,"Demonstrativo de Producao",NIL,,,,,,,"_Demonstrativo_Producao",.T.,.t.)
	else
	for nI := 1 to len(aParambox)
	&("MV_PAR"+strzero(nI,2)) := ParamLoad(__cUserID+"_Demonstrativo_Producao",aParamBox,nI,aParamBox[nI,3])
	next nI
	endif
	*/
return lRet
