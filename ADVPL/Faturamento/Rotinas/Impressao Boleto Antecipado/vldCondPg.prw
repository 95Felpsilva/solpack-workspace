#include 'totvs.ch'
#include 'topconn.ch'

#Define PGTO_ANT_ENV_BOLETO "3"
#Define PGTO_ANT_TIT_REGISTRADO_EM_BANCO "4"
#Define PGTO_ANT_TITULO_BAIXADO "5"


/*/{Protheus.doc} vldCondPG
Valida condição de pagamento informada no Pedido de Vendas
@type function
@version 12.1.33
@author Tiago Faria
@since 18/11/2021
@return logical, Se true condicao de pagametno esta OK se false não está
/*/
user function vldCondPG()
	local lRet  := .t.
	local lHelp := .t.
	local nTotalAdt := if(type("nTotAdt") == "N",nTotAdt,0)

	if BolAntecip():isFormaPgtoBolAntecipado(M->C5_FORPGT)
		BEGIN SEQUENCE
			if !BolAntecip():isCondPgtoBolAntecipado(M->C5_CONDPAG,lHelp)
				lRet := .f.
				break
			endif
			if ALTERA .and. nTotalAdt > 0 .and.;
					SC5->C5_ZZLEGBA+"|" $ PGTO_ANT_ENV_BOLETO + "|" +  PGTO_ANT_TIT_REGISTRADO_EM_BANCO + "|" + PGTO_ANT_TITULO_BAIXADO .and.;
					nTotalAdt <> getTotalAdtPV()
				lRet := .f.
				u_myHelp("Não é possivel relacionar adiantamentos (RA) ao Pedido, pois já foi enviado boleto para pagamento antecipado ao cliente!",,"BOLETO ANTECIPADO")
				break
			endif

			if nTotalAdt == 0 .and. BolAntecip():isRAAbertoCliente(M->C5_CLIENTE,M->C5_LOJACLI)
				if !msgYesNo("Há Recibimentos Antecipados [RA] em aberto para o cliente, deseja realmente continuar com a gravação do Pedido de Vendas?")
					lRet := .f.
					break
				endif
			endif
		END SEQUENCE
	endif
return lRet

static function getTotalAdtPV()
	local cAlias := ''
	local cQuery := ''

	cQuery += "SELECT" + CRLF
	cQuery += "	SUM(FIE_SALDO) AS SALDO" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + RetSqlTab('FIE') + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + RetSqlFil('FIE') + CRLF
	cQuery += "	AND FIE_CART = 'R'" + CRLF
	cQuery += "	AND FIE_PEDIDO = '" + SC5->C5_NUM + "'" + CRLF
	cQuery += "	AND " + RetSqlDel('FIE') + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	nSaldo := (cAlias)->(SALDO)

	(cAlias)->(dbCloseArea())
return nSaldo
