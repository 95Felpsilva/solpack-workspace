#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

static POS_PROGRAMADO 		:= 1
static POS_IMEDIATO 		:= 2
static POS_ATRASADOS 		:= 3
static POS_PREVISTO 		:= 4
static POS_PREV_MES_Q_VEM   := 5
static POS_QATU				:= 6
static POS_QPEDVEN			:= 7
static POS_SALDO_DISPONIVEL := 8

static PROGRAMADO 			:= "Programado"
static IMEDIATO 			:= "Imediato"
static ATRASADOS 			:= "Atrasados"
static PREVISTO_MES_QUE_VEM := "Prog. mês que vem"
static PREVISTO				:= "Previsto"

user function tstMTGRDVW()
	rpcsetenv("01","0101")
	MaViewSB2("30.10.05.01.01")
	rpcClearEnv()
return

/*/{Protheus.doc} MTGRDVW
Inclui campos na tela de Consulta ao estoques
@author Tiago Faria
@since 25/05/2020
@version 1.0
@type function
/*/
user function MTGRDVW()
	//local aViewB2 			:= PARAMIXB[1]
	//local oListBox			:= PARAMIXB[2]
	local oDlg				:= PARAMIXB[3]
	local nColorGreen		:= nil//rgb(128,255,128)
	local nPosInput			:= 0
	local nDistancia 		:= 15
	local nTotalDisponivel 	:= 0
	local nQtdProgramado	:= 0
	local nQtdImediato		:= 0
	local nAtrasado			:= 0
	local nPrevisto			:= 0
	local nPrevMesQVem		:= 0
	local aSituacao			:= u_getSaldosPrd(SB1->B1_COD)
	local oFonte			:= nil
	private lProgramado     := .t.
	private lImediato       := .t.
	private lPrevisto	    := .t.
	private lPrevMesQVem	:= .t.
	private lAtrasado		:= .t.
	//aumenta o tamanho da tela na vertical
	oDLG:nBottom := 590
	oDLG:NCLIENTHEIGHT := oDLG:nBottom

	DEFINE FONT oFonte NAME "Arial" SIZE 0, -12 BOLD

	nQtdProgramado		:= aSituacao[POS_PROGRAMADO]
	nQtdImediato		:= aSituacao[POS_IMEDIATO]
	nAtrasado			:= aSituacao[POS_ATRASADOS]
	nPrevisto			:= aSituacao[POS_PREVISTO]
	nPrevMesQVem		:= aSituacao[POS_PREV_MES_Q_VEM]
	nTotalDisponivel	:= aSituacao[POS_SALDO_DISPONIVEL]

	oPanel := TPanel():New( 205,000,"",oDLG,,.F.,.F.,,nColorGreen,150,150,.f.,.F. )
	nPosInput := 005

	@ nPosInput,007 SAY "#"+ATRASADOS of oPanel PIXEL
	@ nPosInput,075 MsGet nAtrasado Picture PesqPict("SB2","B2_QEMPPRE") of oPanel PIXEL SIZE 070,009 When .F.

	nPosInput+= nDistancia

	@ nPosInput,007 SAY "#"+IMEDIATO of oPanel PIXEL
	@ nPosInput,075 MsGet nQtdImediato Picture PesqPict("SB2","B2_QEMPPRE") of oPanel PIXEL SIZE 070,009 When .F.

	/*
	nPosInput+= nDistancia

	@ nPosInput,007 SAY "#"+PREVISTO_MES_QUE_VEM of oPanel PIXEL
	@ nPosInput,075 MsGet nPrevMesQVem Picture PesqPict("SB2","B2_QEMPPRE") of oPanel PIXEL SIZE 070,009 When .F.
	*/
	nPosInput+= nDistancia

	@ nPosInput,007 SAY "#"+PREVISTO of oPanel PIXEL
	@ nPosInput,075 MsGet nPrevisto Picture PesqPict("SB2","B2_QEMPPRE") of oPanel PIXEL SIZE 070,009 When .F.

	nPosInput+= nDistancia

	@ nPosInput,007 SAY "#"+PROGRAMADO of oPanel PIXEL
	@ nPosInput,075 MsGet nQtdProgramado Picture PesqPict("SB2","B2_QEMPPRE") of oPanel PIXEL SIZE 070,009 When .F.

	@ 225,155 SAY "#Prazo de Venda " + cValToChar(SB1->B1_ZZPE) + " dias" of oDlg FONT oFonte /*COLORS 255, 16777215*/ PIXEL

	if nTotalDisponivel >= 0
		@ 240,155 SAY "#Qtd Dispon. " + alltrim(Transform(nTotalDisponivel,PesqPict("SB2","B2_QEMPPRE"))) of oDlg FONT oFonte /*COLORS 255, 16777215*/ PIXEL
	else
		@ 240,155 SAY "#Qtd Dispon. " + alltrim(Transform(nTotalDisponivel,PesqPict("SB2","B2_QEMPPRE"))) of oDlg FONT oFonte COLORS 255, 16777215 PIXEL
	endif

	@ 245,244  BUTTON "Detalhar Saldo" SIZE 045,010  FONT oDlg:oFont ACTION (u_detalharSaldo())  OF oDlg PIXEL
	@ 260,244  BUTTON "Kardex" SIZE 045,010  FONT oDlg:oFont ACTION (showKardex())  OF oDlg PIXEL
	@ 260,190  BUTTON "PV x OP" SIZE 045,010  FONT oDlg:oFont ACTION (u_detalharSaldo())  OF oDlg PIXEL
return

user function getSaldosPrd(cProduto,lRetSaldo)
	local lRetQuery      := .t.
	local cQuery         := ""
	local aArea          := Lj7GetArea({"SB1", "SB2"})
	local aSituacao      := {0,0,0,0,0,0,0,0}
	local lOrderBy       := .f.
	local nQtdProgramado := 0
	local nQtdImediato   := 0
	local nAtrasado      := 0
	local nPrevisto      := 0
	local nPrevMesQVem   := 0
	local nSaldoSB2      := 0
	default lRetSaldo    := .f.

	cQuery += "SELECT" + CRLF
	cQuery += "	SITUACAO," + CRLF
	cQuery += "	B2_QATU," + CRLF
	cQuery += "	B2_QPEDVEN," + CRLF
	cQuery += "	SUM(SALDO) AS SALDO" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	(" + CRLF
	cQuery += u_getSituacao(lRetQuery,cProduto,cProduto,lOrderBy)
	cQuery += "	)X" + CRLF
	cQuery += "GROUP BY " + CRLF
	cQuery += "	SITUACAO," + CRLF
	cQuery += "	B2_QATU," + CRLF
	cQuery += "	B2_QPEDVEN" + CRLF

	memowrite("\sql\MTGRDVW_AGRUPADO_POR_SITUACAO.sql",cQuery)

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	while (cAlias)->(!Eof())
		cSituacao 				:= alltrim((cAlias)->(SITUACAO))
		aSituacao[POS_QATU]		:= (cAlias)->B2_QATU
		aSituacao[POS_QPEDVEN]	:= (cAlias)->B2_QPEDVEN

		if cSituacao == PROGRAMADO
			aSituacao[POS_PROGRAMADO] := (cAlias)->SALDO
		endif

		if cSituacao == IMEDIATO
			aSituacao[POS_IMEDIATO] := (cAlias)->(SALDO)
		endif

		if cSituacao == ATRASADOS
			aSituacao[POS_ATRASADOS] := (cAlias)->SALDO
		endif

		if cSituacao == PREVISTO
			aSituacao[POS_PREVISTO] := (cAlias)->SALDO
		endif

		if cSituacao == PREVISTO_MES_QUE_VEM
			aSituacao[POS_PREV_MES_Q_VEM] := (cAlias)->SALDO
		endif


		(cAlias)->(dbSkip())
	enddo

	nQtdProgramado		:= aSituacao[POS_PROGRAMADO]
	nQtdImediato		:= aSituacao[POS_IMEDIATO]
	nAtrasado			:= aSituacao[POS_ATRASADOS]
	nPrevisto			:= aSituacao[POS_PREVISTO]
	nPrevMesQVem		:= aSituacao[POS_PREV_MES_Q_VEM]

	nSaldoSB2 := getSaldoDisponivel()

	if nSaldoSB2 >= 0
		nTotalDisponivel 	:= nSaldoSB2 - aSituacao[POS_IMEDIATO] - aSituacao[POS_ATRASADOS] - aSituacao[POS_PREV_MES_Q_VEM] - aSituacao[POS_PREVISTO]
	else
		nTotalDisponivel 	:= ((nSaldoSB2 * -1) + aSituacao[POS_IMEDIATO] + aSituacao[POS_ATRASADOS] + aSituacao[POS_PREV_MES_Q_VEM] + aSituacao[POS_PREVISTO]) * -1
	endif

	aSituacao[POS_SALDO_DISPONIVEL] := nTotalDisponivel

	(cAlias)->(dbCloseArea())

	Lj7RestArea(aArea)

	if lRetSaldo
		return nTotalDisponivel
	endif
return aSituacao

user function getSituacao(lRetQuery,cProdDe,cProdAte,lOrderBy)
	local cAlias      := ""
	local cQuery      := ""
	default lOrderBy  := .f.
	default lRetQuery := .t.

	cQuery += "SELECT" + CRLF
	cQuery += "	C6_NUM," + CRLF
	cQuery += "	C6_ITEM," + CRLF
	cQuery += "	A1_ZZPERCL," + CRLF
	cQuery += "	A1_ZZPADRE," + CRLF
	cQuery += u_regraSituacao()
	cQuery += "	SALDO," + CRLF
	cQuery += "	DATEDIFF(DAY, CAST(C5_EMISSAO AS DATETIME), CAST(C6_ENTREG AS DATETIME)) AS 'DIAS_ENTREGA_EMISSAO'," + CRLF
	cQuery += "	CONVERT(VARCHAR, CAST(C5_EMISSAO AS DATETIME), 103) AS 'EMISSAO'," + CRLF
	cQuery += "	CONVERT(VARCHAR, CAST(C6_ZZDTFAT AS DATETIME), 103) AS 'FATURAMENTO'," + CRLF
	cQuery += "	CONVERT(VARCHAR, CAST(C6_ENTREG AS DATETIME), 103) AS 'ENTREGA'," + CRLF
	cQuery += "	C6_PRODUTO," + CRLF
	cQuery += "	B1_DESC," + CRLF
	cQuery += "	C5_CLIENTE," + CRLF
	cQuery += "	C5_LOJACLI," + CRLF
	cQuery += "	C5_FORPGT AS FORMA_PAGTO," + CRLF
	cQuery += "	A1_NREDUZ," + CRLF
	cQuery += "	B2_QATU," + CRLF
	cQuery += "	B2_QPEDVEN," + CRLF
	cQuery += "	C5_EMISSAO," + CRLF
	cQuery += "	B1_ZZPE" + CRLF
	cQuery += "FROM " + CRLF

	cQuery += "(" + CRLF
	cQuery += "	SELECT" + CRLF
	cQuery += "		'COM SC9' AS ORIGEM," + CRLF
	cQuery += "		C6_FILIAL," + CRLF
	cQuery += "		C6_NUM," + CRLF
	cQuery += "		C6_ITEM," + CRLF
	cQuery += "		C6_PRODUTO," + CRLF
	cQuery += "		C6_TES," + CRLF
	cQuery += "		C6_ENTREG," + CRLF
	cQuery += "		C6_ZZDTFAT," + CRLF
	cQuery += "		C9_QTDLIB AS SALDO," + CRLF
	cQuery += "		C9_BLEST," + CRLF
	cQuery += "		C9_BLCRED" + CRLF
	cQuery += "	FROM " + CRLF
	cQuery += "		" + retSqlTab("SC6") + CRLF
	cQuery += "	INNER JOIN" + CRLF
	cQuery += "		" + retSqlTab("SC9") + CRLF
	cQuery += "	ON 1=1" + CRLF
	cQuery += "		AND C9_FILIAL = C6_FILIAL" + CRLF
	cQuery += "		AND C9_PEDIDO = C6_NUM" + CRLF
	cQuery += "		AND C9_ITEM = C6_ITEM" + CRLF
	cQuery += "		AND C9_NFISCAL = ''" + CRLF
	cQuery += "		AND SC9.D_E_L_E_T_  = ' '" + CRLF
	cQuery += "	WHERE 1=1" + CRLF
	cQuery += "		AND " + retSqlFil("SC6") + CRLF
	cQuery += "	    AND C6_PRODUTO BETWEEN '" + cProdDe + "' AND '" + cProdAte + "'" + CRLF
	cQuery += "		AND C6_QTDVEN > C6_QTDENT " + CRLF
	cQuery += "		AND " + retSqlDel("SC6") + CRLF
	cQuery += "	UNION ALL" + CRLF
	cQuery += "	SELECT" + CRLF
	cQuery += "		'SEM SC9' AS ORIGEM," + CRLF
	cQuery += "		C6_FILIAL," + CRLF
	cQuery += "		C6_NUM," + CRLF
	cQuery += "		C6_ITEM," + CRLF
	cQuery += "		C6_PRODUTO," + CRLF
	cQuery += "		C6_TES," + CRLF
	cQuery += "		C6_ENTREG," + CRLF
	cQuery += "		C6_ZZDTFAT," + CRLF
	cQuery += "		C6_QTDVEN - C6_QTDENT - COALESCE(QTDLIB,0) AS SALDO," + CRLF
	cQuery += "		NULL C9_BLEST," + CRLF
	cQuery += "		NULL C9_BLCRED" + CRLF
	cQuery += "	FROM " + CRLF
	cQuery += "		" + retSqlTab("SC6") + CRLF
	cQuery += "	OUTER APPLY" + CRLF
	cQuery += "	(" + CRLF
	cQuery += "		SELECT" + CRLF
	cQuery += "			C9_FILIAL," + CRLF
	cQuery += "			C9_PEDIDO," + CRLF
	cQuery += "			C9_ITEM," + CRLF
	cQuery += "			SUM(C9_QTDLIB) AS QTDLIB" + CRLF
	cQuery += "		FROM" + CRLF
	cQuery += "			" + retSqlTab("SC9") + CRLF
	cQuery += "		WHERE 1=1" + CRLF
	cQuery += "			AND C9_FILIAL = C6_FILIAL" + CRLF
	cQuery += "			AND C9_PEDIDO = C6_NUM" + CRLF
	cQuery += "			AND C9_ITEM = C6_ITEM" + CRLF
	cQuery += "			AND C9_NFISCAL = ''" + CRLF
	cQuery += "			AND " + retSqlDel("SC9") + CRLF
	cQuery += "		GROUP BY" + CRLF
	cQuery += "			C9_FILIAL," + CRLF
	cQuery += "			C9_PEDIDO," + CRLF
	cQuery += "			C9_ITEM" + CRLF
	cQuery += "	) AS SC9" + CRLF
	cQuery += "	WHERE 1=1" + CRLF
	cQuery += "		AND " + retSqlFil("SC6") + CRLF
	cQuery += "	    AND C6_PRODUTO BETWEEN '" + cProdDe + "' AND '" + cProdAte + "'" + CRLF
	cQuery += "		AND C6_QTDVEN > C6_QTDENT " + CRLF
	cQuery += "		AND C6_QTDVEN - C6_QTDENT - COALESCE(QTDLIB,0) > 0" + CRLF
	cQuery += "		AND " + retSqlDel("SC6") + CRLF
	cQuery += ") SC6" + CRLF

	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlTab('SB1') + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + RetSqlFil('SB1') + CRLF
	cQuery += "	AND B1_COD = C6_PRODUTO" + CRLF
	cQuery += "	AND " + RetSqlDel('SB1') + CRLF

	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlTab('SF4') + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + RetSqlFil('SF4') + CRLF
	cQuery += "	AND F4_CODIGO = C6_TES" + CRLF
	cQuery += "	AND F4_ESTOQUE = 'S' " + CRLF
	cQuery += "	AND " + RetSqlDel('SF4') + CRLF

	cQuery += "JOIN " + CRLF
	cQuery += "	" + retSqlTab("SC5") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SC5") + CRLF
	cQuery += "	AND C5_FILIAL = C6_FILIAL" + CRLF
	cQuery += "	AND C5_NUM = C6_NUM" + CRLF
	cQuery += "	AND C5_NOTA = ' '" + CRLF
	cQuery += "	AND " + retSqlDel("SC5") + CRLF

	cQuery += "JOIN " + CRLF
	cQuery += "	" + retSqlTab("SA1") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SA1") + CRLF
	cQuery += "	AND A1_COD = C5_CLIENTE" + CRLF
	cQuery += "	AND A1_LOJA = C5_LOJACLI" + CRLF
	cQuery += "	AND " + retSqlDel("SA1") + CRLF

	cQuery += "JOIN " + CRLF
	cQuery += "(" + CRLF
	cQuery += "	SELECT" + CRLF
	cQuery += "		B2_FILIAL," + CRLF
	cQuery += "		B2_COD," + CRLF
	cQuery += "		SUM(B2_QATU) AS B2_QATU," + CRLF
	cQuery += "		SUM(B2_RESERVA) AS B2_RESERVA," + CRLF
	cQuery += "		SUM(SB2.B2_QPEDVEN ) AS B2_QPEDVEN" + CRLF
	cQuery += "	FROM " + CRLF
	cQuery += "		" + retSqlTab("SB2") + CRLF
	cQuery += "	WHERE 1=1" + CRLF
	cQuery += "		AND " + retSqlFil("SB2") + CRLF
	cQuery += "		AND " + retSqlDel("SB2") + CRLF
	cQuery += "	GROUP BY" + CRLF
	cQuery += "		B2_FILIAL," + CRLF
	cQuery += "		B2_COD" + CRLF
	cQuery += ") SB2" + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND B2_COD = C6_PRODUTO" + CRLF
	cQuery += "WHERE 1=1" + CRLF

	if lOrderBy
		cQuery += "ORDER BY C5_EMISSAO,C5_NUM" + CRLF
	endif
	memowrite("\sql\MTGRDVW_SEM_AGRUPAMENTO.sql",cQuery)

	if lRetQuery
		cAlias := cQuery
	else
		TcQuery cQuery new Alias (cAlias := getNextAlias())
	endif
return cAlias

static function getQueryFil()
	local cQueryOrig := u_getSituacao(.t.,SB1->B1_COD,SB1->B1_COD,.f.)
	local cQuery := ""
	local cFiltro := ""
	cQuery += "SELECT" + CRLF
	cQuery += "	*" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	(" + CRLF
	cQuery += cQueryOrig + CRLF
	cQuery += "	)X" + CRLF
	cQuery += "WHERE 1=1" + CRLF

	if lProgramado
		cFiltro += PROGRAMADO + "+"
	endif
	if lImediato
		cFiltro += IMEDIATO + "+"
	endif
	if lPrevisto
		cFiltro += PREVISTO + "+"
	endif
	if lPrevMesQVem
		cFiltro += PREVISTO_MES_QUE_VEM + "+"
	endif
	if lAtrasado
		cFiltro += ATRASADOS + "+"
	endif
	if !empty(cFiltro)
		cQuery += "	AND SITUACAO IN " + formatIn(cFiltro,"+")
	endif
	cQuery += "	ORDER BY C5_EMISSAO" + CRLF

	memowrite("\sql\MTGRDVW_getQueryFil.sql",cQuery)
return cQuery

user function detalharSaldo(cProdDe,cProdAte)
	local aArea		:= Lj7GetArea({"SB1","SB2"})
	local aCoords	:= FWGetDialogSize( oMainWnd )
	local oDlg		:= nil
	local cQuery 	:= ""
	local bOK		:= {||oDlg:end()}
	local bCancel	:= {||oDlg:end()}
	local aButtons	:= {}
	local nColumn	:= 0
	private oGrid	:= nil
	default cProdDe := SB1->B1_COD
	default cProdAte:= SB1->B1_COD

	cQuery := u_getSituacao(.t.,cProdDe,cProdAte,.t.)

	aAdd(aButtons,{"",{||FWMsgRun( ,{ || exportExcel(oGrid) } ,"MTGRDVW", "Aguarde exportando dados para o Excel"  )}		,"Exportar Excel"})
	aAdd(aButtons,{"",{||FWMsgRun( ,{ || filGrid(oGrid) } ,"MTGRDVW", "Aguarde Filtrando os dados"  )}		,"Filtrar Dados"})

	Define MsDialog oDlg Title "Detalhamento Saldo"  From aCoords[1], aCoords[2] to aCoords[3], aCoords[4] Pixel

	oGrid := IpGridObject():newIpGridObject(0,0,0,0, oDlg)

	oGrid:setAccessMode("")
	oGrid:addSqlColumns(cQuery)
	aColumns := oGrid:getColumns()

	for nColumn := 1 to len(aColumns)
		cColumn := aColumns[nColumn]:getID()
		oGrid:getColumn(cColumn):setReadOnly(.t.)
	next nColumn

	oGrid:create()
	oGrid:getGrid():oBrowse:align := CONTROL_ALIGN_ALLCLIENT
	Activate MsDialog oDlg Center on init EnchoiceBar( oDlg, bOK,bCancel,,aButtons,,,.f.,.f.,.f.,,.f.)

	Lj7RestArea(aArea)
return

static function exportExcel(oGrid)
	Local oXML 	:= IPGeraXML():new()
	Local aAux	:= {}
	local nG	:= 0
	local nF	:= 0
	For nG := 1 to len(oGrid:getColumns())
		//If allTrim(oGrid:getColumns()[nG]:cBMPId) == ""
		aAdd(aAux,oGrid:getColumns()[nG]:cTitle)
		//EndIf
	Next
	oXML:setCabec(aAux)
	aAux := {}
	For nG := 1 to len(oGrid:getLines())
		aAdd(aAux,Array(len(oGrid:getLines()[nG])-1))
		For nF := 1 to len(aAux[len(aAux)])
			aAux[len(aAux)][nF] := oGrid:getLines()[nG][nF]
		Next
	Next
	oXML:setItens(aAux)

	oXML:createXML()

	oXML:showXML()

	msgInfo("Arquivo gerado com sucesso!")
return

static function filGrid(oGrid)
	local lRet 		:= .t.
	local aParamBox := {}
	local nI		:= 0
	local cBKP		:= MV_PAR01
	default lPerg 	:= .t.

	aAdd(aParamBox,{4,"Programados?",.F.,"",45,"",.F.})
	aAdd(aParamBox,{4,"Previsto?",.F.,"",90,"",.F.})
	aAdd(aParamBox,{4,"Prog. mês que vem?",.F.,"",90,"",.F.})
	aAdd(aParamBox,{4,"Imediato?",.F.,"",90,"",.F.})
	aAdd(aParamBox,{4,"Atrasados?",.F.,"",90,"",.F.})

	if lPerg
		lRet := ParamBox(aParamBox,"Filtro Pedidos",NIL,,,,,,,"_MTGRDVW",.T.,.t.)
	else
		for nI := 1 to len(aParambox)
			&("MV_PAR"+strzero(nI,2)) := ParamLoad(__cUserID+"_MTGRDVW",aParamBox,nI,aParamBox[nI,3])
		next nI
	endif

	if lRet
		lProgramado := MV_PAR01
		lPrevisto := MV_PAR02
		lPrevMesQVem := MV_PAR03
		lImediato := MV_PAR04
		lAtrasado := MV_PAR05
		oGrid:clear()
		oGrid:addSqlColumns(getQueryFil())
	endif
	MV_PAR01 := cBKP
return lRet

static function getSaldoDisponivel()
	local nSaldoSB2 := 0

	posicione("SB2",1,xFilial("SB2")+SB1->(B1_COD),"!eof()")

	while SB2->(!Eof()) .and. SB2->B2_FILIAL == xFilial("SB2") .and. SB2->(B2_COD) == SB1->(B1_COD)
		nSaldoSB2 += saldoSB2() + SB2->B2_RESERVA
		SB2->(dbSkip())
	enddo
return nSaldoSB2

static function showKardex()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se utiliza custo unificado por Empresa/Filial       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	local aBkpMV		:= getBkpMV()
	private cCadastro	:= "Kardex"
	PRIVATE lCusUnif 	:= A330CusFil()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta perguntas no SX1 a fim de preparar o relatorio p/     ³
//³ custo unificado por empresa                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCusUnif
		MTC030CUnf()
	EndIf
	If Pergunte("MTC030",.T.)
		MC030Con()
	EndIf

	restoreBkpMV(aBkpMV)
return

static function getBkpMV()
	local nQtdMV := 60
	local nMV	 := 0
	local cMV	 := ""
	local xContent := nil

	local aBkp	 := {}
	for nMV := 1 to nQtdMV
		cMV := "MV_PAR" + padL(cValToChar(nMV),2,"0")
		xContent := &(cMV)
		aAdd(aBkp,{cMV,xContent})
	next nMV
return aBkp

static function restoreBkpMV(aBkpMV)
	local nMV	 := 0
	local cMV	 := ""
	local xContent := nil

	for nMV := 1 to len(aBkpMV)
		cMV := aBkpMV[nMV,1]
		xContent := aBkpMV[nMV,2]

		&(cMV) := xContent
	next nMV
return

user function regraSituacao()
	local cQuery := ""
	local cData	 := dtos(dDataBase)

	cQuery += "	CASE" + CRLF
	cQuery += "		WHEN CAST(C6_ENTREG AS DATETIME) <= EOMONTH(CAST('" + cData + "' AS DATETIME),-1) THEN '" + ATRASADOS + "' --ENTREGA MENOR OU IGUAL AO MÊS ANTERIOR" + CRLF
	cQuery += "		WHEN C9_BLEST IS NOT NULL AND C9_BLEST = ' ' AND C9_BLCRED = ' ' THEN '" + IMEDIATO + "' --LIBERADO CRÉDITO E ESTOQUE" + CRLF
	cQuery += "		WHEN DATEPART(YEAR,CAST(C6_ENTREG AS DATETIME)) = DATEPART(YEAR,GETDATE()) AND DATEPART(MONTH,CAST(C6_ENTREG AS DATETIME)) = DATEPART(MONTH,GETDATE()) THEN '" + IMEDIATO + "' --ENTREGA NO MÊS ATUAL" + CRLF
	//cQuery += "		WHEN DATEPART(YEAR,CAST(C6_ENTREG AS DATETIME)) = DATEPART(YEAR,EOMONTH(GETDATE(),1)) AND DATEPART(MONTH,CAST(C6_ENTREG AS DATETIME)) = DATEPART(MONTH,EOMONTH(GETDATE(),1)) THEN '" + PREVISTO_MES_QUE_VEM + "'" + CRLF
	cQuery += "		WHEN DATEDIFF(DAY, CAST(C5_EMISSAO AS DATETIME), CAST(C6_ENTREG AS DATETIME)) <= B1_ZZPE THEN '" + PREVISTO + "' --DIFERENÇA ENTRE EMISSAO DO PEDIDO E DATA DA ENTREGA MENOR OU IGUAL AO ZZPE" + CRLF
	cQuery += "		WHEN DATEDIFF(DAY, CAST(C5_EMISSAO AS DATETIME), CAST(C6_ENTREG AS DATETIME)) > B1_ZZPE THEN '" + PROGRAMADO + "' --DIFERENÇA ENTRE EMISSAO DO PEDIDO E DATA DA ENTREGA MAIOR QUE O ZZPE" + CRLF
	cQuery += "		ELSE 'SEM SITUACAO' " + CRLF
	cQuery += "	END AS 'SITUACAO'," + CRLF
return cQuery
