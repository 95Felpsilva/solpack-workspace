#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} MA650BUT
Adiciona itens no menu principal do fonte MATA650
@author Tiago Faria
@since 17/07/2019
@version undefined

@type function
/*/
user function MA650BUT()
	local aRotina := PARAMIXB

	AADD(aRotina,{"# Rel. Acompanhamento Producao"	,"u_RELACOMPPROD()"	,0,6})
	AADD(aRotina,{"# Imprime OP"					,"u_ImpOP()"		,0,6})
	AADD(aRotina,{"# Reabrir OP"					,"u_ReabrirOP()"	,0,6})
return aRotina
