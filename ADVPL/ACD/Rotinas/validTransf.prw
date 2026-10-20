#Include "Protheus.ch"

/*/{Protheus.doc} validTransf
Valida a transferência do produto

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			28/07/2015
@return 		lRet
/*/
User Function validTransf()
	
// COLOCAR O TRECHO ABAIXO NO CAMPO X3_VLDUSER DO D3_COD
// IIF(ExistBlock("validTransf"),U_validTransf(),.T.)                                                                                              
	
	Local lRet			:= .T.
	Local aAreaAtu	:= GetArea()
	Local aAreaSB5	:= SB5->(GetArea())
	
	If FunName() == "MATA260" .OR. FunName() == "MATA261"
		SB5->(DbSetOrder(1)) //B5_FILIAL+B5_COD
		If SB5->(DbSeek(xFilial("SB5") + M->D3_COD))
			If SB5->B5_IMPETI == "1"
				MsgAlert("O produto " + AllTrim(M->D3_COD) + " controla etiqueta. A transferência deve ser efetuada pelo ACD.")
			EndIf
		EndIf
	EndIf
	
	RestArea(aAreaSB5)
	RestArea(aAreaAtu)
	
Return (lRet)
