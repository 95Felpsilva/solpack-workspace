#include 'totvs.ch'
/*/{Protheus.doc} ReImpEtqNF
ReImpressão etiqueta NF
@type function
@author Tiago Faria
@since 25/05/2021
/*/
user function ReImpNFEtq(lMark)
	default lMark := .f.
	selectItens(lMark)
return

static function selectItens(lMark)
	local aArea		:= Lj7GetArea({"SF2","SD2"})
	local aCoords	:= FWGetDialogSize( oMainWnd )
	local oDlg		:= nil
	local cQuery 	:= u_QryEtiqNF(.t.,,lMark)
	local bOK		:= {||oDlg:end(), lConfirm := .t.}
	local bCancel	:= {||oDlg:end(), lConfirm := .f.}
	local aButtons	:= {}
	local nColumn	:= 0
	local lConfirm  := .t.
	private oGrid	:= nil

	//aAdd(aButtons,{"",{||FWMsgRun( ,{ || exportExcel(oGrid) } ,"MTGRDVW", "Aguarde exportando dados para o Excel"  )}		,"Exportar Excel"})
	//aAdd(aButtons,{"",{||FWMsgRun( ,{ || filGrid(oGrid) } ,"MTGRDVW", "Aguarde Filtrando os dados"  )}		,"Filtrar Dados"})

	Aadd( aButtons, {"HISTORIC", {|| marcaTodos(oGrid,.t.)}, "Marcar Todos" })
	Aadd( aButtons, {"HISTORIC", {|| marcaTodos(oGrid,.f.)}, "Desmarcar Todos" })


	Define MsDialog oDlg Title "Re-Impressão Etiquetas NF " + SF2->F2_DOC  From aCoords[1], aCoords[2] to aCoords[3], aCoords[4] Pixel

	oGrid := IpGridObject():newIpGridObject(0,0,0,0, oDlg)

	oGrid:setAccessMode("update")
	oGrid:addSqlColumns(cQuery)

	oGrid:getColumn("MARKCOL"):setBMPId("MARKCOL")
	//oGrid:getColumn("MARKCOL"):setReadOnly(.t.)
	oGrid:getColumn("MARKCOL"):setPicture("@BMP")
	oGrid:getColumn("QTD_ETIQUETA"):setPicture("@E 999999")
	aColumns := oGrid:getColumns()

	for nColumn := 1 to len(aColumns)
		cColumn := aColumns[nColumn]:getID()
		if cColumn $ 'EAN/QTD_ETIQUETA'
			loop
		endif
		oGrid:getColumn(cColumn):setReadOnly(.t.)
	next nColumn

	oGrid:create()
	oGrid:getGrid():oBrowse:blDblClick := {|| onDoubleClick() }
	oGrid:getGrid():oBrowse:align := CONTROL_ALIGN_ALLCLIENT
	Activate MsDialog oDlg Center on init EnchoiceBar( oDlg, bOK,bCancel,,aButtons,,,.f.,.f.,.f.,,.f.)

	if lConfirm
		imprimeEtiqueta(oGrid)
	endif

	Lj7RestArea(aArea)
return

static function imprimeEtiqueta(oGrid)
	local nLine    := 0
	local cRecnos  := ""
	local nQtdMark := 0
	local aQtd     := {}

	for nLine := 1 to oGrid:length()
		if oGrid:getValue("MARKCOL",nLine) == 'CHECKED'
			aAdd(aQtd,{oGrid:getValue('D2RECNO',nLine),oGrid:getValue('QTD_ETIQUETA',nLine)})
			nQtdMark++
			if nQtdMark > 1
				cRecnos += ","
			endif
			cRecnos += cValToChar(oGrid:getValue('D2RECNO',nLine))
			if oGrid:getValue('EAN',nLine) <> oGrid:getValue('EAN_ORGINAL',nLine)
				updB1CodBar(oGrid,nLine)				
			endif
		endif
	next nLine

	if nQtdMark == 0
		if msgYesNo("Não foi selecionado itens para impressão das etiquetas, Deseja abrir a tela novamente?")
			u_ReImpNFEtq(.T.)
		endif
	else
		u_EtiqNF(cRecnos,aQtd)
	endif
return

static function updB1CodBar(oGrid,nLine)
	SB1->(dbGoTo(oGrid:getValue( 'B1RECNO' ,nLine)))
	if empty(SB1->B1_CODBAR)
		reclock("SB1",.f.)
		SB1->B1_CODBAR := oGrid:getValue( 'EAN' ,nLine)
		SB1->(msUnlock())
	endif
return

static function onDoubleClick()
	oGrid:getGrid():editCell()
	if readVar() == "M->MARKCOL"
		if oGrid:getValue("MARKCOL") == "UNCHECKED"
			oGrid:setValue("MARKCOL","CHECKED")
		else
			oGrid:setValue("MARKCOL","UNCHECKED")
		endif
		oGrid:refresh()
	endif
return

static function marcaTodos(oGrid,lMark)
	local nLine := 0

	for nLine := 1 to oGrid:length()
		oGrid:setValue("MARKCOL",if(lMark,"CHECKED","UNCHECKED"),nLine)
	next nLine
return
