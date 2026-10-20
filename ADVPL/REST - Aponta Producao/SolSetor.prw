#INCLUDE "Protheus.ch"

/*/{Protheus.doc} SolSetor

Rotina para realizar manutenção no cadastro de setor

@type function
@author Gabriel Pereira - CRM Services
@since 08/12/2022

/*/
User Function SolSetor()

    dbSelectArea("ZZ6")
    dbSetOrder(1)

    AxCadastro("ZZ6","Cadastro de Setor",".T.",".T.")

Return
