#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc}	ImprEtiq
Rotina com o Objetivo de imprimir as etiquetas de ordem de produção

@author			Julio Lisboa - FSW TOTVS IP Campinas
@since				22/06/2015
@return			nil
/*/
User Function ImprEtiq()
	
	Local aParBox		:= {}
	Local cPerg		:= "ImpEtq"
	Local aCombo		:= {"SIM","NAO"}
	Private aImpr		:= {}
	Private aOpc		:= {}
	
	//Trata as impressoras cadastradas
	U_getImpre(aImpr,aOpc)
	
	Aadd(aParBox,{2,"Imprime dados da Solpack"	,"1",aCombo,50,,.T.})// MV_PAR01
	Aadd(aParBox,{1,"Local de Impressao"	,Space(TamSX3("CB5_CODIGO")[1]),"","",	"CB5","",60,.T.})// MV_PAR02
	AADD(aParBox,{1,"Ordem de Produção"	,Space(TamSX3("H6_OP")[1]),	"",	"",	"ZZSH6",	"",70,.T.})// MV_PAR03
	AADD(aParBox,{1,"Produto"	,Space(TamSX3("H6_PRODUTO")[1]),	"",	"",	"",".F.",70,.F.})// MV_PAR04
	AADD(aParBox,{1,"Operação"	,Space(TamSX3("H6_OPERAC")[1]),	"",	"",	"",".F.",30,.F.})// MV_PAR05
	AADD(aParBox,{1,"Seq"	,Space(TamSX3("H6_SEQ")[1]),"",	"",	"",".F.",30,.F.})// MV_PAR06
	AADD(aParBox,{1,"Data Inicio"	,STOD(Space(TamSX3("H6_DATAINI")[1])),"","",	"",".F.",60,.F.})// MV_PAR07
	AADD(aParBox,{1,"Hora Inicio"	,Space(TamSX3("H6_HORAINI")[1]),"","",	"",".F.",50,.F.})// MV_PAR08
	
	If ParamBox(aParBox,"IMPRESSÃO ETIQUETA",,,,,,,,cPerg,.T.,.T.)
		Processa({|| impEtiqueta()})
	EndIf
	
Return

/*/{Protheus.doc}	impEtiqueta
Realiza a impressão da etiqueta

@author			Julio Lisboa - FSW TOTVS IP Campinas
@since				22/06/2015
@return			nil
/*/
Static Function impEtiqueta()
	
	Local aAreaAtu		:= GetArea()
	Local aAreaSH6		:= SH6->(GetArea())
	Local aAreaSC2		:= SC2->(GetArea())
	Local nQtdEtiq		:= 0
	Local lImpCab			:= .F.
	Local cCampoDiv		:= "B1_QE"
	Local nDivisor		:= 0
	Local nZ				:= 0
	
	SH6->(DbSetOrder(1)) //H6_FILIAL+H6_OP+H6_PRODUTO+H6_OPERAC+H6_SEQ+DTOS(H6_DATAINI)+H6_HORAINI+DTOS(H6_DATAFIN)+H6_HORAFIN
	SC2->(DbSetOrder(1))	//C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
	
	If SH6->(DbSeek(xFilial("SH6") + MV_PAR03 + MV_PAR04 + MV_PAR05 + MV_PAR06 + DToS(MV_PAR07) + MV_PAR08))
		If SC2->(DbSeek(xFilial("SC2") + MV_PAR03))
			
			//Verifica se o apontamento selecionado movimenta estoque
			If U_getLastOperac(SH6->H6_PRODUTO) == SH6->H6_OPERAC
				If MV_PAR01 == "SIM"
					lImpCabec		:= .T.
				EndIf
				
				//Seta o local de impressão
				If !Empty(MV_PAR02)
					If !CB5SetImp(MV_PAR02)
						MsgStop("Problemas no local de impressão!")
						return
					EndIf
				EndIf

				nDivisor := Posicione("SB1",1,xFilial("SB1") + SH6->H6_PRODUTO,cCampoDiv)
				
				If nDivisor == 0
					nQtdEtiq := 1
				Else
					nQtdEtiq := Ceiling(SH6->H6_QTDPROD / nDivisor)
				EndIf
				
				//Chama a rotina de impressão das etiquetas
				For nZ := 1 to nQtdEtiq
					U_valImpEt("",1,lImpCabec,2,nQtdEtiq,nZ)
				Next
				
			EndIf
		EndIf
	EndIf
	
	RestArea(aAreaSC2)
	RestArea(aAreaSH6)
	RestArea(aAreaAtu)
	
Return
