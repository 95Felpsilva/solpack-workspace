#INCLUDE "Protheus.ch"

/*/{Protheus.doc} A250ETRAN
Ponto de Entrada apos a inclusão do apontamento de produção

@type function
@version P12
@author Gabriel Pereira - CRM Services
@since 29/04/2024
/*/
User Function A250ETRAN()

    If FindFunction("u_PCP01AtualizaProgramacao")
        u_PCP01AtualizaProgramacao(SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN)
    EndIf
    
Return Nil
