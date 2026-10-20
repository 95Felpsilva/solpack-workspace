#Include "Protheus.ch"

/*/{Protheus.doc}	RelPedDel
Relatórios de pedidos deletados

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					27/07/2015
@return				nil
/*/
User Function RelPedDel()
	
	Local aParamBox		:= {}
	
	Private oSection		:= nil
	Private oReport		:= nil
	
	Aadd(aParamBox,{1,"Pedido de"			,Space(TamSx3("C5_NUM")[1]),	"",	"",	"SC5",	"",40, .f.})// MV_PAR01
	Aadd(aParamBox,{1,"Pedido Ate"			,Space(TamSx3("C5_NUM")[1]),	"",	"",	"SC5",	"",40, .f.})// MV_PAR02
	
	Aadd(aParamBox,{1,"Emissão de"	,STOD(""),	"",	"",,".T.",50, .f.})// MV_PAR03
	Aadd(aParamBox,{1,"Emissão Ate"	,STOD(""),	"",	"",,".T.",50, .f.})// MV_PAR04
	
	If ParamBox(aParamBox,"PEDIDOS CANCELADOS",,,,,,,,"PED CANCELA",.T.,.T.)
		oReport	:= MontEstr()
		oReport:PrintDialog()
	EndIf
	
Return

/*/{Protheus.doc}	MontEstr
Monta a estrutura do relatório

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					27/07/2015
@return				oReport
/*/
Static Function MontEstr()
	
	Local oReport		:= nil
	Local oBreak		:= nil
	Local cReport 	:= "PEDIDOS CANCELADOS"
	Local cTitulo		:= "Pedidos Cancelados"
	Local nTotal		:= 0
	Local oCel01		:= nil
	Local oCel02		:= nil
	Local oCel03		:= nil
	Local oCel04		:= nil
	Local oCel05		:= nil
	Local oCel06		:= nil
	Local oCel07		:= nil
	Local oCel08		:= nil
	Local oCel09		:= nil
	Local oCel10		:= nil
	Local oCel11		:= nil
	Local oCel12		:= nil
	Local oCel13		:= nil
	Local oCel14		:= nil
	Local oCel15		:= nil
	
	//Nome Relatorio ; Titulo ; Parametros ; Code-block executado ao confirmar
	oReport := TReport():New( cReport , cTitulo , {|| fPerg()} , {|oReport| BuscaDad(oReport)} )
	
	//Impressão em Paisagem
	oReport:SetLandscape()
	
	//Define Seção dos dados
	oSection := TRSection():New(oReport,"DETALHES")
	oSection:lOnPageBreak := .F.
	
	/////////////////////////
	//Definição das Celulas//
	/////////////////////////
	
	//Objeto da Seção - Nome da Celula - Alias - Titulo - Picture - Tam Celula - Tam em Pixel(logico) - CodeBlock conteudo celula
	oCel01 := TRCell():New(oSection,"C5_EMISSAO"			,"","Emissão"							,/*PesqPict("SB1","B1_COD")*/	,TamSX3("C5_EMISSAO")[1])
	oCel02 := TRCell():New(oSection,"C6_NUM"				,"","Pedido"							,PesqPict("SC5","C5_NUM")		,TamSX3("C5_NUM")[1] * 2)
	oCel03 := TRCell():New(oSection,"C5_CLIENTE"			,"","Cod.Cli"							,PesqPict("SC5","C5_CLIENTE")	,TamSX3("C5_CLIENTE")[1])
	oCel04 := TRCell():New(oSection,"C5_LOJACLI"			,"","Lj.Cli"							,PesqPict("SC5","C5_LOJACLI")	,TamSX3("C5_LOJACLI")[1])
	oCel04 := TRCell():New(oSection,"C5_ZZDESRS"			,"","Nome Cli"						,PesqPict("SC5","C5_ZZDESRS")	,TamSX3("C5_ZZDESRS")[1])
	oCel07 := TRCell():New(oSection,"C6_PRODUTO"			,"","Produto"							,PesqPict("SC6","C6_PRODUTO")	,TamSX3("C6_PRODUTO")[1] * 2)
	oCel07 := TRCell():New(oSection,"C6_DESCRI"			,"","Desc.Prod."						,PesqPict("SC6","C6_DESCRI")	,TamSX3("C6_DESCRI")[1] * 2)
	oCel08 := TRCell():New(oSection,"C6_QTDVEN"			,"","Qtd. Vend."						,PesqPict("SC6","C6_QTDVEN")	,TamSX3("C6_QTDVEN")[1])
	oCel09 := TRCell():New(oSection,"C6_PRCVEN"			,"","Prc. Vend."						,PesqPict("SC6","C6_PRCVEN")	,TamSX3("C6_PRCVEN")[1])
	oCel11 := TRCell():New(oSection,"C6_ENTREG"			,"","Entrega"							,PesqPict("SC6","C6_ENTREG")	,TamSX3("C6_ENTREG")[1])
	oCel12 := TRCell():New(oSection,"C6_LOTECTL"			,"","Lote"								,PesqPict("SC6","C6_LOTECTL")	,TamSX3("C6_LOTECTL")[1])
	oCel13 := TRCell():New(oSection,"USRDELC5"			,"","Delet.Ped."					,PesqPict("SC5","C5_ZZUSRDE")	,30)
	oCel14 := TRCell():New(oSection,"USRDELC6"			,"","Delet.Item"					,PesqPict("SC6","C6_ZZUSRDE")	,30)
	
Return (oReport)

/*/{Protheus.doc}	BuscaDad
Busca os dados do relatório

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					27/07/2015
@return				nil
/*/
Static Function BuscaDad(oReport)
	
	Local cDelete		:= "*"
	Local cQuery		:= ""
	Local cUsrSC5		:= ""
	Local cUsrSC6		:= ""
	Local cAlias		:= GetNextAlias()
	Local oSecDet		:= oReport:Section(1)
	Local nCont		:= 0
	
	oSecDet:BeginQuery()
	
	BeginSql Alias cAlias
		COLUMN C5_EMISSAO	 		AS DATE
		COLUMN C6_ENTREG	 		AS DATE
		
		SELECT
			C5_EMISSAO,C6_NUM,C5_CLIENTE,C5_LOJACLI,C5_TRANSP,C5_ZZUSRDE,C6_ZZUSRDE,
			C6_PRODUTO,C6_QTDVEN,C6_PRCVEN,C6_TES,C6_ENTREG,C6_LOTECTL,C6_DESCRI,C5_ZZDESRS
		FROM
			%TABLE:SC6% AS SC6
		LEFT JOIN
			%TABLE:SC5% AS SC5
		ON
			C5_FILIAL = %XFILIAL:SC5% AND
			C5_NUM = C6_NUM
		WHERE
			C6_FILIAL = %XFILIAL:SC6% AND
			C5_NUM BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% AND
			C5_EMISSAO BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR04% AND
			SC6.D_E_L_E_T_ = %exp:cDelete%
		ORDER BY
			C5_EMISSAO, C6_NUM, C6_PRODUTO
	EndSql
	
	oSecDet:EndQuery()
	Count to nCont
	oReport:SetMeter(nCont)
	
	(cAlias)->(DbGoTop())
	
	If (cAlias)->(!Eof())
		//Inicia a Sessão
		oSecDet:Init()
		
		While (cAlias)->(!Eof())
			//Incrementa Régua
			oReport:IncMeter()
			
			cUsrSC5 := AllTrim(UsrRetName(AllTrim((cAlias)->C5_ZZUSRDE)))
			cUsrSC6 := AllTrim(UsrRetName(AllTrim((cAlias)->C6_ZZUSRDE)))
			
			oSecDet:Cell("USRDELC5"):SetValue(cUsrSC5)
			oSecDet:Cell("USRDELC6"):SetValue(cUsrSC6)
			
			//Imprime a Linha
			oSecDet:PrintLine()
			
			//1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
			If oReport:nDevice == 4
				oSection:lHeaderSection := .F.
			EndIf			
			
			(cAlias)->(DbSkip())
		EndDo
		
		oSecDet:Finish()
	EndIf
	
	(cAlias)->(DbCloseArea())
	
Return
