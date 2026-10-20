#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} EACTBA020
Rotina automatica cadastro de conta contabil
@author Tiago Faria
@since 27/03/2019
@version undefined
@param aAuto, array, array com os campos de cabecalho
@param nOpc, numeric, operacao a ser realizada
@type function
/*/
user function EACTBA020(aDadosCT1,nOpc,aDadosCVD,aDadosCTS)
	local lSeek		:= .T.
	//local lPosaRot	:= .f.
	local aRotBkp	:= {}
	local lAltRotina:= .f.
	local aAuto		:= {}
	private aRotina := FwLoadMenuDef("CTBA020")
	default aDadosCVD := {}
	default aDadosCTS := {}


	aDadosCT1 := FwVetByDic(aDadosCT1,"CT1")
	aAdd(aAuto,{"CT1MASTER",aDadosCT1})

	if len(aDadosCVD) > 0
		aDadosCVD := FwVetByDic(aDadosCVD,"CVD",.t.)
		aAdd(aAuto,{"CVDDETAIL",aDadosCVD})
	endif

	if len(aDadosCTS) > 0
		aDadosCTS := FwVetByDic(aDadosCTS,"CTS",.t.)
		aAdd(aAuto,{"CTSDETAIL",aDadosCTS})
	endif

	if type("aRotina") == "A"
		lAltRotina := .t.
		aRotBkp := aRotina
	endif

	FwMvcRotAuto(fwLoadModel("CTBA020"),"CT1",nOpc,aAuto,lSeek/*,lPosaRot*/)

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
