#Include "Totvs.ch"
#Include "FWMVCDef.ch"

//Variveis Estaticas
Static cTitulo    := "Setor x Turno x Media RPM"
Static cCamposChv := "ZPM_SETOR ;ZPM_TURNO;"
Static cTabPai    := "ZPM"

/*/{Protheus.doc} User Function MEDRPM
Media de RPM
@author Solon
@since 02/07/2024
@version 1.0
@type function
/*/

User Function MEDRPM()
	Local aArea   := FWGetArea()
	Local oBrowse
	Private aRotina := {}

	//Definicao do menu
	aRotina := MenuDef()

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cTabPai)
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails()

	//Ativa a Browse
	oBrowse:Activate()

	FWRestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao MEDRPM
/*/

Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.MEDRPM" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.MEDRPM" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.MEDRPM" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.MEDRPM" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Copiar" ACTION "VIEWDEF.MEDRPM" OPERATION 9 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao MEDRPM
/*/

Static Function ModelDef()
	Local oStruPai   := FWFormStruct(1, cTabPai, {|cCampo| Alltrim(cCampo) $ cCamposChv})
	Local oStruFilho := FWFormStruct(1, cTabPai)
	Local aRelation := {}
	Local oModel
	Local bPre := Nil
	Local bPos := Nil
	Local bCancel := Nil


	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("MEDRPMM", bPre, bPos, /*bCommit*/, bCancel)
	oModel:AddFields("ZPMMASTER", /*cOwner*/, oStruPai)
	oModel:AddGrid("ZPMDETAIL","ZPMMASTER",oStruFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	//oModel:SetDescription("Modelo de dados - " + cTitulo)
	oModel:GetModel("ZPMMASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:GetModel("ZPMDETAIL"):SetDescription( "Grid de - " + cTitulo)
	oModel:SetPrimaryKey({})

	//Fazendo o relacionamento
	aAdd(aRelation, {"ZPM_FILIAL", "FWxFilial('ZPM')"} )
	aAdd(aRelation, {"ZPM_SETOR", "ZPM_SETOR"})
	aAdd(aRelation, {"ZPM_TURNO", "ZPM_TURNO"})
	oModel:SetRelation("ZPMDETAIL", aRelation, ZPM->(IndexKey(1)))

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao MEDRPM
/*/

Static Function ViewDef()
	Local oModel     := FWLoadModel("MEDRPM")
	Local oStruPai   := FWFormStruct(2, cTabPai, {|cCampo| Alltrim(cCampo) $ cCamposChv})
	Local oStruFilho := FWFormStruct(2, cTabPai, {|cCampo| ! Alltrim(cCampo) $ cCamposChv})
	Local oView

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ZPM", oStruPai, "ZPMMASTER")
	oView:AddGrid("GRID_ZPM",  oStruFilho,  "ZPMDETAIL")

	//Partes da tela
	oView:CreateHorizontalBox("CABEC", 30)
	oView:CreateHorizontalBox("GRID", 70)
	oView:SetOwnerView("VIEW_ZPM", "CABEC")
	oView:SetOwnerView("GRID_ZPM", "GRID")

	//Titulos
	oView:EnableTitleView("VIEW_ZPM", "Setor x Turno")
	oView:EnableTitleView("GRID_ZPM", "Máquina x Media RPM")

Return oView
