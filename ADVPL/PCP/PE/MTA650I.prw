#include "totvs.ch"

/*/{Protheus.doc} MTA650I

Ponto de entrada após inclusão da ordem de produção

@type function
@version P12
@author Gabriel Pereira - CRM Services
@since 29/04/2024
/*/
User Function MTA650I()
    
    If FindFunction("u_PCP01GeraProgramacao") .And. INCLUI
        u_PCP01GeraProgramacao(SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN)
    EndIf

Return
