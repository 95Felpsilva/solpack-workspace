#include "totvs.ch"
#include "topconn.ch"

static ALINHADO_ESQUERDA    := 0
static ALINHADO_DIREITA     := 1
static CENTRALIZADO         := 2

static RGB_RED := RGB(255,0,0)
static RGB_BLUE:= rgb(91, 155, 213)
static RGB_BLUE_LIGHT:= rgb(221, 235, 247)
static DEF_PRODUTO := "1"
static CFG_MAQUINA := "2"
static IMAGENS     := "3"
static OBSERVACOES := "4"

/*/{Protheus.doc} RelFTTelas
Relatório Ficha Técnica - TELAS
@type function
@author Tiago Faria
@since 19/01/2021
/*/
user function RelFTTelas(oReport)
	private oPrint      := nil
	private nQtdPage    := 0
	private nPageAtual  := 0
	private lSum        := .t.
	private lNSum       := .f.
	private oArial10    := TFont():New("Arial",,010,,.F.,,,,,.F.,.F.)
	private oArial8     := TFont():New("Arial",,008,,.F.,,,,,.F.,.F.)
	private oArial10N   := TFont():New("Arial",,010,,.T.,,,,,.F.,.F.)
	private oArial8N    := TFont():New("Arial",,008,,.T.,,,,,.F.,.F.)
	private oFont07		:= TFont():New("Times New Roman",07,07,,.F.,,,,.T.,.F.)
	private oFont07N	:= TFont():New("Times New Roman",07,07,,.T.,,,,.T.,.F.)
	private oFont08		:= TFont():New("Times New Roman",08,08,,.F.,,,,.T.,.F.)
	private oFont08N	:= TFont():New("Times New Roman",08,08,,.T.,,,,.T.,.F.)

	private oFont20		:= TFont():New("Times New Roman",20,20,,.F.,,,,.T.,.F.)
	private oFont20N	:= TFont():New("Times New Roman",20,20,,.T.,,,,.T.,.F.)

	private oFont09N	:= TFont():New("Arial",09,09,,.T.)
	private oFont09 	:= TFont():New("Arial",09,09,,.f.)

	private oFont10N	:= TFont():New("Times New Roman",10,10,,.T.)
	private oFont10 	:= TFont():New("Times New Roman",10,10,,.f.)

	private oFont16 	:= TFont():New("Times New Roman",16,16,,.f.)
	private oFont16N	:= TFont():New("Times New Roman",16,16,,.T.)

	private oFont12 	:= TFont():New("Times New Roman",12,12,,.f.)
	private oFont12N	:= TFont():New("Times New Roman",12,12,,.T.)

	private oBlueBrush   := TBrush():New(, RGB_BLUE)
	private oBlueLight   := TBrush():New(, RGB_BLUE_LIGHT)
	private oRedBrush    := TBrush():New(, RGB_RED)
	private oGreyBrush   := TBrush():New(, rgb(240,240,240))
	private cLogo        := getNewPar("ZZ_LOGOQNC","logo_ficha_tecnica.jpg")
	private lImpAuto     := .f.
	private cFilePrinter := "ficha_tecnica_" + dtos(date()) + "_" + strtran(time(),":","")
	private cAliasQNC    := ""
	private nLinAtual    := 0
	private nLimitePag   := 26
	private lDebug       := .t.
	private aDefProdutos := {}
	private aCfgMaquinas := {}
	private aImagens     := {}
	private aObservacoes := {}
	private lAuto        := .f.
	default oReport      := nil

	lAuto := valType(oReport) == "O"

	if procQuery()
		if lAuto
			oPrint := oReport
		else
			reportDef()
		endif
		oPrint:startPage()
		topMargin()
		defProdutos()
		defCfgMaquinas()
		defImagens()
		defObservacoes()
		oPrint:endPage()
		if !lAuto
			oPrint:print()
		endif
	endif
return

static function topMargin()
return RelFTImp():topMargin("TELAS")

static function defProdutos()
return RelFTImp():impDefProdutos()

static function defCfgMaquinas()
	local aMicras      := {}
	local aTeares      := {}
	local aDadosGerais := {}
	local nCMMicra     := 0
	local nCMTeares    := 0
	local nCMGerais    := 0
	local aCMs         := {}
	local nMaiorCM     := 0

	aadd(aMicras, {"EXTRUSÃO (Micras)",.t.})
	aadd(aMicras, {"Bob."   , "Simples",.t.})

	aCfg := getCgcMaquina("FRANZE SIMPLES")
	aadd(aMicras, {"Franze", aCfg[1],.f.})

	aCfg := getCgcMaquina("TRAMA SIMPLES")
	aadd(aMicras, {"Trama"  ,aCfg[1],.f.})

	aCfg := getCgcMaquina("TRICOT SIMPLES")
	aadd(aMicras, {"Tricot" ,aCfg[1],.f.})

	aAdd(aMicras,{"Teares x Bobina (cm)",.t.})

	aAdd(aMicras,{getCgcMaquina("TEARES 1")[1],getCgcMaquina("BOBINAS CM 1")[1],.f.})
	aAdd(aMicras,{getCgcMaquina("TEARES 2")[1],getCgcMaquina("BOBINAS CM 2")[1],.f.})
	aAdd(aMicras,{getCgcMaquina("TEARES 3")[1],getCgcMaquina("BOBINAS CM 3")[1],.f.})

	nCMMicra := impCfgMaquinas(aMicras,1)

	aAdd(aTeares,{"PARÂMETROS TEARES",.t.})

	aAdd(aTeares,{"Giletes",.t.})
	aAdd(aTeares,{"Franze/Trama/Tricot",getCgcMaquina("FRANZE/TRAMA/TRICO")[1],.f.})
	aAdd(aTeares,{"Larg. Final Fita",getCgcMaquina("LARG FINAL FITA")[1],.f.})
	aAdd(aTeares,{"Cor da Gilete",getCgcMaquina("COR DA GILETE")[1],.f.})

	aAdd(aTeares,{" ",.f.})

	aAdd(aTeares,{"Leitura dos Discos",.t.})
	aAdd(aTeares,{"Franze",getCgcMaquina("FRANZE")[1],.f.})
	aAdd(aTeares,{"Trama",getCgcMaquina("TRAMA")[1],.f.})

	nCMTeares := impCfgMaquinas(aTeares,7.3333)

	aAdd(aDadosGerais,{"DADOS GERAIS",.t.})
	aAdd(aDadosGerais,{"ALIMENTAÇÃO (mm/Rack)",.t.})

	aadd(aDadosGerais, {"Barra 1 - Franze", getCgcMaquina("BARRA 1 - FRANZE")[1], .f.})
	aadd(aDadosGerais, {"Barra 2 - Trama" , getCgcMaquina("BARRA 2 - TRAMA")[1] , .f.})
	aadd(aDadosGerais, {"Barra 3 - Tricot", getCgcMaquina("BARRA 3 - TRICOT")[1], .f.})

	aAdd(aDadosGerais,{"Engren Nº Dentes",getCgcMaquina("ENGREN. A/B")[1],.t.})

	aAdd(aDadosGerais,{"Resistência Mecânica (kgf)",.t.})
	aAdd(aDadosGerais,{"Teste Vert. - Franze",getCgcMaquina("TESTE VERTICAL - FRANZE")[1],.f.})
	aAdd(aDadosGerais,{"Teste Horiz. - Trama",getCgcMaquina("TESTE HORIZONTAL - TRAMA")[1],.f.})

	nCMGerais := impCfgMaquinas(aDadosGerais,13.6666)
	aAdd(aCMs,nCMGerais)
	aAdd(aCMs,nCMTeares)
	aAdd(aCMs,nCMMicra)
	aSort(aCMs,,,{|X,Y| X>Y})

	nMaiorCM := aCMs[1]
	oPrint:setLine(nMaiorCM,.t.)
return

static function getCgcMaquina(cTitle)
	local nPos    := aScan(aCfgMaquinas,{|X|alltrim(upper(X[1])) == alltrim(upper(cTitle))})
	local aRet    := {}
	local nQtdCol := 0
	local nRet    := 0
	if nPos > 0
		aRet     := aCfgMaquinas[nPos]
		aColTit  := strToKarr(aRet[1],"|")
		aColCont := strToKarr(alltrim(aRet[2]),"|")
		nQtdCol  := len(aColCont)
		aRet     := array(len(aColTit))

		for nRet := 1 to len(aRet)
			if nRet <= nQtdCol
				aRet[nRet] := alltrim(aColCont[nRet])
			else
				aRet[nRet] := ""
			endif
		next nRet
	endif
return aRet

static function impCfgMaquinas(aPrint,nCMIniGrid)
	local nPrint       := 0
	local nCM1Secao    := 6.3333
	local nTamBox      := 0.5
	local cTitulo      := ""
	local nColumn      := 0
	local aColumn      := 0
	local nCM1Column   := 0
	local nQtdColumn   := 0
	local lUltColLogic := .f.
	local nCMPageAtual := oPrint:getLineCM()
	local oBrush       := nil
	local nColor	   := nil
	default nCMIniGrid := 1

	for nPrint := 1 to len(aPrint)
		oPCabec := GridFwMsPrinter():new(nTamBox,nCMIniGrid/*nCMIniGrid*/,nCMPageAtual/*nCMPageAtual*/,oPrint:getCMVertical()/*nLimPage*/,.t./*lImpCabec*/,{||addPage()}/*bNewPage*/,0.40/*nRecuoSayAlign*/)
		aColumn    := aPrint[nPrint]
		nQtdColumn := len(aColumn)
		lUltColLogic := ValType(aColumn[nQtdColumn])=="L"
		nCM1Column := nCM1Secao / (nQtdColumn - if(lUltColLogic,1,0))
		lTitle     := lUltColLogic .and. aColumn[nQtdColumn]
		oBrush     := nil

		if lTitle .and. nPrint == 1
			oBrush := oBlueBrush
			nColor := nil
		elseif lTitle .and. nPrint > 1
			oBrush := oBlueLight
			nColor := RGB_RED
		else
			nColor := nil
			oBrush := nil
		endif

		for nColumn := 1 to nQtdColumn
			cTitulo := aColumn[nColumn]
			if valType(cTitulo) <> "C"
				loop
			endif
			oColumn := ColumnFwMsPrinter():new(nCM1Column,cTitulo,oFont12N,CENTRALIZADO/*nAlignHeader*/,oBrush/*oBlueBrush*/,nColor)
			oPCabec:addCell(oColumn)
		next nColumn

		nCMPageAtual := oPCabec:print(oPrint)
	next nPrint
return nCMPageAtual

static function defImagens()
return RelFTImp():impDefImagens()

static function defObservacoes()
return RelFTImp():impDefObservacoes()

static function addPage()
	nPageAtual++

	oPrint:endPage()
	oPrint:startPage()
	nLinAtual := 0
	nLinAtual += topMargin()
	nLinAtual += 0.4
return nLinAtual

static function reportDef()
	local lViewPDF		:= .t.//!lImpAuto
	local lLandscape    := .f.

	oPrint := IpFwMsPrinter():new(cFilePrinter,lLandscape,lViewPDF)
return

static function procQuery()
	local cAlias := getQuery()
	local lRet   := .f.

	while (cAlias)->(!Eof())
		lRet := .t.
		if (cAlias)->(CZB_ZZLOCI) == DEF_PRODUTO
			aAdd(aDefProdutos,{(cAlias)->(CZB_DSAB),getResposta(cAlias,35),alltrim((cAlias)->(TITDEFPROD))})
		endif

		if (cAlias)->(CZB_ZZLOCI) == CFG_MAQUINA //.and. len(aCfgMaquinas) < 2
			aAdd(aCfgMaquinas,{(cAlias)->(CZB_DSAB),getResposta(cAlias),alltrim((cAlias)->(CZB_ZZTITU))})
		endif

		if (cAlias)->(CZB_ZZLOCI) == IMAGENS
			aAdd(aImagens,{(cAlias)->(CZB_DSAB),getResposta(cAlias),(cAlias)->(CZB_ZZTITU)})
		endif

		if (cAlias)->(CZB_ZZLOCI) == OBSERVACOES
			aAdd(aObservacoes,{(cAlias)->(CZB_DSAB),getResposta(cAlias,80),(cAlias)->(CZB_ZZTITU)})
		endif

		(cAlias)->(dbSkip())
	enddo

	(cAlias)->(dbCloseArea())
return lRet

static function getResposta(cAlias,nQtdChar1Linha)
	local aResp     := {}
	local nPosResp  := 0
	local cField    := ""
	local cRet      := ""
	default nQtdChar1Linha  := 0
	//F=Flag;C=Char;N=Numerico;D=Data;L=Lista;I=Imagem;A=Faixa;R=Formula;M=Memo;T=Tabela;O=Tolerancia
	aAdd(aResp,{"C","CZG_VLCHAR"})
	aAdd(aResp,{"N","CZG_VLNR"})
	aAdd(aResp,{"F","CZG_VLFG"})
	aAdd(aResp,{"D","CZG_VLDT"})
	aAdd(aResp,{"L","CZG_VLLST"})
	aAdd(aResp,{"I","CZG_BITMAP"})
	aAdd(aResp,{"A","CZG_VLFX"})
	aAdd(aResp,{"R","CZG_VLFO"})
	aAdd(aResp,{"M","VLMEMO"})
	aAdd(aResp,{"T","CZG_VLTB"})
	//aAdd(aResp,{"O","CZG_VLCHAR"})

	nPosResp := aScan(aResp,{|X|X[1]==(cAlias)->(CZG_TPAB)})

	if nPosResp > 0
		cField := aResp[nPosResp,2]

		if valTYpe((cAlias)->(&(cField))) == "N"
			cRet := alltrim(cValToChar((cAlias)->(&(cField))))
		else
			cRet := alltrim(alltochar((cAlias)->(&(cField))))
		endif


		if (cAlias)->(CZG_TPAB) $ "C/M" .and. nQtdChar1Linha > 0
			cRet := charToImp(cRet,nQtdChar1Linha)
		endif

		if empty(cRet)
			cRet := "."
		endif
	endif
return cRet

static function getQuery(cIDs)
return RelFTImp():queryRel(cIDs)

static function charToImp(cString ,nQtdChar)
	local aRet 			:= {}
	local nLine 		:= 0
	local nCount 		:= MlCount( cString,nQtdChar )

	if nCount == 0
		aRet := {""}
	else
		for nLine := 1 to nCount
			aAdd(aRet,MemoLine(cString,nQtdChar,nLine))
		next nLine
	endif
return aRet

/*
static function getTamanhoImg(cImagem)
	Local oTImg
	Local aTamanho 	:= {0, 0}
	local n1CMXPixel:= 37.7957517575025
	Default cImagem	:= ""

	//Criando o objeto com a imagem passada via parâmetro
	oTImg := TBitmap():New(01,01,,,,cImagem,,,,,,,,,,,,,)

	//Auto ajusta o tamanho, sem ele, é retornado 0
	oTImg:lAutoSize := .T.

	//Altura
	aTamanho[1] := oTImg:nClientHeight / n1CMXPixel

	//Largura
	aTamanho[2] := oTImg:nClientWidth / n1CMXPixel
	oTImg := nil
	freeobj(oTImg)
Return aTamanho
*/
