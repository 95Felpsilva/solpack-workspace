#include "protheus.ch"


/*
 ======================================================================================================
| Programa    :  SOLPCP01.PRW                                                                          |
|======================================================================================================|
| Descrição   :  PROGRAMA PARA EXPORTAR PARA O EXCEL A PRODUÇÃO DO DIA                                |
|======================================================================================================|
| Data        :  19/06/2015                                                                            |
|======================================================================================================|
| Cliente     :  SOLPACK                                                                               |
|======================================================================================================|
| Responsável : JONI SANTOS                                                                            |
|======================================================================================================|
| Observação  :   														                 	           |
 ======================================================================================================
*/

//#define REL_WORKSHEET 'Produção'
#define REL_TABLE 'Relatorio de Produção'


#define EXCEL_ALIGN_LEFT   1
#define EXCEL_ALIGN_CENTER 2
#define EXCEL_ALIGN_RIGHT  3

#define EXCEL_FORMAT_GENERAL  1
#define EXCEL_FORMAT_NUMBER   2
#define EXCEL_FORMAT_MONEY    3
#define EXCEL_FORMAT_DATETIME 4

user function SOLPCP01()

	Local aParBox  := {}
	Local aCombo  := {"Analitico","Sintetico"}
	Local cNomeRel := "Relatorio de Produção" //+aCombo+"' "
	
	Private cWorkSheet := ""
	
	AADD( aParBox,{1, "Data de" 			,CtoD("")				,   ""			, ""	, ""    	,   "",60	,.T.}) //MV_PAR01
	AADD( aParBox,{1, "Data até"			,CtoD("")				,   ""			, ""	, ""    	,   "",60	,.T.})//MV_PAR02
	AADD( aParBox,{1,"De Recurso"         	,CriaVar("H1_CODIGO") 	,"@!"			,'.T.'	,"SH1"		,'.T.',60	,.F.})//MV_PAR03
	AADD( aParBox,{1,"Até Recurso"        	,CriaVar("H1_CODIGO") 	,"@!"			,'.T.'	,"SH1"		,'.T.',60	,.T.})//MV_PAR04
	AADD( aParBox,{2,"Tipo"    				,'1'					,aCombo			,60		,			,.f.})// MV_PAR05 {"Analitico","Sintetico"}


	
	
	
	If !ParamBox(aParBox,cNomeRel,NIL,,,,,,,cNomeRel,.T.,.T.)
	Return
	EndIf

	cWorkSheet := "Relatorio " + MV_PAR05
	
	RptStatus({|| printPage() },cNomeRel)
return

static function printPage()

	local aDados    := {}
	local oExcel    := FWMSEXCEL():New()
	local cAlias    := nil

	Private nRegs
		
	oExcel:AddworkSheet(cWorkSheet)
	oExcel:AddTable (cWorkSheet, REL_TABLE)	
	
	
	oExcel:AddColumn(cWorkSheet, REL_TABLE, "FILIAL"         , EXCEL_ALIGN_LEFT , EXCEL_FORMAT_GENERAL)
	oExcel:AddColumn(cWorkSheet, REL_TABLE, "ARTIGO"         , EXCEL_ALIGN_LEFT , EXCEL_FORMAT_GENERAL)
	oExcel:AddColumn(cWorkSheet, REL_TABLE, "DESCRICAO"         , EXCEL_ALIGN_LEFT , EXCEL_FORMAT_GENERAL)
		IF MV_PAR05=='Analitico'  //{"Analitico","Sintetico"}
			oExcel:AddColumn(cWorkSheet, REL_TABLE, "ORDEM_DE_PRODUCAO"         , EXCEL_ALIGN_LEFT , EXCEL_FORMAT_GENERAL)
			oExcel:AddColumn(cWorkSheet, REL_TABLE, "DATA_FINAL"         , EXCEL_ALIGN_LEFT , EXCEL_FORMAT_DATETIME) //oExcel:AddColumn(cWorkSheet, REL_TABLE, "DATA_FINAL"         , EXCEL_ALIGN_LEFT , EXCEL_FORMAT_GENERAL)
			oExcel:AddColumn(cWorkSheet, REL_TABLE, "HORA_FINAL"         , EXCEL_ALIGN_LEFT , EXCEL_FORMAT_GENERAL) //
		ENDIF
	oExcel:AddColumn(cWorkSheet, REL_TABLE, "CODIGO_RECURSO"        , EXCEL_ALIGN_LEFT , EXCEL_FORMAT_GENERAL)
	oExcel:AddColumn(cWorkSheet, REL_TABLE, "NOME_RECURSO"         , EXCEL_ALIGN_LEFT , EXCEL_FORMAT_GENERAL)
	oExcel:AddColumn(cWorkSheet, REL_TABLE, "QTD_PROD_1"       , EXCEL_ALIGN_RIGHT, EXCEL_FORMAT_NUMBER)
	oExcel:AddColumn(cWorkSheet, REL_TABLE, "UNID_MED_1"         , EXCEL_ALIGN_LEFT , EXCEL_FORMAT_GENERAL)
	oExcel:AddColumn(cWorkSheet, REL_TABLE, "QTD_PROD_2"       , EXCEL_ALIGN_RIGHT, EXCEL_FORMAT_NUMBER)
	oExcel:AddColumn(cWorkSheet, REL_TABLE, "UNID_MED_2"         , EXCEL_ALIGN_LEFT , EXCEL_FORMAT_GENERAL)
	
	MsgRun("Favor Aguardar.....", "Selecionando os Registros",{|| cAlias := procQuery(cAlias)})
	
	SetRegua(nRegs)
	While (cAlias)->(!EOF())
		IncRegua()

		aDados := {}

		AAdd(aDados,(cAlias)->FILIAL)
		AAdd(aDados,(cAlias)->ARTIGO)
		AAdd(aDados,(cAlias)->DESCRICAO)
		IF MV_PAR05=='Analitico'//{"Analitico","Sintetico"}
			AAdd(aDados,(cAlias)->ORDEM_DE_PRODUCAO)
			AAdd(aDados,(cAlias)->DATA_FINAL)
			AAdd(aDados,(cAlias)->HORA_FINAL)
		ENDIF
		AAdd(aDados,(cAlias)->CODIGO_RECURSO)
		AAdd(aDados,(cAlias)->NOME_RECURSO)
		AAdd(aDados,(cAlias)->QTD_PROD_1)
		AAdd(aDados,(cAlias)->UNID_MED_1)
		AAdd(aDados,(cAlias)->QTD_PROD_2)
		AAdd(aDados,(cAlias)->UNID_MED_2)

		oExcel:AddRow(cWorkSheet, REL_TABLE, aDados)

		(cAlias)->(dbSkip())
	End

	(cAlias)->(dbCloseArea())

	MsgRun("Favor Aguardar.....", "Exportando os Registros",{|| expExcel(oExcel)})
	
return

static function procQuery()
	local cQuery := ""
	local cAlias := GetNextAlias()
	
cQuery += "SELECT H6_FILIAL AS FILIAL, " + CRLF
cQuery += "H6.H6_PRODUTO AS ARTIGO,  " + CRLF
cQuery += "B1.B1_DESC AS DESCRICAO, " + CRLF
	IF MV_PAR05=='Analitico'//{"Analitico","Sintetico"}
		cQuery += "H6.H6_OP AS ORDEM_DE_PRODUCAO, " + CRLF
		cQuery += "H6.H6_DATAFIN AS DATA_FINAL , " + CRLF
		cQuery += "H6.H6_HORAFIN AS HORA_FINAL , " + CRLF
	endif
cQuery += "H6.H6_RECURSO AS CODIGO_RECURSO , " + CRLF
cQuery += "H1.H1_DESCRI AS NOME_RECURSO, " + CRLF
cQuery += "B1.B1_UM AS UNID_MED_1, " + CRLF 
cQuery += "B1.B1_SEGUM AS UNID_MED_2, " + CRLF
	IF MV_PAR05=='Analitico'//{"Analitico","Sintetico"}
		cQuery += "H6.H6_QTDPROD AS QTD_PROD_1, " +CRLF
		cQuery += "H6.H6_ZQTPRO2 AS QTD_PROD_2 " + CRLF//ALTERADO DE H6.H6_QTDPRO2 PARA H6.H6_ZQTPRO2 - JONI 27/09/2017
		else
		cQuery += "SUM(H6.H6_QTDPROD) AS QTD_PROD_1, " +CRLF 
		cQuery += "SUM(H6.H6_ZQTPRO2) AS QTD_PROD_2 " + CRLF //ALTERADO DE H6.H6_QTDPRO2 PARA H6.H6_ZQTPRO2 - JONI 27/09/2017
	endif
cQuery += "FROM SH6010 H6  " + CRLF
cQuery += "JOIN SB1010 B1 ON H6_PRODUTO = B1_COD AND B1.D_E_L_E_T_='' " + CRLF
cQuery += "JOIN SH1010 H1 ON H6_RECURSO = H1_CODIGO AND H1.D_E_L_E_T_='' " + CRLF

cQuery += "WHERE H6.D_E_L_E_T_='' " + CRLF
cQuery += "AND H6_FILIAL = '"+xFilial("SH6")+"' " +CRLF
cQuery += "AND B1_FILIAL = '"+xFilial("SB1")+"' " +CRLF
cQuery += "AND H1_FILIAL = '"+xFilial("SH1")+"' " +CRLF
cQuery += "AND H6_DATAFIN >= '" + DToS(MV_PAR01) + "' " + CRLF
cQuery += "AND H6_DATAFIN <= '" + DToS(MV_PAR02) + "' " + CRLF
cQuery += "AND H6_RECURSO >= '" + MV_PAR03 + "' " + CRLF
cQuery += "AND H6_RECURSO <= '" + MV_PAR04 + "' " + CRLF
cQuery += "AND H6_QTDPROD > 0 " + CRLF
cQuery += "AND H6_OPERAC = (SELECT MAX(G2_OPERAC) " + CRLF
cQuery += "						FROM SG2010 SG2 " + CRLF
cQuery += "							WHERE G2_PRODUTO = H6.H6_PRODUTO AND " + CRLF
cQuery += "							G2_FILIAL = '"+xFilial("SG2")+"'  AND " + CRLF
cQuery += "							SG2.D_E_L_E_T_='')" + CRLF
	IF MV_PAR05=='Sintetico'//{"Analitico","Sintetico"}
		cQuery += "GROUP BY H6_FILIAL, H6_PRODUTO, B1_DESC, H6_RECURSO, H1.H1_DESCRI, B1.B1_UM , B1.B1_SEGUM " + CRLF
	endif 
cQuery += "Order by H6_FILIAL,H6_PRODUTO,H6_RECURSO"


DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	Count To nRegs

	(cAlias)->(dbGoTop())
return cAlias
	
	
static function expExcel(oExcel)

local aDados    := {}
Local cArquivo	:= CriaTrab(,.F.)+".xml"
Local cDirDocs	:= MsDocPath()
Local oExcelApp	:= Nil
Local cPath		:= AllTrim(GetTempPath())

if nRegs > 0
	oExcel:Activate()
	oExcel:GetXMLFile(cDirDocs+"\"+cArquivo)

	CpyS2T(cDirDocs+"\"+cArquivo,cPath)

	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(cPath+cArquivo)
	oExcelApp:SetVisible(.T.)
	oExcelApp:Destroy()
else
	MsgAlert("Não há registros para exportação.")
endIf


return	
	
	
	
	