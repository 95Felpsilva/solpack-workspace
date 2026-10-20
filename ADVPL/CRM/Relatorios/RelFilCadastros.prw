#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDEF.CH'
#include 'TopConn.ch'

#Define ALIAS_FORM						"SA1"
#Define ALIAS_GRID						"SA1"
#Define MODELO							"RELFILCADASTROS"
#Define ID_MODELO						"RELMFILCADASTROS"
#Define TITULO_MODEL 					"Filtro Cadastros"
#Define TITULO_FORM						"Filtro Cadastros"
#Define TITULO_GRID						"Cadastros"
#Define TITULO_VIEW 					TITULO_MODEL
#Define ID_MODEL_FORM					"MODEL_FORM_" + ALIAS_FORM
#Define ID_VIEW_FORM					"VIEW_FORM_" + ALIAS_FORM
#Define ID_MODEL_GRID					"MODEL_GRID_" + ALIAS_GRID
#Define ID_VIEW_GRID					"VIEW_GRID_" + ALIAS_GRID
//Define o campo de incremento no grid (FwFormView():AddIncrementField())
#Define FIELD_ITEM						""
#Define FIELDS_FORM						"A1_FILIAL|A1_EMAIL|A1_TEL|A1_CONTATO|A1_EST|A1_MUN|A1_NOME|A1_CGC|"
#Define FIELDS_GRID						"A1_COD|A1_LOJA|A1_NREDUZ|A1_NOME|A1_ZZVEND|A1_TEL|A1_FAX|A1_TELEX|A1_EMAIL|A1_DSCREG|A1_CONTATO|A1_EST|A1_MUN|A1_CGC|"
#Define PERCENTUAL_TELA_FORM			30
#Define PERCENTUAL_TELA_GRID			100-PERCENTUAL_TELA_FORM
#Define RELACAO_FORM_X_GRID				{{'A1_FILIAL','xFilial("' + ALIAS_FORM + '")'}}
#Define INDICE_RELACAO_FORM_X_GRID		(ALIAS_FORM)->(IndexKey(1))
//Define que determinado(s) campo(s) não pode ser repetido dentro do grid. FWFORMGRIDMODEL():SetUniqueLine(<aUnique >)
#Define UNIQUE_LINE						NIL		
#Define LINE_PRE						nil //{|oModelGrid, nLinha, cAcao, cCampo|linePre(oModelGrid, nLinha, cAcao, cCampo)}
#Define LINE_POST						nil //{|oModelGrid,nLine|linhaOK(oModelGrid,nLine) }
#Define PRE      						nil //{|oModelGrid, nLine,cAction,cField,xNewValue,xOldValue| preValid(oModelGrid, nLine,cAction,cField,xNewValue,xOldValue) }
#Define LINE_LOAD						nil//{|oGridModel, lCopy| loadGrid(oGridModel, lCopy)}
#Define COMMIT							{|oModel| commit(oModel)}

static cUEmail 			:= ""
static cUTelefone		:= ""
static cUContato	    := ""
static cUEstado			:= ""
static cUMunicipio		:= ""
static cURazaoSocial 	:= ""
static cUCGC			:= ""		
/*/{Protheus.doc} RELFILCADASTROS
Relatorio filtor de cadastros
@author Tiago Faria
@since 22/01/2018

@return return, nil
/*/
user function RELFILCADASTROS()
	local aEnableButtons := {}
	/*
	local 	cModelo 	:= MODELO
	local 	cTitle		:= TITULO_MODEL
	local	cAliasForm	:= ALIAS_FORM
	Local 	oBrowse 	:= FWMBrowse():New()

	oBrowse:SetAlias(cAliasForm)
	oBrowse:setMenuDef(cModelo)
	oBrowse:SetDescription(cTitle)
	oBrowse:Activate()
	*/

	aAdd(aEnableButtons ,{.f. ,nil})		//1 - Copiar
	aAdd(aEnableButtons ,{.f. ,nil})        //2 - Recortar
	aAdd(aEnableButtons ,{.f. ,nil})        //3 - Colar
	aAdd(aEnableButtons ,{.f. ,nil})        //4 - Calculadora
	aAdd(aEnableButtons ,{.f. ,nil})        //5 - Spool
	aAdd(aEnableButtons ,{.f. ,nil})        //6 - Imprimir
	aAdd(aEnableButtons ,{.f. ,nil})        //7 - Confirmar
	aAdd(aEnableButtons ,{.t. ,'Fechar'})   //8 - Cancelar
	aAdd(aEnableButtons ,{.f. ,nil})        //9 - WalkTrhough
	aAdd(aEnableButtons ,{.f. ,nil})        //10 - Ambiente
	aAdd(aEnableButtons ,{.f. ,nil})        //11 - Mashup
	aAdd(aEnableButtons ,{.f. ,nil})        //12 - Help
	aAdd(aEnableButtons ,{.f. ,nil})        //13 - Formulário HTML
	aAdd(aEnableButtons ,{.f. ,nil})        //14 - ECM


	FWExecView('CRM','RELFILCADASTROS', 3,, { || .T.},,,aEnableButtons)
return

Static Function MenuDef()
	Local aRotina := {}
	local cModelo := MODELO

	ADD OPTION aRotina Title 'Incluir'		Action 'VIEWDEF.'+cModelo OPERATION 3 ACCESS 0
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
	local cFieldsGrid	:= FIELDS_GRID
	local aRelation		:= RELACAO_FORM_X_GRID
	local cKeyIndice	:= INDICE_RELACAO_FORM_X_GRID
	local aUniqueLine	:= UNIQUE_LINE
	local oForm 		:= FWFormStruct(1, cAliasForm,{|cCampo|  alltrim(cCampo) + '|' $ cFieldsEnch })
	local oGrid 		:= FWFormStruct(1, cAliasForm,{|cCampo| alltrim(cCampo) + '|' $ cFieldsGrid})
	local oModel		:= nil
	local bLinePre		:= LINE_PRE
	local bLinePost		:= LINE_POST
	local bPre			:= PRE
	local bLoad			:= LINE_LOAD
	local xValid		:= nil
	local bCommit		:= COMMIT
	oForm:SetProperty( '*' , MODEL_FIELD_OBRIGAT,.f.)

	oGrid:SetProperty( '*' , MODEL_FIELD_OBRIGAT,.f.)

	xValid := FWBuildFeature( STRUCT_FEATURE_WHEN	,".f."	)
	oGrid:SetProperty( '*' , MODEL_FIELD_WHEN,xValid)

	xValid := FWBuildFeature( STRUCT_FEATURE_VALID	,".t."	)
	oGrid:SetProperty( '*' , MODEL_FIELD_VALID,xValid)	
	oForm:SetProperty( '*' , MODEL_FIELD_VALID,xValid)

	xValid := FWBuildFeature( STRUCT_FEATURE_INIPAD	,"criavar(strtran(readvar(),'M->'),.F.)")
	oGrid:SetProperty( '*' , MODEL_FIELD_INIT,xValid)	
	oForm:SetProperty( '*' , MODEL_FIELD_INIT,xValid)	

	oGrid:SetProperty( 'A1_DSCREG' , MODEL_FIELD_IDFIELD,"TIPO")

	oModel := MPFormModel():New(cIdModelo,,,/*bCommit*/)
	oModel:AddFields(cIdModelForm, /*cOwner*/, oForm)
	oModel:AddGrid( cIdModelGrid, cIdModelForm, oGrid, bLinePre, bLinePost, bPre,,bLoad  )
	oModel:SetRelation( cIdModelGrid, aRelation , cKeyIndice )
	oModel:getModel(cIdModelForm):setOnlyQuery(.t.)
	oModel:GetModel(cIdModelGrid):setOnlyQuery(.t.)
	
	oModel:GetModel(cIdModelForm):SetDescription(cFormTitulo)
	oModel:GetModel(cIdModelGrid):SetDescription(cGridTitulo)
	oModel:GetModel(cIdModelGrid):SetNoUpdateLine(.t.)
	oModel:GetModel(cIdModelGrid):SetNoDeleteLine(.t.)
	oModel:GetModel(cIdModelGrid):SetNoInsertLine(.t.)
	oModel:SetDescription(cModelTitulo)
	if valType(aUniqueLine) == "A"
		oModel:GetModel(cIdModelGrid):SetUniqueLine(aUniqueLine)
	endif
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
	local cFieldsGrid	:= FIELDS_GRID
	local cFieldItem	:= FIELD_ITEM
	local nPerFORM		:= PERCENTUAL_TELA_FORM
	local nPerGrid		:= PERCENTUAL_TELA_GRID
	local oModel 		:= FWLoadModel(cIdModelo)
	Local oForm 		:= FWFormStruct(2, cAliasForm,{|cCampo|  alltrim(cCampo) + '|' $ cFieldsEnch })
	Local oGrid 		:= FWFormStruct(2, cAliasForm,{|cCampo|  alltrim(cCampo) + '|' $ cFieldsGrid })
	local oView			:= nil
	//limpa o grupo e as pastas do SX3
	oForm:aFolders := {}
	oForm:aGroups := {}

	oForm:SetProperty( 'A1_CGC' , MVC_VIEW_PICT,"@R 99999999999999")
	oForm:SetProperty( 'A1_CGC' , MVC_VIEW_PICTVAR,"@R 99999999999999")
	oForm:SetProperty( 'A1_CGC' , MVC_VIEW_PVAR,{|a,b,c| FWInitCpo(a,b,c),xRet:=("@R 99999999999999"),FWCloseCpo(a,b,c,.T.),xRet })

	oGrid:SetProperty( 'A1_CGC' , MVC_VIEW_PICT,"@R 99999999999999")
	oGrid:SetProperty( 'A1_CGC' , MVC_VIEW_PICTVAR,"@R 99999999999999")
	oGrid:SetProperty( 'A1_CGC' , MVC_VIEW_PVAR,{|a,b,c| FWInitCpo(a,b,c),xRet:=("@R 99999999999999"),FWCloseCpo(a,b,c,.T.),xRet })

	oGrid:SetProperty( 'A1_DSCREG' , MVC_VIEW_IDFIELD,"TIPO")
	oGrid:SetProperty( 'TIPO' , MVC_VIEW_ORDEM,"01")
	oGrid:SetProperty( 'TIPO' , MVC_VIEW_TITULO,"Tipo")

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
	oView:showInsertMsg(.f.)
	oView:setFieldAction('A1_EMAIL'		,{|oView, cIDView, cField, xValue|runDados(oView, cIDView, cField, xValue)})
	oView:setFieldAction('A1_TEL'		,{|oView, cIDView, cField, xValue|runDados(oView, cIDView, cField, xValue)})
	oView:setFieldAction('A1_CONTATO'	,{|oView, cIDView, cField, xValue|runDados(oView, cIDView, cField, xValue)})
	oView:setFieldAction('A1_EST'		,{|oView, cIDView, cField, xValue|runDados(oView, cIDView, cField, xValue)})
	oView:setFieldAction('A1_MUN'		,{|oView, cIDView, cField, xValue|runDados(oView, cIDView, cField, xValue)})
	oView:setFieldAction('A1_NOME'		,{|oView, cIDView, cField, xValue|runDados(oView, cIDView, cField, xValue)})
	oView:setFieldAction('A1_CGC'		,{|oView, cIDView, cField, xValue|runDados(oView, cIDView, cField, xValue)})
	oView:AddUserButton('Visualiza Cadastro', 'BOTAO' ,{|oView| visualizaCadastro(oView) } )
Return oView
/*
	Visualiza o cadastro de cliente/suspect/prospect de acordo com o registro posicionado no grid.
	Autor: Tiago Faria
	Data: 13/11/2019
*/
static function visualizaCadastro(oView)
	local cTipo		:= alltrim(FwFldGet("TIPO"))
	local cFornece	:= FwFldGet("A1_COD")
	local cLoja		:= FwFldGet("A1_LOJA")
	local nOperation:= MODEL_OPERATION_VIEW
	if cTipo == "CLIENTE"
		if posicione("SA1",1,xFilial("SA1")+cFornece+cLoja,"!Eof()")
			FWExecView ("Cadastro de Fornecedores", "CRMA980",  MODEL_OPERATION_VIEW,,{||.T.},,,,,,,)
		endif
	elseif cTipo == "PROSPECT"
		if posicione("SUS",1,xFilial("SUS")+cFornece+cLoja,"!Eof()")
			FWExecView ("Cadastro de Prospect", "TMKA260",  MODEL_OPERATION_VIEW,,{||.T.},,,,,,,)
		endif	
	elseif cTipo == "SUSPECT"
		if posicione("ACH",1,xFilial("ACH")+cFornece+cLoja,"!Eof()")
			FWExecView ("Cadastro de Suspect", "TMKA341", MODEL_OPERATION_VIEW,,{||.T.},,,,,,,)
		endif
	endif
return
/*
	Visualiza o cadastro de suspect
	Está funcao tem o mesmo nome da funcao padrão para evitar o error.log:
	erro no parâmetroFWFormFieldsModel: Quantidade de campos retornado pelo bloco de carga do modelo:ACHMASTER, é menor que a quantidade de campos na estrutura. Verifique o bloco de carga:{|X,Y|FORMLOADFIELD(X,Y)} on LOAD(FWFORMFIELDSMODEL.PRX) 12/07/2019 17:27:31 line : 2744
	Autor: Tiago Faria
	Data: 13/11/2019
*/
static function CRMA320()
	FWExecView ("Cadastro de Suspect", "TMKA341", MODEL_OPERATION_VIEW,,{||.T.},,,,,,,)
return

/*
Bloco de Código de pré-edição da linha do grid.
O bloco é invocado na deleção de linha, no undelete da linha e nas tentativas de atribuição de valor.
Recebe como parâmetro o objeto de modelo do FormGrid(FWFormGridModel), o número da linha atual e a identificação da ação.
A Identificação da ação pode ser um dos itens abaixo:
- UNDELETE 
- DELETE 
- SETVALUE: nesse caso, serão passados mais três parâmetros. O 4º parâmetro é o identificador do campo que está sendo atualizado, o 5º parâmetro é o valor que está sendo atribuído e o 6º parâmetro é o valor que está no campo.
- CANSETVALUE: nesse caso será passado mais um parâmetro. O 4º parâmetro é o identificador do campo que está tentando ser atualizado.
O retorno do bloco deve ser um valor lógico que indique se a linha está valida para continuar com a ação. 
Se retornar verdadeiro, executa a ação, se retornar falso, atribui um erro ao Model, sendo necessário indicar a natureza do erro através da função Help. 
Autor: Tiago Faria
*/
static function linePre(oModelGrid, nLinha, cAcao, cCampo)
	local lRet 			:= .t.
	local cMsg			:= ""
	local nOperation 	:= oModelGrid:getOperation()

return lRet
/*
Bloco de código de pós-validação da linha do grid, equivale ao "LINHAOK".
O bloco será invocado antes da gravação dos dados. Espera-se um retorno lógico do bloco, indicando se a linha está ou não válida. 
Se o retorno for verdadeiro, a gravação será realizada, se for falso, um erro será atribuído ao Model e a gravação não será realizada, sendo necessário indicar a natureza do erro através da função Help.
Autor: Tiago Faria
*/
static function linePost(oModelGrid,nLinha)
	local lRet := .t.

return lRet
/*
Bloco de Código de pré-validação do submodelo. 
O bloco é invocado na deleção de linha, no undelete da linha, na inserção de uma linha e nas tentativas de atribuição de valor.
A Identificação da ação pode ser um dos itens abaixo:
- UNDELETE 
- DELETE
- ADDLINE: nesse caso, nada será passado para o parâmetro de número de linha. 
- SETVALUE: nesse caso, serão passados mais três parâmetros. O 4º parâmetro é o identificador do campo que está sendo atualizado, o 5º parâmetro é o valor que está sendo atribuído e o 6º parâmetro é o valor que está no campo.
- CANSETVALUE: nesse caso, será passado mais um parâmetro. O 4º parâmetro é o identificador do campo que está tentando ser atualizado.
O retorno do bloco deve ser um valor lógico que indique se a linha está válida para continuar com a ação.  
Autor: Tiago Faria
*/
static function preValid(oModelGrid, nLine,cAction,cField,xNewValue,xOldValue)
	local lRet := .t.

return lRet
/*
Bloco de carga dos dados do submodelo. 
Este bloco será invocado durante a execução do método activate desta classe.
Espera-se como retorno um array com os dados que serão carregados no objeto. O array deve ter a estrutura abaixo:
[n] 
[n][1] ExpN: Id do registro (RecNo)
[n][2] Array com os dados, os dados devem seguir exatamente a mesma ordem da estrutura de dados
Autor: Tiago Faria 
*/
static function loadGrid(oGridModel, lCopy)
	Local aLoad := {}

	aAdd(aLoad,{0,{xFilial("ZA2"), "000001", "01", "000100","AUTOR1","AUTOR"}})
	aAdd(aLoad,{0,{xFilial("ZA2"), "000001", "02", "000102","AUTOR2","AUTOR"}})
	aAdd(aLoad,{0,{xFilial("ZA2"), "000001", "03", "000104","AUTOR3","AUTOR"}})
	aAdd(aLoad,{0,{xFilial("ZA2"), "000001", "04", "000105","AUTOR4","AUTOR"}})
	aAdd(aLoad,{0,{xFilial("ZA2"), "000001", "05", "000106","AUTOR5","AUTOR"}})

Return aLoad

static function runDados(oView, cIDView, cField, xValue)
	local bAction := {||loadDados(.f.,oView, cIDView, cField, xValue)}

	FWMsgRun( ,bAction,"FILCADASTROS", "Aguarde carregando os dados..."  )
return

static function loadDados(lLoad,oView, cIDView, cField, xValue)
	local cQuery 		:= ""
	local cAlias 		:= ""
	local cEmail 		:= ""
	local cTelefone		:= ""
	local cContato		:= ""
	local cEstado		:= ""
	local cMunicipio	:= ""
	local cRazaoSocial	:= ""
	local nLine			:= 0
	local bAction		:= {|cField,xContent| updGrid(cField,xContent)}
	local lInit			:= .f.
	local lBlankLine	:= .t.
	private oModel 		:= nil
	private	oGrid		:= nil
	private	oStruct 	:= nil

	default lLoad := .f.

	if lLoad

	else
		cEmail 		    := alltrim(FwFldGet("A1_EMAIL"))
		cTelefone		:= alltrim(FwFldGet("A1_TEL"))
		cContato		:= alltrim(FwFldGet("A1_CONTATO"))
		cEstado		    := alltrim(FwFldGet("A1_EST"))
		cMunicipio	    := alltrim(FwFldGet("A1_MUN"))
		cRazaoSocial	:= alltrim(FwFldGet("A1_NOME"))
		cCGC			:= alltrim(FwFldGet("A1_CGC"))

		if cEmail == cUEmail .and.;
		cTelefone == cUTelefone .and.;
		cContato == cUContato .and.;
		cEstado == cUEstado .and.;
		cMunicipio == cUMunicipio .and.;
		cRazaoSocial == cURazaoSocial .and.;
		cCGC == cUCGC
			return
		endif

		cUEmail 		:= cEmail 		
		cUTelefone	    := cTelefone	
		cUContato	    := cContato	
		cUEstado		:= cEstado		
		cUMunicipio	    := cMunicipio	
		cURazaoSocial	:= cRazaoSocial
		cUCGC			:= cCGC		
	endif

	cQuery += "SELECT" + CRLF
	cQuery += "	TOP 100" + CRLF
	cQuery += "	'CLIENTE' AS TIPO," + CRLF
	cQuery += "	A1_COD," + CRLF
	cQuery += "	A1_LOJA," + CRLF
	cQuery += "	A1_NREDUZ," + CRLF
	cQuery += "	A1_NOME," + CRLF
	cQuery += "	A3_NOME AS A1_ZZVEND," + CRLF
	cQuery += "	A1_TEL," + CRLF
	cQuery += "	A1_FAX," + CRLF
	cQuery += "	A1_TELEX," + CRLF
	cQuery += "	A1_EMAIL," + CRLF
	cQuery += "	A1_CONTATO," + CRLF
	cQuery += "	A1_EST," + CRLF
	cQuery += "	A1_MUN," + CRLF
	cQuery += "	A1_CGC" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + retSqlTab("SA1") + CRLF

	cQuery += "LEFT JOIN " + CRLF
	cQuery += "	" + retSqlTab("SA3") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND A3_FILIAL = A1_FILIAL" + CRLF
	cQuery += "	AND A3_COD = A1_VEND" + CRLF
	cQuery += "	AND " + retSqlDel("SA3") + CRLF

	cQuery += "WHERE 1=1" + CRLF
	if !empty(cEmail)
		cQuery += "	AND A1_EMAIL LIKE '%" + cEmail + "%' " + CRLF
	endif
	if !empty(cTelefone)
		cQuery += "	AND (A1_TEL LIKE '%" + cTelefone + "%' OR A1_FAX LIKE '%" + cTelefone + "%' OR A1_TELEX LIKE '%" + cTelefone + "%')" + CRLF
	endif
	if !empty(cContato)
		cQuery += "	AND A1_CONTATO LIKE '%" + cContato + "%'" + CRLF
	endif
	if !empty(cEstado) 
		cQuery += "	AND A1_EST LIKE '%" + cEstado + "%'" + CRLF
	endif
	if !empty(cMunicipio)
		cQuery += "	AND A1_MUN LIKE '%" + cMunicipio + "%'" + CRLF
	endif
	if !empty(cRazaoSocial)
		cQuery += "	AND (A1_NOME LIKE '%" + cRazaoSocial + "%' OR A1_NREDUZ LIKE '%" + cRazaoSocial + "%' )" + CRLF
	endif
	if !empty(cCGC)
		cQuery += "	AND A1_CGC LIKE '%" + cCGC + "%'" + CRLF
	endif

	cQuery += "	AND " + retSqlDel("SA1") + CRLF

	cQuery += "UNION ALL" + CRLF

	cQuery += "SELECT " + CRLF
	cQuery += "	TOP 100" + CRLF
	cQuery += "	'PROSPECT' AS TIPO," + CRLF
	cQuery += "	US_COD AS CODIGO," + CRLF
	cQuery += "	US_LOJA AS LOJA," + CRLF
	cQuery += "	US_NREDUZ AS NOME_FANTASIA," + CRLF
	cQuery += "	US_NOME AS RAZAO_SOCIAL," + CRLF
	cQuery += "	A3_NOME AS VENDEDOR," + CRLF
	cQuery += "	US_TEL AS TELEFONE," + CRLF
	cQuery += "	US_FAX AS TELEFONE2," + CRLF
	cQuery += "	US_ZZTEL AS TELEFONE3," + CRLF
	cQuery += "	US_EMAIL AS EMAIL," + CRLF
	cQuery += "	US_ZZCONT," + CRLF
	cQuery += "	US_EST," + CRLF
	cQuery += "	US_MUN," + CRLF
	cQuery += "	US_CGC" + CRLF

	cQuery += "FROM " + CRLF
	cQuery += "	" + retSqlTab("SUS") + CRLF

	cQuery += "LEFT JOIN " + CRLF
	cQuery += "	" + retSqlTab("SA3") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND A3_FILIAL = US_FILIAL" + CRLF
	cQuery += "	AND A3_COD = US_VEND" + CRLF
	cQuery += "	AND " + retSqlDel("SA3") + CRLF

	cQuery += "WHERE 1=1" + CRLF
	if !empty(cEmail)
		cQuery += "	AND US_EMAIL LIKE '%" + cEmail + "%' " + CRLF
	endif
	if !empty(cTelefone)
		cQuery += "	AND (US_TEL LIKE '%" + cTelefone + "%' OR US_FAX LIKE '%" + cTelefone + "%' OR US_ZZTEL LIKE '%" + cTelefone + "%')" + CRLF
	endif
	if !empty(cContato)
		cQuery += "	AND US_ZZCONT LIKE '%" + cContato + "%'" + CRLF
	endif
	if !empty(cEstado)
		cQuery += "	AND US_EST LIKE '%" + cEstado + "%'" + CRLF
	endif
	if !empty(cMunicipio)
		cQuery += "	AND US_MUN LIKE '%" + cMunicipio + "%'" + CRLF
	endif
	if !empty(cRazaoSocial)
		cQuery += "	AND (US_NOME LIKE '%" + cRazaoSocial + "%' OR US_NREDUZ LIKE '%" + cRazaoSocial + "%' )" + CRLF
	endif
	if !empty(cCGC)
		cQuery += "	AND US_CGC LIKE '%" + cCGC + "%'" + CRLF
	endif
	cQuery += "	AND " + retSqlDel("SUS") + CRLF

	cQuery += "UNION ALL" + CRLF

	cQuery += "SELECT " + CRLF
	cQuery += "	TOP 100" + CRLF
	cQuery += "	'SUSPECT' AS TIPO," + CRLF
	cQuery += "	ACH_CODIGO AS CODIGO," + CRLF
	cQuery += "	ACH_LOJA AS LOJA," + CRLF
	cQuery += "	ACH_NFANT AS NOME_FANTASIA," + CRLF
	cQuery += "	ACH_RAZAO AS RAZAO_SOCIAL," + CRLF
	cQuery += "	ACH_VEND AS COD_VENDEDOR," + CRLF
	cQuery += "	ACH_TEL AS TELEFONE," + CRLF
	cQuery += "	ACH_FAX AS TELEFONE2," + CRLF
	cQuery += "	ACH_ZZTEL AS TELEFONE3," + CRLF
	cQuery += "	ACH_EMAIL AS EMAIL," + CRLF
	cQuery += "	''," + CRLF
	cQuery += "	ACH_EST," + CRLF
	cQuery += "	ACH_CIDADE," + CRLF
	cQuery += "	ACH_CGC" + CRLF

	cQuery += "FROM " + CRLF
	cQuery += "	" + retSqlTab("ACH") + CRLF

	cQuery += "LEFT JOIN " + CRLF
	cQuery += "	" + retSqlTab("SA3") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND A3_FILIAL = ACH_FILIAL" + CRLF
	cQuery += "	AND A3_COD = ACH_VEND" + CRLF
	cQuery += "	AND " + retSqlDel("SA3") + CRLF

	cQuery += "WHERE 1=1" + CRLF
	if !empty(cEmail)
		cQuery += "	AND ACH_EMAIL LIKE '%" + cEmail + "%' " + CRLF
	endif
	if !empty(cTelefone)
		cQuery += "	AND (ACH_TEL LIKE '%" + cTelefone + "%' OR ACH_FAX LIKE '%" + cTelefone + "%' OR ACH_ZZTEL LIKE '%" + cTelefone + "%')" + CRLF
	endif
	if !empty(cEstado)
		cQuery += "	AND ACH_EST LIKE '%" + cEstado + "%'" + CRLF
	endif
	if !empty(cMunicipio)
		cQuery += "	AND ACH_CIDADE LIKE '%" + cMunicipio + "%'" + CRLF
	endif
	if !empty(cRazaoSocial)
		cQuery += "	AND (ACH_RAZAO LIKE '%" + cRazaoSocial + "%' OR ACH_NFANT LIKE '%" + cRazaoSocial + "%')" + CRLF
	endif
	if !empty(cCGC)
		cQuery += "	AND ACH_CGC LIKE '%" + cCGC + "%'" + CRLF
	endif
	cQuery += "	AND " + retSqlDel("ACH") + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	if lLoad

	else
		oModel 	:= FwModelActive()
		oGrid	:= oModel:getModel(ID_MODEL_GRID)
		oStruct := oGrid:GetStruct()
		oGrid:SetNoUpdateLine(.f.)
		oGrid:SetNoDeleteLine(.f.)
		oGrid:SetNoInsertLine(.f.)

		oGrid:ClearData(lInit,lBlankLine)
	endif

	while (cAlias)->(!Eof())
		nLine := oGrid:addLine()

		if nLine < (cAlias)->(recno())
			exit
		endif

		oGrid:goLine(nLine)

		eachField(cAlias,bAction)

		(cAlias)->(dbSkip())
	enddo

	(cAlias)->(dbCloseArea())

	oGrid:goLine(1)

	oGrid:SetNoUpdateLine(.t.)
	oGrid:SetNoDeleteLine(.t.)
	oGrid:SetNoInsertLine(.t.)

	oView:refresh()
return
/*
Atualiza cada campo do grid de acordo com a funcao eachField()
*/
static function updGrid(cField,xContent)
	if oStruct:getFieldPos(cField) > 0
		oGrid:LoadValue(cField	,xContent)
	endif
return
/*
Percorre todos os campos do alias recebido como parametro e executa o bloco de codigo passando o id do campo + conteudo
{|cField,xContent| updGrid(cField,xContent)}
Autor: Tiago Faria
*/
static function eachField(cAlias,bAction)
	local nQtdField := (cAlias)->(fCount())
	local nField	:= 0
	local cField	:= ""
	default bAction := {||.t.}
	for nField := 1 to nQtdField
		cField 		:= (cAlias)->(fieldName(nField))
		xContent	:= (cAlias)->&(cField)

		eval(bAction,cField,xContent)
	next nField
return
/*
Bloco de código de persistência dos dados, ele é invocado pelo método CommitData. 
O bloco recebe como parametro o objeto do Model e deve realizar a gravação dos dados.
*/
static function commit(oModel)
	local lRet := .t.

	//FWFORMCOMMIT(oModel)
return lRet
