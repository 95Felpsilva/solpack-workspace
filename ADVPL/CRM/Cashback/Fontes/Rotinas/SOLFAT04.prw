#include "TOTVS.CH"
#include "FWMVCDEF.CH"
#include "topconn.ch"
#include "fweditpanel.ch"
#include "SOLFAT04.ch"

#define ROTINA_FILE				"SOLFAT04.prw"
#define VERSAO_ROTINA			"V" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[04])) + "-" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[05])) + "[" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[03])) + "]"

#define MODELO					"SOLFAT04"
#define ID_MODEL				"SOMFAT04"
#define TITULO_MODEL			"Cashback - " + SubStr(VERSAO_ROTINA,1,17)
#define TITULO_VIEW				TITULO_MODEL
#define ID_MODEL_FORM0			ALIAS_FORM0+"FORM0"
#define ID_MODEL_GRID0			ALIAS_GRID0+"GRID0"
#define ID_MODEL_GRID1			ALIAS_GRID1+"GRID1"
#define ID_VIEW_FORM0			"VIEW_FORM0"
#define ID_VIEW_GRID0			"VIEW_GRID0"
#define ID_VIEW_GRID1			"VIEW_GRID1"

/*/{Protheus.doc} SOLFAT04
    Monitor de Cashback Solpack
    
    @author Gabriel Pereira Santos
    @since 26/04/2023
    @version P12
/*/ 
User Function SOLFAT04()
	Local oFwMBrowse		:= Nil
	Local cAliasForm 		:= ALIAS_FORM0
	Local cModelo			:= MODELO
	Local cTitulo			:= TITULO_MODEL
	Local bKeyCTRL_X		:= {|| }
	Local bFecharEdicao		:= {|| ( oView := FwViewActive(), Iif( Type("oView") == "O" , oView:ButtonCancelAction() , .F. ) ) }
	
    Private aRotina		:= MenuDef()
	
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
                
        oFwMBrowse:Activate()
        
        SetKey( K_CTRL_X, bKeyCTRL_X )
    Else
        MsgStop("Atenção! Alias da Tabela '" + cAliasForm + "' não encontrado nesse grupo de empresa.","MAFRA")
    Endif
	
Return

/*
	Função que Define o Modelo de Dados do Cadastro
*/
Static Function ModelDef()
	Local cIDModel			    := ID_MODEL
	Local cTitulo			    := TITULO_MODEL
	Local cIDModelForm		    := ID_MODEL_FORM0
	Local cIDModel0Grid		    := ID_MODEL_GRID0
	Local cIDModel1Grid		    := ID_MODEL_GRID1
	Local cAliasForm 		    := ALIAS_FORM0
	Local cAlias0Grid 		    := ALIAS_GRID0
	Local cAlias1Grid 		    := ALIAS_GRID1
	Local oStructForm 		    := Nil
	Local oStruct0Grid			:= Nil
	Local oStruct1Grid			:= Nil
	Local oModel 			    := Nil							 
	Local bActivate			    := {|oModel| activeForm(oModel) }
	Local bCommit			    := {|oModel| saveForm(oModel)}
	Local bPreValidacao		    := {|oModel| preValid(oModel)}
	Local bPosValidacao		    := {|oModel| posValid(oModel)} 
	
	Local cPrefForm			    := PREFIXO_ALIAS_FORM0
	Local cPref0Grid			:= PREFIXO_ALIAS_GRID0
	Local cPref1Grid			:= PREFIXO_ALIAS_GRID1
	Local cCpoFFilial		    := cPrefForm+"_FILIAL"
	Local cCpoFIDCash	        := cPrefForm+"_ID"
	Local cCpoFCliente	        := cPrefForm+"_CLIENT"
	Local cCpoFLoja	            := cPrefForm+"_LOJA"
	Local cCpoFNome	            := cPrefForm+"_NOME"
    Local cCpoG0Filial		    := cPref0Grid+"_FILIAL"
	Local cCpoG0ID	            := cPref0Grid+"_IDCASH"
	Local cCpoG0Produto         := cPref0Grid+"_PRODUT"
	Local cCpoG0Desc            := cPref0Grid+"_DESC"
    Local cCpoG1Filial		    := cPref1Grid+"_FILIAL"
	Local cCpoG1IDCash          := cPref1Grid+"_IDCASH"
	Local cCpoG1IDMovi          := cPref1Grid+"_IDMOVI"
	Local cCpoG1TpMovi          := cPref1Grid+"_TPMOV"
	
	oStructForm	:= FWFormStruct( 1, cAliasForm )	

	oModel	:= MPFormModel():New(cIdModel,bPreValidacao,bPosValidacao,bCommit,/*bCancel*/)
	
	oModel:AddFields( cIDModelForm, /*cOwner*/, oStructForm,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)	
	
	oModel:SetPrimaryKey( { cCpoFFilial, cCpoFIDCash, cCpoFCliente, cCpoFLoja } )
	oModel:SetActivate(bActivate)
	oModel:SetDescription(cTitulo)	
	oModel:GetModel(cIDModelForm):SetDescription(cTitulo)
	                                              
	oStructForm		:= FWFormStruct( 1, cAliasForm )
	oStruct0Grid 	:= FWFormStruct( 1, cAlias0Grid )
	oStruct1Grid 	:= FWFormStruct( 1, cAlias1Grid )

    oStructForm:SetProperty( cCpoFNome , MODEL_FIELD_INIT,  {|| Posicione("SA1",1,xFilial("SA1")+(cAliasForm)->&(cCpoFCliente)+(cCpoFLoja)->&(cCpoFIDCash), "A1_NOME") } )
    oStruct0Grid:SetProperty( cCpoG0Desc , MODEL_FIELD_INIT,  {|| Posicione("SB1",1,xFilial("SB1")+(cAlias0Grid)->&(cCpoG0Produto), "B1_DESC") } )
    oStruct1Grid:AddField("Legenda", "Legenda", "ZF3_LEGEND", "C", 50, 0, {||.T.}, {||.T.},,,{|oModel| getLegendaMov((cAlias1Grid)->&cCpoG1TpMovi)},,,.T.,)

	oModel:AddGrid(cIDModel0Grid,cIDModelForm,oStruct0Grid,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)
	oModel:GetModel(cIDModel0Grid):SetUniqueLine( { cCpoG0Produto } )
	oModel:SetRelation(cIDModel0Grid,{{cCpoG0Filial,'xFilial("'+cAliasForm+'")'},{cCpoG0ID,cCpoFIDCash}},(cAlias0Grid)->(IndexKey(1)))
	oModel:GetModel(cIDModel0Grid):SetDescription("Produtos")
	
    oModel:AddGrid(cIDModel1Grid,cIDModelForm,oStruct1Grid,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)
	oModel:GetModel(cIDModel1Grid):SetUniqueLine( { cCpoG1IDMovi } )
	oModel:SetRelation(cIDModel1Grid,{{cCpoG1Filial,'xFilial("'+cAliasForm+'")'},{cCpoG1IDCash,cCpoFIDCash}},(cAlias1Grid)->(IndexKey(1)))	
	oModel:GetModel(cIDModel1Grid):SetDescription("Movimentações")
	
	If !( IsBlind() )
		oModel:GetModel(cIDModel0Grid):SetNoInsertLine(.T.)
		oModel:GetModel(cIDModel0Grid):SetNoDeleteLine(.T.)
		oModel:GetModel(cIDModel1Grid):SetNoInsertLine(.T.)
		oModel:GetModel(cIDModel1Grid):SetNoDeleteLine(.T.)
	Endif
Return oModel

/*
	Função que Cria a Interface do Cadastro
*/
Static Function ViewDef()
	Local cModelo				:= MODELO
	Local cIDModelForm			:= ID_MODEL_FORM0
	Local cIDModel0Grid			:= ID_MODEL_GRID0
	Local cIDModel1Grid			:= ID_MODEL_GRID1
	Local cIDViewForm			:= ID_VIEW_FORM0
	Local cIDView0Grid			:= ID_VIEW_GRID0
	Local cIDView1Grid			:= ID_VIEW_GRID1
	Local cAliasForm 			:= ALIAS_FORM0
	Local cAlias0Grid 			:= ALIAS_GRID0
	Local cAlias1Grid 			:= ALIAS_GRID1
	Local cPrefForm			    := PREFIXO_ALIAS_FORM0
	Local cCpoFIDCash	        := cPrefForm+"_ID"
	Local oModel 				:= Nil
	Local oStructForm			:= Nil
	Local oStruct0Grid			:= Nil
	Local oStruct1Grid			:= Nil
	Local oView					:= Nil

	oModel 			:= FWLoadModel( cModelo )
	
	oStructForm		:= FWFormStruct( 2, cAliasForm )
	oStruct0Grid	:= FWFormStruct( 2, cAlias0Grid )	
	oStruct1Grid	:= FWFormStruct( 2, cAlias1Grid )

    oStruct1Grid:AddField("ZF3_LEGEND", "00", "", "",{"Legenda"}, "C", "@BMP",,"",.F., "","",{},0,"",.T.,"",.F.,0 ,)
	
	oView 			:= FWFormView():New()

	oView:SetModel(oModel)

    oView:AddField(cIDViewForm,oStructForm,cIDModelForm)
	oView:AddGrid(cIDView0Grid,oStruct0Grid,cIDModel0Grid)
	oView:AddGrid(cIDView1Grid,oStruct1Grid,cIDModel1Grid)
	
	oView:CreateHorizontalBox('SUPERIOR',20)
	oView:CreateHorizontalBox('CENTRO',40)
	oView:CreateHorizontalBox('INFERIOR',40)
	
	oView:SetOwnerView( cIDViewForm,'SUPERIOR' )
	oView:SetOwnerView( cIDView0Grid,'CENTRO' )
	oView:SetOwnerView( cIDView1Grid,'INFERIOR' )
	
	/*
	 FF_LAYOUT_VERT_DESCR_TOP - Vertical com descrição acima do get
	 FF_LAYOUT_VERT_DESCR_LEFT - Vertical com descrição a esquerda
	 FF_LAYOUT_HORZ_DESCR_TOP - Horizontal com descrição acima do get
	 FF_LAYOUT_HORZ_DESCR_LEFT - Horizontal com descrição a esquerda           
	*/
	oView:SetViewProperty(cIDViewForm,"SETLAYOUT",{ FF_LAYOUT_VERT_DESCR_TOP , 5 } )
	
	oView:SetViewProperty(cIDView0Grid,"ENABLENEWGRID")
	oView:SetViewProperty(cIDView0Grid,"GRIDFILTER")
	oView:SetViewProperty(cIDView0Grid,"GRIDSEEK")	
	
    oView:SetViewProperty(cIDView1Grid,"ENABLENEWGRID")
	oView:SetViewProperty(cIDView1Grid,"GRIDFILTER")
	oView:SetViewProperty(cIDView1Grid,"GRIDSEEK")	

	oView:AddUserButton( "Recálculo", 'EXECUTE', {|oView| Processa( {|| faturamento.MonitorCashback.u_recalculoCashback((cAliasForm)->&(cCpoFIDCash)) }, "Recálculo", "Processando recálculo...", .F.) } )

Return oView

/*
	Função que Monta o Menu da Rotina do Cadastro
*/
Static Function MenuDef()
	Local cModelo	:= MODELO 
	Local aRotina 	:= {}

    ADD OPTION aRotina TITLE 'Visualizar'           ACTION 'VIEWDEF.' + cModelo             OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'              ACTION 'VIEWDEF.' + cModelo             OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Relatório'            ACTION 'u_SOLFAT08()'             		OPERATION 8 ACCESS 0
    ADD OPTION aRotina TITLE 'Envia Workflow'       ACTION 'processa( {|| u_SOLFAT07()}, "Worflow", "Processando aguarde...", .F.)'	OPERATION 8 ACCESS 0
	
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
	Local cIDModelForm	:= ID_MODEL_FORM0
	Local cAliasForm 	:= ALIAS_FORM0
	Local nOperation	:= oModel:GetOperation()
	Local lRet			:= .T.

	Local cPrefForm		:= PREFIXO_ALIAS_FORM0
	Local cCpoID	    := cPrefForm+"_ID"
	Local cFilCodigo	:= xFilial(cAliasForm) 
	Local cID		    := oModel:GetValue(cIDModelForm,cCpoID)	
	
	If ( nOperation == MODEL_OPERATION_INSERT )
		
		lRet := .F.
		
		Begin Sequence
		
			dbSelectArea(cAliasForm)
			(cAliasForm)->(dbSetOrder(1))
			If (cAliasForm)->(dbSeek(cFilCodigo+cID))
				Help(,,"HELP",,"Atenção! A regra informada '" + AllTrim(cID) + "' não pode ser utilizada pois já existe na base de dados para esta filial.",1,0)	
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
	Rotina para definir legenda dos movimentos
*/
Static Function getLegendaMov(cTipoMov)
	Local cLegenda := ""

	Do Case
		Case ( cTipoMov == "1" )
			cLegenda := "BR_VERDE"
		Case ( cTipoMov == "2" )
			cLegenda := "BR_VERMELHO"
		Case ( cTipoMov == "3" )
			cLegenda := "BR_AZUL"
	End Case

Return cLegenda
