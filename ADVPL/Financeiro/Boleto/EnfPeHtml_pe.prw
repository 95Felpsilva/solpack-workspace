#include "totvs.ch"

/*/{Protheus.doc} EnfPeHtml

PE para definição do HTML (anexo) da Geração de Boletos Bancários

@type function	
@author Diogo Mesquita
@since 15/02/2017

@param cDoc, String, Número do Documento
@param cSerie, String, Série do Documento

@return cHTML Nome do Arquivo HTML/PDF a ser considerado
/*/
User Function EnfPeHtml(cDoc, cSerie)	
	Local cHtml := "boletos_totvsip\email\boleto-"+AllTrim(cDoc)+AllTrim(cSerie)+".pdf"
	
Return cHtml