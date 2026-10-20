#Include "Protheus.ch"

/*/{Protheus.doc}	F4LOTEHEADER
Responsável por fazer a consulta aos Saldos do 
Lotes da Rastreabilidade.EM QUE PONTO: O Ponto de 
Entrada F4LoteHeader permite manipular o cabeçalho 
a ser usado na consulta F4Lote para seleção do lote.

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					15/06/2015
@return				aRetorno
/*/
User Function F4LOTEHEADER()

	Local aRetorno		:= PARAMIXB[03]
	
	Aadd(aRetorno,"Observação Lote")
	Aadd(aRetorno,"Disp. para Venda")

Return (aRetorno)
