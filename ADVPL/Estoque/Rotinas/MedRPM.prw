#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDEF.CH'
#include 'TopConn.ch'

#Define ALIAS_FORM						"ZPM"
#Define ALIAS_GRID						"ZPM"
#Define MODELO							"MEDRPM"
#Define ID_MODELO						"MEDIARPM"
#Define TITULO_MODEL 					"Setor x Turno x Media RPM"
#Define TITULO_FORM						"Setor x Turno x Media RPM"
#Define TITULO_GRID						"Maquina X RPM"
#Define TITULO_VIEW 					TITULO_MODEL
#Define ID_MODEL_FORM					"MODEL_FORM_" + ALIAS_FORM
#Define ID_VIEW_FORM					"VIEW_FORM_" + ALIAS_FORM
#Define ID_MODEL_GRID					"MODEL_GRID_" + ALIAS_GRID
#Define ID_VIEW_GRID					"VIEW_GRID_" + ALIAS_GRID
#Define FIELD_ITEM						""
#Define FIELDS_FORM						"ZPM_FILIAL|ZPM_SETOR|ZPM_TURNO|ZPM_DESCTU|"
#Define PERCENTUAL_TELA_FORM			20
#Define PERCENTUAL_TELA_GRID			100-PERCENTUAL_TELA_FORM
#Define RELACAO_FORM_X_GRID				{{'ZPM_FILIAL','xFilial("ZPM")'},{'ZPM_SETOR','ZPM_SETOR'},{'ZPM_TURNO','ZPM_TURNO'},{'ZPM_DESCTU','ZPM_DESCTU'}}
#Define INDICE_RELACAO_FORM_X_GRID		ZPM->(IndexKey(1))
#Define UNIQUE_LINE						"ZPM_RECUR/"
#Define FILTER_DEFAULT					getFilterSQL()

/*/{Protheus.doc} User Function MEDRPM
Setor x Turno x Media RPM
@author Solon
@since 02/07/2024
@version 1.0
@type function
/*/

user function MEDRPM()
	local 	cModelo 	:= MODELO
	local 	cTitle		:= TITULO_MODEL
	local	cAliasForm	:= ALIAS_FORM
	Local 	oBrowse 	:= FWMBrowse():New()
	Local 	cFilterSQL	:= FILTER_DEFAULT

	oBrowse:SetAlias(cAliasForm)
	oBrowse:setMenuDef(cModelo)
	oBrowse:SetDescription(cTitle)
	if !empty(cFilterSQL)
		oBrowse:SetFilterDefault(cFilterSQL)
	endif
	oBrowse:Activate()
return

Static Function MenuDef()
	Local aRotina := {}
	local cModelo := MODELO

	ADD OPTION aRotina Title 'Visualizar'	Action 'VIEWDEF.'+cModelo OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'		Action 'VIEWDEF.'+cModelo OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'		Action 'VIEWDEF.'+cModelo OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'		Action 'VIEWDEF.'+cModelo OPERATION 5 ACCESS 0
Return aRotina

Static Function ModelDef()
	local cAliasForm 	:= ALIAS_FORM
	local cAliasGrid 	:= ALIAS_GRID
	local cIdModelForm	:= ID_MODEL_FORM
	local cIdModelGrid	:= ID_MODEL_GRID
	local cFormTitulo	:= TITULO_FORM
	local cGridTitulo	:= TITULO_GRID
	local cModelTitulo	:= TITULO_MODEL
	local cIdModelo		:= ID_MODELO
	local cFieldsEnch	:= FIELDS_FORM
	local oForm 		:= FWFormStruct(1, cAliasForm,{|cCampo|  alltrim(cCampo) + '|' $ cFieldsEnch })
	local oGrid 		:= FWFormStruct(1, cAliasForm,{|cCampo| !alltrim(cCampo) + '|' $ cFieldsEnch })
	local oModel		:= nil
	local aRelation		:= RELACAO_FORM_X_GRID
	local cKeyIndice	:= INDICE_RELACAO_FORM_X_GRID
	local bLinePre		:= {|oModelGrid, nLinha, cAcao, cCampo|linePre(oModelGrid, nLinha, cAcao, cCampo)}
	local aUniqueLine	:= strToKarr(UNIQUE_LINE,"/")

	oModel := MPFormModel():New(cIdModelo,,,)
	oModel:AddFields(cIdModelForm, /*cOwner*/, oForm)
	oModel:AddGrid( cIdModelGrid, cIdModelForm, oGrid, bLinePre )
	oModel:SetRelation( cIdModelGrid, aRelation , cKeyIndice )
	oModel:GetModel(cIdModelForm):SetDescription(cFormTitulo)
	oModel:GetModel(cIdModelGrid):SetDescription(cGridTitulo)
	if valType(aUniqueLine) == "A" .and. len(aUniqueLine) > 0
		oModel:GetModel(cIdModelGrid):SetUniqueLine(aUniqueLine)
	endif
	oModel:SetDescription(cModelTitulo)
	oModel:SetPrimaryKey({})
Return oModel

Static Function ViewDef()
	local cAliasForm 	:= ALIAS_FORM
	local cAliasGrid 	:= ALIAS_GRID
	local cIdModelForm	:= ID_MODEL_FORM
	local cIdModelGrid	:= ID_MODEL_GRID
	local cIdViewForm	:= ID_VIEW_FORM
	local cIdViewGrid	:= ID_VIEW_GRID
	local cFormTitulo	:= TITULO_FORM
	local cGridTitulo	:= TITULO_GRID
	local cModelTitulo	:= TITULO_MODEL
	local cIdModelo		:= MODELO
	local cFieldsEnch	:= FIELDS_FORM
	local oModel 		:= FWLoadModel(cIdModelo)
	Local oForm 		:= FWFormStruct(2, cAliasForm,{|cCampo|  alltrim(cCampo) + '|' $ cFieldsEnch })
	Local oGrid 		:= FWFormStruct(2, cAliasForm,{|cCampo| !alltrim(cCampo) + '|' $ cFieldsEnch })
	local oView			:= nil
	local cFieldItem	:= FIELD_ITEM
	local nPerFORM		:= PERCENTUAL_TELA_FORM
	local nPerGrid		:= PERCENTUAL_TELA_GRID

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField(cIdViewForm, oForm, cIdModelForm)
	oView:AddGrid( cIdViewGrid, oGrid, cIdModelGrid)
	if valType(cFieldItem) == "C" .and. !empty(cFieldItem)
		oView:AddIncrementField( cIdViewGrid, cFieldItem )
	endif
	oView:CreateHorizontalBox( 'Box1' , nPerFORM 		)
	oView:CreateHorizontalBox( 'Box2' , nPerGrid 		)

	oView:SetOwnerView( cIdViewForm , 'Box1' )
	oView:SetOwnerView( cIdViewGrid , 'Box2' )
Return oView

// Pré-validacao de linha

static function linePre(oModelGrid, nLinha, cAcao, cCampo)
	local lRet 			:= .t.
	local cMsg			:= ""
	local nOperation 	:= oModelGrid:getOperation()

return lRet

static function getFilterSQL()
	local cFilter := ""
	cFilter += "@ R_E_C_N_O_ IN (" + CRLF
	cFilter += "	SELECT" + CRLF
	cFilter += "		MAX(ZPM.R_E_C_N_O_)" + CRLF
	cFilter += "	FROM" + CRLF
	cFilter += "		" + retSqlTab("ZPM") + CRLF
	cFilter += "	WHERE 1=1" + CRLF
	cFilter += "		AND " + retSqlFil("ZPM") + CRLF
	cFilter += "		AND " + retSqlDel("ZPM") + CRLF
	cFilter += "	GROUP BY ZPM_SETOR, ZPM_TURNO" + CRLF
	cFilter += ")" + CRLF
return cFilter
