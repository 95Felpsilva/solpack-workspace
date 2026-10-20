#include 'totvs.ch'
#include 'topconn.ch'

user function SF1100I()
    local cAlias    := ""
    local lF050MDVC := existBlock("F050MDVC")
    local aParam    := {}
    return
    if lF050MDVC
        cAlias := getTitulosImposto()
        while (cAlias)->(!Eof())
            SE2->(dbGoTo((cAlias)->(RECNOSE2)))

            aParam := {}
            aAdd(aParam,SE2->E2_VENCREA)
            aAdd(aParam,alltrim(SE2->E2_NATUREZ))
            aAdd(aParam,SE2->E2_EMISSAO)
            aAdd(aParam,SE2->E2_EMIS1)
            aAdd(aParam,SE2->E2_VENCREA)

            dDtVencPCC := ExecBlock("F050MDVC",.F.,.F.,aParam)

            if dDtVencPCC <> SE2->E2_VENCREA
                recLock("SE2",.F.)
                SE2->E2_VENCTO  := dDtVencPCC
                SE2->E2_VENCREA := dDtVencPCC
                SE2->(msUnlock())
            endif
            (cAlias)->(dbSkip())
        enddo

    endif
return

static function getTitulosImposto()
    local cAlias := ""
    local cQuery := ""

    cQuery += "SELECT" + CRLF
    cQuery += "    SE2.R_E_C_N_O_ AS RECNOSE2" + CRLF
    cQuery += "FROM" + CRLF
    cQuery += "    " + retSqlTab("SE2") + CRLF
    cQuery += "WHERE 1=1" + CRLF
    cQuery += "    AND " + retSqlFil("SE2") + CRLF
    cQuery += "    AND E2_NUM = '" + SF1->F1_DOC + "'" + CRLF
    cQuery += "    AND E2_PREFIXO = '" + SF1->F1_SERIE + "'" + CRLF
    //E2_TITPAI = E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
    cQuery += "    AND E2_TITPAI LIKE '%" + SF1->(F1_SERIE+F1_DOC) + "%'" + CRLF
    cQuery += "    AND E2_TITPAI LIKE '%NF " + SF1->(F1_FORNECE+F1_LOJA) + "%'" + CRLF
    cQuery += "    AND E2_TIPO = 'TX'" + CRLF
    cQuery += "    AND E2_NATUREZ IN ('PIS','COFINS','CSLL')" + CRLF
    cQuery += "    AND " + retSqlDel("SE2") + CRLF

    TcQuery cQuery new Alias (cAlias := getNextAlias())
return cAlias
