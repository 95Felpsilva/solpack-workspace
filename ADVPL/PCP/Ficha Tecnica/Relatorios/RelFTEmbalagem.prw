#include "totvs.ch"
#include "topconn.ch"

static ALINHADO_ESQUERDA    := 0
static ALINHADO_DIREITA     := 1
static CENTRALIZADO         := 2

static RGB_RED := RGB(255,0,0)
static RGB_BLUE:= rgb(91, 155, 213)
static DEF_PRODUTO := "1"
static CFG_MAQUINA := "2"
static IMAGENS     := "3"
static OBSERVACOES := "4"

/*/{Protheus.doc} RelFTEmbalagem
Relatório Ficha Técnica
@type function
@author Tiago Faria
@since 19/01/2021
/*/
user function RelFTEmbalagem(oReport)
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

	private oFont14 	:= TFont():New("Times New Roman",14,14,,.f.)
	private oFont14N	:= TFont():New("Times New Roman",14,14,,.T.)

	private oBlueBrush   := TBrush():New(, RGB_BLUE)
	private oRedBrush    := TBrush():New(, RGB_RED)
	private oGreyBrush   := TBrush():New(, rgb(240,240,240))
	private cLogo        := getNewPar("ZZ_LOGOQNC","logo_ficha_tecnica.jpg")
	private lImpAuto     := .f.
	private cFilePrinter := "ft_embalagem_" + dtos(date()) + "_" + strtran(time(),":","")
	private cAliasQNC    := ""
	private nLinAtual    := 0
	private nLimitePag   := 26
	private lDebug       := .t.
	private aDefProdutos := {}
	private aCfgMaquinas := {}
	private aImagens     := {}
	private aObservacoes := {}
	private nNumero		:= 1
	private nNumero2	:= 1
	private lAuto       := .f.
	default oReport := nil

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
		defBobinas()
		defCfgMaquinas()
		defObservacoes()
		oPrint:endPage()
		if !lAuto
			oPrint:print()
		endif
	endif
return

static function topMargin()
return RelFTImp():topMargin("EMBALAGEM")

static function defProdutos()
return RelFTImp():impDefProdutos()

static function defBobinas()
	local cIDFranze	 := "BOB FRANZE"
	local cIDTrama	 := "BOB TRAMA"
	local aFranze    := getBobina(cIDFranze)
	local aTrama     := getBobina(cIDTrama)
	local nLinAtual	 := 0
	local nQtdLin	 := 0
	local aColFranze := {}
	local aColTrama	 := {}
	local oPCabec	 := nil
	local aLine		 := {}
	local aTexto	 := {}
	local aRet		 := {}
	local nLin		 := 0
	aColFranze 	:= getColBobina(cIDFranze,aFranze[1])
	aColTrama 	:= getColBobina(cIDTrama,aTrama[1])

	aRet := impBobina("FRANZE",aFranze,aColFranze,1)
	nLinAtual := aRet[1]
	nQtdLin := aRet[2]

	aRet := impBobina("TRAMA",aTrama,aColTrama,13)

	if aRet[1] > nLinAtual
		nLinAtual := aRet[1]
	endif

	if aRet[2] > nQtdLin
		nQtdLin := aRet[2]
	endif

	oPCabec := GridFwMsPrinter():new(0.6/*nTamBox*/,8/*nCMIniGrid*/,oPrint:getLineCM()/*nCMPageAtual*/,oPrint:getCMVertical()/*nLimPage*/,.f./*lImpCabec*/,{||addPage()}/*bNewPage*/,0.40/*nRecuoSayAlign*/)
	oColumn := ColumnFwMsPrinter():new(5,"",oFont12N,CENTRALIZADO/*nAlignHeader*/,oBlueBrush/*oBlueBrush*/)
	oPCabec:addCell(oColumn)
	nQtdLin += 2
	for nLin := 1 to nQtdLin
		if ceiLing(nQtdLin / 2) == nLin
			aAdd(aTexto,"BOBINAS EXTRUSÃO")
		else
			aAdd(aTexto,"")
		endif
	next nLin

	aAdd(aLine,ColumnFwMsPrinter():new(5,aTexto,oFont12N,CENTRALIZADO/*nAlignHeader*/,oBlueBrush/*oBlueBrush*/))

	oPCabec:addLine(aLine)

	oPCabec:print(oPrint,/*cPixel*/)

	oPrint:setLine(nLinAtual,.t.)
return

static function getBobina(cBobina)
	local nPos 	:= aScan(aCfgMaquinas,{|X|cBobina $ X[1]})
	local aRet	:= {}
	if nPos > 0
		aRet := aCfgMaquinas[nPos]
	endif
return aRet

static function getColBobina(cIDBobina,cString)
	local cColumns := strTran(cString,cIDBobina,"")
	local aColumns := strToKarr(cColumns,getSeparator(cColumns))
return aColumns

static function impBobina(cTitulo,aBobina,aColTitulo,nCmIni)
	local oPCabec    := nil
	local oColumn    := nil
	local oPItens    := nil
	local nCM1Secao  := 7
	local aLinhas    := {}
	local aItens     := {}
	local nCMIniGrid := nCmIni
	local nItens     := 0
	local nItem      := 0
	local nQtdColumn := 0
	local aItem		 := {}
	local cColumns	 := ""
	default aBobina := {}

	if len(aBobina) >= 2
		cColumns := aBobina[2]
	endif

	oPCabec := GridFwMsPrinter():new(0.6/*nTamBox*/,nCMIniGrid/*nCMIniGrid*/,oPrint:getLineCM()/*nCMPageAtual*/,oPrint:getCMVertical()/*nLimPage*/,.t./*lImpCabec*/,{||addPage()}/*bNewPage*/,0.40/*nRecuoSayAlign*/)
	oColumn := ColumnFwMsPrinter():new(nCM1Secao,cTitulo,oFont12N,CENTRALIZADO/*nAlignHeader*/,oBlueBrush/*oBlueBrush*/)
	oPCabec:addCell(oColumn)

	nLinAtual := oPCabec:print(oPrint,/*cPixel*/)
	aLinhas := strToKarr(alltrim(cColumns),CRLF)
	aEval(aLinhas,{|cLinha| aadd(aItens,strToKarr(alltrim(cLinha),getSeparator(cLinha)))})

	oPItens := GridFwMsPrinter():new(0.6/*nTamBox*/,nCMIniGrid/*nCMIniGrid*/,nLinAtual/*nCMPageAtual*/,oPrint:getCMVertical()/*nLimPage*/,.t./*lImpCabec*/,{||addPage()}/*bNewPage*/,0.40/*nRecuoSayAlign*/)
	nQtdColumn := len(aColTitulo)
	aEval(aColTitulo,{|cCollumn| oPItens:addCell(ColumnFwMsPrinter():new(nCM1Secao/nQtdColumn,alltrim(cCollumn),oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBrush*/,RGB_RED/*nColorText*/))})

	for nItens := 1 to len(aItens)
		nQtdColumn := len(aItens[nItens])
		for nItem := 1 to nQtdColumn
			cTitulo := aItens[nItens][nItem]
			aAdd(aItem,ColumnFwMsPrinter():new(nCM1Secao/nQtdColumn,cTitulo,oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBrush*/,/*nColorText*/))
		next nItem
		oPItens:addLine(aItem)
		aItem := {}
	next nItens

	nLinAtual := oPItens:print(oPrint,/*cPixel*/)
return {nLinAtual,len(aItens)}

static function defCfgMaquinas()
	local cFile                := "\confg_maquina.png"
	local nImgAltura           := 8
	local nImgLargura          := 19
	local nCMLinha             := 0.5
	local nCMColumn            := 1
	local cCanal1AMalha        := getValorCanal("CANAL 1 SEQ 1A MALHA")
	local cCanal1AAlimentacao  := getValorCanal("CANAL 1 SEQ 1A ALIMENTAÇÃO")
	local cCanal1BMalha        := getValorCanal("CANAL 1 SEQ 1B MALHA")
	local cCanal1BAlimentacao  := getValorCanal("CANAL 1 SEQ 1B ALIMENTAÇÃO")
	local cCanal1CMalha        := getValorCanal("CANAL 1 SEQ 1C MALHA")
	local cCanal1CAlimentacao  := getValorCanal("CANAL 1 SEQ 1C ALIMENTAÇÃO")
	local cCanal1DMalha        := getValorCanal("CANAL 1 SEQ 1D MALHA")
	local cCanal1DAlimentacao  := getValorCanal("CANAL 1 SEQ 1D ALIMENTAÇÃO")
	local cCanal21AMalha       := getValorCanal("CANAL 2 SEQ 1A MALHA")
	local cCanal21AAlimentacao := getValorCanal("CANAL 2 SEQ 1A ALIMENTAÇÃO")
	local cCanal21BMalha       := getValorCanal("CANAL 2 SEQ 1B MALHA")
	local cCanal21BAlimentacao := getValorCanal("CANAL 2 SEQ 1B ALIMENTAÇÃO")
	local cCanal22AMalha       := getValorCanal("CANAL 2 SEQ 2A MALHA")
	local cCanal22AAlimentacao := getValorCanal("CANAL 2 SEQ 2A ALIMENTAÇÃO")
	local cCanal22BMalha       := getValorCanal("CANAL 2 SEQ 2B MALHA")
	local cCanal22BAlimentacao := getValorCanal("CANAL 2 SEQ 2B ALIMENTAÇÃO")
	local cTotalCanal          := ""
	local cQtdAgulha           := "0"
	oPrint:SayBitmap(nCMLinha, nCMColumn, cFile ,nImgLargura ,nImgAltura,.f.)
	//CANAL 1
	oPrint:IPsay(3.6/*nLine*/,2.2/*nColumn*/,cCanal1AMalha,oFont16N,/*nAlign*/,/*lSumLine*/)
	oPrint:IPsay(4.4/*nLine*/,2.2/*nColumn*/,cCanal1BMalha,oFont16N,/*nAlign*/,/*lSumLine*/)
	oPrint:IPsay(5.3/*nLine*/,2.2/*nColumn*/,cCanal1CMalha,oFont16N,/*nAlign*/,/*lSumLine*/)
	oPrint:IPsay(6.2/*nLine*/,2.2/*nColumn*/,cCanal1DMalha,oFont16N,/*nAlign*/,/*lSumLine*/)

	oPrint:IPsay(3.6/*nLine*/,4.0/*nColumn*/,cCanal1AAlimentacao,oFont16N,/*nAlign*/,/*lSumLine*/)
	oPrint:IPsay(4.4/*nLine*/,4.0/*nColumn*/,cCanal1BAlimentacao,oFont16N,/*nAlign*/,/*lSumLine*/)
	oPrint:IPsay(5.3/*nLine*/,4.0/*nColumn*/,cCanal1CAlimentacao,oFont16N,/*nAlign*/,/*lSumLine*/)
	oPrint:IPsay(6.2/*nLine*/,4.0/*nColumn*/,cCanal1DAlimentacao,oFont16N,/*nAlign*/,/*lSumLine*/)

	//QTD. AGULHAS
	cTotalCanal := cValToChar(val(cCanal21AMalha) + val(cCanal22AMalha))
	nPos := aScan(ADEFPRODUTOS,{|X|alltrim(X[1])=="QTD. AGULHAS"})
	if nPos > 0
		cQtdAgulha := ADEFPRODUTOS[nPos][2][1]
	endif
	oPrint:IPsay(5.0/*nLine*/,7.2/*nColumn*/,cTotalCanal,oFont16N,/*nAlign*/,/*lSumLine*/)
	oPrint:IPsay(1.4/*nLine*/,10.3/*nColumn*/,cQtdAgulha,oFont16N,/*nAlign*/,/*lSumLine*/)
	oPrint:IPsay(4.4/*nLine*/,13.3/*nColumn*/,cCanal21AMalha,oFont16N,/*nAlign*/,/*lSumLine*/)
	oPrint:IPsay(7.0/*nLine*/,13.3/*nColumn*/,cCanal22AMalha,oFont16N,/*nAlign*/,/*lSumLine*/)

	//CANAL 2
	oPrint:IPsay(3.6/*nLine*/,15.6/*nColumn*/,cCanal21AMalha,oFont16N,/*nAlign*/,/*lSumLine*/)
	oPrint:IPsay(4.5/*nLine*/,15.6/*nColumn*/,cCanal21BMalha,oFont16N,/*nAlign*/,/*lSumLine*/)
	oPrint:IPsay(5.3/*nLine*/,15.6/*nColumn*/,cCanal22AMalha,oFont16N,/*nAlign*/,/*lSumLine*/)
	oPrint:IPsay(6.2/*nLine*/,15.6/*nColumn*/,cCanal22BMalha,oFont16N,/*nAlign*/,/*lSumLine*/)

	oPrint:IPsay(3.6/*nLine*/,17.0/*nColumn*/,cCanal21AAlimentacao,oFont16N,/*nAlign*/,/*lSumLine*/)
	oPrint:IPsay(4.5/*nLine*/,17.0/*nColumn*/,cCanal21BAlimentacao,oFont16N,/*nAlign*/,/*lSumLine*/)
	oPrint:IPsay(5.3/*nLine*/,17.0/*nColumn*/,cCanal22AAlimentacao,oFont16N,/*nAlign*/,/*lSumLine*/)
	oPrint:IPsay(6.2/*nLine*/,17.0/*nColumn*/,cCanal22BAlimentacao,oFont16N,/*nAlign*/,/*lSumLine*/)


	oPrint:setLine(oPrint:getLineCM()+nImgAltura+nCMLinha,.t.)
return

static function getValorCanal(cPesq)
	local nPos := aScan(aImagens,{|X|cPesq $ X[1]})
	local cRet := ""
	if nPos > 0
		cRet := alltrim(aImagens[nPos][2])
		if cRet == "0"
			cRet := ""
		endif
	endif
return cRet

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

static function getSeparator(cText)
return if("|"$cText,"|","/")

static function getQuery(cIDs)
return RelFTImp():queryRel(cIDs)
