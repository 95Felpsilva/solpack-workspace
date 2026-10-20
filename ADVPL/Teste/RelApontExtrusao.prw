#include 'totvs.ch'

user function tstRelApontExtrusao()
	RpcSetEnv("01","0101")

	u_RelApontExtrusao()

	rpcClearEnv()
return

user function RelApontExtrusao()
	local oSql 			:= nil
	private cRecursoDe  := ""
	private cRecursoAte := ""
	private cProdDe     := ""
	private cProdAte    := ""
	private cOperadorDe := ""
	private cOperadorAte:= ""
	private dDataIni    := stod("")
	private dDataFim    := stod("")
	private cTurnoDe    := ""
	private cTurnoAte   := ""

	if ask()
		oSql := SQL():new()
		oSql:setQuery(getQuery())
		MsgRun('Gerando EXCEL','Aguarde...',	{||oSQL:showExcel("Acompanhamento de Produção da Extrusao")})
		oSql:destroy()
		msgInfo("Excel gerado com sucsso!")
	endif
return

static function getQuery()
	local cQuery := ""
	local lH6Peso := SH6->(fieldPos("H6_ZZPESBR")) > 0
	local cPesoBruto := if(lH6Peso,"H6_ZZPESBR","B1_PESBRU")
	local cPesoLiquido :=if(lH6Peso,"H6_ZZPESLI","B1_PESO")

	cQuery += "SELECT" + CRLF
	cQuery += "	H6_OP AS ORDEM_PRODUCAO," + CRLF
	cQuery += "	H6_OPERAC AS OPERACAO," + CRLF
	cQuery += "	B1_COD AS COD_PRODUTO," + CRLF
	cQuery += "	B1_DESC AS DESC_PRODUTO," + CRLF
	cQuery += "	B1_TIPO AS TIPO_PRODUTO," + CRLF
	cQuery += "	H6_ZZOPER AS COD_OPERADOR," + CRLF
	cQuery += "	SZZ.ZZ_NOME AS OPERADOR," + CRLF
	cQuery += "	H6_RECURSO AS COD_MAQUINA," + CRLF
	cQuery += "	H1_DESCRI AS MAQUINA," + CRLF
	cQuery += "	H6_QTDPROD AS QUANTIDADE," + CRLF
	cQuery += "	H6_ZQTPRO2 - ((" + cPesoBruto + " * (H6_QTDPROD-H6_QTDPERD) ) - (" +  cPesoLiquido + " * (H6_QTDPROD-H6_QTDPERD))) AS PESO_REAL," + CRLF
	cQuery += "	H6_ZQTPRO2  AS PESO_APONTADO," + CRLF
	cQuery += "	" + cPesoBruto + " * (H6_QTDPROD-H6_QTDPERD) AS PESO_BRUTO_TEORICO," + CRLF
	cQuery += "	" +  cPesoLiquido + " * (H6_QTDPROD-H6_QTDPERD) AS PESO_LIQ_TEORICO," + CRLF

	cQuery += "	H6_ZZTURNO AS TURNO," + CRLF
	cQuery += "	ZZ7_DESC AS DESC_TURNO," + CRLF

	cQuery += "	SUBSTRING(H6_DATAINI,7,2) + '/' + SUBSTRING(H6_DATAINI,5,2) + '/' + SUBSTRING(H6_DATAINI,1,4) AS DATA_INICIO_APONTAMENTO," + CRLF
	cQuery += "	H6_HORAINI AS HORA_INICIO_APONTAMENTO," + CRLF
	cQuery += "	SUBSTRING(H6_DATAFIN,7,2) + '/' + SUBSTRING(H6_DATAFIN,5,2) + '/' + SUBSTRING(H6_DATAFIN,1,4) AS DATA_FIM_APONTAMENTO," + CRLF
	cQuery += "	H6_HORAFIN AS HORA_FIM_APONTAMENTO," + CRLF
	cQuery += "	CASE" + CRLF
	cQuery += "		WHEN --SABADO DAS 18:01 AS 23:59" + CRLF
	cQuery += "			DATEPART(weekday,CONVERT(DATETIME,H6_DATAINI + ' ' + H6_HORAINI)) = 7 AND CONVERT(TIME,H6_DATAINI + ' ' + H6_HORAINI) BETWEEN CONVERT(TIME,H6_DATAINI + ' 18:00') AND CONVERT(TIME,H6_DATAINI + ' 23:59') THEN 'HORA EXTRA'" + CRLF
	cQuery += "		WHEN --DOMINGO DAS 00:00 AS 17:59" + CRLF
	cQuery += "			DATEPART(weekday,CONVERT(DATETIME,H6_DATAINI + ' ' + H6_HORAINI)) = 1 AND CONVERT(TIME,H6_DATAINI + ' ' + H6_HORAINI) BETWEEN CONVERT(TIME,H6_DATAINI + ' 00:00') AND CONVERT(TIME,H6_DATAINI + ' 17:59') THEN 'HORA EXTRA'" + CRLF
	cQuery += "	ELSE 'HORA NORMAL' " + CRLF
	cQuery += "END AS TIPO_HORA" + CRLF
	cQuery += "FROM " + CRLF

	cQuery += "	 " + retSqlTab("SH6") + CRLF

	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("SB1") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SB1") + CRLF
	cQuery += "	AND B1_COD = H6_PRODUTO
	cQuery += "	AND " + retSqlDel("SB1") + CRLF

	cQuery += "INNER JOIN
	cQuery += "	" + retSqlTab("SH1") + CRLF
	cQuery += "ON 1=1
	cQuery += "	AND " + retSqlFil("SH1") + CRLF
	cQuery += "	AND H1_CODIGO = H6_RECURSO
	cQuery += "	AND " + retSqlDel("SH1") + CRLF

	cQuery += "INNER JOIN
	cQuery += "	" + retSqlTab("SZZ") + CRLF
	cQuery += "ON 1=1
	cQuery += "	AND " + retSqlFil("SZZ") + CRLF
	cQuery += "	AND ZZ_COD = H6_ZZOPER" + CRLF
	cQuery += "	AND ZZ_TURNO BETWEEN '" + cTurnoDe + "' AND '" + cTurnoAte + "'" + CRLF
	cQuery += "	AND " + retSqlDel("SZZ") + CRLF

	cQuery += "LEFT JOIN
	cQuery += "	" + retSqlTab("ZZ7") + CRLF
	cQuery += "ON 1=1
	cQuery += "	AND " + retSqlFil("ZZ7") + CRLF
	cQuery += "	AND ZZ7_ID = H6_ZZTURNO" + CRLF
	cQuery += "	AND " + retSqlDel("ZZ7") + CRLF

	cQuery += "WHERE 1=1

	cQuery += "	AND " + retSqlFil("SH6") + CRLF
	cQuery += "	AND H6_OPERAC = '02'" + CRLF
	cQuery += "	AND H6_PRODUTO BETWEEN '" + cProdDe + "' AND '" + cProdAte + "'" + CRLF
	cQuery += "	AND H6_ZZOPER BETWEEN '" + cOperadorDe + "' AND '" + cOperadorAte + "'" + CRLF
	cQuery += "	AND H6_RECURSO BETWEEN '" + cRecursoDe + "' AND '" + cRecursoAte + "'" + CRLF
	cQuery += "	AND H6_DATAINI BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFim) + "'" + CRLF
	cQuery += "	AND H6_DATAFIN BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFim) + "'" + CRLF
	cQuery += "	AND " + retSqlDel("SH6") + CRLF
	cQuery += "ORDER BY H6_DATAINI,H6_HORAINI" + CRLF
return cQuery

static function ask(lPerg)
	local lRet 		:= .t.
	local aParamBox := {}
	local nI		:= 0
	default lPerg 	:= .t.

	aAdd(aParamBox,{1,"Recurso de"		,criavar("H6_RECURSO",.F.)	    ,getSX3Cache("H6_RECURSO","X3_PICTURE"),"","SH1","",50,.f.})
	aAdd(aParamBox,{1,"Recurso Ate"		,criavar("H6_RECURSO",.F.)      ,getSX3Cache("H6_RECURSO","X3_PICTURE"),"","SH1","",50,.t.})

	aAdd(aParamBox,{1,"Prod de"		    ,criavar("B1_COD",.F.)	        ,getSX3Cache("B1_COD","X3_PICTURE"),"","SB1","",80,.f.})
	aAdd(aParamBox,{1,"Prod Ate"		,criavar("B1_COD",.F.)          ,getSX3Cache("B1_COD","X3_PICTURE"),"","SB1","",80,.t.})

	aAdd(aParamBox,{1,"Operador de"		,criavar("H6_ZZOPER",.F.)	    ,getSX3Cache("H6_ZZOPER","X3_PICTURE"),"","SZZ","",40,.f.})
	aAdd(aParamBox,{1,"Operador Ate"	,criavar("H6_ZZOPER",.F.)       ,getSX3Cache("H6_ZZOPER","X3_PICTURE"),"","SZZ","",40,.t.})

	

	aAdd(aParamBox,{1,"Dt Apontamento Inicio"	,stod("")				,getSX3Cache("H6_DATAINI","X3_PICTURE"),"","","",60,.t.})
	aAdd(aParamBox,{1,"Dt Apontamento Fim"		,stod("")				,getSX3Cache("H6_DATAINI","X3_PICTURE"),"","","",60,.t.})

	aAdd(aParamBox,{1,"Turno de"		,criavar("ZZ7_ID",.F.) 			,"@!","","ZZ7","",60,.f.})//,getX3Box("ZZ_TURNO"),50,"",.f.})
	aAdd(aParamBox,{1,"Turno Ate"	    ,criavar("ZZ7_ID",.F.)          ,"@!","","ZZ7","",60,.t.})//,getX3Box("ZZ_TURNO"),50,"",.t.})

	if lPerg
		lRet := ParamBox(aParamBox,"Producao da Extrusao",NIL,,,,,,,"_producao_da_Extrusao",.T.,.t.)
	else
		for nI := 1 to len(aParambox)
			&("MV_PAR"+strzero(nI,2)) := ParamLoad(__cUserID+"_producao_da_Extrusao",aParamBox,nI,aParamBox[nI,3])
		next nI
	endif

	if lRet
		cRecursoDe  := MV_PAR01
		cRecursoAte := MV_PAR02
		cProdDe     := MV_PAR03
		cProdAte    := MV_PAR04
		cOperadorDe := MV_PAR05
		cOperadorAte:= MV_PAR06
		dDataIni    := MV_PAR07
		dDataFim    := MV_PAR08
		cTurnoDe    := MV_PAR09
		cTurnoAte   := MV_PAR10
	endif

return lRet

static function getX3Box(cField,lLenBox,lModel)
	local cBox 			:= getSX3Cache(cField,"X3_CBOX")
	local nInitCBox		:= 0
	local nMaxLenCombo 	:= 0
	local aTmp			:= {}
	local aRet			:= nil
	local nX            := 0
	default lLenBox		:= .f.
	default lModel		:= .t.

	if lModel
		cBox := alltrim(cBox)
	endif

	If !Empty(cBox)
		aRet := {}
		aTmp := RetSX3Box(cBox,@nInitCBox,@nMaxLenCombo,getSX3Cache(cField,"X3_TAMANHO"))
		if lLenBox
			aRet := nMaxLenCombo
		else
			For nX := 1 to Len(aTmp)
				aAdd(aRet,aTmp[nx][1])
			Next nX
		endif
	Endif
return aRet
