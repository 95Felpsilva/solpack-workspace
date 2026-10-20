#include "totvs.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.CH" 
#INCLUDE "FWMVCDEF.CH"

#define MODELO		                    "ApPerdaApara"
#define ID_MODELO			            "ApMPerdaApara"

#define ALIAS_FORM			            "SZ5"
#define ALIAS_GRID_A		            "SZ5"

#define ID_MODEL_FORM		            "MODEL_FORM_" + ALIAS_FORM
#define ID_MODEL_GRID_A		            "MODEL_GRID" + ALIAS_GRID_A

#define TITULO_MODEL 		            "Apontamento de Perda/Apara"
#define TITULO_FORM			            "Apontamento de Perda/Apara"
#define TITULO_GRID_A		            "Apontamentos"

#define FIELDS_FORM						"Z5_CTRAB|Z5_ZZTURNO|Z5_DATA|Z5_HORA|Z5_USER|"
#define FIELDS_GRID_A					"Z5_RECURSO|Z5_DESCRI|Z5_OP|Z5_COMP|Z5_REFILE|Z5_PERDA|Z5_BOBINA|Z5_REJEITO|Z5_TIPO|Z5_MOTIVO|Z5_OBSERR|Z5_STATREF|Z5_STATPER|Z5_STATBOB|Z5_STATREJ|"

#define RELACAO_FORM_X_GRID_A			{{'Z5_FILIAL','xFilial("SH1")'}}
#define INDICE_RELACAO_FORM_X_GRID_A	SZ5->(IndexKey(1))

/*/{Protheus.doc} APICadApara

Rotina para processar cadastro de aparas via API

@type function
@author Gabriel Pereira - CRM Services
@since 12/12/2022

/*/
User Function APICadApara(cCotent)
    Local lRet          := .F.
    
    Private oJson		:= JsonObject():new()
    Private cMsg        := ""

    Default cCotent     := ""

    If FwJsonDeserialize(cCotent, @oJson)
        If podeExecutar()
            lRet := montaRequisicao()

            If lRet 
                cMsg := "Cadastro realizado!"
            EndIf
        EndIf
    Else
        cMsg := "Json enviado está com erro de montagem."
    EndIf

    If Type("oRet") == "J"
        oRet["message"] := EncodeUTF8(cMsg, "cp1252")
    EndIf
    
Return lRet

/*
    Pré validação da execução da rotina
*/
Static Function podeExecutar()
    Local lRet      := .F.
    Local nRecord   := 0
    
    Begin Sequence
        
        If !AttIsMemberOf(oJson,"department")
            cMsg := "Campo 'departamento' é obrigatório (department)."
            Break
        EndIf
        
        If !AttIsMemberOf(oJson,"shift")
            cMsg := "Campo 'turno' é obrigatório (shift)."
            Break
        EndIf
        
        If !AttIsMemberOf(oJson,"items") .And. ( Type("oJson:items") <> "A" )
            cMsg := "Conjunto de itens é obrigatório (items)."
            Break
        EndIf

        If !AttIsMemberOf(oJson,"user")
            cMsg := "Campo 'user' é obrigatório (user)."
            Break
        EndIf
        
        If !AttIsMemberOf(oJson,"date")
            cMsg := "Campo 'date' é obrigatório (date)."
            Break
        EndIf

        If STOD(oJson:date) > Date()
            cMsg := "Não é permitido apontamento com data futura."
            Break
        EndIf
        
        If STOD(oJson:date) < Date()
            cMsg := "Não é permitido apontamento com data retroativa."
            Break
        EndIf

        For nRecord:=1 To Len(oJson:items)
            If !AttIsMemberOf(oJson:items[nRecord],"resource")
                cMsg := "Campo 'recurso' é obrigatório no item " + cValToChar(nRecord) + " (resource)."
                Break
            EndIf
            If !AttIsMemberOf(oJson:items[nRecord],"descriptionResource")
                cMsg := "Campo 'descrição do recurso' é obrigatório no item " + cValToChar(nRecord) + " (descriptionResource)."
                Break
            EndIf
            If !AttIsMemberOf(oJson:items[nRecord],"productionOrder")
                cMsg := "Campo 'ordem de produção' é obrigatório no item " + cValToChar(nRecord) + " (productionOrder)."
                Break
            EndIf
            If !AttIsMemberOf(oJson:items[nRecord],"loss") .And. !AttIsMemberOf(oJson:items[nRecord],"rell") .And. !AttIsMemberOf(oJson:items[nRecord],"trim")
                cMsg := "Necessario informar a quantidade de apara (Refile, Perda ou Bobina) " + cValToChar(nRecord) + " (trim|loss|rell)."
                Break
            EndIf
            If !AttIsMemberOf(oJson:items[nRecord],"type")
                cMsg := "Campo 'tipo' é obrigatório no item " + cValToChar(nRecord) + " (type)."
                Break
            EndIf
            If !AttIsMemberOf(oJson:items[nRecord],"motive")
                cMsg := "Campo 'motivo' é obrigatório no item " + cValToChar(nRecord) + " (motive)."
                Break
            EndIf
        Next nRecord
        
        lRet := .T.
    EndSequence
Return lRet

/*
    Rotina para montagem de array de envio da rotina automática (Cab/Item)
*/
Static Function montaRequisicao()
    Local lRet          := .T.
    Local cCodOP        := ""
    Local aCabPedido    := {}
    Local aItemPedido   := {}
    Local aRecord       := {}
    Local nRecord       := 0
    Local dOldDate      := CTOD("")

    dOldDate := dDataBase
    dDataBase := STOD(oJson:date)

    aAdd(aCabPedido, { "Z5_CTRAB", oJson:department, NIL})
    aAdd(aCabPedido, { "Z5_ZZTURNO", oJson:shift, NIL})
    aAdd(aCabPedido, { "Z5_DATA", STOD(oJson:date), NIL})
    aAdd(aCabPedido, { "Z5_HORA", Time(), NIL})
    aAdd(aCabPedido, { "Z5_USER", oJson:user, NIL})
    
    For nRecord:=1 To Len(oJson:items)
        aRecord := {}
        cCodOP := oJson:items[nRecord]:productionOrder

        If AttIsMemberOf(oJson:items[nRecord],"product")
            cCodApara := oJson:items[nRecord]:product
        Else
            cCodApara := getProdutoApara(cCodOP)
        EndIf

        If Empty(cCodApara)
            cMsg := "Código de apara não cadastro para a OP " + cCodOP
            Return lRet
        EndIf

        aAdd(aRecord, { "Z5_RECURSO", oJson:items[nRecord]:resource, NIL})
        aAdd(aRecord, { "Z5_DESCRI", DecodeUTF8(oJson:items[nRecord]:descriptionResource, "cp1252"), NIL})
        aAdd(aRecord, { "Z5_OP", cCodOP , NIL})
        aAdd(aRecord, { "Z5_COMP", cCodApara, NIL})
        aAdd(aRecord, { "Z5_REFILE", oJson:items[nRecord]:trim, NIL})
        aAdd(aRecord, { "Z5_PERDA", oJson:items[nRecord]:loss, NIL})
        aAdd(aRecord, { "Z5_BOBINA", oJson:items[nRecord]:rell, NIL})
        aAdd(aRecord, { "Z5_REJEITO", Iif(Type("oJson:items[nRecord]:reject") == "N", oJson:items[nRecord]:reject, 0) , NIL})
        aAdd(aRecord, { "Z5_TIPO", oJson:items[nRecord]:type, NIL})
        aAdd(aRecord, { "Z5_MOTIVO", oJson:items[nRecord]:motive, NIL})
        aRecord := FwVetByDic(aRecord,"ZR5")

        If !( hasExistItem(oJson:department, oJson:shift, oJson:items[nRecord]:resource, cCodOP, cCodApara, oJson:items[nRecord]:trim, oJson:items[nRecord]:loss, oJson:items[nRecord]:rell) )
            aAdd(aItemPedido, aRecord)
        EndIf
    Next nRecord

    If Len(aItemPedido) > 0
        lRet := execCadastro(aCabPedido, aItemPedido)
    EndIf

    dDataBase := dOldDate

Return lRet

/*
    Executa rotina automática de cadastro de apara
*/
Static Function execCadastro(aCabPedido, aItemPedido)
    Local lRet      := .F.
    Local oModel    := Nil
    
    Private aRotina         := {}
    Private lMSHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.
    Private lMsErroAuto     := .F.
    
    oModel := FWLoadModel( MODELO )
    
    If ValType(oModel) == "U"
        //oModel := createModel()
    EndIf

    montaMenu()

    FwMVCRotAuto( oModel , ALIAS_FORM , MODEL_OPERATION_INSERT , { { ID_MODEL_FORM, aCabPedido }, { ID_MODEL_GRID_A, aItemPedido } } )

    If lMsErroAuto
        cMsg := getError(oModel)
    Else
        lRet := .T.
    EndIf

Return lRet

/*
    Monta conjunto de menu, necessário para utilizar a rotina automática
*/
Static Function montaMenu()
    Local cModelo := MODELO

    ADD OPTION aRotina Title 'Incluir'		Action 'VIEWDEF.'+cModelo OPERATION 3 ACCESS 0
    
return aRotina

/*
    Captura o erro que ocorreu no processamento da rotina automática
*/
Static Function getError(oModel)
    Local aErro := oModel:GetErrorMessage()

    If Len(aErro) > 0
        cErro := aErro[6]
    ElseIf Len(GetAutoGRLog() > 0)
        cErro := GetAutoGRLog()[1]
    EndIf

Return cErro

/*
    Rotina para recuperar código de apara
*/
Static Function getProdutoApara(cOP)
	local cQuery        := ""
	local cAlias        := getNextAlias()
	local cApara        := getNewPar("ZZ_APARA","50.20.01.0003")

	//criado parametro pois a Solpack parou de usar multiplos códigos de apara.
	if empty(cApara)
		cQuery += "SELECT" + CRLF
		cQuery += "    TOP 1 G1_COMP AS Z5_COMP" + CRLF
		cQuery += "FROM" + CRLF
		cQuery += "    " + RetSqlTab("SC2") + CRLF

		cQuery += "INNER JOIN" + CRLF
		cQuery += "    " + RetSqlTab("SG1") + CRLF
		cQuery += "ON 1=1" + CRLF
		cQuery += "    AND " + RetSqlFil("SG1") + CRLF
		cQuery += "    AND G1_COD = C2_PRODUTO " + CRLF
		cQuery += "    AND G1_QUANT < 0" + CRLF
		cQuery += "    AND " + RetSqlDel("SG1") + CRLF

		cQuery += "WHERE 1=1" + CRLF
		cQuery += "    AND " + RetSqlFil("SC2") + CRLF
		cQuery += "    AND C2_NUM+C2_ITEM+C2_SEQUEN = '" + cOP + "' " + CRLF
		cQuery += "    AND " + RetSqlDel("SC2") + CRLF

        DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)		

        If (cAlias)->(!Eof())
            cApara := (cAlias)->(Z5_COMP)
        EndIf
		
        (cAlias)->(dbCloseArea())
	EndIf
Return cApara

/*
    Rotina para montar model manualmente
*/
Static function createModel()
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
    Verifica se existe apara cadastrada nos ultimos 5 minutos (vide parâmetro)
*/
Static Function hasExistItem(cDepartment, cShift, cResource, cCodOP, cCodApara, nTrim, nLoss, nRell)
    Local lRet      := .F.
    Local cQuery    := ""
    Local cAlias    := getNextAlias()

    cQuery := getQryHasExistItem(cDepartment, cShift, cResource, cCodOP, cCodApara, nTrim, nLoss, nRell)
    cAlias := MpsysOpenQuery(cQuery)
    
    lRet := (cAlias)->(!Eof())

    (cAlias)->(dbCloseArea())
    
Return lRet

/*
    Query para verificar se existe apara cadastrada nos ultimos 5 minutos (vide parâmetro)
*/
Static Function getQryHasExistItem(cDepartment, cShift, cResource, cCodOP, cCodApara, nTrim, nLoss, nRell)
    Local cQuery    := ""
    Local nTimeSub  := GetNewPar("ES_TSUBAPA", 5)
    
    cQuery += " SELECT" + CRLF
    cQuery += "     Z5_OP " + CRLF
    cQuery += " FROM" + CRLF
    cQuery += "     " + RetSqlTab("SZ5") + CRLF
    cQuery += " WHERE" + CRLF
    cQuery += "     1 = 1" + CRLF
    cQuery += "     AND " + RetSqlFil("SZ5") + CRLF
    cQuery += "     AND Z5_CTRAB = " + ValToSql(cDepartment) + CRLF
    cQuery += "     AND Z5_ZZTURNO = " + ValToSql(cShift) + CRLF
    cQuery += "     AND Z5_RECURSO = " + ValToSql(cResource) + CRLF
    cQuery += "     AND Z5_OP = " + ValToSql(cCodOP) + CRLF
    cQuery += "     AND Z5_COMP = " + ValToSql(cCodApara) + CRLF
    cQuery += "     AND Z5_REFILE = " + ValToSql(nTrim) + CRLF
    cQuery += "     AND Z5_PERDA = " + ValToSql(nLoss) + CRLF
    cQuery += "     AND Z5_BOBINA = " + ValToSql(nRell) + CRLF
    cQuery += "     AND Z5_DATA = " + ValToSql(Date()) + CRLF
    cQuery += "     AND Z5_HORA >= " + ValToSql(DecTime(Time(), 0, nTimeSub, 0)) + CRLF
    cQuery += "     AND " + RetSqlDel("SZ5") + CRLF

Return cQuery
