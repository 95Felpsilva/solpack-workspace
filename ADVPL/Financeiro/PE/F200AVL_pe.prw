#include 'totvs.ch'
/*/{Protheus.doc} F200AVL
PE para avaliar se deve ou nao processar o título retornado do cnab
@type function
@version 12.1.33
@author Tiago Faria
@since 05/11/2021
@return logical, Se true processa o titulo se false não processa
/*/
user function F200AVL()
	local lRet      := .t.
	local aValores  := PARAMIXB[1]

	If ExistBlock("BolAntecip")
		oBolAntecip := BolAntecip():new()
		aRet := oBolAntecip:bxTitCNAB(aValores)
        lRet := aRet[2]
	endif
return lRet
