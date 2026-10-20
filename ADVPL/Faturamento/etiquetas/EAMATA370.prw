#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} EAMATA370
Rotina automatica CADASTRO DE PRODUTO X CLIENTE
@author Tiago Faria
@since 27/03/2019
@version undefined
@param aAuto, array, array com os campos de cabecalho
@param nOpc, numeric, operacao a ser realizada
@type function
/*/
user function EAMATA370(aDadosSA7,nOpc)
	local lSeek		:= .T.
	local lPosaRot	:= .f.
	local aRotBkp	:= {}
	local lAltRotina:= .f.
	local aAuto		:= {}
	private INCLUI	:= nOpc == 3
	private ALTERA  := nOpc == 4
	private aRotina := FwLoadMenuDef("MATA370")

	aDadosSA7 := FwVetByDic(aDadosSA7,"SA7")
	aAdd(aAuto,{"SA7MASTER",aDadosSA7})

	if type("aRotina") == "A"
		lAltRotina := .t.
		aRotBkp := aRotina
	endif

	FwMvcRotAuto(fwLoadModel("MATA370"),"SA7",nOpc,aAuto,lSeek/*,lPosaRot*/)

	oModel 	:= FwModelActive()
	/*
	O propósito das linhas a seguir é limpar o objeto da memória para que não dê
	"Reference counter overflow ( over 32600 ) on CodeBlock assignment", erro que acontecia
	quando o ExecAuto era chamado mais de 3000x consecutivas.
	Mais informações: http://tdn.totvs.com/pages/viewpage.action?pageId=146179637
	*/
	if ValType(oModel) <> "U"
		oModel:Deactivate()
		oModel:Destroy()
		oModel:= nil
	endif

	if lAltRotina
		aRotina := aRotBkp
	endif
return
