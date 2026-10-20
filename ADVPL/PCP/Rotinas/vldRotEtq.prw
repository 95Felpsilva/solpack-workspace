#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} ENAPCP25
Funcao chamada da validacao de usuario do campo G2_ZZIMPET
Utilizado para avaliar se há outras operações flegadas como SIM no cadastro
@author Tiago Faria
@since 14/05/2019
@version undefined

@type function
/*/
user function vldRotEtq()
	local oModel	:= FwModelActive()
	local oGrid		:= oModel:GetModel('PCPA124_SG2')
	local nLine		:= 0
	local aLines	:= FWSaveRows()
	local nLineAtu	:= oGrid:getLine()
	local lValid	:= fwFldGet("G2_ZZIMPET") == "S"
	local lRet		:= .t.

	if lValid
		For nLine := 1 To oGrid:Length()
			if nLine <> nLineAtu
				oGrid:GoLine( nLine )
				if oGrid:getValue("G2_ZZIMPET") == "S"
					lRet := .f.
					Help(NIL, NIL, "vldRotEtq", NIL, "Há mais de uma operação com o campo " + alltrim(getSX3Cache("G2_ZZIMPET","X3_TITULO")) + " igual a SIM", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Altere o conteudo desta operação para NAO, ou modifique as demais operações para NAO e deixe esta como SIM"})
					exit
				endif
			endif
		Next nLine
	endif
	FWRestRows( aLines )
return lRet
