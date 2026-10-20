#include 'totvs.ch'
#include 'topconn.ch'

user function tstLibCredito()
	RpcSetEnv("01","0101")

	if posicione("SC5",1,xFilial("SC5")+"050935","!EOf()") .and.;
			posicione("SF2",1,xFilial("SF2")+"0000875341  ","!EOf()")
		u_estornaLibCredito()
	endif
	RpcClearEnv()
return

/*/{Protheus.doc} estornaLibCredito
Função chamada do PE M460FIM responsável por estornar a liberação dos pedidos caso ocorra um faturamneto parcial
@type function
@version  1.0
@author Tiago Faria
@since 01/07/2021
/*/
user function estornaLibCredito()
	local cAlias       := ""
	local nUltRecnoC5  := ""
	local bRecnoC5     :={||(cAlias)->(C5RECNO)}
	local nQtdLib	   := 0
	local lHabilitado  := getNewPar("ZZ_HESTCE",.t.)
	private cFormasPGT := getNewPar("ZZ_FORPGT","DEP,DIH,ANT,CHQ")

	if !lHabilitado
		return
	endif

	cAlias := getQuery()
	while (cALias)->(!Eof())
		SC6->(dbGoTo((cAlias)->(C6RECNO)))
		SC9->(dbGoTo((cAlias)->(C9RECNO)))
		SC5->(dbGoTo((cAlias)->(C5RECNO)))
		nUltRecnoC5 := eval(bRecnoC5)
		nQtdLib := SC9->C9_QTDLIB
		SC9->(a460estorna())
		liberaPedido(nQtdLib)

		(cAlias)->(dbSkip())

		if nUltRecnoC5 <> eval(bRecnoC5) .or. (cAlias)->(eof())
			RecLock("SC5")
			SC5->C5_LIBEROK := if(isLiberOK(SC5->C5_NUM),"S","")
			//if SC5->(fieldPos("C5_ZZOBSLI")) > 0
				SC5->C5_ZZOBSLI := replicate("-",30) + CRLF  + "ESTORNO DAS LIBERAÇÕES DE CRÉDITO/ESTOQUE DO PEDIDO REALIZADO AUTOMÁTICAMENTE EM " + dtoc(date()) + " AS " + time() + " POR " + alltrim(USRFULLNAME()) + " PELA NF: " + SF2->(F2_DOC + "/" + F2_SERIE) + CRLF + SC5->C5_ZZOBSLI
			//endif
			SC5->(MsUnlock())
		endif
	enddo

	(cAlias)->(dbCloseArea())
return

static function liberaPedido(nQtdLib)
	local lTransf:= .f.
	local lLiber := .f.

	lTrans := .f.
	lLiber := .f.
	MaLibDoFat(SC6->(RecNo()),@nQtdLib,.F./*lCredito*/,.F./*lEstoque*/,.f./*lAvCred*/,.f./*lAvEst*/,lLiber,lTransf)
return nQtdLib <= SC6->(C6_QTDVEN - C6_QTDENT)

/*
Realiza query para avaliar se há pedidos sendo faturados parcialmente
*/
static function getQuery()
	local cQuery 	:= ""
	local cAlias 	:= ""

	cQuery += "SELECT" + CRLF
	cQuery += "	SC9.R_E_C_N_O_ AS C9RECNO," + CRLF
	cQuery += "	SC5.R_E_C_N_O_ AS C5RECNO," + CRLF
	cQuery += "	SC6.R_E_C_N_O_ AS C6RECNO" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SD2") + CRLF

	cQuery += "INNER JOIN " + CRLF
	cQuery += "	" + retSqlTab("SC5") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND C5_FILIAL = D2_FILIAL" + CRLF
	cQuery += "	AND C5_NUM = D2_PEDIDO" + CRLF
	cQuery += "	AND C5_FORPGT IN " + formatIn(cFormasPGT,",") + CRLF
	cQuery += "	AND " + retSqlDel("SC5") + CRLF

	cQuery += "INNER JOIN " + CRLF
	cQuery += "	" + retSqlTab("SC6") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND C6_FILIAL = D2_FILIAL" + CRLF
	cQuery += "	AND C6_NUM = D2_PEDIDO" + CRLF
	cQuery += "	AND " + retSqlDel("SC6") + CRLF

	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("SC9") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SC9") + CRLF
	cQuery += "	AND C9_PEDIDO = C6_NUM" + CRLF
	cQuery += "	AND C9_ITEM = C6_ITEM" + CRLF
	cQuery += "	AND C9_NFISCAL = ' '" + CRLF
	cQuery += "	AND C9_SERIENF = ' '" + CRLF
	cQuery += "	AND " + retSqlDel("SC9") + CRLF

	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SD2") + CRLF
	cQuery += "	AND D2_DOC = '" + SF2->F2_DOC  + "'" + CRLF
	cQuery += "	AND D2_SERIE = '" + SF2->F2_SERIE  + "'" + CRLF
	cQuery += "	AND " + retSqlDel("SD2") + CRLF

	cQuery += "GROUP BY" + CRLF
	cQuery += "	SC9.R_E_C_N_O_," + CRLF
	cQuery += "	SC5.R_E_C_N_O_," + CRLF
	cQuery += "	SC6.R_E_C_N_O_" + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())
return cAlias

static function isLiberOK(cPedido)
	local cQuery := ""
	local cAlias := ""
	local aArea  := Lj7GetArea({"SC5","SC6","SC9"})

	cQuery += "SELECT" + CRLF
	cQuery += "	COUNT(C6_NUM) AS QTD_PEDIDO" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + retSqlTab("SC6") + CRLF
	cQuery += "OUTER APPLY" + CRLF
	cQuery += "(" + CRLF
	cQuery += "	SELECT" + CRLF
	cQuery += "		C9_FILIAL," + CRLF
	cQuery += "		C9_PEDIDO," + CRLF
	cQuery += "		C9_ITEM," + CRLF
	cQuery += "		SUM(C9_QTDLIB) AS C9_QTDLIB" + CRLF
	cQuery += "	FROM" + CRLF
	cQuery += "		" + retSqlTab("SC9") + CRLF
	cQuery += "	WHERE 1=1" + CRLF
	cQuery += "		AND C9_FILIAL = C6_FILIAL" + CRLF
	cQuery += "		AND C9_PEDIDO = C6_NUM" + CRLF
	cQuery += "		AND C9_ITEM = C6_ITEM" + CRLF
	cQuery += "		AND " + retSqlDel("SC9") + CRLF
	cQuery += "	GROUP BY" + CRLF
	cQuery += "		C9_FILIAL," + CRLF
	cQuery += "		C9_PEDIDO," + CRLF
	cQuery += "		C9_ITEM" + CRLF
	cQuery += ") SC9" + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SC6") + CRLF
	cQuery += "	AND C6_NUM = '" + cPedido + "'" + CRLF
	cQuery += "	AND C6_QTDVEN <> COALESCE(C9_QTDLIB,0)" + CRLF
	cQuery += "	AND " + retSqlDel("SC6") + CRLF

	TcQuery cQuery new ALias (cAlias := getNextALias())

	lRet := (cALias)->(QTD_PEDIDO) > 0

	(cAlias)->(dbCloseArea())

	Lj7RestArea(aArea)
return lRet
