#include 'protheus.ch'
#include 'topconn.ch'

#Define CHAR_ASK superGetMV("ZZ_CHARASK",,":")
#Define CHAR_MACRO superGetMV("ZZ_CHARMAC",,"@#")

static cQueryBackup := ""

/*/{Protheus.doc} SQL
Classe responsavel por executar querys e extrair dados em excel
@author Tiago Faria
@since 22/06/2017
@version 1.0
@type class
/*/
class SQL
data cQuery 		as string
data cAlias 		as string
data lShowErro 		as boolean
data cError			as string
data aParambox 		as array
data cPathSaveSQL 	as string
data cFileSQL		as string
data aIDAsk			as array
data cIDParambox	as string
data cFileExcel		as string

method new() constructor
method runQuery()
method showExcel()
method showGrid()
method showReport()
method execQuery()
method updateAlias(cAliasUpdate)
method getQuery()
method setQuery()
method getAlias()
method setAlias()
method setShowErro()
method isShowErro()
method getError()
method destroy()
method pergunte()
method addParambox(cId,aParambox)
endclass

/*/{Protheus.doc} new
Metodo construtornew
@author Tiago Faria
@since 22/06/2017
@version 1.0
@type function
/*/
method new() class SQL
	::setQuery("")
	::setShowErro()
	::cError 		:= ""
	::aParamBox 	:= {}
	::cPathSaveSQL 	:= alltrim(superGetMV("ZZ_PATHSQL",,"\sql\"))
	::cFileSQL		:= alltrim(funname())+".sql"
	::aIDAsk		:= {}
	::cIDParambox	:= funname()
	::cFileExcel	:= dtos(date()) + "_" + strtran(time(),":","") + ".xml"
	::setAlias()
return

/*/{Protheus.doc} runQuery
Executa a query criando um novo alias para a mesma
@author Tiago Faria
@since 22/06/2017
@version 6

@type function
/*/
method runQuery() class SQL
	local nField := 0
	local aArea	 := Lj7GetArea({"SX3"})
	local lRet	 := .f.

	if ::pergunte()
		lRet := .t.
		memoWrite(::cPathSaveSQL + ::cFileSQL,::getQuery())

		TcQuery ::getQuery() new Alias (::getAlias())
		SX3->(dbSetOrder(2))
		for nField := 1 to (::getAlias())->(fCount())
			cField := (::getAlias())->(fieldName(nField))
			if !empty(getSX3Cache(cField,"X3_ARQUIVO"))
				tcSetField(::getAlias(),cField,getSX3Cache(cField,"X3_TIPO"),getSX3Cache(cField,"X3_TAMANHO"),getSX3Cache(cField,"X3_DECIMAL"))
			endif
		next nField
	endif
	Lj7RestArea(aArea)
return lRet
/*/{Protheus.doc} showExcel
Mostra o resultado da query em excel
@author Tiago Faria
@since 22/06/2017
@version 6
@type function
/*/
method showExcel(cTitle) class SQL
	local oExcel 		:= FWMSEXCEL():New()
	local cWorkSheet  	:= ::getAlias()
	local cPlan			:= cWorkSheet
	local nField 		:= 0
	local cField		:= ""
	local nAlign		:= 0
	local lCabec		:= .f.
	local aRow			:= {}
	local cTempPath		:= GetTempPath()
	local xContent		:= nil
	default cTitle		:= ""
	
	if !empty(cTitle)
		cWorkSheet 	:= cTitle
		cPlan 		:= cWorksheet
	endif
	if select(::getAlias()) == 0
		if !::runQuery()
			return
		endif
	endif

	oExcel:AddworkSheet(cWorkSheet)
	oExcel:AddTable (cWorkSheet,cPlan)


	if (::getAlias())->(eof())
		oExcel:AddColumn(cWorkSheet,cPlan,"Não há dados para a imprimir, revise os parametros e tente novamente! ",nAlign,1)
	else
		while (::getAlias())->(!eof())
			for nField := 1 to (::getAlias())->(fCount())
				cField := (::getAlias())->(fieldName(nField))
				xContent := (::getAlias())->&(cField)

				cTitulo	:= getSX3Cache(cField,"X3_TITULO")
				if empty(cTitulo)
					cTitulo := strtran(cField,"_"," ")
				endif

				cTipo	:= getSX3Cache(cField,"X3_TIPO")
				if cTipo == "N"
					nAlign	:= 2
				else
					nAlign	:= 1
				endIf

				if !lCabec
					oExcel:AddColumn(cWorkSheet,cPlan,cTitulo,nAlign,1)
				endIf

				if cTipo == "C" .and. subStr(xContent,1,2) == CHAR_MACRO
					xContent := strTran(xContent,CHAR_MACRO) 
					xContent := &(xContent)
					aAdd(aRow,xContent)
				else
					aAdd(aRow,(xContent))
				endif

			next nI

			oExcel:AddRow(cWorkSheet,cPlan,aRow)
			aRow	:= {}
			(::getAlias())->(DbSkip())
			lCabec	:= .t.
		endDo
	endif
	oExcel:Activate()

	If !ApOleClient( 'MsExcel' )
		MsgStop( 'MsExcel não instalado!' )
		Return
	Else
		lRet	:= oExcel:GetXMLFile(::cFileExcel)
		CpyS2T(::cFileExcel,cTempPath)
		fErase(::cFileExcel)
		if ::isShowErro()
			FreeObj(oExcel)
			oExcel:= MsExcel():New()
			oExcel:WorkBooks:Open(cTempPath+::cFileExcel)
			oExcel:SetVisible(.T.)
			oExcel:Destroy()

			FreeObj(oExcel)
		endif
		//shellexecute("Open",cTempPath + cWorkSheet + ".xml","","",1)
	EndIf
return lRet
/*/{Protheus.doc} showGrid
Mostra o resultado da query em grid (MsNewGetDados)
@author Tiago Faria
@since 22/06/2017
@version 6
@type method
/*/
method showGrid() class SQL

return
/*/{Protheus.doc} showReport
Mostra o resultado da query em relatorio (TReport)
@author Tiago Faria
@since 22/06/2017
@version 6
@type method
/*/
method showReport(cTitle,cHelp) class SQL
	local oReport 	:= nil
	default cTitle	:= ""
	default cHelp	:= ""

	oReport := TReport():New(getNextAlias(),cTitle,{||::pergunte()},{|oReport|print(self,oReport,cTitle,cHelp)},cHelp)
	oReport:SetEnvironment(2)
	oReport:SetLandscape()

	oReport:printDialog()
return

static function print(self,oReport,cTitle,cHelp)
	local oSection	:= nil
	local nField	:= 0
	local cField	:= ""

	if at(CHAR_ASK,::getQuery()) > 0
		::pergunte(.f.)
	endif

	oSection := TRSection():New(oReport,cTitle,{::getAlias()})

	oSection:setQuery(::getAlias(),::getQuery())

	oSection:EndQuery()

	for nField := 1 to (::getAlias())->(fCount())
		cField := (::getAlias())->(fieldName(nField))
		if !empty(getSX3Cache(cField	,"X3_ARQUIVO"))
			TRCell():New(;
			oSection,;
			cField ,;
			::getAlias(),;
			getSX3Cache(cField	,"X3_TITULO")	,;
			getSX3Cache(cField		,"X3_PICTURE")	,;
			getSX3Cache(cField		,"X3_TAMANHO"),;
			,;
			{|oCell| getPrintContent(self,oCell)}	)
		else
			TRCell():New(oSection, cField , ::getAlias(), cField	, 	,len((::getAlias())->(&cField)),,{|oCell| getPrintContent(self,oCell)}	)
		endif
	next nField

	oReport:SetMeter((::getAlias())->(RecCount()))

	(::getAlias())->(dbGoTop())

	oSection:Init()
	while (::getAlias())->(!eof())
		oSection:PrintLine()
		oReport:IncMeter()
		(::getAlias())->(dbskip())
	enddo
	oSection:Finish()
	//oReport:Section(1):print()
return

/*/{Protheus.doc} execQuery
Executa a query direto no banco com a funcao tcSqlExec
@author Tiago Faria
@since 22/06/2017
@version 6
@type method
@return logical, se .t. instrucao executada com sucesso se .f. com erro
@example
if !SQL:execQuery()
mostraErro()
endif
/*/
method execQuery() class SQL
	local lOK := .t.

	lOK := TcSqlExec(::getQuery) >= 0

	if !lOK
		::cError := TcSqlError()
		AutoGrLog(::cError)

		if ::isShowErro()
			mostraErro()
		endif
	endif

return lOK
/*/{Protheus.doc} updateAlias
Realiza update de registros do alias recebido como parametro
@author Tiago Faria
@since 22/06/2017
@version 6
@type method
@param cAliasUpdate, characters, Alias a ser realizado o update
@return logical, se .t. update ocorreu com sucesso se .f. com erro
@example
local oSql := SQL():new()
//OBRIGATORIO O CAMPO RECNO NA QUERY PARA REALIZAR O UPDATE
oSql:setQuery("SELECT SA1.R_E_C_N_O_ AS RECNO, 'SP' AS A1_EST, 'TIAGO' AS A1_NOME FROM SA1010 SA1 WHERE D_E_L_E_T_ <> '*' AND A1_EST = 'RJ'")

if !oSql:updateAlias("SA1")
msgAlert("Erro durante execucao")
endif

oSQL:destroy()
/*/
method updateAlias(cAliasUpdate) class SQL
	local nField := 0
	local cField := ""
	local lOK	 := .t.
	local aArea	 := Lj7GetArea({cAliasUpdate})

	default cAliasUpdate := ""

	dbSelectArea(cAliasUpdate)
	(cAliasUpdate)->(dbSetOrder(1))
	(cAliasUpdate)->(dbGoTop())


	if select(::getAlias()) == 0
		::runQuery()
	endif

	if (::getAlias())->(fieldPos("RECNO")) == 0
		AutoGrLog("O campo RECNO é obrigatório na QUERY para realizar o update")
		lOK := .f.
	endif

	BEGIN TRANSACTION

		while lOK .and. (::getAlias())->(!Eof())
			(cAliasUpdate)->(dbGoTo((::getAlias())->(RECNO)))

			if recLock(cAliasUpdate,.f.)

				for nField := 1 to (::getAlias())->(fCount())
					cField := (::getAlias())->(fieldName(nField))
					if cField <> "RECNO" .and. (cAliasUpdate)->(fieldPos(cField)) > 0
						(cAliasUpdate)->(&cField) := (::getAlias())->(&cField)
					endif
				next nField

				(cAliasUpdate)->(msUnlock())
			else
				autoGrLog("Registro com RECNO = " + cValToChar((::getAlias())->(RECNO)) + " está sendo utilizado por outro usuário")
				lOK := .f.
				exit
			endif
			(::getAlias())->(dbSkip())
		enddo

		if !lOK
			::cError := memoread(nomeAutoLog())
			disarmTransaction()
			if ::isShowErro()
				mostraErro()
			endif
		endif

	END TRANSACTION

	Lj7RestArea(aArea)
return lOK

method pergunte(lPerg) class SQL
	local lRet 		:= .t.
	local aParamBox := {}
	local nI		:= 0
	default lPerg 	:= .t.

	aParambox := getAsks(self)

	if len(aParambox) > 0

		if lPerg
			lRet := ParamBox(aParamBox,::cIdParambox,NIL,,,,,,,::cIdParambox,.T.,.t.)
		else
			for nI := 1 to len(aParambox)
				&("MV_PAR"+strzero(nI,2)) := ParamLoad(__cUserID+::cIdParambox,aParamBox,nI,aParamBox[nI,3])
			next nI
		endif

		if lRet
			formatQuery(self)
		endif
	endif
return lRet

method addParamBox(cID,aParambox) class SQL
	default cID 		:= ""
	default aParamBox 	:= {}

	aAdd(::aParambox,{cID,aParamBox})
return

method getQuery() class SQL
return ::cQuery

method setQuery(cQuery) class SQL
	default cQuery := ""

	::cQuery := cQuery

	if at(CHAR_ASK,cQuery) > 0 .and. !isInCallStack("formatQuery")
		cQueryBackup := cQuery
	endif
return

method getAlias() class SQL
return ::cAlias

method setAlias(cAlias) class SQL
	default cAlias := getNextAlias()
	::cAlias := cAlias

	::cFileExcel := ::cAlias + "_" + ::cFileExcel
return

method destroy() class SQL
	if select(::getAlias()) > 0
		(::getAlias())->(dbCloseArea())
	endif
return

method setShowErro(lShowErro) class SQL
	default lShowErro := .t.//isBlind()

	::lShowErro := lShowErro
return

method isShowErro() class SQL
return ::lShowErro

method getError() class SQL
return ::cError


static function getAsks(self)
	local aAsk 		:= strtokarr2(cQueryBackup,CHAR_ASK)
	local nAsk		:= 0
	local cAsk		:= ""
	local aIDAsk 	:= {}
	local nPosAsk	:= 0
	local aParambox := {}

	for nAsk := 1 to len(aAsk)
		cAsk := aAsk[nAsk]

		if at(CHAR_ASK + alltrim(cAsk) + CHAR_ASK,cQueryBackup) > 1 .and. !empty(alltrim(cAsk))
			if aScan(aIDAsk,cAsk) == 0
				aAdd(aIDAsk,cAsk)
			endif
		endif
	next nAsk

	for nAsk := 1 to len(aIDAsk)
		cAsk 		:= aIDAsk[nAsk]
		nPosAsk 	:= aScan(::aParamBox,{|aAsk| aAsk[1] == cAsk})

		if nPosAsk > 0
			aAdd(aParamBox,::aParamBox[nPosAsk,2])
		endif
	next nAsk

	::aIDAsk := aIDAsk
return aParambox

static function formatQuery(self)
	local aAsk 	:= 0
	local xConteudo	:= nil
	local cType		:= ""
	local cAspas	:= ""
	local cIDAsk	:= ""

	::setQuery(cQueryBackup)

	for aAsk := 1 to len(::aIDAsk)
		cIDAsk 		:= CHAR_ASK + ::aIDAsk[aAsk] + CHAR_ASK
		xConteudo 	:= &("MV_PAR"+strzero(aAsk,2))
		cType 		:= valType(xConteudo)
		cAspas 		:= ""

		if cType == "D"
			xConteudo := DToS(xConteudo)
			cAspas := "'"
		elseif cType == "N"
			xConteudo := cValToChar(xConteudo)
		elseif cType == "L"
			xConteudo := if(xConteudo,1,0)
		else
			cAspas := "'"
		endif
		::setQuery(strTran(::getQuery(),cIDAsk,cAspas+xConteudo+cAspas))
	next aAsk
return

static function getPrintContent(self, oCell)
	local xRet	 := (::getAlias())->(&cField)

	if valType(xRet) == "C" .and. subStr(xRet,1,2) == CHAR_MACRO
		xRet := &(strTran(xRet,CHAR_MACRO,""))
	endif
return xRet
