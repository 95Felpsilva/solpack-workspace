#include 'Totvs.ch'
#include 'TopConn.ch'
/*/{Protheus.doc} MT450COLS
PE responsável por incluir linhas na tela de Analise de Credito de pedido de vendas (MATA450)
@type function
@version  1.0
@author Tiago Faria
@since 20/01/2021
@return array, retorna array com as novas linhas a serem exibidas
/*/
user function MT450COLS()
	//local aHeader           := PARAMIXB[1]
	local aCols             := PARAMIXB[2]
	local cMaiorSaldo       := TRansform(Max(SA1->A1_MSALDO,SA1->A1_ZZPSALD),PesqPict("SA1","A1_MSALDO",17,1))
	local cSaldoaFaturar    := 0
	local cSaldoTitPg       := 0
	local cDataUltNF        := ""
	private nSaldoDisponivel:= 0

	posicione("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,"!EOF()")
	
	setValue("Pedidos Liberados",getPedidosLiberado(),@aCols)

	cSaldoaFaturar    := getSaldoAFaturar()
	cSaldoTitPg       := getSaldoTitVenc()
	cDataUltNF        := getDtUltNF()

	aAdd(aCols,{"Maior Saldo"     , cMaiorSaldo       ,cMaiorSaldo        ,"","",""})
	aAdd(aCols,{"Saldo à Faturar"   , cSaldoaFaturar    ,cSaldoaFaturar     ,"","",""})
	aAdd(aCols,{"Saldo Titulos Vencidos"   , cSaldoTitPg    ,cSaldoTitPg     ,"","",""})
	aAdd(aCols,{"Data Ultima NF"   , cDataUltNF    ,cDataUltNF     ,"","",""})

	nSaldoDisponivel := Max(SA1->A1_MSALDO,SA1->A1_ZZPSALD)
	nSaldoDisponivel -= getValue("Saldo à Faturar"          ,aCols)
	nSaldoDisponivel -= getValue("Pedidos Liberados"        ,aCols)
	nSaldoDisponivel -= getValue("Saldo Duplicatas"         ,aCols)
	nSaldoDisponivel -= getValue("Saldo Titulos Vencidos"   ,aCols)
	nSaldoDisponivel := TRansform(nSaldoDisponivel,PesqPict("SC6","C6_VALOR",17,1))

	aAdd(aCols,{"Forma de Pagamento"    , getFormaPgto()    ,getFormaPgto()     ,"","",""})
	aAdd(aCols,{"Crédito Disponivel"    , nSaldoDisponivel    ,nSaldoDisponivel     ,"","",""})

	aCols := orderCols(aCols)
	if len(aCols) >= 9
		aCols[9,5] := aCols[8,5]
		aCols[9,6] := aCols[8,6]

		aCols[8,5] := "Condicao de Pgto"
		aCols[8,6] := getDescCondPagto()
	endif

	setTitle("PEDIDOS LIBERADOS","Pedidos Lib. Crédito",@aCols)
return aCols

static function orderCols(aCols)
	local aNewCols  := cloneaCols(aCols)
	local aSeqCols  := {}
	local nSeq      := 0
	aAdd(aSeqCols,"MAIOR SALDO")
	aAdd(aSeqCols,"PEDIDOS LIBERADOS")
	aAdd(aSeqCols,"Saldo Duplicatas")
	aAdd(aSeqCols,"SALDO A FATURAR")
	aAdd(aSeqCols,"Saldo Titulos Vencidos")
	aAdd(aSeqCols,"Data Ultima NF")
	aAdd(aSeqCols,"Crédito Disponivel")
	aAdd(aSeqCols,"Forma de Pagamento")

	for nSeq := 1 to len(aSeqCols)
		cField := aSeqCols[nSeq]
		nPos := aScan(aCols,{ |X|upper(FwNoAccent(alltrim(X[1]))) == upper(FwNoAccent(alltrim(cField)))})
		//se nao achar algum campo da sequencia, mantém a sequencia padrão do Protheus com os campos personalizados no final
		if nPos > 0
			aNewCols[nSeq,1] := aCols[nPos,1]
			aNewCols[nSeq,2] := aCols[nPos,2]
			aNewCols[nSeq,3] := aCols[nPos,3]
		else
			aNewCols := aCols
			exit
		endif
	next nSeq
return aNewCols

static function cloneACols(aCols)
	local aNewCols  := {}
	local nLin      := 0
	local aLin      := {}
	local aColsClone := AClone(aCols)

	for nLin := 1 to len(aColsClone)
		aLin := aColsClone[nLin]

		aAdd(aNewCols,aLin)
		aNewCols[nLin][1] := ""
		aNewCols[nLin][2] := ""
		aNewCols[nLin][3] := ""
	next nLin
return aNewCols

static function getSaldoAFaturar()
	local cQuery := ""
	local cAlias := ""
	local cValor := ""
	local aArea := Lj7GetArea({"SC6"})

	cQuery += "SELECT " + CRLF
	cQuery += "	SUM((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN) AS A_FATURAR" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + retSqlTab("SC6") + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SC6") + CRLF
	cQuery += "	AND C6_NUM = '" + SC9->C9_PEDIDO + "'" + CRLF
	cQuery += "	AND C6_QTDVEN - C6_QTDENT > 0" + CRLF
	cQuery += "	AND " + retSqlDel("SC6") + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	cValor := TRansform((cAlias)->(A_FATURAR),PesqPict("SC6","C6_VALOR",17,1))
	nSaldoDisponivel -= (cAlias)->(A_FATURAR)
	(cAlias)->(dbCloseArea())
	Lj7RestArea(aArea)
return cValor


static function getSaldoTitVenc()
	local cQuery := ""
	local cAlias := ""
	local cValor := ""
	local aArea := Lj7GetArea({"SC6"})

	cQuery += "SELECT" + CRLF
	cQuery += "    SUM(E1_SALDO) AS SALDO" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + retSqlTab("SE1") + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SE1") + CRLF
	cQuery += "	AND E1_CLIENTE = '" + SC9->C9_CLIENTE + "'" + CRLF
	cQuery += "	AND E1_LOJA = '" + SC9->C9_LOJA + "'" + CRLF
	cQuery += "	AND E1_SALDO > 0" + CRLF
	cQuery += "	AND E1_TIPO NOT IN ('RA','NCC')" + CRLF
	cQuery += "	AND E1_VENCREA < '" + DTOS(DATE()) + "'" + CRLF
	cQuery += "	AND " + retSqlDel("SE1") + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	cValor := TRansform((cAlias)->(SALDO),PesqPict("SE1","E1_SALDO",17,1))
	nSaldoDisponivel -= (cAlias)->(SALDO)
	(cAlias)->(dbCloseArea())
	Lj7RestArea(aArea)
return cValor

static function getDtUltNF()
	local cQuery := ""
	local cAlias := ""
	local dData := stod("")
	local aArea := Lj7GetArea({"SF2"})
	cQuery += "SELECT " + CRLF
	cQuery += "    MAX(F2_EMISSAO) AS DT_ULT_NF" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "    " + retSqlTab("SF2") + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "    AND " + retSqlFil("SF2") + CRLF
	cQuery += "    AND F2_CLIENTE = '" + SC9->C9_CLIENTE + "' " + CRLF
	cQuery += "    AND F2_LOJA = '" + SC9->C9_LOJA + "' " + CRLF
	cQuery += "    AND " + retSqlDel("SF2") + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	dData := dtoc(stod((cAlias)->(DT_ULT_NF)))

	(cAlias)->(dbCloseArea())

	Lj7RestArea(aArea)
return dData

static function getValue(cField,aCols)
	local nPos := aScan(aCols,{ |X|upper(FwNoAccent(alltrim(X[1]))) == upper(FwNoAccent(alltrim(cField)))})
	local nRet := 0
	if nPos > 0
		nRet := aCols[nPos,2]
		nRet := strTran(nRet,".","")
		nRet := strTran(nRet,",",".")
		nRet := val(nRet)
	endif
return nRet

static function setValue(cField,xValue,aCols)
	local nPos := aScan(aCols,{ |X|upper(FwNoAccent(alltrim(X[1]))) == upper(FwNoAccent(alltrim(cField)))})
	local lRet := .f.

	if nPos > 0
		aCols[nPos,2] := xValue
		aCols[nPos,3] := xValue
		lRet := .t.
	endif
return lRet

static function setTitle(cTitle,cNewTitle,aCols)
	local nPos := aScan(aCols,{ |X|upper(FwNoAccent(alltrim(X[1]))) == upper(FwNoAccent(alltrim(cTitle)))})
	local lRet := .f.

	if nPos > 0
		aCols[nPos,1] := cNewTitle
		lRet := .t.
	endif
return lRet

static function getFormaPgto()
return getX3Box("C5_FORPGT",SC5->C5_FORPGT)

static function getDescCondPagto()
return SC5->(C5_CONDPAG + "-" + alltrim(C5_ZZDESCP))

static function getX3Box(cField,cContent)
	local cBox 			:= getSX3Cache(cField,"X3_CBOX")
	local nInitCBox		:= 0
	local nMaxLenCombo 	:= 0
	local aTmp			:= {}
	local cRet			:= ""
	
	if substr(cBox,1,1) == "#"
		cBox := &(substr(cBox,2))
	endif

	If !Empty(cBox)
		aTmp := RetSX3Box(cBox,@nInitCBox,@nMaxLenCombo,getSX3Cache(cField,"X3_TAMANHO"))
		nPos := aScan(aTmp,{|X|upper(alltrim(X[2])) == upper(alltrim(cContent))})

		if nPos > 0
			cRet := alltrim(aTmp[nPos][1])
			aRet := strtokarr(cRet,"=")
			cRet := aRet[2]
		endif
	Endif
return cRet

static function getPedidosLiberado()
	local cQuery := ""
	local cAlias := ""
	local nTotal := 0

	cQuery += "SELECT" + CRLF
	cQuery += "	SUM(C9_QTDLIB * C9_PRCVEN) AS TOTAL" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + retSqlTab("SC9") + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SC9") + CRLF
	cQuery += "	AND C9_CLIENTE = '" + SC9->C9_CLIENTE + "'" + CRLF
	cQuery += "	AND C9_LOJA = '" + SC9->C9_LOJA + "'" + CRLF
	cQuery += "	AND C9_NFISCAL = ' '" + CRLF
	cQuery += "	AND C9_BLCRED = ' '" + CRLF
	cQuery += "	AND " + retSqlDel("SC9") + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	cValor := TRansform((cAlias)->(TOTAL),PesqPict("SC6","C6_VALOR",17,1))
	nTotal := (cAlias)->(TOTAL)

	(cAlias)->(dbCloseArea())
return cValor

