#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc}	valImpEt
Rotina que valida se será impressa a etiqueta de Ordem de Produção

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					26/06/2015
@return				nil
/*/
User Function valImpEt(cCodBar,nQtdEti,lCabec,nTipo,nEtiq,nJ,cNomeUsuario)
	
	Local aAreaAtu		:= GetArea()
	Local aTemp			:= {}
	Local aDados			:= {}
	
	Private cProduto		:= ""
	Private cLoteCTL		:= ""
	Private cDescProd		:= ""
	Private cDataHora		:= ""
	Private cOperador		:= ""
	Private cRecurso		:= ""
	Private cOp			:= ""
	Private nQtdProd		:= 0
	Private nQtde			:= 0
	
	Default cCodBar		:= ""
	Default cNomeUsuario:= ""
	Default nQtdEti		:= 0
	Default lCabec		:= .T.
	Default nTipo			:= 0
	Default nEtiq			:= 0
	Default nJ				:= 0
	
	/*
	*	A variável 'nTipo' define o ponto em que a função é chamada,
	*	para ver de onde serão extraidos os dados para impressão
	*/
	
	If !trataDados(nTipo,nEtiq,nJ)
		return
	EndIf
	
	Aadd(aTemp,cCodBar)			//Codigo de Barras
	Aadd(aTemp,cProduto)			//Produto
	Aadd(aTemp,cLoteCTL)			//Lote
	Aadd(aTemp,cDescProd)		//Descrição Produto
	Aadd(aTemp,cDataHora)		//Data Apontamento
	If !Empty(cNomeUsuario)
		Aadd(aTemp,cNomeUsuario)		//Operador
	Else
		Aadd(aTemp,cOperador)		//Operador
	EndIf
	Aadd(aTemp,cRecurso)			//Recurso
	Aadd(aTemp,cOp)				//Ordem de Produção
	Aadd(aTemp,nQtdProd)			//Peso
	Aadd(aTemp,nQtde)				//Quant Etiqueta
	
	Aadd(aDados,aTemp)
	U_EtqOrPrd(lCabec,aDados,nQtdEti)
	
	aDados := {}
	aTemp 	:= {}
	
	RestArea(aAreaAtu)
	
Return

/*/{Protheus.doc}	trataDados
Trata os dados passados por parâmetro para buscar os dados da etiqueta

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					24/07/2015
@return				nil
/*/
Static Function trataDados(nTipo,nEtiq,nJ)
	
	Local lRet				:= .T.
	Local nDivisor		:= 0
	Local _nQtde			:= 0
	Local _nResto			:= 0
	
	Default nEtiq			:= 0
	Default nJ				:= 0
	
	If nTipo == 0
		return .f.
	
	// Após apontamento de produção
	ElseIf nTipo == 1

		cProduto	:= SH6->H6_PRODUTO
		cLoteCTL	:= SH6->H6_LOTECTL
		cDescProd	:= Posicione("SB1",1,xFilial("SB1") + SH6->H6_PRODUTO,"B1_DESC")
		cDataHora	:= DToC(SH6->H6_DATAFIN) + " - " + AllTrim(SH6->H6_HORAFIN)
		cOperador	:= UPPER(UsrRetName(RetCodUsr()))
		cRecurso	:= SH6->H6_RECURSO
		cOp			:= SH6->H6_OP
		nQtdProd	:= SH6->H6_QTDPROD
		nQtde		:= CB0->CB0_QTDE
	
	//Após apontamento que não irá gerar CB0
	ElseIf nTipo == 2
		
		nDivisor	:= Posicione("SB1",1,xFilial("SB1") + SH6->H6_PRODUTO,"B1_QE")
		
		If nDivisor == 0
			nDivisor := 1
		EndIf
		
		//Trata se for etiqueta unica
		If nEtiq == 1
			_nQtde := SH6->H6_QTDPROD
		Else
			//Se for mais etiquetas, imprime as quebras
			_nQtde := nDivisor
			_nResto := Mod(SH6->H6_QTDPROD,nDivisor)
			
			//Trata o resto
			If nJ == nEtiq .AND. _nResto > 0
				_nQtde := _nResto
			EndIf
		EndIf
		
		cProduto	:= SH6->H6_PRODUTO
		cLoteCTL	:= SH6->H6_LOTECTL
		cDescProd	:= Posicione("SB1",1,xFilial("SB1") + SH6->H6_PRODUTO,"B1_DESC")
		cDataHora	:= DToC(SH6->H6_DATAFIN) + " - " + AllTrim(SH6->H6_HORAFIN)
		cOperador	:= UPPER(UsrRetName(RetCodUsr()))
		cRecurso	:= SH6->H6_RECURSO
		cOp			:= SH6->H6_OP
		nQtdProd	:= _nQtde
		nQtde		:= _nQtde

	//Etiqueta com OP sem apontamento
	ElseIf nTipo == 3
		
		cProduto	:= SC2->C2_PRODUTO
		cLoteCTL	:= CB0->CB0_LOTE
		cDescProd	:= Posicione("SB1",1,xFilial("SB1") + SC2->C2_PRODUTO,"B1_DESC")
		cDataHora	:= DTOC(CB0->CB0_DTNASC)
		cOperador	:= UPPER(UsrRetName(RetCodUsr()))
		cRecurso	:= ""
		cOp			:= CB0->CB0_OP
		nQtdProd	:= CB0->CB0_QTDE
		nQtde		:= CB0->CB0_QTDE

	//Etiqueta sem ordem de produção
	ElseIf nTipo == 4
		
		cProduto	:= CB0->CB0_CODPRO
		cLoteCTL	:= CB0->CB0_LOTE
		cDescProd	:= Posicione("SB1",1,xFilial("SB1") + CB0->CB0_CODPRO,"B1_DESC")
		cDataHora	:= DTOC(CB0->CB0_DTNASC)
		cOperador	:= UPPER(UsrRetName(RetCodUsr()))
		cRecurso	:= ""
		cOp			:= CB0->CB0_OP
		nQtdProd	:= CB0->CB0_QTDE
		nQtde		:= CB0->CB0_QTDE
		
	EndIf
	
Return (lRet)
