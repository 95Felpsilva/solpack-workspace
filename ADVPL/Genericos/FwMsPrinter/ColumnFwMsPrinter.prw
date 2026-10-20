#include 'totvs.ch'

static ALIGN_ESQUERDA   := 0
static ALIGN_DIREITA    := 1
static ALIGN_CENTRO     := 2

class ColumnFwMsPrinter
    data nCMLargura as numeric
    data aString as string
    data nQtdLin as numeric
    data oFont as TFont
    data nAlign as numeric
    data oBrush as TBrush
    data nColorText as numeric
    
    method new(nCMLargura,aString) Constructor
    method addText(cText)
endClass

method new(nCMLargura,xString,oFont,nAlign,oBrush,nColorText) class ColumnFwMsPrinter
    local aString		:= {}
    local cType         := ""
    default nCMLargura	:= 0
    default oFont       := nil
    default nAlign      := ALIGN_ESQUERDA

    cType := valType(xString)
    ::nCMLargura	:= nCMLargura
    if cType == "C"
        //if !empty(xString)
            aAdd(aString,xString)
        //else
        //    xString := {}
        //endif
    elseif cType == "A"
        aString 	:= xString
    else
        aString := {}
    endif
    
    ::aString		:= aString
    ::nQtdLin 		:= len(aString)
    ::oFont	        := oFont
    ::nAlign        := nAlign
    ::oBrush        := oBrush
    ::nColorText    := nColorText
return

method addText(cText,lForceEmpty) class ColumnFwMsPrinter
    default cText := ""
    default lForceEmpty := .f.

    if !empty(cText) .or. lForceEmpty
        aAdd(::aString,cText)
        ::nQtdLin := len(::aString)
    endif
return
