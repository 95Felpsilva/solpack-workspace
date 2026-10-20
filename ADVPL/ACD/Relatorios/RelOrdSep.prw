#Include "Protheus.ch"
#Include "Topconn.ch"

#DEFINE NLINHAINI		0030
#DEFINE NITENSPAG		0019

#DEFINE COL_PROD		0080
#DEFINE COL_DESC		0280
#DEFINE COL_LOTE		0780
#DEFINE COL_QTOR		0990
#DEFINE COL_QTSE		1250
#DEFINE COL_ARMA		1570
#DEFINE COL_ENDE		2030

/*/{Protheus.doc} RelOrdSep
Relatório de Ordem de separação

@author Julio Lisboa - FSW TOTVS IP Campinas
@since 07/08/2015
@version 1.0
@return nil
/*/
User Function RelOrdSep()
	
	Local aAreaAtu		:= GetArea()
	Private aDados		:= {}
	
	Processa({||geraRel()})
	
	RestArea(aAreaAtu)
	
Return

/*/{Protheus.doc} geraRel
Inicia a impressão do relatório

@author Julio Lisboa - FSW TOTVS IP Campinas
@since 07/08/2015
@version 1.0
@return nil
/*/
Static Function geraRel()
	
	Local nRegs			:= 0
	Local nI				:= 0
	Local nZ				:= 0
	Local nLinhaTmp		:= 0
	Local lImpRodape		:= .F.
	Local cDescricao		:= ""

	Private nTotal		:= 0
	Private nPagina		:= 1
	
	Private oFont07		:= TFont():New("Arial",,07,,.F.,,,,.F.,.F.)
	Private oFont07N		:= TFont():New("Arial",,07,,.T.,,,,.F.,.F.)
	Private oFont09		:= TFont():New("Arial",,09,,.F.,,,,.F.,.F.)
	Private oFont09N		:= TFont():New("Arial",,09,,.T.,,,,.F.,.F.)
	Private oFont10		:= TFont():New("Arial",,10,,.F.,,,,.F.,.F.)
	Private oFont10N		:= TFont():New("Arial",,10,,.T.,,,,.F.,.F.)
	Private oFont16		:= TFont():New("Arial",,16,,.F.,,,,.F.,.F.)
	Private oFont16N		:= TFont():New("Arial",,16,,.T.,,,,.F.,.F.)
	Private oFont12		:= TFont():New("Arial",,12,,.F.,,,,.F.,.F.)
	Private oFont12N		:= TFont():New("Arial",,12,,.T.,,,,.F.,.F.)
	
	Private oPrint		:= TMSPrinter():New()
	Private nLimiteHoz	:= oPrint:nHorzRes()
	Private nLimiteVer	:= oPrint:nVertRes()
	Private nLinha		:= NLINHAINI
	Private cAlias		:= GetNextAlias()
	
	BuscaDad()
	
	If Len(aDados) > 0
		//Impressão em Retrato
		oPrint:SetPortrait()
		oPrint:StartPage()
		
		nTotal := Ceiling(Len(aDados) / NITENSPAG)
		
		ImpCabec()
		
		//Percorre todos os itens
		For nZ := 1 to Len(aDados)
			
			oPrint:Say(nLinha,COL_PROD,aDados[nZ,01],oFont07)
			cDescricao := aDados[nZ,02]
			
			//Quebra as linhas da descrição
			nLinhaTmp := nLinha
			For nI := 1 to MlCount(cDescricao,30)
				oPrint:Say(nLinhaTmp,COL_DESC,MemoLine(cDescricao,30,nI),oFont07)
				nLinhaTmp += 30
			Next
			
			oPrint:Say(nLinha,COL_LOTE,aDados[nZ,03],oFont07)
			oPrint:Say(nLinha,COL_QTOR,Transform(aDados[nZ,04],PesqPict("CB8","CB8_QTDORI")),oFont07)
			oPrint:Say(nLinha,COL_QTSE,Transform(aDados[nZ,05],PesqPict("CB8","CB8_SALDOS")),oFont07)
			
			MSBAR4("CODE128",d2cm(nLinha),d2cm(COL_ARMA),aDados[nZ,06],oPrint,.F.,,.T.,2.7,0.400,.T.,NIL,NIL,.F.)
			MSBAR4("CODE128",d2cm(nLinha),d2cm(COL_ENDE),aDados[nZ,07],oPrint,.F.,,.T.,2.7,0.400,.T.,NIL,NIL,.F.)
			
			nLinha += 135
			
			//Verifica se irá quebrar a página
			If nLinha > (nLimiteVer * 0.90)
				lImpRodape := .T.
				ImpRodape()
				nPagina ++
				oPrint:EndPage()
				nLinha := NLINHAINI
				oPrint:StartPage()
				ImpCabec()
			Else
				lImpRodape := .F.
			EndIf
			
			IncProc()
		Next
		
		If !lImpRodape
			nLinha :=  (nLimiteVer * 0.90)
			ImpRodape()
		EndIf
		
		oPrint:EndPage()
		oPrint:Preview()
	EndIf
	
Return

/*/{Protheus.doc} ImpRodape
Imprime o rodapé

@author Julio Lisboa - FSW TOTVS IP Campinas
@since 10/08/2015
@version 1.0
@return nil
/*/
Static Function ImpRodape()
	
	oPrint:Line(nLinha,nLimiteHoz * 0.05,nLinha,nLimiteHoz * 0.95)
	nLinha += 50
	oPrint:Say(nLinha,nLimiteHoz * 0.09,DToC(dDataBase) + " - " + Time(),oFont07)
	oPrint:Say(nLinha,nLimiteHoz * 0.87,"Página " + cValToChar(nPagina) + " de " + cValToChar(nTotal),oFont07)
	
Return

static function d2cm(nLinha)    //pontos para cm
	Local x := oPrint:nlogpixelx() //pontos por polegada
	Local y := nLinha/x             //pontos convertidos em polegadas
	Local z := y/0.3937           //polegadas convertidas em cm
return z

/*/{Protheus.doc} ImpCabec
Imprime o cabeçalho do relatório

@author Julio Lisboa - FSW TOTVS IP Campinas
@since 07/08/2015
@version 1.0
@return nil
/*/
Static Function ImpCabec()
	
	Local cPedido		:= "Pedido : " + AllTrim(CB7->CB7_PEDIDO) + " - "
	Local cStatus		:= ""
	Local cLogoTp		:= ""
	Local cCodCli		:= AllTrim(CB7->CB7_CLIENT)
	Local cLojCli		:= AllTrim(CB7->CB7_LOJA)
	Local cRazSocial	:= AllTrim(Posicione("SA1",1,xFilial("SA1") + CB7->CB7_CLIENT + CB7->CB7_LOJA,"A1_NOME"))
	
	If cFilAnt == "0101"
		cLogoTp := "\system\LGRL010101.bmp"
	ElseIf cFilAnt == "0201"
		cLogoTp := "\system\LGRL010201.bmp"
	EndIf
	
	If CB7->CB7_STATUS == "0"
		cStatus := "NÃO INICIADO"
	ElseIf CB7->CB7_STATUS == "1"
		cStatus := "SEPARANDO"
	ElseIf CB7->CB7_STATUS == "2"
		cStatus := "SEPARACAO FINAL"
	ElseIf CB7->CB7_STATUS == "3"
		cStatus := "EMBALANDO"
	ElseIf CB7->CB7_STATUS == "4"
		cStatus := "EMBALAÇÃO FINAL"
	ElseIf CB7->CB7_STATUS == "5"
		cStatus := "GERA NOTA"
	ElseIf CB7->CB7_STATUS == "6"
		cStatus := "IMPRESSÃO DA NOTA"
	ElseIf CB7->CB7_STATUS == "7"
		cStatus := "IMPRESSÃO DE VOLUME"
	ElseIf CB7->CB7_STATUS == "8"
		cStatus := "EMBARCADO"
	ElseIf CB7->CB7_STATUS == "9"
		cStatus := "EMBARQUE FINALIZADO"
	EndIf
	
	nLinha += 50
	oPrint:SayBitmap(nLinha,140,cLogoTp,190 * 2,64 * 2)
	oPrint:Say(nLinha,nLimiteHoz * 0.25,"Ordem de Separação - " + AllTrim(CB7->CB7_ORDSEP),oFont16N)
	MSBAR4("CODE128",d2cm(nLinha),d2cm(nLimiteHoz * 0.7),AllTrim(CB7->CB7_ORDSEP),oPrint,.F.,,.T.,3,0.500,.T.,NIL,NIL,.F.)
	
	//Data e Hora
	oPrint:Say(nLinha + 065,nLimiteHoz * 0.25,"Cliente: " + cCodCli + "/" + cLojCli + " - " + cRazSocial,oFont07N)
	oPrint:Say(nLinha + 105,nLimiteHoz * 0.25,cPedido + cStatus,oFont07N)
	
	nLinha += 165
	oPrint:Line(nLinha,nLimiteHoz * 0.05,nLinha,nLimiteHoz * 0.95)
	nLinha += 070
	
	oPrint:Say(nLinha,COL_PROD,"Produto"		,oFont12N)
	oPrint:Say(nLinha,COL_DESC,"Descrição"		,oFont12N)
	oPrint:Say(nLinha,COL_LOTE,"Lote"			,oFont12N)
	oPrint:Say(nLinha,COL_QTOR,"Qtd.Orig."		,oFont12N)
	oPrint:Say(nLinha,COL_QTSE,"Qtd.Separ."	,oFont12N)
	oPrint:Say(nLinha,COL_ARMA,"Armazem"		,oFont12N)
	oPrint:Say(nLinha,COL_ENDE,"Endereço"		,oFont12N)
	
	nLinha += 100
	
Return

/*/{Protheus.doc} BuscaDad
Busca os dados da ordem de separação

@author Julio Lisboa - FSW TOTVS IP Campinas
@since 07/08/2015
@version 1.0
@return nil
/*/
Static Function BuscaDad()
	
	Local cQuery			:= ""
	Local nCont			:= 0
	Local aTmp				:= {}
	
	cQuery := "SELECT " + CRLF
	cQuery += "	CB8_PROD, B1_DESC, CB8_LOTECT, CB8_QTDORI, " + CRLF
	cQuery += "	CB8_SALDOS, CB8_LOCAL, CB8_LCALIZ " + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + RetSqlName("CB8") + " AS CB8 " + CRLF
	cQuery += "INNER JOIN " + CRLF
	cQuery += "	" + RetSqlName("SB1") + " AS SB1 " + CRLF
	cQuery += "ON " + CRLF
	cQuery += "	B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
	cQuery += "	B1_COD = CB8_PROD AND " + CRLF
	cQuery += "	SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "	CB8_FILIAL = '" + xFilial("CB8") + "' AND " + CRLF
	cQuery += "	CB8_ORDSEP = '" + CB7->CB7_ORDSEP + "' AND " + CRLF
	cQuery += "	CB8.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "ORDER BY " + CRLF
	cQuery += "	CB8_ITEM " + CRLF
	
	TcQuery cQuery New Alias &cAlias
	Count to nCont
	ProcRegua(nCont)
	(cAlias)->(DbGoTop())
	
	While (cAlias)->(!Eof())
		
		Aadd(aTmp,AllTrim((cAlias)->CB8_PROD))
		Aadd(aTmp,AllTrim((cAlias)->B1_DESC))
		Aadd(aTmp,AllTrim((cAlias)->CB8_LOTECT))
		Aadd(aTmp,(cAlias)->CB8_QTDORI)
		Aadd(aTmp,(cAlias)->CB8_SALDOS)
		Aadd(aTmp,AllTrim((cAlias)->CB8_LOCAL))
		Aadd(aTmp,AllTrim((cAlias)->CB8_LCALIZ))
		
		Aadd(aDados,aTmp)
		aTmp := {}
		
		(cAlias)->(DbSkip())
	EndDo
	
Return
