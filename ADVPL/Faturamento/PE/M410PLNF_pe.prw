#include 'totvs.ch'
/*/{Protheus.doc} M410PLNF
PE após os calculos de impostos da planilha financeira
@type function
@version 12.1.33
@author Tiago Faria
@since 17/11/2021
/*/
user function M410PLNF()
	If ExistBlock("BolAntecipDel")
        setThreadValue("ZZNF_BASEDUP",MAFISRET(,"NF_BASEDUP"))
	endif
return
