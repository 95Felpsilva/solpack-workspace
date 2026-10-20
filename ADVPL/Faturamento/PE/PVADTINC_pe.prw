#include 'totvs.ch'

#Define PGTO_ANT_ENV_BOLETO "3"
#Define PGTO_ANT_TIT_REGISTRADO_EM_BANCO "4"
#Define PGTO_ANT_TITULO_BAIXADO "5"

/*/{Protheus.doc} PVADTINC
PE para bloquear a inclusão de adiantamento
@type function
@version 12.1.33
@author Tiago Faria
@since 24/11/2021
@return logical, Se true bloquea a tela de adiantamento se false não bloquea
/*/
user function PVADTINC()
return getNewPar("ZZ_BAADTIN",.t.)
