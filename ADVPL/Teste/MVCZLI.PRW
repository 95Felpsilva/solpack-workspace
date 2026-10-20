#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MVCZLI

Cadastro MVC de Ligações a Solpack

@author     Solon Thomas - Solpack
@since      01/08/2023
@version    1.0
/*/
//-------------------------------------------------------------------

/*User Function Principal*/
User Function MVCZLI()

    Local oBrowse := FwLoadBrw("MVCZLI")

    oBrowse:Activate()

Return (NIL)


Static Function BrowseDef()

    Local oBrowse := FwmBrowse():New()

    oBrowse:SetAlias("ZLI")
    oBrowse:SetDescription("Ligações Solpack")

    oBrowse:AddLegend("ZLI->ZLI_TPCONT == '1'","YELLOW","Primeiro Contato")
    oBrowse:AddLegend("ZLI->ZLI_TPCONT == '2'","GREEN","Cliente")
    oBrowse:AddLegend("ZLI->ZLI_TPCONT == '3'","BLUE","Fornecedor")
    oBrowse:AddLegend("ZLI->ZLI_TPCONT == '4'","WHITE","Funcionario")
    oBrowse:AddLegend("ZLI->ZLI_TPCONT == '5'","RED","Engano")
    oBrowse:AddLegend("ZLI->ZLI_TPCONT == '6'","BLACK","Desligou")

    //oBrowse:SetOnlyField({"","",""})

    //oBrowse:DisableDetails()
    
   oBrowse:SetMenuDef("MVCZLI")

Return (oBrowse)


Static Function MenuDef()

    Local aMenu := {}

    ADD OPTION aMenu TITLE 'Pesquisar' 	ACTION 'PesqBrw' 		OPERATION 1 ACCESS 0
    ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.MVCZLI' OPERATION 2 ACCESS 0
    ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.MVCZLI' OPERATION 3 ACCESS 0
    ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.MVCZLI' OPERATION 4 ACCESS 0
    ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.MVCZLI' OPERATION 5 ACCESS 0
    ADD OPTION aMenu TITLE 'Imprimir' 	ACTION 'VIEWDEF.MVCZLI' OPERATION 8 ACCESS 0

Return (aMenu)


static function ModelDef()

    local oModel as object
    local oStruct as object

    oModel := MPFormModel():New( "MODEL_ZLI", /*bPre*/ , /*bPos*/, /*bCommit*/, /*bCancel*/ )

    oStruct := FwFormStruct( 1, "ZLI", /*bFiltro*/ )

    oModel:AddFields( "FIELDS_ZLI", /*Owner*/ , oStruct, /*bPre*/ , /*bPos*/ , /*bLoad*/ )

    oModel:SetPrimaryKey({'ZLI_FILIAL'})

Return (oModel)


static function ViewDef()

    local oView as object
    local oStruct as object
    local oModel as object

    oView := FwFormView():New()
    oModel := FwLoadModel("MVCZLI")
    oStruct := FwFormStruct( 2, "ZLI", /*bFiltro*/ )

    oView:SetModel(oModel)
    oView:AddField( "VIEW_ZLI", oStruct, "FIELDS_ZLI" )

return (oView)
