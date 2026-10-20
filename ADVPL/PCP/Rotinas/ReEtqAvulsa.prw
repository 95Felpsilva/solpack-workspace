#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} ReEtqAvulsa
Reimpressao de etiqueta Avulsa
@author Tiago Faria
@since 24/05/2019
@version 1.0
@return nil

@type function
/*/
user function ReEtqAvulsa()
	local aDados		:= {}
	local aTemp			:= {}
	local cDataHora		:= ""

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

		Aadd(aTemp,"0000469003")//Codigo de Barras
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
	local cIDParam	:= cFilAnt + "_ReEtqAvulsa_"// + GetComputerName()
	default lPerg 	:= .t.

	Aadd(aParambox,{2,"Imp. dados da empresa","SIM",{"SIM","NAO"},50,,.T.})// MV_PAR01
	aAdd(aParamBox,{1,"Produto"				,criavar("B1_COD",.f.)			,getSX3Cache("B1_COD","X3_PICTURE")		,"u_vldEtqProduto(&(readVar()))"								,"SB1"		,""		,70,.T.})
	aAdd(aParamBox,{1,"OP"					,criavar("H6_OP",.f.)			,getSX3Cache("H6_OP","X3_PICTURE")		,"Empty(&(readVar())) .or.ExistCpo('SC2',&(readVar())+alltrim(MV_PAR02))"						,"SC2TMP"	,""		,60,.T.})
	aAdd(aParamBox,{1,"Lote"				,criavar("H6_LOTECTL",.f.)		,"@!"									,"Empty(&(readVar())) .or. ExistCpo('SB8',MV_PAR02+MV_PAR03,5)"	,""			,""		,60,.F.})
	aAdd(aParamBox,{1,"Dt. Fabric"			,stod("")						,										,""																,""			,""		,60,.T.})
	aAdd(aParamBox,{1,"Hora"				,criavar("H6_HORAINI",.f.)		,getSX3Cache("H6_HORAINI","X3_PICTURE")	,""																,""			,""		,40,.T.})
	aAdd(aParamBox,{1,"Conferente"			,UsrRetName()					,										,""																,""			,".f."	,80,.F.})
	if SH6->(fieldPos("H6_ZZOPER")) > 0
		aAdd(aParamBox,{1,"Operador"		,criavar("H6_ZZOPER",.f.)		,										,"Empty(&(readVar())) .or. ExistCpo('SZZ')"						,"SZZ"		,""		,50,.T.})
	else
		aAdd(aParamBox,{1,"Operador"		,criavar("H6_OPERADO",.f.)		,										,""																,""			,""		,50,.T.})
	endif
	
	aAdd(aParamBox,{1,"Qtd. Produto"		,criavar("H6_QTDPROD",.f.)		,getSX3Cache("H6_QTDPROD","X3_PICTURE"),"positivo()"													,""			,""		,50,.T.})
	aAdd(aParamBox,{1,"Qtd. Copias"			,criavar("H6_QTDPROD",.f.)		,getSX3Cache("H6_QTDPROD","X3_PICTURE"),"positivo()"													,""			,""		,50,.T.})
	Aadd(aParambox,{1,"Local de Impressao"	,Space(TamSX3("CB5_CODIGO")[1])	,""									   ,"Empty(&(readVar())) .or. ExistCpo('CB5')"						,"CB5"		,""		,60,.T.})

	if lPerg
		lRet := ParamBox(aParamBox,"Etiqueta Avulsa",NIL,,,,,,,cIDParam,.T.,.T.)
	else
		for nI := 1 to len(aParambox)
			&("MV_PAR"+strzero(nI,2)) := ParamLoad(__cUserID+"_"+cIDParam,aParamBox,nI,aParamBox[nI,3])
		next nI
	endif

	if lRet
		lCabecalho 	:= MV_PAR01 == "SIM"
		cProduto 	:= MV_PAR02
		cDescProd	:= Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
		cOP			:= MV_PAR03
		cLote		:= MV_PAR04
		dDtFabri	:= MV_PAR05
		cHora		:= MV_PAR06
		cConferente	:= MV_PAR07
		cOperador	:= MV_PAR08		
		nQtd		:= MV_PAR09
		nQtdCopia	:= MV_PAR10
		cLocalImp	:= MV_PAR11
	endif
return lRet

user function vldEtqProduto(cProduto)
	local lRet := .t.
	
	lRet := empty(cProduto) .or. ExistCpo('SB1')
	
	if  lRet
		nQE := posicione("SB1",1,xFilial("SB1")+cProduto,"B1_QE")
		MV_PAR09 := nQE
	endif
return lRet
