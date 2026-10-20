#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT410TOK
Este ponto de entrada é executado ao clicar no botão OK e pode ser usado para validar a confirmação das operações: incluir,  alterar, copiar 
e excluir.Se o ponto de entrada retorna o conteúdo .T., o sistema continua a operação, caso contrário, volta para a tela do pedido.
@author Tiago Faria
@since 02/04/2018
@version undefined

@type function
/*/
user function MT410TOK()
	local lRet := .t.
	//local nOpc := PARAMIXB[1]
	private aRecnoSE1RA := PARAMIXB[2]
	private nTotAdt := 0
	
	aEval(aRecnoSE1RA,{|X|nTotAdt+=X[3]})
	
	setThreadValue("TOTAL_RA_PV",nTotAdt)

	u_recalcPesoPV()

	if isIncluiPV() .or. isAlteraPV()
		if existBlock("vldAltPV")
			lRet := u_vldAltPV()
		endif

		if lRet .and. existBlock("vldCondPg")
			lRet := u_vldCondPg()
		endif

		if lRet .and. existBlock("vldVlrDtEntrega")
			lRet := u_vldVlrDtEntrega()
		endif
	endif

	if isDeletePV() .and. existBlock("BolAntecipDel")
		oBol := BolAntecipDel():new()
		lRet := oBol:deletaTitulo(SC5->C5_NUM)
		if !lRet
			u_myHelp("Erro ao excluir títulos referente a pagamento de boleto antecipado!")
		endif
	endif
return lRet

static function isDeletePV()
return !INCLUI .and. !ALTERA

static function isAlteraPV()
return ALTERA

static function isIncluiPV()
return INCLUI
