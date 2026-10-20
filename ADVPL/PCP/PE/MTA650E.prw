#include "totvs.ch"

/*/{Protheus.doc} MTA650E

Ponto de entrada na exclusão da Ordem de produção

@type function
@author Gabriel Pereira Santos
@since 10/06/2024
@version P11,P12
@database MSSQL,Oracle

@return character, lRet - Indica se pode prosseguir com a exclusão

/*/
User Function MTA650E()
    Local lRet  := .T.
    
    If FindFunction("u_PCP01ExcluiProgramacao")
        u_PCP01ExcluiProgramacao(SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN)
    EndIf
    
Return lRet
