#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} A250SPRC
Substitui a função padrão no encerramento da OP
@author Tiago Faria
@since 18/10/2019
@version 1.0
@return lRet, logico, se true pode encerrar OP se false nao pode

@type function
/*/
user function A250SPRC()
	local cOP 		:= PARAMIXB[1]
	local dDtRef	:= PARAMIXB[2]
	local lRet		:= .t.
	
	lRet := u_vldPendenciaOP(cOP)
	
return lRet