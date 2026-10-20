#Include "Protheus.ch"

/*/{Protheus.doc}	M410lDel
Ponto de Entrada que permite adicionar validações 
para o tratamento de exclusão de um item do PV.

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					27/07/2015
@return				lRet
/*/
User Function M410lDel()
	
	Local lRet			:= .T.
	Local aAreaSC6	:= SC6->(GetArea())
	
	Local nItem		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
	Local nProduto	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
	
	Local cPedido		:= SC6->C6_NUM
	Local cItem		:= aCols[n,nItem]
	Local cProduto	:= aCols[n,nProduto]
	
	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(xFilial("SC6") + cPedido + cItem + cProduto))
		If SC6->(FieldPos("C6_ZZUSRDE")) > 0
			RecLock("SC6",.F.)
			SC6->C6_ZZUSRDE := RetCodUsr()
			SC6->(MsUnlock())
		EndIf
	EndIf
	
	RestArea(aAreaSC6)
	
Return (lRet)
