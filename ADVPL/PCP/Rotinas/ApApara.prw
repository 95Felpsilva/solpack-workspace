#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} ApApara
Apontamento de apara
@author Tiago Faria
@since 06/06/2019
@version 1.0
@return nil

@type function
/*/
user function ApApara()
	local aCoords	:= FWGetDialogSize( oMainWnd )
	local oDlg		:= nil
	local cQuery	:= getQuery()
	local bOK		:= {||FWMsgRun( ,{ || oDlg:end(),lOK := EAMata241() } ,"AP APARA", "Aguarde realizando o apontamento de apara"  )}
	local bCancel	:= {||oDlg:end()}
	local aButtons	:= {}
	local lOK		:= .t.
	private oGrid	:= nil
	private lApara	:= getNewPar("ZZ_ISAPARA",.T.) 
	
	if !lApara
		return lOK
	endif
	
	Define MsDialog oDlg Title "Apontamento de Apara"  From aCoords[1], aCoords[2] to aCoords[3]*0.60, aCoords[4]*0.60 Pixel
	/*
	Timer necessário para  fechar a tela automaticamente quando não há nenhum item para apontamento de apara.
	Pois estava apenas fazendo um if() para nao ativar a tela e o sistema estava travando, com o timer o problema não ocorre.
	Provavelmente é algum problema de lib.
	*/
	oTimer := TTimer():New(250, {|| if(isFechaTela(),oDlg:end(),.t.) }, oDlg )
	oTimer:Activate()

	oGrid := IpGridObject():newIpGridObject(0,0,0,0, oDlg)

	oGrid:setAccessMode("update")
	oGrid:addSqlColumns(cQuery)
	aColumns := oGrid:getColumns()

	for nColumn := 1 to len(aColumns)
		cColumn := aColumns[nColumn]:getID()
		oGrid:getColumn(cColumn):setReadOnly(.t.)
	next nColumn

	oGrid:getColumn('QTD'):setReadOnly(.f.)
	oGrid:getColumn('QTD'):setPicture(getSX3Cache("D3_QUANT","X3_PICTURE"))
	oGrid:getColumn('QTD'):setValidation("Positivo()")

	oGrid:create()
	oGrid:getGrid():oBrowse:align := CONTROL_ALIGN_ALLCLIENT
	Activate MsDialog oDlg Center on init EnchoiceBar( oDlg, bOK,bCancel,,aButtons,,,.f.,.f.,.f.,,.f.)
return lOK

static function getQuery()
	local cQuery := ""
	local cAlias := ""

	cQuery += "SELECT" + CRLF
	cQuery += "	0 AS QTD," + CRLF
	cQuery += "	G1_COMP," + CRLF
	cQuery += "	B1_DESC," + CRLF
	cQuery += "	B1_UM" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SG1") + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("SB1") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND B1_COD = G1_COMP" + CRLF
	cQuery += "	AND SB1.D_E_L_E_T_ <> '*'" + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND G1_COD = '" + M->H6_PRODUTO + "'" + CRLF
	cQuery += "	AND G1_QUANT < 0" + CRLF
	cQuery += "	AND SG1.D_E_L_E_T_ <> '*'" + CRLF
return cQuery

static function EAMata241()
	local nLine  	:= 0
	local cTM	 	:= getNewPar("ZZ_TMAPARA","130")
	local aCabec	:= {}
	local aItens 	:= {}
	local aAux	 	:= {}
	local nQtd		:= 0
	local cProduto	:= ""
	local cUM		:= ""
	private lMsErroAuto := .f.

	aAdd(aCabec,{"D3_TM"		,cTM		,nil})
	aAdd(aCabec,{"D3_EMISSAO"	,dDataBase	,nil})

	for nLine := 1 to len(oGrid:getLines())
		nQtd := oGrid:getValue('QTD',nLine)

		if nQtd > 0
			cProduto 	:= oGrid:getValue('G1_COMP',nLine)
			cUM			:= oGrid:getValue('B1_UM',nLine)

			aAdd(aAux,{"D3_COD"		,cProduto			,nil})
			aAdd(aAux,{"D3_UM"		,cUM				,nil})
			aAdd(aAux,{"D3_QUANT"	,nQtd				,nil})
			aAdd(aAux,{"D3_OP"		,M->H6_OP			,nil})
			aAdd(aAux,{"D3_LOCAL"	,M->H6_LOCAL		,nil})
			aAdd(aAux,{"D3_LOTECTL"	,M->H6_LOTECTL		,nil})		

			aAux := FwVetByDic(aAux,"SD3")

			aAdd(aItens,aAux)
			aAux := {}
		endif
	next nLine

	if len(aItens) > 0
		MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aItens,3)

		if lMsErroAuto
			mostraErro()
			u_myHelp("Erro ao requisitar Apara contra OP!")
		endif
	endif
return !lMsErroAuto

static function isFechaTela()	
return len(oGrid:getLines()) > 0 .and. empty(oGrid:getValue("G1_COMP",1))