#include 'Protheus.ch'
#include 'Parmtype.ch'
#include 'FWMVCDEF.CH'
#include 'TopConn.ch'

#define ALIAS_FORM						"SZ5"
#define ALIAS_GRID_A					"SZ5"

#define MODELO							"ApPerdaApara"
#define ID_MODELO						"ApMPerdaApara"

#define TITULO_MODEL 					"Apontamento de Perda/Apara"
#define TITULO_FORM						"Apontamento de Perda/Apara"
#define TITULO_GRID_A					"Apontamentos"
#define TITULO_VIEW 					TITULO_MODEL

#define ID_MODEL_FORM					"MODEL_FORM_" + ALIAS_FORM
#define ID_VIEW_FORM					"VIEW_FORM_" + ALIAS_FORM

#define ID_MODEL_GRID_A					"MODEL_GRID" + ALIAS_GRID_A
#define ID_VIEW_GRID_A					"VIEW_GRID_" + ALIAS_GRID_A

#define FIELD_ITEM						""

#define FIELDS_FORM						"Z5_CTRAB|Z5_ZZTURNO|Z5_DATA|Z5_HORA|Z5_USER|"
#define FIELDS_GRID_A					"Z5_RECURSO|Z5_DESCRI|Z5_OP|Z5_COMP|Z5_REFILE|Z5_PERDA|Z5_BOBINA|Z5_REJEITO|Z5_TIPO|Z5_MOTIVO|Z5_OBSERR|Z5_STATREF|Z5_STATPER|Z5_STATBOB|Z5_STATREJ|"

#define PERCENTUAL_TELA_FORM			20
#define PERCENTUAL_TELA_GRID_A			80

#define RELACAO_FORM_X_GRID_A			{{'Z5_FILIAL','xFilial("SH1")'}}
#define INDICE_RELACAO_FORM_X_GRID_A	SZ5->(IndexKey(1))


static nPosID       := 1
static nPosOP       := 2
static nPosRecurso  := 3
static nPosQtd      := 4
static nPosLine     := 5
static nPosApara    := 6
static nPosMotivo   := 7
static nPosTipo     := 8

/*/{Protheus.doc} ApPerdaApara
    Tela responsável por realizar o apontamento de Perda e ou Apara de acordo com os dados preenchidos.
    @type  User Function
    @author user
    @since 04/06/2020
    @version version
    @return nil
    /*/
user function ApPerdaApara()
	FWExecView('Apontamento Perda/Apara','APPERDAAPARA', 3,, { || .T.},,,)
return nil
/*
Definicoes do menu
Autor: Tiago Faria
Data: 04/06/2020
*/
static function MenuDef()
	Local aRotina := {}
	local cModelo := MODELO

	//ADD OPTION aRotina Title 'Visualizar'	Action 'VIEWDEF.'+cModelo OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'		Action 'VIEWDEF.'+cModelo OPERATION 3 ACCESS 0
	//ADD OPTION aRotina Title 'Alterar'		Action 'VIEWDEF.'+cModelo OPERATION 4 ACCESS 0
	//ADD OPTION aRotina Title 'Excluir'		Action 'VIEWDEF.'+cModelo OPERATION 5 ACCESS 0
	//ADD OPTION aRotina Title 'Copiar'     	Action 'VIEWDEF.'+cModelo OPERATION 9 ACCESS 0

return aRotina
/*
Definicoes do model
Autor: Tiago Faria
Data: 04/06/2020
*/
static function ModelDef()
	local cAliasForm 	:= ALIAS_FORM
	local cAAliasGrid 	:= ALIAS_GRID_A

	local cIdModelForm	:= ID_MODEL_FORM
	local cAIdModelGrid	:= ID_MODEL_GRID_A

	local cFormTitulo	:= TITULO_FORM
	local cAGridTitulo	:= TITULO_GRID_A

	local cModelTitulo	:= TITULO_MODEL
	local cIdModelo		:= ID_MODELO

	local cFieldsEnch	:= FIELDS_FORM
	local cAFieldsGrid	:= FIELDS_GRID_A

	local oForm 		:= FWFormStruct(1 ,cAliasForm 	, {|cCampo| if(!empty(cFieldsEnch),alltrim(cCampo) + '|' $ cFieldsEnch,.t.)})
	local oAGrid 		:= FWFormStruct(1 ,cAAliasGrid 	, {|cCampo| if(!empty(cAFieldsGrid),alltrim(cCampo) + '|' $ cAFieldsGrid,.t.)})

	local oModel		:= nil

	local aARelation	:= RELACAO_FORM_X_GRID_A
	local cAKeyIndice	:= INDICE_RELACAO_FORM_X_GRID_A

	local bPosValidacao	:= {|oModel| tudoOK(oModel)}
	local bLinhaOK      := {|oModel|linhaOK(oModel)}

	oModel := MPFormModel():New(cIdModelo ,/*bPreValidacao*/ ,bPosValidacao ,/*bCommit*/ {|oModel| commit(oModel)} ,/*bCancel*/)
	oModel:AddFields(cIdModelForm ,/*cOwner*/ ,oForm)

	oModel:AddGrid(cAIdModelGrid ,cIdModelForm ,oAGrid ,,bLinhaOK)
	oModel:SetRelation(cAIdModelGrid ,aARelation ,cAKeyIndice)

	oModel:GetModel(cIdModelForm):SetDescription(cFormTitulo)
	oModel:GetModel(cAIdModelGrid):SetDescription(cAGridTitulo)

	//oModel:GetModel(cIdModelForm):SetOnlyQuery(.t.)
	//oModel:GetModel(cAIdModelGrid):SetOnlyQuery(.t.)

	oModel:SetDescription(cModelTitulo)
	oModel:SetPrimaryKey({})
Return oModel
/*
Definicoes da view
Autor: Tiago Faria
Data: 04/06/2020
*/
static function ViewDef()
	local cAliasForm 	:= ALIAS_FORM
	local cAAliasGrid 	:= ALIAS_GRID_A

	local cIdModelForm	:= ID_MODEL_FORM
	local cAIdModelGrid	:= ID_MODEL_GRID_A

	local cIdViewForm	:= ID_VIEW_FORM
	local cAIdViewGrid	:= ID_VIEW_GRID_A

	local cFormTitulo	:= TITULO_FORM
	local cAGridTitulo	:= TITULO_GRID_A
	local cModelTitulo	:= TITULO_MODEL

	local cIdModelo		:= MODELO
	local cFieldsEnch	:= FIELDS_FORM
	local cAFieldsGrid	:= FIELDS_GRID_A

	local oModel 		:= FWLoadModel(cIdModelo)
	Local oForm 		:= FWFormStruct(2 ,cAliasForm 	,{|cCampo| if(!empty(cFieldsEnch),alltrim(cCampo) + '|' $ cFieldsEnch,.t.)})
	Local oAGrid 		:= FWFormStruct(2 ,cAAliasGrid 	,{|cCampo| if(!empty(cAFieldsGrid),alltrim(cCampo) + '|' $ cAFieldsGrid,.t.)})

	local oView			:= nil
	local cFieldItem	:= FIELD_ITEM
	local nPerFORM		:= PERCENTUAL_TELA_FORM
	local nPerAGrid		:= PERCENTUAL_TELA_GRID_A

	local oUtilMVC		:= IPUtilMVC():new()

	oUtilMVC:removeFolders(@oForm)
	oUtilMVC:addOtherFields(@oForm,cFieldsEnch,.f.)
	updOrdem(@oForm,cFieldsEnch)

	oUtilMVC:removeFolders(@oAGrid)
	oUtilMVC:addOtherFields(@oAGrid,cAFieldsGrid,.f.)
	updOrdem(@oAGrid,cAFieldsGrid)

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField(cIdViewForm ,oForm ,cIdModelForm)
	oView:AddGrid(cAIdViewGrid ,oAGrid ,cAIdModelGrid)

	if valType(cFieldItem) == "C" .and. !empty(cFieldItem)
		oView:AddIncrementField(cAIdViewGrid ,cFieldItem)
	endif

	oView:CreateHorizontalBox('Box1' ,nPerFORM)
	oView:CreateHorizontalBox('Box2' ,nPerAGrid)

	oView:SetOwnerView(cIdViewForm 	,'Box1')
	oView:SetOwnerView(cAIdViewGrid ,'Box2')
return oView

/*
Atualiza a sequencia dos campos no MVC
*/
static function updOrdem(oStruct,cFields,cSeparator)
	local cField := ""
	local aFields := {}
	local nField := len(aFields)
	local cOrdem := "00"
	default cSeparator := "|"

	aFields := strToKarr(cFields,cSeparator)

	for nField := 1 to len(aFields)
		cField := aFields[nField]
		if oStruct:hasField(cField)
			cOrdem := soma1(cOrdem)
			oStruct:SetProperty(cField,MVC_VIEW_ORDEM,cOrdem)
		endif
	next nField
return

static function tudoOK(oModel)
	local lRet  := .t.
	local oView := FwViewActive()

	FWMsgRun( ,{ || lRet := runEA(oModel) } ,"APPERDAAPARA", "Aguarde Realizado apontamento de Perda/Apara..."  )

	if !lRet
		oView:refresh(ID_VIEW_GRID_A)
		u_myHelp("Erro ao tentar realizar o apontamento de Perda/Apara","Avalie todas as linhas do grid cujo status seja igual a X")
	endif
return lRet

static function runEA(oModel)
	local aDados        := dataCollect(oModel)
	local lRet          := .t.
	local nDados        := 0
	local cID           := ""
	local lRetBkp       := .f.

	if len(aDados) == 0
		lRet := .f.
		u_myHelp("Não foi digitado a quantidade de Refile/Perda/Rejeito para nenhum recurso!")
	endif

	aSort(aDados,,,{|X,Y|X[nPosID] > Y[nPosID]})

	for nDados := 1 to len(aDados)
		cID         := aDados[nDados][1]

		if cID $ "MATA685_COM_PRD_DESTINO/MATA685_COM_PRD_DESTINO_BOB/MATA685_SEM_PRD_DESTINO"
			lRetBkp := runMata685(aDados[nDados])

			if lRet
				lRet := lRetBkp
			endif
		endif

		if cID == "MATA241"
			lRetBkp := runMata241({aDados[nDados]})

			if lRet
				lRet := lRetBkp
			endif
		endif
	next nDados
    /*
    if lRet .and. len(aMata241) > 0
        lRet := runMata241(aDados)
    endif
    */
return lRet

static function runMata685(aDados)
	local lRet             := .t.
	local aCab             := {}
	local aItem            := {}
	local aItens           := {}
	local cOP              := aDados[nPosOP]
	local cRecurso         := aDados[nPosRecurso]
	local nQtd             := aDados[nPosQtd]
	local nLineMVC         := aDados[nPosLine]
	local cApara           := aDados[nPosApara]
	local cMotivo          := aDados[nPosMotivo]
	local cTipo            := aDados[nPosTipo]
	local cProduto         := ""
	local lProdDest        := aDados[nPosID] == "MATA685_COM_PRD_DESTINO"
	local lProdDestBOB     := aDados[nPosID] == "MATA685_COM_PRD_DESTINO_BOB"
	local cCampoErro       := ""
	local cError           := ""
	local cTurno           := FwFldGet("Z5_ZZTURNO")
	private lMsErroAuto    := .f.
	private lAutoErrNoFile := .t.

	if lProdDestBOB
		cCampoErro := "Z5_STATBOB"
	elseif lProdDest
		cCampoErro := "Z5_STATPER"
	else
		cCampoErro := "Z5_STATREJ"
	endif

	cAlias := getDadosPrimeiroNivel(cOP,nQtd)
	cProduto := (cAlias)->(C2_PRODUTO)

	aAdd(aCab,{"BC_OP"         ,cOP                ,NIL})
	aAdd(aCab,{"BC_RECURSO"    ,cRecurso           ,NIL})
	aAdd(aCab,{"BC_PRODUTO"    ,cProduto           ,NIL})

	aCab := FwVetByDic(aCab,"SBC")

	while (cAlias)->(!eof())
		if (cAlias)->(Z5_REFILE) > 0
			aAdd(aItem,{"BC_PRODUTO"    ,(cAlias)->(D4_COD)     ,nil})
			aAdd(aItem,{"BC_LOCORIG"    ,(cAlias)->(D4_LOCAL)   ,nil})
			aAdd(aItem,{"BC_QUANT"      ,(cAlias)->(Z5_REFILE)   ,nil})
			aAdd(aItem,{"BC_QTDDEST"    ,(cAlias)->(Z5_REFILE)   ,nil})
			aAdd(aItem,{"BC_ZZTURNO"    ,cTurno                 ,nil})

			if !empty(cMotivo)
				aAdd(aItem,{"BC_MOTIVO"     ,cMotivo                ,nil})
			endif

			if !empty(cTipo)
				aAdd(aItem,{"BC_TIPO"       ,cTipo                  ,nil})
			endif

			if lProdDest .or. lProdDestBOB
				aAdd(aItem,{"BC_CODDEST"    ,cApara             ,nil})
			endif

			aItem := FwVetByDic(aItem,"SBC")

			aAdd(aItens,aClone(aItem))
			aItem := {}
		endif
		(cAlias)->(dbSkip())
	enddo
	if len(aItens) > 0
		MsExecAuto ( {|x,y,z| MATA685(x,y,z) }, aCab, aItens, 3)
	endif
	if lMserroAuto
		cError := getErroAuto()
		lRet := .f.
	endif

	updStatusLine(nLineMVC,!lMsErroAuto,cError,cCampoErro)
return lRet

static function getDadosPrimeiroNivel(cOP,nQtd)
	local cQuery    := ""
	local cAlias    := ""
	local cApara    := getNewPar("ZZ_APARA","50.20.01.0003")

	cQuery += "SELECT" + CRLF
	cQuery += "	C2_PRODUTO," + CRLF
	cQuery += "	C2_QUANT," + CRLF
	cQuery += "	D4_COD," + CRLF
	cQuery += "	D4_LOCAL," + CRLF
	cQuery += "	ROUND(SUM((D4_QTDEORI / C2_QUANT) * " + cValToChar(nQtd) + ")," + cValToChar(getSX3Cache("Z5_REFILE","X3_DECIMAL")) + ") AS Z5_REFILE," + CRLF
	cQuery += "	ROUND(SUM(CASE " + CRLF
	cQuery += "     WHEN B1_UM = 'KG' THEN (D4_QTDEORI / C2_QUANT) * " + cValToChar(nQtd) + CRLF
	cQuery += "     ELSE ( (D4_QTDEORI / C2_QUANT) * B1_PESO) * " + cValToChar(nQtd) + CRLF
	cQuery += " END)," + cValToChar(getSX3Cache("Z5_REFILE","X3_DECIMAL")) + ") AS Z5_REJEITO," + CRLF
	if empty(cApara)
		cQuery += "	G1_COMP" + CRLF
	else
		cQuery += "'" + cApara + "' AS G1_COMP" + CRLF
	endif
	cQuery += "FROM " + CRLF
	cQuery += "	" + retSqlTab("SC2") + CRLF

	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("SD4") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND D4_FILIAL = C2_FILIAL" + CRLF
	cQuery += "	AND D4_OP = C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD" + CRLF
	cQuery += "	AND D4_QTDEORI > 0" + CRLF
	cQuery += "	AND " + retSqlDel("SD4") + CRLF

	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlTab('SB1') + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + RetSqlFil('SB1') + CRLF
	cQuery += "	AND B1_COD = D4_COD " + CRLF
	cQuery += "	AND ((B1_UM <> 'KG' AND B1_PESO > 0) OR B1_UM = 'KG')" + CRLF
	cQuery += "	AND " + RetSqlDel('SB1') + CRLF

	if empty(cApara)
		cQuery += "INNER JOIN" + CRLF
		cQuery += "	" + retSqlTab("SG1") + CRLF
		cQuery += "ON 1=1" + CRLF
		cQuery += "	AND G1_FILIAL = '    '" + CRLF
		cQuery += "	AND G1_COD = C2_PRODUTO" + CRLF
		cQuery += "	AND G1_QUANT < 0" + CRLF
		cQuery += "	AND " + retSqlDel("SG1") + CRLF
	endif
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD = '" + cOP + "'" + CRLF
	cQuery += "	AND " + retSqlDel("SC2") + CRLF
	cQuery += "GROUP BY " + CRLF
	cQuery += "	C2_PRODUTO," + CRLF
	cQuery += "	C2_QUANT," + CRLF
	cQuery += "	D4_COD," + CRLF
	cQuery += "	D4_LOCAL" + CRLF
	TcQuery cQuery new Alias (cAlias := getNextAlias())
return cAlias

static function runMata241(aDados)
	local lRet      := .t.
	local aAux      := {}
	local aItens    := {}
	local cTurno    := FwFldGet("Z5_ZZTURNO")
	local aCabec    := {}
	local cTM	 	:= getNewPar("ZZ_TMAPARA","130")
	local nLineMVC  := 0
	local oModel    := FwModelActive()
	local oGrid     := oModel:getModel(ID_MODEL_GRID_A)
	local nPosMVC   := 0
	local cError    := ""
	local cRecurso  := ""
	local nDados    := 0
	local nItens    := 0
	private lMsErroAuto := .f.
	private lAutoErrNoFile := .t.

	aAdd(aCabec,{"D3_TM"		,cTM		,nil})
	aAdd(aCabec,{"D3_EMISSAO"	,dDataBase	,nil})

	for nDados := 1 to len(aDados)
		cOP         := aDados[nDados][nPosOP]
		nQtd        := aDados[nDados][nPosQtd]
		nLineMVC    := aDados[nDados][nPosLine]
		cProduto    := aDados[nDados][nPosApara]
		cRecurso    := aDados[nDados][nPosRecurso]
		posicione("SB1",1,xFilial("SB1")+cProduto,"!Eof()")

		aAdd(aAux,{"D3_COD"		,cProduto			,nil})
		aAdd(aAux,{"D3_QUANT"	,nQtd				,nil})
		aAdd(aAux,{"D3_OP"		,cOP    			,nil})
		aAdd(aAux,{"D3_LOCAL"	,SB1->B1_LOCPAD		,nil})
		aAdd(aAux,{"D3_ZZTURNO"	,cTurno    			,nil})
		aAdd(aAux,{"D3_ZZRECUR"	,cRecurso  			,nil})
		aAdd(aAux,{"LINEMVC"	,nLineMVC  			,nil})

		aAux := FwVetByDic(aAux,"SD3")

		aAdd(aItens,aAux)
		aAux := {}

	next aDados
	if len(aItens) > 0
		MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aItens,3)

		if lMsErroAuto
			cError := getErroAuto()
			lRet := .f.
		endif

		for nItens := 1 to len(aItens)
			nPosMVC := aScan(aItens[nItens],{|X|X[1] == "LINEMVC"})

			if nPosMVC > 0
				nPosMVC := aItens[nItens][nPosMVC][2]

				updStatusLine(nPosMVC,!lMsErroAuto,cError,"Z5_STATREF")
			endif
		next nItens
	endif

	oGrid:goLine(1)
return lRet

static function getProdutoApara(cOP)
	local cQuery        := ""
	local cAlias        := ""
	local cApara        := getNewPar("ZZ_APARA","50.20.01.0003")
	//criado parametro pois a Solpack parou de usar multiplos códigos de apara.
	if empty(cApara)
		cQuery += "SELECT" + CRLF
		cQuery += "    TOP 1 G1_COMP AS Z5_COMP" + CRLF
		cQuery += "FROM" + CRLF
		cQuery += "    " + retSqlTab("SC2") + CRLF

		cQuery += "INNER JOIN" + CRLF
		cQuery += "    " + retSqlTab("SG1") + CRLF
		cQuery += "ON 1=1" + CRLF
		cQuery += "    AND " + retSqlFil("SG1") + CRLF
		cQuery += "    AND G1_COD = C2_PRODUTO " + CRLF
		cQuery += "    AND G1_QUANT < 0" + CRLF
		cQuery += "    AND " + retSqlDel("SG1") + CRLF

		cQuery += "WHERE 1=1" + CRLF
		cQuery += "    AND " + retSqlFil("SC2") + CRLF
		cQuery += "    AND C2_NUM+C2_ITEM+C2_SEQUEN = '" + cOP + "' " + CRLF
		cQuery += "    AND " + retSqlDel("SC2") + CRLF

		TcQuery cQuery new Alias (cAlias := getNextAlias())

		cApara := (cAlias)->(Z5_COMP)

		(cAlias)->(dbCloseArea())
	endif
return cApara

static function dataCollect(oModel)
	local oGrid         := oModel:getModel(ID_MODEL_GRID_A)
	local aSaveRows     := FwSaveRows()
	local cOP           :=  ""
	local cRecurso      := ""
	local nQtdRefile    := 0
	local nQtdPerca     := 0
	local nQtdRejeito   := 0
	local aDados        := {}
	local nLine         := 0
	local cApara        := ""
	local cMotivo       := ""
	local cTipo         := ""
	for nLine := 1 to oGrid:length()
		oGrid:goLine(nLine)

		if !oGrid:isDeleted()
			cOP         := FwFldGet("Z5_OP")
			if !empty(cOP)
				posicione("SC2",1,xFilial("SC2")+cOP,"!Eof()")
				cRecurso    := FwFldGet("Z5_RECURSO")
				cApara      := FwFldGet("Z5_COMP")
				nQtdRefile  := FwFldGet("Z5_REFILE")
				nQtdPerca   := getQtd1UM(SC2->C2_PRODUTO,FwFldGet("Z5_PERDA"))
				nQtdBobina  := getQtd1UM(SC2->C2_PRODUTO,FwFldGet("Z5_BOBINA"))
				nQtdRejeito := getQtd1UM(SC2->C2_PRODUTO,FwFldGet("Z5_REJEITO"))
				cMotivo     := FwFldGet("Z5_MOTIVO")
				cTipo       := FwFldGet("Z5_TIPO")

				if nQtdRefile > 0 .and. alltrim(oGrid:getValue("Z5_STATREF")) <> "BR_VERDE"
					aAdd(aDados,{"MATA241",cOP,cRecurso,nQtdRefile,nLine,cApara,"",""})
				endif

				if nQtdPerca > 0 .and. alltrim(oGrid:getValue("Z5_STATPER")) <> "BR_VERDE"
					aAdd(aDados,{"MATA685_COM_PRD_DESTINO",cOP,cRecurso,nQtdPerca,nLine,cApara,cMotivo,cTipo})
				endif

				if nQtdBobina > 0 .and. alltrim(oGrid:getValue("Z5_STATBOB")) <> "BR_VERDE"
					aAdd(aDados,{"MATA685_COM_PRD_DESTINO_BOB",cOP,cRecurso,nQtdBobina,nLine,cApara,cMotivo,cTipo})
				endif

				if nQtdRejeito > 0 .and. alltrim(oGrid:getValue("Z5_STATREJ")) <> "BR_VERDE"
					aAdd(aDados,{"MATA685_SEM_PRD_DESTINO",cOP,cRecurso,nQtdRejeito,nLine,cApara,cMotivo,cTipo})
				endif
			endif

		endif
	next nLinha

	FwRestRows(aSaveRows)
return aDados

user function loadCTrab()
	local cCTrab        := FwFldGet("Z5_CTRAB")
	local cQuery        := ""
	local lRet          := .t.
	local oIPUtilMVC    := IPUtilMVC():new()
	local oModel        := FwModelActive()
	local oGrid         := oModel:getModel(ID_MODEL_GRID_A)
	local oView         := FwViewActive()

	oGrid:ClearData()

	cQuery += "SELECT" + CRLF
	cQuery += "    H1_CODIGO AS Z5_RECURSO," + CRLF
	cQuery += "    H1_DESCRI AS Z5_DESCRI," + CRLF
	cQuery += "    0 AS Z5_REFILE," + CRLF
	cQuery += "    0 AS Z5_REJEITO," + CRLF
	cQuery += "    0 AS Z5_PERDA," + CRLF
	cQuery += "    'BR_BRANCO' AS Z5_STATREF," + CRLF
	cQuery += "    'BR_BRANCO' AS Z5_STATREJ," + CRLF
	cQuery += "    'BR_BRANCO' AS Z5_STATPER," + CRLF
	cQuery += "    'BR_BRANCO' AS Z5_STATBOB," + CRLF
	cQuery += "    '' AS Z5_OBSERR," + CRLF
	cQuery += "    '' AS Z5_OP" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "    " + retSqlTab("SH1") + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "    AND " + retSqlFil("SH1") + CRLF
	cQuery += "    AND H1_CTRAB = '" + cCTrab + "' " + CRLF
	cQuery += "    AND " + retSqlDel("SH1") + CRLF
	cQuery += "ORDER BY H1_DESCRI" + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	oIPUtilMVC:updModel2Qry(cAlias,oGrid)

	(cAlias)->(dbCloseArea())

	oView:refresh(ID_VIEW_GRID_A)
return lRet

static function getErroAuto()
	local aErro := GetAutoGrLog()
	local nErro := 0
	local cErro := ""

	for nErro := 1 to len(aErro)
		cErro += aErro[nErro] + CRLF
	next nErro
return cErro

static function updStatusLine(nLineMVC,lSuccess,cError,cFieldErro)
	local oModel    := FwModelActive()
	local oGrid     := oModel:getModel(ID_MODEL_GRID_A)
	local cLogError := ""
	local cMsg      := ""

	if cFieldErro == "Z5_STATREF"
		cMsg := "Z5_REFILE"
	elseif cFieldErro == "Z5_STATREJ"
		cMsg := "Z5_REJEITO"
	elseif cFieldErro == "Z5_STATPER"
		cMsg := "Z5_PERDA"
	elseif cFieldErro == "Z5_STATBOB"
		cMsg := "Z5_BOBINA"
	endif

	oGrid:goLine(nLineMVC)

	if lSuccess
		oGrid:loadValue(cFieldErro,"BR_VERDE")
	endif

	if !lSuccess
		cLogError += cMsg + replicate("*",50) + CRLF
		cLogError += cError
		cLogError += cMsg + replicate("*",50) + CRLF
		cLogError += oGrid:getValue("Z5_OBSERR")

		oGrid:loadValue(cFieldErro,"BR_CANCEL")
		oGrid:loadValue("Z5_OBSERR",cLogError)
	endif
return

static function getQtd1UM(cProduto,nQtde2SBC)
	local nQtdConv := 0
	nQtdConv := round(convUM(cProduto,0,nQtde2SBC,1),getSX3Cache("Z5_PERDA","X3_DECIMAL"))
	if nQtdConv == 0
		nQtdConv := nQtde2SBC
	endif
return nQtdConv

user function vldOP()
	Local lRet 		:= .T.
	local cOrdemP   := FwFldGet("Z5_OP")
	local cApara    := ""

	SC2->(dbSetorder(1))
	If SC2->(dbSeek(xFilial("SC2")+cOrdemP))
		If !Empty(SC2->C2_DATRF)
			u_myHelp("Acesso negado Ordem de Produção Encerrado(a)")
			lRet := .f.
		EndIf
		If SC2->C2_TPOP == "P"	//Prevista
			Help(" ",1,"NOPPREVIST")
			lRet := .F.
		EndIf
		If lRet .And. FindFunction("A113BlqApo")
			lRet := A113BlqApo(cOrdemP)
		EndIf
	EndIf

	if lRet
		cApara := getProdutoApara(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN))
		if !empty(cApara)
			lRet := FwFldPut("Z5_COMP",cApara)
		endif
	endif
return lRet

user function vldProduto()
	local cProduto  := FwFldGet("Z5_COMP")
	local lRet      := .t.

	if posicione("SB1",1,xFilial("SB1")+cProduto,"!Eof()") .and. !(SB1->B1_TIPO $ getNewPar("ZZ_TPAPARA","SP"))
		u_myHelp("Produto digitado não é uma Apara, digite um produto cujo Tipo seja igual a SP")
		lRet := .f.
	endif
return lRet

static function linhaOK(oModel)
	local lRet := .t.

	if !empty(FwFldGet("Z5_OP")) .and. (FwFldGet("Z5_PERDA") <> 0  .or. FwFldGet("Z5_REFILE") <> 0 ).and. empty(FwFldGet("Z5_COMP"))
		lRet := .f.
		u_myHelp("O campo Cód. Apara é obrigatório, preencha-o para continuar!")
	endif

return lRet

static function commit(oModel)
	local lRet := .t.
	local cQuery := ''

	BEGIN TRANSACTION

		lRet := FWFORMCOMMIT(oModel)
		if lRet
			cQuery += "DELETE" + CRLF
			cQuery += "	" + retSqlName("SZ5") + CRLF
			cQuery += "WHERE 1=1" + CRLF
			cQuery += "	AND Z5_REFILE+Z5_PERDA+Z5_REJEITO = 0" + CRLF
			cQuery += "	AND D_E_L_E_T_ = ' '" + CRLF

			nStatus := TcSqlExec(cQuery)

			if nStatus < 0
				lRet := .f.
				u_myHelp(TcSqlError())
				disarmTransaction()
			endif
		endif

	END TRANSACTION
return lRet
