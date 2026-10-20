#Include "RwMake.ch"

/*/{Protheus.doc} MT140CPO
    Ponto de Entrada responsável pela adição de campos na tela da pré-nota NF-e (MATA140)

    Para a NFLegal, fazemos a inclusão do campo D1_IDENTB6, para quando houver amarração com nota de beneficiamento,
    assim sendo possível lançar a pré-nota já com este vínculo.

@type function
@version 1.0
@author Marcos Bortoluci
@since  21/08/2024
@return array, Array com os campos adicionais da MATA140
/*/
User Function MT140CPO()
    Local aCpos := {"D1_IDENTB6"}
return(aCpos)
