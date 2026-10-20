#include "totvs.ch"

/*/{Protheus.doc} SD3250R

Ponto de entrada após encerramento da ordem de produção

@type function
@version P12
@author Gabriel Pereira - CRM Services
@since 29/04/2024
/*/
User Function SD3250R()
    
    If FindFunction("u_PCP01EncerraProgramacao")
        u_PCP01EncerraProgramacao(SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN)
    EndIf

Return
