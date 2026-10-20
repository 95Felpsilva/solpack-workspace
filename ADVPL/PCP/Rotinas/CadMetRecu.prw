#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CADMETRECU

Cadastro MVC de Cadastro de Metas por Recurso

@author     Solon Thomas - Solpack
@since      02/09/2025
@version    1.0
/*/
//-------------------------------------------------------------------

/*User Function Principal*/
User Function CADMETRECU()

    Local oBrowse := FwLoadBrw("CADMETRECU")

    oBrowse:Activate()

Return  (NIL)


Static Function BrowseDef()

    Local oBrowse := FwmBrowse():New()

    oBrowse:SetAlias("ZH1")
    oBrowse:SetDescription("Cadastro de Metas por Recurso")

    //oBrowse:SetOnlyField({"","",""})

    //oBrowse:DisableDetails()

    oBrowse:SetMenuDef("CADMETRECU")

Return (oBrowse)


Static Function MenuDef()

    Local aMenu := {}

    ADD OPTION aMenu TITLE 'Pesquisar' 	ACTION 'PesqBrw' 		    OPERATION 1 ACCESS 0
    ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.CADMETRECU' OPERATION 2 ACCESS 0
    ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.CADMETRECU' OPERATION 3 ACCESS 0
    ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.CADMETRECU' OPERATION 4 ACCESS 0
    ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.CADMETRECU' OPERATION 5 ACCESS 0
    ADD OPTION aMenu TITLE 'Imprimir' 	ACTION 'VIEWDEF.CADMETRECU' OPERATION 8 ACCESS 0

Return (aMenu)


static function ModelDef()

    local oModel as object
    local oStruct as object

    oModel := MPFormModel():New( "MODEL_ZH1", /*bPre*/ , /*bPos*/, /*bCommit*/, /*bCancel*/ )

    oStruct := FwFormStruct( 1, "ZH1", /*bFiltro*/ )

    oModel:AddFields( "FIELDS_ZH1", /*Owner*/ , oStruct, /*bPre*/ , /*bPos*/ , /*bLoad*/ )

    oModel:SetPrimaryKey({'ZH1_FILIAL'})

return (oModel)


static function ViewDef()

    local oView as object
    local oStruct as object
    local oModel as object

    oView := FwFormView():New()
    oModel := FwLoadModel("CADMETRECU")
    oStruct := FwFormStruct( 2, "ZH1", /*bFiltro*/ )

    oView:SetModel(oModel)
    oView:AddField( "VIEW_ZH1", oStruct, "FIELDS_ZH1" )

return (oView)
