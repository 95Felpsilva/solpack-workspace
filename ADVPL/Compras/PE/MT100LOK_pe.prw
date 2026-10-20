#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT100LOK
Ponto de entrada validação de linha documento de entrada.
@author Tiago Faria
@since 04/07/2018
@version undefined

@type function
/*/
user function MT100LOK()
	local lRet := .t.
	if existBlock("ENACOM01")
		lRet := ExecBlock("ENACOM01",.f.,.f.)
	endif

return lRet
