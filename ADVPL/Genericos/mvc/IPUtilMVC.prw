#include 'protheus.ch'
#Include 'FWMVCDEF.CH'
#include 'TopConn.ch'

#Define CHAR_MACRO superGetMV("ZZ_CMVCMAC",,"##")

/*/{Protheus.doc} IPUtilMVC
Funcoes uteis para utilizar com as classes MVC
@type class
@version  1.0
@author Tiago Faria
@since 06/11/2018
/*/
class IPUtilMVC
	data aDePara
	data cFieldCopy
	data oStruct
	data lModel

	method new() constructor
	method addFieldFromX3()
	method addOtherFields()
	method getProperty()
	method removeTrigger()
	method removeFolders()
	method updModel2Qry()
	method loadGrid()
	method updOrdem()
	method addLineGrid()
	method addFieldBMP()
	method addFieldBT()
endclass

/*/{Protheus.doc} new
Metodo construtor da classe
@author Tiago Faria
@since 06/11/2018 
@version 1.0
@type method
/*/
method new() class IPUtilMVC
	::cFieldCopy := ""
	::aDePara	 := {}
	::lModel	 := .f.
return
/*/{Protheus.doc} IPUtilMVC::getProperty
Recupera conteudo do dicioinario de dados, caso o array aOption tenha o campo preenchido retorna o conteudo do array
@type method
@version  1.0
@author Tiago Faria
@since 10/03/2019
@param cFieldX3, character, Campo do SX3 que será copiado
@param aOption, array, array com os campos do SX3 que devem ser considerado na copia exemplo {{"X3_TITULO","TESTE"}} copia o campo já com o titulo TESTE
@return character, retorna conteudo do sx3
/*/
method getProperty(cFieldX3,aOption,lOnlyArray) class IPUtilMVC
	local nPos			:= aScan(aOption,{|X|alltrim(X[1]) == cFieldX3 })
	local nPosProperty	:= 0
	local xRet			:= nil
	local cVldUser		:= ""
	default aOption		:= {}
	default lOnlyArray	:= .f.

	if nPos > 0
		xRet := aOption[nPos,2]
	elseif !lOnlyArray
		if cFieldX3 == "TIPO_CAMPO"
			if !empty(getSX3Cache(::cFieldCopy,"X3_CBOX"))
				xRet := "COMBO"
			else
				if getSX3Cache(::cFieldCopy,"X3_TIPO") == "L"
					xRet := "CHECK"
				else
					xRet := "GET"
				endif
			endif
		elseif cFieldX3 == "X3_PICTURE"
			xRet := getSX3Cache(::cFieldCopy,cFieldX3)
			cTipo := getSX3Cache(::cFieldCopy,"X3_TIPO")
			if empty(xRet) .and. cTipo == "C"
				xRet := "@X"
			endif
		elseif cFieldX3 == "CBOX"
			xRet := getX3Box(::cFieldCopy,.f.)
		elseif cFieldX3 == "LENBOX"
			xRet := getX3Box(::cFieldCopy,.t.)
		elseif cFieldX3 == "X3_VALID"
			xRet := alltrim(getSX3Cache(::cFieldCopy,cFieldX3))
			cVldUser := alltrim(getSX3Cache(::cFieldCopy,"X3_VLDUSER"))

			if !empty(xRet) .and. !empty(cVldUser)
				xRet += " .and. "
			endif

			xRet += cVldUser
		elseif SX3->(FieldPos(cFieldX3)) > 0 .and. !empty(::cFieldCopy) .and. valType(::oStruct) == "O"
			nPos := aScan(::aDePara,{|X|X[1] == cFieldX3})
			if nPos > 0
				nPosProperty := ::aDePara[nPos,2]

				if ::lModel
					lFieldStr := ::oStruct:GetFieldPos(::cFieldCopy) > 0
				else
					lFieldStr := ::oStruct:HasField(::cFieldCopy)
				endif

				if lFieldStr
					xRet := ::oStruct:getProperty(::cFieldCopy,nPosProperty)
				else
					xRet := getSX3Cache(::cFieldCopy,cFieldX3)

					if cFieldX3 == "X3_CONTEXT"
						xRet := xRet == "V"
					endif
				endif
			endif
		endif
	endif

	Do Case
	Case cFieldX3 $ "X3_VALID/X3_VLDUSER"
		if empty(xRet)
			xRet := ".t."
		endif

		xRet := FWBuildFeature( STRUCT_FEATURE_VALID	, xRet	)
	Case cFieldX3 == "PICTVAR"
		if !empty(xRet)
			xRet := FWBuildFeature( STRUCT_FEATURE_PICTVAR	, xRet	)
		endif
	Case cFieldX3 == "X3_WHEN"
		if empty(xRet)
			xRet := ".t."
		endif

		xRet := FWBuildFeature( STRUCT_FEATURE_WHEN	, xRet	)

	Case cFieldX3 == "X3_RELACAO"
		if !empty(xRet)
			xRet := FWBuildFeature( STRUCT_FEATURE_INIPAD	, xRet	)
		endif
	End Case
return xRet
/*/{Protheus.doc} addFieldFromX3
Adiciona um campo a estrutura de metadado da classe
Não considera os campos abaixo, caso seja necessario esses campso passar no parametro aOption
X3_VALID
X3_VLDUSER
X3_WHEN
X3_OBRIGAT
X3_RELACAO
@author Tiago Faria
@since 06/11/2018
@version undefined
@param oStruct, object, Objeto FWFormModelStruct
@param cFieldCopy, characters, Campo do SX3 que será tomado como base para criar o novo campo
@param cIdNewField, characters, ID do novo campo criado, se for vazio assume o ID passado no parametro cFieldCopy
@param aOption, array, Array com opções 
@param lModel, logical, Indica se deve ser criado a estrutura do campo do model se true, se false cria a estrutura da view
@param lVirtual, logical, indica se o campo é virtual default LVIRTUAL = TRUE
@type function
/*/
method addFieldFromX3(oStruct,cFieldCopy,cIdNewField,aOption,lModel,lVirtual) class IPUtilMVC
	default lModel 	:= FwIsInCallStack("modeldef")
	default lVirtual := .t.
	default cIdNewField := ""
	default aOption := {}

	::oStruct		:= oStruct
	::cFieldCopy 	:= cFieldCopy
	::lModel		:= lModel

	if empty(cIdNewField)
		cIdNewField := cFieldCopy
	endif

	aAdd(aOption,{"X3_CONTEXT",lVirtual})

	if lModel
		getModelDePara(@::aDePara)
		oStruct:AddField(  ;
			::getProperty("X3_TITULO",aOption)				, ; // [01] Titulo do campo
		::getProperty("X3_DESCRIC",aOption)				, ; // [02] ToolTip do campo
		cIdNewField       								, ; // [03] Id do Field
		::getProperty("X3_TIPO",aOption)				, ; // [04] Tipo do campo
		::getProperty("X3_TAMANHO",aOption)				, ;	// [05] Tamanho do campo
		::getProperty("X3_DECIMAL",aOption)				, ; // [06] Decimal do campo
		::getProperty("X3_VALID",aOption,.t.)			, ;	// [07] Code-block de validação do campo
		::getProperty("X3_WHEN",aOption,.t.)			, ; // [08] Code-block de validação When do campo
		::getProperty("CBOX",aOption)					, ; // [09] Lista de valores permitido do campo
		::getProperty("X3_OBRIGAT",aOption,.t.)			, ; // [10] Indica se o campo tem preenchimento obrigatório
		::getProperty("X3_RELACAO",aOption,.t.)			, ; // [11] Code-block de inicializacao do campo
		::getProperty("CHAVE",aOption,.t.)   			, ; // [12] Indica se trata-se de um campo chave
		::getProperty("UPDATE",aOption,.t.)				, ; // [13] Indica se o campo pode receber valor em uma operação de update.
		::getProperty("X3_CONTEXT",aOption) 	)  			// [14] Indica se o campo ó virtual
	else
		getViewDePara(@::aDePara)
		oStruct:AddField( 						  ;      // Ord. Tipo Desc.
		cIdNewField                       		, ;      // [01]  C   Nome do Campo
		::getProperty("X3_ORDEM",aOption)		, ;      // [02]  C   Ordem
		::getProperty("X3_TITULO",aOption)		, ;      // [03]  C   Titulo do campo
		::getProperty("X3_DESCRIC",aOption)		, ;      // [04]  C   Descricao do campo
		::getProperty("HELP",aOption)			, ;      // [05]  A   Array com Help
		::getProperty("TIPO_CAMPO",aOption)		, ;      // [06]  C   Tipo do campo
		::getProperty("X3_PICTURE",aOption)		, ;      // [07]  C   Picture
		::getProperty("PICTVAR",aOption)		, ;      // [08]  B   Bloco de Picture Var
		::getProperty("X3_F3",aOption)			, ;      // [09]  C   Consulta F3
		.T./*::getProperty("X3_VISUAL",aOption)*/, ;     // [10]  L   Indica se o campo ó alteravel
		::getProperty("X3_FOLDER",aOption)		, ;      // [11]  C   Pasta do campo
		::getProperty("X3_FOLDER",aOption)		, ;      // [12]  C   Agrupamento do campo
		::getProperty("CBOX",aOption)			, ;      // [13]  A   Lista de valores permitido do campo (Combo)
		::getProperty("LENBOX",aOption)			, ;      // [14]  N   Tamanho maximo da maior opção do combo
		::getProperty("X3_INIBRW",aOption,.t.)	, ;  	 // [15]  C   Inicializador de Browse
		::getProperty("X3_CONTEXT",aOption)		, ;      // [16]  L   Indica se o campo ó virtual
		::getProperty("X3_PICTVAR",aOption)		, ;      // [17]  C   Picture Variavel
		NIL                                	)   	     // [18]  L   Indica pulo de linha após o campo
	endif
return

static function myGetX3(cFieldCopy,cFieldX3,aOption,lOnlyArray)
	local xRet 	:= nil
	local nPos	:= aScan(aOption,{|X|alltrim(X[1]) == cFieldX3 })

	if nPos > 0
		xRet := aOption[nPos,2]

		Do Case
		Case cFieldX3 == "X3_VALID"
			if !empty(xRet)
				xRet := FWBuildFeature( STRUCT_FEATURE_VALID	, xRet	)
			endif
		Case cFieldX3 == "PICTVAR"
			if !empty(xRet)
				xRet := FWBuildFeature( STRUCT_FEATURE_PICTVAR	, xRet	)
			endif
		Case cFieldX3 == "X3_WHEN"
			if !empty(xRet)
				xRet := FWBuildFeature( STRUCT_FEATURE_WHEN	, xRet	)
			endif
		Case cFieldX3 == "X3_RELACAO"
			if !empty(xRet)
				xRet := FWBuildFeature( STRUCT_FEATURE_INIPAD	, xRet	)
			endif
		End Case
	elseif !lOnlyArray

	endif
return xRet

static function getX3Box(cField,lLenBox,lModel)
	local cBox 			:= getSX3Cache(cField,"X3_CBOX")
	local nInitCBox		:= 0
	local nMaxLenCombo 	:= 0
	local aTmp			:= {}
	local aRet			:= nil
	local nX			:= 0
	default lLenBox		:= .f.
	default lModel		:= FwIsInCallStack("modeldef")

	if lModel
		cBox := alltrim(cBox)
	endif

	If !Empty(cBox)
		aRet := {}
		aTmp := RetSX3Box(cBox,@nInitCBox,@nMaxLenCombo,getSX3Cache(cField,"X3_TAMANHO"))
		if lLenBox
			aRet := nMaxLenCombo
		else
			For nX := 1 to Len(aTmp)
				aAdd(aRet,aTmp[nx][1])
			Next nX

			//aAdd(aRet,aCombo)
			//aAdd(aRet,nMaxLenCombo)

		endif
	Endif
return aRet
/*/{Protheus.doc} removeTrigger
Remove todos os gatilhos da estrutura
@author Tiago Faria
@since 06/11/2018
@version undefined
@param oStruct, object, Objeto FWFormModelStruct
@type function
/*/
method removeTrigger(oStruct) class IPUtilMVC
	private oStr := oStruct
	if type("oStr:ATRIGGERS") == "A"

		oStruct:aTriggers := {}
	endif
return

/*/{Protheus.doc} removeFolders
Remove todas as pastas da estrutura
@author Tiago Faria
@since 06/11/2018
@version undefined
@param oStruct, object, Objeto FWFormModelStruct
@type function
/*/
method removeFolders(oStruct) class IPUtilMVC
	private oStr := oStruct
	if type("oStr:aFolders") == "A"

		oStruct:aFolders := {}
	endif
return
/*/{Protheus.doc} IPUtilMVC::addOtherFields
Adiciona no formulario outros campos que ainda não foram adicionados pela função FwFormSctruct desde que estes campos estejam no SX3
@type method
@version  1.0
@author Tiago Faria
@since 10/03/2019
@param oForm, object, Objeto FwFormStruct
@param xFields, character, string com todos os campos que devem estar no formulario separado por |
@param lModel, logical, Indica se deve carregar a estrutura no formato esperado pelo model ou pela view
/*/
method addOtherFields(oForm,xFields,lModel) class IPUtilMVC
	local aFields 	:= {}
	local nPosID	:= 0
	local nField	:= 0
	local cField	:= ""
	default xFields := ""
	default lModel := FwIsInCallStack("modeldef")

	nPosID := if(lModel,MODEL_FIELD_IDFIELD,MVC_VIEW_IDFIELD)

	if valType(xFields) == "C"
		aFields := StrToKarr(xFields,"|")
	endif

	for nField := 1 to len(aFields)
		cField := aFields[nField]

		if hasNotField(oForm,cField,nPosID) .and. isExistSX3(cField)
			::addFieldFromX3(@oForm,cField,cField,,lModel)
		endif
	next nField
return
/*/{Protheus.doc} updModel2Qry
Atualiza os campos de um modelo de dados (FWFormFieldsModel ou FWFormGridModel) atraves dos campos de uma query
@author Tiago Faria
@since 04/09/2019
@version 1.0
@param cAlias, characters, Alias da query, percorre o alias da query até chegar em final de arquivo
@param oForm, object, objeto do model (FWFormFieldsModel ou FWFormGridModel) a ser atualizado
@param lPosLine1, logical, se true indica que deve deixar o grid posicionado na primeira linha
@param lClearGrid, logical, Indica se deve limpar todo o conteudo do grid, utiliza a funcao do MVC FWFORMGRIDMODEL():ClearData(<lInit>,<lBlankLine>)
@param lInit, logical, Indica se deve carregar os inicializadores padrão no grid 
@param lBlankLine, logical, Indica se deve criar a linha em branco
@type function
/*/
method updModel2Qry(cAlias,oForm,lPosLine1,lLoadValue,lClearGrid,lInit,lBlankLine) class IPUtilMVC
	local cField       := ""
	local lBKPDelLine  := .t.
	local lBKPNewLine  := .t.
	local lBKPUpdLine  := .t.
	local lGrid        := oForm:ClassName() == "FWFORMGRID"
	local nField       := 0
	local oStruct      := oForm:getStruct()
	local oView        := FwViewActive()
	local nQtdField    := (cAlias)->(fCount())
	local xContent     := nil
	local nQtdLine     := 0
	local nLine        := 0
	local lRet         := .t.
	default lPosLine1  := .t.
	default lClearGrid := .t.
	default lInit      := .F.
	default lLoadValue := .t.

	runTcSetField(cAlias,oStruct)

	if lGrid
		lBKPDelLine := !oForm:CanDeleteLine()
		lBKPNewLine := !oForm:CanInsertLine()
		lBKPUpdLine := !oForm:CanUpdateLine()

		oForm:SetNoInsertLine(.f.)
		oForm:SetNoUpdateLine(.f.)
		oForm:SetNoDeleteLine(.f.)

		if lClearGrid
			oForm:ClearData(lInit,lBlankLine)
		endif
	endif

	while (cAlias)->(!Eof())
		if lGrid
			if oForm:length() == 0 .or. !oForm:isEmpty()
				nQtdLine := oForm:length()
				nLine := oForm:addLine()

				if nLine == nQtdLine
					oView:ShowLastError()
					lRet := .f.
					exit
				endif
			endif
		endif

		for nField := 1 to nQtdField
			cField   := (cAlias)->(fieldName(nField))
			xContent := (cAlias)->(&(cField))
			if !updGrid(cField,xContent,oForm,lLoadValue)
				oView:ShowLastError()
				lRet := .f.
				exit
			endif
		next nField

		if !oForm:VldLineData()
			lRet := .f.
			oView:ShowLastError()
			exit
		endif

		(cAlias)->(dbSkip())
	enddo

	if lRet .and. lGrid
		if lPosLine1
			oForm:goLine(1)
		endif

		oForm:SetNoInsertLine(lBKPNewLine)
		oForm:SetNoUpdateLine(lBKPUpdLine)
		oForm:SetNoDeleteLine(lBKPDelLine)
	endif

	oView:refresh(oForm:cID)
return lRet
/*/{Protheus.doc} loadGrid
Retorna array para carga manual do grid, facilitando a implementação do bloco de código bLoad no método MPFORMMODEL():AddGrid
@author Tiago Faria
@since 04/09/2019
@version 1.0
@return array, retorna array no formato esperado do parametro bLoad FWFORMMODEL():AddFields([ cId ], [ cOwner ], [ oModelStruct ], [ bPre ], [ bPost ], [ bLoad ])-
@param cQuery, characters, Query a ser executada
@param oGridModel, object, objeto de grid para avaliar a estrutura dos campos x query
@param cAliasParam, character, Alias da query caso não passe o parametro 1
@type function
/*/
method loadGrid(cQuery,oGridModel,cAliasParam) class IPUtilMVC
	local aLoad 	:= {}
	local cAlias 	:= {}
	local bAction	:= {|cField,xContent| aAdd(aFields,xContent), .t.}
	local nRecno	:= 0
	local lRecno	:= .t.
	private oStruct	:= oGridModel:getStruct()
	private oGrid	:= oGridModel
	private aFields	:= {}
	default cAliasParam := ""

	if empty(cAliasParam)
		cAlias := runQuery(cQuery,oStruct)
	else
		cAlias := cAliasParam
	endif
	lRecno := (cAlias)->(fieldPos("RECNO")) > 0

	if (cAlias)->(eof())
		eachField(cAlias,bAction,oGridModel)
		aAdd(aLoad,{nRecno,aClone(aFields)})
	endif

	while (cAlias)->(!eof())
		aFields := {}
		if lRecno
			nRecno := (cAlias)->(RECNO)
		endif

		eachField(cAlias,bAction,oGridModel)

		aAdd(aLoad,{nRecno,aClone(aFields)})

		(cAlias)->(dbSkip())
	enddo

	(cAlias)->(dbCloseArea())
return aLoad
/*/{Protheus.doc} IPUtilMVC::updOrdem
Atualiza a ordem da view de acordo com a ordem passada no parametro xFields
@type method
@version  1.0
@author Tiago Faria
@since 10/03/2019
@param oStruct, object, Objeto FwFormStruct()
@param xFields, character, Array ou string separadada por | com a ordem dos campos
/*/
method updOrdem(oStruct,xFields) class IPUtilMVC
	local cField := ""
	local nField := 0
	local cOrdem := "00"
	local aFields := {}
	default xFields := ""

	if valType(xFields) == "C"
		aFields := strToKarr(xFields,"|")
	else
		aFields := xFields
	endif

	nField := len(aFields)
	for nField := 1 to len(aFields)
		cField := aFields[nField]
		if oStruct:hasField(cField)
			cOrdem := soma1(cOrdem)
			oStruct:SetProperty(cField,MVC_VIEW_ORDEM,cOrdem)
		endif
	next nField
return
/*/{Protheus.doc} IPUtilMVC::addLineGrid
Adiciona linhas no grid de acordo com o resultado de uma query
@type method
@version 1.0
@author Tiago Faria
@since 10/03/2021
@param cQuery, character, Query a ser executada
@param oGrid, object, Objeto do grid que deverá ser adicionado as linhas
@param lLoadValue, object, Indica se deve usar o método FWFORMGRIDMODEL():LoadValue() para atribuir os valores no grid, caso seja false utiliza o método FWFORMGRIDMODEL():SetValue()
@param lClearGrid, logical, Indica se deve limpar todo o conteudo do grid, utiliza a funcao do MVC FWFORMGRIDMODEL():ClearData(<lInit>,<lBlankLine>)
@param lInit, logical, Indica se deve carregar os inicializadores padrão no grid 
@param lBlankLine, logical, Indica se deve criar a linha em branco
@return logical, se true as linhas foram inseridos com sucesso, se false houve erro
/*/
method addLineGrid(cQuery,oGrid,lLoadValue,lClearGrid,lInit,lBlankLine) class IPUtilMVC
	Private cAlias     := runQuery(cQuery,oGrid:getStruct())
return ::updModel2Qry(cAlias,oGrid,.t./*lPosLine1*/,lLoadValue,lClearGrid,lInit,lBlankLine)
/*/{Protheus.doc} IPUtilMVC::addFieldBMP
Adiciona um campo virtual do tipo Caracter com a picture @BMP para criação de legendas ou campos mark
@type method
@version  1.0
@author Tiago Faria
@since 18/03/2021
@param oStruct, object, Objeto FwFormStruct 
@param cID, character, ID do campo
@param cTitle, character, Titulo do campo, Default "Legenda"
@param nTamanho, numeric, Tamanho do campo, Default 50
@param cSeq, character, Sequencia que o campo será exibido na View, default "00"
@param cInicializador, character, valor para inicializacao do campo
@param lModel, logical, Indica se a estrutura a ser adicionada é do Model, caso a variavel for false adiciona a estrutura da view, default lMOdel := FwIsInCallStack("modeldef")
/*/
method addFieldBMP(oStruct,cID,cTitle,nTamanho,cSeq,lModel,cInicializador) class IPUtilMVC
	default cID 		:= ""
	default cTitle 		:= "Legenda"
	default nTamanho 	:= 50
	default cSeq		:= "00"
	default lModel := FwIsInCallStack("modeldef")
	default cInicializador := ""

	if lModel
		oStruct:AddField( ;
			cTitle , ; 					// [01] C Titulo do campo
		cTitle , ; 					// [02] C ToolTip do campo
		cID , ;           			// [03] C identificador (ID) do Field
		'C' , ;                     // [04] C Tipo do campo
		nTamanho , ;                // [05] N Tamanho do campo
		0 , ;                       // [06] N Decimal do campo
		NIL , ;                     // [07] B Code-block de validação do campo
		NIL , ;                     // [08] B Code-block de validação When do campo
		NIL , ;                     // [09] A Lista de valores permitido do campo
		NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
		FWBuildFeature( STRUCT_FEATURE_INIPAD, cInicializador) ,;// [11] B Code-block de inicializacao do campo
		NIL , ;                     // [12] L Indica se trata de um campo chave
		NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
		.T. )
	else
		oStruct:AddField( ;            			// Ord. Tipo Desc.
		cID                  			, ;   	// [01]  C   Nome do Campo
		cSeq                         	, ;     // [02]  C   Ordem
		cTitle        					, ;     // [03]  C   Titulo do campo
		cTitle       					, ;     // [04]  C   Descricao do campo
		{ cTitle } 						, ;     // [05]  A   Array com Help
		'C'                             , ;     // [06]  C   Tipo do campo
		'@BMP'                			, ;     // [07]  C   Picture
		NIL                             , ;     // [08]  B   Bloco de Picture Var
		''                              , ;     // [09]  C   Consulta F3
		.F.                             , ;     // [10]  L   Indica se o campo é alteravel
		NIL                             , ;     // [11]  C   Pasta do campo
		NIL                             , ;     // [12]  C   Agrupamento do campo
		NIL				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
		NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
		NIL                             , ;     // [15]  C   Inicializador de Browse
		.T.                             , ;     // [16]  L   Indica se o campo é virtual
		NIL                             , ;     // [17]  C   Picture Variavel
		NIL                             )       // [18]  L   Indica pulo de linha após o campo
	endif
return
/*/{Protheus.doc} IPUtilMVC::addFieldBMP
Adiciona um campo virtual do tipo Caracter com a picture @BMP para criação de legendas ou campos mark
@type method
@version  1.0
@author Tiago Faria
@since 31/03/2021
@param oStruct, object, Objeto FwFormStruct 
@param cID, character, ID do campo
@param cTitle, character, Titulo do campo, Default "Legenda"
@param nTamanho, numeric, Tamanho do campo, Default 50
@param cSeq, character, Sequencia que o campo será exibido na View, default "00"
@param cValid, character, Code-block de validação do campo
@param lModel, logical, Indica se a estrutura a ser adicionada é do Model, caso a variavel for false adiciona a estrutura da view, default lMOdel := FwIsInCallStack("modeldef")
/*/
method addFieldBT(oStruct,cID,cTitle,nTamanho,cSeq,lModel,cValid) class IPUtilMVC
	default cID 		:= ""
	default cTitle 		:= "Botão"
	default nTamanho 	:= 50
	default cSeq		:= "00"
	default lModel := FwIsInCallStack("modeldef")
	default cValid := ""

	if lModel
		oStruct:AddField( ;
			cTitle, ; 										// [01] C Titulo do campo
		cTitle, ; 										// [02] C ToolTip do campo
		cID , ;           								// [03] C identificador (ID) do Field
		'BT' , ;                    					// [04] C Tipo do campo
		nTamanho , ;                					// [05] N Tamanho do campo
		0 , ;                       					// [06] N Decimal do campo
		FwBuildFeature( STRUCT_FEATURE_VALID,cValid), ;	// [07] B Code-block de validação do campo
		NIL , ;                     					// [08] B Code-block de validação When do campo
		{}  , ;                     					// [09] A Lista de valores permitido do campo
		.F. , ;                     					// [10] L Indica se o campo tem preenchimento obrigatório
		NIL ,;								            // [11] B Code-block de inicializacao do campo
		.F. , ;                     					// [12] L Indica se trata de um campo chave
		.F. , ;                     					// [13] L Indica se o campo pode receber valor em uma operação de update.
		.T. )											//[14] L Indica se o Campo é Virtual
	else
		oStruct:AddField( ;            			// Ord. Tipo Desc.
		cID                  			, ;   	// [01]  C   Nome do Campo
		cSeq                         	, ;     // [02]  C   Ordem
		cTitle          			    , ;     // [03]  C   Titulo do campo
		cTitle      					, ;     // [04]  C   Descricao do campol
		NIL          					, ;     // [05]  A   Array com Help
		'BT'                            , ;     // [06]  C   Tipo do campo
		'@BMP'	                		, ;     // [07]  C   Picture
		NIL                             , ;     // [08]  B   Bloco de Picture Var
		NIL                             , ;     // [09]  C   Consulta F3
		.T.                             , ;     // [10]  L   Indica se o campo é alteravel
		NIL                             , ;     // [11]  C   Pasta do campo
		NIL                             , ;     // [12]  C   Agrupamento do campo
		NIL				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
		NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
		NIL                             , ;     // [15]  C   Inicializador de Browse
		.T.                             , ;     // [16]  L   Indica se o campo é virtual
		NIL                             , ;     // [17]  C   Picture Variavel
		NIL                             )       // [18]  L   Indica pulo de linha após o campo
	endif
return

/*
Percorre todos os campos do alias recebido como parametro e executa o bloco de codigo passando o id do campo + conteudo
{|cField,xContent| updGrid(cField,xContent)}
Autor: Tiago Faria
*/
static function eachField(cAlias,bAction,oGrid)
	local oStruct	:= oGrid:getStruct()
	local aFields	:= oStruct:getFields()
	local nQtdField := len(aFields)
	local nField	:= 0
	local cField	:= ""
	local lRet		:= .t.
	default bAction := {||.t.}

	for nField := 1 to nQtdField
		cField 		:= aFields[nField,MODEL_FIELD_IDFIELD]

		if (cAlias)->(fieldPos(cField)) > 0
			xContent	:= (cAlias)->&(cField)
			if valType(xContent) == "C" .and. subStr(xContent,1,2) == CHAR_MACRO
				xContent := &(StrTran(xContent,CHAR_MACRO,""))
			endif

			if !eval(bAction,cField,xContent,oGrid)
				lRet := .f.
			endif
		else
			alert(cField + " nao existe na query revise a função " + CRLF + procname(1) + CRLF + procname(2) + CRLF + procname(3))
		endif
	next nField
return lRet

static function getModelDePara(aDePara)
	aAdd(aDePara,{"X3_TITULO"	,MODEL_FIELD_TITULO})
	aAdd(aDePara,{"X3_DESCRIC"	,MODEL_FIELD_TOOLTIP})
	aAdd(aDePara,{"X3_TIPO"		,MODEL_FIELD_TIPO})
	aAdd(aDePara,{"X3_TAMANHO"	,MODEL_FIELD_TAMANHO})
	aAdd(aDePara,{"X3_DECIMAL"	,MODEL_FIELD_DECIMAL})
	aAdd(aDePara,{"X3_WHEN"		,MODEL_FIELD_WHEN})
	aAdd(aDePara,{"X3_OBRIGAT"	,MODEL_FIELD_OBRIGAT})
	aAdd(aDePara,{"X3_RELACAO"	,MODEL_FIELD_INIT})
	aAdd(aDePara,{"UPDATE"		,MODEL_FIELD_NOUPD})
	aAdd(aDePara,{"X3_TIPO"		,MODEL_FIELD_TIPO})
	aAdd(aDePara,{"X3_CONTEXT"	,MODEL_FIELD_VIRTUAL})
	aAdd(aDePara,{"CBOX"		,MODEL_FIELD_VALUES})
return

static function getViewDePara(aDePara)
	aAdd(aDePara,{"X3_ORDEM"	,MVC_VIEW_ORDEM})
	aAdd(aDePara,{"X3_TITULO"	,MVC_VIEW_TITULO})
	aAdd(aDePara,{"X3_DESCRIC"	,MVC_VIEW_DESCR})
	aAdd(aDePara,{"HELP"		,MVC_VIEW_HELP})
	aAdd(aDePara,{"TIPO_CAMPO"	,MVC_VIEW_ORDEM})
	aAdd(aDePara,{"X3_PICTURE"	,MVC_VIEW_PICT})
	aAdd(aDePara,{"PICTVAR"		,MVC_VIEW_PVAR})
	aAdd(aDePara,{"X3_F3"		,MVC_VIEW_LOOKUP})
	aAdd(aDePara,{"X3_VISUAL"	,MVC_VIEW_CANCHANGE})
	aAdd(aDePara,{"X3_FOLDER"	,MVC_VIEW_FOLDER_NUMBER})
	aAdd(aDePara,{"X3_FOLDER"	,MVC_VIEW_GROUP_NUMBER})
	aAdd(aDePara,{"CBOX"		,MVC_VIEW_COMBOBOX})
	aAdd(aDePara,{"LENBOX"		,MVC_VIEW_MAXTAMCMB})
	aAdd(aDePara,{"X3_INIBRW"	,MVC_VIEW_INIBROW})
	aAdd(aDePara,{"X3_CONTEXT"	,MVC_VIEW_VIRTUAL})
return

static function hasNotField(oForm,cField,nPosID)
	local lRet := aScan(oForm:getFields(),{|aField|aField[nPosID]==cField}) == 0
return lRet

static function runQuery(cQuery,oStruct)
	local cAlias     := ""

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	runTcSetField(cAlias,oStruct)
return cAlias

Static Function updGrid(cField,xContent,oGrid,lLoadValue)
	local lRet         := .t.
	local oStruct      := oGrid:getStruct()
	default lLoadValue := .t.
	default lShowError := .t.

	If oStruct:getFieldPos(cField) > 0
		if lLoadValue
			lRet := oGrid:LoadValue(cField	,xContent)
		else
			lRet := oGrid:SetValue(cField	,xContent)
		endif
	Endif
Return lRet

static function isExistSX3(cField)
return !empty(getSX3Cache(cField,"X3_CAMPO"))

static function runTcSetField(cAlias,oStruct)
	local aFieldsStr := oStruct:getFields()
	local nQtdField	 := len(aFieldsStr)
	local cField	 := ""
	local cTipo		 := ""
	local nTamanho   := 0
	local nDecimal   := 0
	local nField     := 0

	for nField := 1 to nQtdField
		cField 		:= aFieldsStr[nField,MODEL_FIELD_IDFIELD]
		cTipo 		:= aFieldsStr[nField,MODEL_FIELD_TIPO ]
		nTamanho 	:= aFieldsStr[nField,MODEL_FIELD_TAMANHO]
		nDecimal	:= aFieldsStr[nField,MODEL_FIELD_DECIMAL]

		if (cAlias)->(fieldPos(cField)) > 0 .and. cTipo $ "D/N/L"
			TcSetField(cAlias,cField,cTipo,nTamanho,nDecimal)
		endif
	next nField
return
