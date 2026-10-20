#include 'totvs.ch'
/*/{Protheus.doc} UpdStatusPIN
Atualiza o status do PIN na NF
@type function
@version 12.1.27
@author Tiago Faria
@since 14/10/2021
/*/
user function UpdStatusPIN()
    local lGerouPIN := .t.
    local cStPIN    := ""

    if SF2->F2_ZZSTPIN == "BR_AZUL" .or. empty(SF2->F2_ZZSTPIN) .or. !u_IsClienteSuframa(SF2->F2_CLIENTE,SF2->F2_LOJA)
        msgAlert("Cliente da NF não está parametrizado para geração do Suframa!")
        return
    endif

    lGerouPIN := msgYesNo("SUFRAMA gerado para a NF" + SF2->(F2_DOC + "/" + F2_SERIE) + "?")
    if lGerouPIN
        cStPIN := "BR_VERDE"
    else
        cStPIN := "BR_VERMELHO"
    endif

    RecLock("SF2", .F.)
    SF2->F2_ZZSTPIN := cStPIN     
    SF2->(MsUnlock())
return
