#INCLUDE "totvs.ch"

/*/{Protheus.doc} User Function SACI008
    PE após a rotina de baixas a receber
    @type  Function
    @author user
    @since 25/11/2021
    @version 12.1.33
    /*/
User Function SACI008()
    If ExistBlock("BolAntecip")
        oBol := BolAntecip():new()
        oBol:atualizaStatus()
    endif
Return 
