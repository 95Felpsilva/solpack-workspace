#include 'totvs.ch'
#INCLUDE "RPTDEF.CH"

static ALIGN_ESQUERDA   := 0
static ALIGN_DIREITA    := 1
static ALIGN_CENTRO     := 2

user function tstGridFWMsPrinter()
    local lDisableSetup	:= .t.
    local lViewPDF		:= .t.
    local lServer		:= .f.
    local cFilePrinter	:= "tst_" + cvaltochar(seconds())
    local cPathInServer	:= "c:\temp\glovis\"
    local oColumn 	    := nil
    local aAux          := {}
    local oPrintGrid    := nil
    LOCAL oBlueBrush  := TBrush():New( , rgb(239,245,251))
    local nItem         := 0
    Private oFont08		:= TFont():New("Arial",32,32,,.F.,,,,.T.,.F.)
    Private oFont08N	:= TFont():New("Arial",32,32,,.T.,,,,.T.,.F.)
    private oPrint      := nil

    RpcSetType( 3 )
    RpcSetEnv("01", "0101")

    oPrint := FWMSPrinter():New(cFilePrinter/*cFilePrintert */,IMP_PDF/*nDevice*/,.f./*lAdjustToLegacy*/,cPathInServer/*cPathInServer*/ ,lDisableSetup/*lDisabeSetup*/,/*lTReport*/,/*oPrintSetup*/,/*cPrinter*/,lServer/*lServer*/,/*lPDFAsPNG*/,/*lRaw*/,lViewPDF,/*nQtdCopy*/)
    oPrint:cPathPDF := cPathInServer
    oPrint:SetPortrait()
    oPrint:SetResolution(72)
    oPrint:SetParm("-RFS" )
    //oPrint:SetMargin(60,60,60,60)
    //oPrint:SetPaperSize(DMPAPER_A4)
    oPrint:startPage()

    oPrintGrid := GridFwMsPrinter():new(1.3/*nTamBox*/,1/*nCMIniGrid*/,5/*nCMPageAtual*/,29/*nLimPage*/,.t./*lImpCabec*/,/*bNewPage*/,1.40/*nRecuoSayAlign*/,.f./*lBoxLine*/)

    oColumn := ColumnFwMsPrinter():new(2,"IT",oFont08,ALIGN_CENTRO)
    oPrintGrid:addCell(oColumn)

    oColumn := ColumnFwMsPrinter():new(5,"PREÇO 1",oFont08,ALIGN_CENTRO)
    oPrintGrid:addCell(oColumn)

    oColumn := ColumnFwMsPrinter():new(5,"PREÇO 2",oFont08,ALIGN_CENTRO)
    oPrintGrid:addCell(oColumn)

    oColumn := ColumnFwMsPrinter():new(5,"PREÇO 3",oFont08,ALIGN_CENTRO)
    oPrintGrid:addCell(oColumn)

    while nItem < 17
        nItem++
        if nItem % 2 <> 0
            oBlueBrush  := TBrush():New( , rgb(176,224,230))
        else
            oBlueBrush := nil
        endif
        oColumn := ColumnFwMsPrinter():new(,{cValToChar(nItem)},oFont08N,ALIGN_ESQUERDA,oBlueBrush,rgb(255,0,0)/*nColorText*/)
        aAdd(aAux,oColumn)

        oColumn := ColumnFwMsPrinter():new(,{"853,89","2"},oFont08N,ALIGN_ESQUERDA,oBlueBrush)
        aAdd(aAux,oColumn)

        oColumn := ColumnFwMsPrinter():new(,"853,89",oFont08N,ALIGN_DIREITA,oBlueBrush)
        aAdd(aAux,oColumn)

        oColumn := ColumnFwMsPrinter():new(,"1",oFont08N,ALIGN_CENTRO,oBlueBrush)
        aAdd(aAux,oColumn)

        oPrintGrid:addLine(aclone(aAux))

        aAux := {}
    enddo
    nLin := oPrintGrid:print(oPrint)

    oPrint:endPage()
    oPrint:print()

    RpcClearEnv()
return


    class GridFwMsPrinter
        data aHeaderRel as array
        data aColsRel as array
        data nLimPage as numeric
        data nCMPageAtual as numeric
        data bNewPage as block
        data nTamBox as numeric
        data nCMIniGrid as numeric
        data aColumnModel as array
        data aItens as array
        data lImpCabec as boolean
        data nRecuoSayAlign as numeric
        data lBoxLine as logical
        method new(aColumns,nLimPage) Constructor
        method print(oPrint)
        method headerToLine()
        method lineToColumn()
        method printLines(oPrint)
        method printColumns(oPrint)
        method getCMAlign()
        method addCell()
        method addLine()
        method boxRect()
    endClass

method new(nTamBox,nCMIniGrid,nCMPageAtual,nLimPage,lImpCabec,bNewPage,nRecuoSayAlign,lBoxLine) class GridFwMsPrinter
    default nTamBox			:= 0
    default nCMPageAtual	:= 0
    default nLimPage		:= 29
    default nCMIniGrid		:= 1
    default bNewPage		:= {|oPrint|oPrint:endPage(),oPrint:startPage(),1}
    default lImpCabec		:= .t.
    default nRecuoSayAlign  := 0.35
    default lBoxLine        := .t.

    ::aHeaderRel	:= {}
    ::aColsRel		:= {}
    ::nLimPage		:= nLimPage
    ::bNewPage		:= bNewPage
    ::nCMPageAtual 	:= nCMPageAtual
    ::nTamBox		:= nTamBox
    ::nCMIniGrid	:= nCMIniGrid
    ::aColumnModel	:= {}
    ::aItens		:= {}
    ::lImpCabec		:= lImpCabec
    ::nRecuoSayAlign:= nRecuoSayAlign
    ::lBoxLine      := lBoxLine
return

method print(oPrint,cPixel) class GridFwMsPrinter
    ::aColumnModel := ::HeaderToLine()
    if ::lImpCabec
        aAdd(::aItens,aClone(::aColumnModel))
    endif
    ::lineToColumn()

    ::printLines(oPrint,cPixel)
return ::nCMPageAtual

method printLines(oPrint,cPixel) class GridFwMsPrinter
    local nItem 			:= 0
    local aColumn			:= {}

    for nItem := 1 to len(::aItens)
        aColumn := ::aItens[nItem]

        ::printColumns(oPrint,aColumn,nItem,,cPixel)
    next nItem
return ::nCMPageAtual

method printColumns(oPrint,aColumn,nItem,nPosIniString,cPixel) class GridFwMsPrinter
    local aColOrd 			:= aSort(aClone(aColumn),,,{|X,Y|X[3]:nQtdLin > Y[3]:nQtdLin})
    local nMaxQtdLinBox 	:= 0
    local lQuebraPagina		:= .t.
    local nCMAtual			:= 0
    local nCMLinAtual		:= 0
    local nColumn			:= 0
    local nCMIni			:= 0
    local nCMFim			:= 0
    local aString			:= {}
    local oFont				:= nil
    local nQtdString		:= 0
    local lSomou			:= .t.
    local nString			:= 0
    local nEspacoDisponivel := 0
    local nQtdBoxDisponivel := 0
    local aLinSomado		:= {}
    local nAlign            := 0
    local nRecuoBox         := 0.01
    local oColumn           := nil
    local nBoxTop           := 0
    local nBoxLeft          := 0
    local nBoxBottom        := 0
    local nBoxRight         := 0
    local nClrText          := nil
    default nPosIniString	:= 1

    if ::nLimPage - ::nCMPageAtual <= 0
        ::nCMPageAtual := eval(::bNewPage,oPrint)
        nCMAtual := ::nCMPageAtual
    else
        nCMAtual := ::nCMPageAtual
    endif

    nEspacoDisponivel := ::nLimPage - nCMAtual

    nMaxQtdLinBox := (aColOrd[1,3]:nQtdLin- nPosIniString) + 1
    nQtdBoxDisponivel := ::nTamBox * nMaxQtdLinBox

    if nEspacoDisponivel < nQtdBoxDisponivel
        nQtdBoxDisponivel := NoRound(nEspacoDisponivel / ::nTamBox,0)
        lQuebraPagina 	:= .t.
    else
        nQtdBoxDisponivel := nMaxQtdLinBox
        lQuebraPagina	:= .f.
    endif

    nCMLinAtual	:= 	nCMAtual

    for nColumn := len(aColumn) to 1 step -1
        nCMIni 		:= aColumn[nColumn,1]
        nCMFim		:= aColumn[nColumn,2]
        oColumn     := aColumn[nColumn,3]
        aString		:= oColumn:aString
        oFont		:= oColumn:oFont
        nQtdString 	:= oColumn:nQtdLin
        nAlign      := oColumn:nAlign
        oBrush      := oColumn:oBrush
        nClrText    := oColumn:nColorText

        nBoxTop     := nCMLinAtual
        nBoxLeft    := ::nCMIniGrid
        nBoxBottom  := nCMLinAtual+(::nTamBox * nQtdBoxDisponivel)
        nBoxRight   := nCMFim
        lSomou		:= .f.

        if ::lBoxLine
            nRecuoBox := 0
            nBoxTop-= nRecuoBox
            ::boxRect(nBoxTop,nBoxLeft,nBoxBottom,nBoxRight,oBrush,cPixel)
        else
            nRecuoBox := 0.01
            nBoxTop-= nRecuoBox
            oPrint:box(CToP(nBoxTop),CToP(nBoxLeft),CToP(nBoxBottom),CToP(nBoxRight),cPixel)
            if valType(oBrush) == "O"
                oPrint:Fillrect( {CToP(nCMLinAtual-nRecuoBox+0.01), CToP(::nCMIniGrid+0.01), CToP(nCMLinAtual+(::nTamBox * nQtdBoxDisponivel)-0.05), CToP(nCMFim-0.07) }, oBrush, /*"-2"*/)
            endif
        endif
        for nString := nPosIniString to len(aString)
            if nString > nQtdBoxDisponivel + (nPosIniString - 1)
                exit
            endif

            cString := aString[nString]
            nPosSay := nCMLinAtual+(::nTamBox * ((nString - nPosIniString) + 1))
            nPosSay -=0.08

            //nCM := ::getCMAlign(cString,nAlign,nCMIni,nCMFim,oFont,oPrint)

            oPrint:SayAlign(CToP(nPosSay-::nRecuoSayAlign),CToP(nCMIni-nRecuoBox+0.03),cString,oFont,CToP(nCMFim-nCMIni-0.03)/*nWidth*/,/*nHeigth*/,nClrText/*nClrText*/,nAlign/*nAlignHorz*/,/*nAlignVert*/)
            //oPrint:say(CToP(nPosSay),CToP(nCM),cString,oFont,CToP(nCMFim-nCMIni))
            //só incrementa a posicao do relatorio se for a coluna com mais linhas a ser impressa
            if nQtdString == (nMaxQtdLinBox + (nPosIniString - 1)) .and. aScan(aLinSomado,{|X|X[1] == nItem .and. X[2]==nString}) == 0
                ::nCMPageAtual += ::nTamBox
                lSomou := .t.
                aAdd(aLinSomado,{nItem,nString})
            endif
        next nString
    next nColumn

    nCMAtual := ::nCMPageAtual

    if lQuebraPagina

        nCMAtual := eval(::bNewPage,oPrint)

        if ::lImpCabec
            oGrid := GridFwMsPrinter():new()
            oGrid:aHeaderRel        := ::aHeaderRel
            oGrid:aColsRel          := {}
            oGrid:nTamBox           := ::nTamBox
            oGrid:nCMIniGrid        := ::nCMIniGrid
            oGrid:nCMPageAtual      := nCMAtual
            oGrid:nLimPage          := ::nLimPage
            oGrid:lImpCabec         := ::lImpCabec
            oGrid:bNewPage          := ::bNewPage
            oGrid:nRecuoSayAlign    := ::nRecuoSayAlign
            oGrid:lBoxLine          := ::lBoxLine
            ::nCMPageAtual := oGrid:print(oPrint)//-0.01
        endif
        ::printColumns(oPrint,aColumn,nItem,nQtdBoxDisponivel+1,cPixel)
    endif
return nCMAtual

method HeaderToLine() class GridFwMsPrinter
    local nColumn 	:= 0
    local aAux		:= {}
    local nCMIni	:= ::nCMIniGrid
    local aColumn	:= {}

    for nColumn := 1 to len(::aHeaderRel)
        oColumn := ::aHeaderRel[nColumn]

        aAdd(aAux,nCMIni)
        aAdd(aAux,nCMIni+oColumn:nCMLargura)
        aAdd(aAux,oColumn)

        aAdd(aColumn,aClone(aAux))
        aAux := {}

        nCMIni+=oColumn:nCMLargura
    next nColumn
return aColumn

method lineToColumn() class GridFwMsPrinter
    local nItem 	:= 0
    local aItem 	:= {}
    local nColumn	:= 0
    local oColumn   := nil
    for nItem := 1 to len(::aColsRel)
        aItem := ::aColsRel[nItem]

        for nColumn := 1 to len(aItem)
            oColumn := aItem[nColumn]

            ::aColumnModel[nColumn][3] := oColumn
        next nColumn

        aAdd(::aItens,aClone(::aColumnModel))
    next nItem
return

method getCMAlign(cString,nAlign,nCMIni,nCMFim,oFont,oPrint) class GridFwMsPrinter
    local nLenCM    := 0
    local nRet      := 0
    local nLenFont  := 0
    default cString := ""
    default nAlign  := ALIGN_ESQUERDA
    default nCMIni  := 0
    default nCMFim  := 0

    if nAlign == ALIGN_ESQUERDA .or. nAlign == ALIGN_CENTRO
        nLenFont := PToC(oPrint:GetTextWidth (cString,oFont,2))
    endif

    nLenCM := nCMFim - nCMIni

    if nAlign == ALIGN_DIREITA
        //0.02 = Espaço em CM adicional para a impressão não sair em cima do grid
        nRet := nCMIni += 0.02
    endif

    if nAlign == ALIGN_ESQUERDA
        nRet := nCMFim - nLenFont - 0.02
    endif

    if nAlign == ALIGN_CENTRO
        //calcula para impressao no centro com a formula
        //nLenCM = Espaco disponivel no Grid
        //nLenFont = Espaco que a fonte ocupara no Grid
        //(nLenCM - nLenFont) = Espaco que ficará em branco no box
        //((nLenCM - nLenFont) / 2) = Divide o espaço que ficará em branco no box em 2
        nRet := nCMIni + ((nLenCM - nLenFont) / 2)
    endif
return nRet

method addCell(oCell) class GridFwMsPrinter
    aAdd(::aHeaderRel,oCell)
return

method addLine(aLine) class GridFwMsPrinter
    aAdd(::aColsRel,aLine)
return

method boxRect(nBoxTop,nBoxLeft,nBoxBottom,nBoxRight,oBrush,cPixel) class GridFwMsPrinter
    if valType(oBrush) == "O"
        //imprime box colorido sem borda
        oPrint:Fillrect( {CToP(nBoxTop), CToP(nBoxLeft), CToP(nBoxBottom), CToP(nBoxRight) }, oBrush, /*"-2"*/)
    endif
    //imprime as bordar do box colorido
    //imprime as linhas na horizontal
    oPrint:Line(CToP(nBoxTop)       , CToP(nBoxLeft)   , CToP(nBoxTop)    , CToP(nBoxRight), , cPixel)
    oPrint:Line(CToP(nBoxBottom)    , CToP(nBoxLeft)   , CToP(nBoxBottom) , CToP(nBoxRight), , cPixel)
    //imprime as linhas na vertical
    oPrint:Line(CToP(nBoxTop)       , CToP(nBoxLeft)   , CToP(nBoxBottom)    , CToP(nBoxLeft), , cPixel)
    oPrint:Line(CToP(nBoxTop)       , CToP(nBoxRight)   , CToP(nBoxBottom)    , CToP(nBoxRight), , cPixel)
    /*
    if !empty(cText)
        //imprime o texto
        oPrint:Say(CToP(nTextRow),CToP(nTextCol),cText,oFont)
    endif
    */
return

static function CToP(nCentimetro,nArred)
    local nResolution 	:= oPrint:getResolution()
    local nFator 		:= nResolution/2.54

    default nArred := 9
return round(nCentimetro*nFator,nArred)

static function PToC(nPixel,nArred)
    local nResolution 	:= oPrint:getResolution()
    local nFator 		:= nResolution/2.54

    default nArred := 9
return round(nPixel/nFator,nArred)
