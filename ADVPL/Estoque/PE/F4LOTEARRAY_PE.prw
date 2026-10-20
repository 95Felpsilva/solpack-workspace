#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc}	F4LOTEARRAY
O Ponto de Entrada F4LoteArray permite manipular as 
informações a serem exibidas na consulta F4Lote para seleção do lote.

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					15/06/2015
@return				aRetorno
/*/
User Function F4LOTEARRAY()
	
	Local aAreaSB8		:= SB8->(GetArea())
	Local aRetorno		:= PARAMIXB[05]
	Local nSldLote		:= 0
	Local nQtdLote		:= 0
	Local cObs				:= ""
	Local cLocal			:= ""
	
	If FunName() == "MATA410"
		cLocal := GDFieldGet("C6_LOCAL",n)
	EndIf
	
	SB8->(DbSetOrder(3)) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
	If SB8->(DbSeek(xFilial("SB8") + aRetorno[02] + cLocal + aRetorno[01]))
		cObs 		:= SB8->B8_ZZOBS
		nQtdLote	:= SB8->B8_SALDO
	EndIf
	
	//Julio Lisboa - 18/08/2015
	nSldLote := buscaSldLote(aRetorno[02],cLocal,aRetorno[01])
	nSldLote := (nQtdLote - nSldLote)
	
	Aadd(aRetorno,cObs)
	Aadd(aRetorno,nSldLote)
	
	RestArea(aAreaSB8)
	
Return (aRetorno)

/*/{Protheus.doc}	buscaSldLote
Busca o saldo do lote

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					18/08/2015
@return				nRet
/*/
Static Function buscaSldLote(cProd,cArmazem,cLote)
	
	Local nRet		:= 0
	Local cQuery	:= ""
	Local cAlias	:= GetNextAlias()
	
	cQuery := "SELECT" + CRLF
	cQuery += "	SUM(C6_QTDVEN - C6_QTDENT) AS QUANT" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + RetSqlName("SC6") + " AS SC6" + CRLF
	cQuery += "WHERE" + CRLF
	cQuery += "	C6_FILIAL = '" + xFilial("SC6") + "' AND" + CRLF
	cQuery += "	C6_PRODUTO = '" + cProd + "' AND" + CRLF
	cQuery += "	C6_LOCAL = '" + cArmazem + "' AND" + CRLF
	cQuery += "	C6_LOTECTL = '" + cLote + "' AND" + CRLF
	cQuery += "	(C6_QTDVEN - C6_QTDENT) > 0 AND" + CRLF
	cQuery += "	SC6.D_E_L_E_T_ = ' '" + CRLF
	
	TcQuery cQuery New Alias &cAlias
	
	If (cAlias)->(!Eof())
		nRet := (cAlias)->QUANT
	EndIf
	
	(cAlias)->(DbCloseArea())
	
Return (nRet)
