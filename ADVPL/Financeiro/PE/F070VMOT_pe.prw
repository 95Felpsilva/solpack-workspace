#include 'totvs.ch'
/*/{Protheus.doc} F070VMOT
Ponto de Entrada para o usuário fazer	a sua própria validação a respeito do motivo da baixa.
@type function
@version 12.1.33
@author Tiago Faria
@since 05/11/2021
@return logical, Se true pode realizar a baixa se false não pode
/*/
user function F070VMOT()
	local lRet := .t.

	If ExistBlock("BolAntecipDel")
		oBolAntecip := BolAntecipDel():new()
		if oBolAntecip:canAccess(.f./*lHelp*/)
            lRet := vldPadrao()
		endif
    else
        lRet := vldPadrao()
	endif
return lRet
/*
Clone da validação existente na função Fa070ValMo que está no fonte FINXBX.PRX
*/
static function vldPadrao()
	local lRet := .t.
	//Situacao de cobranca diferente de Carteira e motivo de baixa nao movimenta banco
	If !(FN022SITCB(SE1->E1_SITUACA)[1]) .and. !MovBcoBx(cMotBx, .T.)
		lRet := .F.
	EndIf

	If ! lRet
		Help(" ",1,"FA070MOTIN")
	Endif
return lRet
