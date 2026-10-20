#include 'totvs.ch'
/*/{Protheus.doc} F070BTOK
PE no TOK na baixa de titulos a pagar
@type function
@version 12.1.33
@author Tiago Faria
@since 22/11/2021
@return logical, Se true pode realizar a baixa se false não pode
/*/
user function F070BTOK()
	local lRet    := .t.
	local lBolAnt := .f.
    local cCodMotBx := getCodMotBx(cMotBX)
	If ExistBlock("BolAntecip")
		oBolAntecip := BolAntecipDel():new()
		lBolAnt := !oBolAntecip:canAccess(.f./*lHelp*/)

		if lBolAnt .and. cCodMotBx  <> oBolAntecip:getMotBx() .and. cCodMotBx <> oBolAntecip:getMotBxMan()
			lRet := .f.
			u_myHelp("Para títulos com boleto antecipado só poderá ser utilizado o motivo de baixa " + oBolAntecip:getMotBx() + " ou " + oBolAntecip:getMotBxMan())
		endif
		if lBolAnt .and. lRet
			oBol := BolAntecip():new()
			lRet := oBol:geraRA(nValRec,dBaixa,cCodMotBx)
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
