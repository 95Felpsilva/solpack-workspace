#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} setConta
Atribui ao campo D1_CC o valor da conta contabil, de acordo com o campo recebido por parametro
@author tiago
@since 28/08/2018
@version undefined
@param cField, characters, Campo a ser avaliado para setar a conta
@type function
/*/
user function setConta(cFieldConta,lAvalCC)
	local cConta 		:= criavar("B1_CONTA",.f.)
	local lRet	 		:= .t.
	local cMsg			:= ""
	local cSolucao		:= ""
	local cField 		:= ""
	default cFieldConta	:= ""
	default lAvalCC		:= .t.

	BEGIN SEQUENCE
		if lAvalCC
			if CTT->(eof())
				cMsg 		:= "Centro de custo não informado!"
				cSolucao	:= "Preencha o campo '" + alltrim(getSX3Cache("D1_CC","X3_TITULO")) + "' para continuar!"
				BREAK	
			else
				cConta := u_getConta(CTT->CTT_CUSTO,SB1->B1_COD)

				if len(cConta) > getSX3Cache("B1_CONTA","X3_TAMANHO")
					cMsg 		:= cConta
					cSolucao 	:= "Preencha o campo informado para continuar!" 
					BREAK
				endif
			endif
		else
			cConta := &(getSX3Cache("B1_CONTA","X3_ARQUIVO")+"->B1_CONTA")
			cField := "B1_CONTA"
		endif

		If EMPTY(cConta)
			cMsg 		:= "Cadastro do Produto: '" + AllTrim(SB1->B1_COD) + "' esta sem '" + alltrim(getSX3Cache(cField,"X3_TITULO"))  + "'"
			cSolucao	:= "Preencha o campo '" + alltrim(getSX3Cache(cField,"X3_TITULO")) + "' para o produto " + AllTrim(SB1->B1_COD) + " para continuar!"  
			BREAK
		else
			gdFieldPut(cFieldConta,cConta)
		EndIf

		RECOVER
		u_myHelp(cMsg,cSolucao)
		lRet := .F.
	END SEQUENCE
return lRet

user function getConta(cCusto,cProduto)
	local cConta := ""
	local aArea	 := Lj7GetArea({"SB1","CTT"})
	local cField := ""
	if CTT->CTT_CUSTO <> cCusto
		posicione("CTT",1,xFilial("CTT")+cCusto,"!Eof()")
	endif

	if SB1->B1_COD <> cProduto
		posicione("SB1",1,xFilial("SB1")+cProduto,"!Eof()")
	endif
	
	if Alltrim(CTT->CTT_ZZTPCC) == '3'//"CUSTO"
		cConta := SB1->B1_ZZCTAC
		cField := "B1_ZZCTAC"
	ElseIf Alltrim(CTT->CTT_ZZTPCC) == '1'//"DESPESA"
		cConta := SB1->B1_ZZCTAD
		cField := "B1_ZZCTAD"
	ElseIf Alltrim(CTT->CTT_ZZTPCC) == '2'//"COMERCIAL"
		cConta := SB1->B1_ZZCTAA
		cField := "B1_ZZCTAA"
	else
		cConta := "Centro de Custo sem '" + alltrim(getSX3Cache("CTT_ZTPCC","X3_TITULO"))  + "' (CTT_ZTPCC)"
	endif
	
	if empty(cConta)
		cConta := "Cadastro do Produto: '" + AllTrim(SB1->B1_COD) + "' esta sem o campo '" + alltrim(getSX3Cache(cField,"X3_TITULO"))  + "' preenchido"
	endif
	
	Lj7RestArea(aArea)
return cConta
