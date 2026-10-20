#include 'totvs.ch'
#include 'topconn.ch'

static ALINHADO_ESQUERDA    := 0
static ALINHADO_DIREITA     := 1
static CENTRALIZADO         := 2

static RGB_RED        := RGB(255,0,0)
static RGB_BLUE       := rgb(91, 155, 213)
static RGB_BLUE_LIGHT := rgb(221, 235, 247)

static TAM_BOX := 0.6
static ESPACO_SECAO := 0.5
/*/{Protheus.doc} RelFTExtrusao
Relatório Ficha Técnica - Extrusao
@type function
@version 12.1.27
@author Tiago Faria
@since 10/09/2021
/*/
user function RelFTExtrusao(oReport)
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
	private lDebug       := .F.
	private aDefProdutos := {}
	private aCfgMaquinas := {}
	private aImagens     := {}
	private aObservacoes := {}
	private lAuto        := .f.

	default lFake        := .f.
	default cPathPDF     := ""
	default lAuto        := .f.
	default lDbg         := .f.
	default oReport      := nil

	lAuto := valType(oReport) == "O"

	if lDebug
		CZG->(dbGoTo(4444))
	endif

	if lAuto
		oPrint := oReport
	else
		reportDef(cPathPDF)
	endif
	oPrint:startPage()
	topMargin()
	oPrint:setLine(oPrint:getLineCM()+0.5,.t.)

	defProduto()
	defTemperaturas()
	defMistura()
	defTrocaCheckList()
	defInspecao()

	oPrint:endPage()
	if !lAuto
		oPrint:print()
	endif
return


static function topMargin()
return RelFTImp():topMargin("BOBINAS")

static function defProduto()
	local oPrintGrid := nil
	local oColumn    := nil
	local cAlias     := RelFTImp():queryRel(/*cIDs*/,"EXT CABEC")
	local nLine      := 0
	local nTamBox    := TAM_BOX
	local aCol1      := {}
	local aCol2      := {}
	local nCol       := 0
	local aLine      := {}

	if lAuto
		aAdd(aCol2,"OP: " + SC2->C2_NUM)
	endif

	while (cAlias)->(!EOf())
		nLine++

		if nLine <= 6
			aAdd(aCol1,alltrim((cAlias)->(CZB_DSAB)) + ": " + getResposta(cAlias))
		elseif nLine <= 12
			aAdd(aCol2,alltrim((cAlias)->(CZB_DSAB)) + ": " + getResposta(cAlias))
		endif

		(cAlias)->(dbSkip())
	enddo

	if len(aCol1) <> len(aCol2)
		for nCol := len(aCol2)+1 to len(aCol1)
			aAdd(aCol2,"")
		next nCol
	endif

	oPrintGrid := GridFwMsPrinter():new(nTamBox/*nTamBox*/,1/*nCMIniGrid*/,oPrint:getLineCM()/*nCMPageAtual*/,oPrint:getCMVertical()/*nLimPage*/,.t./*lImpCabec*/,{||addPage()}/*bNewPage*/,0.40/*nRecuoSayAlign*/)

	for nCol := 1 to len(aCol1)
		if nCol == 1
			oColumn := ColumnFwMsPrinter():new(9.5,aCol1[nCol],oFont12N,ALINHADO_ESQUERDA/*nAlignHeader*/,/*oBlueBrush*/)
			oPrintGrid:addCell(oColumn)

			oColumn := ColumnFwMsPrinter():new(9.5,aCol2[nCol],oFont12N,ALINHADO_ESQUERDA/*nAlignHeader*/,/*oBlueBrush*/)
			oPrintGrid:addCell(oColumn)
		else

			aAdd(aLine,ColumnFwMsPrinter():new(9.5,aCol1[nCol],oFont12N,ALINHADO_ESQUERDA/*nAlignHeader*/,/*oBlueBrush*/))
			aAdd(aLine,ColumnFwMsPrinter():new(9.5,aCol2[nCol],oFont12N,ALINHADO_ESQUERDA/*nAlignHeader*/,/*oBlueBrush*/))

			oPrintGrid:addLine(aLine)
			aLine := {}
		endif
	next nCol

	nLinAtual := oPrintGrid:print(oPrint,/*cPixel*/)

	oPrint:setLine(nLinAtual+ESPACO_SECAO,.t./*lConv*/)

	(cAlias)->(dbCloseArea())
return

static function defTemperaturas()
	local cAlias         := RelFTImp():queryRel(/*cIDs*/,"EXT TEMPER")
	local nTamBox        := TAM_BOX
	local oPrintGrid     := nil
	local aLine          := {}
	local nReg           := 0
	local nCM            := 0
	local nCMIniGrid     := 1
	local nTamBox2       := 2.25
	local nCMTemperatura := 0

	nCM := printCell("TEMPERATURAS ºc"/*cText*/,/*oFont*/,1/*nCMIniGrid*/,19/*nCMLargura*/,/*nCMPageAtual*/   ,/*nTamBox*/,oBlueBrush/*oBrush*/)

	oPrint:setLine(nCM,.t./*lConv*/)


	oRosca := GridFwMsPrinter():new(nTamBox * 2/*nTamBox*/,1/*nCMIniGrid*/,oPrint:getLineCM()/*nCMPageAtual*/,oPrint:getCMVertical()/*nLimPage*/,.t./*lImpCabec*/,{||addPage()}/*bNewPage*/,0.40/*nRecuoSayAlign*/)
	oColumn := ColumnFwMsPrinter():new(2,"ROSCA",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
	oRosca:addCell(oColumn)
	oRosca:print(oPrint,/*cPixel*/)

	oPrintGrid := GridFwMsPrinter():new(nTamBox/*nTamBox*/,3/*nCMIniGrid*/,oPrint:getLineCM()/*nCMPageAtual*/,oPrint:getCMVertical()/*nLimPage*/,.t./*lImpCabec*/,{||addPage()}/*bNewPage*/,0.40/*nRecuoSayAlign*/)

	//aAdd(aLine,ColumnFwMsPrinter():new(1.5454,getResposta(cAlias),oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/))

	While (cAlias)->(!Eof())
		nReg++
		if alltrim((cAlias)->(CZB_DSAB)) == "HELICOIDAL"
			oFont := oFont07N
		else
			oFont := oFont12N
		endif
		oColumn := ColumnFwMsPrinter():new(1.5454,alltrim((cAlias)->(CZB_DSAB)),oFont,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
		oPrintGrid:addCell(oColumn)

		aAdd(aLine,ColumnFwMsPrinter():new(1.5454,getResposta(cAlias),oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/))

		(cAlias)->(dbSkip())

		if nReg == 11
			exit
		endif
	enddo

	oPrintGrid:addLine(aClone(aLine))
	aLine := {}

	nLinAtual := oPrintGrid:print(oPrint,/*cPixel*/)

	oPrint:setLine(nLinAtual+ESPACO_SECAO,.t./*lConv*/)

	nReg := 0


	While (cAlias)->(!Eof())
		nReg++

		oPrintGrid := GridFwMsPrinter():new(nTamBox/*nTamBox*/,nCMIniGrid/*nCMIniGrid*/,oPrint:getLineCM()/*nCMPageAtual*/,oPrint:getCMVertical()/*nLimPage*/,.t./*lImpCabec*/,{||addPage()}/*bNewPage*/,0.40/*nRecuoSayAlign*/)

		oColumn := ColumnFwMsPrinter():new(nTamBox2 * 2,alltrim((cAlias)->(CZB_DSAB)),oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
		oPrintGrid:addCell(oColumn)

		nCM := oPrintGrid:print(oPrint,/*cPixel*/)

		oPrintGrid := GridFwMsPrinter():new(nTamBox/*nTamBox*/,nCMIniGrid/*nCMIniGrid*/,nCM/*nCMPageAtual*/,oPrint:getCMVertical()/*nLimPage*/,.t./*lImpCabec*/,{||addPage()}/*bNewPage*/,0.40/*nRecuoSayAlign*/)

		oColumn := ColumnFwMsPrinter():new(nTamBox2,getResposta(cAlias),oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
		oPrintGrid:addCell(oColumn)

		oColumn := ColumnFwMsPrinter():new(nTamBox2,"",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
		oPrintGrid:addCell(oColumn)

		nCMTemperatura := oPrintGrid:print(oPrint,/*cPixel*/)

		(cAlias)->(dbSkip())

		nCMIniGrid += (nTamBox2 * 2) + 0.3333

	enddo

	oPrint:setLine(nCMTemperatura+ESPACO_SECAO,.t./*lConv*/)

	(cAlias)->(dbCloseArea())
return

static function defMistura()
	local nCM      := 0
	local nTamBox  := TAM_BOX
	//local cAlias   := RelFTImp():queryRel(/*cIDs*/,"EXT MISTURA")
	local aLine    := {}
//	local nQtd     := 0
	local aCM      := {}
	local cProduto := CZG->CZG_CDAC
	local cAlias   := ''
	local cQuery   := ''
	local cFornece := ''
	local aFornece := {}
	
	cQuery += "SELECT" + CRLF
	cQuery += " B1_PROC," + CRLF
	cQuery += " SA2.A2_NREDUZ," + CRLF
	cQuery += " B1_ZZPROC2," + CRLF
	cQuery += " COALESCE(SA22.A2_NREDUZ,'') AS NREDUZ2, " + CRLF
	cQuery += " B1_ZZPROC3," + CRLF
	cQuery += " COALESCE(SA23.A2_NREDUZ,'') AS NREDUZ3, " + CRLF
	cQuery += " G1_COMP," + CRLF
	cQuery += " B1_DESC," + CRLF
	cQuery += " CASE WHEN G1_QUANT < 0 THEN 0 ELSE G1_QUANT * 100 END AS PERCENTUAL" + CRLF

	cQuery += "FROM" + CRLF
	cQuery += "	" + RetSqlTab('SG1') + CRLF
	
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlTab('SB1') + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + RetSqlFil('SB1') + CRLF
	cQuery += "	AND B1_COD = G1_COMP" + CRLF
	cQuery += "	AND " + RetSqlDel('SB1') + CRLF
	
	// BUSCANDO FORNECEDOR PADRÃO 1
	cQuery += "LEFT JOIN" + CRLF
	cQuery += "	" + RetSqlTab('SA2') + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + RetSqlFil('SA2') + CRLF
	cQuery += "	AND SA2.A2_COD = B1_PROC" + CRLF
	cQuery += "	AND SA2.A2_LOJA = B1_LOJPROC" + CRLF
	cQuery += "	AND " + RetSqlDel('SA2') + CRLF

	// BUSCANDO FORNECEDOR PADRÃO 2
	cQuery += "LEFT JOIN" + CRLF
	cQuery += "	" + RetSqlName('SA2') +" SA22 " + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND SA22.A2_FILIAL='" + xFilial("SA2") + "'" + CRLF
	cQuery += "	AND SA22.A2_COD  = B1_ZZPROC2" + CRLF
	cQuery += "	AND SA22.A2_LOJA = B1_ZZLOJP2" + CRLF
	cQuery += "	AND SA22.D_E_L_E_T_ = ' '" + CRLF

	// BUSCANDO FORNECEDOR PADRÃO 3
	cQuery += "LEFT JOIN" + CRLF
	cQuery += "	" + RetSqlName('SA2') +" SA23 " + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND SA23.A2_FILIAL='" + xFilial("SA2") + "'" + CRLF
	cQuery += "	AND SA23.A2_COD  = B1_ZZPROC3" + CRLF
	cQuery += "	AND SA23.A2_LOJA = B1_ZZLOJP3" + CRLF
	cQuery += "	AND SA23.D_E_L_E_T_ = ' '" + CRLF

	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + RetSqlFil('SG1') + CRLF
	cQuery += "	AND G1_COD = '" + cProduto + "'" + CRLF
	cQuery += "	AND " + RetSqlDel('SG1') + CRLF
	
	TcQuery cQuery new Alias (cAlias := getNextAlias())


	aAdd(aCM,6) //Fornecedor
	aAdd(aCM,8) //Código
	aAdd(aCM,1) //Porcentagem
	aAdd(aCM,4) //Lote

	nCM := printCell("MISTURA"/*cText*/,/*oFont*/,1/*nCMIniGrid*/,19/*nCMLargura*/,/*nCMPageAtual*/   ,/*nTamBox*/,oBlueBrush/*oBrush*/)

	oPrint:setLine(nCM,.t./*lConv*/)

	oPrintGrid := GridFwMsPrinter():new(nTamBox/*nTamBox*/,1/*nCMIniGrid*/,oPrint:getLineCM()/*nCMPageAtual*/,oPrint:getCMVertical()/*nLimPage*/,.t./*lImpCabec*/,{||addPage()}/*bNewPage*/,0.40/*nRecuoSayAlign*/)

	oColumn := ColumnFwMsPrinter():new(aCM[1],"Fornecedor",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
	oPrintGrid:addCell(oColumn)

	oColumn := ColumnFwMsPrinter():new(aCM[2],"Código",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
	oPrintGrid:addCell(oColumn)

	oColumn := ColumnFwMsPrinter():new(aCM[3],"%",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
	oPrintGrid:addCell(oColumn)

	oColumn := ColumnFwMsPrinter():new(aCM[4],"Lote",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
	oPrintGrid:addCell(oColumn)

	while (cAlias)->(!Eof())
			
			cFornece := alltrim((cAlias)->A2_NREDUZ)
			if !empty((cAlias)->NREDUZ2)
				cFornece += ' / ' + alltrim((cAlias)->NREDUZ2)
			endif
			if !empty((cAlias)->NREDUZ3)
				cFornece += ' / ' + alltrim((cAlias)->NREDUZ3)
			endif
			aFornece := charToImp(cFornece,30)
			aAdd(aLine,ColumnFwMsPrinter():new(aCM[1],aFornece,oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/))
			aAdd(aLine,ColumnFwMsPrinter():new(aCM[2],alltrim((cAlias)->B1_DESC),oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/))
			aAdd(aLine,ColumnFwMsPrinter():new(aCM[3],cValToChar((cAlias)->PERCENTUAL),oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/))
			aAdd(aLine,ColumnFwMsPrinter():new(aCM[4],"",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/))
	
			(cAlias)->(dbSkip())

		oPrintGrid:addLine(aLine)
		aLine := {}
	enddo

	nCM := oPrintGrid:print(oPrint,/*cPixel*/)

	oPrint:setLine(nCM+ESPACO_SECAO,.t./*lConv*/)
	(cAlias)->(dbCloseArea())
return

static function defTrocaCheckList()
	local nCM 		:= 0
	local nCMIniGrid:= 1
	local nCMLargura:= 0

	nCM := printCell("CONTROLE DE TROCA E CHECK LIST DA EXTRUSORA"/*cText*/,/*oFont*/,1/*nCMIniGrid*/,19/*nCMLargura*/,/*nCMPageAtual*/   ,/*nTamBox*/,oBlueBrush/*oBrush*/)

	oPrint:setLine(nCM,.t./*lConv*/)

	//COLUNA 1
	nCMLargura := 2.5
	nCM := printCell(/*cText*/				  ,/*oFont*/,nCMIniGrid/*nCMIniGrid*/,nCMLargura/*nCMLargura*/,/*nCMPageAtual*/   ,TAM_BOX*2/*nTamBox*/,/*oBrush*/)
	nCM := printCell("Acerto de Máq."/*cText*/,/*oFont*/,nCMIniGrid/*nCMIniGrid*/,nCMLargura/*nCMLargura*/,nCM/*nCMPageAtual*/,/*nTamBox*/,/*oBrush*/)
	//COLUNA 1

	//COLUNA 2
	nCMIniGrid := nCMIniGrid + nCMLargura
	nCMLargura := 4.5
	nCM := printCell("Início"/*cText*/ ,/*oFont*/,nCMIniGrid/*nCMIniGrid*/,nCMLargura/*nCMLargura*/,/*nCMPageAtual*/   ,/*nTamBox*/,/*oBrush*/)

	printCell("Data:"/*cText*/   ,/*oFont*/,nCMIniGrid/*nCMIniGrid*/,2.7/*nCMLargura*/,nCM/*nCMPageAtual*/,/*nTamBox*/,/*oBrush*/)
	nCM := printCell("Hora:"/*cText*/   ,/*oFont*/,nCMIniGrid+2.7/*nCMIniGrid*/,1.8/*nCMLargura*/,nCM/*nCMPageAtual*/,/*nTamBox*/,/*oBrush*/)

	printCell("    /       /    "  /*cText*/   ,/*oFont*/,nCMIniGrid/*nCMIniGrid*/,2.7/*nCMLargura*/,nCM/*nCMPageAtual*/,/*nTamBox*/,/*oBrush*/)
	nCM := printCell("   :   "/*cText*/   ,/*oFont*/,nCMIniGrid+2.7/*nCMIniGrid*/,1.8/*nCMLargura*/,nCM/*nCMPageAtual*/,/*nTamBox*/,/*oBrush*/)
	//COLUNA 2

	//COLUNA 3
	nCMIniGrid := nCMIniGrid + nCMLargura
	nCMLargura := 4.5
	nCM := printCell("Final"/*cText*/ ,/*oFont*/,nCMIniGrid/*nCMIniGrid*/,nCMLargura/*nCMLargura*/,/*nCMPageAtual*/   ,/*nTamBox*/,/*oBrush*/)

	printCell("Data:"/*cText*/   ,/*oFont*/,nCMIniGrid/*nCMIniGrid*/,2.7/*nCMLargura*/,nCM/*nCMPageAtual*/,/*nTamBox*/,/*oBrush*/)
	nCM := printCell("Hora:"/*cText*/   ,/*oFont*/,nCMIniGrid+2.7/*nCMIniGrid*/,1.8/*nCMLargura*/,nCM/*nCMPageAtual*/,/*nTamBox*/,/*oBrush*/)

	printCell("    /       /    "  /*cText*/   ,/*oFont*/,nCMIniGrid/*nCMIniGrid*/,2.7/*nCMLargura*/,nCM/*nCMPageAtual*/,/*nTamBox*/,/*oBrush*/)
	nCM := printCell("   :   "/*cText*/   ,/*oFont*/,nCMIniGrid+2.7/*nCMIniGrid*/,1.8/*nCMLargura*/,nCM/*nCMPageAtual*/,/*nTamBox*/,/*oBrush*/)
	//COLUNA 3

	//COLUNA 4
	nCMIniGrid := nCMIniGrid + nCMLargura
	nCMLargura := 1.25
	nCM := printCell(""/*cText*/ ,/*oFont*/,nCMIniGrid/*nCMIniGrid*/,nCMLargura/*nCMLargura*/,/*nCMPageAtual*/   ,/*nTamBox*/,/*oBrush*/)
	nCM := printCell(""/*cText*/   ,/*oFont*/,nCMIniGrid/*nCMIniGrid*/,nCMLargura/*nCMLargura*/,nCM/*nCMPageAtual*/,/*nTamBox*/,/*oBrush*/)
	nCM := printCell(""/*cText*/   ,/*oFont*/,nCMIniGrid/*nCMIniGrid*/,nCMLargura/*nCMLargura*/,nCM/*nCMPageAtual*/,/*nTamBox*/,/*oBrush*/)
	//COLUNA 4

	//COLUNA 5
	nCMIniGrid := nCMIniGrid + nCMLargura
	nCMLargura := 1.25
	nCM := printCell("N.A"/*cText*/ ,/*oFont*/,nCMIniGrid/*nCMIniGrid*/,nCMLargura/*nCMLargura*/,/*nCMPageAtual*/   ,/*nTamBox*/,/*oBrush*/)
	nCM := printCell(""/*cText*/   ,/*oFont*/,nCMIniGrid/*nCMIniGrid*/,nCMLargura/*nCMLargura*/,nCM/*nCMPageAtual*/,/*nTamBox*/,/*oBrush*/)
	nCM := printCell(""/*cText*/   ,/*oFont*/,nCMIniGrid/*nCMIniGrid*/,nCMLargura/*nCMLargura*/,nCM/*nCMPageAtual*/,/*nTamBox*/,/*oBrush*/)
	//COLUNA 5
	//COLUNA 6
	nCMIniGrid := nCMIniGrid + nCMLargura
	nCMLargura := 5
	nCM := printCell("Responsável/Visto:"/*cText*/ ,/*oFont*/,nCMIniGrid/*nCMIniGrid*/,nCMLargura/*nCMLargura*/,/*nCMPageAtual*/   ,/*nTamBox*/,/*oBrush*/)
	nCM := printCell(""/*cText*/   ,/*oFont*/,nCMIniGrid/*nCMIniGrid*/,nCMLargura/*nCMLargura*/,nCM/*nCMPageAtual*/,/*nTamBox*/,/*oBrush*/)
	nCM := printCell(""/*cText*/   ,/*oFont*/,nCMIniGrid/*nCMIniGrid*/,nCMLargura/*nCMLargura*/,nCM/*nCMPageAtual*/,/*nTamBox*/,/*oBrush*/)
	//COLUNA 6

	oPrint:setLine(nCM+ESPACO_SECAO,.t./*lConv*/)
return

static function printCell(cText,oFont,nCMIniGrid,nCMLargura,nCMPageAtual,nTamBox,oBrush)
	default cText		 := ""
	default nCMIniGrid   := 1
	default nCMLargura   := 1
	default nCMPageAtual := oPrint:getLineCM()
	default nTamBox      := TAM_BOX
	default oFont		 := oFont12N
	default oBrush		 := nil

	oPrintGrid := GridFwMsPrinter():new(nTamBox/*nTamBox*/,nCMIniGrid/*nCMIniGrid*/,nCMPageAtual/*nCMPageAtual*/,oPrint:getCMVertical()/*nLimPage*/,.t./*lImpCabec*/,{||addPage()}/*bNewPage*/,0.40/*nRecuoSayAlign*/)

	oColumn := ColumnFwMsPrinter():new(nCMLargura/*nCMLargura*/,cText,oFont,CENTRALIZADO/*nAlignHeader*/,oBrush/*oBlueBrush*/)
	oPrintGrid:addCell(oColumn)
return oPrintGrid:print(oPrint,/*cPixel*/)

static function defInspecao()
	local nCM     := 0
	local nI      := 0
	local nTamBox := TAM_BOX
	local aLine	  := {}
	local nRepeat := 1
	local nCMIniGrid := 1
	nCM := printCell("INSPEÇÃO"/*cText*/,/*oFont*/,1/*nCMIniGrid*/,19/*nCMLargura*/,/*nCMPageAtual*/   ,/*nTamBox*/,oBlueBrush/*oBrush*/)

	oPrint:setLine(nCM,.t./*lConv*/)

	while nRepeat < 3
		nRepeat++

		oPrintGrid := GridFwMsPrinter():new(nTamBox/*nTamBox*/,nCMIniGrid/*nCMIniGrid*/,oPrint:getLineCM()/*nCMPageAtual*/,oPrint:getCMVertical()/*nLimPage*/,.t./*lImpCabec*/,{||addPage()}/*bNewPage*/,0.40/*nRecuoSayAlign*/)

		oColumn := ColumnFwMsPrinter():new(1.8749,"Nº das Bob.",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
		oPrintGrid:addCell(oColumn)

		oColumn := ColumnFwMsPrinter():new(1.5833,"Hr. Inicio",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
		oPrintGrid:addCell(oColumn)

		oColumn := ColumnFwMsPrinter():new(1.5833,"Hr. Fim",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
		oPrintGrid:addCell(oColumn)

		oColumn := ColumnFwMsPrinter():new(1.5833,"Largura",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
		oPrintGrid:addCell(oColumn)

		oColumn := ColumnFwMsPrinter():new(1.5833,"G/m²",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
		oPrintGrid:addCell(oColumn)

		oColumn := ColumnFwMsPrinter():new(1.2916,"Cor",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
		oPrintGrid:addCell(oColumn)

		for nI := 1 to 8
			aAdd(aLine,ColumnFwMsPrinter():new(1.5833,"",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/))
			aAdd(aLine,ColumnFwMsPrinter():new(1.5833,"  :  ",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/))
			aAdd(aLine,ColumnFwMsPrinter():new(1.5833,"  :  ",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/))
			aAdd(aLine,ColumnFwMsPrinter():new(1.5833,"",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/))
			aAdd(aLine,ColumnFwMsPrinter():new(1.5833,"",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/))
			aAdd(aLine,ColumnFwMsPrinter():new(1.5833,"",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/))

			oPrintGrid:addLine(aLine)
			aLine := {}
		next nI

		nCM := oPrintGrid:print(oPrint,/*cPixel*/)

		nCMIniGrid += 9.5
	enddo
	oPrint:setLine(nCM,.t./*lConv*/)
	
	nCMIniGrid := 1

	oPrintGrid := GridFwMsPrinter():new(nTamBox/*nTamBox*/,nCMIniGrid/*nCMIniGrid*/,oPrint:getLineCM()/*nCMPageAtual*/,oPrint:getCMVertical()/*nLimPage*/,.t./*lImpCabec*/,{||addPage()}/*bNewPage*/,0.40/*nRecuoSayAlign*/)

	oColumn := ColumnFwMsPrinter():new(6,"Responsável pelo Preenchimento",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
	oPrintGrid:addCell(oColumn)

	oColumn := ColumnFwMsPrinter():new(3,"Turno",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
	oPrintGrid:addCell(oColumn)

	oColumn := ColumnFwMsPrinter():new(3,"Data",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
	oPrintGrid:addCell(oColumn)

	oColumn := ColumnFwMsPrinter():new(7,"Responsável pelo Turno",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
	oPrintGrid:addCell(oColumn)
	
	oColumn := ColumnFwMsPrinter():new(1.5833,"",oFont12N,CENTRALIZADO/*nAlignHeader*/,/*oBlueBrush*/)
	oPrintGrid:addLine({oColumn,oColumn,oColumn,oColumn})

	nCM := oPrintGrid:print(oPrint,/*cPixel*/)
	oPrint:setLine(nCM+ESPACO_SECAO,.t./*lConv*/)
return

static function addPage()
	nPageAtual++

	oPrint:endPage()
	oPrint:startPage()
	nLinAtual := 0
	nLinAtual += topMargin()
	nLinAtual += 0.4
return nLinAtual

static function reportDef(cPathPDF)
	local lViewPDF		:= .t.//!lImpAuto
	local lLandscape    := .f.

	oPrint := IpFwMsPrinter():new(cFilePrinter,lLandscape,lViewPDF)
return

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
