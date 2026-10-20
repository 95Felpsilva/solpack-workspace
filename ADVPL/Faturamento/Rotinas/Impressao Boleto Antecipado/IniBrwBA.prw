#include 'totvs.ch'
/*/{Protheus.doc} iniBrwBA
Retorna o texto com a legenda do campo
@type function
@version 12.1.33
@author Tiago Faria
@since 02/12/2021
@return character, Retorna a legenda do campo
/*/
user function iniBrwBA()
    local cLeg := POSICIONE("SC5",1,XFILIAL("SC5")+SC9->C9_PEDIDO,"C5_ZZLEGBA")
return getX3Box("C5_ZZLEGBA",cLeg)

static function getX3Box(cField,cContent)
	local cBox 			:= getSX3Cache(cField,"X3_CBOX")
	local nInitCBox		:= 0
	local nMaxLenCombo 	:= 0
	local aTmp			:= {}
	local cRet			:= ""

	If !Empty(cBox) .and. !empty(cContent)
		aTmp := RetSX3Box(cBox,@nInitCBox,@nMaxLenCombo,getSX3Cache(cField,"X3_TAMANHO"))
		nPos := aScan(aTmp,{|X|upper(alltrim(X[2])) == upper(alltrim(cContent))})

		if nPos > 0
			cRet := alltrim(aTmp[nPos][1])
			aRet := strtokarr(cRet,"=")
			cRet := aRet[2]
		endif
	Endif
return cRet
