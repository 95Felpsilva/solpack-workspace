#include "Protheus.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT100AGR  ºAutor  ³Leonardo Azevedo    º Data ³  24/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ CAMPO B1_ZZLOCPD ENDEREÇO PADRÃO                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT100AGR()

Local aArea    := GetArea()
Local aAreaSD1 := SD1->(GetArea())
Local cEnd     := ""
//Local cEndPA     	:= SuperGetMV("ZZ_ENDEPA",,"30")
Local cEndNfe := SuperGetMV("ZZ_ENDNFE",,"32")
        

dbSelectArea("SD1")
If SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))	
	While SD1->(!Eof()) .and. xFilial("SF1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+;
		SD1->D1_FORNECE+SD1->D1_LOJA
		if Posicione("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_ESTOQUE")=="S"
			if Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_LOCALIZ")=="S"
				//fGrvEnd(SD1->D1_ITEM,SD1->D1_COD,SD1->D1_LOCAL,SB1->B1_ZZLOCPD,SD1->D1_NUMSEQ,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_QUANT)
				fGrvEnd(SD1->D1_ITEM,SD1->D1_COD,SD1->D1_LOCAL,cEndNfe,SD1->D1_NUMSEQ,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_QUANT)
			endif
		endif
		SD1->(dbSkip())
	EndDo
endif 

RestArea(aArea)
RestArea(aAreaSD1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT100AGR  ºAutor  ³Leonardo Azevedo    º Data ³  24/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fGrvEnd(cItem,cProduto,cLocal,cEnd,cNumSeq,cDoc,cSerie,cFornece,cLoja,nQuant)

Local aCab     := {}
Local aItem    := {}         
Local aArea    := GetArea()   
Local aAreaSF1 := SF1->(GetArea())
Local aAreaSD1 := SD1->(GetArea())  
Local aAreaAll	:= Lj7GetArea({"CB0"}) //joni
Local cQry		:= ""

Private	lMsErroAuto := .F.

dbSelectArea("SDA")
dbSetOrder(1)
if dbSeek(xFilial("SDA")+cProduto+cLocal+cNumSeq+cDoc+cSerie+cFornece+cLoja)
	
	aCab:={	{"DA_PRODUTO",	SDA->DA_PRODUTO, nil},;
           	{"DA_LOCAL",	SDA->DA_LOCAL,	 nil},;
         	{"DA_NUMSEQ",	SDA->DA_NUMSEQ,  nil},;
        	{"DA_DOC",		SDA->DA_DOC,	 nil}}
	
	aItens:={{ {"DB_ITEM",		cItem,	   		 nil},;
               {"DB_LOCALIZ",	cEnd,   		 nil},;
	           {"DB_QUANT",  	nQuant,    	     nil},;
	           {"DB_DATA",		dDATABASE,		 nil}}}
	
	
	//MsgRun("Executando endereçamento do produto",,{||msExecAuto({|x,y|mata265(x,y)},aCab,aItens)})
	MsExecAuto({|x,y|mata265(x,y)},aCab,aItens)
	
	If lMsErroAuto
		MostraErro()
		RollBackSX8()
		DisarmTransaction()
	Else
		cQry := "SELECT CB0_CODETI"
		cQry += " FROM "+RetSQLName("CB0")
		cQry += " WHERE D_E_L_E_T_ <> '*'"
		//cQry += " AND CB0_NUMSEQ = '"+cNumSeq+"'"
		cQry += " AND CB0_NFENT = '"+cDoc+"'"
		cQry += " AND CB0_SERIEE = '"+cSerie+"'"
		cQry += " AND CB0_ITNFE = '"+cItem+"'" 
		cQry += " AND CB0_FORNEC = '"+cFornece+"'"
		cQry += " AND CB0_LOJAFO = '"+cLoja+"'"
		
		
		If Select("TRBCB0") > 0
			TRBCB0->(dbCloseArea())
		EndIf
		
		TcQuery cQry New Alias "TRBCB0"
		
		dbSelectArea("TRBCB0")
		
		Count To nRegs
		
		If nRegs > 0
			dbSelectArea("TRBCB0")
			dbGoTop()
			While !TRBCB0->(eof())
				dbSelectArea("CB0")
				dbSetOrder(1)
				If dbSeek(xFilial("CB0")+TRBCB0->CB0_CODETI)
					If RecLock("CB0",.F.)
						CB0->CB0_LOCALI := cEnd
						MsUnlock()
					EndIf
				EndIf
				TRBCB0->(dbSkip())
			EndDo
		EndIf
		
		If Select("TRBCB0") > 0
			TRBCB0->(dbCloseArea())
		EndIf
	EndIf
Endif        

restArea(aArea)   
RestArea(aAreaSF1)
RestArea(aAreaSD1)

Return