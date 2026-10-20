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

/*/{Protheus.doc} RelFTRius
Relatório Ficha Técnica
@type function
@author Tiago Faria
@since 19/01/2021
/*/
user function RelFTRius(oReport)
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
	private oRedBrush    := TBrush():New(, RGB_RED)
	private oGreyBrush   := TBrush():New(, rgb(240,240,240))
	private lImpAuto     := .f.
	private cFilePrinter := "ft_embalagem_" + dtos(date()) + "_" + strtran(time(),":","")
	private cAliasQNC    := ""
	private nLinAtual    := 0
	private nLimitePag   := 26
	private lDebug       := .t.
	private aDefProdutos := {}
	private aCfgMaquinas := {}
	private aImagens     := {}
	private aObsSup		 := {}
	private aObsInf		 := {}
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
		defObservacoes(aObsSup)
		defImagens()
		defObservacoes(aObsInf)
		oPrint:endPage()
		if !lAuto
			oPrint:print()
		endif
	endif
return

static function topMargin()
return RelFTImp():topMargin("RIUS")

static function defProdutos()
return RelFTImp():impDefProdutos()

static function defImagens()
return RelFTImp():impDefImagens()

static function defObservacoes(aObs)
return RelFTImp():impDefObservacoes(aObs)

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
			if "OBSERVAÇÃO SUPERIOR" $ (cAlias)->(CZB_DSAB)
				aAdd(aObsSup,{(cAlias)->(CZB_DSAB),getResposta(cAlias,80),(cAlias)->(CZB_ZZTITU)})
			endif
			if "OBSERVAÇÃO INFERIOR" $ (cAlias)->(CZB_DSAB)
				aAdd(aObsInf,{(cAlias)->(CZB_DSAB),getResposta(cAlias,80),(cAlias)->(CZB_ZZTITU)})
			endif
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



