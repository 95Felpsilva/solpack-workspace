#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} ReEtqProd
Reimpressao de etiquetas para troca de produto
@author Tiago Faria
@since 24/05/2019
@version 1.0
@return nil

@type function
/*/
user function ReEtqProd()
	local aDados		:= {}
	local aTemp			:= {}
	
	private lCabecalho 	:= .t.
	private cProduto 	:= ""
	private cDescProd	:= ""
	private cOP			:= ""
	private dDtFabri	:= stod("")
	private cHora		:= ""
	private cConferente	:= ""
	private cOperador	:= ""
	private nQtd		:= 0
	private nQtdCopia	:= 0
	private cLocalImp	:= ""
	private cLote		:= ""
	private cRecurso	:= ""
	if ask()
		cDataHora := dtoc(dDtFabri) + " - " + alltrim(cHora)

		Aadd(aTemp,"")			//Codigo de Barras
		Aadd(aTemp,cProduto)	//Produto
		Aadd(aTemp,cLote)		//Lote
		Aadd(aTemp,cDescProd)	//Descrição Produto
		Aadd(aTemp,cDataHora)	//Data Apontamento
		Aadd(aTemp,cConferente)	//Conferente
		Aadd(aTemp,cRecurso)	//Recurso
		Aadd(aTemp,cOP)			//Ordem de Produção
		Aadd(aTemp,0)			//Peso
		Aadd(aTemp,nQtd)		//Quant Etiqueta
		Aadd(aTemp,cOperador)	//Operador
		Aadd(aDados,aTemp)
		
		If !CB5SetImp(cLocalImp)
			MsgStop("Problemas no local de impressão!")
			return
		EndIf
	
		U_EtqOrPrd(lCabecalho,aDados,nQtdCopia)		
	endif
return

static function ask(lPerg)
	local lRet 		:= .t.
	local aParamBox := {}
	local nI		:= 0
	local cIDParam	:= cFilAnt + "_ReEtqProd_" + GetComputerName()
	default lPerg 	:= .t.

	Aadd(aParambox,{2,"Imp. dados da empresa","SIM",{"SIM","NAO"},50,,.T.})// MV_PAR01
	aAdd(aParamBox,{1,"Produto"				,criavar("B1_COD",.f.)			,getSX3Cache("B1_COD","X3_PICTURE")		,"Empty(&(readVar())) .or. ExistCpo('SB1')"			,"SB1"		,""		,70,.T.})
	aAdd(aParamBox,{1,"Qtd. Produto"		,criavar("H6_QTDPROD",.f.)		,getSX3Cache("H6_QTDPROD","X3_PICTURE"),"positivo()"										,""			,""		,50,.T.})
	aAdd(aParamBox,{1,"Qtd. Copias"			,criavar("H6_QTDPROD",.f.)		,getSX3Cache("H6_QTDPROD","X3_PICTURE"),"positivo()"										,""			,""		,50,.T.})
	Aadd(aParambox,{1,"Local de Impressao"	,Space(TamSX3("CB5_CODIGO")[1])	,""									   ,"Empty(&(readVar())) .or. ExistCpo('CB5')"			,"CB5"		,""		,60,.T.})

	if lPerg
		lRet := ParamBox(aParamBox,"Etiqueta Troca Produto",NIL,,,,,,,cIDParam,.F.,.F.)
	else
		for nI := 1 to len(aParambox)
			&("MV_PAR"+strzero(nI,2)) := ParamLoad(__cUserID+"_"+cIDParam,aParamBox,nI,aParamBox[nI,3])
		next nI
	endif

	if lRet
		lCabecalho 	:= MV_PAR01 == "SIM"
		cProduto 	:= MV_PAR02
		nQtd		:= MV_PAR03
		nQtdCopia	:= MV_PAR04
		cLocalImp	:= MV_PAR05
		cDescProd	:= Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
		cOP			:= ""//SH6->H6_OP
		cLote		:= ""//SH6->H6_LOTECTL
		dDtFabri	:= date()
		cHora		:= time()
		cConferente := UsrRetName()
		if SH6->(fieldPos("H6_ZZOPER")) > 0
			cOperador	:= SH6->H6_ZZOPER
		endif
	endif
return lRet