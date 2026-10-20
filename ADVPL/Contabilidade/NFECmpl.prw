#Include "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NFECOMPL  ºAutor  ³Donizete            º Data ³  11/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este programa tem a função de retornar informações para o  º±±
±±º          ³ histórico do lançamento padrão, geralmente LPs 650 pois    º±±
±±º          ³ nas notas de frete o sistema não grava no SD1 o número da  º±±
±±º          ³ original.                                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Usado em LPs                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function NFECOMPL()

// Variáveis utilizaas na função.
Local _xArea    := GetArea()
Local _xAreaSF8 := {}
Local _xAreaSA2 := {}
Local _cRet     := ""

If !Empty(SD1->D1_NFORI) // Caso aplicado a Complemento de Preços.

	_cRet := "COMPL.NF."+SD1->D1_NFORI+"-"

Else // Caso aplicado a notas de conhecimento de frete.

	// Posiciona no SF8 para obter dados.
	dbSelectArea("SF8")
	_xAreaSF8 := GetArea()
	dbSetOrder(3)
	dbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
	
	// Encontrando dados, monta o histórico.
	If Found()
		dbSelectArea("SA2")
		_xAreaSA2 := GetArea()
		dbSetOrder(1)
		dbSeek(xFilial("SA2")+SF8->F8_FORNECE+SF8->F8_LOJA)
		If Found()
			_cRet := "COMPL.NF."+SF8->F8_NFORIG+"/"+SubStr(SA2->A2_NREDUZ,1,10)+"-"
		EndIf

		// Restaura área de trabalho.
		RestArea(_xAreaSA2)
		
	EndIf
	
	// Restaura área de trabalho.
	RestArea(_xAreaSF8)
	
EndIf

// Restaura área de trabalho.
RestArea(_xArea)

Return(_cRet) // Retorna o histórico para o LP.
