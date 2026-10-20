#include "totvs.ch"

/*/{Protheus.doc} BolPeHtml

PE para definição do HTML (anexo) da Geração de Boletos Bancários

@type function	
@author Victor Hugo
@since 05/08/2014

@param cPrefixo, String, Parcela do Título
@param cNumero, String, Número do Tìtulo
@param cParcela, String, Parcela do Título
@param cTipo, String, Tipo do Título

@return cHTML Nome do Arquivo HTML/PDF a ser considerado
/*/
User Function BolPeHtml(cPrefixo, cNumero, cParcela, cTipo)	
	Local cHtml := "boletos_totvsip\email\boleto-"+AllTrim(cPrefixo)+AllTrim(cNumero)+AllTrim(cParcela)+AllTrim(cTipo)+".pdf"
	
Return cHtml