#include 'Totvs.ch'
/*/{Protheus.doc} RelApApara
Relatório para listar as movimentações referente a apara
@type function
@version  1.0
@author Tiago Faria
@since 08/04/2021
/*/
user function RelApApara()
	local oSql 			:= nil
	private cOPAte      := ""
	private cOPDe       := ""
	private cProdAte    := ""
	private cProdDe     := ""
	private cRecursoAte := ""
	private cRecursoDe  := ""
	private cTurnoAte   := ""
	private cTurnoDe    := ""
	private dEmissaoAte := stod("")
	private dEmissaoDe  := stod("")

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

	cQuery += "SELECT	" + CRLF
	cQuery += "	D3_EMISSAO," + CRLF
	cQuery += "	D3_OP," + CRLF
	cQuery += "	D3_COD," + CRLF
	cQuery += "	B1_DESC," + CRLF
	cQuery += "	D3_UM," + CRLF
	cQuery += "	D3_QUANT," + CRLF
	cQuery += "	D3_ZZRECUR," + CRLF
	cQuery += "	D3_ZZTURNO," + CRLF
	cQuery += "	D3_DOC" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + retSqlTab("SD3") + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("SB1") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SB1") + CRLF
	cQuery += "	AND B1_COD = SD3.D3_COD " + CRLF
	cQuery += "	AND " + retSqlDel("SB1") + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SD3") + CRLF
	cQuery += "	AND D3_CF = 'DE9'" + CRLF
	cQuery += "	AND D3_TM = '130'" + CRLF
	cQuery += "	AND D3_OP BETWEEN '" + cOPDe + "' AND '" + cOPAte + "'" + CRLF
	cQuery += "	AND D3_EMISSAO BETWEEN '" + dtos(dEmissaoDe) + "' AND '" + dtos(dEmissaoAte) + "'" + CRLF
	cQuery += "	AND D3_ZZRECUR BETWEEN '" + cRecursoDe + "' AND '" + cRecursoAte + "'" + CRLF
	cQuery += "	AND D3_ZZTURNO BETWEEN '" + cTurnoDe + "' AND '" + cTurnoAte + "'" + CRLF
	cQuery += "	AND D3_COD BETWEEN '" +  cProdDe + "' AND '" + cProdAte + "'" + CRLF
	cQuery += "	AND " + retSqlDel("SD3") + CRLF
	cQuery += "ORDER BY" + CRLF
	cQuery += "	D3_EMISSAO," + CRLF
	cQuery += "	D3_OP" + CRLF

return cQuery

static function ask(lPerg)
	local lRet 		:= .t.
	local aParamBox := {}
	local nI		:= 0
	default lPerg 	:= .t.

	aadd(aParamBox, {1, "Emissao De" , stod("")                , "", "", ""   , "", 50, .F.})
	aadd(aParamBox, {1, "Emissao Ate", stod("")                , "", "", ""   , "", 50, .t.})
	aadd(aParamBox, {1, "OP De"      , criavar("D3_OP",.F.)    , "", "", "SC2", "", 90, .F.})
	aadd(aParamBox, {1, "OP Ate"     , criavar("D3_OP",.F.)    , "", "", "SC2", "", 90, .t.})
	aadd(aParamBox, {1, "Recurso De" , criavar("H1_CODIGO",.F.), "", "", "SH1", "", 70, .F.})
	aadd(aParamBox, {1, "Recurso Ate", criavar("H1_CODIGO",.F.), "", "", "SH1", "", 70, .t.})
	aadd(aParamBox, {1, "Produto De" , criavar("B1_COD",.F.)   , "", "", "SB1", "", 70, .F.})
	aadd(aParamBox, {1, "Produto Ate", criavar("B1_COD",.F.)   , "", "", "SB1", "", 70, .t.})
	aadd(aParamBox, {2, "Turno de"   , criavar("ZZ_TURNO",.F.) , getX3Box("ZZ_TURNO"), 50, ""   , .f.})
	aadd(aParamBox, {2, "Turno Ate"  , criavar("ZZ_TURNO",.F.) , getX3Box("ZZ_TURNO"), 50, ""   , .t.})

	if lPerg
		lRet := ParamBox(aParamBox,"Ap Apara",NIL,,,,,,,"_RelApApara",.T.,.t.)
	else
		for nI := 1 to len(aParambox)
			&("MV_PAR"+strzero(nI,2)) := ParamLoad(__cUserID+"_RelApApara",aParamBox,nI,aParamBox[nI,3])
		next nI
	endif
	
    dEmissaoDe  := MV_PAR01
	dEmissaoAte := MV_PAR02
	cOPDe       := MV_PAR03
	cOPAte      := MV_PAR04
	cRecursoDe  := MV_PAR05
	cRecursoAte := MV_PAR06
	cProdDe     := MV_PAR07
	cProdAte    := MV_PAR08
	cTurnoDe    := MV_PAR09
	cTurnoAte   := MV_PAR10

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
