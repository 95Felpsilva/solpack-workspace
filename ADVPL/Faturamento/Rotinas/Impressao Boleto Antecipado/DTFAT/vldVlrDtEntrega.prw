#include 'totvs.ch'
/*/{Protheus.doc} vldVlrDtEntrega
Valida data de entrega e valor
@type function
@version 12.1.33
@author Tiago Faria
@since 22/11/2021
@return logical, Se true esta tudo correto se false houve erro no preenchimento
/*/
user function vldVlrDtEntrega(lValid)
	local lRet       := .t.
	local oBol       := BolAntecip():New()
	local dDtEntrega := stod("")
	default lValid   := .t.

	BEGIN SEQUENCE
		if lValid .and. !oBol:isPVBoletoAntecipado(M->C5_FORPGT/*cFormaPagamento*/,M->C5_CONDPAG/*cCondPagamento*/,.f./*lHelp*/)
			BREAK
		endif

		//Tratamento para integração via API REST FLUIG X PROTHEUS
		if lValid .and. isBlind() .and. M->C5_ZZBASED>0
			M->C5_ZZPAR2 := M->(C5_ZZBASED-C5_ZZPAR1)
		endif

		if lValid .and. getValorTotal() <> M->C5_ZZBASED
			lRet := .f.
			u_myHelp("O valor dos campos " + getTitle("C5_ZZPAR1") + "[" + cValToChar(M->(C5_ZZPAR1)) + "] + " + getTitle("C5_ZZPAR2") + "[" + cValToChar(M->(C5_ZZPAR2)) + "] estão diferente do campo " + getTitle("C5_ZZBASED") + "[" + cValToChar(M->C5_ZZBASED) + "]" ,,"BOLETO ANTECIPADO")
			break
		endif

		dDtEntrega := maiorDataEntrega()

		if !empty(M->C5_ZZPAR1)
			M->C5_ZZVEN1 := BolAntecip():somaDiasUteis(date(),oBol:nDias1Parcela)
		Else
			M->C5_ZZVEN1 := STOD("")
		EndIf
		if !empty(M->C5_ZZPAR2)
			M->C5_ZZVEN2 := BolAntecip():somaDiasUteis(dDtEntrega,oBol:nDias2Parcela * -1)
		Else
			M->C5_ZZVEN2 := STOD("")
		endif
	END SEQUENCE

return lRet

static function maiorDataEntrega()
	local nLin       := 0
	local dDtEntrega := stod("")
	local dDtEntRet  := stod("")

	for nLin := 1 to len(aCols)
		if gdDeleted(nLin)
			loop
		endif

		dDtEntrega := gdFieldGet("C6_ZZDTFAT")

		if dDtEntrega > dDtEntRet
			dDtEntRet := dDtEntrega
		endif
	next nLin
return dDtEntRet

static function getTitle(cField)
return alltrim(getSX3Cache(cField,"X3_TITULO"))

static function getValorTotal()
	local nField        := 0
	local cCampoParcela := ""
	local nRet          := 0

	while .t.
		nField++
		cCampoParcela  := "C5_ZZPAR" + cValToChar(nField)

		if SC5->(fieldPos(cCampoParcela)) > 0
			nParcela := &("M->"+cCampoParcela)
			if nParcela > 0
				nRet += nParcela
			endif
		else
			exit
		endif
	enddo
return nRet
