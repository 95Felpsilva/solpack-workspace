#include 'totvs.ch'
/*/{Protheus.doc} IsClienteSuframa
Valida se o cliente esta habilitado para o Suframa
@type function
@version  12.1.27
@author Tiago Faria
@since 14/10/2021
@param cCliente, character, Codigo do cliente
@param cLoja, character, Codigo da loja
@return logical, Se true cliente habilitado se false cliente desabilitado
/*/
user function IsClienteSuframa(cCliente,cLoja)
    local aArea := Lj7GetArea({"SA1"})
    local lRet  := .t.
    if SA1->(A1_COD+A1_LOJA) <> cCliente+cLoja
        posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"!Eof()")
    endif

    lRet := !empty(SA1->A1_SUFRAMA) .and. SA1->A1_CALCSUF <> 'N'
    Lj7RestArea(aArea)
return lRet
