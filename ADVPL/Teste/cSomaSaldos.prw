#include 'totvs.ch'
User Function xTotal(cSomaSaldos)
Local nRet          := 0
Local cAlias        := GetNextAlias()

Default cSomaSaldos := ZSB->ZSB_TOTAL

BeginSQL alias cAlias

SELECT SUM(distinct ZSB_BRADES+ZSB_BRASIL+ZSB_QITECH+ZSB_SOMAET+ZSB_CREPAR+ZSB_ITAU) AS SALDO_TOTAL
from %Table:ZSB%
where
     %NOTDEL%
     AND ZSB_FILIAL      = %xfilial:ZSB%
     AND ZSB_TOTAL       = %Exp:cSomaSaldos%
EndSQL

IF !(cAlias)->(EOF())
     nRet := (cAlias)->SALDO_TOTAL
EndIf

IF Select(cAlias)> 0
     (cAlias)->(dbCloseArea())
EndIF
Return nRet
