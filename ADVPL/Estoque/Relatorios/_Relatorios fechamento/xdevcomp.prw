//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} XDEVCOMP
Relatório - Devolucao de compras          
@author Nunes
@since 21/06/2019
@version 1.0
	@example
	u_XDEVCOMP()
	
/*/
	
User Function XDEVCOMP()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	
	//Definições da pergunta
	cPerg := " "
	
	/*Se a pergunta não existir, zera a variável
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM
	If ! SX1->(DbSeek(cPerg))
		cPerg := Nil
	EndIf
	
	Pergunte(cPerg,.T.) //CHAMAR PERGUNTAS AO CLICAR NO RELATÓRIO
	*/
	
	IF Perg (cPerg)
		
	//Cria as definições do relatório
	oReport := fReportDef()
	
	//Será enviado por e-Mail?
	If lEmail
		oReport:nRemoteType := NO_REMOTE
		oReport:cEmail := cPara
		oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
		oReport:SetPreview(.F.)
		oReport:Print(.F., "", .T.)
	//Senão, mostra a tela
	Else
		oReport:PrintDialog()
	EndIf
 EndIF	
	RestArea(aArea)
Return
	
/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Desc:  Função que monta a definição do relatório                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	Local oBreak := Nil
	Local oFunTot1 := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New(	"XDEVCOMP",;		//Nome do Relatório
								"Devolucao de compras",;		//Título
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão
								)		//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetPortrait()
	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"Dados",;		//Descrição da seção
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(oSectDad, "D2_FILIAL", "QRY_AUX", "Filial", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_ITEM", "QRY_AUX", "Item", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_COD", "QRY_AUX", "Produto", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_DESC", "QRY_AUX", "Descricao", /*Picture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_TIPO", "QRY_AUX", "Tipo", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_TIPOBN", "QRY_AUX", "Tipo BN", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_CONTA", "QRY_AUX", "C.contabil produto", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_UM", "QRY_AUX", "Unidade", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_QUANT", "QRY_AUX", "Quantidade", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_PRCVEN", "QRY_AUX", "Vlr.Unitario", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_TOTAL", "QRY_AUX", "Vlr.Total", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_TES", "QRY_AUX", "Tipo Saida", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "F4_TEXTO", "QRY_AUX", "Txt Padrao", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_CF", "QRY_AUX", "Cod. Fiscal", /*Picture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_EMISSAO", "QRY_AUX", "Emissao", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_DOC", "QRY_AUX", "Num. Docto.", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_SERIE", "QRY_AUX", "Serie", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_NFORI", "QRY_AUX", "N.F.Original", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_SERIORI", "QRY_AUX", "Serie Orig.", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_CLIENTE", "QRY_AUX", "Cliente", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_LOJA", "QRY_AUX", "Loja", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "A2_NREDUZ", "QRY_AUX", "N Fantasia", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D2_CUSTO1", "QRY_AUX", "Custo", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	//Definindo a quebra
	oBreak := TRBreak():New(oSectDad,{|| QRY_AUX->(B1_TIPO) },{|| "SEPARACAO DO RELATORIO" })
	oSectDad:SetHeaderBreak(.T.)
	
	//Totalizadores
	oFunTot1 := TRFunction():New(oSectDad:Cell("D2_CUSTO1"),,"SUM",oBreak,,"@E 999,999,999.99")
	oFunTot1:SetEndReport(.F.)
Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT D2_FILIAL,D2_ITEM,D2_COD,B1_DESC,B1_TIPO,B1_TIPOBN,B1_CONTA,D2_UM,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_TES,F4_TEXTO,D2_CF,D2_EMISSAO,D2_DOC,D2_SERIE,D2_NFORI,D2_SERIORI,D2_CLIENTE,D2_LOJA,A2_NREDUZ,D2_CUSTO1 FROM " + retSqlName("SD2") + " SD2"		+ STR_PULA
	cQryAux += "   INNER JOIN " + retSqlName("SF4") + " SF4 ON SD2.D2_TES = SF4.F4_CODIGO"		+ STR_PULA
	cQryAux += "   INNER JOIN " + retSqlName("SB1") + " SB1 ON SD2.D2_COD = SB1.B1_COD"		+ STR_PULA
	cQryAux += "   INNER JOIN " + retSqlName("SA2") + " SA2 ON D2_CLIENTE+D2_LOJA=SA2.A2_COD+SA2.A2_LOJA"		+ STR_PULA
	cQryAux += "    WHERE SD2.D2_FILIAL  = '"+XFILIAL("SD2")+"'"		+ STR_PULA
	cQryAux += "      AND SD2.D2_EMISSAO>= '"+DTOS(MV_PAR01)+"'"		+ STR_PULA
	cQryAux += "      AND SD2.D2_EMISSAO<= '"+DTOS(MV_PAR02)+"'"		+ STR_PULA
	cQryAux += "      AND SF4.F4_FILIAL  = '"+XFILIAL("SF4")+"'"		+ STR_PULA
	cQryAux += "      AND SD2.D2_TES     = SF4.F4_CODIGO"		+ STR_PULA
	cQryAux += "      AND SF4.F4_ESTOQUE = 'S'"		+ STR_PULA
	cQryAux += "      AND SF4.F4_PODER3  IN (' ','N')"		+ STR_PULA
	cQryAux += "      AND SD2.D2_TIPO    = 'D'"		+ STR_PULA
	cQryAux += "      AND SD2.D2_ORIGLAN <> 'LF'"		+ STR_PULA
	cQryAux += "      AND SD2.D2_REMITO  = '         '"		+ STR_PULA
	cQryAux += "      AND SD2.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "      AND SF4.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "      AND SB1.B1_FILIAL  = '"+XFILIAL("SB1")+"'"		+ STR_PULA
	cQryAux += "      AND SB1.B1_COD     = SD2.D2_COD"		+ STR_PULA
	cQryAux += "      AND SB1.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "      AND SA2.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "	  GROUP BY SB1.B1_TIPO,SB1.B1_TIPOBN,SB1.B1_CONTA,SD2.D2_FILIAL,SD2.D2_ITEM,SD2.D2_COD,SB1.B1_DESC,SD2.D2_UM,SD2.D2_QUANT,SD2.D2_PRCVEN,SD2.D2_TOTAL,SD2.D2_TES,SF4.F4_TEXTO,SD2.D2_CF,SD2.D2_EMISSAO,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_NFORI,SD2.D2_SERIORI,SD2.D2_CLIENTE,SD2.D2_LOJA,SA2.A2_NREDUZ,SD2.D2_CUSTO1 "		+ STR_PULA
	cQryAux += "	  ORDER BY SB1.B1_TIPO,SD2.D2_EMISSAO,SD2.D2_COD ASC"		+ STR_PULA
		
	cQryAux := ChangeQuery(cQryAux)
	
	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	TCSetField("QRY_AUX", "D2_EMISSAO", "D")
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		//Incrementando a régua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		QRY_AUX->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())
	
	RestArea(aArea)
Return

/**************************************************************************
Perguntas Relatorio
***************************************************************************/
Static Function Perg(cPerg)
Local aParBox 		:= {}
//Local aCombo	:= {"1=Metal","2=Plastico"}

aadd(aParBox,{1,"Data De",CTOD("")	,"","","","",50,.F.	})	//MV_PAR01
aadd(aParBox,{1,"Data Até",CTOD("")	,"","","","",50,.T.	})	//MV_PAR02

/*aadd(aParBox,{1,"Filial De",Space(TamSX3("Z04_FILIAL")[1])	,"","","FWSM0","",50,.F.	})	//MV_PAR01
aadd(aParBox,{1,"Filial Até",Space(TamSX3("Z04_FILIAL")[1])	,"","","FWSM0","",50,.T.	})	//MV_PAR02
aadd(aParBox,{1,"Data De",CTOD("")	,"","","","",50,.F.	})	//MV_PAR03
aadd(aParBox,{1,"Data Até",CTOD("")	,"","","","",50,.T.	})	//MV_PAR04
aadd(aParBox,{1,"Order De",Space(TamSX3("ZZ3_ORDER")[1])	,"","","","",50,.F.	})	//MV_PAR05
aadd(aParBox,{1,"Order Até",Space(TamSX3("ZZ3_ORDER")[1])	,"","","","",50,.T.	})	//MV_PAR06
aadd(aParBox,{1,"Produto De",Space(TamSX3("B1_COD")[1])	    ,"","","SB1","",50,.F.	})	//MV_PAR07
aadd(aParBox,{1,"Produto Até",Space(TamSX3("B1_COD")[1])	,"","","SB1","",50,.T.	})	//MV_PAR08
aadd(aParBox,{1,"Coleta De" ,0	,"@E 999999999","","","",50,.F.	})	//MV_PAR09
aadd(aParBox,{1,"Coleta Até",0	,"@E 999999999","","","",50,.T.	})	//MV_PAR10
AADD(aParBox,{2,"Tipo 			  	"," ",aCombo,50,"",.T.})									//MV_PAR09
*/
lRet := ParamBox(aParBox,cPerg,,,,,,,,cPerg,.T.,.T.)
	
return lRet