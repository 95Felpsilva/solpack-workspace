#include 'totvs.ch'
/*/{Protheus.doc} A682CPO
description
@type function
@version  
@author tiago
@since 08/02/2022
@return variant, return_description
/*/
user function A682CPO()
    local aFields    := PARAMIXB
    local aNewFields := {}
    local nField     := 0
    local cField     := ""

    for nField := 1 to len(aFields)
        cField := aFields[nField]

        if alltrim(cField)+"/" $ "H6_ZZMULTP/H6_ZQTPRO2/H6_ZZREVIS/H6_ZZLARG/H6_ZZCOR/H6_ZZMICRA/H6_ZQCORTE/H6_ZTRAMA/"
            loop
        endif

        aAdd(aNewFields,cField)
    next nField
return aNewFields
