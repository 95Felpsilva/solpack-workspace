#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT410CPY
Ponto de entrada na copia de um pedido
@author Tiago Faria
@since 15/07/2021
@version undefined

@type function
/*/
user function MT410CPY()

	M->C5_ZZOBSLI := criavar("C5_ZZOBSLI",.f.)
return
