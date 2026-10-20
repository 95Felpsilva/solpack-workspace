#INCLUDE "Protheus.ch"

/*/{Protheus.doc} CadZZ9

Rotina para realizar manutenção no cadastro de acessos do usuario

@type function
@author Gabriel Pereira - CRM Services
@since 18/11/2025

/*/
User Function CadZZ9()

    dbSelectArea("ZZ9")
    dbSetOrder(1)

    AxCadastro("ZZ9","Cadastro de Acessos do Usuario",".T.",".T.")

Return
