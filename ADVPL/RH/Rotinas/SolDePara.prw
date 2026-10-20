#INCLUDE "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} SolDePara

Cadastro De-Para Integração RH

@author Solon Thomas
@since 28/07/2021
@version 
/*/
//-------------------------------------------------------------------
User Function SolDePara()

    dbSelectArea("ZUV")
    dbSetOrder(1)

    AxCadastro("ZUV","Cadastro De-Para Integração RH",".T.",".T.")

Return
