#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "font.ch"
#INCLUDE "topconn.ch"

/**
 * Rotina		:	MSRORCGFLF
 * Autor		:	Winston Dellano de Castro
 * Data		    :	27/10/2006
 * Descrição	:	Rotina responsável pela impressão do Orçamento de Vendas
 * Modulo		:  	Faturamento
**/

User Function MSRORCGF(lAuto,cNumero)

	Local cTitulo      := "Relatório de Orçamento de Vendas"
	Local nCount       := 0  
	Local cPerg        := "PERORC" 
	
	Default lAuto      := .F.
	Default cNumero    := ""
	
	Private cOrcamento := ""    
	Private cEmissao   := ""
	Private nQtdPag    := 0
	Private aTotaIpi   := {0,0}                                      // Controle do Valor Total do IPI
	Private nTotaIcm   := 0
	Private oFont1     := TFont():New("Arial",09,13,   ,.T.,,,,,.F.) // Parametros TFonte ("Tipo Fonte", ,Tamanho Fonte , , ,Italico (.T./.F.))
	Private oFont2     := TFont():New("Arial",07,07,   ,.F.,,,,,.F.) // Normal
	Private oFont3     := TFont():New("Arial",09,09,.T.,.T.,,,,,.F.) // Negrito
	Private oFont4     := TFont():New("Arial",09,13,.T.,.T.,,,,,.T.) // Negrito - Sublinhado
	Private oFont5     := TFont():New("Arial",09,09,   ,.F.,,,,,.F.) // Negrito
	Private oPrint     := Nil
	
	// Instânciação do Objeto OPrint
	oPrint := TMSPrinter():New()
	oPrint:setPaperSize(9)
	
	//ValidPerg(cPerg)
	
	If lAuto
		mv_par01 := cNumero
		mv_par02 := cNumero
		mv_par03 := Ctod("01/01/1990")
		mv_par04 := Ctod("31/12/2060")
	Else
		If !(Pergunte(cPerg,.T.))
			Return
		EndIf  
	EndIf
	     
	// Query que retorna os dados do orcamento e os dados dos itens.
	cQuery := "SELECT CJ_NUM,CJ_EMISSAO,CJ_CONDPAG,CJ_DESC1,CJ_DESC2,CJ_DESC3,CJ_FRETE, " + CRLF
	cQuery += "       CJ_DESPESA,CJ_DESC4,CJ_DATA1,CJ_DATA2,CJ_DATA3,CJ_DATA4,CJ_PARC1, " + CRLF
	cQuery += "       CJ_PARC2,CJ_COTCLI,CJ_PARC3,CJ_PARC4,CJ_CLIENTE,CJ_LOJA,CJ_VALIDA," + CRLF
	cQuery += "       CJ_ZZTRANS,CJ_OBSERV,CK_ITEM,CK_NUM,CK_PRODUTO,CK_DESCRI,CK_UM,  " + CRLF
	cQuery += "       CK_TES,CK_QTDVEN,CK_PRCVEN,CK_VALOR,CK_OBS,B1_IPI,               " + CRLF
	cQuery += "		  CASE WHEN CJ_PROSPE <> ' ' THEN (SELECT US_END FROM "+  RetSqlName("SUS")+" US WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = CJ_PROSPE AND US_LOJA = CJ_LOJPRO) ELSE A1_END END AS A1_END, " + CRLF
	cQuery += "       CASE WHEN CJ_PROSPE <> ' ' THEN (SELECT US_COD FROM "+  RetSqlName("SUS")+" US WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = CJ_PROSPE AND US_LOJA = CJ_LOJPRO) ELSE A1_COD END AS A1_COD, " + CRLF
	cQuery += "       CASE WHEN CJ_PROSPE <> ' ' THEN (SELECT US_NOME FROM "+  RetSqlName("SUS")+" US WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = CJ_PROSPE AND US_LOJA = CJ_LOJPRO) ELSE A1_NOME END AS A1_NOME, " + CRLF
	cQuery += "       CASE WHEN CJ_PROSPE <> ' ' THEN (SELECT US_EMAIL FROM "+  RetSqlName("SUS")+" US WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = CJ_PROSPE AND US_LOJA = CJ_LOJPRO) ELSE A1_EMAIL END AS A1_EMAIL, " + CRLF
	cQuery += "       CASE WHEN CJ_PROSPE <> ' ' THEN (SELECT US_MUN FROM "+  RetSqlName("SUS")+" US WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = CJ_PROSPE AND US_LOJA = CJ_LOJPRO) ELSE A1_MUN END AS A1_MUN, " + CRLF
	cQuery += "       CASE WHEN CJ_PROSPE <> ' ' THEN (SELECT US_EST FROM "+  RetSqlName("SUS")+" US WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = CJ_PROSPE AND US_LOJA = CJ_LOJPRO) ELSE A1_EST END AS A1_EST, " + CRLF
	cQuery += "       CASE WHEN CJ_PROSPE <> ' ' THEN (SELECT US_DDD FROM "+  RetSqlName("SUS")+" US WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = CJ_PROSPE AND US_LOJA = CJ_LOJPRO) ELSE A1_DDD END AS A1_DDD, " + CRLF
	cQuery += "       CASE WHEN CJ_PROSPE <> ' ' THEN (SELECT US_TEL FROM "+  RetSqlName("SUS")+" US WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = CJ_PROSPE AND US_LOJA = CJ_LOJPRO) ELSE A1_TEL END AS A1_TEL, " + CRLF
	cQuery += "       CASE WHEN CJ_PROSPE <> ' ' THEN (SELECT US_GRPTRIB FROM "+  RetSqlName("SUS")+" US WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = CJ_PROSPE AND US_LOJA = CJ_LOJPRO) ELSE A1_GRPTRIB END AS A1_GRPTRIB, " + CRLF
	cQuery += "       CASE WHEN CJ_PROSPE <> ' ' THEN (SELECT US_TIPO FROM "+  RetSqlName("SUS")+" US WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = CJ_PROSPE AND US_LOJA = CJ_LOJPRO) ELSE A1_TIPO END AS A1_TIPO, " + CRLF
	cQuery += "       CASE WHEN CJ_PROSPE <> ' ' THEN (SELECT US_FAX FROM "+  RetSqlName("SUS")+" US WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = CJ_PROSPE AND US_LOJA = CJ_LOJPRO) ELSE A1_FAX END AS A1_FAX, " + CRLF
	cQuery += "       CASE WHEN CJ_PROSPE <> ' ' THEN (SELECT US_CEP FROM "+  RetSqlName("SUS")+" US WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = CJ_PROSPE AND US_LOJA = CJ_LOJPRO) ELSE A1_CEP END AS A1_CEP, " + CRLF
	cQuery += "       CASE WHEN CJ_PROSPE <> ' ' THEN (SELECT US_ZZCONT FROM "+  RetSqlName("SUS")+" US WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = CJ_PROSPE AND US_LOJA = CJ_LOJPRO) ELSE A1_CONTATO END AS A1_CONTATO, " + CRLF
	cQuery += "       CASE WHEN CJ_PROSPE <> ' ' THEN (SELECT US_BAIRRO FROM "+  RetSqlName("SUS")+" US WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = CJ_PROSPE AND US_LOJA = CJ_LOJPRO) ELSE A1_BAIRRO END AS A1_BAIRRO, " + CRLF
	cQuery += "       CASE WHEN CJ_PROSPE <> ' ' THEN (SELECT US_URL FROM "+  RetSqlName("SUS")+" US WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = CJ_PROSPE AND US_LOJA = CJ_LOJPRO) ELSE A1_HPAGE END AS A1_HPAGE, " + CRLF
	cQuery += "       CASE WHEN CJ_PROSPE <> ' ' THEN (SELECT US_CGC FROM "+  RetSqlName("SUS")+" US WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = CJ_PROSPE AND US_LOJA = CJ_LOJPRO) ELSE A1_CGC END AS A1_CGC, " + CRLF
	cQuery += "       CASE WHEN CJ_PROSPE <> ' ' THEN (SELECT US_INSCR FROM "+  RetSqlName("SUS")+" US WHERE US_FILIAL = '"+xFilial("SUS")+"' AND US_COD = CJ_PROSPE AND US_LOJA = CJ_LOJPRO) ELSE A1_INSCR END AS A1_INSCR, " + CRLF
	cQuery += "       B1_GRTRIB,B1_PICM,                   " + CRLF
	cQuery += "       ISNULL(A4_NOME,'')   A4_NOME,                                     " + CRLF
	cQuery += "       ISNULL(E4_DESCRI,'') E4_DESCRI                                    " + CRLF
	cQuery += "FROM "       + RetSqlName("SCJ")+" CJ                                    " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SCK")+" CK                                    " + CRLF
	cQuery += "ON CK_FILIAL = '"+xFilial("SCK")+"' AND                                  " + CRLF
	cQuery += "   CK_NUM    = CJ_NUM AND                                                " + CRLF
	cQuery += "   CK.D_E_L_E_T_ = ' '                                                   " + CRLF
	cQuery += "INNER JOIN "+  RetSqlName("SA1")+" A1                                    " + CRLF
	cQuery += "ON A1_FILIAL = '"+xFilial("SA1")+"' AND                                  " + CRLF
	cQuery += "   A1_COD    = CJ_CLIENTE AND                                            " + CRLF
	cQuery += "   A1_LOJA   = CJ_LOJA    AND                                            " + CRLF
	cQuery += "   A1.D_E_L_E_T_ = ' '                                                   " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1")+" B1                                    " + CRLF
	cQuery += "ON B1_FILIAL = '"+xFilial("SB1")+"' AND                                  " + CRLF
	cQuery += "   B1_COD    = CK_PRODUTO AND                                            " + CRLF
	cQuery += "   B1.D_E_L_E_T_ = ' '                                                   " + CRLF
	cQuery += "LEFT JOIN " +  RetSqlName("SE4")+" E4                                    " + CRLF
	cQuery += "ON E4_FILIAL = '"+xFilial("SE4")+"' AND                                  " + CRLF
	cQuery += "   E4_CODIGO = CJ_CONDPAG AND                                            " + CRLF
	cQuery += "   E4.D_E_L_E_T_ = ' '                                                   " + CRLF
	cQuery += "LEFT JOIN " +  RetSqlName("SA4")+" A4                                    " + CRLF
	cQuery += "ON A4_FILIAL = '"+xFilial("SA4")+"' AND                                  " + CRLF
	cQuery += "   A4_COD    = CJ_ZZTRANS AND                                            " + CRLF
	cQuery += "   A4.D_E_L_E_T_ = ' '                                                   " + CRLF
	cQuery += "WHERE CJ_FILIAL = '"+xFilial("SCJ")+ "' AND                              " + CRLF
	cQuery += "     CJ_NUM     BETWEEN '"+ mv_par01     +"' AND '"+ mv_par02 +"'     AND" + CRLF
	If !Empty(mv_par03) .AND. !Empty(mv_par04)
		cQuery += " CJ_EMISSAO BETWEEN '"+Dtos(mv_par03)+"' AND '"+Dtos(mv_par04)+"' AND" + CRLF
	EndIf
	cQuery += "      CJ.D_E_L_E_T_ = ' '                                                " + CRLF
	cQuery += "ORDER BY CJ_NUM,CK_ITEM                                                  " + CRLF
			
	TCQUERY cQuery NEW ALIAS "QRY"
	
	Count to nCount
	
	QRY->(dbgotop())
	
	If QRY->(Eof())
		MsgSTOP("Não há registros para os parametros informados !!")
		QRY->(dbCloseArea())
	EndIf
		
	While QRY->(!Eof())
	
		TcSetField("QRY","CJ_EMISSAO","D") 
		TcSetField("QRY","CJ_VALIDA","D")
	
		cOrcamento := QRY->CJ_NUM
		cEmissao   := QRY->CJ_EMISSAO
		aTotaIpi   := {0,0}
		nTotaIcm   := 0
				
		// Query que retorna a Quantidade Total de itens em um orcamento
		cQuery := "SELECT COUNT(CK_ITEM) AS TOTAL "
		cQuery += "FROM " + RetSqlName("SCK") + " "
		cQuery += "WHERE CK_NUM = '" + QRY->CJ_NUM + "' AND D_E_L_E_T_ = ' ' "
		
		TCQUERY cQuery NEW ALIAS "cCount"
		
		// Atribui a Quantidade Total de itens na Variavel nCount
		nCount := cCount->TOTAL 
		
		// Controla a Quantidade de Paginas no Relatorio
		nQtdPag := Str((cCount->TOTAL / 30)+ 1) 
		nQtdPag := Left(nQtdPag, At(".",nQtdPag)-1)
		
		cCount->(dbCloseArea())
		
		// Inicia uma Nova Pagina para Impressao
		oPrint:StartPage()
		
		// Define o modo de Impressao como Retrato
		oPrint:SetPortrait()  // SetLandscape -> Para definir como modo Paisagem
		
		PrintHeader(cOrcamento,cEmissao)       // Funcao para impressao do Cabecalho
	    PrintCustomer()	                       // Funcao para impressao dos dados do Cliente
	   	PrintDetail(cOrcamento,nCount,nQtdPag) // Funcao para impressao dos Detalhes do Produto
				
	EndDo
	
	QRY->(dbCloseArea())
	
	Define MsDialog oDlg Title "Orçamento de Vendas" From 0, 0 To 090, 430 Pixel
	Define Font oBold Name "Arial" Size 0, -13 Bold
	@ 000, 000 Bitmap oBmp ResName "LOGIN" Of oDlg Size 30, 120 NoBorder When .f. Pixel
	@ 003, 040 Say cTitulo Font oBold Pixel
	@ 014, 030 To 016, 400 Label '' Of oDlg  Pixel
	@ 020, 040 Button "Configurar" 	Size 40, 13 Pixel Of oDlg Action oPrint:Setup()
	@ 020, 082 Button "Imprimir"   	Size 40, 13 Pixel Of oDlg Action oPrint:Print()
	@ 020, 124 Button "Visualizar" 	Size 40, 13 Pixel Of oDlg Action oPrint:Preview()
	@ 020, 166 Button "Sair"       	Size 40, 13 Pixel Of oDlg Action oDlg:End()
	Activate MsDialog oDlg Centered

Return

/*
Impressao do cabecalho do relatorio.
Informacao: Cabecalho - Dados da Empresa
*/
Static Function PrintHeader(cOrcamento,cEmissao)

	Local nTopo    := 0  // Controle de Linhas
	Local nInicio  := 0  // Indica a posição da primeira coluna  
	Local cEmail   := AllTrim(GetMV("MV_RELFROM"))
	Local cLogo    := AllTrim(GetMV("ZZ_LOGO"))
	Local cAddress := ""
	Local cCnpj    := ""
	
	// Retorna o tamanho Horizontal e Vertical da pagina.
	nVertSize := oPrint:nVertSize()
	nHorzSize := oPrint:nHorzSize()
	
	// Impressao do cabeçalho do Relatorio.
	// Obs.: O Logo pode ser colocado na pasta System do Protheus, no caso só referencia o nome.
	
	// oPrint:SayBitmap(Coluna, Linha, Caminho, Largura, Altura) 
	oPrint:SayBitmap(nTopo + 50,nInicio + 40,cLogo,410,185)
	dbSelectArea("SM0")
	SM0->(dbseek(cEmPant + cFilant))
	
	cAddress := AllTrim(SM0->M0_ENDENT)+" "+AllTrim(SM0->M0_CIDENT)+"/"+AllTrim(SM0->M0_ESTENT)+" "+Left(AllTrim(SM0->M0_CEPENT),5) + "-" + Right(AllTrim(SM0->M0_CEPENT),3)
	cCnpj    := "CNPJ: " + AllTrim(Transform(SM0->M0_CGC, "@R 99.999.999/9999-99")) + " - IE: " +  AllTrim(Transform(SM0->M0_INSC, "@R 999.999.999.999"))
	
	// oPrint:Say(Coluna, Linha, Texto, Fonte, Num de Caracteres, , ,Alinhamento - 0=Left, 1=Right e 2=Center)
	oPrint:Say(nTopo + 0050,nInicio + 2360,AllTrim(SM0->M0_NOMECOM)       ,oFont1,100,,,1)
	oPrint:Say(nTopo + 0100,nInicio + 2360,cAddress                       ,oFont5,100,,,1)
	oPrint:Say(nTopo + 0150,nInicio + 2360,"E-mail: " + AllTrim(cEmail)   ,oFont3,100,,,1)
	oPrint:Say(nTopo + 0200,nInicio + 2360,"Fone: " + AllTrim(SM0->M0_TEL),oFont5,100,,,1)
	oPrint:Say(nTopo + 0250,nInicio + 2360,cCnpj                          ,oFont5,100,,,1)
	
	// oPrint:Line(Coluna, Linha, Coluna, Linha)
	oPrint:Line(nTopo + 0310,nInicio + 0040,nTopo + 0310,nInicio + 2360)
	oPrint:Line(nTopo + 0313,nInicio + 0040,nTopo + 0313,nInicio + 2360)
	oPrint:Line(nTopo + 0410,nInicio + 0040,nTopo + 0410,nInicio + 2360)
	oPrint:Line(nTopo + 0413,nInicio + 0040,nTopo + 0413,nInicio + 2360)
	
	oPrint:Say(nTopo + 0335,nInicio + 0040,"Orçamento N° " + cOrcamento,oFont1,100,,,0)
	oPrint:Say(nTopo + 0335,nInicio + 2360,"Data: " + Dtoc(cEmissao)   ,oFont1,100,,,1)
	
Return
	
/*
Impressao dos Dados do Cliente.
Informacoes: Nome, E-mail, Endereco, Cidade, CEP, Tel, FAX,Contato e Bairro.
*/
Static Function PrintCustomer()

	Local nTopo        := 0  // Controle de Linhas
	Local nInicio      := 0  // Indica a posicao da primeira coluna
	Local cPhoneNumber := ""
	Local cZipCode     := ""
	Local cFaxNumber   := ""
	
	// Impressão da Estrutura dos Dados do Cliente
	
	// Texto a Esquerda
	oPrint:Say(nTopo + 0430,nInicio + 0040,"Cliente" ,oFont3,100,,,0)
	oPrint:Say(nTopo + 0480,nInicio + 0040,"E-mail"  ,oFont3,100,,,0)
	oPrint:Say(nTopo + 0530,nInicio + 0040,"Endereço",oFont3,100,,,0)
	oPrint:Say(nTopo + 0580,nInicio + 0040,"Cidade"  ,oFont3,100,,,0)
	oPrint:Say(nTopo + 0630,nInicio + 0040,"TEL"     ,oFont3,100,,,0)
	If Len(AllTrim(QRY->A1_CGC)) > 11 
		oPrint:Say(nTopo + 0680,nInicio + 0040,"CNPJ",oFont3,100,,,0)
	Else
		oPrint:Say(nTopo + 0680,nInicio + 0040,"CPF" ,oFont3,100,,,0)
	EndIf
	
	// Texto Centralizado
//	oPrint:Say(nTopo + 0430	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"Site"    ,oFont3,100,,,0)
	oPrint:Say(nTopo + 0530	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"Contato" ,oFont3,100,,,0)
	oPrint:Say(nTopo + 0580	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"Bairro"  ,oFont3,100,,,0)
	oPrint:Say(nTopo + 0630	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"CEP"     ,oFont3,100,,,0)
//	oPrint:Say(nTopo + 0630	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"FAX"     ,oFont3,100,,,0)
	oPrint:Say(nTopo + 0680	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"I.E."    ,oFont3,100,,,0)
	  
    // Texto a Esquerda
    cPhoneNumber := ": (" + QRY->A1_DDD + ") " + Left(QRY->A1_TEL,4) + "-" + Substr(QRY->A1_TEL,5,8)
    
	oPrint:Say(nTopo + 0430,nInicio + 0190,": " + QRY->A1_COD + " - " + QRY->A1_NOME  ,oFont5,100,,,0)
	oPrint:Say(nTopo + 0480,nInicio + 0190,": " + QRY->A1_EMAIL                       ,oFont5,100,,,0)
	oPrint:Say(nTopo + 0530,nInicio + 0190,": " + QRY->A1_END                         ,oFont5,100,,,0)
	oPrint:Say(nTopo + 0580,nInicio + 0190,": " + AllTrim(QRY->A1_MUN)+"/"+QRY->A1_EST,oFont5,100,,,0)
	oPrint:Say(nTopo + 0630,nInicio + 0190,cPhoneNumber                               ,oFont5,100,,,0)

	If Len(AllTrim(QRY->A1_CGC)) > 11  
		oPrint:Say(nTopo + 0680,nInicio + 0190,": " + AllTrim(Transform(QRY->A1_CGC,"@R 99.999.999/9999-99")),oFont5,100,,,0)
	Else	
		oPrint:Say(nTopo + 0680,nInicio + 0190,": " + AllTrim(Transform(QRY->A1_CGC,"@R 999.999.999-99"))    ,oFont5,100,,,0)
	EndIf
	
	// Texto Centralizado
	cZipCode   := ": " + Left(QRY->A1_CEP,5) + "-" + Right(QRY->A1_CEP,3)
	cFaxNumber := ": (" + QRY->A1_DDD + ") " + Left(QRY->A1_FAX,4) + "-" + Substr(QRY->A1_FAX,5,8)
	
//	oPrint:Say(nTopo + 0430	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0150,": " + QRY->A1_HPAGE  ,oFont5,100,,,0)
	oPrint:Say(nTopo + 0530	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0150,": " + QRY->A1_CONTATO,oFont5,100,,,0)
	oPrint:Say(nTopo + 0580	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0150,": " + QRY->A1_BAIRRO ,oFont5,100,,,0)
	oPrint:Say(nTopo + 0630	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0150,cZipCode              ,oFont5,100,,,0)
//	oPrint:Say(nTopo + 0630	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0150,cFaxNumber            ,oFont5,100,,,0)

	If Len(AllTrim(QRY->A1_INSCR)) > 6
		oPrint:Say(nTopo + 0680	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0150,": " + AllTrim(Transform(QRY->A1_INSCR,"@R 999.999.999.999")),oFont5,100,,,0)
	Else
		oPrint:Say(nTopo + 0680	,Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0150,": " + AllTrim(QRY->A1_INSCR),oFont5,100,,,0)
	EndIf
	
Return
	
/*
Impressao dos Dados de Detalhes dos Produtos.
Parametros: cOrcamento - Numero do Orçamento de Venda Corrente.
            nCount     - Quantidade Total de Itens.
*/
Static Function PrintDetail(cOrcamento,nCount,nQtdPag)

	Local nTopo    := 750 // Controle de Linhas
	Local nInicio  := 0   // Indica a posição da primeira coluna
	Local nTotal   := 0   // Controle do Valor Total do Orçamento 
	Local nTotal2  := 0   // Controle do Valor Total do Orçamento 
	Local nFrete   := 0   // Controle do Valor Total do Orçamento 
	Local nDespesa := 0   // Controle do Valor Total do Orçamento
	Local nPage    := 1
	Local nCont    := 1 
	Local nContP   := 0 
	Local nTamDes  := 0
	Local nTamStr  := 0
	Local cPrcVen  := ""
    Local cValor   := ""
	Local aTexto	:= {}
    Local nCon	:= 0
	
	Private nTpag  := 0

	// Box, Linhas Verticais e Dados do Cabecalho de Orçamento.
	// Box
	oPrint:Box(nTopo,nInicio + 0040, nTopo + 0050,nInicio + 2360)
	
	// Linhas Verticais
	oPrint:Line(nTopo,nInicio + 0120,nTopo + 0050,nInicio + 0120) //180
	oPrint:Line(nTopo,nInicio + 0340,nTopo + 0050,nInicio + 0340) //580 //440 //300 //320 --> Barra esquerda Descrição
	oPrint:Line(nTopo,nInicio + 1190,nTopo + 0050,nInicio + 1190) //1330
	oPrint:Line(nTopo,nInicio + 1270,nTopo + 0050,nInicio + 1270) //1440
	oPrint:Line(nTopo,nInicio + 1430,nTopo + 0050,nInicio + 1430) //1600
	oPrint:Line(nTopo,nInicio + 1730,nTopo + 0050,nInicio + 1730) //1900
	oPrint:Line(nTopo,nInicio + 2030,nTopo + 0050,nInicio + 2030) //2200
	oPrint:Line(nTopo,nInicio + 2200,nTopo + 0050,nInicio + 2200)
	
	// Texto?
	oPrint:Say(nTopo + 0007,nInicio + 0050,"Item"     ,oFont3,100,,,0) //60
	oPrint:Say(nTopo + 0007,nInicio + 0140,"Produto"  ,oFont3,100,,,0) //200
	oPrint:Say(nTopo + 0007,nInicio + 0360,"Descrição",oFont3,100,,,0) //600 //460 //320 //340 --> Descrição
	oPrint:Say(nTopo + 0007,nInicio + 1210,"UM"       ,oFont3,100,,,0) //1350
	oPrint:Say(nTopo + 0007,nInicio + 1290,"Qtd."     ,oFont3,100,,,0) //1460
	oPrint:Say(nTopo + 0007,nInicio + 1450,"Preço R$" ,oFont3,100,,,0) //1620
	oPrint:Say(nTopo + 0007,nInicio + 1750,"Total R$" ,oFont3,100,,,0) //1920
	oPrint:Say(nTopo + 0007,nInicio + 2050,"% ICMS"   ,oFont3,100,,,0)
	oPrint:Say(nTopo + 0007,nInicio + 2220,"% IPI"    ,oFont3,100,,,0)
			
	While QRY->(!Eof()) .AND. QRY->CJ_NUM == cOrcamento
		
		// Testa se o limite da pagina para a impressao dos produtos.
		// Caso ultrapasse o limite gera uma Nova Pagina
		If (nTopo + 0130) >= 2550
			
			// Linhas Horizontais  -  FIM Orçamento
			oPrint:Line(nTopo + 0040,nInicio + 0040,nTopo + 0040,nInicio + 2360)
		
			PrintTrailer(nPage,nTotal,nTopo)
			
			// Inicia uma Nova Pagina para Impressao
			oPrint:StartPage()
			
			// Define o modo de Impressão como Retrato
			oPrint:SetPortrait()   // SetLandscape -> Para definir como modo Paisagem
			
			// Funcao para impressao do Cabecalho
			PrintHeader(cOrcamento,cEmissao)
			
			// Incrementa o contador de Paginas
			nPage := nPage + 1
			nTopo := 450
			
   			// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// ³ Box, Linhas Verticais e Dados do Cabecalho de Orçamento.                                        ³
			// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// Box
			oPrint:Box(nTopo,nInicio + 0040, nTopo + 0050,nInicio + 2360)
			
			// Linhas Verticais
			oPrint:Line(nTopo,nInicio + 0120,nTopo + 0050,nInicio + 0120) //180
			oPrint:Line(nTopo,nInicio + 0300,nTopo + 0050,nInicio + 0300) //580 //440**
			oPrint:Line(nTopo,nInicio + 1190,nTopo + 0050,nInicio + 1190) //1330
			oPrint:Line(nTopo,nInicio + 1270,nTopo + 0050,nInicio + 1270) //1440
			oPrint:Line(nTopo,nInicio + 1430,nTopo + 0050,nInicio + 1430) //1600
			oPrint:Line(nTopo,nInicio + 1730,nTopo + 0050,nInicio + 1730) //1900
			oPrint:Line(nTopo,nInicio + 2030,nTopo + 0050,nInicio + 2030)
			oPrint:Line(nTopo,nInicio + 2200,nTopo + 0050,nInicio + 2200)
			
			// Texto
			oPrint:Say(nTopo + 0007,nInicio + 0050,"Item"     ,oFont3,100,,,0) //60
			oPrint:Say(nTopo + 0007,nInicio + 0140,"Produto"  ,oFont3,100,,,0) //200
			oPrint:Say(nTopo + 0007,nInicio + 0320,"Descrição",oFont3,100,,,0) //600 //460**
			oPrint:Say(nTopo + 0007,nInicio + 1350,"UM"       ,oFont3,100,,,0)
			oPrint:Say(nTopo + 0007,nInicio + 1290,"Qtd."     ,oFont3,100,,,0) //1460
			oPrint:Say(nTopo + 0007,nInicio + 1450,"Preço R$" ,oFont3,100,,,0)
			oPrint:Say(nTopo + 0007,nInicio + 1750,"Total R$" ,oFont3,100,,,0)
			oPrint:Say(nTopo + 0007,nInicio + 2050,"% ICMS"   ,oFont3,100,,,0)
			oPrint:Say(nTopo + 0007,nInicio + 2220,"% IPI"    ,oFont3,100,,,0)
			
		EndIf

		// Box, Linhas Verticais, Linhas Horizontais e Dados do Orçamento.
		aTexto	:= QJustTxt(AllTrim(QRY->CK_DESCRI), 50)
		nTamDes := Len(aTexto)//Len(AllTrim(QRY->CK_DESCRI)) / 30
		
		If nTamDes > 1      
			// Linhas Verticais - Divisao Colunas
			oPrint:Line(nTopo + 0030,nInicio + 0040,nTopo + 0090,nInicio + 0040)
			oPrint:Line(nTopo + 0030,nInicio + 0120,nTopo + 0090,nInicio + 0120) //180
			oPrint:Line(nTopo + 0030,nInicio + 0340,nTopo + 0090,nInicio + 0340) //580 //440
			oPrint:Line(nTopo + 0030,nInicio + 1190,nTopo + 0090,nInicio + 1190) //1330
			oPrint:Line(nTopo + 0030,nInicio + 1270,nTopo + 0090,nInicio + 1270) //1440
			oPrint:Line(nTopo + 0030,nInicio + 1430,nTopo + 0090,nInicio + 1430) //1600
			oPrint:Line(nTopo + 0030,nInicio + 1730,nTopo + 0090,nInicio + 1730) //1900
			oPrint:Line(nTopo + 0030,nInicio + 2030,nTopo + 0090,nInicio + 2030)
			oPrint:Line(nTopo + 0030,nInicio + 2200,nTopo + 0090,nInicio + 2200)
			oPrint:Line(nTopo + 0030,nInicio + 2360,nTopo + 0090,nInicio + 2360)
			
			// Impressao dos Campos dos Detalhes dos Produtos
			cPrcVen := AllTrim(Transform(QRY->CK_PRCVEN,PesqPict("SCK","CK_PRCVEN")))
			cValor  := AllTrim(Transform(QRY->CK_VALOR ,PesqPict("SCK","CK_VALOR")))
			
			oPrint:Say(nTopo + 0057,nInicio + 0050,AllTrim(QRY->CK_ITEM)               ,oFont2,100,,,0) //60
			oPrint:Say(nTopo + 0057,nInicio + 0140,AllTrim(QRY->CK_PRODUTO)            ,oFont2,100,,,0) //200
			// oPrint:Say(nTopo + 0057,nInicio + 0360,Substr(AllTrim(QRY->CK_DESCRI),2,30),oFont2,100,,,0) //600 **
			oPrint:Say(nTopo + 0057,nInicio + 0360,aTexto[1],oFont2,100,,,0) //600 **
			oPrint:Say(nTopo + 0057,nInicio + 1210,AllTrim(QRY->CK_UM)                 ,oFont2,100,,,0) //1350
			oPrint:Say(nTopo + 0057,nInicio + 1410,AllTrim(Str(QRY->CK_QTDVEN))        ,oFont2,100,,,1) //1580
			oPrint:Say(nTopo + 0057,nInicio + 1720,cPrcVen                             ,oFont2,100,,,1)
			oPrint:Say(nTopo + 0057,nInicio + 2020,cValor                              ,oFont2,100,,,1)
			oPrint:Say(nTopo + 0057,nInicio + 2190,getIcmValue(1)                      ,oFont2,100,,,1)
			oPrint:Say(nTopo + 0057,nInicio + 2340,getIpiValue(1)                      ,oFont2,100,,,1)
			
			getIcmValue(2)
			getIpiValue(2)

			nTamStr := 31
				
			For nCon := 2 to Int(nTamDes)			
				nTopo := nTopo + 50 
				
				// Testa se o limite da pagina para a impressao dos produtos.
				// Caso ultrapasse o limite gera uma Nova Pagina
				If (nTopo + 0130) >= 2550
					
					// Linhas Horizontais  -  FIM Orçamento
					oPrint:Line(nTopo + 0040,nInicio + 0040,nTopo + 0040,nInicio + 2360)
				
					PrintTrailer(nPage,nTotal,nTopo)
					
					// Inicia uma Nova Pagina para Impressao
					oPrint:StartPage()
					
					// Define o modo de Impressão como Retrato
					oPrint:SetPortrait()   // SetLandscape -> Para definir como modo Paisagem
					
					// Funcao para impressao do Cabecalho
					PrintHeader(cOrcamento,cEmissao)
					
					// Incrementa o contador de Paginas
					nPage := nPage + 1										
					nTopo := 450
					
					// Box, Linhas Verticais e Dados do Cabecalho de Orçamento.
					// Box
					oPrint:Box(nTopo,nInicio + 0040, nTopo + 0050,nInicio + 2360)
					
					// Linhas Verticais
					oPrint:Line(nTopo,nInicio + 0120,nTopo + 0050,nInicio + 0120) //180
					oPrint:Line(nTopo,nInicio + 0300,nTopo + 0050,nInicio + 0300) //580 //440
					oPrint:Line(nTopo,nInicio + 1190,nTopo + 0050,nInicio + 1190) //1330
					oPrint:Line(nTopo,nInicio + 1270,nTopo + 0050,nInicio + 1270) //1440
					oPrint:Line(nTopo,nInicio + 1430,nTopo + 0050,nInicio + 1430) //1600
					oPrint:Line(nTopo,nInicio + 1730,nTopo + 0050,nInicio + 1730) //1900
					oPrint:Line(nTopo,nInicio + 2030,nTopo + 0050,nInicio + 2030)
					oPrint:Line(nTopo,nInicio + 2200,nTopo + 0050,nInicio + 2200)
					
					// Texto
					oPrint:Say(nTopo + 0007,nInicio + 0050,"Item"     ,oFont3,100,,,0) //60
					oPrint:Say(nTopo + 0007,nInicio + 0140,"Produto"  ,oFont3,100,,,0) //200
					oPrint:Say(nTopo + 0007,nInicio + 0320,"Descrição",oFont3,100,,,0) //600
					oPrint:Say(nTopo + 0007,nInicio + 1350,"UM"       ,oFont3,100,,,0)
					oPrint:Say(nTopo + 0007,nInicio + 1290,"Qtd."     ,oFont3,100,,,0) //1460
					oPrint:Say(nTopo + 0007,nInicio + 1450,"Preço R$" ,oFont3,100,,,0)
					oPrint:Say(nTopo + 0007,nInicio + 1750,"Total R$" ,oFont3,100,,,0)
					oPrint:Say(nTopo + 0007,nInicio + 2050,"% ICMS"   ,oFont3,100,,,0)
					oPrint:Say(nTopo + 0007,nInicio + 2220,"% IPI"    ,oFont3,100,,,0)
					
				EndIf      
				
				// Linhas Verticais - Divisao Colunas
				oPrint:Line(nTopo + 0030,nInicio + 0040,nTopo + 0090,nInicio + 0040)				
				oPrint:Line(nTopo + 0030,nInicio + 0120,nTopo + 0090,nInicio + 0120) //180
				oPrint:Line(nTopo + 0030,nInicio + 0340,nTopo + 0090,nInicio + 0340) //580 //440
				oPrint:Line(nTopo + 0030,nInicio + 1190,nTopo + 0090,nInicio + 1190) //1330
				oPrint:Line(nTopo + 0030,nInicio + 1270,nTopo + 0090,nInicio + 1270) //1440
				oPrint:Line(nTopo + 0030,nInicio + 1430,nTopo + 0090,nInicio + 1430) //1600
				oPrint:Line(nTopo + 0030,nInicio + 1730,nTopo + 0090,nInicio + 1730) //1900
				oPrint:Line(nTopo + 0030,nInicio + 2030,nTopo + 0090,nInicio + 2030)
				oPrint:Line(nTopo + 0030,nInicio + 2200,nTopo + 0090,nInicio + 2200)
				oPrint:Line(nTopo + 0030,nInicio + 2360,nTopo + 0090,nInicio + 2360)   
				
				oPrint:Say(nTopo + 0057,nInicio + 0360, aTexto[nCon],oFont2,100,,,0) //600
			    
			 	nTamStr := nTamStr + 30				
			Next 			
		Else		
			// Linhas Verticais - Divisao Colunas
			oPrint:Line(nTopo + 0030,nInicio + 0040,nTopo + 0090,nInicio + 0040)			
			oPrint:Line(nTopo + 0030,nInicio + 0120,nTopo + 0090,nInicio + 0120) //180
			oPrint:Line(nTopo + 0030,nInicio + 0340,nTopo + 0090,nInicio + 0340) //580  //440 //300 //320 -> linha vertical esquerda descrição produto
			oPrint:Line(nTopo + 0030,nInicio + 1190,nTopo + 0090,nInicio + 1190) //1330 //1190
			oPrint:Line(nTopo + 0030,nInicio + 1270,nTopo + 0090,nInicio + 1270) //1440 //1270
			oPrint:Line(nTopo + 0030,nInicio + 1430,nTopo + 0090,nInicio + 1430) //1600 //1430
			oPrint:Line(nTopo + 0030,nInicio + 1730,nTopo + 0090,nInicio + 1730) //1900
			oPrint:Line(nTopo + 0030,nInicio + 2030,nTopo + 0090,nInicio + 2030)
			oPrint:Line(nTopo + 0030,nInicio + 2200,nTopo + 0090,nInicio + 2200)
			oPrint:Line(nTopo + 0030,nInicio + 2360,nTopo + 0090,nInicio + 2360)
			
			// Impressao dos Campos dos Detalhes dos Produtos
			cPrcVen := AllTrim(Transform(QRY->CK_PRCVEN,PesqPict("SCK","CK_PRCVEN")))
			cValor  := AllTrim(Transform(QRY->CK_VALOR ,PesqPict("SCK","CK_VALOR")))
			
			oPrint:Say(nTopo + 0057,nInicio + 0050,AllTrim(QRY->CK_ITEM)       ,oFont2,100,,,0)
			oPrint:Say(nTopo + 0057,nInicio + 0140,AllTrim(QRY->CK_PRODUTO)    ,oFont2,100,,,0)
			oPrint:Say(nTopo + 0057,nInicio + 0360,AllTrim(QRY->CK_DESCRI)     ,oFont2,100,,,0) //600 //460 aqui
			oPrint:Say(nTopo + 0057,nInicio + 1210,AllTrim(QRY->CK_UM)         ,oFont2,100,,,0) //1350
			oPrint:Say(nTopo + 0057,nInicio + 1410,AllTrim(Str(QRY->CK_QTDVEN)),oFont2,100,,,1) //1580
			oPrint:Say(nTopo + 0057,nInicio + 1720,cPrcVen                     ,oFont2,100,,,1)
			oPrint:Say(nTopo + 0057,nInicio + 2020,cValor                      ,oFont2,100,,,1)
			oPrint:Say(nTopo + 0057,nInicio + 2190,getIcmValue(1)              ,oFont2,100,,,1)
			oPrint:Say(nTopo + 0057,nInicio + 2340,getIpiValue(1)              ,oFont2,100,,,1)
			
			getIcmValue(2)
			getIpiValue(2)
		EndIf
		
		// Calculo do Valor Total do Orçamento de Venda
		nTotal += QRY->CK_VALOR 				
		nTopo  := nTopo + 0050
		
		// Impressão da Observação do Orçamento		
		nTamDes := Len(AllTrim(QRY->CK_OBS)) / 30
		
		If nTamDes > 2  
			// Testa se o limite da pagina para a impressao dos produtos.
			// Caso ultrapasse o limite gera uma Nova Pagina
			If (nTopo + 0130) >= 2550
						
				// Linhas Horizontais  -  FIM Orçamento
				oPrint:Line(nTopo + 0040,nInicio + 0040,nTopo + 0040,nInicio + 2360)
				
				PrintTrailer(nPage,nTotal,nTopo)
				
				// Inicia uma Nova Pagina para Impressao
				oPrint:StartPage()
				
				// Define o modo de Impressão como Retrato
				oPrint:SetPortrait()   // SetLandscape -> Para definir como modo Paisagem
				
				// Funcao para impressao do Cabecalho
				PrintHeader(cOrcamento,cEmissao)
				
				// Incrementa o contador de Paginas
				nPage := nPage + 1									
				nTopo := 450

				// ³ Box, Linhas Verticais e Dados do Cabecalho de Orçamento.
				// Box
				oPrint:Box(nTopo,nInicio + 0040, nTopo + 0050,nInicio + 2360)
				
				// Linhas Verticais
				oPrint:Line(nTopo,nInicio + 0120,nTopo + 0050,nInicio + 0120) //180
				oPrint:Line(nTopo,nInicio + 0440,nTopo + 0050,nInicio + 0440) //580
				oPrint:Line(nTopo,nInicio + 1190,nTopo + 0050,nInicio + 1190) //1330
				oPrint:Line(nTopo,nInicio + 1270,nTopo + 0050,nInicio + 1270) //1440
				oPrint:Line(nTopo,nInicio + 1430,nTopo + 0050,nInicio + 1430) //1600
				oPrint:Line(nTopo,nInicio + 1730,nTopo + 0050,nInicio + 1730) //1900
				oPrint:Line(nTopo,nInicio + 2030,nTopo + 0050,nInicio + 2030)
				oPrint:Line(nTopo,nInicio + 2200,nTopo + 0050,nInicio + 2200)
				
				// Texto
				oPrint:Say(nTopo + 0007,nInicio + 0050,"Item"     ,oFont3,100,,,0) //60
				oPrint:Say(nTopo + 0007,nInicio + 0140,"Produto"  ,oFont3,100,,,0) //200
				oPrint:Say(nTopo + 0007,nInicio + 0360,"Descrição",oFont3,100,,,0) //600 //460++
				oPrint:Say(nTopo + 0007,nInicio + 1350,"UM"       ,oFont3,100,,,0)
				oPrint:Say(nTopo + 0007,nInicio + 1290,"Qtd."     ,oFont3,100,,,0) //1460
				oPrint:Say(nTopo + 0007,nInicio + 1450,"Preço R$" ,oFont3,100,,,0)
				oPrint:Say(nTopo + 0007,nInicio + 1750,"Total R$" ,oFont3,100,,,0)
				oPrint:Say(nTopo + 0007,nInicio + 2050,"% ICMS"   ,oFont3,100,,,0)
				oPrint:Say(nTopo + 0007,nInicio + 2220,"% IPI"    ,oFont3,100,,,0)
			EndIf   
		       	// Linhas Verticais - Divisao Colunas
				oPrint:Line(nTopo + 0030,nInicio + 0040,nTopo + 0090,nInicio + 0040)				
				oPrint:Line(nTopo + 0030,nInicio + 0120,nTopo + 0090,nInicio + 0120) //180
				oPrint:Line(nTopo + 0030,nInicio + 0440,nTopo + 0090,nInicio + 0440) //580
				oPrint:Line(nTopo + 0030,nInicio + 1190,nTopo + 0090,nInicio + 1190) //1330
				oPrint:Line(nTopo + 0030,nInicio + 1270,nTopo + 0090,nInicio + 1270) //1440
				oPrint:Line(nTopo + 0030,nInicio + 1430,nTopo + 0090,nInicio + 1430) //1600
				oPrint:Line(nTopo + 0030,nInicio + 1730,nTopo + 0090,nInicio + 1730) //1900
				oPrint:Line(nTopo + 0030,nInicio + 2030,nTopo + 0090,nInicio + 2030)
				oPrint:Line(nTopo + 0030,nInicio + 2200,nTopo + 0090,nInicio + 2200)
				oPrint:Line(nTopo + 0030,nInicio + 2360,nTopo + 0090,nInicio + 2360)
				
				// Impressao dos Campos dos Detalhes dos Produtos
				oPrint:Say(nTopo + 0057,nInicio + 0600, Substr(AllTrim(QRY->CK_OBS),1,30),oFont2,100,,,0)
					
				nTamStr := 31
				
			For nCon := 2 to Int(nTamDes) + 1  
			
				nTopo := nTopo + 0050 

				// Testa se o limite da pagina para a impressao dos produtos.
				// Caso ultrapasse o limite gera uma Nova Pagina
				If (nTopo + 0130) >= 2550
					
					// Linhas Horizontais  -  FIM Orçamento
					oPrint:Line(nTopo + 0040,nInicio + 0040,nTopo + 0040,nInicio + 2360)
				
					PrintTrailer(nPage,nTotal,nTopo)
					
					// Inicia uma Nova Pagina para Impressao
					oPrint:StartPage()
					
					// Define o modo de Impressão como Retrato
					oPrint:SetPortrait()   // SetLandscape -> Para definir como modo Paisagem
					
					// Funcao para impressao do Cabecalho
					PrintHeader(cOrcamento,cEmissao)
					
					// Incrementa o contador de Paginas
					nPage := nPage + 1										
					nTopo := 450
					
					// Box, Linhas Verticais e Dados do Cabecalho de Orçamento.
					// Box
					oPrint:Box(nTopo,nInicio + 0040, nTopo + 0050,nInicio + 2360)
					
					// Linhas Verticais
					oPrint:Line(nTopo,nInicio + 0120,nTopo + 0050,nInicio + 0120) //180
					oPrint:Line(nTopo,nInicio + 0440,nTopo + 0050,nInicio + 0440) //580
					oPrint:Line(nTopo,nInicio + 1190,nTopo + 0050,nInicio + 1190) //1330
					oPrint:Line(nTopo,nInicio + 1270,nTopo + 0050,nInicio + 1270) //1440
					oPrint:Line(nTopo,nInicio + 1430,nTopo + 0050,nInicio + 1430) //1600
					oPrint:Line(nTopo,nInicio + 1730,nTopo + 0050,nInicio + 1730) //1900
					oPrint:Line(nTopo,nInicio + 2030,nTopo + 0050,nInicio + 2030)
					oPrint:Line(nTopo,nInicio + 2200,nTopo + 0050,nInicio + 2200)
					
					// Texto
					oPrint:Say(nTopo + 0007,nInicio + 0050,"Item"     ,oFont3,100,,,0) //60
					oPrint:Say(nTopo + 0007,nInicio + 0140,"Produto"  ,oFont3,100,,,0) //200
					oPrint:Say(nTopo + 0007,nInicio + 0360,"Descrição",oFont3,100,,,0) //600 //460++
					oPrint:Say(nTopo + 0007,nInicio + 1350,"UM"       ,oFont3,100,,,0)
					oPrint:Say(nTopo + 0007,nInicio + 1290,"Qtd."     ,oFont3,100,,,0) //1460
					oPrint:Say(nTopo + 0007,nInicio + 1450,"Preço R$" ,oFont3,100,,,0)
					oPrint:Say(nTopo + 0007,nInicio + 1750,"Total R$" ,oFont3,100,,,0)
					oPrint:Say(nTopo + 0007,nInicio + 2050,"% ICMS"   ,oFont3,100,,,0)
					oPrint:Say(nTopo + 0007,nInicio + 2220,"% IPI"    ,oFont3,100,,,0)
				EndIf
				
				// Linhas Verticais - Divisao Colunas
				oPrint:Line(nTopo + 0030,nInicio + 0040,nTopo + 0090,nInicio + 0040)				
				oPrint:Line(nTopo + 0030,nInicio + 0120,nTopo + 0090,nInicio + 0120) //180
				oPrint:Line(nTopo + 0030,nInicio + 0440,nTopo + 0090,nInicio + 0440) //580
				oPrint:Line(nTopo + 0030,nInicio + 1190,nTopo + 0090,nInicio + 1190) //1330
				oPrint:Line(nTopo + 0030,nInicio + 1270,nTopo + 0090,nInicio + 1270) //1440
				oPrint:Line(nTopo + 0030,nInicio + 1430,nTopo + 0090,nInicio + 1430) //1600
				oPrint:Line(nTopo + 0030,nInicio + 1730,nTopo + 0090,nInicio + 1730) //1900
				oPrint:Line(nTopo + 0030,nInicio + 2030,nTopo + 0090,nInicio + 2030)
				oPrint:Line(nTopo + 0030,nInicio + 2200,nTopo + 0090,nInicio + 2200)
				oPrint:Line(nTopo + 0030,nInicio + 2360,nTopo + 0090,nInicio + 2360)   
				
				oPrint:Say(nTopo + 0057,nInicio + 0600, Substr(AllTrim(QRY->CK_OBS),nTamStr,30)		,oFont2,100,,,0)
			    
			 	nTamStr := nTamStr + 30				
			Next			
			nTopo := nTopo + 0050			
		EndIf 		
		
		// Incrementa Contador da Quantidade de Itens no Orçamento de Venda
		nCont ++
		
		// Se o arquivo chegou ao fim, imprime rodape.
		If nCont > nCount
		
			nTotal := nTotal + QRY->CJ_FRETE + QRY->CJ_DESPESA
			
			// Box e Dados - Valor Total
			oPrint:Box(nTopo  + 0060,nInicio + 1600,nTopo + 0110,nInicio + 2200)
			oPrint:Line(nTopo + 0060,nInicio + 1900,nTopo + 0110,nInicio + 1900) 
			
			oPrint:Say(nTopo + 0067,nInicio + 1620,"Valor Produtos",oFont3,100,,,0)
			oPrint:Say(nTopo + 0067,nInicio + 2190," " + AllTrim(Transform(nTotal,PesqPict("SCK","CK_VALOR"))),oFont3,100,,,1)
			
			// Box e Dados - Valor Total
			oPrint:Box(nTopo  + 0060,nInicio + 0580,nTopo + 0110,nInicio + 1330)
		  //	oPrint:Line(nTopo + 0060,nInicio + 0955,nTopo + 0160,nInicio + 0955) 
			
		  	oPrint:Line(nTopo + 0110,nInicio + 0580,nTopo + 0110,nInicio + 1330) 
			
			oPrint:Say(nTopo + 0067,nInicio + 0600,"Valor Frete",oFont3,100,,,0)
			oPrint:Say(nTopo + 0067,nInicio + 1310," " + AllTrim(Transform(QRY->CJ_FRETE,PesqPict("SCJ","CJ_FRETE"))),oFont3,100,,,1)
			
		 //	oPrint:Say(nTopo + 0117,nInicio + 0600,"Valor Total ICM",oFont3,100,,,0)  
		  //  oPrint:Say(nTopo + 0117,nInicio + 0600,"Valor Total ",oFont3,100,,,0)  
		 // 	oPrint:Say(nTopo + 0117,nInicio + 1310," " + AllTrim(Transform(nTotaIcm,"@E 9,999,999.99")),oFont3,100,,,1)	
						
			oPrint:Box(nTopo  + 0120,nInicio + 1600,nTopo + 0170,nInicio + 2200)
			oPrint:Line(nTopo + 0120,nInicio + 1900,nTopo + 0170,nInicio + 1900) 
			
		 //	oPrint:Say(nTopo + 0127,nInicio + 1615,"Valor Total + IPI",oFont3,100,,,0)  
	    	 oPrint:Say(nTopo + 0127,nInicio + 1615,"Valor Total ",oFont3,100,,,0)  
	    	oPrint:Say(nTopo + 0127,nInicio + 2190," " + AllTrim(Transform(aTotaIpi[2],"@E 9,999,999.99")),oFont3,100,,,1)
		
			// Linhas Horizontais  -  FIM Orçamento
			oPrint:Line(nTopo + 0040,nInicio + 0040,nTopo + 0040,nInicio + 2360)
			
			
			// Imprime o Numero de Paginas
			oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0150,nInicio + 2360,"Página: " + Str(nPage) + " / " + AllTrim(nQtdPag)  ,oFont3,100,,,1)
			
			// Funcao de Impressao do Rodape. Parametro: Numero da linha atual
		   	PrintTrailer(nPage,nTotal,nTopo)
		EndIf  
				
		QRY->(dbskip())		
		
	EndDo
	
Return

// nOption = 1 (Alíquota) / 2 (Valor)
Static Function getIpiValue(nOption)

	Local cIpiValue := ""
	Local nIpiValue := 0
	Local cCalcIPI  := AllTrim(Posicione("SF4",1,xFilial("SF4")+QRY->CK_TES,"F4_IPI"))
	
	If nOption == 1
		cIpiValue := If(cCalcIPI == "S",AllTrim(Str(QRY->B1_IPI,4,1)),"0,0")
	Else
		If cCalcIPI == "S"
			nIpiValue := (QRY->CK_VALOR * ((QRY->B1_IPI)/100))
		EndIf
		
		// Calcula o Valor Total do Orçamento de Venda com IPI
		aTotaIpi[1] += nIpiValue
		aTotaIpi[2] += nIpiValue + QRY->CK_VALOR
		
		cIpiValue := AllTrim(Transform(nIpiValue,PesqPict("SD2","D2_VALIPI")))
	EndIf
	
Return cIpiValue

// nOption = 1 (Alíquota) / 2 (Valor)
Static Function getIcmValue(nOption)

	Local cIcmValue := ""
	Local nIcmValue := 0
	Local cCalcICM  := AllTrim(Posicione("SF4",1,xFilial("SF4")+QRY->CK_TES,"F4_ICM"))
	Local nAliqIcm  := getAliqICM()
	
	If nOption == 1
		cIcmValue := If(cCalcICM == "S",AllTrim(Str(nAliqIcm,4,1)),"0,0")
	Else
		If cCalcIcm == "S"
			nIcmValue := (QRY->CK_VALOR * ((nAliqIcm)/100))
		EndIf
		
		nTotaIcm += nIcmValue
		
		cIcmValue := AllTrim(Transform(nIcmValue,PesqPict("SD2","D2_VALICM")))
	EndIf
	
Return cIcmValue

Static Function getAliqICM()

	Local cQuery   := ""
	Local nAliqIcm := 0
	
	cQuery := "SELECT F7_SEQUEN,F7_ALIQINT,F7_ALIQEXT,F7_ALIQDST" + CRLF
	cQuery += "FROM "+RetSqlName("SF7")+" F7                    " + CRLF
	cQuery += "WHERE F7_FILIAL  = '"+xFilial("SF7")+"' AND      " + CRLF
	cQuery += "      F7_GRTRIB  = '"+QRY->B1_GRTRIB+"' AND      " + CRLF
	cQuery += "      F7_GRPCLI  = '"+QRY->A1_GRPTRIB+"' AND     " + CRLF
	cQuery += "      F7_EST     = '"+QRY->A1_EST+"' AND         " + CRLF
	cQuery += "      F7_TIPOCLI = '"+QRY->A1_TIPO+"' AND        " + CRLF
	cQuery += "      F7.D_E_L_E_T_ = ' '                        " + CRLF
	
	TCQUERY cQuery NEW ALIAS "QICM"
	
	If QICM->(!eof())
		nAliqIcm := QICM->F7_ALIQINT
	ElseIf QRY->B1_PICM > 0
		nAliqIcm := QRY->B1_PICM
	Else
		//nAliqIcm := GetMv("MV_ESTICM")
		nAliqIcm := Val(Subs(alltrim(getmv("MV_ESTICM")),AT(QRY->A1_EST,alltrim(getmv("MV_ESTICM")))+2,2))
	EndIf
	
	QICM->(dbCloseArea())
	
Return nAliqIcm

// Funcao para impressao do Rodape.
Static Function PrintTrailer(nPage,nTotal,nTopo)
	
	Local nInicio    := 0  // Indica a posicao da primeira coluna
	Local cDescontos := ""
	
	If QRY->CJ_DESC1 > 0
		cDescontos += AllTrim(Str(QRY->CJ_DESC1, 10, 2))
	EndIf
	
	If QRY->CJ_DESC2 > 0
		If !Empty(cDescontos)
			cDescontos += " + "
		Endif
		cDescontos += AllTrim(Str(QRY->CJ_DESC2, 10, 2))
	EndIf
	
	If QRY->CJ_DESC3 > 0
		If !Empty(cDescontos)
			cDescontos += " + "
		Endif
		cDescontos += AllTrim(Str(QRY->CJ_DESC3, 10, 2))
	EndIf
	
	If QRY->CJ_DESC4 > 0
		If !Empty(cDescontos)
			cDescontos += " + "
		Endif
		cDescontos += AllTrim(Str(QRY->CJ_DESC4, 10, 2))
	EndIf
		
	If nTopo <= (Mm2Pix(oPrint, oPrint:nVertSize()) - 0600)
	
		// Box Condicoes Gerais
		oPrint:Box(Mm2Pix(oPrint, oPrint:nVertSize()) - 0650,nInicio + 0040, Mm2Pix(oPrint, oPrint:nVertSize()) - 0290,nInicio + 2360)
		
		// Titulo Centralizado
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0630, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"Informações Gerais",oFont1,100,,,2)
			
		// Textos Posicionados à Esquerda
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0550,nInicio + 0060,"Forma de Pagamento"  									,oFont3,100,,,0)
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0550,nInicio + 0450,": " + QRY->CJ_CONDPAG + " - " + QRY->E4_DESCRI	,oFont5,100,,,0)
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0500,nInicio + 0060,"Transportadora" 				 			   			,oFont3,100,,,0)
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0500,nInicio + 0450,": (" + QRY->CJ_ZZTRANS + ") " + QRY->A4_NOME		,oFont5,100,,,0)
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0450,nInicio + 0060,"Nº do Orçamento Cliente" 				 				,oFont3,100,,,0)
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0450,nInicio + 0450,": " + QRY->CJ_COTCLI								,oFont5,100,,,0)
		
		If !Empty(cDescontos)
			oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0400,nInicio + 0060,"Descontos % "   ,oFont3,100,,,0)
			oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0400,nInicio + 0450,": " + cDescontos,oFont5,100,,,0)
		EndIf
				
		// Textos Posicionados à Esquerda
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0550, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"Validade" 				 		  ,oFont3,100,,,0)
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0550, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0250,": " + Dtoc(QRY->CJ_VALIDA),oFont5,100,,,0)
		//oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0450, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"Vendedor" 					 	  ,oFont3,100)
		//oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0450, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0250,": (" + QRY->CJ_ZZVEND1 + ") " + QRY->A3_NOME,oFont5,100)
				
	   //	 Box para a Mensagem da Nota
	    	oPrint:Box(Mm2Pix(oPrint, oPrint:nVertSize()) - 0270,nInicio + 0040, Mm2Pix(oPrint, oPrint:nVertSize()) - 0170  ,nInicio + 2360)
		
		// ESTOU BEM AQUI
		/*
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0260,nInicio + 0060,"Obs"                                       ,oFont3,100,,,0)
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0260,nInicio + 0200,".: " + Substr(QRY->CJ_OBSERV,1,100)      ,oFont5,100,,,0)
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0210,nInicio + 0200,Space(03) + Substr(QRY->CJ_OBSERV,101,100),oFont5,100,,,0)
		*/    
		 
		 	// Box para a observação
	    	oPrint:Box(Mm2Pix(oPrint, oPrint:nVertSize()) - 0270,nInicio + 0040, Mm2Pix(oPrint, oPrint:nVertSize()) - 0170  ,nInicio + 2360)
 		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0260,nInicio + 0060,"Obs" 			   						    ,oFont3,100,,,0)
   		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0260,nInicio + 0200,".: " + Transform(QRY->CJ_OBSERV,'@!S100'),oFont5,100,,,0)
		           
		// Imprime o Numero de Paginas
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0150,nInicio + 2360,"Página: " + Str(nPage) + " / " + AllTrim(nQtdPag)   ,oFont3,100,,,1)
		
		oPrint:EndPage()
		
	Else
		
		// Encerra a Pagina Atual
		oPrint:EndPage()
		
		// Inicia uma Nova Pagina para Impressao
		oPrint:StartPage()
		
		// Define o modo de Impressão como Retrato
		oPrint:SetPortrait()  // SetLandscape -> Para definir como modo Paisagem
		
		// Funcao para impressao do Cabecalho
		PrintHeader(cOrcamento,cEmissao)
		nTopo := 0420
		
		nPage += 1
	
		// Box Condicoes Gerais
		oPrint:Box(Mm2Pix(oPrint, oPrint:nVertSize()) - 0650,nInicio + 0040, Mm2Pix(oPrint, oPrint:nVertSize()) - 0290,nInicio + 2360)
		
		// Titulo Centralizado
		oPrint:Say (Mm2Pix(oPrint, oPrint:nVertSize()) - 0630, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"Informações Gerais"		,oFont1,100,,,2)
			
		// Textos Posicionados à Esquerda
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0550,nInicio + 0060,"Forma de Pagamento"  								 ,oFont3,100,,,0)
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0550,nInicio + 0450,": " + QRY->CJ_CONDPAG + " - " + QRY->E4_DESCRI,oFont5,100,,,0)
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0500,nInicio + 0060,"Transportadora" 				 			   		 ,oFont3,100,,,0)
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0500,nInicio + 0450,": (" + QRY->CJ_ZZTRANS + ") " + QRY->A4_NOME	 ,oFont5,100,,,0)
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0450,nInicio + 0060,"Nº Orçamento Cliente" 				 				 ,oFont3,100,,,0)
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0450,nInicio + 0450,": " + QRY->CJ_COTCLI							 ,oFont5,100,,,0)
				
		If !Empty(cDescontos)
			oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0400,nInicio + 0060,"Descontos % "   ,oFont3,100,,,0)
			oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0400,nInicio + 0450,": " + cDescontos,oFont5,100,,,0)
		EndIf
				
		// Textos Posicionados à Esquerda
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0550, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"Validade" 				 		  ,oFont3,100,,,0)
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0550, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0250,": " + Dtoc(QRY->CJ_VALIDA),oFont5,100,,,0)
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0450, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2,"Vendedor" 					 	  ,oFont3,100)
		//oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0450, Mm2Pix(oPrint, oPrint:nHorzSize()) / 2 + 0250,": (" + QRY->CJ_ZZVEND1 + ") " + QRY->A3_NOME,oFont5,100)
				
		// Box para a Mensagem da Nota
	 
	  //	oPrint:Box(Mm2Pix(oPrint, oPrint:nVertSize()) - 0270,nInicio + 0040, Mm2Pix(oPrint, oPrint:nVertSize()) - 0170  ,nInicio + 2360)
	//	oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0260,nInicio + 0060,"Obs" 			   						    ,oFont3,100,,,0)
	 //	oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0260,nInicio + 0200,".: " + Transform(QRY->CJ_OBSERV,'@!S100'),oFont5,100,,,0)
		 
		   			                   
		// Imprime o Numero de Paginas
		oPrint:Say(Mm2Pix(oPrint, oPrint:nVertSize()) - 0150,nInicio + 2360,"Página: " + Str(nPage) + " / " + AllTrim(nQtdPag),oFont3,100,,,1)
				
		oPrint:EndPage()
			
	EndIf
		
Return
	
/*
Retorna a Largura da Pagina em Pixel.
*/
/*
Retirado metodo oPrint:nLogPixelX(), pois estava ocorrendo casos em clientes 
em que a linha impressa que utliza a funcao MM2PIX saia desconfigurada

Local nValor := (nMm * oPrint:nLogPixelX()) / 25.4
*/
Static Function Mm2Pix(oPrint,nMm)

	Local nValor := (nMm * 300) / 25.4
	
Return nValor

	
/*
Valida se existe um grupo de perguntas caso contrario o grupo de perguntas é criado.
*/
/*
Static Function ValidPerg(cPerg)
	
	Local _sAlias := Alias()
	Local aRegs := {}
	Local i,j
	
	dbSelectArea("SX1")
	dbSetOrder(1)

	cPerg := Padr(cPerg,Len(SX1->X1_GRUPO))
		
	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd(aRegs,{cPerg,"01","Orçamento de " ,"","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SCJ"})
	aAdd(aRegs,{cPerg,"02","Orçamento até ","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SCJ"})
	aAdd(aRegs,{cPerg,"03","Data de "      ,"","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Data até "     ,"","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				EndIf
			Next
			MsUnlock()
		EndIf
	Next
	
	dbSelectArea(_sAlias)
  
Return .T.
*/
