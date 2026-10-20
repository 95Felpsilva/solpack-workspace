#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} A103VCTO
	Descrição TDN
		O ponto de entrada A103VCTO será utilizado para manipular as informações do array aColsSE2 utilizado na 
		geração dos títulos financeiros (Tabela SA2) no momento da inclusão do documento de entrada (MATA103).

	Descrição Monitor
		Atualização do campo E2_VENCTO conforme o parâmetro na manifestação em lote.

 @author Marcos Bortoluci
 @since 21/11/2019
 @version 1.0
 @type function
/*/
user function A103VCTO()
	local aVencto		:= {} //Array com os vencimentos e valores para geração dos títulos.
	local aColsSE2 		:= PARAMIXB[1]
	local nValorTit		:= PARAMIXB[2]
	local cCondPag		:= PARAMIXB[3]
	local nValIPI		:= PARAMIXB[4]
	local dDtEmissao	:= PARAMIXB[5]
	local nValSol		:= PARAMIXB[6]

	local dVenctoFat	:= getThreadValue("LGT01_VENCTO_FATURA")

	//Apenas executa se estiver rodando na NFLegal
	if upper(funName()) == "NFLMAINSCREEN" .OR. FwIsInCallStack("U_NFLMAINSCREEN") .OR. FwIsInCallStack("U_NFLMainScreen") .OR. FwIsInCallStack("U_NFLMai")
		if !empty(dVenctoFat)
			aadd(aVencto,{dVenctoFat, nValorTit})
		endIf
	endIf

return(aVencto)
