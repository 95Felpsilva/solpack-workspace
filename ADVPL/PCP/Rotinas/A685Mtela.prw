#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} A685Mtela
Monta a tela de Explosão do 1º nível da estrutura
na rotina Apotamento de Perda.  
Clone da Função padrão A685MTELA() pois não havia PE para incluir o campo com a quantidade da 2º UM
@author Tiago Faria
@since 17/07/2019
@version 1.0
@return nil

@type function
/*/
user Function A685Mtela()
	Local oDlg         
	Local oOp
	Local oProduto
	Local oQtde    
	Local oQtde2UM   
	Local lOk       	:= .F.
	Local aArrayAux		:= {}
	Local nX       		:= 0
	Local nAcuSDC		:= 0
	Private nQtdeSBC	:= 0 
	Private nQtde2SBC	:= 0

	DEFINE MSDIALOG oDlg FROM 140,000 TO 340,340 TITLE "Explosão do 1º nível da estrutura" PIXEL //"Explosão do 1º nível da estrutura"
	@ 0.9,01 SAY "Ordem de Produção" SIZE 15,10 OF oDlg //"Ordem de Produção"
	@ 2.1,01 SAY "Produto" SIZE 10,10 OF oDlg //"Produto"
	@ 3.3,01 SAY "Qtde. Perd 2ª U.M." SIZE 5,10  OF oDlg //"Qtde. Perd"
	@ 4.3,01 SAY "Qtde. Perd" SIZE 5,10  OF oDlg //"Qtde. Perd"
	@ 10,60 MSGET oOp VAR cOrdemP Picture PesqPict("SBC","BC_OP") When .F. Valid (NaoVazio(cOrdemP)) SIZE 100,9 OF oDlg PIXEL
	@ 25,60 MSGET oProduto VAR cProduto Picture PesqPict("SBC","BC_PRODUTO") When .F. Valid (NaoVazio(cProduto)) SIZE 100,9 OF oDlg PIXEL
	@ 40,60 MSGET oQtde2UM VAR nQtde2SBC Picture PesqPict("SC2","C2_QUANT")Valid vldSegUM() SIZE 100,9 OF oDlg PIXEL
	@ 55,60 MSGET oQtde VAR nQtdeSBC Picture PesqPict("SC2","C2_QUANT") When .F. Valid !(Empty(cOrdemP)) .And. (Positivo(nQtdeSBC)) .And. (NaoVazio(nQtdeSBC)) SIZE 100,9 OF oDlg PIXEL
	DEFINE SBUTTON FROM 70,63 TYPE 1 ACTION (lOK := .T.,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 70,90 TYPE 2 ACTION (lOk := .F.,oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED	                       

	//Apos a confirmacao da explosao, calcula e preenche os campos BC_PRODUTO, BC_LOCORIG, BC_QUANT.

	If lOK 
		SD4->(DbSetOrder(2))
		SD4->(DbSeek(xFilial("SD4")+cOrdemP))
		SDC->(DbSetOrder(2))

		While !SD4->(Eof()) .And. SD4->(D4_FILIAL+D4_OP) == xFilial("SD4")+cOrdemP
			If SD4->D4_QTDEORI < 0
				SD4->(DbSkip())
				Loop
			EndIf	

			nAcuSDC := (SD4->D4_QTDEORI / SC2->C2_QUANT) * nQtdeSBC
			aArrayAux := {}

			SDC->(DbSeek(xFilial("SDC")+SD4->D4_COD+SD4->D4_LOCAL+cOrdemP+SD4->(D4_TRT+D4_LOTECTL+D4_NUMLOTE)))
			While !SDC->(Eof()) .And. SDC->(DC_FILIAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE) == xFilial("SDC")+cOrdemP+SD4->(D4_TRT+D4_LOTECTL+D4_NUMLOTE)
				For nX := 1 to Len(aHeader)
					Do case
						Case nX == GdFieldPos("BC_PRODUTO")
						AAdd(aArrayAux,SDC->DC_PRODUTO)
						Case nX == GdFieldPos("BC_LOCORIG")
						AAdd(aArrayAux,SDC->DC_LOCAL)
						Case nX == GdFieldPos("BC_QUANT")
						AAdd(aArrayAux,(SDC->DC_QTDORIG / SC2->C2_QUANT) * nQtdeSBC)
						Case nX == GdFieldPos("BC_LOTECTL")
						AAdd(aArrayAux,SDC->DC_LOTECTL)
						Case nX == GdFieldPos("BC_NUMLOTE")
						AAdd(aArrayAux,SDC->DC_NUMLOTE)
						Case nX == GdFieldPos("BC_LOCALIZ")
						AAdd(aArrayAux,SDC->DC_LOCALIZ)
						Case nX == GdFieldPos("BC_NUMSERI")
						AAdd(aArrayAux,SDC->DC_NUMSERI)
						Case nX == (Len(aHeader)-1)
						AAdd(aArrayAux,"SBC")
						Case nX == (Len(aHeader))
						AAdd(aArrayAux,0)
						Case nX == GdFieldPos("BC_DATA")
						AAdd(aArrayAux,dDataBase)
						Otherwise
						AAdd(aArrayAux,CriaVar(Alltrim(aHeader[nX,2]),.F.))
					EndCase 
				Next nX            
				nAcuSDC -= (SDC->DC_QTDORIG / SC2->C2_QUANT) * nQtdeSBC
				AAdd(aArrayAux,.F.)
				// Se a primeira linha esta em branco remove a mesma do acols
				If Empty(aTail(aCols)[GDFieldPos("BC_PRODUTO")])
					aDel(aCols,Len(aCols))
					aSize(aCols,Len(aCols)-1)
				EndIf
				AAdd(aCols,aArrayAux)
				aArrayAux := {}
				SDC->(DbSkip()) 
			End

			If nAcuSDC > 0 	
				For nX := 1 to Len(aHeader)
					Do case
						Case nX == GdFieldPos("BC_PRODUTO")
						AAdd(aArrayAux,SD4->D4_COD)
						Case nX == GdFieldPos("BC_LOCORIG")
						AAdd(aArrayAux,SD4->D4_LOCAL)
						Case nX == GdFieldPos("BC_QUANT")
						AAdd(aArrayAux,nAcuSDC)
						Case nX == GdFieldPos("BC_LOTECTL")
						AAdd(aArrayAux,SD4->D4_LOTECTL)
						Case nX == GdFieldPos("BC_NUMLOTE")
						AAdd(aArrayAux,SD4->D4_NUMLOTE)	
						Case nX == (Len(aHeader)-1)
						AAdd(aArrayAux,"SBC")
						Case nX == (Len(aHeader))
						AAdd(aArrayAux,0)
						Case nX == GdFieldPos("BC_DATA")
						AAdd(aArrayAux,dDataBase)
						Otherwise
						AAdd(aArrayAux,CriaVar(Alltrim(aHeader[nX,2]),.F.))
					EndCase 
				Next nX              
				AAdd(aArrayAux,.F.)
				// Se a primeira linha esta em branco remove a mesma do acols
				If Empty(aTail(aCols)[GDFieldPos("BC_PRODUTO")])
					aDel(aCols,Len(aCols))
					aSize(aCols,Len(aCols)-1)
				EndIf
				AAdd(aCols,aArrayAux)
			EndIf 		

			//Validacao do gatilho
			If ExistTrigger("BC_QUANT")
				//RunTrigger(2,Len(aCols),,"BC_QUANT")
				RunTrigger(2,Len(aCols),NIL,,"BC_QUANT")
			EndIf
			SD4->(DbSkip()) 
		EndDo		                                               
	EndIf
Return

static function vldSegUM()
	local lRet := .t.
	
	if !(Empty(cOrdemP)) .And. (Positivo(nQtde2SBC)) .And. (NaoVazio(nQtde2SBC))
		nQtdeSBC := round(convUM(cProduto,nQtdeSBC,nQtde2SBC,1),getSX3Cache("BC_QTSEGUM","X3_DECIMAL"))
	else
		lRet := .f.
	endif
return lRet