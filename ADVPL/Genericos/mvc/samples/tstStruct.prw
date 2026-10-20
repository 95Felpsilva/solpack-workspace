#include 'totvs.ch'

static PROGRAMA      := "TSTSTRUCT"
static ID_MODEL      := "MVC_TSTSTRUCT"
static ID_VIEW_GRID  := "GRID_VIEW"
static ID_MODEL_GRID := "GRID_VIEW"

static ID_VIEW_FORM  := "FORM_VIEW"
static ID_MODEL_FORM := "FORM_MODEL"


user function tstStruct()

	FWExecView( "Teste Struct" , PROGRAMA/*cIDPrograma*/, 3/*nOperation*/, /*oDlg*/,/*bCloseOnOK*/, /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/,/* bCancel*/ , /*cOperatId*/, /*cToolBar*/, /*oModel*/ )
return

static function modelDef()
	local oModel      := nil
	local oStructFake := getModelTableFake()
	local oFieldText := StructModel():new()
	local oFieldLogic := StructModel():new()
    local oFieldNum   := StructModel():new()
    local oFieldCombo := StructModel():new()

	oFieldText:setTitle("Texto")
	oFieldText:setTooltip("Teste Texto")
	oFieldText:setIdField("TST_1")
	oFieldText:setType("C")
	oFieldText:setSize(30)
	oFieldText:setDecimal(0)
	oFieldText:setValid(".t.")
	oFieldText:setWhen(".t.")
	//oFieldText:setValues()
	oFieldText:setObrigat(.t.)
	oFieldText:setInit("'TESTE TEXTO'")
	//oFieldText:setKey()
	//oFieldText:setNoUpd()
	//oFieldText:setVirtual()


    oFieldLogic:setTitle("Logico")
	oFieldLogic:setTooltip("Teste Logico")
	oFieldLogic:setIdField("TST_2")
	oFieldLogic:setType("L")
	oFieldLogic:setSize(1)
	oFieldLogic:setDecimal(0)
	oFieldLogic:setValid(".t.")
	oFieldLogic:setWhen("!empty(FwFldGet('TST_1'))")
	//oFieldLogic:setValues()
	oFieldLogic:setObrigat(.t.)
	oFieldLogic:setInit(".f.")
	//oFieldLogic:setKey()
	//oFieldLogic:setNoUpd()
	//oFieldLogic:setVirtual()

	oFieldNum:setTitle("Numero")
	oFieldNum:setTooltip("Teste Numero")
	oFieldNum:setIdField("TST_3")
	oFieldNum:setType("N")
	oFieldNum:setSize(12)
	oFieldNum:setDecimal(4)
	oFieldNum:setValid("Positivo()")
	//oFieldNum:setWhen("!empty(FwFldGet('TST_1'))")
	//oFieldNum:setValues()
	//oFieldNum:setObrigat(.t.)
	//oFieldNum:setInit(".f.")
	//oFieldNum:setKey()
	//oFieldNum:setNoUpd()
	//oFieldNum:setVirtual()

    oFieldCombo:setTitle("Combo")
	oFieldCombo:setTooltip("Teste Combo")
	oFieldCombo:setIdField("TST_4")
	oFieldCombo:setType("C")
	oFieldCombo:setSize(2)
	oFieldCombo:setDecimal(0)
	//oFieldCombo:setValid("Positivo()")
	//oFieldCombo:setWhen("!empty(FwFldGet('TST_1'))")
	oFieldCombo:setValues({"SI=SIM","NA=NAO","OK=OK","TS=TESTE"})
	//oFieldCombo:setObrigat(.t.)
	//oFieldCombo:setInit(".f.")
	//oFieldCombo:setKey()
	//oFieldCombo:setNoUpd()
	//oFieldCombo:setVirtual()


	oFieldLogic:addField(oStructFake)
	oFieldText:addField(oStructFake)
	oFieldNum:addField(oStructFake)
	oFieldCombo:addField(oStructFake)

	oModel := MPFormModel():New(ID_MODEL/*cID*/,/*bPre*/,/*bPost*/,/*bCommit*/,/*bCancel*/)

	oModel:addFields(ID_MODEL_FORM, /*cOwner*/, oStructFake , /*bPre*/, /*bPost*/, /*bLoad*/)

	//oModel:addGrid(::getIDGridModel() /*cId */,;
		//	ID_MODEL_FORM /*cOwner */,;
		//	::getStructGridModel() /*oModelStruct*/,;
		//   	/*bLinePre*/,;
		//    /*bLinePost*/,;
		//	/*bPre*/,;
		//	/*bPost*/,;
		//	bLoad)
	oModel:setDescription("TESTE")
	oModel:SetOnlyQuery(ID_MODEL_FORM/*cIdForm*/,.t./*lOp*/)
return oModel

static function viewDef()
	local oView 	:= nil
	local oModel 	:= nil
	local oStrCab 	:= nil
	local oFieldTxt := StructView():new()
    local oFieldLogic := StructView():new()
    local oFieldNum := StructView():new()
    local oFieldCombo := StructView():new()
	//local oStrGrid 	:= nil

    //oFieldTxt:setComboValues()
	oFieldTxt:setHelp({"Campo texto","teste 2"})
	oFieldTxt:setDescric("Campo texto teste 2")
    //oFieldTxt:setFolder()
    //oFieldTxt:setGroup()
	oFieldTxt:setIdField("TST_1")
    //oFieldTxt:setIniBrow()
	oFieldTxt:setLookUp("SA1")
	oFieldTxt:setOrder("01")
	oFieldTxt:setPicture("@!")
	oFieldTxt:setTitle("Teste Texto")
	oFieldTxt:setType("C")
    //oFieldTxt:setMaxLenCombo()
    //oFieldTxt:setWidth()
    //oFieldTxt:setCanChange()
    //oFieldTxt:setInsertLine()
    //oFieldTxt:setVirtual()

    //oFieldLogic:setComboValues()
	oFieldLogic:setHelp({"Campo Logico","Logico 2"})
	oFieldLogic:setDescric("Campo Logico Logico 2")
    //oFieldLogic:setFolder()
    //oFieldLogic:setGroup()
	oFieldLogic:setIdField("TST_2")
    //oFieldLogic:setIniBrow()
	//oFieldLogic:setLookUp("SA1")
	oFieldLogic:setOrder("02")
	//oFieldLogic:setPicture("@!")
	oFieldLogic:setTitle("Teste Logico")
	oFieldLogic:setType("L")
    //oFieldLogic:setMaxLenCombo()
    //oFieldLogic:setWidth()
    //oFieldLogic:setCanChange()
    //oFieldLogic:setInsertLine()
    //oFieldLogic:setVirtual()

    //oFieldNum:setComboValues()
	oFieldNum:setHelp({"Campo Numérico","Numerico 2"})
	oFieldNum:setDescric("Campo Numérico Logico 2")
    //oFieldNum:setFolder()
    //oFieldNum:setGroup()
	oFieldNum:setIdField("TST_3")
    //oFieldNum:setIniBrow()
	//oFieldNum:setLookUp("SA1")
	oFieldNum:setOrder("03")
	oFieldNum:setPicture(AVCALCPICT(12,4))
	oFieldNum:setTitle("Teste Numérico")
	oFieldNum:setType("N")
    //oFieldNum:setMaxLenCombo()
    //oFieldNum:setWidth()
    //oFieldNum:setCanChange()
    oFieldNum:setInsertLine(.t.)
    //oFieldNum:setVirtual()

    oFieldCombo:setComboValues({"SI=SIM","NA=NAO","OK=OK","TS=TESTE"})
	oFieldCombo:setHelp({"Campo Combo","Combo 2"})
	oFieldCombo:setDescric("Campo Combo Combo 2")
    //oFieldCombo:setFolder()
    //oFieldCombo:setGroup()
	oFieldCombo:setIdField("TST_4")
    //oFieldCombo:setIniBrow()
	//oFieldCombo:setLookUp("SA1")
	oFieldCombo:setOrder("04")
	oFieldCombo:setPicture("@!")
	oFieldCombo:setTitle("Teste Combo")
	oFieldCombo:setType("C")
    oFieldCombo:setMaxLenCombo(2)
    //oFieldCombo:setWidth()
    //oFieldCombo:setCanChange()
    //oFieldCombo:setInsertLine()
    //oFieldCombo:setVirtual()

	// Estrutura Fake de Field
	oStrCab := getViewTableFake()

	oFieldLogic:addField(oStrCab)
	oFieldTxt:addField(oStrCab)
	oFieldNum:addField(oStrCab)
	oFieldCombo:addField(oStrCab)

	//Estrutura de Grid
	//oStrGrid := ::getStructGridView()

	oModel := FWLoadModel(PROGRAMA)

	oView := FwFormView():New()

	oView:setModel(oModel)
	oView:addField(ID_VIEW_FORM, oStrCab, ID_MODEL_FORM)
	//oView:addGrid(ID_VIEW_GRID, oStrGrid, ::cIDGridModel)

	oView:createHorizontalBox("TOHIDE", 100 )
	//oView:createHorizontalBox("TOSHOW", 90 )
	oView:setOwnerView(ID_VIEW_FORM, "TOHIDE" )
	//oView:setOwnerView(ID_VIEW_GRID, "TOSHOW")
return oView
/*
Monta estrutura do Model de tabela falsa para servir de cabeçalho da tela MVC
Autor: Tiago Faria
Data: 07/07/2021
*/
static function getModelTableFake()
	local oModelStruct := FWFormModelStruct():New()

	oModelStruct:addTable(""/*oJson */, {"FAKE_01"}/*aPK */, "."/*cDescription */, {|| ""}/*bRealName*/)
	oModelStruct:addField("Field Fake 01", "Field Fake 01", "FAKE_01", "C", 15)
return oModelStruct

/*
Monta estrutura da View de tabela falsa para servir de cabeçalho da tela MVC
Autor: Tiago Faria
Data: 07/07/2021
*/
static function getViewTableFake()
	local oViewStruct := FWFormViewStruct():New()
	oViewStruct:addField("FAKE_01", "01" , "Field Fake 01", "Campo de texto", , "C" )
return oViewStruct
