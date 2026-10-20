#Include "Protheus.ch"

/*/{Protheus.doc} MT680EST
É chamado no estorno das produções PCP, modelo I e II. 
É utilizado para validar se pode ocorrer o estorno do apontamento ou não.

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			24/07/2015
@return 		lRet
/*/
User Function MT680EST()
	
	Local lRet			:= .T.
	
	If ExistBlock("estEtiqu")
		U_estEtiqu()
	EndIf
	
Return (lRet)
