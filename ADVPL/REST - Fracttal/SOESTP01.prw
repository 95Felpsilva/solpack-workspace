#include "TOTVS.CH"
#include "FWMVCDEF.CH"
#include "topconn.ch"
#include "fweditpanel.ch"

#define ROTINA_FILE				"SOESTP01.prw"
#define VERSAO_ROTINA			"V" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[04])) + "-" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[05])) + "[" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[03])) + "]"
	
#define ALIAS_FORM0 			"ZZ8"
#define MODELO					"SOESTP01"
#define ID_MODEL				"SOMEST01"
#define TITULO_MODEL			"Log de Integração Fracttal " + SubStr(VERSAO_ROTINA,1,17)
#define TITULO_VIEW				TITULO_MODEL
#define ID_MODEL_FORM			ALIAS_FORM0+"FORM0"
#define ID_VIEW_FORM			"VIEW_FORM0"
#define PREFIXO_ALIAS_FORM0		Right(ALIAS_FORM0,03)

/*/{Protheus.doc} SOESTP01

Rotina para monitoramento dos logs de integração Protheus X Fracttal

@type function	
@author	Gabriel Pereira Santos - CRM Services
@since 14/02/2024
@version P11,P12
@database MSSQL
/*/
User Function SOESTP01(aAutoCab, nOperacao)
    Local oFwMBrowse		:= Nil
	Local cAliasForm 		:= ALIAS_FORM0
	Local cModelo			:= MODELO
	Local cTitulo			:= TITULO_MODEL
	Local bKeyCTRL_X		:= {|| }
	Local bFecharEdicao		:= {|| ( oView := FwViewActive(), Iif( Type("oView") == "O" , oView:ButtonCancelAction() , .F. ) ) }
	Local lRet				:= .F.

    Private aRotina		    := MenuDef()
	Private lAutoFAT61		:= ( ValType(aAutoCab) == "A" )

	If ( lAutoFAT61 )
		lRet := runAutoExecute(aAutoCab,nOperacao)
    Else 
        If ( FwAliasInDic(cAliasForm) )
            oFwMBrowse:= FWMBrowse():New()
            oFwMBrowse:SetAlias(cAliasForm)
            oFwMBrowse:SetDescription(cTitulo)
            oFwMBrowse:SetMenuDef(cModelo)
            
            oFwMBrowse:SetLocate()	
            oFwMBrowse:SetAmbiente(.F.)
            oFwMBrowse:SetWalkthru(.T.)
            oFwMBrowse:SetDetails(.T.)
            oFwMBrowse:SetSizeDetails(60)
            oFwMBrowse:SetSizeBrowse(40)

            oFwMBrowse:SetCacheView(.T.)

            oFwMBrowse:SetAttach( .T. )
            oFwMBrowse:SetOpenChart( .T. )
            
            bKeyCTRL_X	:= SetKey( K_CTRL_X, bFecharEdicao )

			oFwMBrowse:AddLegend( cAliasForm + "_STATUS == '1'", "GREEN"   , "Sucesso"    )
			oFwMBrowse:AddLegend( cAliasForm + "_STATUS == '2'", "RED"   	, "Erro"    )
                    
            oFwMBrowse:Activate()
            
            SetKey( K_CTRL_X, bKeyCTRL_X )
        Else
            MsgStop("Atenção! Alias da Tabela '" + cAliasForm + "' não encontrado nesse grupo de empresa.","MAFRA")
        Endif
    EndIf
	
Return lRet

/*
	Função que Define o Modelo de Dados do Cadastro
*/
Static Function ModelDef()
	Local cIDModel			    := ID_MODEL
	Local cTitulo			    := TITULO_MODEL
	Local cIDModelForm		    := ID_MODEL_FORM
	Local cAliasForm 		    := ALIAS_FORM0
	Local oStructForm 		    := Nil
	Local oModel 			    := Nil
	Local bActivate			    := {|oModel| activeForm(oModel) }
	Local bCommit			    := {|oModel| saveForm(oModel)}
	Local bPreValidacao		    := {|oModel| preValid(oModel)}
	Local bPosValidacao		    := {|oModel| posValid(oModel)} 
	
	Local cPrefForm			    := PREFIXO_ALIAS_FORM0
	Local cCpoFilial		    := cPrefForm+"_FILIAL"
	Local cCpoCodigo		    := cPrefForm+"_ID"
	
	oStructForm    := FWFormStruct( 1, cAliasForm )

	oModel	:= MPFormModel():New(cIdModel,bPreValidacao,bPosValidacao,bCommit,/*bCancel*/)
	
	oStructForm:SetProperty( cCpoCodigo  , MODEL_FIELD_INIT,  {|| NextNumero( cAliasForm, 1, cCpoCodigo, .T.) } )

	oModel:AddFields( cIDModelForm, /*cOwner*/, oStructForm,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
	
	oModel:SetPrimaryKey( { cCpoFilial, cCpoCodigo } )
	oModel:SetActivate(bActivate)
	oModel:SetDescription(cTitulo)
	oModel:GetModel(cIDModelForm):SetDescription(cTitulo)	                                              
    
Return oModel

/*
	Função que Cria a Interface do Cadastro
*/
Static Function ViewDef()
	Local cModelo				:= MODELO
	Local cIDModelForm			:= ID_MODEL_FORM
	Local cID0ViewForm			:= ID_VIEW_FORM
	Local cAliasForm 			:= ALIAS_FORM0
	Local oModel 				:= Nil
	Local oStructForm			:= Nil
	Local oView					:= Nil

	oModel 			:= FWLoadModel( cModelo )
	
	oStructForm    	:= FWFormStruct( 2, cAliasForm )

	oView 			:= FWFormView():New()

	oView:SetModel(oModel)

    oView:AddField(cID0ViewForm,oStructForm,cIDModelForm)

	oView:CreateHorizontalBox("SUPERIOR",100)
    
	oView:SetOwnerView( cID0ViewForm,"SUPERIOR" )

	oView:EnableTitleView(cID0ViewForm,"Cabeçalho")
	
	/*
	 FF_LAYOUT_VERT_DESCR_TOP - Vertical com descrição acima do get
	 FF_LAYOUT_VERT_DESCR_LEFT - Vertical com descrição a esquerda
	 FF_LAYOUT_HORZ_DESCR_TOP - Horizontal com descrição acima do get
	 FF_LAYOUT_HORZ_DESCR_LEFT - Horizontal com descrição a esquerda           
	*/
	oView:SetViewProperty(cID0ViewForm,"SETLAYOUT",{ FF_LAYOUT_VERT_DESCR_TOP , 5 } )
	
Return oView

/*
	Função que Monta o Menu da Rotina do Cadastro
*/
Static Function MenuDef()
	Local cModelo	:= MODELO 
	Local aRotina 	:= {}

    ADD OPTION aRotina TITLE 'Visualizar'           ACTION 'VIEWDEF.' + cModelo             OPERATION 2 ACCESS 0

Return aRotina

/*
	Função para Salvar os Dados do Cadastro usando MVC
*/ 
Static Function saveForm(oModel)
	Local lRet 			:= .T.

	FWModelActive(oModel)
	lRet := FWFormCommit(oModel)
	
Return lRet

/*
	Função executado no Cancelamento da Tela de Cadastro
*/ 
Static Function cancForm(oModel)
	Local nOperation	:= oModel:GetOperation()
	Local lRet			:= .T.

	If ( nOperation == MODEL_OPERATION_INSERT )
		RollBackSX8()
	EndIf		

Return lRet

/*
	Função para Validar os Dados Antes da Confirmação da Tela do Cadastro
*/
Static Function preValid(oModel)
	Local lRet			:= .T.
	
Return lRet

/*
	Função para Validar os Dados Após Confirmação da Tela de Cadastro - Verifica se pode incluir
*/
Static Function posValid(oModel)
	Local cIDModelForm	:= ID_MODEL_FORM
	Local cAliasForm 	:= ALIAS_FORM0
	Local nOperation	:= oModel:GetOperation()
	Local lRet			:= .T.

	Local cPrefForm		:= PREFIXO_ALIAS_FORM0
	Local cCpoCodigo	:= cPrefForm+"_ID"
	Local cFilCodigo	:= xFilial(cAliasForm) 
	Local cCodigo		:= oModel:GetValue(cIDModelForm,cCpoCodigo)	
	
	If ( nOperation == MODEL_OPERATION_INSERT )
		
		lRet := .F.
		
		Begin Sequence
		
			dbSelectArea(cAliasForm)
			(cAliasForm)->(dbSetOrder(1))
			If (cAliasForm)->(dbSeek(cFilCodigo+cCodigo))
				Help(,,"HELP",,"Atenção! A regra informada '" + AllTrim(cCodigo) + "' não pode ser utilizada pois já existe na base de dados para esta filial.",1,0)	
				Break
			Endif
		
			lRet := .T.
			
		End Sequence
		
	Endif

Return lRet

/*
	Função de Validação executada na Ativação do Modelo
*/
Static Function activeForm(oModel)
	Local lRet				:= .T.

Return lRet

/*
	Função que executa a carga dos dados no Formato aAutoCab
*/
Static Function runAutoExecute(aAutoCab,nOperacao)
	Local cAliasForm 	:= ALIAS_FORM0
	Local cIDModelForm	:= ID_MODEL_FORM
	Local cModelo		:= MODELO 
    Local cErro     	:= ""
    Local oModel    	:= FWLoadModel( cModelo )
    Local lRet      	:= .F.
    
    Private lMSHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.
    Private lMsErroAuto     := .F.
    
    FwMVCRotAuto( oModel , cAliasForm , nOperacao , { { cIDModelForm, aAutoCab } } )

    If !( lRet := !lMsErroAuto )
        cErro := getError(oModel)
    EndIf

	If !( lRet )
		addLogs(cErro)
	EndIf

Return lRet

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
	Tratamento de Logs para Rotina Automática e pela Interface com Solução
*/
Static Function addLogs(cLogs,cSolucao,lRet)
	Local aSolucao 	:= {}

	Default lRet	:= .F.

	If (!( lRet ))
		If (!Empty(cSolucao))
			aAdd( aSolucao , cSolucao )
		EndIf
		Help(,,"HELP " + ProcName(1),,cLogs,1,0, Nil, Nil, Nil, Nil, Nil, aSolucao )
	EndIf

Return
