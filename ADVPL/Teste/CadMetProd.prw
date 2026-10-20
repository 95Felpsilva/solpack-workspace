#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CADMETPROD

Cadastro MVC de Cadastro de Metas de Produção

@author     Solon Thomas - Solpack
@since      16/10/2023
@version    1.0
/*/
//-------------------------------------------------------------------

/*User Function Principal*/
User Function CADMETPROD()

    Local oBrowse := FwLoadBrw("CADMETPROD")

    oBrowse:Activate()

Return  (NIL)


Static Function BrowseDef()

    Local oBrowse := FwmBrowse():New()

    oBrowse:SetAlias("ZMP")
    oBrowse:SetDescription("Cadastro de Metas de Produção")

    //oBrowse:SetOnlyField({"","",""})

    //oBrowse:DisableDetails()

    oBrowse:SetMenuDef("CADMETPROD")

Return (oBrowse)


Static Function MenuDef()

    Local aMenu := {}

    ADD OPTION aMenu TITLE 'Pesquisar' 	ACTION 'PesqBrw' 		    OPERATION 1 ACCESS 0
    ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.CADMETPROD' OPERATION 2 ACCESS 0
    ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.CADMETPROD' OPERATION 3 ACCESS 0
    ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.CADMETPROD' OPERATION 4 ACCESS 0
    ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.CADMETPROD' OPERATION 5 ACCESS 0
    ADD OPTION aMenu TITLE 'Imprimir' 	ACTION 'VIEWDEF.CADMETPROD' OPERATION 8 ACCESS 0

Return (aMenu)


static function ModelDef()

    local oModel as object
    local oStruct as object

    oModel := MPFormModel():New( "MODEL_ZMP", /*bPre*/ , /*bPos*/, /*bCommit*/, /*bCancel*/ )

    oStruct := FwFormStruct( 1, "ZMP", /*bFiltro*/ )

    oModel:AddFields( "FIELDS_ZMP", /*Owner*/ , oStruct, /*bPre*/ , /*bPos*/ , /*bLoad*/ )

    oModel:SetPrimaryKey({'ZMP_FILIAL'})

return (oModel)


static function ViewDef()

    local oView as object
    local oStruct as object
    local oModel as object

    oView := FwFormView():New()
    oModel := FwLoadModel("CADMETPROD")
    oStruct := FwFormStruct( 2, "ZMP", /*bFiltro*/ )

    oView:SetModel(oModel)
    oView:AddField( "VIEW_ZMP", oStruct, "FIELDS_ZMP" )

return (oView)
