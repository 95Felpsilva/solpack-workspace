#Include 'Protheus.ch'

/*/{Protheus.doc} MT103NTZ
	Selecionar a natureza no Documento de Entrada.

 @type function
 @version 1.0
 @author jair.andrade
 @since 23/10/2023
 @return character, Natureza cadastrada pelo NFLegal
/*/
user function MT103NTZ()
	Local cNaturPad		:= PARAMIXB[1]
	Local cNewNatur		:= ""
	Local oHistControl	:= NFLHistLancAutoControl():new()
    Local nTamCpo       := U_NFLTAMFLD("HIST_ROTAUTO_MAP","ITEM_XML")[3]

	cNewNatur := ALLTRIM(oHistControl:getFieldValueByItemNF(SF1-> F1_CHVNFE, PADL(SD1-> D1_ITEM,nTamCpo,"0"), "E2_NATUREZ"))

	// Se não for preenchido no NFLegal, considera da Natureza definida pelo padrão do Protheus
	If empty(cNewNatur)
		cNewNatur := cNaturPad
	endIf
return cNewNatur
