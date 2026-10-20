#include 'totvs.ch'
#include 'topconn.ch'
/*/{Protheus.doc} ApParada
    Validação referente ao apontamento de parada de máquina MATA682
    @type  Function
    @author user
    @since 08/09/2020
    @return nil
    /*/
user function ApParada()
    local lRet              := .t.
    local aArea             := Lj7GetArea({"SH6","SD3"})
    local cAlias            := getQuery()
    local oTime             := nil
    local cTempoParada      := ""
    local cTempoApontamento := ""

    if (cAlias)->(!eof())
        SH6->(dbGoTo((cAlias)->RECNOH6))
        oTime := Time():new(M->H6_HORAINI)
        cTempoParada := oTime:calcTotalHora(M->H6_DATAINI,M->H6_HORAINI,M->H6_DATAFIN,M->H6_HORAFIN)

        cTempoApontamento := H6tempoToTime(SH6->H6_TEMPO)
        cTempoSemParada := oTime:secToTime(oTime:diffTime(cTempoParada,cTempoApontamento))
        cTempoSemParada := formatH6Tempo(cTempoSemParada)

        recLock("SH6",.f.)
        SH6->H6_TEMPO := cTempoSemParada
        SH6->(msUnlock())

        updMODSD3(SH6->H6_IDENT,cTempoSemParada)
    endif
    (cAlias)->(dbCloseArea())

    Lj7RestArea(aArea)
return lRet

static function getQuery()
    local cQuery    := ""
    local cAlias    := ""
    local cDtInicio := dtos(M->H6_DATAINI) + " " + M->H6_HORAINI
    local cDtFim    := dtos(M->H6_DATAFIN) + " " + M->H6_HORAFIN

    cQuery += "SELECT" + CRLF
    cQuery += " 	H6_RECURSO," + CRLF
    cQuery += " 	H6_OP," + CRLF
    cQuery += " 	H6_DATAINI," + CRLF
    cQuery += " 	H6_HORAINI," + CRLF
    cQuery += " 	H6_HORAFIN," + CRLF
    cQuery += " 	H6_DATAFIN," + CRLF
    cQuery += " 	SH6.R_E_C_N_O_  AS RECNOH6" + CRLF
    cQuery += " FROM " + CRLF
    cQuery += " 	" + retSqlTab("SH6") + CRLF
    cQuery += " WHERE 1=1" + CRLF
    cQuery += " 	AND " + retSqlFil("SH6") + CRLF
    cQuery += " 	AND H6_OP <> ' '" + CRLF
    cQuery += " 	AND H6_DATAINI >= '20200901'--DATA DE IMPLANTACAO DA ROTINA, NECESSARIO POIS HÁ REGISTROS ANTIGOS NO BANCO COM A DATA OU HORA ERRADA" + CRLF
    cQuery += " 	AND H6_RECURSO = '" + M->H6_RECURSO + "'" + CRLF
    cQuery += " 	AND CONVERT(DATETIME,'" + cDtInicio  + "') BETWEEN CONVERT(DATETIME,H6_DATAINI + ' ' + H6_HORAINI) AND CONVERT(DATETIME,H6_DATAFIN + ' ' + H6_HORAFIN)" + CRLF
    cQuery += " 	AND CONVERT(DATETIME,'" + cDtFim + "') BETWEEN CONVERT(DATETIME,H6_DATAINI + ' ' + H6_HORAINI) AND CONVERT(DATETIME,H6_DATAFIN + ' ' + H6_HORAFIN)" + CRLF
    cQuery += " 	AND " + retSqlDel("SH6") + CRLF
    cQuery += " ORDER BY R_E_C_N_O_  DESC" + CRLF

    cQuery := ChangeQuery(cQuery)

    memoWrite("\sql\APPARADA.SQL",cQuery)

    TcQuery cQuery new Alias (cAlias := getNextAlias())
return cAlias

static function formatH6Tempo(cTempo)
    local aTempo := strToKarr(cTempo,":")
    local cRet   := ""

    for nTempo := 1 to len(aTempo)
        //se for os segundos da hora não considera
        if nTempo > 2
            exit
        endif
        cTempo := aTempo[nTempo]

        if nTEmpo == 1//hora
            if len(cTempo) == 2
                cTempo := "0" + cTempo
            endif
        endif

        if nTempo > 1
            cRet += ":"
        endif

        cRet += cTempo
    next nTempo
return cRet

static function horaToDecimal(cTempo)
    local aTempo := strToKarr(cTempo,":")
    local cRet   := ""

    for nTempo := 1 to len(aTempo)
        //se for os segundos da hora não considera
        if nTempo > 2
            exit
        endif
        cTempo := aTempo[nTempo]

        if nTempo == 2 //segundos - proporciona em decimal
            cTempo := strtran(cValToChar((val(cTempo) / 60) * 100),".","")
        endif

        if nTempo > 1
            cRet += "."
        endif

        cRet += cTempo
    next nTempo
return val(cRet)

static function updMODSD3(cIdent,cTempoSemParada)
    local cQuery := ""
    local cAlias := ""

    cQuery += "SELECT" + CRLF
    cQuery += "	SD3.R_E_C_N_O_ AS D3RECNO" + CRLF
    cQuery += "FROM " + CRLF
    cQuery += "	" + retSqlTab("SD3") + CRLF
    cQuery += "WHERE 1=1" + CRLF
    cQuery += "	AND " + retSqlFil("SD3") + CRLF
    cQuery += "	AND D3_IDENT = '" + cIdent + "'" + CRLF
    cQuery += "	AND D3_TIPO = 'MO'" + CRLF
    cQuery += "	AND D3_ESTORNO <> 'S'" + CRLF
    cQuery += "	AND " + retSqlDel("SD3") + CRLF

    TcQuery cQuery new Alias (cAlias := getNextAlias())

    while (cAlias)->(!Eof())
        SD3->(dbGoTo((cAlias)->(D3RECNO)))

        recLock("SD3",.f.)
        SD3->D3_QUANT := horaToDecimal(cTempoSemParada)
        SD3->(msUnlock())

        (cAlias)->(dbSkip())
    enddo
return

static function H6tempoToTime(cTempo)
    local aTempo := strToKarr(cTempo,":")
    local cRet   := ""

    for nTempo := 1 to len(aTempo)
        cTempo := aTempo[nTempo]
        if nTempo == 1
            cTempo := strZero(val(cTempo),2)
        endif

        //se for os segundos da hora não considera
        if nTempo > 2
            exit
        endif

        if nTempo > 1
            cRet += ":"
        endif

        cRet += cTempo
    next nTempo
return cRet
