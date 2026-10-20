#include 'totvs.ch'
/*/{Protheus.doc} vldAltPV
Valida alteração do pedido de vendas
@type function
@version 12.1.33
@author Tiago Faria
@since 10/11/2021
@return logical, Se true pode alterar se false não pode
/*/
user function vldAltPV()
	local lRet     := .t.

	M->C5_ZZBASED := BolAntecip():getBaseDup()

	if ALTERA
		If ExistBlock("BolAntecipDel")

			oBolAntecip := BolAntecipDel():new()
			if oBolAntecip:isBoletoGerado(.f./*lHelp*/)
				oCompare := CompareMemoryBank():new({|cField,cContentMemory,cContentDB| vldFields(cField,cContentMemory,cContentDB)})

				if !oCompare:runMemory("SC5",1,SC5->(C5_FILIAL+C5_NUM),"C5_CLIENTE|C5_LOJACLI|C5_FORPGT|C5_CONDPAG|C5_FRETE|C5_DESPESA|C5_ZZPAR1|C5_ZZVEN1|C5_ZZPAR2|C5_ZZVEN2|C5_ZZPAR3|C5_ZZVEN3|C5_ZZPAR4|C5_ZZVEN4|")
					lRet := .f.
					oCompare:showMessage("BOLETO ANTECIPADO")
				endif

				if lRet .and. !oCompare:runGetDados("SC6",1,SC5->(C5_FILIAL+C5_NUM),"C6_ITEM","C6_VALOR|C6_TES|C6_ENTREG|")
					lRet := .f.
					oCompare:showMessage("BOLETO ANTECIPADO")
				endif
                /*
                Valida o campo C5_ZZBASED após a validação dos campos da SC5 e SC6 para que
                o usuário consiga ser alertado sobre quais campos ele alterou que influenciou no valor do pedido
                caso algum campo que interfira no valor não esteja mapeado realiza a validação pelo campo C5_ZZBASED
                */
				if lRet .and. !oCompare:runMemory("SC5",1,SC5->(C5_FILIAL+C5_NUM),"C5_ZZBASED|")
					lRet := .f.
					oCompare:showMessage("BOLETO ANTECIPADO")
				endif

			endif
		endif
	endif
return lRet

static function getStrTotal(nTotal,cField)
	default cField := "C6_VALOR"
return alltrim(transform(nTotal,getSX3Cache(cField,"X3_PICTURE")))

static function vldFields(cField,cContentMemory,cContentDB)
	local lRet := .t.

	BEGIN SEQUENCE
		if cField == "C6_TES"
			cDupMem := posicione("SF4",1,xFilial("SF4")+cContentMemory,"F4_DUPLIC")
			cDupDB := posicione("SF4",1,xFilial("SF4")+cContentDB,"F4_DUPLIC")
			if cDupMem == cDupDB
				break
			endif
		endif

		RECOVER
		lRet := .f.

	END SEQUENCE

return lRet
