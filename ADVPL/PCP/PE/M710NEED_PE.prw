#Include "Protheus.ch"

User Function M710NEED()
	
	Local cProduto 	:= PARAMIXB[01]	//Codigo do Produto
	Local nRet 		:= PARAMIXB[02]	//Valor da Necessidade Calculado pelo Sistema
	Local nMultiplo 	:= NoRound(Retfield("SB1",1,xFilial("SB1")+cProduto,"B1_LM"),0)
	Local nRazao		:= 0
	Local nNewRazao	:= 0
	
	If nMultiplo > 0
		nRazao := nRet / nMultiplo
		If nRazao - int(nRazao) <> 0
			nNewRazao	:= Ceiling(nRazao)
			nNewQuant	:= nNewRazao * nMultiplo
			nRet 		:= nNewQuant
		endif
	Else
		nNewQuant := nRet
	Endif
	
Return (nNewQuant)
