#include 'totvs.ch'
/*/{Protheus.doc} GNREDePara
Atribui na variavel de memoria da tabela SF6 os campos da tabela SZ6
@type function
@version 12.1.33
@author Tiago Faria
@since 10/11/2021
@return logical, Retorna sempre .t.
/*/
user function GNREDePara(lReclock)
	local lRet      := .t.
	local nQtyField := SF6->(fCount())
	local nField    := 0
	local cField    := ""
	local cFieldSZ6 := ""
	local aArea     := Lj7GetArea({"SZ6", "SF6"})
	local cAlias    := ""
	default lReclock := .f.

	if lReclock
		cAlias := "SF6"
	else
		cAlias := "M"
	endif

	if Posicione("SZ6",1,xFilial("SZ6")+&(cAlias+"->F6_EST"),"!Eof()")
		if lReclock
			recLock("SF6",.f.)
		endif
		for nField := 1 to nQtyField
			cField     := SF6->(fieldName(nField))
			cFieldSZ6  := strTran(cField,"F6_","Z6_")

			if type(cAlias+"->" + cField) <> "U" .and. SZ6->(fieldPos(cFieldSZ6) > 0)
				&(cAlias+"->" + cField) := SZ6->(&(cFieldSZ6))
			endif
		next nField

		if lReclock
			SF6->(msUnlock())
		endif
	endif
	Lj7RestArea(aArea)
return lRet
