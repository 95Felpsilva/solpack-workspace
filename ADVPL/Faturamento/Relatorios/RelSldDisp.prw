#include 'totvs.ch'
#include 'topconn.ch'
/*/{Protheus.doc} RelSldDisp
Relatório Saldo Disponivel
@type function
@version 12.1.33
@author Tiago Faria
@since 03/11/2021
/*/
user function RelSldDisp()
	private cProdDe := ""
	private cProdAte := ""

	if ask()
        FWMsgRun( ,{ || run() } ,"RelSldDisp", "Aguarde extraindo os dados!"  )
	endif
return

static function run()
	local cAlias := ''
	local cQuery := ''
	local aItens := {}
	local aAux   := {}
	local aCab   := {}

	cQuery += "SELECT" + CRLF
	cQuery += "	SB1.R_E_C_N_O_ AS B1RECNO," + CRLF
	cQuery += "	B1_COD," + CRLF
	cQuery += "	B1_DESC" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + RetSqlTab('SB1') + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + RetSqlFil('SB1') + CRLF
	cQuery += "	AND B1_COD BETWEEN '" + cProdDe + "' AND '" + cProdAte + "'" + CRLF
	cQuery += "	AND B1_TIPO = 'PA'" + CRLF
	cQuery += "	AND " + RetSqlDel('SB1') + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	while (cAlias)->(!Eof())
        SB1->(dbGoTo((cAlias)->(B1RECNO)))
		nSldDisp := u_getSaldosPrd((cAlias)->(B1_COD),.t./*lRetSaldo*/)

		aAdd(aAux,(cAlias)->(B1_COD))
		aAdd(aAux,(cAlias)->(B1_DESC))
		aAdd(aAux,nSldDisp)

		aAdd(aItens,aAux)

		aAux := {}
		(cAlias)->(dbSkip())
	enddo

	aadd(aCab,"Código")
	aadd(aCab,"Descrição")
	aadd(aCab,"Saldo Disponivel")

	FWMsgRun( ,{ || exportExcel(aCab,aItens) } ,"RelSldDisp", "Aguarde gerando o excel!"  )

	(cAlias)->(dbCloseArea())
return

static function ask()
	Local aParamBox := {}
	local lRet      := .f.

	Aadd(aParamBox,{1,"Produto De"			,Space(getSX3Cache("B1_COD","X3_TAMANHO")),	"",	"",	"SB1",	"",70, .F.})// MV_PAR01
	Aadd(aParamBox,{1,"Produto Ate"			,Space(getSX3Cache("B1_COD","X3_TAMANHO")),	"",	"",	"SB1",	"",70, .T.})// MV_PAR02

	If ParamBox(aParamBox,"Filtros Relatório",,,,,,,,"RelPedSituacao",.T.,.T.)
		lRet := .t.
		cProdDe := MV_PAR01
		cProdAte := MV_PAR02
	EndIf
return lRet

static function exportExcel(aCab,aItens)
	Local oXML 	:= IPGeraXML():new()

	oXML:setCabec(aCab)
	oXML:setItens(aItens)

	oXML:createXML()

	oXML:showXML()

	msgInfo("Arquivo gerado com sucesso!")
return
