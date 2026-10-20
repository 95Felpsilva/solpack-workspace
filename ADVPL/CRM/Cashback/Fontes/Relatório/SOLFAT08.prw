
#include 'Protheus.ch'
#include 'Protheus.ch'
#include 'topconn.ch'
#include "SOLFAT04.ch"
  
/*/{Protheus.doc} SOLFAT08
    Relação CashBack
    
    @author Gabriel Pereira Santos
    @since 24/03/2023
    @version P12
/*/ 
User Function SOLFAT08()
	Local oReport       := NIL
	Local cPergunta     := Padr("SOLFAT08",10)
	
	Pergunte(cPergunta,.F.)	          
		
	oReport := ReportDefine(cPergunta)
	oReport:PrintDialog()
Return

/*
    Função para definição das seções e campos
*/
Static Function ReportDefine(cNome)
	Local oReport           := NIL
	Local oSection1         := NIL
	Local oSection2         := NIL
	Local oSection3         := NIL

    Local cPrefForm			:= PREFIXO_ALIAS_FORM0 as character
	Local cPref0Grid		:= PREFIXO_ALIAS_GRID0 as character
	Local cPref1Grid		:= PREFIXO_ALIAS_GRID1 as character
	
	oReport := TReport():New(cNome,"Cashback",cNome,{|oReport| ReportPrint(oReport)},"")
	oReport:SetPortrait()    
	oReport:SetTotalInLine(.F.)
	
	oSection1 := TRSection():New(oReport, "Cliente", {cPrefForm},, .F., .T.)
    TRCell():New(oSection1,cPrefForm+"_ID"         ,cPrefForm, GetSx3Cache(cPrefForm+"_ID","X3_TITULO") ,GetSx3Cache(cPrefForm+"_ID","X3_PICTURE"), GetSx3Cache(cPrefForm+"_ID","X3_TAMANHO"))
    TRCell():New(oSection1,cPrefForm+"_CLIENT"     ,cPrefForm, GetSx3Cache(cPrefForm+"_CLIENT","X3_TITULO") ,GetSx3Cache(cPrefForm+"_CLIENT","X3_PICTURE"), GetSx3Cache(cPrefForm+"_CLIENT","X3_TAMANHO"))
    TRCell():New(oSection1,cPrefForm+"_LOJA"       ,cPrefForm, GetSx3Cache(cPrefForm+"_LOJA","X3_TITULO") ,GetSx3Cache(cPrefForm+"_LOJA","X3_PICTURE"), GetSx3Cache(cPrefForm+"_LOJA","X3_TAMANHO"))
    TRCell():New(oSection1,cPrefForm+"_NOME"       ,cPrefForm, GetSx3Cache(cPrefForm+"_NOME","X3_TITULO") ,GetSx3Cache(cPrefForm+"_NOME","X3_PICTURE"), GetSx3Cache(cPrefForm+"_NOME","X3_TAMANHO"))
    TRCell():New(oSection1,cPrefForm+"_VALOR"      ,cPrefForm, GetSx3Cache(cPrefForm+"_VALOR","X3_TITULO") ,GetSx3Cache(cPrefForm+"_VALOR","X3_PICTURE"), GetSx3Cache(cPrefForm+"_VALOR","X3_TAMANHO"))
    TRCell():New(oSection1,cPrefForm+"_DATA"       ,cPrefForm, GetSx3Cache(cPrefForm+"_DATA","X3_TITULO") ,GetSx3Cache(cPrefForm+"_DATA","X3_PICTURE"), GetSx3Cache(cPrefForm+"_DATA","X3_TAMANHO"))
    TRCell():New(oSection1,cPrefForm+"_HORA"       ,cPrefForm, GetSx3Cache(cPrefForm+"_HORA","X3_TITULO") ,GetSx3Cache(cPrefForm+"_HORA","X3_PICTURE"), GetSx3Cache(cPrefForm+"_HORA","X3_TAMANHO"))

	oSection2 := TRSection():New(oReport, "Produto", {cPrefForm},, .F., .T.)
    TRCell():New(oSection2,cPref0Grid+"_IDCASH"     ,cPref0Grid, GetSx3Cache(cPref0Grid+"_IDCASH","X3_TITULO") ,GetSx3Cache(cPref0Grid+"_IDCASH","X3_PICTURE"), GetSx3Cache(cPref0Grid+"_IDCASH","X3_TAMANHO"))
    TRCell():New(oSection2,cPref0Grid+"_PRODUT"     ,cPref0Grid, GetSx3Cache(cPref0Grid+"_PRODUT","X3_TITULO") ,GetSx3Cache(cPref0Grid+"_PRODUT","X3_PICTURE"), GetSx3Cache(cPref0Grid+"_PRODUT","X3_TAMANHO"))
    TRCell():New(oSection2,cPref0Grid+"_DESC"       ,cPref0Grid, GetSx3Cache(cPref0Grid+"_DESC","X3_TITULO") ,GetSx3Cache(cPref0Grid+"_DESC","X3_PICTURE"), GetSx3Cache(cPref0Grid+"_DESC","X3_TAMANHO"))
    TRCell():New(oSection2,cPref0Grid+"_VALOR"      ,cPref0Grid, GetSx3Cache(cPref0Grid+"_VALOR","X3_TITULO") ,GetSx3Cache(cPref0Grid+"_VALOR","X3_PICTURE"), GetSx3Cache(cPref0Grid+"_VALOR","X3_TAMANHO"))

	oSection3 := TRSection():New(oReport, "Movimentos", {cPref1Grid},, .F., .T.)
    TRCell():New(oSection3,cPref1Grid+"_IDCASH"     ,cPref1Grid, GetSx3Cache(cPref1Grid+"_IDCASH","X3_TITULO") ,GetSx3Cache(cPref1Grid+"_IDCASH","X3_PICTURE"), GetSx3Cache(cPref1Grid+"_IDCASH","X3_TAMANHO"))
    TRCell():New(oSection3,cPref1Grid+"_IDMOVI"     ,cPref1Grid, GetSx3Cache(cPref1Grid+"_IDMOVI","X3_TITULO") ,GetSx3Cache(cPref1Grid+"_IDMOVI","X3_PICTURE"), GetSx3Cache(cPref1Grid+"_IDMOVI","X3_TAMANHO"))
    TRCell():New(oSection3,cPref1Grid+"_TPMOV"      ,cPref1Grid, GetSx3Cache(cPref1Grid+"_TPMOV","X3_TITULO") ,GetSx3Cache(cPref1Grid+"_TPMOV","X3_PICTURE"), GetSx3Cache(cPref1Grid+"_TPMOV","X3_TAMANHO"))
    TRCell():New(oSection3,cPref1Grid+"_DESCMOV"    ,cPref1Grid, "Desc. Movimento" ,"", 40)
    TRCell():New(oSection3,cPref1Grid+"_CLIENT"     ,cPref1Grid, GetSx3Cache(cPref1Grid+"_CLIENT","X3_TITULO") ,GetSx3Cache(cPref1Grid+"_CLIENT","X3_PICTURE"), GetSx3Cache(cPref1Grid+"_CLIENT","X3_TAMANHO"))
    TRCell():New(oSection3,cPref1Grid+"_LOJA"       ,cPref1Grid, GetSx3Cache(cPref1Grid+"_LOJA","X3_TITULO") ,GetSx3Cache(cPref1Grid+"_LOJA","X3_PICTURE"), GetSx3Cache(cPref1Grid+"_LOJA","X3_TAMANHO"))
    TRCell():New(oSection3,cPref1Grid+"_PRODUT"     ,cPref1Grid, GetSx3Cache(cPref1Grid+"_PRODUT","X3_TITULO") ,GetSx3Cache(cPref1Grid+"_PRODUT","X3_PICTURE"), GetSx3Cache(cPref1Grid+"_PRODUT","X3_TAMANHO"))
    TRCell():New(oSection3,cPref1Grid+"_DESC"       ,cPref1Grid, GetSx3Cache(cPref0Grid+"_DESC","X3_TITULO") ,GetSx3Cache(cPref0Grid+"_DESC","X3_PICTURE"), GetSx3Cache(cPref0Grid+"_DESC","X3_TAMANHO"))
    TRCell():New(oSection3,cPref1Grid+"_VALOR"      ,cPref1Grid, GetSx3Cache(cPref1Grid+"_VALOR","X3_TITULO") ,GetSx3Cache(cPref1Grid+"_VALOR","X3_PICTURE"), GetSx3Cache(cPref1Grid+"_VALOR","X3_TAMANHO"))
    TRCell():New(oSection3,cPref1Grid+"_DATA"       ,cPref1Grid, GetSx3Cache(cPref1Grid+"_DATA","X3_TITULO") ,GetSx3Cache(cPref1Grid+"_DATA","X3_PICTURE"), GetSx3Cache(cPref1Grid+"_DATA","X3_TAMANHO"))
    TRCell():New(oSection3,cPref1Grid+"_HORA"       ,cPref1Grid, GetSx3Cache(cPref1Grid+"_HORA","X3_TITULO") ,GetSx3Cache(cPref1Grid+"_HORA","X3_PICTURE"), GetSx3Cache(cPref1Grid+"_HORA","X3_TAMANHO"))
    TRCell():New(oSection3,cPref1Grid+"_FILPED"     ,cPref1Grid, GetSx3Cache(cPref1Grid+"_FILPED","X3_TITULO") ,GetSx3Cache(cPref1Grid+"_FILPED","X3_PICTURE"), GetSx3Cache(cPref1Grid+"_FILPED","X3_TAMANHO"))
    TRCell():New(oSection3,cPref1Grid+"_PV"         ,cPref1Grid, GetSx3Cache(cPref1Grid+"_PV","X3_TITULO") ,GetSx3Cache(cPref1Grid+"_PV","X3_PICTURE"), GetSx3Cache(cPref1Grid+"_PV","X3_TAMANHO"))
    TRCell():New(oSection3,cPref1Grid+"_ITEMPV"     ,cPref1Grid, GetSx3Cache(cPref1Grid+"_ITEMPV","X3_TITULO") ,GetSx3Cache(cPref1Grid+"_ITEMPV","X3_PICTURE"), GetSx3Cache(cPref1Grid+"_ITEMPV","X3_TAMANHO"))

	oReport:SetTotalInLine(.F.)

	oSection1:SetPageBreak(.T.)
	oSection1:SetTotalText(" ")				
Return(oReport)

/*
    Rotina para impressão do relatório
*/
Static Function ReportPrint(oReport)
	Local oSection1         := oReport:Section(1)
	Local oSection2         := oReport:Section(2)
	Local oSection3         := oReport:Section(3)
	Local cAliasForm        := ""
	Local cAlias0Grid       := ""
	Local cAlias1Grid       := ""
	Local cQryForm          := ""
	Local cQry0Grid         := ""
	Local cQry1Grid         := ""

    Local cPrefForm			:= PREFIXO_ALIAS_FORM0 as character
	Local cPref0Grid		:= PREFIXO_ALIAS_GRID0 as character
	Local cPref1Grid		:= PREFIXO_ALIAS_GRID1 as character

    
    oSection1:BeginQuery()
        cQryForm += " SELECT  " + CRLF
        cQryForm += "     " + cPrefForm + ".* " + CRLF
        cQryForm += "     ,A1_NOME " + cPrefForm + "_NOME " + CRLF
        cQryForm += " FROM  " + CRLF
        cQryForm += "     " + RetSqlTab(cPrefForm) + CRLF
        
        cQryForm += "     INNER JOIN " + RetSqlTab("SA1") + " ON 1 = 1 " + CRLF
        cQryForm += "         AND" + RetSqlFil("SA1") + CRLF
        cQryForm += "         AND SA1.A1_COD = " + cPrefForm + "_CLIENT " + CRLF
        cQryForm += "         AND SA1.A1_LOJA = " + cPrefForm + "_LOJA " + CRLF
        cQryForm += "         AND" + RetSqlDel("SA1") + CRLF
        
        cQryForm += " WHERE  " + CRLF
        cQryForm += "       1 = 1 " + CRLF
        cQryForm += "       AND" + RetSqlFil(cPrefForm) + CRLF
        If (Type("MV_PAR01") == "C" .And. Type("MV_PAR02") == "C" .And. !Empty(MV_PAR02))
            cQryForm += "       AND " + cPrefForm + "_ID BETWEEN " + ValToSql(MV_PAR01) + " AND " + ValToSql(MV_PAR02)
        EndIf
        If (Type("MV_PAR03") == "C" .And. Type("MV_PAR04") == "C" .And. !Empty(MV_PAR04))
            cQryForm += "       AND " + cPrefForm + "_CLIENT BETWEEN " + ValToSql(MV_PAR03) + " AND " + ValToSql(MV_PAR04)
        EndIf
        If (Type("MV_PAR05") == "C" .And. Type("MV_PAR06") == "C" .And. !Empty(MV_PAR06))
            cQryForm += "       AND " + cPrefForm + "_LOJA BETWEEN " + ValToSql(MV_PAR05) + " AND " + ValToSql(MV_PAR06)
        EndIf
        cQryForm += "         AND" + RetSqlDel(cPrefForm) + CRLF

		TCQUERY cQryForm NEW Alias(cAliasForm:=GetNextAlias())
			
		dbselectarea(cAliasForm)
		(cAliasForm)->(dbGoTop())
	
	oSection1:EndQuery()

    If (cAliasForm)->(!Eof())
        oSection1:init()

		While (cAliasForm)->(!Eof())
			If oReport:Cancel()
				Exit
			EndIf
	
			oReport:IncMeter()
        
            oSection1:Cell(cPrefForm+"_ID"):SetValue((cAliasForm)->&(cPrefForm+"_ID"))
            oSection1:Cell(cPrefForm+"_CLIENT"):SetValue((cAliasForm)->&(cPrefForm+"_CLIENT"))
            oSection1:Cell(cPrefForm+"_LOJA"):SetValue((cAliasForm)->&(cPrefForm+"_LOJA"))
            oSection1:Cell(cPrefForm+"_VALOR"):SetValue((cAliasForm)->&(cPrefForm+"_VALOR"))
            oSection1:Cell(cPrefForm+"_DATA"):SetValue((cAliasForm)->&(cPrefForm+"_DATA"))
            oSection1:Cell(cPrefForm+"_HORA"):SetValue((cAliasForm)->&(cPrefForm+"_HORA"))
            oSection1:Cell(cPrefForm+"_NOME"):SetValue((cAliasForm)->&(cPrefForm+"_NOME"))
            
            oSection1:Printline()
	
			(cAliasForm)->(DBSkip())
		EndDo

        oSection1:Finish()
	Endif

    oSection2:BeginQuery()
        cQry0Grid += " SELECT  " + CRLF
        cQry0Grid += "     " + cPref0Grid + ".* " + CRLF
        cQry0Grid += "     ,B1_DESC AS " + cPref0Grid + "_DESC " + CRLF
        cQry0Grid += " FROM  " + CRLF
        cQry0Grid += "     " + RetSqlTab(cPref0Grid) + CRLF
        
        cQry0Grid += "     INNER JOIN " + RetSqlTab("SB1") + " ON 1 = 1 " + CRLF
        cQry0Grid += "         AND" + RetSqlFil("SB1") + CRLF
        cQry0Grid += "         AND SB1.B1_COD = " + cPref0Grid + "_PRODUT " + CRLF
        cQry0Grid += "         AND" + RetSqlDel("SB1") + CRLF
        
        cQry0Grid += " WHERE  " + CRLF
        cQry0Grid += "       1 = 1 " + CRLF
        cQry0Grid += "       AND" + RetSqlFil(cPref0Grid) + CRLF
        If (Type("MV_PAR01") == "C" .And. Type("MV_PAR02") == "C" .And. !Empty(MV_PAR02))
            cQryForm += "       AND " + cPref0Grid + "_IDCASH BETWEEN " + ValToSql(MV_PAR01) + " AND " + ValToSql(MV_PAR02)
        EndIf
        If (Type("MV_PAR03") == "C" .And. Type("MV_PAR04") == "C" .And. !Empty(MV_PAR04))
            cQryForm += "       AND " + cPref0Grid + "_CLIENT BETWEEN " + ValToSql(MV_PAR03) + " AND " + ValToSql(MV_PAR04)
        EndIf
        If (Type("MV_PAR05") == "C" .And. Type("MV_PAR06") == "C" .And. !Empty(MV_PAR06))
            cQryForm += "       AND " + cPref0Grid + "_LOJA BETWEEN " + ValToSql(MV_PAR05) + " AND " + ValToSql(MV_PAR06)
        EndIf
        cQryForm += "         AND" + RetSqlDel(cPref0Grid) + CRLF

		TCQUERY cQry0Grid NEW Alias(cAlias0Grid:=GetNextAlias())
			
		dbselectarea(cAlias0Grid)
		(cAlias0Grid)->(dbGoTop())
	
	oSection2:EndQuery()

    If (cAlias0Grid)->(!Eof())
        oSection2:init()

		While (cAlias0Grid)->(!Eof())
			If oReport:Cancel()
				Exit
			EndIf
	
			oReport:IncMeter()
        
            oSection2:Cell(cPref0Grid+"_IDCASH"):SetValue((cAlias0Grid)->&(cPref0Grid+"_IDCASH"))
            oSection2:Cell(cPref0Grid+"_PRODUT"):SetValue((cAlias0Grid)->&(cPref0Grid+"_PRODUT"))
            oSection2:Cell(cPref0Grid+"_DESC"):SetValue((cAlias0Grid)->&(cPref0Grid+"_DESC"))
            oSection2:Cell(cPref0Grid+"_VALOR"):SetValue((cAlias0Grid)->&(cPref0Grid+"_VALOR"))
            
            oSection2:Printline()
	
			(cAlias0Grid)->(DBSkip())
		EndDo

        oSection2:Finish()
	Endif

    oSection3:BeginQuery()
        cQry1Grid += " SELECT  " + CRLF
        cQry1Grid += "     " + cPref1Grid + ".* " + CRLF
        cQry1Grid += "     ,B1_DESC AS " + cPref1Grid + "_DESC " + CRLF
        cQry1Grid += "     ,CASE" + CRLF
        cQry1Grid += "          WHEN " + cPref1Grid+"_TPMOV = " + ValToSQL(MOVIMENTO_ENTRADA) + " THEN" + CRLF
        cQry1Grid += "              'ENTRADA'" + CRLF
        cQry1Grid += "          WHEN " + cPref1Grid+"_TPMOV = " + ValToSQL(MOVIMENTO_SAIDA) + " THEN" + CRLF
        cQry1Grid += "              'SAÍDA'" + CRLF
        cQry1Grid += "          WHEN " + cPref1Grid+"_TPMOV = " + ValToSQL(MOVIMENTO_VENCIMENTO) + " THEN" + CRLF
        cQry1Grid += "              'VENCIMENTO'" + CRLF
        cQry1Grid += "      END DESCMOVIMENTO" + CRLF
        cQry1Grid += " FROM  " + CRLF
        cQry1Grid += "     " + RetSqlTab(cPref1Grid) + CRLF
        
        cQry1Grid += "     INNER JOIN " + RetSqlTab("SB1") + " ON 1 = 1 " + CRLF
        cQry1Grid += "         AND" + RetSqlFil("SB1") + CRLF
        cQry1Grid += "         AND SB1.B1_COD = " + cPref1Grid + "_PRODUT " + CRLF
        cQry1Grid += "         AND" + RetSqlDel("SB1") + CRLF
        
        cQry1Grid += " WHERE  " + CRLF
        cQry1Grid += "       1 = 1 " + CRLF
        cQry1Grid += "       AND" + RetSqlFil(cPref1Grid) + CRLF
        If (Type("MV_PAR01") == "C" .And. Type("MV_PAR02") == "C" .And. !Empty(MV_PAR02))
            cQryForm += "       AND " + cPref1Grid + "_IDCASH BETWEEN " + ValToSql(MV_PAR01) + " AND " + ValToSql(MV_PAR02)
        EndIf
        If (Type("MV_PAR03") == "C" .And. Type("MV_PAR04") == "C" .And. !Empty(MV_PAR04))
            cQryForm += "       AND " + cPref1Grid + "_CLIENT BETWEEN " + ValToSql(MV_PAR03) + " AND " + ValToSql(MV_PAR04)
        EndIf
        If (Type("MV_PAR05") == "C" .And. Type("MV_PAR06") == "C" .And. !Empty(MV_PAR06))
            cQryForm += "       AND " + cPref1Grid + "_LOJA BETWEEN " + ValToSql(MV_PAR05) + " AND " + ValToSql(MV_PAR06)
        EndIf
        cQryForm += "         AND" + RetSqlDel(cPref1Grid) + CRLF

		TCQUERY cQry1Grid NEW Alias(cAlias1Grid:=GetNextAlias())
			
		dbselectarea(cAlias1Grid)
		(cAlias1Grid)->(dbGoTop())
	
	oSection3:EndQuery()

    If (cAlias1Grid)->(!Eof())
        oSection3:init()

		While (cAlias1Grid)->(!Eof())
			If oReport:Cancel()
				Exit
			EndIf
	
			oReport:IncMeter()

            oSection3:Cell(cPref1Grid+"_IDCASH"):SetValue((cAlias1Grid)->&(cPref1Grid+"_IDCASH"))
            oSection3:Cell(cPref1Grid+"_IDMOVI"):SetValue((cAlias1Grid)->&(cPref1Grid+"_IDMOVI"))
            oSection3:Cell(cPref1Grid+"_TPMOV"):SetValue((cAlias1Grid)->&(cPref1Grid+"_TPMOV"))
            oSection3:Cell(cPref1Grid+"_DESCMOV"):SetValue((cAlias1Grid)->DESCMOVIMENTO)
            oSection3:Cell(cPref1Grid+"_CLIENT"):SetValue((cAlias1Grid)->&(cPref1Grid+"_CLIENT"))
            oSection3:Cell(cPref1Grid+"_LOJA"):SetValue((cAlias1Grid)->&(cPref1Grid+"_LOJA"))
            oSection3:Cell(cPref1Grid+"_PRODUT"):SetValue((cAlias1Grid)->&(cPref1Grid+"_PRODUT"))
            oSection3:Cell(cPref1Grid+"_DESC"):SetValue((cAlias1Grid)->&(cPref1Grid+"_DESC"))
            oSection3:Cell(cPref1Grid+"_VALOR"):SetValue((cAlias1Grid)->&(cPref1Grid+"_VALOR"))
            oSection3:Cell(cPref1Grid+"_DATA"):SetValue((cAlias1Grid)->&(cPref1Grid+"_DATA"))
            oSection3:Cell(cPref1Grid+"_HORA"):SetValue((cAlias1Grid)->&(cPref1Grid+"_HORA"))
            oSection3:Cell(cPref1Grid+"_FILPED"):SetValue((cAlias1Grid)->&(cPref1Grid+"_FILPED"))
            oSection3:Cell(cPref1Grid+"_PV"):SetValue((cAlias1Grid)->&(cPref1Grid+"_PV"))
            oSection3:Cell(cPref1Grid+"_ITEMPV"):SetValue((cAlias1Grid)->&(cPref1Grid+"_ITEMPV"))
            
            oSection3:Printline()
	
			(cAlias1Grid)->(DBSkip())
		EndDo

        oSection3:Finish()
	Endif    
    
    (cAliasForm)->(DBCloseArea())
    (cAlias0Grid)->(DBCloseArea())
    (cAlias1Grid)->(DBCloseArea())
Return
