#Include "Protheus.ch"

/*/{Protheus.doc} gravaEtique
Rotina que gera as etiquetas

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			21/07/2015
@return 		nil
/*/
User Function GravaEtique(cTipo,cProduto,cOP,nQtde,nQtdEmb,cLocal,cEndereco,cLote,dDtValid,nRecno,nContaEtiq)
	
	Local aAreaCB0		:= CB0->(GetArea())
	Local nJ				:= 0
	Local nQtdeEtiq		:= 0
	Local nTotalEtiq		:= 0
	Local nResto			:= 0
	Local cCodEtiq		:= ""
	
	Default cTipo			:= ""
	Default cProduto		:= ""
	Default cOP			:= ""
	Default nQtde			:= 0
	Default nQtdEmb		:= 0
	Default nContaEtiq	:= 0
	
	If Empty(cProduto) .AND. nQtde <= 0
		return
	EndIf
	
	//Se for 0 ou 1, gerar uma etiqueta apenas com a quantidade cheia
	If nQtdEmb == 0
		nTotalEtiq		:= 1
		nQtdeEtiq 		:= nQtde
	Else
		nTotalEtiq		:= Ceiling(nQtde / nQtdEmb)
		nQtdeEtiq 		:= IIF(nQtde < nQtdEmb,nQtde,nQtdEmb)
		nResto			:= Mod(nQtde,nQtdEmb)
	EndIf
	
	For nJ := 1 To nTotalEtiq
		
		If nJ > 1 .AND. nJ == nTotalEtiq
			If nResto > 0
				nQtdeEtiq := nResto
			EndIf
		EndIf
		
		cCodEtiq := CBGrvEti(cTipo  ,;	// 01 - Tipo Etiqueta
		{cProduto						,;	// 02 - Produto
		nQtdeEtiq 		            	,;	// 03 - Quantidade
		Nil			                 	,;	// 04 - Operador
		NIL				   				,;	// 05 - Nota Entrada
		NIL				   				,;	// 06 - Serie
		NIL				  				,;	// 07 - Fornecedor
		NIL				  				,;	// 08 - Loja
		NIL				  				,;	// 09 - Pedido
		cEndereco		   				,;	// 10 - Endereco
		cLocal			   				,;	// 11 - Local
		cOP				   				,;	// 12 - Ordem de Producao
		cNumSeq  	   					,;	// 13 - Numero Sequencial
		NIL				   				,;	// 14 - Nota Saida
		NIL         	   				,;	// 15 - Serie
		NIL				   				,;	// 16 - Etiqueta 2
		cLote       	   				,;	// 17 - Lote
		NIL	   		   					,;	// 18 - Sub-Lote
		dDtValid        				,;	// 19 - Dt. Validade Lote
		NIL				   				,;	// 20 - Centro Custo
		NIL				   				,;	// 21 - Local Orig.
		NIL				   				,;	// 22 - Reservado
		NIL				   				,;	// 23 - Ordem Requisitante
		NIL         	   				,;	// 24 - Numero Serie
		"SD3"			   				})	// 25 - Origem
		
		CB0->(DbSetOrder(1))
		If CB0->(DbSeek(xFilial("CB0") + cCodEtiq))
			RecLock("CB0",.F.)
			CB0->CB0_ZZREC := nRecno
			CB0->(MsUnlock())
		EndIf
		
		nContaEtiq++
		
	Next
	
	RestArea(aAreaCB0)
	
Return
