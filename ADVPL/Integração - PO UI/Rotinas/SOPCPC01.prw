#include "TOTVS.CH"
#include "FWMVCDEF.CH"
#include "topconn.ch"
#include "fweditpanel.ch"
#include "TBICONN.ch"

#define ROTINA_FILE				"SOPCPC01.prw"
#define VERSAO_ROTINA			"V" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[04])) + "-" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[05])) + "[" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[03])) + "]"

#define ALIAS_FORM0 			"ZO2"
#define MODELO					"SOPCPC01"
#define ID_MODEL				"SOMPCP01"
#define TITULO_MODEL			"Programação Ordem de Produção"// + SubStr(VERSAO_ROTINA,1,17)
#define TITULO_VIEW				TITULO_MODEL
#define ID_MODEL_FORM			ALIAS_FORM0+"FORM0"
#define ID_VIEW_FORM			"VIEW_FORM0"
#define PREFIXO_ALIAS_FORM0		Right(ALIAS_FORM0,03)

#define TIPO_OPERACAO_INCLUSAO	1
#define TIPO_OPERACAO_ATUALIZA	2
#define TIPO_OPERACAO_FECHAR	3

/*/{Protheus.doc} SOPCPC01

Rotina de monitor de progração de OP

@type function	
@author	Gabriel Pereira Santos - CRM Services
@since 29/04/2024
@version P11,P12
@database MSSQL
/*/
User Function SOPCPC01(aAutoCab, nOperacao)
	Local oFwMBrowse		:= Nil
	Local cAliasForm 		:= ALIAS_FORM0
	Local cModelo			:= MODELO
	Local cTitulo			:= TITULO_MODEL
	Local cVisaoDefault		:= "CUSTOMIZADOPCP"
	Local bKeyCTRL_X		:= {|| }
	Local bFecharEdicao		:= {|| ( oView := FwViewActive(), Iif( Type("oView") == "O" , oView:ButtonCancelAction() , .F. ) ) }
	Local oTableAtt 		:= FWTableAtt():New()
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

			bKeyCTRL_X	:= SetKey( K_CTRL_X, bFecharEdicao )

			oFwMBrowse:AddLegend("u_PC01DefLeg(1)", "BR_AMARELO"	, "Prevista")
			oFwMBrowse:AddLegend("u_PC01DefLeg(2)", "BR_VERDE"		, "Em aberto")
			oFwMBrowse:AddLegend("u_PC01DefLeg(3)", "BR_LARANJA"	, "Iniciada")
			oFwMBrowse:AddLegend("u_PC01DefLeg(4)", "BR_CINZA"		, "Ociosa")
			oFwMBrowse:AddLegend("u_PC01DefLeg(5)", "BR_AZUL"		, "Encerrada parcialmente")
			oFwMBrowse:AddLegend("u_PC01DefLeg(6)", "BR_VERMELHO"	, "Encerrada totalmente")

			oTableAtt:SetAlias(cAliasForm)
			oCustomizado := FWDSView():New()
			oCustomizado:SetID("CUSTOMIZADOPCP")
			oCustomizado:SetName("Customizado PCP")
			oCustomizado:SetCollumns({cAliasForm + "_FILIAL", cAliasForm + "_SETOR", cAliasForm + "_TEAR",;
				cAliasForm + "_PRODUT", cAliasForm + "_DESC", cAliasForm + "_CONV",;
				cAliasForm + "_DATPRI", cAliasForm + "_DATPRF", cAliasForm + "_NUM",;
				cAliasForm + "_QUANT",cAliasForm + "_QUJE", cAliasForm + "_ZQTOP1", cAliasForm + "_STATUS",;
				cAliasForm + "_OBS", cAliasForm + "_PRODIA", cAliasForm + "_PRIOR", cAliasForm + "_RECDES", cAliasForm + "_KGHREX", cAliasForm + "_EFICIE",;
				cAliasForm + "_KGPROD", cAliasForm + "_RPM", cAliasForm + "_PROMED"})
			oCustomizado:AddFilter("Status Em Aberto", + cAliasForm + "_STATUS <> '3' ")
			oCustomizado:SetOrder(3)
			oCustomizado:SetPublic(.T.)
			oCustomizado:SetLegend(.T.)
			oTableAtt:AddView(oCustomizado)

			oFwMBrowse:SetAttach(.T.)
			oFwMBrowse:SetOpenChart(.T.)
			oFwMBrowse:SetViewsDefault( oTableAtt:aViews )

			If ( !Empty(cVisaoDefault) )
				nScan := aScan( oTableAtt:aViews, { |x| x:cID == cVisaoDefault } )
				If ( nScan > 0 )
					oFwMBrowse:SetIDViewDefault( oTableAtt:aViews[nScan]:cID )
				EndIf
			EndIf

			oFwMBrowse:Activate()

			SetKey( K_CTRL_X, bKeyCTRL_X )
		Else
			MsgStop("Atenção! Alias da Tabela '" + cAliasForm + "' não encontrado nesse grupo de empresa.","Solpack")
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
	Local bTrig		        	:= {|oModel,cField,uVal| FieldTrigger(oModel,cField,uVal)}

	Local cPrefForm			    := PREFIXO_ALIAS_FORM0
	Local cCpoFilial		    := cPrefForm+"_FILIAL"
	Local cCpoOP		    	:= cPrefForm+"_NUM"
	Local cCpoRPM		    	:= cPrefForm+"_RPM"
	Local cCpoPMedia    		:= cPrefForm+"_PROMED"
	Local cCpoPMultiProd   		:= cPrefForm+"_MULTPR"
	Local cCpoPDataIni    		:= cPrefForm+"_DATPRI"
	Local cCpoKgHrEx    		:= cPrefForm+"_KGHREX"
	Local cCpoEficie    		:= cPrefForm+"_EFICIE"

	oStructForm    := FWFormStruct( 1, cAliasForm )

	oStructForm:AddTrigger(cCpoRPM, cCpoRPM,  { || .T. }, bTrig )
	oStructForm:AddTrigger(cCpoPMedia, cCpoPMedia,  { || .T. }, bTrig )
	oStructForm:AddTrigger(cCpoPMultiProd, cCpoPMultiProd,  { || .T. }, bTrig )
	oStructForm:AddTrigger(cCpoPDataIni, cCpoPDataIni,  { || .T. }, bTrig )
	oStructForm:AddTrigger(cCpoKgHrEx, cCpoKgHrEx, { || .T. }, bTrig )
	oStructForm:AddTrigger(cCpoEficie, cCpoEficie, { || .T. }, bTrig )

	oModel	:= MPFormModel():New(cIdModel,bPreValidacao,bPosValidacao,bCommit,/*bCancel*/)

	oModel:AddFields( cIDModelForm, /*cOwner*/, oStructForm,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

	oModel:SetPrimaryKey( { cCpoFilial, cCpoOP } )
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
	Local cPrefForm				:= PREFIXO_ALIAS_FORM0

	oModel 			:= FWLoadModel( cModelo )
	oStructForm    	:= FWFormStruct( 2, cAliasForm )
	oView 			:= FWFormView():New()

	oStructForm:SetProperty(cPrefForm + "_TEAR", MVC_VIEW_TITULO, 'Recurso')
	oStructForm:SetProperty(cPrefForm + "_KGHREX", MVC_VIEW_TITULO, 'KG/HORA da Extrusora')
	oStructForm:SetProperty(cPrefForm + "_RECDES", MVC_VIEW_TITULO, 'Desc Recurso')

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
	oView:AddUserButton( 'Atualizar Tela', 'CLIPS', {|oView| atualizaView() },'Atualiza Tela',VK_F5,,.F. )
Return oView

/*
	Função que Monta o Menu da Rotina do Cadastro
*/
Static Function MenuDef()
	Local cModelo	:= MODELO
	Local aRotina 	:= {}

	ADD OPTION aRotina TITLE 'Visualizar'           ACTION 'VIEWDEF.' + cModelo             OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'           	ACTION 'VIEWDEF.' + cModelo             OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'           	ACTION 'VIEWDEF.' + cModelo             OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Processa Programação' ACTION 'u_PCPC01ProcessaProgramacao()'  OPERATION 6 ACCESS 0
Return aRotina

/*
	Função para Salvar os Dados do Cadastro usando MVC
*/ 
Static Function saveForm(oModel)
	Local cPrefForm		:= PREFIXO_ALIAS_FORM0
	Local cIDModelForm	:= ID_MODEL_FORM
	Local cCpoOP		:= cPrefForm+"_NUM"
	Local cCpoTear		:= cPrefForm+"_TEAR"
	Local cCpoRPM		:= cPrefForm+"_RPM"
	Local cCpoPMedia    := cPrefForm+"_PROMED"
	Local cCpoPDia    	:= cPrefForm+"_PRODIA"
	Local cCpoPSetor    := cPrefForm+"_SETOR"
	Local cCpoKgHrEx	:= cPrefForm+"_KGHREX"
	Local cCpoEficie	:= cPrefForm+"_EFICIE"
	Local cNumOP		:= oModel:GetValue(cIDModelForm,cCpoOP)
	Local cTear			:= oModel:GetValue(cIDModelForm,cCpoTear)
	Local nRPM			:= oModel:GetValue(cIDModelForm,cCpoRPM)
	Local nProdMedia	:= oModel:GetValue(cIDModelForm,cCpoPMedia)
	Local nProdDia		:= oModel:GetValue(cIDModelForm,cCpoPDia)
	Local cSetor		:= oModel:GetValue(cIDModelForm,cCpoPSetor)
	Local nKgHrEx		:= oModel:GetValue(cIDModelForm,cCpoKgHrEx)
	Local nEficie		:= oModel:GetValue(cIDModelForm,cCpoEficie)
	Local lRet 			:= .T.

	FWModelActive(oModel)
	lRet := FWFormCommit(oModel)

	If ( lRet )
		Processa({|| alteraRPMOutrasOPs(cNumOP, cTear, nRPM, nProdMedia, nProdDia, cSetor, nKgHrEx, nEficie)}, "Atualizando RPM/Prod. diária...")
		Processa({|| processaProgramacao(, cTear, cSetor)}, "Calculando datas da programaão...")
	EndIf
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
	Local cCpoOP		:= cPrefForm+"_NUM"
	Local cFilCodigo	:= xFilial(cAliasForm)
	Local cNumOP		:= oModel:GetValue(cIDModelForm,cCpoOP)

	If ( nOperation == MODEL_OPERATION_INSERT )
		lRet := .F.

		Begin Sequence
			dbSelectArea(cAliasForm)
			(cAliasForm)->(dbSetOrder(1))
			If (cAliasForm)->(dbSeek(cFilCodigo+cNumOP))
				Help(,,"HELP",,"Atenção! A regra informada '" + AllTrim(cNumOP) + "' não pode ser utilizada pois já existe na base de dados para esta filial.",1,0)
				Break
			Endif

			lRet := .T.
		End Sequence
	Endif
Return lRet

/*
	Altera o valor de RPM e Produção diárias para demais OPs
	Que estejam em branco
*/
Static Function alteraRPMOutrasOPs(cOrdemProducao, cTear, nRPM, nProdMedia, nProdDia, cSetor, nKgHrEx, nEficie)
	Local cQuery		:= ""
	Local cAlias		:= ""
	Local cAliasForm	:= ALIAS_FORM0
	Local aArea  		:= FWGetArea()
	Local aAreas 		:= Lj7GetArea({cAliasForm})

	Default nKgHrEx		:= 0
	Default nEficie		:= 0

	If (!Empty(nRPM) .And. !Empty(nProdMedia) .And. !Empty(nProdDia)) .Or. (!Empty(nKgHrEx) .And. !Empty(nEficie))
		cQuery := getQryOPByStatus(cOrdemProducao, cTear, cSetor, "1,2")
		cAlias := MPSysOpenQuery(cQuery)

		While (cAlias)->(!Eof())
			(cAliasForm)->(dbSetOrder(1))
			(cAliasForm)->(dbGoTo((cAlias)->RECNO))

			Reclock(cAliasForm, .F.)
			If !Empty(nRPM) .And. !Empty(nProdMedia) .And. !Empty(nProdDia)
				(cAliasForm)->&(cAliasForm+"_RPM") 		:= nRPM
				(cAliasForm)->&(cAliasForm+"_PROMED") 	:= nProdMedia
				(cAliasForm)->&(cAliasForm+"_PRODIA") 	:= getQtdProduzir((cAliasForm)->&(cAliasForm+"_PRODUT"), (cAliasForm)->&(cAliasForm+"_NUM"), (cAliasForm)->&(cAliasForm+"_MULTPR"), nRPM, nProdMedia)
			EndIf

			If !Empty(nKgHrEx) .And. !Empty(nEficie)
				(cAliasForm)->&(cAliasForm+"_KGHREX") 	:= nKgHrEx
				(cAliasForm)->&(cAliasForm+"_EFICIE") 	:= nEficie
				If Empty((cAliasForm)->&(cAliasForm+"_PRODIA")) .Or. (Empty(nRPM) .And. Empty(nProdMedia))
					(cAliasForm)->&(cAliasForm+"_PRODIA") := nKgHrEx * 24 * ( nEficie / 100 )
				EndIf
			EndIf
			(cAliasForm)->(MsUnlock())

			// (cAliasForm)->(dbCloseArea()) // Removido para evitar fechar a tabela dentro do loop

			(cAlias)->(dbSkip())
		EndDo

		(cAlias)->(dbCloseArea())
	EndIf

	Lj7RestArea(aAreas)
	FWRestArea(aArea)
Return

/*
	Rotina para processar reprogramação de datas da OP em massa
*/
User Function PCPC01ProcessaProgramacao(lIsJob)
	Local cPrefForm		:= PREFIXO_ALIAS_FORM0
	Local cCpoTear		:= cPrefForm+"_TEAR"
	Local cTear			:= Space(GetSx3Cache(cCpoTear,"X3_TAMANHO"))
	Local cTitle		:= "Processar Programção de Datas"
	Local cQuery		:= ""
	Local cAlias		:= ""
	Local aParamBox     := {}

	Default lIsJob		:= .F.

	aAdd(aParamBox, {2, "Setor", "1", {"G0=G0","G1=G1","G2=G2","G3=G3"}, 80, ".T." , .T.})
	aAdd(aParamBox, {1, "Tear de", 	cTear, "", "", "", ".T.", 80, .F.})
	aAdd(aParamBox, {1, "Tear até", cTear, "", "!Empty(MV_PAR02)", "", ".T.", 80, .T.})

	If ( lIsJob )
		cQuery := getQryTearDisponivel(lIsJob)
	Else
		If ( ParamBox(aParamBox, cTitle) )
			cQuery := getQryTearDisponivel(lIsJob, MV_PAR01, MV_PAR02, MV_PAR03)
		EndIf
	EndIf

	If ( !Empty(cQuery) )
		cAlias := MPSysOpenQuery(cQuery)

		If (cAlias)->(!Eof())
			While (cAlias)->(!Eof())
				Processa({|| processaProgramacao(,(cAlias)->TEAR, (cAlias)->SETOR)}, "Calculando datas da programação...")
				(cAlias)->(dbSkip())
			EndDo

			FwAlertSuccess("Processo finalizado com sucesso!", "Solpack")
		Else
			FwAlertError("Nenhum tear disponível para processamento com os parâmetros informados", "Solpack")
		EndIf

		(cAlias)->(dbCloseArea())
	EndIf
Return

/*
	Monta query de teares disponíveis para reprocessamento de data
*/
Static Function getQryTearDisponivel(lIsJob, cSetor, cTearDe, cTearAte)
	Local cAliasForm 	:= ALIAS_FORM0
	Local cPrefForm		:= PREFIXO_ALIAS_FORM0
	Local cQuery		:= ""

	cQuery += "	SELECT " + CRLF
	cQuery += "		 " + cPrefForm + "_TEAR AS TEAR" + CRLF
	cQuery += "		 ," + cPrefForm + "_SETOR AS SETOR" + CRLF
	cQuery += "	FROM " + CRLF
	cQuery += "		" + RetSqlTab(cAliasForm) + CRLF
	cQuery += "	WHERE " + CRLF
	cQuery += "		1 = 1 " + CRLF
	cQuery += "		AND " + RetSqlFil(cAliasForm) + CRLF
	If !( lIsJob )
		cQuery += "		AND " + cPrefForm + "_TEAR BETWEEN " + ValToSql(cTearDe) + " AND " +  ValToSql(cTearAte) + CRLF
		cQuery += "		AND " + cPrefForm + "_SETOR = " + ValToSql(cSetor) + CRLF
	EndIf
	cQuery += "		AND " + cPrefForm + "_STATUS IN ('1', '2') " + CRLF
	cQuery += "		AND " + RetSqlDel(cAliasForm) + CRLF
	cQuery += "	GROUP BY " + CRLF
	cQuery += "		" + cPrefForm + "_TEAR" + CRLF
	cQuery += "		," + cPrefForm + "_SETOR" + CRLF
	cQuery += "	ORDER BY " + CRLF
	cQuery += "		" + cPrefForm + "_TEAR" + CRLF
	cQuery += "		," + cPrefForm + "_SETOR" + CRLF
Return cQuery

/*
	Rotina responsável por realizar cálculo da programação das datas com controle de saldo de capacidade diária
*/
Static Function processaProgramacao(cNumOP, cTear, cSetor)
	Local cAliasForm 	:= ALIAS_FORM0
	Local cPriorAnt		:= ""
	Local cPrior        := ""
	Local dIniPrior     := STOD("")
	Local dMaxFimPrior  := STOD("")
	Local lAtivo		:= GetNewPar("ES_ATVCADT", .T.)
	Local lProcessa		:= .F.
	Local nRecord		:= 0
	Local nProdDiaria	:= 0
	Local dDataIni		:= STOD("")
	Local dDataFim		:= STOD("")
	Local aArea  		:= FWGetArea()
	Local aAreas 		:= Lj7GetArea({cAliasForm})
	Local dPrimeiroAp	:= STOD("")
	Local nCapDiaria    := 0
	Local nQtdFalt      := 0
	Local nRest         := 0
	Local dCalcData     := STOD("")

	Default cNumOP		:= ""
	Default cTear		:= ""

	If ( lAtivo .And. !Empty(cTear))
		cQuery := getQryCalculoData(cTear, cSetor)
		cAlias := MPSysOpenQuery(cQuery)

		While !(cAlias)->(Eof())
			nRecord++
			cPrior := Alltrim(cValToChar((cAlias)->PRIORIDADE))

			dPrimeiroAp := getFirstApont((cAlias)->NUMOP)

			If nRecord == 1
				nProdDiaria := (cAlias)->PRODIARIA
				If Empty(nProdDiaria)
					FwAlertError("OP " + (cAlias)->NUMOP + " não está com a produção diária definida, não será possível realizar a programação das datas.", "Solpack")
					Exit
				EndIf
				dIniPrior := STOD((cAlias)->DATAINI)
				If Empty(dIniPrior)
					dIniPrior := Date()
				EndIf
				cPriorAnt    := cPrior
				dMaxFimPrior := dIniPrior
			EndIf

			If !Empty(cNumOP) .And. !lProcessa
				lProcessa := cNumOP == (cAlias)->NUMOP
			Else
				lProcessa := .T.
			EndIf

			If ( lProcessa )
				nCapDiaria := Iif(Empty((cAlias)->PRODIARIA), nProdDiaria, (cAlias)->PRODIARIA)
				If nCapDiaria <= 0
					nCapDiaria := 1
				EndIf

				nQtdFalt := (cAlias)->QTDOP - (cAlias)->QTDPROD
				If nQtdFalt < 0
					nQtdFalt := 0
				EndIf

				// Se mudou a prioridade, o novo grupo inicia no maior término da prioridade anterior
				If cPrior != cPriorAnt
					dIniPrior    := dMaxFimPrior
					cPriorAnt    := cPrior
					dMaxFimPrior := dIniPrior
				EndIf

				// Definição da Data Inicial da OP:
				If !Empty(dPrimeiroAp)
					dDataIni := dPrimeiroAp
				Else
					dDataIni := dIniPrior
				EndIf

				If Empty(dPrimeiroAp) .And. dDataIni < Date()
					dDataIni  := Date()
					dIniPrior := Date()
				EndIf

				// Cálculo da data final
				nRest     := nQtdFalt
				dCalcData := dDataIni

				If nRest > 0 .And. dCalcData < Date()
					dCalcData := Date()
				EndIf

				If nRest <= nCapDiaria
					dDataFim := dCalcData
				Else
					nRest -= nCapDiaria
					While nRest > 0
						dCalcData := somaDiasUteis(dCalcData, 2)
						If nRest <= nCapDiaria
							dDataFim := dCalcData
							nRest    := 0
						Else
							nRest    -= nCapDiaria
						EndIf
					EndDo
				EndIf

				If nQtdFalt > 0 .And. dDataFim < Date()
					dDataFim := Date()
				EndIf

				// Guarda o maior término entre as OPs da mesma prioridade
				If Empty(dMaxFimPrior) .Or. dDataFim > dMaxFimPrior
					dMaxFimPrior := dDataFim
				EndIf

				(cAliasForm)->(dbSetOrder(2))
				If ( (cAliasForm)->(MsSeek(xFilial(cAliasForm)+(cAlias)->NUMOP)) )
					RecLock(cAliasForm, .F.)
					(cAliasForm)->&(cAliasForm+"_DATPRI") 	:= dDataIni
					(cAliasForm)->&(cAliasForm+"_DATPRF") 	:= dDataFim
					(cAliasForm)->(MSUnlock())
				EndIf
			Else
				dDataFim := STOD((cAlias)->DATAFIM)
				If Empty(dMaxFimPrior) .Or. dDataFim > dMaxFimPrior
					dMaxFimPrior := dDataFim
				EndIf
			EndIf

			(cAlias)->(dbSkip())
		EndDo

		(cAlias)->(dbCloseArea())
	EndIf

	Lj7RestArea(aAreas)
	FWRestArea(aArea)
Return
/*
	Query para buscar OPs a serem alteradas as datas
*/
Static Function getQryCalculoData(cTear, cSetor)
	Local cAliasForm 	:= ALIAS_FORM0
	Local cPrefForm		:= PREFIXO_ALIAS_FORM0
	Local cQuery		:= ""

	cQuery += "	SELECT " + CRLF
	cQuery += "		 " + cPrefForm + "_NUM AS NUMOP" + CRLF
	cQuery += "		 ," + cPrefForm + "_QUANT AS QTDOP" + CRLF
	cQuery += "		 ," + cPrefForm + "_QUJE AS QTDPROD" + CRLF
	cQuery += "		 ," + cPrefForm + "_PRODIA AS PRODIARIA" + CRLF
	cQuery += "		 ,CASE WHEN C2_DATPRI IS NOT NULL THEN C2_DATPRI ELSE " + cPrefForm + "_DATPRI END AS DATAINI" + CRLF
	cQuery += "		 ," + cPrefForm + "_DATPRF AS DATAFIM" + CRLF
	cQuery += "		 ," + cPrefForm + "_PRIOR AS PRIORIDADE" + CRLF
	cQuery += "	FROM " + CRLF
	cQuery += "		" + RetSqlTab(cAliasForm) + CRLF
	cQuery += "		LEFT JOIN " + RetSqlTab("SC2") + " ON 1 = 1 " + CRLF
	cQuery += "			AND C2_FILIAL = " + cPrefForm + "_FILIAL " + CRLF
	cQuery += "			AND C2_NUM + C2_ITEM + C2_SEQUEN = " + cPrefForm + "_NUM " + CRLF
	cQuery += "			AND " + RetSqlDel("SC2") + CRLF
	cQuery += "	WHERE " + CRLF
	cQuery += "		1 = 1 " + CRLF
	cQuery += "		AND " + RetSqlFil(cAliasForm) + CRLF
	cQuery += "		AND " + cPrefForm + "_TEAR = " + ValToSql(cTear) + CRLF
	cQuery += "		AND " + cPrefForm + "_SETOR = " + ValToSql(cSetor) + CRLF
	cQuery += "		AND " + cPrefForm + "_STATUS IN ('1', '2') " + CRLF
	cQuery += "		AND " + RetSqlDel(cAliasForm) + CRLF
	cQuery += "	ORDER BY " + CRLF
	cQuery += "		" + cPrefForm + "_STATUS " + CRLF
	cQuery += "		," + cPrefForm + "_PRIOR " + CRLF
	cQuery += "		," + cPrefForm + "_DATPRI " + CRLF
Return cQuery

/*
	Rotina para recuperar primeiro apontamento da OP
*/
Static Function getFirstApont(cOrdem)
	Local cDtApont	:= STOD("")
	Local cQuery	:= ""
	Local cAlias	:= ""

	cQuery := getQryFirstApont(cOrdem)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(!Eof())
		cDtApont := STOD((cAlias)->H6_DATAINI)
	EndIf

	(cAlias)->(DBCloseArea())
Return cDtApont

/*
	Query para buscar OPs primeiro apontamento da OP
*/
Static Function getQryFirstApont(cOrdem)
	Local cQuery	:= ""

	cQuery += "	SELECT " + CRLF
	cQuery += "		TOP 1  " + CRLF
	cQuery += "		H6_FILIAL " + CRLF
	cQuery += "		,H6_OP " + CRLF
	cQuery += "		,H6_DATAINI" + CRLF
	cQuery += "	FROM " + CRLF
	cQuery += "		" + RetSqlTab("SH6") + CRLF
	cQuery += "	WHERE " + CRLF
	cQuery += "		1 = 1 " + CRLF
	cQuery += "		AND " + RetSqlFil("SH6") + CRLF
	cQuery += "		AND H6_OP = "  + ValToSql(cOrdem) + CRLF
	cQuery += "		AND " + RetSqlDel("SH6") + CRLF
	cQuery += "	ORDER BY " + CRLF
	cQuery += "		H6_DATAINI " + CRLF
Return cQuery

/*
	Função de Validação executada na Ativação do Modelo
*/
Static Function activeForm(oModel)
	Local lRet				:= .T.
Return lRet

/*
	Função para adicionar gatilho a campo do field
*/
Static Function FieldTrigger(oModel,cField,uVal)
	Local oView     			:= FwViewActive()
	Local aArea     			:= GetArea()
	Local cCodProduto			:= ""
	Local cNumOP				:= ""
	Local nMultiProd			:= ""
	Local nQtdProduzir			:= 0
	Local nValRPM				:= 0
	Local nValPMedia			:= 0
	Local nDiasProducao			:= 0
	Local nQuantPrd				:= 0
	Local nProduzido			:= 0
	Local dDataIni				:= STOD("")
	Local dDataFim				:= STOD("")
	Local cPrefForm			    := PREFIXO_ALIAS_FORM0
	Local cCpoCodProd	    	:= cPrefForm+"_PRODUT"
	Local cCpoNumOP	    		:= cPrefForm+"_NUM"
	Local cCpoMultiProd    		:= cPrefForm+"_MULTPR"
	Local cCpoRPM		    	:= cPrefForm+"_RPM"
	Local cCpoPMedia    		:= cPrefForm+"_PROMED"
	Local cCpoPQuant    		:= cPrefForm+"_QUANT"
	Local cCpoPQProd    		:= cPrefForm+"_QUJE"
	Local cCpoPMultiProd   		:= cPrefForm+"_MULTPR"
	Local cCpoPDiaria    		:= cPrefForm+"_PRODIA"
	Local cCpoPDataIni    		:= cPrefForm+"_DATPRI"
	Local cCpoPDataFim    		:= cPrefForm+"_DATPRF"
	Local cCpoKgHrEx    		:= cPrefForm+"_KGHREX"
	Local cCpoEficie    		:= cPrefForm+"_EFICIE"
	Local nKgHrEx				:= 0
	Local nEficie				:= 0

	Do Case
	Case cField == cCpoRPM .Or. cField == cCpoPMedia .Or. cField == cCpoPMultiProd
		cCodProduto	:= Alltrim(oModel:GetValue(cCpoCodProd))
		cNumOP		:= oModel:GetValue(cCpoNumOP)
		nMultiProd	:= oModel:GetValue(cCpoMultiProd)
		nValRPM 	:= oModel:GetValue(cCpoRPM)
		nValPMedia 	:= oModel:GetValue(cCpoPMedia)
		dDataIni 	:= oModel:GetValue(cCpoPDataIni)
		nQuantPrd 	:= oModel:GetValue(cCpoPQuant)
		nProduzido 	:= oModel:GetValue(cCpoPQProd)

		If ( !Empty(nValRPM) .And. !Empty(nValPMedia) )
			nQtdProduzir := getQtdProduzir(cCodProduto, cNumOP, nMultiProd, nValRPM, nValPMedia)
			oModel:LoadValue(cCpoPDiaria, nQtdProduzir)

			nDiasProducao := ( ( nQuantPrd - nProduzido ) / nQtdProduzir)

			dDataFim := u_somDiasUteis(IIF(dDataIni < Date(), Date(), dDataIni), Ceiling(nDiasProducao))
			oModel:LoadValue(cCpoPDataFim, dDataFim)
		Else
			oModel:LoadValue(cCpoPDiaria, nQtdProduzir)
		EndIf
	Case cField == cCpoKgHrEx .Or. cField == cCpoEficie
		nKgHrEx 	:= oModel:GetValue(cCpoKgHrEx)
		nEficie 	:= oModel:GetValue(cCpoEficie)
		dDataIni 	:= oModel:GetValue(cCpoPDataIni)
		nQuantPrd 	:= oModel:GetValue(cCpoPQuant)
		nProduzido 	:= oModel:GetValue(cCpoPQProd)

		If ( !Empty(nKgHrEx) .And. !Empty(nEficie) )
			nQtdProduzir := nKgHrEx * 24 * ( nEficie / 100 )
			oModel:LoadValue(cCpoPDiaria, nQtdProduzir)

			If ( nQtdProduzir > 0 )
				nDiasProducao := ( ( nQuantPrd - nProduzido ) / nQtdProduzir )
				dDataFim := u_somDiasUteis(IIF(dDataIni < Date(), Date(), dDataIni), Ceiling(nDiasProducao))
				oModel:LoadValue(cCpoPDataFim, dDataFim)
			EndIf
		Else
			oModel:LoadValue(cCpoPDiaria, 0)
		EndIf

	Case cField == cCpoPDataIni
		dDataIni		:= oModel:GetValue(cCpoPDataIni)
		nQuantPrd 		:= oModel:GetValue(cCpoPQuant)
		nProduzido 		:= oModel:GetValue(cCpoPQProd)
		nProdDiaria		:= oModel:GetValue(cCpoPDiaria)
		nDiasProducao 	:= ( ( nQuantPrd - nProduzido ) / nProdDiaria )
		dDataFim 		:= u_somDiasUteis(IIF(dDataIni < Date(), Date(), dDataIni), Ceiling(nDiasProducao))

		oModel:LoadValue(cCpoPDataFim, dDataFim)
	EndCase

	oView:Refresh()

	RestArea(aArea)
Return uVal

/*
	Cálcula quantidade a ser produzida 
*/
Static Function getQtdProduzir(cCodProduto, cNumOP, nMultiProd, nQtdRPM, nPorcProdutividade)
	Local cTipoProduto			:= ""
	Local cCodRecurso			:= ""
	Local nTipoTear				:= 0
	Local nQtdProduzir			:= 0
	Local nMetroLinear			:= 0
	Local nPonto				:= 0
	Local nLargEmbalagem		:= 0
	Local nCostura				:= 0
	Local nComprimentoTela		:= 0
	Local nCaida				:= 0
	Local nQtdPrograma			:= 0
	Local cAtrCompTela			:= GetNewPar("ES_ATBCTPO", "0000000009")
	Local cAtrLargEmbalagem		:= GetNewPar("ES_ATBLEPO", "0000000040")
	Local cAtrPonto				:= GetNewPar("ES_ATBPTPO", "0000000090,0000000038,0000000005")
	Local cAtrCaida				:= GetNewPar("ES_ATBCAPO", "0000000042")

	Begin Sequence

		cTipoProduto := Posicione("SB1",1,xFilial("SB1")+cCodProduto, "B1_XTPPROD")

		If ( Empty(cTipoProduto) )
			FwAlertError("Produto " + cCodProduto + " não tem tipo (Tela/Embalagem/Redinha) definido no cadastro de produto. Não será possível cálcular produção diária", "Solpack" )
			Break
		EndIf

		nPonto := getAtributoByProduto(cCodProduto, cAtrPonto)
		If ( Empty(nPonto) )
			FwAlertError("Não foi possível buscar o valor de ponto do produto " + cCodProduto + ", verifique se o atributo de ponto esta cadastrado na ficha técnica. Não será possível cálcular produção diária", "Solpack" )
			Break
		EndIf

		cCodRecurso	:= Posicione("SC2",1,xFilial("SC2")+cNumOP, "C2_ZRECORI")
		If Empty(cCodRecurso)
			cCodRecurso := Posicione("SC2",1,xFilial("SC2")+cNumOP, "C2_ZZTEAR")
		EndIf
		nTipoTear	:= Val(Posicione("SH1",1,xFilial("SH1")+cCodRecurso, "H1_ZZTPTEA"))
		If ( Empty(nTipoTear) )
			FwAlertError("O tipo de tear não foi definido para o recurso " + cCodRecurso + ". Não será possível cálcular produção diária", "Solpack" )
			Break
		EndIf

		If cTipoProduto == "1" //Tela
			nComprimentoTela := getAtributoByProduto(cCodProduto, cAtrCompTela, .T.)
			If ( Empty(nComprimentoTela) )
				FwAlertError("Não foi possível buscar o valor de comprimento de tela do produto " + cCodProduto + ", verifique se o atributo de comprimento de tela esta cadastrado na ficha técnica. Não será possível cálcular produção diária", "Solpack" )
				Break
			EndIf

			nMetroLinear 		:= ( nQtdRPM / nTipoTear * 0.6 ) / nPonto * 24 * ( nPorcProdutividade / 100 )
			nComprimentoTela	:= nComprimentoTela * 1.06
			nQtdProduzir 		:= ( nMetroLinear / nComprimentoTela )
			If ( nQtdProduzir > 1 )
				nQtdProduzir := Round(nQtdProduzir, 0)
			EndIf
		ElseIf cTipoProduto == "2" //Embalagem

			nLargEmbalagem := getAtributoByProduto(cCodProduto, cAtrLargEmbalagem)
			If ( Empty(nLargEmbalagem) )
				FwAlertError("Não foi possível buscar o valor de largura da embalagem do produto " + cCodProduto + ", verifique se o atributo de largura da embalagem esta cadastrado na ficha técnica. Não será possível cálcular produção diária", "Solpack" )
				Break
			EndIf

			nCostura := Posicione("SB1",1,xFilial("SB1")+cCodProduto, "B1_ZZQTPCO")
			If ( Empty(nCostura) )
				FwAlertError("O valor de costura esta zerado no cadastro do produto " + cCodProduto + ". Não será possível cálcular produção diária", "Solpack" )
				Break
			EndIf

			nCaida := getAtributoByProduto(cCodProduto, cAtrCaida)
			If ( Empty(nCaida) )
				FwAlertError("Não foi possível buscar o valor de caída do produto " + cCodProduto + ", verifique se o atributo de caída esta cadastrado na ficha técnica. Não será possível cálcular produção diária", "Solpack" )
				Break
			EndIf

			nQtdPrograma := Posicione("SB1",1,xFilial("SB1")+cCodProduto, "B1_ZZQTPRO")
			If ( Empty(nQtdPrograma) )
				FwAlertError("A quantidade de programção no cadastro do produto " + cCodProduto + " não foi preenchida. Não será possível cálcular produção diária", "Solpack" )
				Break
			EndIf

			nMetroLinear := ( nQtdRPM / nTipoTear * 0.6 ) / nPonto * 24 * ( nPorcProdutividade / 100 )
			nQtdProduzir := nMetroLinear * nCaida / ( ( nLargEmbalagem + nCostura ) / 100 )
			nQtdProduzir := ( nQtdProduzir / nQtdPrograma )
			If ( nQtdProduzir > 1 )
				nQtdProduzir := Round(nQtdProduzir, 0)
			EndIf
		ElseIf cTipoProduto == "3" //Redinha
			cAtrCompTela			:= GetNewPar("ES_ATRCTPO", "0000000078")

			nComprimentoTela := getAtributoByProduto(cCodProduto, cAtrCompTela, .T.)
			If ( Empty(nComprimentoTela) )
				FwAlertError("Não foi possível buscar o valor de comprimento de tela do produto " + cCodProduto + ", verifique se o atributo de comprimento de tela esta cadastrado na ficha técnica. Não será possível cálcular produção diária", "Solpack" )
				Break
			EndIf

			nMetroLinear 		:= ( nQtdRPM / nTipoTear * 0.6 ) / nPonto * 24 * ( nPorcProdutividade / 100 )
			nQtdProduzir 		:= ( nMetroLinear / nComprimentoTela )
		Else
			FwAlertError("Tipo de produto (Tela/Embalagem/Redinha) definido para o produto " + cCodProduto + " é inválido. Não será possível cálcular produção diária", "Solpack" )
			Break
		EndIf

		If !Empty(nMultiProd)
			nQtdProduzir := ( nQtdProduzir * nMultiProd )
		EndIf

	End Sequence
Return nQtdProduzir

/*
	Rotina para buscar valor de atributo da ficha técnica do produto
*/
Static Function getAtributoByProduto(cCodProduto, cAtributo, lComprimento)
	Local nVlrAtb			:= 0
	Local cValAtr			:= ""
	Local cAlias    		:= ""
	Local cQuery    		:= ""

	Default lComprimento	:= .F.

	cQuery := getQryAtributo(cCodProduto, cAtributo)
	cAlias := MPSysOpenQuery(cQuery)

	If !(cAlias)->(Eof())
		If !Empty((cAlias)->CZG_VLNR)
			nVlrAtb := (cAlias)->CZG_VLNR
		ElseIf !Empty((cAlias)->CZG_VLCHAR)
			cValAtr := (cAlias)->CZG_VLCHAR
			cValAtr := Replace(cValAtr, ".", "")
			cValAtr := Replace(cValAtr, ",", ".")
			If ( lComprimento )
				If ( "X" $ Upper(cValAtr) )
					cValAtr := Replace(cValAtr, "X", "*")
					nVlrAtb := &(cValAtr)
				Else
					cValAtr := StrDelChr(Upper(cValAtr), {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"})
					nVlrAtb := Val(cValAtr)
				EndIf
			Else
				cValAtr := StrDelChr(Upper(cValAtr), {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"})
				nVlrAtb := Val(cValAtr)
			EndIf
		EndIf

	EndIf

	(cAlias)->(dbCloseArea())
Return nVlrAtb

/* 
	Query para descricao
*/
Static Function getQryAtributo(cCodProduto, cAtributo)
	Local cQuery 			:= ""

	cQuery += " SELECT " + CRLF
	cQuery += " 	CZG_VLNR " + CRLF
	cQuery += " 	,CZG_VLCHAR " + CRLF
	cQuery += " FROM " + CRLF
	cQuery += " 	" + RetSqlTab("CZG") + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += "		1 = 1 " + CRLF
	cQuery += "		AND " + RetSqlFil("CZG") + CRLF
	cQuery += "		AND CZG_CDAC = " + ValToSql(cCodProduto) + CRLF
	cQuery += "		AND CZG_CDAB IN " + FormatIn(cAtributo, ",") + CRLF
	cQuery += "		AND " + RetSqlDel("CZG") + CRLF
	cQuery += "	ORDER BY " + CRLF
	cQuery += "		CZG_VRFH DESC " + CRLF
Return cQuery

/*
	Rotina genérica para testar integração a rotina de programação de OP
*/
User Function tstProgOP()
	Local lRet                  := .F.
	Local cOrdemProducao    	:= "00000701001"

	PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01"
	lRet := u_PCP01EncerraProgramacao(cOrdemProducao)
	RESET ENVIRONMENT
Return lRet

/*
	Rotina para integrar OP ao processo de programção de OP
*/
User Function PCP01GeraProgramacao(cOrdemProducao)
	Local cAliasForm	:= ALIAS_FORM0
	Local cAliasQry		:= ""
	Local cQuery		:= ""
	Local nQuantOP		:= 0
	Local nKgProd		:= 0
	Local nTipoOperacao	:= TIPO_OPERACAO_INCLUSAO
	Local lRet			:= .F.

	If ( podeExecutar(cOrdemProducao, nTipoOperacao) )
		cQuery 		:= getQryOPProgramacao(cOrdemProducao)
		cAliasQry 	:= MpSysOpenQuery(cQuery)

		If (cAliasQry)->(!Eof())
			If (cAliasQry)->B1_XTPPROD <> "2" .And. Alltrim((cAliasQry)->C2_ZZSETOR) <> "G0"
				nQuantOP 	:= IIF(!Empty((cAliasQry)->B1_QE), ( (cAliasQry)->C2_QUANT / (cAliasQry)->B1_QE ), (cAliasQry)->C2_QUANT )
				nKgProd 	:= nQuantOP * IIF(!Empty((cAliasQry)->B1_QE), (cAliasQry)->B1_QE, 1 ) * (cAliasQry)->B1_CONV
			Else
				nQuantOP 	:= (cAliasQry)->C2_QUANT
				nKgProd 	:= nQuantOP * (cAliasQry)->B1_CONV
			EndIf

			RecLock(cAliasForm, .T.)
			(cAliasForm)->&(cAliasForm+"_FILIAL") 	:= xFilial(cAliasForm)
			If Alltrim((cAliasQry)->C2_ZZSETOR) == "G0"
				(cAliasForm)->&(cAliasForm+"_TEAR") 	:= Alltrim((cAliasQry)->C2_ZRECORI)
			Else
				(cAliasForm)->&(cAliasForm+"_TEAR") 	:= Right(Alltrim((cAliasQry)->C2_ZZTEAR), 2)
			EndIf
			(cAliasForm)->&(cAliasForm+"_RECDES") 	:= Alltrim((cAliasQry)->H1_DESCRI)
			(cAliasForm)->&(cAliasForm+"_SETOR") 	:= (cAliasQry)->C2_ZZSETOR
			(cAliasForm)->&(cAliasForm+"_PRODUT") 	:= Alltrim((cAliasQry)->C2_PRODUTO)
			(cAliasForm)->&(cAliasForm+"_DESC") 	:= Alltrim((cAliasQry)->B1_DESC)
			(cAliasForm)->&(cAliasForm+"_CONV") 	:= (cAliasQry)->B1_CONV
			(cAliasForm)->&(cAliasForm+"_DATPRI") 	:= STOD((cAliasQry)->C2_DATPRI)
			(cAliasForm)->&(cAliasForm+"_DATPRF") 	:= STOD((cAliasQry)->C2_DATPRF)
			(cAliasForm)->&(cAliasForm+"_NUM") 		:= (cAliasQry)->C2_NUM + (cAliasQry)->C2_ITEM + (cAliasQry)->C2_SEQUEN
			(cAliasForm)->&(cAliasForm+"_QUANT") 	:= nQuantOP
			(cAliasForm)->&(cAliasForm+"_KGPROD")	:= nKgProd
			(cAliasForm)->&(cAliasForm+"_STATUS") 	:= "2"
			(cAliasForm)->&(cAliasForm+"_OBS") 		:= (cAliasQry)->C2_OBS
			(cAliasForm)->&(cAliasForm+"_PRIOR") 	:= 9

			lRet := .T.
			(cAliasForm)->(MSUnlock())
		EndIf

		(cAliasQry)->(dbCloseArea())
	EndIf
Return lRet

/*
	Avalia se pode ser executado um determinado bloco de código.
*/
Static Function podeExecutar(cOrdemProducao, nTipoOperacao)
	Local cAliasForm	:= ALIAS_FORM0
	Local lActive		:= GetNewPar("ES_ATVPC01", .T.)
	Local lRet 			:= .F.

	Begin Sequence

		If !( lActive )
			cMsg := "Rotina de integração com programação de OP não está ativa, parâmetro ES_ATVPC01"
			Break
		EndIf

		If !( FwAliasInDic(cAliasForm) )
			cMsg := "Tabela " + cAliasForm + " não foi criada no ambiente."
			Break
		EndIf

		lRet := .T.

	End Sequence
Return lRet

/*
	Monta query de informações a serem preenchidas na programação de OP
*/
Static Function getQryOPProgramacao(cOrdemProducao)
	Local cQuery		:= ""

	cQuery += "	SELECT " + CRLF
	cQuery += "		COALESCE(NULLIF(C2_ZRECORI, ''), C2_ZZTEAR) C2_ZRECORI " + CRLF
	cQuery += "		,COALESCE(H1_DESCRI, ' ') H1_DESCRI " + CRLF
	cQuery += "		,COALESCE(B1_TIPO, ' ') B1_TIPO " + CRLF
	cQuery += "		,C2_ZZTEAR " + CRLF
	cQuery += "		,C2_PRODUTO " + CRLF
	cQuery += "		,COALESCE(B1_DESC, ' ') B1_DESC " + CRLF
	cQuery += "		,CASE " + CRLF
	cQuery += "			WHEN CZG_VLNR <> 0 THEN " + CRLF
	cQuery += "				COALESCE(CZG_VLNR, 0) " + CRLF
	cQuery += "			ELSE " + CRLF
	cQuery += "				COALESCE(B1_QE * B1_PESO, 0) " + CRLF
	cQuery += "		END PESO" + CRLF
	cQuery += "		,COALESCE(B1_CONV, ' ') B1_CONV " + CRLF
	cQuery += "		,COALESCE(B1_ZZCOMP, ' ') B1_ZZCOMP " + CRLF
	cQuery += "		,C2_DATPRI " + CRLF
	cQuery += "		,C2_DATPRF " + CRLF
	cQuery += "		,C2_NUM " + CRLF
	cQuery += "		,C2_ITEM " + CRLF
	cQuery += "		,C2_SEQUEN " + CRLF
	cQuery += "		,C2_QUANT " + CRLF
	cQuery += "		,C2_QUJE " + CRLF
	cQuery += "		,C2_OBS " + CRLF
	cQuery += "		,C2_ZZSETOR " + CRLF
	cQuery += "		,B1_QE " + CRLF
	cQuery += "		,H6_DATAINI " + CRLF
	cQuery += "		,B1_GRUPO " + CRLF
	cQuery += "		,B1_XTPPROD " + CRLF
	cQuery += "		,C2_DATRF " + CRLF
	cQuery += "		,C2_ZZQTOP1 " + CRLF
	cQuery += "	FROM  " + CRLF
	cQuery += "		" + RetSqlTab("SC2") + CRLF
	cQuery += "		LEFT JOIN " + RetSqlTab("SB1") + " ON 1 = 1 " + CRLF
	cQuery += "			AND " + RetSqlFil("SB1") + CRLF
	cQuery += "			AND B1_COD = C2_PRODUTO " + CRLF
	cQuery += "			AND " + RetSqlDel("SB1") + CRLF
	cQuery += "		LEFT JOIN " + RetSqlTab("SH1") + " ON 1 = 1 " + CRLF
	cQuery += "			AND " + RetSqlFil("SH1") + CRLF
	cQuery += "			AND H1_CODIGO = COALESCE(NULLIF(C2_ZRECORI, ''), C2_ZZTEAR) " + CRLF
	cQuery += "			AND " + RetSqlDel("SH1") + CRLF
	cQuery += "		LEFT JOIN " + RetSqlTab("CZG") + " ON 1 = 1 " + CRLF
	cQuery += "			AND " + RetSqlFil("CZG") + CRLF
	cQuery += "			AND CZG_CDAC = C2_PRODUTO " + CRLF
	cQuery += "			AND CZG_CDAB = '00009' " + CRLF
	cQuery += "			AND " + RetSqlDel("CZG") + CRLF
	cQuery += "		LEFT JOIN ( " + CRLF
	cQuery += "			SELECT " + CRLF
	cQuery += "				TOP 1  " + CRLF
	cQuery += "				H6_FILIAL " + CRLF
	cQuery += "				,H6_OP " + CRLF
	cQuery += "				,H6_DATAINI " + CRLF
	cQuery += "			FROM " + CRLF
	cQuery += "				" + RetSqlTab("SH6") + CRLF
	cQuery += "			WHERE " + CRLF
	cQuery += "				1 = 1 " + CRLF
	cQuery += "				AND " + RetSqlFil("SH6") + CRLF
	cQuery += "				AND H6_OP = "  + ValToSql(cOrdemProducao) + CRLF
	cQuery += "				AND " + RetSqlDel("SH6") + CRLF
	cQuery += "			ORDER BY " + CRLF
	cQuery += "				H6_DATAINI " + CRLF
	cQuery += "		) SH6 ON 1 = 1  " + CRLF
	cQuery += "	WHERE  " + CRLF
	cQuery += "		1 = 1  " + CRLF
	cQuery += "		AND " + RetSqlFil("SC2") + CRLF
	cQuery += "		AND C2_NUM + C2_ITEM + C2_SEQUEN = " + ValToSql(cOrdemProducao) + CRLF
	cQuery += "		AND " + RetSqlDel("SC2") + CRLF
Return cQuery

/*
	Rotina para atualizar processo de programção de OP
*/
User Function PCP01AtualizaProgramacao(cOrdemProducao)
	Local cAliasForm		:= ALIAS_FORM0
	Local cAliasQry			:= ""
	Local cQuery			:= ""
	Local cStatus			:= ""
	// Local cGrupoEmbalagem	:= GetNewPar("ES_GRPPEMB", "3020")
	Local nQuantOP			:= 0
	Local nQuantProd		:= 0
	// Adicionado por Felipe Silva.
	local nQtOper2			:= 0
	Local nKgProd			:= 0
	Local nTipoOperacao		:= TIPO_OPERACAO_ATUALIZA
	Local lRet				:= .F.
	local nAuxQtd			:= 0

	If ( podeExecutar(cOrdemProducao, nTipoOperacao) )
		cQuery 		:= getQryOPProgramacao(cOrdemProducao)
		cAliasQry 	:= MpSysOpenQuery(cQuery)

		If (cAliasQry)->(!Eof())
			nAuxQtd := u_GetSH6((cAliasQry)->C2_NUM, (cAliasQry)->C2_ITEM, (cAliasQry)->C2_SEQUEN)

			If (cAliasQry)->B1_XTPPROD <> "2" .And. Alltrim((cAliasQry)->C2_ZZSETOR) <> "G0"
				nQuantOP 	:= IIF(!Empty((cAliasQry)->B1_QE), ( (cAliasQry)->C2_QUANT / (cAliasQry)->B1_QE ), (cAliasQry)->C2_QUANT )
				nQuantProd	:= IIF(!Empty((cAliasQry)->B1_QE), ( (cAliasQry)->C2_QUJE / (cAliasQry)->B1_QE ), (cAliasQry)->C2_QUJE )
				// Adicionado por Felipe Silva.
				nQtOper2	:= IIF(!Empty((cAliasQry)->B1_QE), ( nAuxQtd / (cAliasQry)->B1_QE ), nAuxQtd )
				nKgProd		:= ( nQuantOP - nQuantProd ) * IIF(!Empty((cAliasQry)->B1_QE), (cAliasQry)->B1_QE, 1 ) * (cAliasQry)->B1_CONV
			Else
				nQuantOP 	:= (cAliasQry)->C2_QUANT
				nQuantProd	:= (cAliasQry)->C2_QUJE
				nQtOper2	:= nAuxQtd
				nKgProd		:= ( nQuantOP - nQuantProd ) * (cAliasQry)->B1_CONV
			EndIf

			// If !(Alltrim((cAliasQry)->B1_GRUPO) $ cGrupoEmbalagem)
			// 	validaOPEmAndamento(cOrdemProducao, Right(Alltrim((cAliasQry)->C2_ZZTEAR), 2), (cAliasQry)->C2_ZZSETOR)
			// EndIf

			If nQuantProd == 0
				cStatus := "2"
			Else
				cStatus := "1"
			EndIf

			(cAliasForm)->(dbSetOrder(2))
			If ( (cAliasForm)->(MsSeek(xFilial(cAliasForm)+cOrdemProducao)) )
				RecLock(cAliasForm, .F.)
				(cAliasForm)->&(cAliasForm+"_QUJE") 	:= nQuantProd
				(cAliasForm)->&(cAliasForm+"_ZQTOP1") 	:= nQtOper2
				(cAliasForm)->&(cAliasForm+"_CONV") 	:= (cAliasQry)->B1_CONV
				If Alltrim((cAliasQry)->C2_ZZSETOR) == "G0"
					(cAliasForm)->&(cAliasForm+"_TEAR") 	:= Alltrim((cAliasQry)->C2_ZRECORI)
				Else
					(cAliasForm)->&(cAliasForm+"_TEAR") 	:= Right(Alltrim((cAliasQry)->C2_ZZTEAR), 2)
				EndIf
				(cAliasForm)->&(cAliasForm+"_RECDES") 	:= Alltrim((cAliasQry)->H1_DESCRI)
				(cAliasForm)->&(cAliasForm+"_SETOR") 	:= (cAliasQry)->C2_ZZSETOR
				(cAliasForm)->&(cAliasForm+"_DATPRI") 	:= IIF(!Empty((cAliasQry)->H6_DATAINI), STOD((cAliasQry)->H6_DATAINI), STOD((cAliasQry)->C2_DATPRI))
				(cAliasForm)->&(cAliasForm+"_DATPRF") 	:= STOD((cAliasQry)->C2_DATPRF)
				(cAliasForm)->&(cAliasForm+"_KGPROD")	:= nKgProd
				(cAliasForm)->&(cAliasForm+"_STATUS") 	:= cStatus
				(cAliasForm)->&(cAliasForm+"_OBS") 		:= (cAliasQry)->C2_OBS

				lRet := .T.
				(cAliasForm)->(MSUnlock())
			Else
				RecLock(cAliasForm, .T.)
				(cAliasForm)->&(cAliasForm+"_FILIAL") 		:= xFilial(cAliasForm)
				If Alltrim((cAliasQry)->C2_ZZSETOR) == "G0"
					(cAliasForm)->&(cAliasForm+"_TEAR") 		:= Alltrim((cAliasQry)->C2_ZRECORI)
				Else
					(cAliasForm)->&(cAliasForm+"_TEAR") 		:= Right(Alltrim((cAliasQry)->C2_ZZTEAR), 2)
				EndIf
				(cAliasForm)->&(cAliasForm+"_RECDES") 		:= Alltrim((cAliasQry)->H1_DESCRI)
				(cAliasForm)->&(cAliasForm+"_SETOR") 		:= (cAliasQry)->C2_ZZSETOR
				(cAliasForm)->&(cAliasForm+"_PRODUT") 		:= Alltrim((cAliasQry)->C2_PRODUTO)
				(cAliasForm)->&(cAliasForm+"_DESC") 		:= Alltrim((cAliasQry)->B1_DESC)
				(cAliasForm)->&(cAliasForm+"_CONV") 		:= (cAliasQry)->B1_CONV
				(cAliasForm)->&(cAliasForm+"_DATPRI") 		:= IIF(!Empty((cAliasQry)->H6_DATAINI), STOD((cAliasQry)->H6_DATAINI), STOD((cAliasQry)->C2_DATPRI))
				(cAliasForm)->&(cAliasForm+"_DATPRF") 		:= STOD((cAliasQry)->C2_DATPRF)
				(cAliasForm)->&(cAliasForm+"_NUM") 			:= (cAliasQry)->C2_NUM + (cAliasQry)->C2_ITEM + (cAliasQry)->C2_SEQUEN
				(cAliasForm)->&(cAliasForm+"_QUANT") 		:= nQuantOP
				(cAliasForm)->&(cAliasForm+"_QUJE") 		:= nQuantProd
				(cAliasForm)->&(cAliasForm+"_ZQTOP1") 		:= nQtOper2
				(cAliasForm)->&(cAliasForm+"_KGPROD")		:= nKgProd
				(cAliasForm)->&(cAliasForm+"_STATUS") 		:= cStatus
				(cAliasForm)->&(cAliasForm+"_OBS") 			:= (cAliasQry)->C2_OBS

				lRet := .T.
				(cAliasForm)->(MSUnlock())
			EndIf

			processaProgramacao(,IIF(Alltrim((cAliasQry)->C2_ZZSETOR) == "G0", Alltrim((cAliasQry)->C2_ZRECORI), Right(Alltrim((cAliasQry)->C2_ZZTEAR), 2)), (cAliasQry)->C2_ZZSETOR)
		EndIf

		(cAliasQry)->(dbCloseArea())
	EndIf
Return lRet

/*
	Valida se tem outra OP em andamento para o mesmo tear
	Encerrando caso encontre
*/
Static Function validaOPEmAndamento(cOrdemProducao, cTear, cSetor)
	Local cQuery		:= ""
	Local cAlias		:= ""
	Local cAliasForm	:= ALIAS_FORM0
	Local aArea  		:= FWGetArea()
	Local aAreas 		:= Lj7GetArea({cAliasForm})

	cQuery := getQryOPByStatus(cOrdemProducao, cTear, cSetor, "1")
	cAlias := MPSysOpenQuery(cQuery)

	While (cAlias)->(!Eof())
		(cAliasForm)->(dbSetOrder(1))
		(cAliasForm)->(dbGoTo((cAlias)->RECNO))

		Reclock(cAliasForm, .F.)
		(cAliasForm)->(dbDelete())
		(cAliasForm)->(MsUnlock())

		(cAliasForm)->(dbCloseArea())

		(cAlias)->(dbSkip())
	EndDo

	(cAlias)->(dbCloseArea())

	Lj7RestArea(aAreas)
	FWRestArea(aArea)
Return

/*
	Monta query ordens em andamento para encerra antes de processar calculo
*/
Static Function getQryOPByStatus(cOrdemProducao, cTear, cSetor, cStatus)
	Local cAliasForm 	:= ALIAS_FORM0
	Local cPrefForm		:= PREFIXO_ALIAS_FORM0
	Local cQuery		:= ""

	Default cStatus		:= "1"

	cQuery += "	SELECT " + CRLF
	cQuery += "		R_E_C_N_O_ AS RECNO" + CRLF
	cQuery += "		," + cPrefForm+"_RPM RPM" + CRLF
	cQuery += "		," + cPrefForm+"_PROMED PROMED" + CRLF
	cQuery += "	FROM " + CRLF
	cQuery += "		" + RetSqlTab(cAliasForm) + CRLF
	cQuery += "	WHERE " + CRLF
	cQuery += "		1 = 1 " + CRLF
	cQuery += "		AND " + RetSqlFil(cAliasForm) + CRLF
	cQuery += "		AND " + cPrefForm + "_NUM <> " + ValToSql(cOrdemProducao) + CRLF
	cQuery += "		AND " + cPrefForm + "_TEAR = " + ValToSql(cTear) + CRLF
	cQuery += "		AND " + cPrefForm + "_SETOR = " + ValToSql(cSetor) + CRLF
	cQuery += "		AND " + cPrefForm + "_STATUS IN " + FormatIn(cStatus, ",") + CRLF
	cQuery += "		AND " + RetSqlDel(cAliasForm) + CRLF
Return cQuery

/*
	Rotina para excluir programção de OP
*/
User Function PCP01ExcluiProgramacao(cOrdemProducao)
	Local cAliasForm	:= ALIAS_FORM0
	Local lRet			:= .T.

	If ( podeExecutar(cOrdemProducao) )
		(cAliasForm)->(dbSetOrder(2))
		If ( (cAliasForm)->(MsSeek(xFilial(cAliasForm)+cOrdemProducao)) )
			RecLock(cAliasForm, .F. )
			(cAliasForm)->( dbDelete() )
			(cAliasForm)->( MsUnlock() )
		EndIf
	EndIf
Return lRet

/*
	Rotina para encerrar processo de programção de OP
*/
User Function PCP01EncerraProgramacao(cOrdemProducao)
	Local cAliasForm	:= ALIAS_FORM0
	Local cAliasQry		:= ""
	Local cQuery		:= ""
	Local nQuantOP		:= 0
	Local nQuantProd	:= 0
	Local nQtOper2		:= 0
	Local nKgProd		:= 0
	Local nTipoOperacao	:= TIPO_OPERACAO_ATUALIZA
	Local lRet			:= .F.
	local nAuxQtd		:= 0

	If ( podeExecutar(cOrdemProducao, nTipoOperacao) )
		cQuery 		:= getQryOPProgramacao(cOrdemProducao)
		cAliasQry 	:= MpSysOpenQuery(cQuery)

		If (cAliasQry)->(!Eof())
			nAuxQtd := u_GetSH6((cAliasQry)->C2_NUM, (cAliasQry)->C2_ITEM, (cAliasQry)->C2_SEQUEN)

			If (cAliasQry)->B1_XTPPROD <> "2" .And. Alltrim((cAliasQry)->C2_ZZSETOR) <> "G0"
				nQuantOP 	:= IIF(!Empty((cAliasQry)->B1_QE), ( (cAliasQry)->C2_QUANT / (cAliasQry)->B1_QE ), (cAliasQry)->C2_QUANT )
				nQuantProd	:= IIF(!Empty((cAliasQry)->B1_QE), ( (cAliasQry)->C2_QUJE / (cAliasQry)->B1_QE ), (cAliasQry)->C2_QUJE )

				// Adicionado por Felipe Silva
				nQtOper2	:= IIF(!Empty((cAliasQry)->B1_QE), ( nAuxQtd / (cAliasQry)->B1_QE ), nAuxQtd )
				nKgProd		:= ( nQuantOP - nQuantProd ) * IIF(!Empty((cAliasQry)->B1_QE), (cAliasQry)->B1_QE, 1 ) * (cAliasQry)->B1_CONV
			Else
				nQuantOP 	:= (cAliasQry)->C2_QUANT
				nQuantProd	:= (cAliasQry)->C2_QUJE
				nQtOper2	:= nAuxQtd
				nKgProd		:= ( nQuantOP - nQuantProd ) * (cAliasQry)->B1_CONV
			EndIf

			(cAliasForm)->(dbSetOrder(2))
			If ( (cAliasForm)->(MsSeek(xFilial(cAliasForm)+cOrdemProducao)) )
				RecLock(cAliasForm, .F.)
				(cAliasForm)->&(cAliasForm+"_QUJE") 	:= nQuantProd
				(cAliasForm)->&(cAliasForm+"_ZQTOP1") 	:= nQtOper2
				(cAliasForm)->&(cAliasForm+"_CONV") 	:= (cAliasQry)->B1_CONV
				(cAliasForm)->&(cAliasForm+"_KGPROD")	:= nKgProd
				(cAliasForm)->&(cAliasForm+"_STATUS") 	:= "3"
				(cAliasForm)->&(cAliasForm+"_OBS") 		:= (cAliasQry)->C2_OBS

				lRet := .T.
				(cAliasForm)->(MSUnlock())
			Else
				RecLock(cAliasForm, .T.)
				(cAliasForm)->&(cAliasForm+"_FILIAL") 		:= xFilial(cAliasForm)
				If Alltrim((cAliasQry)->C2_ZZSETOR) == "G0"
					(cAliasForm)->&(cAliasForm+"_TEAR") 		:= Alltrim((cAliasQry)->C2_ZRECORI)
				Else
					(cAliasForm)->&(cAliasForm+"_TEAR") 		:= Right(Alltrim((cAliasQry)->C2_ZZTEAR), 2)
				EndIf
				(cAliasForm)->&(cAliasForm+"_RECDES") 		:= Alltrim((cAliasQry)->H1_DESCRI)
				(cAliasForm)->&(cAliasForm+"_SETOR") 		:= (cAliasQry)->C2_ZZSETOR
				(cAliasForm)->&(cAliasForm+"_PRODUT") 		:= Alltrim((cAliasQry)->C2_PRODUTO)
				(cAliasForm)->&(cAliasForm+"_DESC") 		:= Alltrim((cAliasQry)->B1_DESC)
				(cAliasForm)->&(cAliasForm+"_CONV") 		:= (cAliasQry)->B1_CONV
				(cAliasForm)->&(cAliasForm+"_DATPRI") 		:= STOD((cAliasQry)->C2_DATPRI)
				(cAliasForm)->&(cAliasForm+"_DATPRF") 		:= STOD((cAliasQry)->C2_DATPRF)
				(cAliasForm)->&(cAliasForm+"_NUM") 			:= (cAliasQry)->C2_NUM + (cAliasQry)->C2_ITEM + (cAliasQry)->C2_SEQUEN
				(cAliasForm)->&(cAliasForm+"_QUANT") 		:= nQuantOP
				(cAliasForm)->&(cAliasForm+"_QUJE") 		:= nQuantProd
				(cAliasForm)->&(cAliasForm+"_ZQTOP1") 		:= nQtOper2
				(cAliasForm)->&(cAliasForm+"_KGPROD")		:= nKgProd
				(cAliasForm)->&(cAliasForm+"_STATUS") 		:= "3"
				(cAliasForm)->&(cAliasForm+"_OBS") 			:= (cAliasQry)->C2_OBS

				lRet := .T.
				(cAliasForm)->(MSUnlock())
			EndIf
		EndIf

		(cAliasQry)->(dbCloseArea())
	EndIf
Return lRet

/*
	Rotina par atualizar/refresh na view
*/
Static Function atualizaView()
	Local oView 		:= FwViewActive()

	If ( Type("oView") == "O" )
		oView:Refresh()
	Endif
Return

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

/*
	Função Interna que Soma Dias Úteis
*/
User Function somDiasUteis(dDataRef,nDiasUteisUteis,lUseDataValida)
	Local dDataUtil				:= CtoD("")

	Default nDiasUteisUteis 	:= 0
	Default lUseDataValida		:= .F.

	dDataUtil := somaDiasUteis(dDataRef,nDiasUteisUteis)

	If lUseDataValida
		dDataUtil	:= DataValida( dDataUtil )
	Endif
Return dDataUtil

/*	
	Rotina para soma dias util retirando sabado e domingo
*/
Static Function somaDiasUteis(dDataRef,nDiasUteis)
	Local nCont	:= 0

	If !Empty(dDataRef)
		For nCont:=1 to nDiasUteis
			If nCont == 1
				Loop
			EndIf

			dDataRef += 1

			If ( Dow(dDataRef) == 1 )
				dDataRef += 1
			Endif
		Next
	Endif
Return dDataRef

/*
	Rotina para definir legenda do browser
*/
User Function PC01DefLeg(nDef)
	Local lRet 				:= .T.
	Local cAliasForm 		:= ALIAS_FORM0

	SC2->(dbSetOrder(1))
	SC2->(MsSeek(xFilial("SC2")+(cAliasForm)->&(cAliasForm + "_NUM")))
	lRet := A650DefLeg(nDef)
	SC2->(dbCloseArea())
Return lRet
