#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDEF.CH'

#Define ALIAS_FORM		"SZ6"
#Define MODELO			"CadGNREDePara"
#Define ID_MODELO		"CadMGNREDePara"
#Define TITULO_MODEL 	"Cadastro De/Para GNRE"
#Define TITULO_FORM		TITULO_MODEL
#Define TITULO_VIEW 	TITULO_MODEL
#Define ID_MODEL_FORM	"MODEL_FORM_" + ALIAS_FORM
#Define ID_VIEW_FORM	"VIEW_FORM_" + ALIAS_FORM

/*/{Protheus.doc} CadGNREDePara
Cadastro De/Para GNRE
@author Tiago Faria
@since 10/11/2021
@version undefined
@type function
/*/
user function CadGNREDePara()
	local 	cModelo 	:= MODELO
	local 	cTitle		:= TITULO_MODEL
	local	cAliasForm	:= ALIAS_FORM
	Local 	oBrowse 	:= FWMBrowse():New()

	oBrowse:SetAlias(cAliasForm)
	oBrowse:setMenuDef(cModelo)
	oBrowse:SetDescription(cTitle)
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
	local cIdModelForm	:= ID_MODEL_FORM
	local cFormTitulo	:= TITULO_FORM
	local cModelTitulo	:= TITULO_MODEL
	local cIdModelo		:= ID_MODELO
	Local oForm 		:= FWFormStruct(1, cAliasForm)
	Local oModel		:= nil

	oModel := MPFormModel():New(cIdModelo,,,)
	oModel:AddFields(cIdModelForm, /*cOwner*/, oForm)
	oModel:GetModel(cIdModelForm):SetDescription(cFormTitulo)
	oModel:SetDescription(cModelTitulo)
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
	local oForm 		:= FWFormStruct(2, cAliasForm)
	local oView			:= nil

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField(cIdViewForm, oForm, cIdModelForm)
	oView:CreateHorizontalBox( 'Box1' , 100 )
	oView:SetOwnerView( cIdViewForm , 'Box1' )
Return oView
