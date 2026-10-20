#include 'totvs.ch'
/*/{Protheus.doc} FA750BRW
PE para adicionar opcoes na rotina do contas a pagar
@type function
@version 12.1.33
@author Tiago Faria
@since 06/01/2022
@return array, Retorna array com as novas opções do menu
/*/
user function FA750BRW()
	local aRotina := {}

	aAdd( aRotina , { "#Imp. GNRE", "u_impGNRE()", 0, 0, 0, NIL })
return aRotina
