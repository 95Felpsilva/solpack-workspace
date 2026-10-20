#include 'totvs.ch'
/*/{Protheus.doc} RelPedSituacao
Relatório de pedido de vendas por situação ATRASADO, IMEDIATO, PROGRAMADO
@type function
@version 12.1.27
@author Tiago Faria
@since 13/08/2021
/*/
user function RelPedSituacao()
    private cProdDe := ""
    private cProdAte := ""

    if ask()
        u_detalharSaldo(cProdDe,cProdAte)
    endif
return

static function ask()
	Local aParamBox := {}
    local lRet      := .f.

	Aadd(aParamBox,{1,"Produto De"			,Space(getSX3Cache("B1_COD","X3_TAMANHO")),	"",	"",	"SB1",	"",70, .F.})// MV_PAR01
	Aadd(aParamBox,{1,"Produto Ate"			,Space(getSX3Cache("B1_COD","X3_TAMANHO")),	"",	"",	"SB1",	"",70, .T.})// MV_PAR02

	If ParamBox(aParamBox,"Filtros Relatório",,,,,,,,"RelPedSituacao",.T.,.T.)
        lRet := .t.
        cProdDe := MV_PAR01
        cProdAte := MV_PAR02
	EndIf
return lRet
