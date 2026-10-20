#INCLUDE "PROTHEUS.CH"

/*
* Funcao			: A103CLAS 
* Autor				: Daniel Tornisielo
* Data				: 25/09/2019
* Descrição			:  
* Observacoes		: 
*/       

User Function A103CLAS()
	Local cAliasSD1		:= PARAMIXB[1]
	Local oHistControl	:= NFLHistLancAutoControl():new()
	Local cTes			:= ""
	Local cKeyNF		:= IIF(allTrim(SF1-> F1_ESPECIE) $ "NFS/RPS", SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA, SF1-> F1_CHVNFE)

	cTes := oHistControl:getFieldValueByItemNF(cKeyNF, (cAliasSD1)-> D1_ITEM, "TESCLAS")

	If !Empty(cTes)
		GdFieldPut("D1_TES", padR(cTes, TamSX3('D1_TES')[1]), Len(aCols))
	EndIf
return

