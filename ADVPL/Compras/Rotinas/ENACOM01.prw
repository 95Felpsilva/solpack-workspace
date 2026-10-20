#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} ENACOM01
Validação de linha do documento de entrada
@author Tiago Faria
@since 04/07/2018
@version undefined
@see MT100LOK
@type function
/*/
user function ENACOM01()
	local aArea			:= Lj7GetArea({"SF4","SB1","CTT","SC2"})
	local lRet 			:= .t.
	local cMsg			:= ""
	local cSolucao		:= ""
	local cField		:= ""
	local lCtrEstoq		:= .f.
	local lCC			:= .t.
	local lEstoque		:= .t.
	private lAtivoFixo	:= .f.
	private lMatConsEst	:= .f.
	private lMatPrima	:= .f.
	private lOutros		:= .f.
	private lRateio		:= isInCallStack("U_NFEINICC")
	if type("cTipo") == "U"
		cTipo := "N"
	endif
	
	If isLineNotDel()
		POSICIONE("SF4",1,xFilial("SF4")+getValue("D1_TES"),"!EOF()")
		POSICIONE("SB1",1,xFilial("SB1")+getValue("D1_COD"),"!EOF()")
		POSICIONE("CTT",1,xFilial("CTT")+getValue("D1_CC"),"!EOF()")
		POSICIONE("SC2",1,xFilial("SC2")+getValue("D1_OP"),"!EOF()")
		
		//if cTipo == "B"
		//	lRet := u_ENACOM12()
		//endif
		
		if lRet .and. isRateioOK() .and. isNotRateio()

			lAtivoFixo 	:= alltrim(SB1->B1_TIPO) $ supergetMV("ZZ_TPPRDAT",,"AI")
			lMatConsEst	:= alltrim(SB1->B1_TIPO) $ supergetMV("ZZ_TPPRDMC",,"")
			lMatPrima	:= alltrim(SB1->B1_TIPO) $ supergetMV("ZZ_TPPRDMP",,"MP/PI/PA/SA")
			lSVI		:= alltrim(SB1->B1_TIPO) $ supergetMV("ZZ_TPPRDSV",,"BN") .and. SF4->F4_ESTOQUE == "S" .AND. cTipo == "N" .AND. SF4->F4_DUPLIC == "S"
			lOutros		:= !lMatConsEst .and. !lMatPrima .and. !lAtivoFixo .and. !lSVI

			if lAtivoFixo
				lEstoque := SF4->F4_ESTOQUE == 'N'
				lCC		 := .t.
				lCtrEstoq:= .f.
				if SF4->F4_PODER3 == 'N'
					lRet := u_setConta("D1_CONTA",.f.)
				endif
			endif

			if lMatConsEst
				limpaCC()
				lEstoque := SF4->F4_ESTOQUE == 'S'
				lCC		 := Empty(getValue("D1_CC"))
				lCtrEstoq:= .t.
				lRet := u_setConta("D1_CONTA",.F.)
			endif

			if lMatPrima
				limpaCC()
				lEstoque := SF4->F4_ESTOQUE == 'S'
				lCC		 := Empty(getValue("D1_CC"))
				lCtrEstoq:= .t.

				lRet := u_setConta("D1_CONTA",.F.)

				if lRet .and. (subStr(getValue("D1_CF"),1,1) == "3" .OR. IsInCallStack('mata119')     )  //ALTERADO JONI
					gdFieldPut("D1_CONTA","11204010002")
				endif
			endif

			if lOutros
				lEstoque := SF4->F4_ESTOQUE == 'N'
				lCtrEstoq:= .f.
				
				if SF4->F4_PODER3 == 'N'
					lRet 	 := u_setConta("D1_CONTA",.T.)
					lCC		 := !Empty(getValue("D1_CC"))
				else
					lCC		 := .t.
				endif
			endif

			if lSVI
				limpaCC()
				lRet := u_setConta("D1_CONTA",.F.)
				if lRet .and. empty(getValue("D1_OP"))
					cMsg 		:= "Campo '" + alltrim(getSX3Cache("D1_OP","X3_TITULO")) + "' vazio."
					cSolucao 	:=  "Preencha o campo '" + alltrim(getSX3Cache("D1_OP","X3_TITULO")) + "' para continuar!"
					u_myHelp(cMsg,cSolucao)
					lRet := .f.
				endif

				If lRet .and. Alltrim(getValue("D1_COD")) == Alltrim(SC2->C2_PRODUTO)
					cMsg 		:= "Produto da NF é o mesmo da OP."
					cSolucao 	:= "Digite um produto diferente do produto da OP!"
					u_myHelp(cMsg,cSolucao)
					lRet := .F. 
				Endif
			endif

			if lRet .and. !lCC
				cMsg 		:= "Centro de Custo obrigatório"
				cSolucao 	:= "Preencha o campo '" + alltrim(getSX3Cache("D1_CC","X3_TITULO")) + "' para continuar!"
				u_myHelp(cMsg,cSolucao)

				lRet := .f.		
			endif

			if lRet .and. !lEstoque
				cMsg 		:= "TES utilizada " + if(lCtrEstoq,"deve","não deve") + " controlar estoque"
				if lCtrEstoq .and. lRateio
					cMsg += " e não pode sofrer RATEIO por CENTRO DE CUSTO"
				endif
				cSolucao 	:= "Digite uma TES que " + if(lCtrEstoq,"controle","não controle") + " estoque" + " para continuar!"
				u_myHelp(cMsg,cSolucao)

				lRet := .f.				
			endif
		endif
	endif

	Lj7RestArea(aArea)
return lRet
/*
Valida se a linha posicionada não esta deletada
*/
static function isLineNotDel()
return !aCols[n][Len(aCols[n])]
/*
Valida se a NF não esta sendo rateada.
*/
static function isNotRateio()
return getValue("D1_RATEIO") == "2"
/*
Limpa o conteudo do campo centro de custo D1_CC
*/
static function limpaCC()
	gdFieldPut("D1_CC",criavar("D1_CC",.F.))
return
/*
Valida se a nota esta com o flag para ser rateada
*/
static function isRateioOK()
	local lRet := .t.

	if lRateio
		lRet := SF4->F4_ESTOQUE == 'N'

		if !lRet
			u_myHelp("Para itens que a TES controla estoque, não é possível realizar o rateio por CENTRO DE CUSTO!")
		endif
	endif
return lRet

static function getValue(cField)
	local xRet := nil
	local cMacro := "M->" + cField
	if type(cMacro) == "U"
		xRet := gdFieldGet(cField)
	else
		xRet := &(cMacro)
	endif
return xRet
