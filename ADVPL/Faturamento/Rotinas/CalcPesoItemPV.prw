#include 'totvs.ch'
/*/{Protheus.doc} CalcPesoItemPV
Função chamada dos campos C6_ZZPESOL e C6_ZZPESOB
@type function
@version 
@author Tiago Faria
@since 04/12/2020
@param cTipoPeso, character, param_description
@return numerico, retorna o peso do item do pedido
/*/
user function CalcPesoItemPV(cTipoPeso)
    local nRet := 0
    default cTipoPeso := "BRUTO"
    if funname() != "CRMA290"
        if cTipoPeso == "BRUTO"
            nRet := IF(INCLUI,0,SC6->C6_QTDVEN*RETFIELD("SB1",1,XFILIAL("SB1")+SC6->C6_PRODUTO,"B1_PESBRU"))
        elseif cTipoPeso == "LIQUIDO"
            nRet := IF(INCLUI,0,SC6->C6_QTDVEN*RETFIELD("SB1",1,XFILIAL("SB1")+SC6->C6_PRODUTO,"B1_PESO"))
        endif
    endif
return nRet
