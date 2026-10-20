#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc}	getImpre
Captura todas as impressoras cadastradas e devolve no array

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					26/06/2015
@return				nil
/*/
User Function getImpre(aCombo,aOpc)
	local aZP			:= FWGetSX5("ZP")
	local nZP			:= 0
	local cChave		:= ""
	local cDescricao	:= ""
	Default aCombo		:= {}
	Default aOpc		:= {}

	for nZP := 1 to len(aZP)
		cChave 		:= alltrim(aZP[nZP][3])
		cDescricao 	:= alltrim(aZP[nZP][4])

		Aadd(aCombo	,cDescricao)
		Aadd(aOpc	,{cDescricao,cChave})
	next nZP
Return
