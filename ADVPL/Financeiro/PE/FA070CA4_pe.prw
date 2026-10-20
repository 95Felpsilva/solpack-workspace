#include 'totvs.ch'
/*/{Protheus.doc} FA070CA4
TOK no cancelamento da baixa de titulos a receber
@type function
@version 12.1.33
@author Tiago Faria
@since 22/11/2021
@return logical, Se true pode excluir a baixa se false nao pode
/*/
user function FA070CA4()
	local lRet := .t.
    local lBoletoAntecipado := .t.
	If ExistBlock("BolAntecipDel")
		oBolAntecip := BolAntecipDel():new()
		lBoletoAntecipado := !oBolAntecip:canAccess(.f./*lHelp*/)
		
        if lBoletoAntecipado
            lRet := oBolAntecip:deletaTitulo(SE1->E1_NUM,.T./*lApenasRA*/,SE1->E1_PARCELA)
        endif
	endif
return lRet
