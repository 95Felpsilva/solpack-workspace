#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDEF.CH'
#Include 'topconn.CH'

#Define ALIAS_FORM		"SH6"
#Define MODELO			"APCODBAR"
#Define ID_MODELO		"APMCODBAR"
#Define TITULO_MODEL 	"Apontamento Codigo de Barras"
#Define TITULO_FORM		"Apontamento Codigo de Barras"
#Define TITULO_VIEW 	TITULO_MODEL
#Define ID_MODEL_FORM	"MODEL_FORM_" + ALIAS_FORM
#Define ID_VIEW_FORM	"VIEW_FORM_" + ALIAS_FORM
#Define FIELDS_FORM		"|H6_OP|H6_PRODUTO|H6_ZDESCRI|H6_OPERAC|H6_RECURSO|H6_DATAINI|H6_HORAINI|H6_LOCAL|H6_QTDPROD|H6_ZQTPRO2|H6_ZZMULTP|H6_ZZOPER|"
/*/{Protheus.doc} APCODBAR
Cad Registro Anvisa
@author Tiago Faria
@since 06/03/2018
@version undefined
@type function
/*/
user function APCODBAR()
	local 	cModelo 	:= MODELO
	local 	cTitle		:= TITULO_MODEL
	local	cAliasForm	:= ALIAS_FORM
	Local 	oBrowse 	:= FWMBrowse():New()
	private cCadastro	:= "VISUALIZAR - Apontamento de Produção Codigo de Barras"

	if funName() == "MATA681"
		FWExecView('INCLUIR - Apontamento de Produção Codigo de Barras','APCODBAR', 3,, { || .T.})
	else
		oBrowse:SetAlias(cAliasForm)
		oBrowse:setMenuDef(cModelo)
		oBrowse:SetDescription(cTitle)
		oBrowse:Activate()	
	endif
return

Static Function MenuDef()
	Local aRotina := {}
	local cModelo := MODELO
	ADD OPTION aRotina Title 'Incluir' Action 'u_IncApCodBar()' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar' Action 'AxVisual' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Rel. Acompanhamento Producao' Action 'u_RELACOMPPROD()' OPERATION 6 ACCESS 0
	/*
	ADD OPTION aRotina Title 'Alterar'		Action 'VIEWDEF.'+cModelo OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'		Action 'VIEWDEF.'+cModelo OPERATION 5 ACCESS 0
	*/
Return aRotina

Static Function ModelDef()
	local cAliasForm 	:= ALIAS_FORM
	local cIdModelForm	:= ID_MODEL_FORM
	local cFormTitulo	:= TITULO_FORM
	local cModelTitulo	:= TITULO_MODEL
	local cIdModelo		:= ID_MODELO
	local cFieldsForm	:= FIELDS_FORM
	Local oForm 		:= FWFormStruct(1, cAliasForm,{|cCampo|  alltrim(cCampo) + '|' $ cFieldsForm })
	Local oModel		:= nil
	local oUtilMVC		:= IPUtilMVC():new()
	local xValid		:= nil
	local aOption		:= {}
	local oEvent		:= ApCodBarGRV():new()
	oModel := MPFormModel():New(cIdModelo,,,/*bCommit*/)

	oForm 		:= FWFormStruct(1, cAliasForm,{|cCampo|  alltrim(cCampo) + '|' $ cFieldsForm })
	//oUtilMVC:removeTrigger(@oForm)     

	xValid := FWBuildFeature( STRUCT_FEATURE_VALID	, ".t."	)
	oForm:SetProperty( '*' , MODEL_FIELD_VALID,xValid)

	xValid := FWBuildFeature( STRUCT_FEATURE_WHEN	,".f."	)
	oForm:SetProperty( '*' , MODEL_FIELD_WHEN,xValid)
	/*
	xValid := FWBuildFeature( STRUCT_FEATURE_WHEN	,".t."	)
	oForm:SetProperty( 'H6_ZQTPRO2' , MODEL_FIELD_WHEN,xValid)
	oForm:SetProperty( 'H6_ZZMULTP' , MODEL_FIELD_WHEN,xValid)
	*/
	xValid := FWBuildFeature( STRUCT_FEATURE_VALID	,"u_vldMultiplicidade()"	)
	oForm:SetProperty( 'H6_ZZMULTP' , MODEL_FIELD_VALID,xValid)

	/*
	xValid := FWBuildFeature( STRUCT_FEATURE_WHEN	,"u_EditCpoMul()"	)
	oForm:SetProperty( 'H6_ZZMULTP' , MODEL_FIELD_WHEN,xValid)

	xValid := FWBuildFeature( STRUCT_FEATURE_WHEN	,"!u_EditCpoMul()"	)
	oForm:SetProperty( 'H6_QTDPROD' , MODEL_FIELD_WHEN,xValid)
	*/
	oForm:SetProperty( 'H6_QTDPROD' , MODEL_FIELD_OBRIGAT,.t.)
	oForm:SetProperty( 'H6_ZQTPRO2' , MODEL_FIELD_OBRIGAT,.t.)
	oForm:SetProperty( 'H6_ZZMULTP' , MODEL_FIELD_OBRIGAT,.t.)

	aadd(aOption, {"X3_TITULO" , "Cód. Barras"})
	aadd(aOption, {"X3_DESCRIC", "Cód. Barras"})
	aadd(aOption, {"X3_ORDEM"  , "01"})
	aadd(aOption, {"X3_CONTEXT", .t.})
	aadd(aOption, {"X3_WHEN"   , ".T."})
	aadd(aOption, {"X3_TIPO"   , "C"})
	aadd(aOption, {"X3_TAMANHO", getSX3Cache("H6_OP","X3_TAMANHO")-getSX3Cache("C2_ITEMGRD","X3_TAMANHO")+getSX3Cache("H6_IDENT","X3_TAMANHO")})
	aadd(aOption, {"X3_DECIMAL", 0})
	aadd(aOption, {"X3_VALID"  , "u_vldCodBarras()"})
	aadd(aOption, {"X3_OBRIGAT", .T.})
	aadd(aOption, {"X3_F3"     , "ZZH6"})
	
	oUtilMVC:addFieldFromX3(@oForm,"","ZZCODBAR",aOption,.t.)
	aOption := {}

	aAux :=  FwStruTrigger(;
	"H6_ZZMULTP" ,; // Campo Dominio
	"H6_ZQTPRO2" ,; // Campo de Contradominio
	"u_getPesoProd()",; // Regra de Preenchimento
	.f. ,; // Se posicionara ou nao antes da execucao do gatilhos
	nil ,; // Alias da tabela a ser posicionada
	nil ,; // Ordem da tabela a ser posicionada
	nil ,; // Chave de busca da tabela a ser posicionada
	NIL ,; // Condicao para execucao do gatilho
	"01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)

	oForm:AddTrigger( ;
	aAux[1] , ;       // [01] Id do campo de origem
	aAux[2] , ;       // [02] Id do campo de destino
	aAux[3] , ;       // [03] Bloco de codigo de validação da execução do gatilho
	aAux[4] )       // [04] Bloco de codigo de execução do gatilho

	oModel:AddFields(cIdModelForm, /*cOwner*/, oForm)
	oModel:getModel(cIdModelForm):setOnlyQuery(.t.)
	oModel:GetModel(cIdModelForm):SetDescription(cFormTitulo)
	oModel:SetDescription(cModelTitulo)
	oModel:InstallEvent("APCODBARGRV", /*cOwner*/, oEvent)
	oModel:SetPrimaryKey({})
Return oModel

Static Function ViewDef()
	local cAliasForm 	:= ALIAS_FORM
	local cIdModelForm	:= ID_MODEL_FORM
	local cIdViewForm	:= ID_VIEW_FORM
	local cFormTitulo	:= TITULO_FORM
	local cModelTitulo	:= TITULO_MODEL
	local cIdModelo		:= MODELO
	local oModel 		:= FWLoadModel(cIdModelo)
	local cFieldsForm	:= FIELDS_FORM
	local oForm 		:= FWFormStruct(2, cAliasForm,{|cCampo|  alltrim(cCampo) + '|' $ cFieldsForm })
	local oView			:= nil
	local aOption		:= nil
	local oUtilMVC		:= IPUtilMVC():new()
	local xValid		:= nil
	local aOption		:= {}
	local aSeq			:= {}
	local cSeq			:= ""
	local nSeq			:= 0

	oForm 		:= FWFormStruct(2, cAliasForm,{|cCampo|  alltrim(cCampo) + '|' $ cFieldsForm })
	aAdd(aOption,{"X3_TITULO"	,"Cód. Barras"})
	aAdd(aOption,{"X3_DESCRIC"	,"Cód. Barras"})
	aAdd(aOption,{"X3_ORDEM"	,"01"})
	aAdd(aOption,{"X3_CONTEXT"	,.t.})
	aAdd(aOption,{"X3_TIPO",	"C"})
	aAdd(aOption,{"X3_TAMANHO",	getSX3Cache("H6_OP","X3_TAMANHO")+getSX3Cache("H6_IDENT","X3_TAMANHO")})
	aAdd(aOption,{"X3_DECIMAL",	0})
	aAdd(aOption,{"X3_F3",	"ZZH6"})
	//aAdd(aOption,{"X3_VISUAL",	.t.})
	oUtilMVC:addFieldFromX3(@oForm,"","ZZCODBAR",aOption,.f.)
	aOption := {}

	aAdd(aSeq,"H6_ZQTPRO2")
	aAdd(aSeq,"H6_ZZMULTP")
	aAdd(aSeq,"H6_ZZOPER")
	aAdd(aSeq,"H6_QTDPROD")
	aAdd(aSeq,"H6_PRODUTO")
	aAdd(aSeq,"H6_ZDESCRI")
	aAdd(aSeq,"H6_OP")
	cSeq := "01"

	for nSeq := 1 to len(aSeq)
		cSeq := soma1(cSeq)
		oForm:SetProperty( aSeq[nSeq] , MVC_VIEW_ORDEM,cSeq)
	next nSeq

	oForm:setProperty("*",MVC_VIEW_FOLDER_NUMBER,"1")

	oView := FWFormView():New()
	oView:showInsertMsg(.f.)
	oView:SetCloseOnOk({||closeOnOk()})
	oView:SetAfterOkButton({|oView|afterOkBtn(oView)})
	oView:SetModel( oModel )
	oView:AddField(cIdViewForm, oForm, cIdModelForm)
	oView:CreateHorizontalBox( 'Box1' , 100 )
	oView:SetOwnerView( cIdViewForm , 'Box1' )
Return oView

static function closeOnOk()
	local lRet := .f.
return lRet

static function afterOkBtn(oView)
	oView:refresh(ID_VIEW_FORM)
return

user function IncApCodBar()
	SetKey (VK_F9,{|| pressBtnOK()})

	FWExecView("INCLUIR - Apontamento de Produção Codigo de Barras","APCODBAR", 3,, { || .T.})

	SetKey (VK_F9,nil)
return

static function pressBtnOK()
	local oView := FwViewActive()

	oView:ButtonOkAction()
return

user function vldMultiplicidade()
	local nQtdMultiplo 	:= fwFldGet("H6_ZZMULTP")
	local cCodBar 		:= alltrim(FwFldGet("ZZCODBAR")) 
	local cIdent		:= Right(cCodBar,getSX3Cache("H6_IDENT","X3_TAMANHO"))
	local cOP			:= subStr(cCodBar,1,len(cCodBar)-len(cIdent))
	local lRet			:= .t.
	local cAlias		:= u_qryTotApont02(cIdent,cOP)

	if nQtdMultiplo * (cAlias)->B1_QE > (cAlias)->(QTD_APONT01-TOTAL_OPER02)
		nQtdPermitida :=  (cAlias)->(QTD_APONT01-TOTAL_OPER02) / (cAlias)->B1_QE
		lRet := .f.
		u_myHelp("O saldo a ser apontado é de <b>" + cValToChar(nQtdPermitida) + "</b>","Digite uma quantidade menor ou igual a <b>" + cValToChar(nQtdPermitida) + "</b>")
	endif

	(cAlias)->(dbCloseArea())
return lRet

user function getPesoProd()
	local nPeso := 0
	local cCodBar 		:= alltrim(FwFldGet("ZZCODBAR")) 
	local cIdent		:= Right(cCodBar,getSX3Cache("H6_IDENT","X3_TAMANHO"))
	local cOP			:= subStr(cCodBar,1,len(cCodBar)-len(cIdent))
	local cAlias		:= u_qryTotApont02(cIdent,cOP)
	local nQtdProd		:= FwFldGet("H6_QTDPROD")

	nPeso := (cAlias)->(H6_ZQTPRO2/H6_QTDPROD) * nQtdProd

return nPeso

user function qryTotApont02(cIdent,cOP)
	local cQuery := ""

	cQuery += "SELECT" + CRLF
	cQuery += "	SH6.H6_QTDPROD AS QTD_APONT01," + CRLF
	cQuery += "	ULTH6.TOTAL_OPER02," + CRLF
	cQuery += "	SH6.H6_IDENT," + CRLF
	cQuery += "	SH6.H6_QTDPROD," + CRLF
	cQuery += "	SH6.H6_ZQTPRO2," + CRLF
	cQuery += "	SH6.H6_ZZREVIS," + CRLF
	cQuery += "	B1_QE," + CRLF
	cQuery += "	C2_QUANT-C2_QUJE AS SALDO_OP," + CRLF
	cQuery += "	C2_QUANT," + CRLF
	cQuery += "	SH6.R_E_C_N_O_ AS RECSH6" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SH6") + CRLF

	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("SB1") + CRLF
	cQuery += "ON" + CRLF
	cQuery += "	1 = 1" + CRLF
	cQuery += "	AND " + retSqlFil("SB1") + CRLF
	cQuery += "	AND B1_COD = SH6.H6_PRODUTO" + CRLF
	cQuery += "	AND " + retSqlDel("SB1") + CRLF

	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("SC2") + CRLF
	cQuery += "ON" + CRLF
	cQuery += "	1 = 1" + CRLF
	cQuery += "	AND " + retSqlFil("SC2") + CRLF
	cQuery += "	AND C2_NUM+C2_ITEM+C2_SEQUEN = SH6.H6_OP" + CRLF
	cQuery += "	AND " + retSqlDel("SC2") + CRLF

	cQuery += "LEFT JOIN" + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT" + CRLF
	cQuery += "	H6_FILIAL," + CRLF
	cQuery += "	H6_OP," + CRLF
	cQuery += "	SUM(H6_QTDPROD) AS TOTAL_OPER02" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SH6") + CRLF
	cQuery += "WHERE 1=1" + CRLF
	if !empty(cIdent)
		cQuery += "	AND H6_ZZIDENT = '" + cIdent + "'" + CRLF
	endif
	cQuery += "	AND H6_OPERAC = '02'
	cQuery += "	AND " + retSqlDel("SH6") + CRLF
	cQuery += "GROUP BY" + CRLF
	cQuery += "	H6_FILIAL," + CRLF
	cQuery += "	H6_OP" + CRLF
	cQuery += ") ULTH6 ON 1=1" + CRLF
	cQuery += "	AND ULTH6.H6_FILIAL = SH6.H6_FILIAL" + CRLF
	cQuery += "	AND ULTH6.H6_OP = SH6.H6_OP" + CRLF

	cQuery += "WHERE" + CRLF
	cQuery += "	1 = 1" + CRLF
	cQuery += "	AND SH6." + retSqlFil("SH6") + CRLF
	cQuery += "	AND SH6.H6_OP = '" + cOP + "'" + CRLF
	if !empty(cIdent)
		cQuery += "	AND SH6.H6_IDENT = '" + cIdent + "'" + CRLF
	endif
	cQuery += "	AND " + retSqlDel("SH6") + CRLF

	memowrite("\sql\APCodBar_qryTotApont02.sql",cQuery)

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	TcSetField(cAlias,"H6_ZZREVIS","L",1,0)
return cAlias
