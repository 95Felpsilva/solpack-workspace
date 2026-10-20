#Include "Protheus.ch"
#Include "Topconn.ch"

#DEFINE EXTENSAO		".XML"

/*/{Protheus.doc}	RFtSolpack
Rotina que gera a planilha com os dados do módulo faturamento

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					26/06/2015
@return				nil
/*/
User Function RFtSolpack()
	
	Local aParBox			:= {}
	Private aCampos		:= {}
	Private aDados		:= {}
	Private oExcel		:= nil
	
	Aadd(aParBox,{1,"Data de"	,STOD(""),	"",	"",,".T.",50, .f.})// MV_PAR09
	Aadd(aParBox,{1,"Data ate"	,STOD(""),	"",	"",,".T.",50, .t.})// MV_PAR10
	
	If ParamBox(aParBox,"Relatorio Faturamento",,,,,,,,"ZRELFAT",.T.,.T.)
		Processa({||GeraExcel()})
	EndIf
	
Return

/*/{Protheus.doc}	GeraExcel
Gera a planilha Excel

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					26/06/2015
@return				nil
/*/
Static Function GeraExcel()
	
	Local nI				:= 0
	Local cWorkSheet		:= "Faturamento"
	Local cPlanilha		:= "Faturamento de " + DTOC(MV_PAR01) + " até " + DTOC(MV_PAR02)
	Local cNomePlan		:= "Relatorio_Faturamento_" + DTOS(dDataBase) + "_" + StrTran(Time(),":","")
	
	buscaDados()
	
	If Len(aCampos) > 0 .AND. Len(aDados) > 0
		oExcel := FWMsExcel():New()
		oExcel:AddWorkSheet(cWorkSheet)
		oExcel:AddTable(cWorkSheet,cPlanilha)
		
		//Cria Cabeçalho
		For nI := 1 To Len(aCampos)
			oExcel:AddColumn(cWorkSheet,cPlanilha,aCampos[nI],1,1,.F.)
		Next
		
		nI := 0
		
		ProcRegua(Len(aDados))
		
		//Insere os Dados
		For nI := 1 To Len(aDados)
			oExcel:AddRow(cWorkSheet,cPlanilha,aDados[nI])
			IncProc()
		Next
		
		oExcel:Activate()
		oExcel:GetXMLFile(cNomePlan + EXTENSAO)
	EndIf
	
Return

/*/{Protheus.doc}	buscaDados
Busca os dados da nota e para preencher os arrays com os dados

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					26/06/2015
@return				nil
/*/
Static Function buscaDados()
	
	Local cQuery			:= ""
	Local nQtdReg			:= 1
	Local cAlias			:= GetNextAlias()
	
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	cQuery += "" + CRLF
	
	TcQuery cQuery New Alias &cAlias
	
	If (cAlias)->(!Eof())
		(cAlias)->(DbGoTop())
		
		While (cAlias)->(!Eof())
			
			//Se for o primeiro registro
			If nQtdReg == 1
				Aadd(aCampos,{;
					;
				})
			EndIf
			
			//Insere os dados no array
			Aadd(aDados,{;
				;
			})
			
			(cAlias)->(DbSkip())
		EndDo
		
	EndIf
	
	(cAlias)->(DbCloseArea())
	
Return
