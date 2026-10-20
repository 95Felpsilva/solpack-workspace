#include 'totvs.ch'

/*/{Protheus.doc} SetEntidade
Rotina responsavel pelo inicializador browser do campo [AOB_ZZENT].
@author Felipe Silva
@type user function
@since 13/08/2026
@version 12.1.2510
/*/
user function SetEntidade()
    local cRet := ""

    if AOB->AOB_ENTIDA == "ACH"
        cRet := "SUSPECT"
    elseif AOB->AOB_ENTIDA == "SUS"
        cRet := "PROSPECT"
    elseif AOB->AOB_ENTIDA == "SA1"
        cRet := "CLIENTE"
    endif
return cRet
