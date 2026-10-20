#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.ch'
#Include 'FWMVCDEF.CH'
/*/{Protheus.doc} vldCodBarras
Valida a digitação do código de barras
@author Tiago Faria
@since 28/05/2019
@version 1.0
@return lRet, logico, se true conteudo OK se false há algo errado no conteudo lido

@type function
/*/
user function vldCodBarras()
	local aArea		:= Lj7GetArea({"SH6"})
	local lRet 		:= .t.
	local cCodBar 	:= alltrim(FwFldGet("ZZCODBAR"))
	local cIdent	:= Right(cCodBar,getSX3Cache("H6_IDENT","X3_TAMANHO"))
	local cOP		:= subStr(cCodBar,1,len(cCodBar)-len(cIdent))
	local cAlias	:= ""
	local oModel	:= FwModelActive()
	local oForm		:= oModel:getModel("MODEL_FORM_SH6")
	local oView		:= FwViewActive()
	local bWhenTrue	:= FWBuildFeature( STRUCT_FEATURE_WHEN	,".t."	)
	local bWhenFalse:= FWBuildFeature( STRUCT_FEATURE_WHEN	,".f."	)
	lRet := isIdentValid(cOP,cIdent)

	if lRet
		cAlias	:= getProxOperac(cOP,cIdent)

		if (cAlias)->(Eof())
			lRet := .f.
			u_myHelp("Não há próxima operação a ser apontada para a OP " + cOP)
		else
			oForm:GetStruct():SetProperty("H6_ZQTPRO2", MODEL_FIELD_WHEN, bWhenTrue)
			oForm:GetStruct():SetProperty("H6_ZZMULTP", MODEL_FIELD_WHEN, bWhenTrue)

			oForm:loadValue("H6_OPERAC",(cAlias)->(G2_OPERAC))
			oForm:loadValue("H6_RECURSO",(cAlias)->(H6_RECURSO))

			if dDataBase < date()
				oForm:loadValue("H6_DATAINI",dDataBase)
				oTime := Time():new((cAlias)->(H6_HORAFIN))
				aDate := oTime:subTimeHour(dDataBase,oTime:getcHora(),"00:01")
				dDtFim := aDate[1]

				if len(aDate[3]) >= 8
					cHrFim := substr(aDate[3],1,5)
				else
					cHrFim := aDate[3]
				endif

				oForm:loadValue("H6_HORAINI",cHrFim)
			else
				oForm:loadValue("H6_DATAINI",date())
				oForm:loadValue("H6_HORAINI",subStr(time(),1,5))
			endif


			oForm:loadValue("H6_LOCAL",(cAlias)->(H6_LOCAL))
			oForm:loadValue("H6_OP",(cAlias)->(H6_OP))
			oForm:loadValue("H6_PRODUTO",(cAlias)->(H6_PRODUTO))
			oForm:loadValue("H6_ZDESCRI",(cAlias)->(B1_DESC))
			oForm:loadValue("H6_QTDPROD",(cAlias)->(H6_QTDPROD))
			oForm:loadValue("H6_ZZOPER",(cAlias)->(H6_ZZOPER))

			oForm:setValue("H6_ZQTPRO2",(cAlias)->(H6_ZQTPRO2))
			if !oForm:setValue("H6_ZZMULTP",(cAlias)->(H6_ZZMULTP))
				showErro(oModel,.t.)
			endif

			oForm:GetStruct():SetProperty("H6_ZQTPRO2", MODEL_FIELD_WHEN,bWhenFalse)
			oForm:GetStruct():SetProperty("H6_ZZMULTP", MODEL_FIELD_WHEN,bWhenFalse)
		endif

		(cAlias)->(dbCloseArea())
	endif
	Lj7RestArea(aArea)

	oView:refresh()
return lRet
/*
Retorna a proxima operação da OP
Autor: Tiago Faria
Data: 28/05/2019
*/
static function getProxOperac(cOP,cIdent)
	local cQuery 	:= ""
	local cAlias 	:= ""
	default cOP 	:= ""
	default cIdent 	:= ""

	cQuery += "SELECT" + CRLF
	cQuery += "	TOP 1" + CRLF
	cQuery += "	LTRIM(RTRIM(H6_OP)) + H6_IDENT AS CODBAR," + CRLF
	cQuery += "	SG2.*," + CRLF
	cQuery += "	SH6.*," + CRLF
	cQuery += "	B1_DESC" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SH6") + CRLF
	cQuery += "INNER JOIN " + retSqlTab("SC2") + " ON" + CRLF
	cQuery += "	1 = 1" + CRLF
	cQuery += "	AND C2_FILIAL = H6_FILIAL" + CRLF
	cQuery += "	AND C2_NUM + C2_ITEM + C2_SEQUEN + C2_GRADE = H6_OP" + CRLF
	cQuery += "	AND " + retSqlDel("SC2") + CRLF
	cQuery += "INNER JOIN " + retSqlTab("SB1") + " ON" + CRLF
	cQuery += "	1 = 1" + CRLF
	cQuery += "	AND " + retSqlFil("SB1") + CRLF
	cQuery += "	AND B1_COD = C2_PRODUTO" + CRLF
	cQuery += "	AND " + retSqlDel("SB1") + CRLF

	cQuery += "INNER JOIN " + retSqlTab("SG2") + " ON" + CRLF
	cQuery += "	1 = 1" + CRLF
	cQuery += "	AND G2_FILIAL = H6_FILIAL" + CRLF
	cQuery += "	AND G2_PRODUTO = H6_PRODUTO" + CRLF
	cQuery += "	AND G2_CODIGO = C2_ROTEIRO" + CRLF
	cQuery += "	AND G2_OPERAC > H6_OPERAC" + CRLF
	cQuery += "	AND " + retSqlDel("SG2") + CRLF
	cQuery += "WHERE" + CRLF
	cQuery += "	1 = 1" + CRLF
	cQuery += "	AND " + retSqlFil("SH6") + CRLF
	cQuery += "	AND H6_OP = '" + cOP + "'" + CRLF
	cQuery += "	AND H6_IDENT = '" + cIdent + "'" + CRLF
	cQuery += "	AND " + retSqlDel("SH6") + CRLF
	cQuery += "ORDER BY" + CRLF
	cQuery += "	H6_OP,G2_OPERAC" + CRLF
	memowrite("\sql\vldCodBarras_getProxOperac.sql",cQuery)
	TcQuery cQuery new Alias (cAlias := getNextAlias())
return cAlias

static function isIdentValid(cOP,cIdent)
	local cQuery := ""
	local cAlias := ""
	local lRet	 := .t.

	cQuery += "SELECT" + CRLF
	cQuery += "	H6_OP" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SH6") + CRLF
	cQuery += "WHERE" + CRLF
	cQuery += "	1 = 1" + CRLF
	cQuery += "	AND " + retSqlFil("SH6") + CRLF
	cQuery += "	AND H6_OP = '" + cOP + "'" + CRLF
	cQuery += "	AND H6_IDENT = '" + cIdent + "'" + CRLF
	cQuery += "	AND " + retSqlDel("SH6") + CRLF
	memowrite("\sql\vldCodBarras_isIdentValid.sql",cQuery)
	TcQuery cQuery new Alias (cAlias := getNextAlias())

	if (cAlias)->(eof())
		lRet := .f.
		u_myHelp("Etiqueta digitada " + cIdent + " não existe no sistema","Digite uma etiqueta válida")
	endif

	(cAlias)->(dbCloseArea())
return lRet

static function showErro(oModel,lShowAlert)
	Local aErro 	:= {}
	Local cRet      := ""
	default oModel	:= FwModelActive()
	default lShowAlert := .t.
	// Se os dados não foram validados obtemos a descrição do erro para gerar
	// LOG ou mensagem de aviso
	aErro := oModel:GetErrorMessage()
	// A estrutura do vetor com erro é:
	// [1] identificador (ID) do formulário de origem
	// [2] identificador (ID) do campo de origem
	// [3] identificador (ID) do formulário de erro
	// [4] identificador (ID) do campo de erro
	// [5] identificador (ID) do erro
	// [6] mensagem do erro
	// [7] mensagem da solução
	// [8] Valor atribuído
	// [9] Valor anterior
	cRet +=  "Id do formulário de origem:" + ' [' + AllToChar( aErro[1] ) + ']' + CRLF
	cRet +=  "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' + CRLF
	cRet +=  "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + ']' + CRLF
	cRet +=  "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' + CRLF
	cRet +=  "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' + CRLF
	cRet +=  "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' + CRLF
	cRet +=  "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' + CRLF
	cRet +=  "Valor atribuído: " + ' [' + AllToChar( aErro[8] ) + ']' + CRLF
	cRet +=  "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']' + CRLF
	If Type("nItErro") == "N" .and. nItErro > 0
		cRet +=   "Erro  no  Item:               "  +  '  ['  +  AllTrim(  cValToChar(nItErro ) ) + ']' + CRLF
	EndIf
	if lShowAlert
		msgAlert("Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' + CRLF + "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' ,AllToChar( aErro[5] ))
	endif
return(cRet)
