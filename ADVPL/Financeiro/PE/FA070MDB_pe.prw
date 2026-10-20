#include 'totvs.ch'
/*/{Protheus.doc} FA070MDB
Valida motivo da baixa
@type function
@version 12.1.33
@author Tiago Faria
@since 05/11/2021
@return logical, Se true pode utilizar o motivo de baixa se false não pode
/*/
user function FA070MDB()
    local lRet := .t.
	If ExistBlock("BolAntecipDel")
		oBolAntecip := BolAntecipDel():new()
		if !oBolAntecip:canAccess(.f./*lHelp*/) .and. getCodMotBx(cMotBX) <> oBolAntecip:getMotBx() .and. getCodMotBx(cMotBX) <> oBolAntecip:getMotBxMan()
            lRet := .f.
            u_myHelp("Para títulos com boleto antecipado só poderá ser utilizado o motivo de baixa " + oBolAntecip:getMotBx() + " ou " + oBolAntecip:getMotBxMan())
		endif
	endif
return lRet

static function getCodMotBx(cText)
	local aMotBX := readMotBX()
	local nPos   := aScan(aMotBX,{|X| alltrim(SubStr(X,7,10)) == alltrim(cText)})
	local cCod   := ""

	if nPos > 0
		cCod := subStr(aMotBX[nPos],1,3)
	endif
return cCod
