#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} SALDBANCDIA

Cadastro MVC de Saldo Bancario Diario

@author     Solon Thomas - Solpack
@since      02/05/2024
@version    1.0
/*/
//-------------------------------------------------------------------

/*User Function Principal*/
User Function SALDBANCDIA()

    Local oBrowse := FwLoadBrw("SALDBANCDIA")

    oBrowse:Activate()

Return  (NIL)

Static Function BrowseDef()

    Local oBrowse := FwmBrowse():New()

    oBrowse:SetAlias("ZSB")
    oBrowse:SetDescription("Saldo Bancario Diario")

    //oBrowse:SetOnlyField({"","",""})

    //oBrowse:DisableDetails()

    oBrowse:SetMenuDef("SALDBANCDIA")

Return (oBrowse)

Static Function MenuDef()

    Local aMenu := {}

    ADD OPTION aMenu TITLE 'Pesquisar' 	ACTION 'PesqBrw' 		     OPERATION 1 ACCESS 0
    ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.SALDBANCDIA' OPERATION 2 ACCESS 0
    ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.SALDBANCDIA' OPERATION 3 ACCESS 0
    ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.SALDBANCDIA' OPERATION 4 ACCESS 0
    ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.SALDBANCDIA' OPERATION 5 ACCESS 0
    ADD OPTION aMenu TITLE 'Imprimir' 	ACTION 'VIEWDEF.SALDBANCDIA' OPERATION 8 ACCESS 0

Return (aMenu)

static function ModelDef()

    local oModel as object
    local oStruct as object

    oModel := MPFormModel():New( "MODEL_ZSB", /*bPre*/ , /*bPos*/, /*bCommit*/, /*bCancel*/ )

    oStruct := FwFormStruct( 1, "ZSB", /*bFiltro*/ )

    oModel:AddFields( "FIELDS_ZSB", /*Owner*/ , oStruct, /*bPre*/ , /*bPos*/ , /*bLoad*/ )

    oModel:SetPrimaryKey({'ZSB_FILIAL'})

return (oModel)

static function ViewDef()

    local oView as object
    local oStruct as object
    local oModel as object

    oView := FwFormView():New()
    oModel := FwLoadModel("SALDBANCDIA")
    oStruct := FwFormStruct( 2, "ZSB", /*bFiltro*/ )

    oView:SetModel(oModel)
    oView:AddField( "VIEW_ZSB", oStruct, "FIELDS_ZSB" )

return (oView)
