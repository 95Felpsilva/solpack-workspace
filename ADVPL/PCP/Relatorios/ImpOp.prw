#include 'totvs.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "topconn.CH"
/*/{Protheus.doc} ImpOP
Impressão de OP
@type function
@version 12.1.27
@author Tiago Faria
@since 27/09/2021
/*/
user function ImpOP()
	local aBkpMV := u_saveMV()
	private lTemFichaTecnica := .f.
	private lImpOP           := .t.
	private lImpEtq          := .t.
	private lImpFichaTecnica := .t.
	private lImpFrenteVerso  := .t.
	private oReport          := nil
	if ask()
		reportDef()
		if lImpOP
			u_FSWImpOP(@oReport)
		endif

		if lImpFichaTecnica
            lTemFichaTecnica := impFichaTecnica(@oReport)
			if !lTemFichaTecnica .and. lImpFrenteVerso
				oReport:startPage()
				oReport:endPage()
			endif
		endif

		if lImpEtq
			u_RelEtqOp(@oReport,lImpFrenteVerso)
		endif

        oReport:print()
	endif

	u_restoreMV(aBkpMV)
return

static function reportDef()
	local cFilePrinter := "impop_" + FwTimeStamp()
	local lViewPDF		:= .t.
	local lLandscape    := .f.
	
	oReport := IpFwMsPrinter():new(cFilePrinter,lLandscape,lViewPDF)
return

static function impFichaTecnica(oReport)
    local cAlias := ''
    local cQuery := ''
    local lRet   := .f.

    cQuery += "SELECT" + CRLF
    cQuery += "	CZG_CDAC," + CRLF
    cQuery += "	CZG_CDRC," + CRLF
    cQuery += "	CZG_CDMD," + CRLF
    cQuery += "	MAX(CZG_VRFH) AS CZG_VRFH" + CRLF
    cQuery += "FROM" + CRLF
    cQuery += "	" + RetSqlTab('CZG') + CRLF
    cQuery += "WHERE 1=1" + CRLF
    cQuery += "	AND " + RetSqlFil('CZG') + CRLF
    cQuery += "	AND CZG_CDAC = '" + SC2->C2_PRODUTO + "'" + CRLF
    cQuery += "	AND " + RetSqlDel('CZG') + CRLF
    cQuery += "GROUP BY CZG_CDAC,CZG_CDRC,CZG_CDMD" + CRLF
    
    TcQuery cQuery new Alias (cAlias := getNextAlias())

    if Posicione("CZG",1,xFilial("CZG")+(cAlias)->(CZG_CDAC+CZG_CDRC+CZG_CDMD+CZG_VRFH),"!Eof()")
		lRet := .t.
        u_RelFichaTecnica(oReport)
    endif

    (cAlias)->(dbCloseArea())
return lRet

static function ask(lPerg)
	local lRet      := .t.
	local aParamBox := {}
	local nI        := 0
	local aMvPar    := saveMvPar()
	default lPerg   := .t.

	aadd(aParamBox, {4, "OP"           , .F., "", 45, "", .F.})
	aadd(aParamBox, {4, "Ficha Técnica", .F., "", 90, "", .F.})
	aadd(aParamBox, {4, "Etiqueta"     , .F., "", 90, "", .F.})
	aadd(aParamBox, {4, "Impressão Frente e Verso"     , .F., "", 90, "", .F.})

	if lPerg
		lRet := ParamBox(aParamBox,"Imprime OP",NIL,,,,,,,"_IMPOP",.T.,.t.)
	else
		for nI := 1 to len(aParambox)
			&("MV_PAR"+strzero(nI,2)) := ParamLoad(__cUserID+"_IMPOP",aParamBox,nI,aParamBox[nI,3])
		next nI
	endif

	if lRet
		lImpOP           := MV_PAR01
		lImpFichaTecnica := MV_PAR02
		lImpEtq          := MV_PAR03
		lImpFrenteVerso  := MV_PAR04
	endif
	restoreMvPar(aMvPar)
return lRet

static function saveMvPar()
	Local aMvPar	:= {}
	Local nMV		:= 0

	For nMv := 1 To 60
		aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
	Next nMv
Return aMvPar

static function restoreMVPar(aMvPar)
	Local nMv	 	:= 0

	For nMv := 1 To Len( aMvPar )
		&( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
	Next nMv
Return
