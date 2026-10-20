#Include "Protheus.ch"

/*/{Protheus.doc}	EditCpoMult
Função que valida se o campo de multiplos na tela de
apontamento de OP deve pode ser editado ou não

@author			Julio Lisboa - FSW TOTVS IP Campinas
@since				29/06/2015
@return			lRet
/*/
User Function EditCpoMult()
	Local lRet			:= .T.
	Local aAreaAtu	:= GetArea()
	Local aAreaSB1	:= SB1->(GetArea())
	Local cCampo	:= "M->H6_PRODUTO"
	Local cFunName	:= FunName() 

	if cFunName == "APCODBAR"
		cCampo := "FwFldGet('H6_PRODUTO')"
	endif
	
	If cFunName $ "MATA681/APCODBAR" .and. (INCLUI .OR. ALTERA)
		lRet := .F.
		SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
		If SB1->(DbSeek(xFilial("SB1") + &(cCampo)))
			If SB1->B1_QE > 0
				lRet := .T.
			EndIf
		EndIf
	EndIf
	lRet := lRet .and. cFunName $ "MATA681/APCODBAR"
	RestArea(aAreaSB1)
	RestArea(aAreaAtu)
Return (lRet)
