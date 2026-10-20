#include 'totvs.ch'
/*/{Protheus.doc} AliasToJson
Converte qualquer alias aberto no Protheus para JSON
@type function
@version 12.1.27
@author Tiago Faria
@since 31/07/2021
@param cAlias, character, Alias a ser convertido
@param lQuery, logical, Indica se o alias foi gerado a partir de uma query ou é alias padrão do protheus
@return json, Retorna objeto JSON
/*/
user function AliasToJson(cAlias,lQuery,lWhile)
	local oJson 	:= JsonObject():new()
	local oJsonIt 	:= JsonObject():new()
	local aItens    := {}
	local aStruct	:= (cAlias)->(dbStruct())
	local aArea     := {}
	default cALias 	:= "ZS2"
	default lQuery 	:= .f.
	default lWhile  := .t.

	if !lWhile
		return toJson(cAlias,aStruct)
	endif

	if !lQuery
		dbSelectArea(cAlias)
		(cAlias)->(dbSetOrder(1))
		(cAlias)->(dbGoTop())
		aArea := Lj7GetArea({cAlias})
	endif

	while (cAlias)->(!Eof())
		oJsonIt := toJson(cAlias,aStruct)
		aAdd(aItens,oJsonIt)
		(cAlias)->(dbSkip())
	enddo

	oJson[cAlias] := aItens

	if lQuery .and. lWhile
		(cAlias)->(dbGoTop())
	else
		Lj7RestArea(aArea)
	endif
	
return oJson

static function toJson(cAlias,aStruct)
	local oJsonIt 	:= JsonObject():new()
	local nField    := 0
	local cField    := ""
	local nQtdField := len(aStruct)

	for nField := 1 to nQtdField
		cField := aStruct[nField,1]

		oJsonIt[cField] := (cAlias)->(fieldGet(nField))
	next nField
return oJsonIt
