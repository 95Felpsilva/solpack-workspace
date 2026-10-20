#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} FISTRFNFE
Inclusão de botões
@author Tiago Faria
@since 25/05/2021
@version 1.0
@type function
/*/
user function FISTRFNFE()
	if getNewPar("ZZ_ETQNFAT",.T.)
		aadd(aRotina ,{'# Impressão Etiqueta NF' ,'u_ReImpNFEtq(.t.)' ,0 ,4 ,0 ,nil})
	endif
	aadd(aRotina ,{'# Atualiza Status PIN' ,'u_UpdStatusPIN()' ,0 ,4 ,0 ,nil})
	aadd(aRotina ,{'# Legenda Status PIN' ,'u_LegStatusPIN()' ,0 ,4 ,0 ,nil})
return
