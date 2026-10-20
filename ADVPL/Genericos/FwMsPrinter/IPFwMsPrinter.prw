#include 'protheus.ch'
#Include "RPTDEF.CH"
#include "FWPrintSetup.ch"

#Define ALINHADO_ESQUERDA 0
#Define ALINHADO_DIREITA 1
#Define CENTRALIZADO 2

static nQtdSleep	 := 100//getNewPar("ZZ_QTSLEEP",1500)

user function IPFwMsPrinter
	local lSumLine		:= .t.
	local lNotSumLine	:= .f.
	local aDevice 		:= {}
	local lBold			:= .t.
	Local lBold				:= .T.
	Local lNotBold			:= .F.
	Local lSublinhado		:= .T.
	Local lNotSublinhado	:= .F.

	private o14BTimes	:= tFont():New("Times New Roman" ,,14,,lBold	,,,,,lNotSublinhado)
	RpcSetType(3)
	RpcClearEnv()
	RpcSetEnv("01","0101")

	oArial18Bold	:= tFont():New("Arial",,18,,.t.)

	oRel := IpFwMsPrinter():new("Maquinas")
	oRel:StartPage()

	oRel:Box(1,1,4.5,20)

	//oRel:IPMsBar(/*cTypeBar*/"CODE128", /*nRow*/0.1, /*nCol*/ 0.1, /*cCodeBar*/ "4500074009", /*oPrint*/oRel, /*lCheck*/.f.,  /*nWidth*/ /*0.04*/, /*nHeight*/ /*0.6*/, /*lBanner*/ .f., /*lCheck*/ .f.,/*lSumLine*/ .t.)

	//oRel:FWMsBar(/*cTypeBar*/"CODE3_9",/*nRow*/65, 30/*nCol*/, /*cCodeBar*/"4500074009", oRel/*oPrinter*/, /*lCheck*/ .F.,/*color*/ , /*lHorz*/ , /*nWidth*/0.1, /*nHeight*/2, /*lBanner*/ .f.,/*cFont*/,/*cMode*/,/*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,.f./*lCmtr2Pix*/)

	oRel:EndPage()
	oRel:print()

	RpcClearEnv()

return .t.

/*/{Protheus.doc} IPFwMsPrinter
Classe para geração de relatorios com base na classe FwMsPrinter
@author Tiago Faria
@since 30/01/2018
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
	class IPFwMsPrinter From FwMsPrinter
		data nHorizontalProportion
		data nVerticalProportion
		data cFile
		data nLine
		data nLimHorizontal
		data nLimVertical
		data lFileOK
		data lLandscape
		data nResolution
		data oPrintSetup
		data lPrintPDF
		data lCancelSetup

		method new() constructor
		method IPsay()
		method IPCode128()
		method IPQRCode(nRow, nCol, cCodeBar, nSizeBar)
		method IPline()
		method box()
		method boxLine()
		method SayBitmap()
		method sumLine()
		method getHorizontalProportion()
		method getVerticalProportion()
		method getFile()
		method getLine()
		method getLimHorizontal()
		method getLimVertical()
		method getResolution()
		method setResolution()
		method setReport()
		method setHorizontalProportion()
		method setVerticalProportion()
		method setFile()
		method setLine()
		method setLimHorizontal()
		method setLimVertical()
		method getLineCM()
		method getCMVertical()
		method IPMsBar()
		method startPage()
		method getTextHeigth()
		method getCMTextHeigth()
		method IPfillRect()
		method getWidthCM()
		method getTextWidth()
		method setPaperSize()
		method isPrint()
		method printGrid()
		method delFile()
		method print()
		method showPrinterSetup()
	endclass

/*/{Protheus.doc} new
Metodo construtor da classe
@author Tiago Faria
@since 30/01/2018 
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
method new(cFile,lLandscape,lImpPDF,cPathInServer,lDisableSetup,oPrintSetup,cPrinter,lViewPDF,nQtdCopy,lPrintPDF) class IPFwMsPrinter
	local nDevice			:= 0
	default lLandscape 		:= .F.
	default lDisableSetup 	:= .t.
	default lImpPDF			:= .t.
	default cFile			:= NIL
	default lPrintPDF		:= .f.
	//cFile += iif(!empty(cFile),"_","")+retCodUsr()+"_"+cValToChar(round(seconds(),0))
	if lImpPDF
		nDevice := IMP_PDF
	else
		nDevice := IMP_SPOOL
	endif
	::lPrintPDF	:= lPrintPDF
	::lLandscape := lLandscape
	::setFile(cFile)
	::lCancelSetup := .f.
//	getTrab()
	::lFileOK := ::setReport(nDevice,cPathInServer,lDisableSetup,oPrintSetup,cPrinter,lViewPDF,nQtdCopy)
	::setLine(0)
return
/*
Função utilizada para consumir os arquivos temporarios SC0 criado na pasta SYSTEM para evitar erro na hora de geração do PDF
*/
static function getTrab()
	local cTabTrab := criaTrab(, .f.)

	while File(cTabTrab)
		cTabTrab := criaTrab(, .f.)
	enddo
return
/*/{Protheus.doc} IPsay
Insere um texto no relatório
@author Tiago Faria
@since 08/02/2020
@version 1.0
@return nil
@param nLine, numeric, Indica a coordenada vertical em centimetros
@param nColumn, numeric, Indica a coordenada horizontal em centimetros
@param cTexto, characters, Texto a ser impresso
@param oFont, object, Indica o objeto do tipo TFont utilizado para definir as características da fonte aplicada na exibição do conteúdo do controle visual.
@param nAlign, numeric, Indica o alinhamento do texto
@param lSumLine, logical, Indica se deve ou nao somar a linha na propriedade ::nLine
@type function
/*/
method IPsay(nLine,nColumn,cTexto,oFont,nAlign,lSumLine) class IPFwMsPrinter
	Local nWidth 		:= 1000
	Local nHeigth		:= _Super:getTextHeigth(cTexto,oFont)
	Default nAlign		:= 0
	default lSumLine 	:= .f.

	nLine *= ::getVerticalProportion()
	nColumn *= ::getHorizontalProportion()

	if !lSumLine
		nLine := ::getLine() + nLine
	else
		nLine += ::getLine()
	endif

	If nAlign == ALINHADO_ESQUERDA
		_Super:SayAlign(nLine,nColumn,cTexto,oFont,nColumn+nWidth,nHeigth,,nAlign)
	ElseIf nAlign == ALINHADO_DIREITA
		_Super:SayAlign(nLine,0,cTexto,oFont,nColumn,nHeigth,,nAlign)
	Elseif nAlign == CENTRALIZADO
		_Super:SayAlign(nLine,nColumn-(nWidth/2),cTexto,oFont,nWidth,nHeigth,,nAlign)
	Endif

	//_Super:SayAlign(nLine,nColumn,cTexto,oFont,_Super:getTextWidth(cTexto,oFont),,,nAlign)
	//_Super:Say(nLine,nColumn,cTexto,oFont,_Super:getTextWidth(cTexto,oFont))

	if lSumLine
		nLine += ::getTextHeigth(cTexto,oFont)
		::setLine(nLine)
	endif
return
/*/{Protheus.doc} IPCode128
Imprime codigo de barras no padrão code128
@author Tiago Faria
@since 09/02/2018
@version undefined
@param nRow, numeric, Linha em centimetros
@param nCol, numeric, Coluna em centimetros
@param cCodeBar, characters, Codigo de barras
@param nWidth, numeric, Largura da barra em centimetros
@param nHeight, numeric, Altura da barra em centimetros
@param lSay, logical, Indica se deve imprimir o conteudo do código de barras a baixo do mesmo
@param oFont, object, Fonte a ser utilizada na impressão do conteudo do código de barras
@param nTotalWidth, numeric, Indica a largura maxima em centimetros do código de barras (Invalida o parametro nWidth)
@param lSumLine, logical, Indica se deve somar a linha ao total de linhas
@type function
/*/
method IPCode128(nRow, nCol, cCodeBar, nWidth, nHeight, lSay, oFont, nTotalWidth,lSumLine) class IPFwMsPrinter

	default nTotalWidth := 0

	cCodeBar := fwNoAccent(cCodeBar)

	nRow *= ::getVerticalProportion()
	nCol *= ::getHorizontalProportion()

	nWidth *= ::getHorizontalProportion()
	nHeight *= ::getVerticalProportion()

	//deixa variavel como nula, pois se passar 0 a funcao code128 deixa o tamanho do código de barras em 0
	if nTotalWidth == 0
		nTotalWidth := nil
	else
		nTotalWidth *= ::getHorizontalProportion()
	endif

	if !lSumLine
		nRow := ::getLine() + nRow
	else
		nRow += ::getLine()
	endif

	_Super:code128(nRow, nCol, cCodeBar, nWidth, nHeight, lSay, oFont, nTotalWidth)

	if lSumLine
		nRow += nHeight
		::setLine(nRow)
	endif
return
/*/{Protheus.doc} IPMsBar
Imprime codigo de barras no padrão code128
@author Tiago Faria
@since 09/02/2018
@version undefined
@param cTypeBar, caracter, "EAN13", "EAN8", "UPCA" , "SUP5" , "CODE128","INT25","MAT25,"IND25","CODABAR","CODE3_9"
@param nRow, numeric, Linha em centimetros
@param nCol, numeric, Coluna em centimetros
@param cCodeBar, characters, Codigo de barras
@param oPrint, objeto, Objeto Printer
@param lCheck, logico, indica se calcula digito de controle
@param nWidth, numeric, Largura da barra em centimetros
@param nHeight, numeric, Altura da barra em centimetros
@param lBanner, logical, Indica se deve imprimir o conteudo do código de barras a baixo do mesmo
@param nTotalWidth, numeric, Indica a largura maxima em centimetros do código de barras (Invalida o parametro nWidth)
@param lSumLine, logical, Indica se deve somar a linha ao total de linhas
@type function
/*/
method IPMsBar(cTypeBar, nRow, nCol, cCodeBar, oPrint, lCheck,  nWidth, nHeight, lBanner, lCheck,lSumLine) class IPFwMsPrinter

	default lCheck		:= .f.

	nRow *= ::getVerticalProportion()
	nRow := nRow / 3

	nCol *= ::getHorizontalProportion()
	nCol := nCol / 3

	nWidth *= ::getHorizontalProportion()
	nWidth := nWidth / 3

	nHeight *= ::getVerticalProportion()
	nHeight := nHeight / 3

	if !lSumLine
		nRow := ::getLine() + nRow
	else
		nRow += ::getLine()
	endif

	self:FWMsBar(cTypeBar,nRow, nCol, cCodeBar, oPrint /*oPrinter*/, lCheck,/*color*/ , /*lHorz*/ , nWidth, nHeight, lBanner,/*cFont*/,/*cMode*/,/*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,.F./*lCmtr2Pix*/)

	if lSumLine
		nRow += nHeight
		::setLine(nRow)
	endif
return
/*/{Protheus.doc} IPQRCode
Imprime codigo de barras no padrão code128
@author Tiago Faria
@since 09/02/2018
@version undefined
@param nRow, numeric, Linha em centimetros
@param nCol, numeric, Coluna em centimetros
@param cCodeBar, characters, Codigo de barras
@param nSizeBar, numeric, Indica o tamanho do código de barras
@param lSumLine, logical, Indica se deve somar a linha ao total de linhas
@type function
/*/
method IPQRCode(nRow, nCol, cCodeBar, nSizeBar,lSumLine) class IPFwMsPrinter
	default nSizeBar := 1
	default lSumLine := .f.
	nRow *= ::getVerticalProportion()
	nCol *= ::getHorizontalProportion()

	nSizeBar *= ::getHorizontalProportion()
	if !lSumLine
		nRow := ::getLine() + nRow
	else
		nRow += ::getLine()
	endif

	_Super:QRCode ( nRow, nCol,cCodeBar, nSizeBar )

	if lSumLine
		nRow += nHeight
		::setLine(nRow)
	endif
return
/*/{Protheus.doc} IPline
Insere uma linha no relatório.
@author Tiago Faria
@since 08/02/2020
@version 1.0
@return nil
@param nLine1, numeric, Indica a coordenada vertical em centimetros
@param nColumn1, numeric, Indica a coordenada horizontal em centimetros
@param nLine2, numeric, Indica a posição do objeto na vertical
@param nColumn2, numeric, Indica a posição do objeto na horizontal
@param nColor, numeric, Cor da linha. Default é 0
@param cPixel, characters, Expessura da linha em pixels. Default é "-2"
@param lSumLine, logical, Indica se deve somar a linha ao total de linhas
@type function
/*/
method IPline(nLine1,nColumn1,nLine2,nColumn2,nColor,cPixel,lSumLine) class IPFwMsPrinter
	local nPosLine1 := nLine1*::getHorizontalProportion()+::getLine()
	local nPosLine2 := nLine2*::getHorizontalProportion()+::getLine()
	local nPosCol1	:= nColumn1*::getVerticalProportion()
	local nPosCol2	:= nColumn2*::getVerticalProportion()
	default nColor := 0
	default cPixel := "-2"
	default lSumLine := .t.
	_Super:Line(nPosLine1,nPosCol1,nPosLine2,nPosCol2,nColor,cPixel)

	if lSumLine
		if nPosLine1 > nPosLine2
			::setLine(nPosLine1)
		else
			::setLine(nPosLine2)
		endif
	endif
return
/*/{Protheus.doc} box
Insere um retângulo no relatório
@author Tiago Faria
@since 08/02/2020
@version 1.0
@return nil
@param nLine1, numeric, Indica a coordenada vertical em centimetros
@param nColumn1, numeric, Indica a coordenada horizontal em centimetros
@param nLine2, numeric, Indica a posição do objeto na vertical
@param nColumn2, numeric, Indica a posição do objeto na horizontal
@param cPixel, characters, Expessura da linha em pixels. Default é "-2"
@param lSumLine, logical, Indica se deve somar a linha ao total de linhas
@type function
/*/
method box(nLine1,nColumn1,nLine2,nColumn2,cPixel,lSumLine,lConvert) class IPFwMsPrinter
	local nPosLine1 := nLine1*::getHorizontalProportion() + ::getLine()
	local nPosLine2 := nLine2*::getHorizontalProportion() + ::getLine()
	local nPosCol1	:= nColumn1*::getVerticalProportion()
	local nPosCol2	:= nColumn2*::getVerticalProportion()
	default cPixel := "-1"
	default lConvert := .t.

	if !lConvert
		nPosLine1 := nLine1
		nPosLine2 := nLine2
		nPosCol1  := nColumn1
		nPosCol2  := nColumn2
	endif
	if lSumLine
		if nPosLine1 > nPosLine2
			::setLine(nPosLine1)
		else
			::setLine(nPosLine2)
		endif
	endif
	_Super:Box(nPosLine1,nPosCol1,nPosLine2,nPosCol2,cPixel)
return

/*/{Protheus.doc} boxLine
Insere um retangulo no relatorio em linhas
@author Tiago Faria
@since 08/02/2020
@version 1.0
@return nil
@param nLine1, numeric, Indica a coordenada vertical em centimetros
@param nColumn1, numeric, Indica a coordenada horizontal em centimetros
@param nLine2, numeric, Indica a posição do objeto na vertical
@param nColumn2, numeric, Indica a posição do objeto na horizontal
@param nColor, numeric, Cor da linha. Default é 0
@param cPixel, characters, Expessura da linha em pixels. Default é "-2"
@param lSumLine, logical, Indica se deve somar a linha ao total de linhas
@type function
/*/
method boxLine(nLine1,nColumn1,nLine2,nColumn2,nColor,cPixel,lSumLine) class IPFwMsPrinter
	local nPosLine1 := nLine1*::getHorizontalProportion() + ::getLine()
	local nPosLine2 := nLine2*::getHorizontalProportion() + ::getLine()
	local nPosCol1	:= nColumn1*::getVerticalProportion()
	local nPosCol2	:= nColumn2*::getVerticalProportion()

	if lSumLine
		if nPosLine1 > nPosLine2
			::setLine(nPosLine1)
		else
			::setLine(nPosLine2)
		endif
	endif

	_Super:Line(nPosLine1,nPosCol1,nPosLine1,nPosCol2,nColor,cPixel)

	_Super:Line(nPosLine1,nPosCol1,nPosLine2,nPosCol1,nColor,cPixel)
	_Super:Line(nPosLine1,nPosCol2,nPosLine2,nPosCol2,nColor,cPixel)

	_Super:Line(nPosLine2,nPosCol1,nPosLine2,nPosCol2,nColor,cPixel)
return

/*/{Protheus.doc} SayBitmap
Insere uma imagem no relatório.
@author Tiago Faria
@since 08/02/2020
@version 1.0
@return nil
@param nRow, numeric, Indica a coordenada vertical em centimetros
@param nCol, numeric, Indica a coordenada horizontal em centimetros
@param cBitMap, characters, Indica o diretório e o nome, com extensão BMP (Bitmap), da imagem
@param nWidth, numeric, Indica a largura em centimetros do objeto
@param nHeight, numeric, Indica a altura em pixels do objeto
@param lSumLine, logical, Indica se deve somar a linha ao total de linhas
@type function
/*/
method SayBitmap(nRow,nCol,cBitMap,nWidth,nHeight,lSumLine) class IPFwMsPrinter
	local nPosLine1 := nRow*::getHorizontalProportion() + ::getLine()
	local nPosLine2 := nCol*::getHorizontalProportion()
	local nPosCol1	:= nWidth*::getVerticalProportion()
	local nPosCol2	:= nHeight*::getVerticalProportion()
	default lSumLine:= .f.

	_Super:SayBitmap(nPosLine1,nPosLine2,cBitMap,nPosCol1,nPosCol2)

	if lSumLine
		if nPosLine1 > nPosCol2
			::setLine(nPosLine1)
		else
			::setLine(nPosCol2)
		endif
	endif
return
/*/{Protheus.doc} sumLine
Soma ao contador ::nLine o valor passado por parametro
@author Tiago Faria
@since 08/02/2020
@version 1.0
@return nil
@param nLine, numeric, indica o tamanho da linha a ser somado no atributo ::nLine
@type function
/*/
method sumLine(nLine,lCM) class IPFwMsPrinter
	default lCM := .f.
	::setLine(::getLine() + nLine * if(lCM,::getHorizontalProportion(),1))
return
/*/{Protheus.doc} getHorizontalProportion
Getter do atributo nHorizontalProportion
@author Tiago Faria
@since 30/01/2018
@version undefined
@type function
/*/
method getHorizontalProportion() class IPFwMsPrinter
return ::nHorizontalProportion
/*/{Protheus.doc} getVerticalProportion
Getter do atributo nVerticalProportion
@author Tiago Faria
@since 30/01/2018
@version undefined
@type function
/*/
method getVerticalProportion() class IPFwMsPrinter
return ::nVerticalProportion
/*/{Protheus.doc} getFile
Getter do atributo cFile
@author Tiago Faria
@since 30/01/2018
@version undefined
@type function
/*/
method getFile() class IPFwMsPrinter
return ::cFile
/*/{Protheus.doc} getLine
Getter do atributo nLine
@author Tiago Faria
@since 30/01/2018
@version undefined
@type function
/*/
method getLine() class IPFwMsPrinter
return ::nLine
/*/{Protheus.doc} getLimHorizontal
Getter do atributo nLimHorizontal
@author Tiago Faria
@since 25/07/2018
@version undefined

@type function
/*/
method getLimHorizontal() class IPFwMsPrinter
return ::nLimHorizontal
/*/{Protheus.doc} getLimVertical
Getter do atributo nLimVertical
@author Tiago Faria
@since 25/07/2018
@version undefined

@type function
/*/
method getLimVertical() class IPFwMsPrinter
return ::nLimVertical
/*/{Protheus.doc} getResolution
Getter do atributo nResolution
@author Tiago Faria
@since 06/11/2019
@version 1.0
@return nResolution, numerico, retorna a resolução do relatorio default 72

@type function
/*/
method getResolution() class IPFwMsPrinter
return ::nResolution

/*/{Protheus.doc} setResolution
Setter do atributo nResolution
@author Tiago Faria
@since 06/11/2019
@version 1.0
@return nil
@param nResolution, numeric, Seta a resolucao do relatorio
@type function
/*/
method setResolution(nResolution) class IPFwMsPrinter
	default nResolution := 78
	::nResolution := nResolution
	_Super:SetResolution(::getResolution())
return
/*/{Protheus.doc} setReport
Setter do atributo oReport
@author Tiago Faria
@since 30/01/2018
@version undefined
@param nDevice, numeric, Tipos de Saída aceitos:IMP_SPOOL Envia para impressora.IMP_PDF Gera arquivo PDF à partir do relatório.Default é IMP_SPOOL
@param cPathInServer, characters, Diretório onde o arquivo de relatório será salvo
@param lDisableSetup, logical, Se .T. não exibe a tela de Setup, ficando à cargo do programador definir quando e se será feita sua chamada. Default é .F.
@param oPrintSetup, object, Objeto FWPrintSetup instanciado pelo usuário.
@param cPrinter, characters, Impressora destino "forçada" pelo usuário. Default é ""
@param lViewPDF, logical, Quando o tipo de impressão for PDF, define se arquivo será exibido após a impressão. O default é .T.
@param nQtdCopy, numeric, Define a quantidade de cópias a serem impressas quando utilizado o metodo de impressão igual a SPOOL. Recomendavel em casos aonde a utilização da classe FwMsPrinter se da por meio de eventos sem a intervenção do usuario (JOBs / Schedule por exemplo)Obs: Aplica-se apenas a ambientes que possuam o fonte FwMsPrinter.prw com data igual ou superior a 03/05/2012.
@type function
/*/
method setReport(nDevice,cPathInServer,lDisableSetup,oPrintSetup,cPrinter,lViewPDF,nQtdCopy) class IPFwMsPrinter
	local lRet 				:= .t.
	local nHandle			:= 0
	local lAdjustToLegacy	:= .f.
	local lServer			:= .t.
	local lPDFAsPNG			:= .t.
	local lRaw				:= .t.
	local lTReport			:= .f.
	local cPathPdf			:= ""
	default nDevice 		:= IMP_PDF
	default cPathInServer	:= "c:\temprel\"
	default lDisableSetup	:= .t.
	default oPrintSetup		:= nil
	default cPrinter		:= ""
	default lViewPDF		:= .t.
	default nQtdCopy		:= 1

	if !lDisableSetup
		::lCancelSetup := !::showPrinterSetup()
	else
		::lCancelSetup := .f.
	endif

	if !existDir(cPathInServer)
		makeDir(cPathInServer)
	endif

	if valtype(::oPrintSetup) == "O"
		if ::oPrintSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
			nDevice 		:= IMP_SPOOL
			cPrinter 		:= ::oPrintSetup:aOptions[PD_VALUETYPE]
			lViewPDF		:= .f.
		else
			nDevice 		:= IMP_PDF
			cPathPdf 	:= ::oPrintSetup:aOptions[PD_VALUETYPE]
		endif
		lServer := ::oPrintSetup:GetProperty(PD_DESTINATION)==AMB_SERVER
		freeobj(::oPrintSetup)
		::oPrintSetup := nil
	else
		cPathPdf := cPathInServer
	endif

	lDisableSetup := .t.
	_Super:new(::getFile(),nDevice,lAdjustToLegacy,cPathInServer,lDisableSetup,,/*::oPrintSetup*/,cPrinter,lServer,/*lPDFAsPNG*/,/*lRaw*/,lViewPDF,nQtdCopy)
	::cPathPdf := cPathPdf
	If ::lLandscape
		_Super:SetLandscape()
	Else
		_Super:SetPortrait()
	EndIf
	::setResolution(::getResolution())
	::setHorizontalProportion()
	::setVerticalProportion()
	::setPaperSize(DMPAPER_A4)
	//::SetParm( "-RFS")
return lRet
/*/{Protheus.doc} setHorizontalProportion
Setter do atributo nHorizontalProportion
@author Tiago Faria
@since 30/01/2018
@version undefined
@param oReport, object, Indica a proporção horizontal
@type function
/*/
method setHorizontalProportion(nHorizontalProportion) class IPFwMsPrinter
	default nHorizontalProportion := ::getResolution()/2.54//converte polegada para centimetro
	::nHorizontalProportion := nHorizontalProportion
return
/*/{Protheus.doc} setVerticalProportion
Setter do atributo nVerticalProportion
@author Tiago Faria
@since 30/01/2018
@version undefined
@param oReport, object, Indica a proporção vertical
@type function
/*/
method setVerticalProportion(nVerticalProportion) class IPFwMsPrinter
	default nVerticalProportion := ::getResolution()/2.54//converte polegada para centimetro
	::nVerticalProportion := nVerticalProportion
return
/*/{Protheus.doc} setFile
Setter do atributo cFile
@author Tiago Faria
@since 30/01/2018
@version undefined
@param cFile, caracter, Indica o nome do arquivo .rel a ser gerado
@type function
/*/
method setFile(cFile) class IPFwMsPrinter
	default cFile := dtos(date()) + "_" + strtran(time(),":","") + "_" + cValToChar(randomize(0,999999)) + ".rel"

	::cFile := cFile
return
/*/{Protheus.doc} setLine
Setter do atributo nLine
@author Tiago Faria
@since 30/01/2018
@version undefined
@type function
/*/
method setLine(nLine, lConv) class IPFwMsPrinter
	default nLine := 0
	default lConv := .f.
	::nLine := nLine * if(lConv,::getHorizontalProportion(),1)
return
/*/{Protheus.doc} setLimHorizontal
Limite horizontal da pagina
@author Tiago Faria
@since 25/07/2018
@version undefined

@type function
/*/
method setLimHorizontal(nLimHorizontal) class IPFwMsPrinter
	::nLimHorizontal := nLimHorizontal * 0.98
return
/*/{Protheus.doc} setLimVertical
Limite vertical da pagina
@author Tiago Faria
@since 25/07/2018
@version undefined

@type function
/*/
method setLimVertical(nLimVertical) class IPFwMsPrinter
	::nLimVertical := nLimVertical * 0.98
return
/*/{Protheus.doc} getLineCM
Retorna a linha atual em Centimetros
@author Tiago Faria
@since 19/03/2019
@version undefined

@type function
/*/
method getLineCM() class IPFwMsPrinter
	local nCM := ::getLine() / ::getVerticalProportion()
return nCM
/*/{Protheus.doc} getCMVertical
Retorna o limite vertical em centimetros
@author Tiago Faria
@since 19/03/2019
@version undefined

@type function
/*/
method getCMVertical() class IPFwMsPrinter
	local nCM := ::getLimVertical() / ::getVerticalProportion()
return nCM
/*/{Protheus.doc} startPage
Inicia uma nova pagina no relatorio
@author Tiago Faria
@since 25/07/2018
@version undefined

@type function
/*/
method startPage() class IPFwMsPrinter
	_Super:startPage()
	::setLine(0)
return
/*/{Protheus.doc} getTextHeigth
Retornar tamanho da fonte em pixel
@author Tiago Faria
@since 27/07/2018
@version undefined
@param cTexto, characters, string com o texto a ser impresso
@param oFont, object, Objeto da fonte que o texto sera impresso
@type function
/*/
method getTextHeigth(cTexto,oFont) class IPFwMsPrinter
	local nFator 		:= 7.590804598
	local nPixel 		:= _Super:getTextHeigth(cTexto,oFont)/nFator

return nPixel
/*/{Protheus.doc} getCMTextHeigth
Retornar tamanho da fonte em centimetros
@author Tiago Faria
@since 08/02/2020
@version 1.0
@return nil
@param cTexto, characters, string com o texto a ser impresso
@param oFont, object, Objeto da fonte que o texto sera impresso
@type function
/*/
method getCMTextHeigth(cTexto,oFont) class IPFWMsPrinter
	local nCM := ::getTextHeigth(cTexto,oFont) / ::getVerticalProportion()
return nCM
/*/{Protheus.doc} getTextWidth
Retornar tamanho da fonte em pixel
@author Tiago Faria
@since 27/07/2018
@version undefined
@param cTexto, characters, string com o texto a ser impresso
@param oFont, object, Objeto da fonte que o texto sera impresso
@type function
/*/
method getTextWidth(cTexto,oFont) class IPFwMsPrinter
	local nFator 		:= 3.809999
	local nPixel 		:= _Super:getTextWidth(cTexto,oFont)/nFator

return nPixel
/*/{Protheus.doc} getWidthCM
Retornar tamanho da fonte em centimetros
@author Tiago Faria
@since 08/02/2020
@version 1.0
@return nil
@param cTexto, characters, string com o texto a ser impresso
@param oFont, object, Objeto da fonte que o texto sera impresso
@type function
/*/
method getWidthCM(cTexto,oFont) class IPFwMsPrinter
	local nWidthCM := ::getTextWidth(cTexto,oFont)
	nWidthCM := nWidthCM/::getHorizontalProportion()
return nWidthCM
/*/{Protheus.doc} IPfillRect
Cria um objeto do tipo retângulo, que pode ser preenchido com uma determinada cor.
@author Tiago Faria
@since 08/02/2020
@version 1.0
@return nil
@param nTop, numeric, Indica a coordenada vertical em centimetros
@param nLeft, numeric, Indica a coordenada horizontal em centimetros
@param nBottom, numeric, Indica a posição do objeto na vertical
@param nRight, numeric, Indica a posição do objeto na horizontal
@param oBrush, object, Indica o objeto do tipo TBrush utilizado para definir a cor de preenchimento do shape e responsável pelo preenchimento do retângulo.
@param cPixel, characters, Expessura da linha em pixels. Default é "-2"
@param lSumLine, logical, Indica se deve ou nao somar a linha na propriedade ::nLine
@type function
/*/
method IPfillRect(nTop,nLeft,nBottom,nRight,oBrush,cPixel,lSumLine) class IPFwMsPrinter
	local aCoord 	:= {}
	local nNewBottom:= 0
	default oBrush 	:= TBrush():New(,RGB(0,0,0))
	default lSumLine:= .t.

	nNewBottom := nBottom

	nTop := nTop*::getHorizontalProportion()
	nTop += ::getLine()

	nBottom := nBottom*::getHorizontalProportion()
	nBottom += ::getLine()

	aAdd(aCoord,nTop)
	aAdd(aCoord,nLeft*::getHorizontalProportion())
	aAdd(aCoord,nBottom)
	aAdd(aCoord,nRight*::getHorizontalProportion())

	if lSumLine
		::setLine(::getLine()+(nNewBottom*::getHorizontalProportion()))
	endif

	_Super:FillRect(aCoord,oBrush,cPixel)
return
/*/{Protheus.doc} setPaperSize
Metodo responsavel por atribuir o tamanho do papel que será impresso o relatorio
@author Tiago Faria
@since 30/07/2018
@version undefined
@param nPaperSize, numeric, Tamanho do papel CARTA = DMPAPER_LETTER,A4=DMPAPER_A4,A3=DMPAPER_A3,EXECUTIVO=DMPAPER_EXECUTIVE,TABLOIDE=DMPAPER_TABLOID
@type function
/*/
method setPaperSize(nPaperSize ,nWidth ,nHeight) class IPFwMsPrinter
	default nWidth 	:= nil
	default nHeight := nil

	If (nPaperSize = DMPAPER_LETTER)
		If ::lLandscape
			::setLimVertical(::getVerticalProportion() * 21.59)
			::setLimHorizontal(::getHorizontalProportion() * 27.94)
		Else
			::setLimVertical(::getVerticalProportion() * 27.94)
			::setLimHorizontal(::getHorizontalProportion() * 21.59)
		EndIf
	ElseIf nPaperSize = DMPAPER_A4
		If ::lLandscape
			::setLimVertical(::getVerticalProportion() * 21) // width
			::setLimHorizontal(::getHorizontalProportion() * 29.7) // heigth
		Else
			::setLimVertical(::getVerticalProportion() * 29.7)
			::setLimHorizontal(::getHorizontalProportion() * 21)
		EndIf
	ElseIf nPaperSize = DMPAPER_A3
		If ::lLandscape
			::setLimVertical(::getVerticalProportion() * 29.7)
			::setLimHorizontal(::getHorizontalProportion() * 42)
		Else
			::setLimVertical(::getVerticalProportion() * 42)
			::setLimHorizontal(::getHorizontalProportion() * 29.7)
		EndIf
	ElseIf nPaperSize = DMPAPER_EXECUTIVE
		If ::lLandscape
			::setLimVertical(::getVerticalProportion() * 18.41)
			::setLimHorizontal(::getHorizontalProportion() * 26.67)
		Else
			::setLimVertical(::getVerticalProportion() * 26.67)
			::setLimHorizontal(::getHorizontalProportion() * 18.41)
		EndIf
	ElseIf nPaperSize = DMPAPER_TABLOID
		If ::lLandscape
			::setLimVertical(::getVerticalProportion() * 27.94)
			::setLimHorizontal(::getHorizontalProportion() * 43.18)
		Else
			::setLimVertical(::getVerticalProportion() * 43.18)
			::setLimHorizontal(::getHorizontalProportion() * 27.94)
		EndIf
	Endif
	If !empty(nHeight) .and. !empty(nWidth)
		/*
		nHeight := nHeight/3.55
		nWidth	:= nWidth/3.55
		*/
		If ::lLandscape
			nWidth	:= ::getVerticalProportion() * nWidth
			nHeight := ::getHorizontalProportion() * nHeight
			::setLimVertical(nWidth)
			::setLimHorizontal(nHeight)
		Else
			nWidth	:= ::getHorizontalProportion() * nWidth
			nHeight := ::getVerticalProportion() * nHeight
			::setLimVertical(nHeight)
			::setLimHorizontal(nWidth)
		EndIf
		nHeight	:= (nHeight)
		nWidth	:= (nWidth)
	Endif

	_Super:setPaperSize(nPaperSize ,nHeight ,nWidth)
return
/*/{Protheus.doc} isPrint
Avalia se há espaco suficiente no relatorio para realizar a impressão, de acordo com os centimetros recebidos por parametro
@author Tiago Faria
@since 30/07/2018
@version undefined
@param nCM, numeric, Centimetros
@param lVertical, logical, Indica se esta avaliando a impressão do texto na vertical ou na horizontal
@type function
/*/
method isPrint(nCM,lVertical) class IPFwMsPrinter
	local lRet := .t.
	default lVertical := !::lLandscape

	if lVertical
		lRet := (::getLine() + (nCM * ::getVerticalProportion())) <= ::getLimVertical()
	else
		lRet := (::getLine() + (nCM * ::getHorizontalProportion())) <= ::getLimHorizontal()
	endif

return lRet
/*/{Protheus.doc} delFile
Deleta o arquivo definido no atributo ::cFilePrint
@author Tiago Faria
@since 08/02/2020
@version 1.0
@return nil

@type function
/*/
method delFile() class IPFwMsPrinter
	local nHandle := 0

	fErase(self:cFilePrint)
return

/*/{Protheus.doc} print
Realiza a impressão do relatorio e limpa o objeto da memoria
@author Tiago Faria
@since 07/11/2019
@version 1.0
@return nil

@type function
/*/
method print(lFreeObj,lDelFile) class IPFwMsPrinter
	local cFilePDF	 	:= ""
	default lFreeObj 	:= .t.
	default lDelFile	:= .t.

	if !::lCancelSetup
		cFilePDF := ::cPathPDF
		if right(::cPathPDF,1) != "\"
			cFilePDF += "\"
		endif

		cFilePDF += ::cFile

		if !(upper(".pdf") $ upper(cFilePDF))
			cFilePDF+=".pdf"
		endif

		sleep(nQtdSleep)
		_Super:print()

		if ::lPrintPDF
			if file(cFilePDF)
				nRet := shellExecute("print",cFilePDF,"","c:\",0)
				if nRet <= 32
					msgAlert("Erro ao enviar impressão para o Windows, imprima o arquivo manualmento salvo em " + cFilePDF)
					shellExecute("open",cFilePDF,"","c:\",0)
				endif
			endif
		endif
		if lDelFile
			::delFile()
		endif
	endif

	if lFreeObj
		//freeObj(self)
	endif
return .t.
/*/{Protheus.doc} showPrinterSetup
Disponibiliza uma Dialog genérica para definições de impressão
@author Tiago Faria
@since 08/02/2020
@version 1.0
@return lRet, logical, indica se a tela de setup foi clicado no botão OK [.t.] ou CANCELAR [.f.]
@param lDisablePaperSize, logical, indica se desabilita o botao para configurar o tamanho do papel
@param lDisableMargin, logical, indica se desabilita o botão para configurar a margem
@param lDisableOrientation, logical, indica se desabilita o botão para configurar a orientação da pagina a ser impressa 
@param lDisableDestination, logical, indica se desabilita o botão para selecionar o destino de impressão
@param cTitle, characters, Indica o titulo da tela de parametros
@type function
/*/
method showPrinterSetup(lDisablePaperSize,lDisableMargin,lDisableOrientation,lDisableDestination,cTitle) class IPFwMsPrinter
	local oSetup 				:= nil
	local nFlags				:= 0
	local lRet					:= .t.
	default lDisablePaperSize 	:= .t.
	default lDisableMargin		:= .t.
	default lDisableOrientation	:= .t.
	default lDisableDestination	:= .t.
	default cTitle 				:= "PARÂMETROS RELATÓRIO"
	/*
	PD_ISTOTVSPRINTER=1
	PD_DISABLEDESTINATION=2
	PD_DISABLEORIENTATION=4
	PD_DISABLEPAPERSIZE=8
	PD_DISABLEPREVIEW=16	
	*/
	nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPREVIEW
	if lDisablePaperSize
		nFlags += PD_DISABLEPAPERSIZE
	endif

	if lDisableMargin
		nFlags += PD_DISABLEMARGIN
	endif

	if lDisableOrientation
		nFlags += PD_DISABLEORIENTATION
	endif

	if lDisableDestination
		nFlags += PD_DISABLEDESTINATION
	endif

	oSetup := FWPrintSetup():New(nFlags, cTitle)
	/*
	PD_DESTINATION=1
	PD_PRINTTYPE=2
	PD_ORIENTATION=3
	PD_PAPERSIZE=4
	PD_PREVIEW=5
	PD_VALUETYPE=6
	PD_MARGIN=7
	*/
	oSetup:SetProperty(PD_DESTINATION,2)//1=SERVER;2=LOCAL
	//oPrintSetup:SetProperty(PD_PRINTTYPE,1)//1=DISCO;2=SPOOL;6=PDF
	oSetup:SetProperty(PD_ORIENTATION,1)//1=RETRATO;2=PAISAGEM
	lRet := oSetup:activate() == PD_OK

	oSetup:GetProperty(PD_ORIENTATION) == 1
	oSetup:GetProperty(PD_DESTINATION) == 2
	val( oSetup:cQtdCopia )

	::oPrintSetup := oSetup
return lRet
