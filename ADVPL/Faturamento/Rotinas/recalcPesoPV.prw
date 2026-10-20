#include 'totvs.ch'
/*/{Protheus.doc} calcPesoBruto
Calcula o peso bruto e liquido no pedido de vendas
@type function
@version 
@author Tiago Faria
@since 04/12/2020
@param nLin, numeric, param_description
@return nil
@see M4140LIOK
@see M410TOK
/*/
user function recalcPesoPV(nLin)
	local nLinhas 	:= len(aCols)
	local nLinha 	:= 0
	local cProduto 	:= ""
	local nPosPesoL	:= gdFieldPos("C6_ZZPESOL")
	local nPosPesoB	:= gdFieldPos("C6_ZZPESOB")
    default nLin    := 1
	for nLinha := nLin to nLinhas
		cProduto := aCols[nLinha,gdFieldPos("C6_PRODUTO")]
		nQtdVen	 := aCols[nLinha,gdFieldPos("C6_QTDVEN")]

		if posicione("SB1",1,xFilial("SB1")+cProduto,"!Eof()")
			nPesoBruto	:= SB1->B1_PESBRU * nQtdVen
			nPesoLiq 	:= SB1->B1_PESO * nQtdVen

			aCols[nLinha,nPosPesoL] := nPesoLiq
			aCols[nLinha,nPosPesoB] := nPesoBruto
		endif
	next nLinha
return
