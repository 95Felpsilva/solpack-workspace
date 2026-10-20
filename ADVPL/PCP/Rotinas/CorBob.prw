#include 'totvs.ch'
/*/{Protheus.doc} CorBob
Função chamada do combobox H6_ZZCOR
@type function
@version 12.1.27
@author Tiago Faria
@since 13/09/2021
@return character, Retorna as opções em string
/*/
user function CorBob()
	local cRet   := ""
	local aCores := {}
    local nCor   := 0

	aAdd(aCores,"10=LARANJA")
	aAdd(aCores,"28=VERDE LIMÃO")
	aAdd(aCores,"25=VERDE MILHO")
	aAdd(aCores,"BR=BRANCA")
	aAdd(aCores,"60=ROXO")
	aAdd(aCores,"42=VERMELHO")
	aAdd(aCores,"11=CANARIO")
	aAdd(aCores,"40=CEBOLA")
	aAdd(aCores,"41=ALHO")
	aAdd(aCores,"80=BATATA JUTA")
	aAdd(aCores,"27=REPOLHO")
	aAdd(aCores,"22=CABOTIA")
	aAdd(aCores,"24=VAGEM")
	aAdd(aCores,"23=REPOLHO")
	aAdd(aCores,"12=MELÃO")
	aAdd(aCores,"13=DOURADA")
	aAdd(aCores,"50=TRANSPARENTE")
	aAdd(aCores,"PR=PRETO")

    nQtdCor := len(aCores)

    for nCor := 1 to nQtdCor
        cRet += aCores[nCor]

        if nCor < nQtdCor
            cRet += ";"
        endif
    next nCor
return cRet
