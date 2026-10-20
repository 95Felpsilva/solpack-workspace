#Include "Protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AUXCT5    ºAutor  ³J.Donizete R.Silva  º Data ³  19/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este programa tem a função de auxiliar a contabilização    º±±
±±º          ³ e elminando a necessidade de aumentar os campos do CT5     º±±
±±º          ³ para mais de 200 caracteres.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa utilizados nos LPs. Parâmetros:                   º±±
±±º          ³ _cLP     : código do LP, exemplo "530"                     º±±
±±º          ³ _cSeq    : sequencia do LP, exemplo "001"                  º±±
±±º          ³ _cCampo  : campo a ser tratado, exemplo "CT5_VLR01"        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºData      ³ Alterações                                                 º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±º11/08/07  ³ Alteração no tratamento do LP 530 quando for uma baixa ge- º±±
±±º          ³rada por fatura.                                            º±±
±±º28/02/08  ³ Melhorado a questão ref. a restauração de áreas.           º±±
±±º          ³                                                            º±±
±±º          ³ Incorporado os LPs enviados pelo Vitor que contabilizam a  º±±
±±º          ³retenção de PIS/COFINS/CSLL no LP 620.                      º±±
±±º          ³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function AuxCt5(_cLP,_cSeq,_cCampo)

// Variáveis usadas pelo programa.
Local _xVal
Local _xArea 	:= GetArea()

Local _nVlCof  	:= 0
Local _nVlPis  	:= 0
Local _nVlCsl  	:= 0

Public _xAreaSE1 := {}
Public _xAreaSE2 := {}
Public _xAreaSE5 := {}

_cCampo := Upper(Alltrim(_cCampo))

// Processamento para retorno de informações para os LPs.

If _cLP == "511" .And. _cSeq == "001" .And. _cCampo == "CT5_HIST"
	
	// Posiciona no registro de rateio.
	DbSelectArea("SE2")
	_xAreaSE2 := GetArea()
	nRecAnt := Recno()
	DbGoto(STRLCTPAD)
	
	// Monta o histórico.
	_xVal := "A PAGAR " + SE2->(E2_PREFIXO+ "/" + E2_NUM + "-" + SE2->E2_NOMFOR)
	
	//Restaura área.
	DBGOTO(nRecAnt)
	RestArea(_xAreaSE2)
	
ElseIf _cLP == "520" .And. _cSeq == "XXX" .And. _cCampo == "CT5_VLR01"
	// Colaboração do João Marcondes
	R520SE1("PI-",@_xRet)
	
ElseIf _cLP == "520" .And. _cSeq == "XXX" .And. _cCampo == "CT5_VLR01"
	// Colaboração do João Marcondes
	R520SE1("CF-",@_xRet)
	
ElseIf _cLP == "520" .And. _cSeq == "XXX" .And. _cCampo == "CT5_VLR01"
	// Colaboração do João Marcondes
	R520SE1("CS-",@_xRet)
	
ElseIf _cLP == "530" .And. _cSeq == "001" .And. _cCampo == "CT5_VLR01"
	_xRet := IiF(!SE5->E5_MOTBX$"DAC,DEV,VEN,CHQ".AND.!SE5->E5_TIPO$"PA ".AND. ;
	!EMPTY(SE5->E5_MOEDA).AND.!SA2->A2_ZZTP$ALLTRIM(TABELA("Z@","ZA1",.F.)).AND.;
	SE5->E5_RECPAG=="P",SE5->(E5_VALOR-E5_VLJUROS-E5_VLMULTA+E5_VLDESCO-E5_VLCORRE),0)
	
	If Type("CFATURA")=="C" .Or. Type("CFATCAN")=="C" .Or. !Empty(SEF->EF_OK)
		_xRet := 0
	EndIf
	
ElseIf _cLP == "530" .And. _cSeq == "002" .And. _cCampo == "CT5_VLR01"
	_xRet := IiF(!SE5->E5_MOTBX$"DAC,DEV,VEN,CHQ".AND.SE5->E5_TIPO<>"PA ".AND.;
	EMPTY(SE5->E5_MOEDA).AND.!ALLTRIM(SE5->E5_NATUREZ)$TABELA("Z@","ZA2",.F.).AND.;
	SA2->A2_ZZTP==TABELA("Z@","ZA5",.F.),SE5->(E5_VALOR-E5_VLJUROS-E5_VLMULTA+E5_VLDESCO-E5_VLCORRE),0)
	
	If Type("CFATURA")=="C" .Or. Type("CFATCAN")=="C"
		_xRet := 0
	EndIf
	
ElseIf _cLP == "530" .And. _cSeq == "003" .And. _cCampo == "CT5_VLR01"
	_xRet := IiF(!SE5->E5_MOTBX$"DAC,DEV,VEN,CHQ".AND.SE5->E5_TIPO<>"PA ".AND.;
	EMPTY(SE5->E5_MOEDA).AND.ALLTRIM(SE5->E5_NATUREZ)$TABELA("Z@","ZA3",.F.).AND.;
	TABELA("Z@","ZA5",.F.),SE5->(E5_VALOR-E5_VLJUROS-E5_VLMULTA+E5_VLDESCO-E5_VLCORRE),0)
	
	If Type("CFATURA")=="C" .Or. Type("CFATCAN")=="C"
		_xRet := 0
	EndIf
	
ElseIf _cLP == "530" .And. _cSeq == "004" .And. _cCampo == "CT5_VLR01"
	_xRet := IiF(!SE5->E5_MOTBX$"DAC,DEV,VEN,CHQ".AND.SE5->E5_TIPO<>"PA ".AND.EMPTY(SE5->E5_MOEDA).AND.;
	ALLTRIM(SE5->E5_NATUREZ)$TABELA("Z@","ZA4",.F.).AND.TABELA("Z@","ZA5",.F.),;
	SE5->(E5_VALOR-E5_VLJUROS-E5_VLMULTA+E5_VLDESCO-E5_VLCORRE),0)
	
	If Type("CFATURA")=="C" .Or. Type("CFATCAN")=="C"
		_xRet := 0
	EndIf
	
ElseIf _cLP == "991" .And. _cSeq == "001" .And. _cCampo == "CT5_VLR01"
	IIF(Substr(SW9->W9_INVOICE,1,1)#"*",xMoeda(SW9->W9_FOB_TOT+SW9->W9_INLAND+SW9->W9_PACKING+;
	SW9->W9_FRETEIN-SW9->W9_DESCONT+SW9->W9_SEGURO,SimbToMoeda(SW9->W9_MOE_FOB),1,;
	SW6->W6_DT_DESE,,SW6->W6_TX_FOB),0)
	
ElseIf _cLP == "620" .And. _cSeq == "001" .And. _cCampo == "CT5_VLR01"
	// Colaboração do Vitor Fattori
	
	DbSelectArea("SE1")
	_xAreaSE1 := GetArea()
	DbSetOrder(1)
	DbSeek(xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC+" "+"PI-")
	If Found()
		_nVlPis := SE1->E1_VALOR
	Endif
	
	DbSeek(xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC+" "+"CF-")
	If Found()
		_nVlCof := SE1->E1_VALOR
	Endif
	
	DbSeek(xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC+" "+"CS-")
	If Found()
		_nVlCsl := SE1->E1_VALOR
	Endif
	
	_xRet := SF2->F2_VALFAT
	_xRet -= (_nVlPis+_nVlCof+_nVlCsl)
	_xRet -= (SF2->F2_VALINSS+SF2->F2_VALIRRF)
	_xRet -= IF(SF2->F2_RECISS=="1",SF2->F2_VALISS,0)
	
	//Restaura área de trabalho.
	RestArea(_xAreaSE1)
	
ElseIf _cLP == "620" .And. _cSeq == "002" .And. _cCampo == "CT5_VLR01"
	// Colaboração do Vitor Fattori
	R620SE1("PI-",@_xRet)
	
ElseIf _cLP == "620" .And. _cSeq == "003" .And. _cCampo == "CT5_VLR01"
	// Colaboração do Vitor Fattori
	R620SE1("CF-",@_xRet)
	
	
ElseIf _cLP == "620" .And. _cSeq == "004" .And. _cCampo == "CT5_VLR01"
	// Colaboração do Vitor Fattori
	R620SE1("CS-",@_xRet)
	
EndIf

//Restaura área de trabalho.
RestArea(_xArea)

Return(_xRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R620SE1   ºAutor  ³Microsiga           º Data ³  28/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para retornar retenção gerada pelo faturamento.   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ lançamento Padrão.                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R620SE1(_cTipo,_xRet)

DbSelectArea("SE1")
_xAreaSE1 := GetArea()
DbSetOrder(1)
DbSeek(xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC+" "+_cTipo)
If Found()
	_xRet := SE1->E1_VALOR
Endif

RestArea(_aAreaSE1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R520SE1   ºAutor  ³Microsiga           º Data ³  28/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para retornar retenção gerada na baixa de títulos º±±
±±º          ³ a receber                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lançamento Padrão.                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R520SE1(_cTipo,_xRet)

DbSelectArea("SE5")
_xAreaSE5 := GetArea()

DbSelectArea("SE1")
_xAreaSE1 := GetArea()
DbSetOrder(1)
DbGoTop()
DbSeek(xFilial("SE1")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+_cTipo)
While !eof().AND.(SE1->E1_PREFIXO==SE5->E5_PREFIXO.AND.SE1->E1_NUM==SE5->E5_NUMERO.AND.;
	SE1->E1_PARCELA==SE5->E5_PARCELA.AND.SE1->E1_TIPO==_cTipo)
	IF SE1->E1_EMISSAO>=CTOD('01/01/07')
		_xRet += SE1->E1_VALOR
	ENDIF
	DBskip()
EndDo

RestArea(_aAreaSE1)
RestArea(_aAreaSE5)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ZArroba   ºAutor  ³Donizete            º Data ³  28/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este programa permite o uso da função tabela juntamente comº±±
±±º          ³ a execução de macros do Clipper. Retorna dados para os LPs.º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LPs que usam contas de despesas/receitas financeiras.      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºData      ³ Alterações                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±º26/02/08  ³ Correção de nome de variável.                              º±±
±±º          ³                                                            º±±
±±º28/02/08  ³ Alterado lógica para possibilitar retorno correto da variá-º±±
±±º          ³ vel.                                                       º±±
±±º          ³                                                            º±±
±±º          ³ Incorporado ao AUXCT5.                                     º±±
±±º          ³                                                            º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ZArroba(_cChave)

// Variáveis usadas pelo programa.
Local _cRet
Local _xArea   	:= GetArea()
Local _xAreaSX5	:= SX5->(GetArea())

// Verifica se é para executar uma macro executável.
If SubStr(Tabela("Z@",_cChave,.F.),1,1) == "&"
	_cRet := &(SubStr(Tabela("Z@",_cChave,.F.),2,Len(Tabela("Z@",_cChave,.F.))-1))
EndIf

// Restaura áreas.
RestArea(_xAreaSX5)
RestArea(_xArea)

Return(_cRet)
