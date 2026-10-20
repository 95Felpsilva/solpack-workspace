#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "MsObject.ch"
#Include "RwMake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

#Define COLUNA_1		540							
#Define COLUNA_2		880
#Define COLUNA_3		1130
#Define COLUNA_4		1380
#Define COLUNA_5		1850
#Define ALTURA_CABEC	80
#Define ALTURA_CAMPOS	80
#Define ALTURA_SACADO	210
#Define LARG_PONT		20
#Define ESP_PONT		20 
#Define ALIN_ESQ		0 
#Define ALIN_DIR		1  
#Define ALIN_CEN		2
#Define MARGEM_ESQ		50
#Define MARGEM_DIR	 	2300
#Define PIC_DATAS		"dd/mm/yyyy"

/*/{Protheus.doc} ImpBolCofe

Impressão de Boletos COFEMA

@type function
@author Victor Hugo
@since 29/07/2014

@param oBol, BoletosProtheus, Objeto de Geração de Boletos TOTVS IP
@param cHtml, String, PDF a ser gerado
/*/
User Function ImpBolCofe(oBol,cPdf)	

	if Empty(cPdf)
		u_ProcImpBol(oBol)
	else
		geraBoletoPdf(oBol, cPdf)
	endIf

Return

/*
Geração do Boleto em PDF para quando estiver via Job
*/
Static Function geraBoletoPdf(oBol, cPdf)	
	Local nI 		 := 0		     
	Local nTotTit	 := 0
	Local nTitAtu	 := 0
	Local cPrefixo	 := ""
	Local cNumero	 := ""
	Local cParcela	 := ""
	Local cTipo		 := ""
	Local cTempPdf	 := ""
	Local cUserId    := if(Type("oMainWnd") == "O", __cUserId, "ws")
	Local cIdTmp	 := DtoS(Date())+StrTran(Time(), ":", "")
	Local aTitulos	 := {}
	Local oPdf		 := nil
	Local nTamArquivo:= 0
	Private lHtml    := .F.
	Private oPrint	 := nil 			

	cPdf := StrTran(AllTrim(cPdf), ".html", ".pdf")

	cTempPdf := StrTran(cPdf, "/", "")
	cTempPdf := StrTran(cTempPdf, "\", "")
	cTempPdf := "tmp"+cUserId+Right(cTempPdf, 21)						
	while .t.
		oPdf   := IpPdfObject():newIpPdfObject(cTempPdf)
		oPrint := oPdf:getFwMsPrinter()				

		if !chkTitulos(@oBol)
			Return
		endIf	

		aTitulos := oBol:aTitulos			

		ProcRegua((nTotTit := Len(aTitulos)))

		For nI := 1 To nTotTit

			cPrefixo	:= aTitulos[nI,1]
			cNumero 	:= aTitulos[nI,2]
			cParcela 	:= aTitulos[nI,3]
			cTipo	 	:= aTitulos[nI,4]

			fImpBoleto(cPrefixo, cNumero, cParcela, cTipo, oBol)			

		Next nI	

		oPdf:create()
		aFile := directory(oPdf:getPdfFile())
		if len(aFile) > 0
			nTamArquivo := aFile[1,2] 
			oFile := IpFileObject():newIpFileObject(oPdf:getPdfFile())
			if nTamArquivo > 0
				if oFile:copy(cPdf)
					oFile:delete()
				endIf
				oFile:close()
				exit
			else
				oFile:delete()
			endif
		endif 
	enddo		
Return 

/**
* Funcao		:	fImpBoleto
* Autor		:	Victor Hugo
* Data			:	12/10/2010
* Descricao	:	Impressao do Boleto de um Titulo
*
* Parametros	:	cPrefixo 	- Prefixo do Titulo         
*					cNumero		- Numero do Titulo
*					cParcela	- Parcela do Titulo
*					cTipo		- Tipo do Titulo                        
*					oBol 		- Objeto Gerenciador da Impressao de Boletos
*					
*/
Static Function fImpBoleto(cPrefixo, cNumero, cParcela, cTipo, oBol) 

	Private nOpcao	:= 0
	Private nInico	:= 0		

	oPrint:StartPage()

	For nOpcao := 1 To 2		

		nInicio	:= If(nOpcao == 1, 50, 1550)

		fImpDados(cPrefixo, cNumero, cParcela, cTipo, oBol)		

	Next nI				

	oPrint:endPage()

Return

/**
* Funcao		:	fImpLayout
* Autor		:	Victor Hugo
* Data			:	12/10/2010
* Descricao	:	Impressao do Layout dos Boletos
*/
Static Function fImpLayout()

	Local nI		:= 0	
	Local nLinha	:= 0	
	Local nQtdPont  := 0          
	Local nPosPont  := 0 
	Local nLargBox  := 2500
	Local nLinhaBox := if(nOpcao == 1, 1060, 2560)

	// Box Agrupador
	oPrint:Box((nInicio + ALTURA_CABEC), MARGEM_ESQ, nLinhaBox, nLargBox)

	// Pontilhado caso esteja Imprimindo a Via com o Codigo de Barras
	If (nOpcao == 2)    
		nLinha 	 	:= (nInicio - 200)
		nPosPont	:= MARGEM_ESQ
		nQtdPont 	:= (MARGEM_DIR - MARGEM_ESQ) / (LARG_PONT + ESP_PONT)			
		For nI := 1 To nQtdPont
			oPrint:Line(nLinha, nPosPont, nLinha, (nPosPont + LARG_PONT))
			nPosPont += (LARG_PONT + ESP_PONT)	
		Next nI
	EndIf

	// Linhas Verticais do Cabecalho		
	oPrint:Line(nInicio, COLUNA_1, nInicio + ALTURA_CABEC, COLUNA_1)
	oPrint:Line(nInicio, COLUNA_2, nInicio + ALTURA_CABEC, COLUNA_2)		

	// Segunda a Sexta Linha Horizontal	                        
	nLinha := (nInicio + ALTURA_CABEC)	
	For nI := 2 To 6
		nLinha += ALTURA_CAMPOS
		oPrint:Line(nLinha, MARGEM_ESQ, nLinha, nLargBox)	
	Next nI	

	// Linhas Verticais dos Dados dos Titulos
	nLinha := (nInicio + ALTURA_CABEC) + (ALTURA_CAMPOS * 3)
	oPrint:Line(nLinha, COLUNA_1, nLinha + (ALTURA_CAMPOS * 2), COLUNA_1) 
	oPrint:Line(nLinha, COLUNA_2, nLinha + (ALTURA_CAMPOS * 2), COLUNA_2) 
	oPrint:Line(nLinha, COLUNA_3, nLinha + (ALTURA_CAMPOS * 2), COLUNA_3)
	oPrint:Line(nLinha, COLUNA_4, nLinha + (ALTURA_CAMPOS * 2), COLUNA_4)

	// Quinta Linha Vertical
	nLinha := (nInicio + ALTURA_CABEC)
	oPrint:Line(nLinha, COLUNA_5, nLinha + (ALTURA_CAMPOS * 9) + ALTURA_SACADO, COLUNA_5) 

	// Linhas Horizontais dos Campos a Direita do Quadro de Instrucoes de Cobranca
	nLinha := (nInicio + ALTURA_CABEC) + (ALTURA_CAMPOS * 4)
	For nI := 1 To 5
		oPrint:Line(nLinha, COLUNA_5, nLinha, nLargBox)	
		nLinha += ALTURA_CAMPOS
	Next nI	

	// Linhas Horizontais do Quadro Pagador
	nLinha := (nInicio + ALTURA_CABEC) + (ALTURA_CAMPOS * 9)	
	oPrint:Line(nLinha, MARGEM_ESQ, nLinha, nLargBox)		                       
	nLinha += ALTURA_SACADO
	oPrint:Line(nLinha, MARGEM_ESQ, nLinha, nLargBox)		                       	

Return

/**
* Funcao		:	fImpDados
* Autor		:	Victor Hugo
* Data			:	12/10/2010
* Descricao	:	Impressao dos Dados dos Boletos
*
* Parametros	:	cPrefixo 	- Prefixo do Titulo          
*					cNumero		- Numero do Titulo
*					cParcela	- Parcela do Titulo
*					cTipo		- Tipo do Titulo
*					oBol 		- Objeto Gerenciador da Impressao de Boletos 
*/
Static Function fImpDados(cPrefixo, cNumero, cParcela, cTipo, oBol) 

	Local oFun			:= AdvplFun():New()

	Local cBanco		:= ""
	Local cDigBco		:= ""
	Local cImpBanco		:= ""
	Local cNomeBanco	:= ""
	Local cLogotipo		:= ""
	Local cLocalPag		:= ""	
	Local cCedente		:= ""
	Local cEndCedente	:= ""
	Local cAgencia		:= ""
	Local cCodCedente	:= ""	
	Local cNumDoc		:= ""
	Local cEspDoc		:= ""
	Local cAceite		:= ""	
	Local cNossoNum		:= ""
	Local cDvNossoNum	:= ""
	Local cImpNossoNum	:= ""
	Local cUsoBanco		:= ""
	Local cCarteira		:= ""
	Local cEspecie		:= ""
	Local cQuantidade	:= ""
	Local cValor		:= ""	
	Local cLin1Sacado 	:= ""
	Local cLin2Sacado 	:= ""
	Local cLin3Sacado 	:= ""
	Local cConvenio		:= ""
	Local cCodBaixa		:= ""    
	Local cTxtAutent  	:= ""              
	Local cCodBarras	:= ""   
	Local cTpCodBar		:= ""	
	Local cPicValores	:= PesqPict("SE1", "E1_VALOR") 

	Local nI			:= 0
	Local nLinha		:= 0 
	Local nSavLinha		:= 0
	Local nLin1Logo 	:= 0	
	Local nLin2Logo 	:= 0
	Local nColLogo		:= 0
	Local nLargLogo		:= 0
	Local nAltLogo		:= 0 
	Local nValorDoc		:= 0
	Local nDescAbat		:= 0
	Local nOutrasDed	:= 0
	Local nMoraMulta	:= 0
	Local nOutrosAcre 	:= 0
	Local nVlrCobrado	:= 0 
	Local nColCodBar	:= 0
	Local nLinCodBar	:= 0
	Local nLargCodBar	:= 0
	Local nAltCodBar	:= 0
	Local nIncLin1		:= 35
	Local nIncLin2		:= 46
	Local nIncTitCol	:= 15
	Local nIncCposCol	:= 20	
	Local nColTit1		:= (MARGEM_ESQ + nIncTitCol)
	Local nColCpo1		:= (nColTit1 + nIncCposCol)
	Local nColTit2		:= (COLUNA_1 + nIncTitCol)
	Local nColCpo2		:= (nColTit2 + nIncCposCol)
	Local nColTit3		:= (COLUNA_2 + nIncTitCol)
	Local nColCpo3		:= (nColTit3 + nIncCposCol)
	Local nColTit4		:= (COLUNA_3 + nIncTitCol)
	Local nColCpo4		:= (nColTit4 + nIncCposCol)
	Local nColTit5		:= (COLUNA_4 + nIncTitCol)
	Local nColCpo5		:= (nColTit5 + nIncCposCol)
	Local nColTit6		:= (COLUNA_5 + nIncTitCol)
	Local nColCpo6		:= (MARGEM_DIR - 70)

	Local dVencto		:= CtoD("")
	Local dDataDoc		:= CtoD("")
	Local dDtProc		:= CtoD("")

	Local lImpDvNN		:= .T.

	Local oArial07		:= TFont():New("Arial", 09, 09, , .F., , , , , .F.)
	Local oArial08N		:= TFont():New("Arial", 10, 10, , .T., , , , , .F.)
	Local oArial10N		:= TFont():New("Arial", 12, 12, , .T., , , , , .F.)
	Local oArial12N		:= TFont():New("Arial", 14, 14, , .T., , , , , .F.)
	Local oArial14N		:= TFont():New("Arial", 16, 16, , .T., , , , , .F.)
	Local oArial16N		:= TFont():New("Arial", 18, 18, , .T., , , , , .F.)
	Local oArial20N		:= TFont():New("Arial", 22, 22, , .T., , , , , .F.)

	Local aInstrucoes	:= {}	
	Local aTxtRecibo	:= {}	
	Local aArea			:= getArea()       
	Local aAreaSEE		:= SEE->(getArea())
	Local aAreaSE1		:= SE1->(getArea())	
	Local aAreaSA1		:= SA1->(getArea())
	Local aAreaSA6		:= SA6->(getArea())
	Local aAreaSEE		:= SEE->(getArea())
	Local aAreaZB1		:= ZB1->(getArea())
	Local aAreaZB2		:= ZB2->(getArea())
	Local aAreaZB3		:= ZB3->(getArea())
	private cAliasConf	:= ""
	// Posiciona todas as tabelas necessarias	
	oBol:posicionaTabelas(cPrefixo, cNumero, cParcela, cTipo)

	// Consiste o Nosso Numero
	if !Empty(SE1->E1_ZZDVNN) .and. Empty(SE1->E1_NUMBCO)
		if (Type("oMainWnd") == "O")
			oFun:showHelp("Título Iconsistente", "Não é possível gerar Boleto para o Título "+cPrefixo+cNumero+cParcela+cTipo+;
			" pois o mesmo possui DV do Nosso Número mas não possui Nosso Número.", "Execute a Rotina de Restauração de Boletos")
		endIf				   		   
		Return .F.
	endIf	

	fImpLayout()

	// Coleta os Dados da Configuracao do Boleto
	cBanco 		:= ZB1->ZB1_BANCO
	cDigBco		:= ZB1->ZB1_DIGBCO
	if ZB1->(FieldPos("ZB1_IMPBCO") > 0)
		cImpBanco := ZB1->ZB1_IMPBCO
	endIf
	cLocalPag	:= AllTrim(&(ZB1->ZB1_LOCPAG))
	dVencto		:= &(ZB1->ZB1_VENCTO)
	cCedente	:= AllTrim(&(ZB1->ZB1_CEDENTE))
	if ZB1->(FieldPos("ZB1_ENDCED") > 0)
		cEndCedente	:= AllTrim(&(ZB1->ZB1_ENDCED))
	endIf 
	cAgencia	:= AllTrim(&(ZB1->ZB1_AGEIMP))
	cCodCedente	:= AllTrim(&(ZB1->ZB1_CODCED))
	dDataDoc	:= &(ZB1->ZB1_DTDOC)
	cNumDoc		:= AllTrim(&(ZB1->ZB1_NUMDOC))
	cEspDoc		:= AllTrim(&(ZB1->ZB1_ESPDOC))
	cAceite		:= AllTrim(&(ZB1->ZB1_ACEITE))
	dDtProc		:= &(ZB1->ZB1_DTPROC)
	cNossoNum	:= AllTrim(&(ZB1->ZB1_NOSSON))
	cDvNossoNum	:= AllTrim(&(ZB1->ZB1_DVNNUM))
	cImpNossoNum:= cNossoNum + If(ZB1->ZB1_IMPDV <> "N", "-"+cDvNossoNum, "")
	cUsoBanco	:= AllTrim(&(ZB1->ZB1_USOBCO))
	cCarteira	:= AllTrim(&(ZB1->ZB1_CARTEI))
	cEspecie	:= AllTrim(&(ZB1->ZB1_ESPECI))
	cQuantidade	:= AllTrim(&(ZB1->ZB1_QUANTI))
	cValor		:= AllTrim(&(ZB1->ZB1_VALOR))
	nValorDoc	:= &(ZB1->ZB1_VLDOC)
	nDescAbat	:= &(ZB1->ZB1_DESABA)
	nOutrasDed	:= &(ZB1->ZB1_OUTDED)
	nMoraMulta	:= &(ZB1->ZB1_MORMUL)
	nOutrosAcre := &(ZB1->ZB1_OUTACR)
	cLin1Sacado := AllTrim(&(ZB1->ZB1_SACAD1))	
	cLin2Sacado := AllTrim(&(ZB1->ZB1_SACAD2))
	cLin3Sacado := AllTrim(&(ZB1->ZB1_SACAD3))	
	cCodBaixa	:= AllTrim(&(ZB1->ZB1_CODBX))
	cConvenio	:= AllTrim(&(ZB1->ZB1_CONVEN))
	nLin1Logo	:= ZB1->ZB1_LI1LOG      
	nLin2Logo	:= ZB1->ZB1_LI2LOG
	nColLogo	:= ZB1->ZB1_COLLOG
	nLargLogo	:= ZB1->ZB1_LARLOG
	nAltLogo	:= ZB1->ZB1_ALTLOG 	
	cLogotipo	:= AllTrim(ZB1->ZB1_LOGO)
	cNomeBanco	:= AllTrim(ZB1->ZB1_NOME)		
	cTpCodBar	:= AllTrim(ZB1->ZB1_TPBAR)
	nLinCodBar	:= ZB1->ZB1_LINBAR
	nColCodBar	:= ZB1->ZB1_COLBAR
	nLargCodBar	:= ZB1->ZB1_LARBAR
	nAltCodBar	:= ZB1->ZB1_ALTBAR

	// Calcula o Valor Cobrado
	If (ZB1->ZB1_IMPVLC == "S")                                
		nVlrCobrado := nValorDoc
		nVlrCobrado -= nDescAbat
		nVlrCobrado -= nOutrasDed
		nVlrCobrado += nMoraMulta
		nVlrCobrado += nOutrosAcre           		
	EndIf	

	// Impressao do Logotipo ou Nome do Banco
	If !lHtml .AND. !Empty(cLogotipo) .AND. File(cLogotipo) 
		nLinha := If(nOpcao == 1, nLin1Logo, nLin2Logo)
		oPrint:sayBitmap(nLinha, nColLogo, cLogotipo, nLargLogo, nAltLogo)	
	Else
		nLinha := (nInicio + ALTURA_CABEC) - 65
		oPrint:Say(nLinha, nColTit1, cNomeBanco, oArial12N)	
	EndIf	

	// Codigo do Banco na Camara de Compensacao
	nLinha := (nInicio + ALTURA_CABEC) - 20
	if Empty(cImpBanco)
		cImpBanco := cBanco+"-"+cDigBco
	endIf
	oPrint:Say(nLinha+5, nColTit2+80, cImpBanco, oArial20N)

	// Coleta a String do Codigo de Barras
	cCodBarras := oBol:getStrCodBarras()	

	// Impressao da Linha Digitavel	
	oPrint:Say(nLinha+8, nColTit3+60, oBol:getStrLinDig(cCodBarras), oArial10N)

	// Texto Recibo do Sacado
	if (nOpcao == 1)
		oPrint:Say(nLinha+12, (MARGEM_DIR - 35), "Recibo do Pagador", oArial07, , , , ALIN_DIR)
	endIf

	// Primeira Linha de Dados - Local de Pagamento e Vencimento 
	nLinha := (nInicio + ALTURA_CABEC) + 25
	oPrint:Say(nLinha, nColTit1, "Local de Pagamento", oArial07)	                                                                		
	oPrint:Say(nLinha, nColTit6, "Vencimento", oArial07)                                                                                
	nLinha += nIncLin1
	oPrint:Say(nLinha, nColCpo1, cLocalPag, oArial08N)	                                                                		
	oPrint:Say(nLinha, nColCpo6-10, oFun:StrData(dVencto), oArial08N, , , , ALIN_DIR)

	// Segunda Linha de Dados - Beneficiario e Agencia/Codigo do Beneficiario
	nLinha += nIncLin2
	oPrint:Say(nLinha, nColTit1, "Beneficiário", oArial07)	                                                                		
	oPrint:Say(nLinha, nColTit6, "Agência/Código do Beneficiário", oArial07)                                                                                
	nLinha += nIncLin1
	oPrint:Say(nLinha, nColCpo1, cCedente, oArial08N)
	if (cBanco == "748")	                                                                		
		oPrint:Say(nLinha, nColCpo6-10, AllTrim(cAgencia)+"."+cCodCedente, oArial08N, , , , ALIN_DIR)
	else
		oPrint:Say(nLinha, nColCpo6-10, AllTrim(cAgencia)+" / "+cCodCedente, oArial08N, , , , ALIN_DIR)	
	endIf	

	// Terceira Linha de Dados - Endereço do Beneficiario e Nosso Numero
	nLinha += (nIncLin2 - 5)
	oPrint:Say(nLinha, nColTit1, "Endereço Beneficiário / Beneficiário Avalista", oArial07)
	oPrint:Say(nLinha, nColTit6, "Nosso Número", oArial07)	                                                                                                                                              
	nLinha += nIncLin1
	oPrint:Say(nLinha, nColCpo1, cEndCedente, oArial08N)
	oPrint:Say(nLinha, nColCpo6-10, cImpNossoNum, oArial08N, , , , ALIN_DIR)	                                                                		

	// Quarta Linha de Dados - Data do Documento, Numero do Documento, Especie Doc., Aceite, Data do Proc. e Valor do Documento
	nLinha += nIncLin2
	oPrint:Say(nLinha, nColTit1, "Data do Documento", oArial07)	                                                                		
	oPrint:Say(nLinha, nColTit2, "Número do Documento", oArial07)                                                                                
	oPrint:Say(nLinha, nColTit3, "Espécie Doc.", oArial07)
	oPrint:Say(nLinha, nColTit4, "Aceite", oArial07)
	oPrint:Say(nLinha, nColTit5, "Data de Processamento", oArial07)
	oPrint:Say(nLinha, nColTit6, "(=) Valor do Documento", oArial07)
	nLinha += nIncLin1
	oPrint:Say(nLinha, nColCpo1+140, oFun:StrData(dDataDoc), oArial08N)	                                                                		
	oPrint:Say(nLinha, nColCpo2+30, cNumDoc, oArial08N)					
	oPrint:Say(nLinha, nColCpo3+80, cEspDoc, oArial08N)
	oPrint:Say(nLinha, nColCpo4+80, cAceite, oArial08N)
	oPrint:Say(nLinha, nColCpo5+140, oFun:StrData(dDtProc), oArial08N)
	oPrint:Say(nLinha, nColCpo6-10, AllTrim(Transform(nValorDoc, cPicValores)), oArial08N, , , , ALIN_DIR)	

	// Quinta Linha de Dados - Uso do Banco, Carteira, Especie, Quantidade, Valor e Desconto/Abatimento
	nLinha += nIncLin2
	oPrint:Say(nLinha, nColTit1, "Uso do Banco", oArial07)	                                                                		
	oPrint:Say(nLinha, nColTit2, "Carteira", oArial07)                                                                                
	oPrint:Say(nLinha, nColTit3, "Espécie", oArial07)
	oPrint:Say(nLinha, nColTit4, "Quantidade", oArial07)
	oPrint:Say(nLinha, nColTit5, "Valor", oArial07)
	oPrint:Say(nLinha, nColTit6, "(-) Desconto/Abatimento", oArial07)
	nLinha += nIncLin1
	oPrint:Say(nLinha, nColCpo1+140, cUsoBanco, oArial08N)	                                                                		
	oPrint:Say(nLinha, nColCpo2+100, cCarteira, oArial08N)					
	oPrint:Say(nLinha, nColCpo3+80, cEspecie, oArial08N)
	oPrint:Say(nLinha, nColCpo4+80, cQuantidade, oArial08N)
	oPrint:Say(nLinha, nColCpo5+140, cValor, oArial08N)
	If (nDescAbat > 0)
		oPrint:Say(nLinha, nColCpo6-10, AllTrim(Transform(nDescAbat, cPicValores)), oArial08N, , , , ALIN_DIR)
	EndIf	

	// Instrucoes de Cobranca
	nLinha += nIncLin2
	nSavLinha := nLinha
	oPrint:Say(nLinha, nColTit1, "Instruções (Todas as informações deste bloqueto são de exclusiva responsabilidade do beneficiário)", oArial07)
	nLinha += (nIncLin1 + 10)
	
	cAliasConf := ""
	oBol:getAliasConf()
	aInstrucoes := oBol:getInstrucoes()

	For nI := 1 To Len(aInstrucoes)
		oPrint:Say(nLinha, nColCpo1, aInstrucoes[nI], oArial08N)
		nLinha += nIncLin2
	Next nI	

	// Demais Valores do Titulo	                                                                		
	nLinha := nSavLinha	
	oPrint:Say(nLinha, nColTit6, "(-) Outras Deduções", oArial07)
	nLinha += nIncLin2
	If (nOutrasDed > 0)
		oPrint:Say(nLinha-8, nColCpo6-10, AllTrim(Transform(nOutrasDed, cPicValores)), oArial08N, , , , ALIN_DIR)
	EndIf	
	nLinha += nIncLin1
	oPrint:Say(nLinha, nColTit6, "(+) Mora/Multa", oArial07)
	nLinha += nIncLin2
	If (nMoraMulta > 0)	
		oPrint:Say(nLinha-8, nColCpo6-10, AllTrim(Transform(nMoraMulta, cPicValores)), oArial08N, , , , ALIN_DIR)
	EndIf	
	nLinha += nIncLin1	
	oPrint:Say(nLinha, nColTit6, "(+) Outros Acréscimos", oArial07)
	nLinha += nIncLin2         	
	If (nOutrosAcre > 0)
		oPrint:Say(nLinha-8, nColCpo6-10, AllTrim(Transform(nOutrosAcre, cPicValores)), oArial08N, , , , ALIN_DIR)
	EndIf	
	nLinha += nIncLin1	
	oPrint:Say(nLinha, nColTit6, "(=) Valor Cobrado", oArial07)
	nLinha += nIncLin2
	If (nVlrCobrado > 0)
		oPrint:Say(nLinha-8, nColCpo6-10, AllTrim(Transform(nVlrCobrado, cPicValores)), oArial08N, , , , ALIN_DIR)
	EndIf	
	nLinha += nIncLin1                    
	nSavLinha := (nLinha - 5)
	oPrint:Say(nLinha, nColTit6, "Codigo de Baixa", oArial07)
	nLinha += nIncLin2
	oPrint:Say(nLinha, nColCpo6-10, cCodBaixa, oArial08N, , , , ALIN_DIR)
	nLinha += nIncLin1

	// Dados do Pagador 
	nLinha := nSavLinha
	oPrint:Say(nLinha, nColTit1, "Pagador", oArial07)
	nLinha += nIncLin1
	oPrint:Say(nLinha, nColCpo1, cLin1Sacado, oArial08N)	                                                                		
	nLinha += nIncLin2
	oPrint:Say(nLinha, nColCpo1, cLin2Sacado, oArial08N)
	nLinha += nIncLin2
	oPrint:Say(nLinha, nColCpo1, cLin3Sacado, oArial08N)		                 
	nLinha += nIncLin2
	oPrint:Say(nLinha, nColTit1, "Pagador / Avalista:", oArial07)
	if (ZB1->(FieldPos("ZB1_PAGAVA") > 0) .and. !Empty(ZB1->ZB1_PAGAVA))
		oPrint:Say(nLinha-2, nColCpo1+220, &(ZB1->ZB1_PAGAVA), oArial08N)
	endIf

	// Codigo de Barras
	If (nOpcao == 2)
		//MSBAR3(cTpCodBar,nLinCodBar,nColCodBar,cCodBarras,oPrint,.F.,,.T.,0.0300,1.2200,.F.,0.5,0.5,.F.)
		//oEtiqStarkey:FWMSBAR("CODE128", 14.5, 16, Alltrim(cCep), oEtiqStarkey, .T., Nil, .T., 0.04, 1.30, .F., "Arial", Nil, .F., 2, 2, .F.)
		//FWMsPrinter():Int25(nLinCodBar,nColCodBar,cCodBarras,nLargCodBar,nAltCodBar)

		//Aviso("Aviso",cCodBarras,{"OK"},3)

		//cCodBarras := "03399527645430000000400002701043155290000008055"

		FWMsPrinter():FWMsBar("INT25",90,4,cCodBarras,oPrint,.T.,Nil,.T.,0.12,4,.F.,"Arial",Nil,.F.,1,1,.F.)
	EndIf				

	// Textos Recibo do Sacado / Autenticacao Mecanica / Ficha de Compensacao 
	nLinha := (nInicio + ALTURA_CABEC) + (ALTURA_CAMPOS * 9) + ALTURA_SACADO + 15

	if (nOpcao == 1)
		nSavLinha := nLinha
		aTxtRecibo := oBol:getTxtRecibo()
		for nI := 1 to Len(aTxtRecibo)
			if (nI <= 5)
				oPrint:Say(nLinha, nColCpo1, aTxtRecibo[nI], oArial07)
				nLinha += nIncLin1
			endIf	
		next nI
		nLinha := nSavLinha
	endIf		

	cTxtAutent := "Autenticação Mecânica"
	If (nOpcao == 2)
		cTxtAutent += " / Ficha de Compensação"			
	EndIf
	oPrint:Say(nLinha+8, nColTit6-65, cTxtAutent, oArial07)  	

	// Gravacao dos Dados do Boleto no Titulo
	SE1->(RecLock("SE1", .F.))
	SE1->E1_PORTADO := oBol:cBanco
	SE1->E1_AGEDEP	:= oBol:cAgencia
	SE1->E1_CONTA	:= oBol:cConta
	SE1->E1_ZZSUBCO := oBol:cSubConta
	SE1->E1_ZZDVNN	:= cDvNossoNum		
	If !Empty(ZB1->ZB1_GRVNN)
		SE1->E1_NUMBCO := &(ZB1->ZB1_GRVNN)
	EndIf
	SE1->(MsUnlock())

	oBol:gravaBoleto()	

	RestArea(aAreaSEE)	
	RestArea(aAreaSE1)
	RestArea(aAreaSA1)                                              
	RestArea(aAreaSA6)
	RestArea(aAreaSEE)
	RestArea(aAreaZB1)
	RestArea(aAreaZB2)
	RestArea(aAreaZB3)
	RestArea(aArea)

Return .T.

/*
Verifica se todos os Titulos estao ok
*/
Static Function chkTitulos(oBol)	
	Local nI 		:= 0	
	Local cPrefixo	:= ""
	Local cNumero	:= ""
	Local cParcela	:= ""
	Local cTipo		:= ""
	Local aOk		:= {}
	Local cFunMenu	:= Upper(AllTrim(FunName()))	

	if (cFunMenu == "MANBOLETOS")
		Return .T.
	endIf

	for nI := 1 to Len(oBol:aTitulos)

		cPrefixo	:= oBol:aTitulos[nI,1]
		cNumero 	:= oBol:aTitulos[nI,2]
		cParcela 	:= oBol:aTitulos[nI,3]
		cTipo	 	:= oBol:aTitulos[nI,4]

		if oBol:vldImpressao(cPrefixo, cNumero, cParcela, cTipo)
			aAdd(aOk, oBol:aTitulos[nI])
		endIf

	next nI

	oBol:aTitulos := aClone(aOk)

Return (Len(aOk) > 0)
