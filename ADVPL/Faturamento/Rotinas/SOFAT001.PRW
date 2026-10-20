#include "Protheus.ch"
#include "Topconn.ch"

/*/{Protheus.doc} SOFAT001
	Função utilizada na validação de usuário.
	Rotina: Pedido de Vendas.
	Campo: C6_QTDVEN (quantidade).
	Finalidade: valida se a quantidade informada é múltipla de vendas. Emite um alerta para o usuário confirmar (sim ou não).
	@type function
	@author Cristiano Pedroni 	
	@since 26/05/2015
	@version 1.0
	@return logical, se .T. a quantidade informada é multipla de vendas, se .F. a quantidade nao é multipla de vendas.
/*/
User Function SOFAT001(cCodigo,nQtdven)
	Local nValor  := 0
	Local lRet    := .T.
	local aArea   := Lj7GetArea({"SC6","SB1"})
	default cCodigo := gdFieldGet("C6_PRODUTO")
	default nQtdven := M->C6_QTDVEN

	cQuery :="SELECT CASE WHEN B1_QE = 0 THEN 1 ELSE B1_QE END AS QE "
	cQuery +="FROM "+RetSqlName("SB1")+" SB1 "
	cQuery +="WHERE SB1.D_E_L_E_T_ !='*' "
	cQuery += "AND B1_COD = '"+ cCodigo + "' "
	cQuery += "AND B1_FILIAL = '"+xFilial("SB1")+"' "

	TcQuery cQuery ALIAS "S01" NEW

	nQtdmul := (S01->QE)

	If nQtdmul > 0
		nValor  := Mod(nQtdven,nQtdmul)
		If nValor > 0 
			lRet := .T.
			MsgAlert("A quantidade informada não é múltiplo de venda. O múltiplo de vendas do produto " + cCodigo + " é " + alltrim(STR(nQtdMul)) + ".")
			lRet := MsgYesNo("Deseja confirmar a quantidade digitada no pedido de vendas?","Confirma")
		Else
			lRet := .T.
		Endif
	Else
		lRet := .T.
	EndIf

	S01->(dbCloseArea())
	Lj7RestArea(aArea)
 Return(lRet)
