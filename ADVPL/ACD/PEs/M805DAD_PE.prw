#Include "Protheus.ch"

/*/{Protheus.doc} M805DAD
O ponto de entrada M805DAD permite que o cliente/usuário 
manipule os vetores aCols[] e aHeader[] de acordo com a 
sua necessidade. É permitido alterar a ordem, incluir ou 
excluir campos das colunas, por exemplo.

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			17/07/2015
@return 		nil
/*/
User Function M805DAD()
	
	If ExistBlock("CriaSldEndereco")
		U_CriaSldEndereco()
	EndIf
	
Return
