#include 'totvs.ch'
#include 'topconn.ch'
/*/{Protheus.doc} AtuDtBaixaRA
Atualiza data da baixa via RA
@type function
@version 12.1.33
@author Tiago Faria
@since 06/12/2021
/*/
user function AtuDtBaixaRA()
	Local aParambox		:= {}
	local cMVBkp        := MV_PAR01

	Aadd(aParambox,{1,"Data da Baixa"	,stod(""),"","","","",70,.T.})		//MV_PAR01

	if SE1->(alltrim(E1_TIPO) == 'RA' .AND. alltrim(E1_PREFIXO) $ 'PV/MAN' .AND. E1_SALDO == 0)
		//Valida o endereço que será gerado os saldos
		If ParamBox(aParambox,"Atualiza data da Baixa RA",,,,,,,,"AtuDtBaixaRA",.T.,.T.)
			Processa({||atuData()})
		EndIf
	else
        msgAlert("A atualização da data de baixa só funciona para títulos do TIPO RA, PREFIXO PV e que esteja baixado!")
	endif

	MV_PAR01 := cMVBkp
return

static function atuData()
	local cQuery := ""
	local cAlias := ""
	local aArea  := Lj7GetArea({"SE5","SE1","FK5"})

	cQuery += "SELECT" + CRLF
	cQuery += "	SE1.R_E_C_N_O_ AS E1RECNO," + CRLF
	cQuery += "	SE5.R_E_C_N_O_ AS E5RECNO," + CRLF
	cQuery += "	FK5.R_E_C_N_O_ AS FK5RECNO" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SE1") + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("SE5") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SE5") + CRLF
	cQuery += "	AND E5_PREFIXO = E1_PREFIXO" + CRLF
	cQuery += "	AND E5_NUMERO = E1_NUM" + CRLF
	cQuery += "	AND E5_PARCELA = E1_PARCELA" + CRLF
	cQuery += "	AND E5_TIPO = E1_TIPO" + CRLF
	cQuery += "	AND E5_CLIFOR = E1_CLIENTE" + CRLF
	cQuery += "	AND E5_LOJA = E1_LOJA " + CRLF
	cQuery += "	AND " + retSqlDel("SE5") + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("FK5") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("FK5") + CRLF
	cQuery += "	AND FK5_IDMOV = E5_IDORIG" + CRLF
	cQuery += "	AND FK5.D_E_L_E_T_ =  ' '" + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SE1") + CRLF
	cQuery += "	AND E1_PREFIXO  = '" + SE1->E1_PREFIXO + "'" + CRLF
	cQuery += "	AND E1_NUM  = '" + SE1->E1_NUM + "'" + CRLF
	cQuery += "	AND E1_PARCELA  = '" + SE1->E1_PARCELA + "'" + CRLF
	cQuery += "	AND E1_TIPO  = '" + SE1->E1_TIPO + "'" + CRLF
	cQuery += "	AND E1_TIPO = 'RA'" + CRLF
	cQuery += "	AND E1_PREFIXO IN ('PV','MAN')" + CRLF
	cQuery += "	AND E1_SALDO = 0" + CRLF
	cQuery += "	AND " + retSqlDel("SE1") + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	if (cAlias)->(Eof())
		msgAlert("Não há dados para alterar a data da baixa!")
	endif

	While (cAlias)->(!EOf())
		SE1->(dbGoTo((cAlias)->(E1RECNO)))
		SE5->(dbGoTo((cAlias)->(E5RECNO)))
		FK5->(dbGoTo((cAlias)->(FK5RECNO)))

		recLock("SE1",.f.)
		SE1->E1_BAIXA := MV_PAR01
		SE1->(msUnlock())

		recLock("SE5",.f.)
		SE5->E5_DTDISPO := MV_PAR01
		SE5->E5_DATA    := MV_PAR01
		SE5->(msUnlock())

		recLock("FK5",.f.)
		FK5->FK5_DATA    := MV_PAR01
		FK5->FK5_DTDISPO := MV_PAR01
		FK5->(msUnlock())

		(cAlias)->(dbskip())
	enddo

	(cAlias)->(dbCloseArea())

	Lj7RestArea(aArea)
return
