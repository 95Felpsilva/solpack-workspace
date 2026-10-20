#include "Protheus.ch"
#include "Topconn.ch"  
#include "rwmake.ch"  

/*/{Protheus.doc} SOFAT002
	Função utilizada na validação de usuário.
	Rotina: Pedido de Vendas.
	Campo: CK_QTDVEN (quantidade).
	Finalidade: valida se a quantidade informada é múltipla de vendas. Emite um alerta para o usuário confirmar (sim ou não).
	@author Cristiano  Ajustes Bete - Equipe Interna
	@since 09/05/2016
	@version 1.0
	@return lRet, logico, se .T. a quantidade informada é multipla de vendas, se .F. a quantidade nao é multipla de vendas.
/*/

User Function SOFAT002()

      
	Local cCod    := GdFieldPos("CK_PRODUTO")
   // Local cCodigo := aCols[n,cCod]        
    Local cCodigo := SB1->B1_COD
 	Local nQtdven := M->CK_QTDVEN
	Local nValor  := 0
	Local lRet    := .T.

	if select("S02") > 0
		S02->(dbCloseArea())
	endif

	cQuery :="SELECT CASE WHEN B1_QE = 0 THEN 1 ELSE B1_QE END AS QE "
	cQuery +="FROM "+RetSqlName("SB1")+" SB1 "
	cQuery +="WHERE SB1.D_E_L_E_T_ !='*' "
   	cQuery += "AND B1_COD = '"+ cCodigo + "' "          
 	cQuery += "AND B1_FILIAL = '"+xFilial("SB1")+"' "

	TcQuery cQuery ALIAS "S02" NEW

	nQtdmul := (S02->QE)

	If nQtdmul > 0
		nValor  := Mod(nQtdven,nQtdmul)
		If nValor > 0 
			lRet := .T.
			MsgAlert("A quantidade informada não é múltiplo de venda. O múltiplo de vendas do produto " + cCodigo + " é " + alltrim(STR(nQtdMul)) + ".")
				If !MsgYesNo("Deseja confirmar a quantidade digitada no pedido de vendas?","Confirma")
          			Return .F.
     			EndIf
		Else
			lRet := .T.
		Endif
	Else
		lRet := .T.
	EndIf
 Return(lRet)