#INCLUDE "PROTHEUS.CH"

User Function xmatr320() //ENTRADAS E SAÍDAS POR CODIGO DE PRODUTO
Local oReport


oReport:= ReportDef()
oReport:PrintDialog()

Return NIl

Static Function ReportDef()

Local oReport
Local oSection1
Local oCell
Local cTamVlr  := 20
Local cPictVl  := PesqPict("SD2","D2_CUSTO1",20)
Local cProcNam := GetSPName("MAT056","22")


oReport:= TReport():New("xmatr320","Resumo das Entradas e Saidas - B1_COD","MTR320", {|oReport| ReportPrint(oReport)},"Este programa mostra um resumo, por CODIGO de material, de todas as suas"+" "+"entradas e saidas. A coluna SALDO INICIAL e o resultado da soma das"+" "+"outras colunas do relatorio e nao o saldo inicial cadastrado no estoque.") //"Resumo das Entradas e Saidas"##"Este programa mostra um resumo ,por tipo de material ,de todas  as  suas"##"entradas e saidas. A coluna SALDO INICIAL  e' o  resultado da  soma  das"##"outras colunas do relatorio e nao o saldo inicial cadastrado no estoque."
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)


// Verifica as perguntas selecionadas                           


// Variaveis utilizadas para parametros                         
// mv_par01     // Almoxarifado De                              
// mv_par02     // Almoxarifado Ate                             
// mv_par03     // Tipo inicial                                 
// mv_par04     // Tipo final                                   
// mv_par05     // Produto inicial                              
// mv_par06     // Produto Final                                
// mv_par07     // Emissao de                                   
// mv_par08     // Emissao ate                                  
// mv_par09     // moeda selecionada ( 1 a 5 )                  
// mv_par10     // Saldo a considerar : Atual / Fechamento      
// mv_par11     // Considera Saldo MOD: Sim / Nao               
// mv_par12     // Imprime OPs geradas pelo SIGAMNT? Sim / Nao
Pergunte("MTR320",.F.)

oSection1 := TRSection():New(oReport,"Movimentação dos Produtos",{"SB1","SD1","SD2","SD3"}) //"Movimentacoes dos Produtos"
oSection1 :SetTotalInLine(.F.)
oSection1 :SetNoFilter("SD1")
oSection1 :SetNoFilter("SD2")
oSection1 :SetNoFilter("SD3")
If ExistProc( cProcNam, VerIDProc())
	oSection1 :SetNoFilter("SB1")
EndIf
TRCell():New(oSection1,"cTipant"	,"   ",/*Titulo*/			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//oSection1:Cell("cTipant"):GetFieldInfo("B1_TIPO")
oSection1:Cell("cTipant"):GetFieldInfo("B1_COD") //JONI

TRCell():New(oSection1,"cDescr"		,"   ","Descrição"							,PesqPict("SB1","B1_DESC",20),TAMSX3("B1_COD")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Saldo"##"Inicial"
TRCell():New(oSection1,"nSalant"	,"   ","Saldo"+CRLF+"Inicial"				,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Saldo"##"Inicial"
TRCell():New(oSection1,"nCompras"	,"   ","Compras"							,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Compras"
TRCell():New(oSection1,"nReqCons"	,"   ","Movimentacoes"+CRLF+"Internas"		,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Movimentacoes"##"Internas"
TRCell():New(oSection1,"nReqProd"	,"   ","Requisicoes"+CRLF+"para Producao"	,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Requisicoes"##"para Producao"
TRCell():New(oSection1,"nReqTrans"	,"   ","Transferencias"						,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Transferencias"
TRCell():New(oSection1,"nProducao"	,"   ","Producao"							,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Producao"
TRCell():New(oSection1,"nVendas"	,"   ","Vendas"								,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Vendas"
TRCell():New(oSection1,"nReqOutr"	,"   ","Transf. p/"+CRLF+"Processo"			,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Transf. p/"##"Processo"
TRCell():New(oSection1,"nDevVendas"	,"   ","Devolucao de"+CRLF+"Vendas"			,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Devolucao de"##"Vendas"
TRCell():New(oSection1,"nDevComprs"	,"   ","Devolucao de"+CRLF+"Compras"		,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Devolucao de"##"Compras"
TRCell():New(oSection1,"nEntrTerc"	,"   ","Entrada Poder"+CRLF+"Terceiros"		,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Entrada Poder"##"Terceiros"
TRCell():New(oSection1,"nSaiTerc"	,"   ","Saida Poder"+CRLF+"Terceiros"		,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Saida Poder"##"Terceiros"
TRCell():New(oSection1,"nSaldoAtu"	,"   ","Saldo"+CRLF+"Atual"					,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Saldo"##"Atual"

TRFunction():New(oSection1:Cell("nSalant"   ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
TRFunction():New(oSection1:Cell("nCompras"  ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
TRFunction():New(oSection1:Cell("nReqCons"  ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
TRFunction():New(oSection1:Cell("nReqProd"  ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
TRFunction():New(oSection1:Cell("nReqTrans" ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
TRFunction():New(oSection1:Cell("nProducao" ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
TRFunction():New(oSection1:Cell("nVendas"   ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
TRFunction():New(oSection1:Cell("nReqOutr"  ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
TRFunction():New(oSection1:Cell("nDevVendas"),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
TRFunction():New(oSection1:Cell("nDevComprs"),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
TRFunction():New(oSection1:Cell("nEntrTerc" ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
TRFunction():New(oSection1:Cell("nSaiTerc"  ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
TRFunction():New(oSection1:Cell("nSaldoAtu" ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)

Return(oReport)


Static Function ReportPrint(oReport,cAliasSDH)

Local oSection1:= oReport:Section(1)
Local cSelectD1 := '', cWhereD1 := ''
Local cSelectD2 := '', cWhereD2 := ''
Local cSelectD3 := '', cWhereD3 := ''
Local cSelectB2 := '', cWhereB2 := ''
Local lContinua :=.T.
Local lPassou   :=.F.
Local lTotal    :=.F.
Local nValor    := 0
Local cProduto  := ""
Local cFiltroUsr:= ""
Local nSalant,nCompras,nReqCons,nReqProd,nEntrTerc,nReqMNT
Local nSaiTerc,cTipAnt,cCampo,cMoeda,nReqTrans,nProducao
Local nVendas,nSaldoAtu,nReqOutr,nDevVendas,nDevComprs
Local cSelect	:= ''
Local cSelect1	:= ''
Local aStrucSB1 := SB1->(dbStruct())
Local cName		:= ""
Local nX        := 0
Local aResult   := {'',0,0,0,0,0,0,0,0,0,0,0,0,0}
Local cProcNam  := GetSPName("MAT056","22")
Local lD3Servico:= GetMV('MV_D3SERVI', .F., 'N')=='S'
Local cAliasTop := ""

cMoeda := LTrim(Str(mv_par09))
cMoeda := IIF(cMoeda=="0","1",cMoeda)
oReport:SetTitle( oReport:Title()+'EM'+AllTrim(GetMv("MV_SIMB"+cMoeda))+" - "+"Período de "+dtoc(mv_par07,"ddmmyy")+" Até "+dtoc(mv_par08,"ddmmyy"))

oReport:NoUserFilter()  // Desabilita a aplicacao do filtro do usuario no filtro/query das secoes

cFiltroUsr := oSection1:GetAdvplExp()

dbSelectArea("SD2")
dbSetOrder(1)
nRegs := SD2->(LastRec())

dbSelectArea("SD3")
dbSetOrder(1)
nRegs += SD3->(LastRec())

dbSelectArea("SD1")
dbSetOrder(1)
nRegs += SD1->(LastRec())

//Transforma parametros Range em expressao SQL                            

MakeSqlExpr(oReport:uParam)

cAliasTop := GetNextAlias()

//Query do relatorio da secao 1   																		  
oReport:Section(1):BeginQuery()

cSelect  := "B1_COD,B1_TIPO,B1_UM,B1_GRUPO,B1_DESC,"
cSelect1 := "%"
cSelect2 := "%"
oSection1:GetAdvplExp()
If !Empty(cFiltroUsr)
	For nX := 1 To SB1->(FCount())
		cName := SB1->(FieldName(nX))
		If AllTrim( cName ) $ cFiltroUsr
			If aStrucSB1[nX,2] <> "M"
				If !cName $ cSelect
					cSelect1 += cName + ","
				EndIf
			EndIf
		EndIf
	Next
	cSelect1 += "%"
Endif


//Complemento do SELECT da tabela SD1                                     

cSelectD1 := "% D1_CUSTO"
If mv_par09 > 1
	cSelectD1 += Str(mv_par09,1,0) // Coloca a Moeda do Custo
EndIf
cSelectD1 += " CUSTO,"
cSelectD1 += "%"


//Complemento do WHERE da tabela SD1                                      

cWhereD1 := "%"
If cPaisLoc <> "BRA"
	cWhereD1 += " AND D1_REMITO = '" + Space(TamSx3("D1_REMITO")[1]) + "' "
EndIf
cWhereD1 += "%"


//Complemento do SELECT da tabela SD2                                     

cSelectD2 := "% D2_CUSTO"
cSelectD2 += Str(mv_par09,1,0) // Coloca a Moeda do Custo
cSelectD2 += " CUSTO,"
cSelectD2 += "%"


//Complemento do WHERE da tabela SD2                                      

cWhereD2 := "%"
If cPaisLoc <> "BRA"
	cWhereD2 += " AND D2_REMITO = '" + Space(TamSx3("D2_REMITO")[1]) + "' "
EndIf
cWhereD2 += "%"


//Complemento do SELECT da tabelas SD3                                    

cSelectD3 := "% D3_CUSTO"
cSelectD3 += Str(mv_par09,1,0) // Coloca a Moeda do Custo
cSelectD3 +=	" CUSTO,"
cSelectD3 += "%"


//Complemento do WHERE da tabela SD3                                      

cWhereD3 := "%"
If SuperGetMV('MV_D3ESTOR', .F., 'N') == 'N'
	cWhereD3 += " AND D3_ESTORNO <> 'S'"
EndIf
If SuperGetMV('MV_D3SERVI', .F., 'N') == 'N' .And. IntDL()
	cWhereD3 += " AND ( (D3_SERVIC = '   ') OR (D3_SERVIC <> '   ' AND D3_TM <= '500')  "
	cWhereD3 += " OR  (D3_SERVIC <> '   ' AND D3_TM > '500' AND D3_LOCAL ='"+SuperGetMV('MV_CQ', .F., '98')+"') )"
EndIf
cWhereD3 += "%"

BeginSql Alias cAliasTop
	
	SELECT 	'SD1' ARQ, 				//-- 01 ARQ
	SB1.B1_COD PRODUTO, 	//-- 02 PRODUTO
	SB1.B1_TIPO, 			//-- 03 TIPO
	SB1.B1_UM,   			//-- 04 UM
	SB1.B1_GRUPO,      	//-- 05 GRUPO
	SB1.B1_DESC,      		//-- 06 DESCR
	%Exp:cSelect1%			//-- 07 FILTRO COM CAMPOS DO USUARIO
	D1_DTDIGIT DATA,		//-- 08 DATA
	D1_TES TES,			//-- 09 TES
	D1_CF CF,				//-- 10 CF
	D1_NUMSEQ SEQUENCIA,	//-- 11 SEQUENCIA
	D1_DOC DOCUMENTO,		//-- 12 DOCUMENTO
	D1_SERIE SERIE,		//-- 13 SERIE
	D1_QUANT QUANTIDADE,	//-- 14 QUANTIDADE
	D1_QTSEGUM QUANT2UM,	//-- 15 QUANT2UM
	D1_LOCAL ARMAZEM,		//-- 16 ARMAZEM
	' ' OP,				//-- 17 OP
	D1_FORNECE FORNECEDOR,	//-- 18 FORNECEDOR
	D1_LOJA LOJA,			//-- 19 LOJA
	D1_TIPO TIPONF,		//-- 20 TIPO NF
	%Exp:cSelectD1%		//-- 21 CUSTO / 21 B1_CODITE
	SD1.R_E_C_N_O_ NRECNO  //-- 22 RECNO
	
	FROM %table:SB1% SB1,%table:SD1% SD1,%table:SF4% SF4
	
	WHERE SB1.B1_COD     =  SD1.D1_COD		AND  	SD1.D1_FILIAL  =  %xFilial:SD1%		AND
	SF4.F4_FILIAL  =  %xFilial:SF4%  	AND 	SD1.D1_TES     =  SF4.F4_CODIGO		AND
	SF4.F4_ESTOQUE =  'S'				AND 	SD1.D1_DTDIGIT >= %Exp:mv_par07%   AND
	SD1.D1_DTDIGIT <= %Exp:mv_par08%	AND		SD1.D1_ORIGLAN <> 'LF'				AND
	SD1.D1_LOCAL   >= %Exp:mv_par01%	AND		SD1.D1_LOCAL   <= %Exp:mv_par02%	AND
	SD1.%NotDel%						AND 	SF4.%NotDel%                        AND
	SB1.B1_COD     >= %Exp:mv_par05%	AND		SB1.B1_COD     <= %Exp:mv_par06% 	AND
	SB1.B1_FILIAL  =  %xFilial:SB1%	AND		SB1.B1_TIPO    >= %Exp:mv_par03%	AND
	SB1.B1_TIPO    <= %Exp:mv_par04%	AND		SB1.%NotDel%
	%Exp:cWhereD1%
	
	UNION
	
	SELECT 'SD2',	     			//-- 01 ARQ
	SB1.B1_COD,	        	//-- 02 PRODUTO
	SB1.B1_TIPO,		    //-- 03 TIPO
	SB1.B1_UM,				//-- 04 UM
	SB1.B1_GRUPO,		    //-- 05 GRUPO
	SB1.B1_DESC,		    //-- 06 DESCR
	%Exp:cSelect1%			//-- 07 FILTRO COM CAMPOS DO USUARIO
	D2_EMISSAO,				//-- 08 DATA
	D2_TES,					//-- 09 TES
	D2_CF,					//-- 10 CF
	D2_NUMSEQ,				//-- 11 SEQUENCIA
	D2_DOC,					//-- 12 DOCUMENTO
	D2_SERIE,				//-- 13 SERIE
	D2_QUANT,				//-- 14 QUANTIDADE
	D2_QTSEGUM,				//-- 15 QUANT2UM
	D2_LOCAL,				//-- 16 ARMAZEM
	' ',					//-- 17 OP
	D2_CLIENTE,				//-- 18 FORNECEDOR
	D2_LOJA,				//-- 19 LOJA
	D2_TIPO,				//-- 20 TIPO NF
	%Exp:cSelectD2%			//-- 21 CUSTO
	SD2.R_E_C_N_O_ SD2RECNO //-- 22 RECNO
	
	FROM %table:SB1% SB1,%table:SD2% SD2,%table:SF4% SF4
	
	WHERE	SB1.B1_COD     =  SD2.D2_COD		AND	SD2.D2_FILIAL  = %xFilial:SD2%		AND
	SF4.F4_FILIAL  = %xFilial:SF4% 		AND	SD2.D2_TES     =  SF4.F4_CODIGO		AND
	SF4.F4_ESTOQUE =  'S'				AND	SD2.D2_EMISSAO >= %Exp:mv_par07%	AND
	SD2.D2_EMISSAO <= %Exp:mv_par08%	AND	SD2.D2_ORIGLAN <> 'LF'				AND
	SD2.D2_LOCAL   >= %Exp:mv_par01%	AND	SD2.D2_LOCAL   <= %Exp:mv_par02%	AND
	SD2.%NotDel%						AND SF4.%NotDel%						AND
	SB1.B1_COD     >= %Exp:mv_par05%	AND		SB1.B1_COD  <= %Exp:mv_par06% 	AND
	SB1.B1_FILIAL  =  %xFilial:SB1%	    AND		SB1.B1_TIPO >= %Exp:mv_par03%	AND
	SB1.B1_TIPO    <= %Exp:mv_par04%	AND		SB1.%NotDel%
	%Exp:cWhereD2%
	
	UNION
	
	SELECT 	'SD3',	    			//-- 01 ARQ
	SB1.B1_COD,	    	    //-- 02 PRODUTO
	SB1.B1_TIPO,		    //-- 03 TIPO
	SB1.B1_UM,				//-- 04 UM
	SB1.B1_GRUPO,	     	//-- 05 GRUPO
	SB1.B1_DESC,		    //-- 06 DESCR
	%Exp:cSelect1%			//-- 07 FILTRO COM CAMPOS DO USUARIO
	D3_EMISSAO,				//-- 08 DATA
	D3_TM,					//-- 09 TES
	D3_CF,					//-- 10 CF
	D3_NUMSEQ,				//-- 11 SEQUENCIA
	D3_DOC,					//-- 12 DOCUMENTO
	' ',					//-- 13 SERIE
	D3_QUANT,				//-- 14 QUANTIDADE
	D3_QTSEGUM,				//-- 15 QUANT2UM
	D3_LOCAL,				//-- 16 ARMAZEM
	D3_OP,					//-- 17 OP
	' ',					//-- 18 FORNECEDOR
	' ',					//-- 19 LOJA
	' ',					//-- 20 TIPO NF
	%Exp:cSelectD3%			//-- 21 CUSTO
	SD3.R_E_C_N_O_ SD3RECNO //-- 22 RECNO
	
	FROM %table:SB1% SB1,%table:SD3% SD3
	
	WHERE	SB1.B1_COD     =  SD3.D3_COD 		AND SD3.D3_FILIAL  =  %xFilial:SD3%		AND
	SD3.D3_EMISSAO >= %Exp:mv_par07%	AND	SD3.D3_EMISSAO <= %Exp:mv_par08%	AND
	SD3.D3_LOCAL   >= %Exp:mv_par01%	AND	SD3.D3_LOCAL   <= %Exp:mv_par02%	AND
	SD3.%NotDel%						                                   		AND
	SB1.B1_COD     >= %Exp:mv_par05%	AND		SB1.B1_COD  <= %Exp:mv_par06% 	AND
	SB1.B1_FILIAL  =  %xFilial:SB1%	    AND		SB1.B1_TIPO >= %Exp:mv_par03%	AND
	SB1.B1_TIPO    <= %Exp:mv_par04%	AND		SB1.%NotDel%
	%Exp:cWhereD3%
	
	UNION
	
	SELECT 	'SB1',			     	//-- 01 ARQ
	SB1.B1_COD,	    	    //-- 02 PRODUTO
	SB1.B1_TIPO,		    //-- 03 TIPO
	SB1.B1_UM,				//-- 04 UM
	SB1.B1_GRUPO,		    //-- 05 GRUPO
	SB1.B1_DESC,		    //-- 06 DESCR
	%Exp:cSelect1%			//-- 07 FILTRO COM CAMPOS DO USUARIO
	' ',					//-- 08 DATA
	' ',					//-- 09 TES
	' ',					//-- 10 CF
	' ',					//-- 11 SEQUENCIA
	' ',					//-- 12 DOCUMENTO
	' ',					//-- 13 SERIE
	0,						//-- 14 QUANTIDADE
	0,						//-- 15 QUANT2UM
	' ',	    			//-- 16 ARMAZEM
	' ',					//-- 17 OP
	' ',					//-- 18 FORNECEDOR
	' ',					//-- 19 LOJA
	' ',					//-- 20 TIPO NF
	0,						//-- 21 CUSTO
	0						//-- 22 RECNO
	
	FROM %table:SB1% SB1
	
	WHERE   SB1.B1_COD     >= %Exp:mv_par05%	AND		SB1.B1_COD  <= %Exp:mv_par06% 	AND
	SB1.B1_FILIAL  =  %xFilial:SB1%	    AND		SB1.B1_TIPO >= %Exp:mv_par03%	AND
	SB1.B1_TIPO    <= %Exp:mv_par04%	AND		SB1.%NotDel%
	
	//ORDER BY 3,2,1
	ORDER BY 5,2,1
	
EndSql

//Metodo EndQuery ( Classe TRSection )                                    
//                                                                        
//Prepara o relatorio para executar o Embedded SQL.                       
//                                                                        
//ExpA1 : Array com os parametros do tipo Range                           
//                                                                        

oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)


//Inicio da impressao do fluxo do relatorio                               

dbSelectArea(cAliasTop)
oReport:SetMeter(nRegs)

oSection1:Init()

While !oReport:Cancel() .And. !(cAliasTop)->(Eof())
	
	If oReport:Cancel()
		Exit
	EndIf
	
	
	// Filtro de Usuario                                            
	
	If !Empty(cFiltroUsr)
		If !(&cFiltroUsr)
			dbSelectArea(cAliasTop)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	//cTipant := (cAliasTop)->B1_TIPO
	cTipant := (cAliasTop)->PRODUTO   //joni
	cDescr := POSICIONE('SB1',1,Xfilial('SB1')+(cAliasTop)->PRODUTO,'B1_DESC')   //joni

	oSection1:Cell("cTipant"):SetValue(cTipant)
	oSection1:Cell("cDescr"):SetValue(cDescr)
	
	Store 0 TO 	nSalant,nCompras,nReqCons,nReqProd,nEntrTerc,nSaiTerc,nReqMNT
	Store 0 TO 	nReqTrans,nProducao,nVendas,nSaldoAtu,nReqOutr,nDevVendas,nDevComprs
	lPassou := .F.
	
	//While !oReport:Cancel() .And. !(cAliasTop)->(Eof()) .And. (cAliasTop)->B1_TIPO == cTipAnt
	While !oReport:Cancel() .And. !(cAliasTop)->(Eof()) .And. (cAliasTop)->PRODUTO == cTipAnt    //joni
		
		If oReport:Cancel()
			Exit
		EndIf
		
		
		// Filtro de Usuario                                            
		
		If !Empty(cFiltroUsr)
			If !(&cFiltroUsr)
				dbSelectArea(cAliasTop)
				dbSkip()
				Loop
			EndIf
		EndIf
		
		cProduto  := (cAliasTop)->PRODUTO
		
		oReport:IncMeter()
		
		
		// Saldo final e inicial dos almoxarifados                      
		
		dbSelectArea("SB2")
		dbSeek(xFilial()+cProduto+mv_par01,.T.)
		While !EOF() .And. B2_FILIAL+B2_COD == xFilial()+cProduto .And. B2_LOCAL <= mv_par02
			
			// Verifica se deve somar custo da Mao de Obra no Saldo Final   
			
			If	!(IsProdMod(SB2->B2_COD) .And. mv_par11 == 2)
				IF mv_par10==1
					nSaldoAtu := nSaldoAtu + &("B2_VATU"+cMoeda)
				Elseif mv_par10 == 2
					nSaldoAtu := nSaldoAtu + &("B2_VFIM"+cMoeda)
				Else
					aSaldoAtu	:= CalcEst(SB2->B2_COD,SB2->B2_LOCAL,mv_par08+1)
					nSaldoAtu 	:= nSaldoAtu + aSaldoAtu[mv_par09+1]
				EndIF
			EndIf
			dbSkip()
		EndDo
		
		lPassou := IIF(nSaldoAtu > 0,.t.,lPassou)
		
		// SB1 - Verifica Produtos Sem Movimento						 
		
		dbSelectArea(cAliasTop)
		While !Eof() .And. (cAliasTop)->PRODUTO == cProduto .And. Alltrim((cAliasTop)->ARQ) == "SB1"
			dbSkip()
		EndDo
		
		
		// SD1 - Pesquisa as Entradas de um determinado produto         
		
		dbSelectArea(cAliasTop)
		While !Eof() .And. (cAliasTop)->PRODUTO == cProduto .And. Alltrim((cAliasTop)->ARQ) == "SD1"
			
			dbSelectArea("SF4")
			dbSeek(xFilial()+(cAliasTop)->TES)
			dbSelectArea(cAliasTop)
			
			If SF4->F4_ESTOQUE == "S"
				nValor := (cAliasTop)->CUSTO
				If SF4->F4_PODER3 == "N"
					If (cAliasTop)->TIPONF == "D"
						nDevVendas  += nValor
					Else
						nCompras += nValor
					EndIf
				Else
					nEntrTerc += nValor
				EndIf
				lPassou := .T.
			EndIf
			dbSkip()
		EndDo
		
		
		// SD2 - Pesquisa Vendas                                        
		
		dbSelectArea(cAliasTop)
		While !Eof() .And. (cAliasTop)->PRODUTO == cProduto .And. Alltrim((cAliasTop)->ARQ) == "SD2"
			
			dbSelectArea("SF4")
			dbSeek(xFilial()+(cAliasTop)->TES)
			dbSelectArea(cAliasTop)
			If SF4->F4_ESTOQUE == "S"
				nValor := (cAliasTop)->CUSTO
				If SF4->F4_PODER3 == "N"
					If (cAliasTop)->TIPONF == "D"
						nDevComprs += nValor
					Else
						nVendas  += nValor
					EndIf
				Else
					nSaiTerc += nValor
				EndIf
				lPassou := .T.
			EndIf
			dbSkip()
		EndDo
		
		
		// SD3 - Pesquisa requisicoes                                   
		
		dbSelectArea(cAliasTop)
		While !Eof() .And. (cAliasTop)->PRODUTO == cProduto .And. Alltrim((cAliasTop)->ARQ) == "SD3"
			
			If SubStr(AllTrim((cAliasTop)->OP),7,2) == 'OS' .And. SubStr(AllTrim((cAliasTop)->OP),9,3) == '001' .And. MV_PAR12 == 2 .And. !__lPyme
				If (cAliasTop)->TES > "500"
					nReqMNT += (cAliasTop)->CUSTO*-1
				Else
					nReqMNT += (cAliasTop)->CUSTO
				EndIf
				dbskip()
				Loop
			EndIf
			
			nValor := (cAliasTop)->CUSTO
			
			If (cAliasTop)->TES > "500"
				nValor := nValor*-1
			EndIf
			
			If Substr((cAliasTop)->CF,1,2) == "PR"
				nProducao += nValor
			ElseIf allTrim((cAliasTop)->CF)$"RE4/DE4"
				nReqTrans += nValor
			ElseIf Empty((cAliasTop)->OP) .And. Substr((cAliasTop)->CF,3,1) != "3"
				nReqCons += nValor
			ElseIf !Empty((cAliasTop)->OP)
				nReqProd += nValor
			Else
				nReqOutr += nValor
			EndIf
			lPassou := .T.
			dbSkip()
		EndDo
		dbSelectArea(cAliasTop)
	EndDo
	
	If lPassou
		lTotal:=.T.
		nSalant := nSaldoAtu-nCompras-nReqMNT-nReqProd-nReqCons-nProducao+nVendas-nReqTrans-nReqOutr-nDevVendas+nDevComprs-nEntrTerc+nSaiTerc
		
		oSection1:Cell("nSalant"   ):SetValue(nSalant)
		oSection1:Cell("nCompras"  ):SetValue(nCompras)
		oSection1:Cell("nReqCons"  ):SetValue(nReqCons)
		oSection1:Cell("nReqProd"  ):SetValue(nReqProd)
		oSection1:Cell("nReqTrans" ):SetValue(nReqTrans)
		oSection1:Cell("nProducao" ):SetValue(nProducao)
		oSection1:Cell("nVendas"   ):SetValue(nVendas)
		oSection1:Cell("nReqOutr"  ):SetValue(nReqOutr)
		oSection1:Cell("nDevVendas"):SetValue(nDevVendas)
		oSection1:Cell("nDevComprs"):SetValue(nDevComprs)
		oSection1:Cell("nEntrTerc" ):SetValue(nEntrTerc)
		oSection1:Cell("nSaiTerc"  ):SetValue(nSaiTerc)
		oSection1:Cell("nSaldoAtu" ):SetValue(nSaldoAtu)
		
		oSection1:PrintLine()
	EndIf
	dbSelectArea(cAliasTop)
EndDo
oSection1:Finish()
//EndIf //endif da chamada da procedure //joni

Return NIL

Static Function VerIDProc()
Return '002'
