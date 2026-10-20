#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CADMETAFAT

Cadastro MVC de Cadastro de Metas de Faturamento

@author     Solon Thomas - Solpack
@since      08/02/2025
@version    1.0
/*/
//-------------------------------------------------------------------

/User Function Principal/
User Function CADMETAFAT()

    Local oBrowse := FwLoadBrw("CADMETAFAT")

    oBrowse:Activate()

Return  (NIL)


Static Function BrowseDef()

    Local oBrowse := FwmBrowse():New()

    oBrowse:SetAlias("ZMF")
    oBrowse:SetDescription("Cadastro de Metas de Faturamento")

    //oBrowse:SetOnlyField({"","",""})

    //oBrowse:DisableDetails()

    oBrowse:SetMenuDef("CADMETAFAT")

Return (oBrowse)


Static Function MenuDef()

    Local aMenu := {}

    ADD OPTION aMenu TITLE 'Pesquisar' 	ACTION 'PesqBrw' 		    OPERATION 1 ACCESS 0
    ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.CADMETAFAT' OPERATION 2 ACCESS 0
    ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.CADMETAFAT' OPERATION 3 ACCESS 0
    ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.CADMETAFAT' OPERATION 4 ACCESS 0
    ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.CADMETAFAT' OPERATION 5 ACCESS 0
    ADD OPTION aMenu TITLE 'Imprimir' 	ACTION 'VIEWDEF.CADMETAFAT' OPERATION 8 ACCESS 0

Return (aMenu)


static function ModelDef()

    local oModel as object
    local oStruct as object

    oModel := MPFormModel():New( "MODEL_ZMF", /bPre/ , /bPos/, /bCommit/, /bCancel/ )

    oStruct := FwFormStruct( 1, "ZMF", /bFiltro/ )

    oModel:AddFields( "FIELDS_ZMF", /Owner/ , oStruct, /bPre/ , /bPos/ , /bLoad/ )

    oModel:SetPrimaryKey({'ZMF_FILIAL'})

return (oModel)


static function ViewDef()

    local oView as object
    local oStruct as object
    local oModel as object

    oView := FwFormView():New()
    oModel := FwLoadModel("CADMETAFAT")
    oStruct := FwFormStruct( 2, "ZMF", /bFiltro/ )

    oView:SetModel(oModel)
    oView:AddField( "VIEW_ZMF", oStruct, "FIELDS_ZMF" )

return (oView)