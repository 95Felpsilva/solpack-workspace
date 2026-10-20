#include 'totvs.ch'
/*/{Protheus.doc} F040BLQ
PE para bloquear o acesso a rotina nas operações de INCLUSAO, ALTERACAO e SUBISTITUICAO
@type function
@version 12.1.33
@author Tiago Faria
@since 04/11/2021
@return logical, Se true pode acessar se false não pode
/*/
user function F040BLQ()
	local lRet := .t.

	If ExistBlock("BolAntecipDel") .and. !INCLUI
		oBolAntecip := BolAntecipDel():new()
        lRet := oBolAntecip:canAccess()
	endif
return lRet
