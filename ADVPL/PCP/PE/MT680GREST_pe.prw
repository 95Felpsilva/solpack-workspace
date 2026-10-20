#include 'totvs.ch'
#include 'topconn.ch'
/*/{Protheus.doc} MT680GREST
    Estorno do Movimento
    @type  Function
    @author user
    @since 08/09/2020
    @return nil
    /*/
user function MT680GREST()
    local aArea     := Lj7GetArea({"SD3","CTT"})
    local cQuery    := ""
    local cAlias    := ""

    cQuery += "SELECT" + CRLF
    cQuery += " SD3.R_E_C_N_O_ AS D3RECNO" + CRLF
    cQuery += "FROM" + CRLF
    cQuery += " " + retSqlTab("SD3") + CRLF
    cQuery += "WHERE 1=1" + CRLF
    cQuery += " AND " + retSqlFil("SD3") + CRLF
    cQuery += " AND D3_OP = '" + SH6->H6_OP + "'" + CRLF
    cQuery += " AND D3_IDENT = '" + SH6->H6_IDENT + "'" + CRLF
    cQuery += " AND D3_TIPO = 'MO'" + CRLF 
    cQuery += " AND D3_ESTORNO <> 'S'" + CRLF
    cQuery += " AND " + retSqlDel("SD3") + CRLF

    TcQuery cQuery new Alias (cAlias := getNextAlias())

    while (cAlias)->(!Eof())
        SD3->(dbGoTo((cAlias)->(D3RECNO)))
        recLock("SD3",.f.)
        SD3->(dbDelete())
        SD3->(msUnlock())
        (cAlias)->(dbSkip())
    enddo

    (cAlias)->(dbCloseArea())

    Lj7RestArea(aArea)

    If FindFunction("u_PCP01AtualizaProgramacao")
        u_PCP01AtualizaProgramacao(SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN)
    EndIf

	if ExistBlock("GrvCpoOP1")
		u_GrvCpoOP1(SH6->H6_OP, SH6->H6_QTDPROD, .t.)
	endif
return
