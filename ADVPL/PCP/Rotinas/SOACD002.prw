#include 'rwmake.ch'
#include 'protheus.ch'
#include 'Topconn.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CIPCP006  ºAutor  ³Leonardo Azevedo    º Data ³  29/09/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para efetuar o endereçamento automatico dos itens   º±±
±±º          ³ produzidos com base no parametro MV_ZZENDER                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SOACD002()
	
	Local nUsaEnd := SuperGetMv("ZZ_USAENDE",,2)
	
	If nUsaEnd == 1
		
		fGrvEnd(SD3->D3_ITEM,SD3->D3_COD,SD3->D3_LOCAL,SD3->D3_NUMSEQ,SD3->D3_DOC,SD3->D3_QUANT,SD3->D3_OP)
		
	EndIf
	
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CIPCP006  ºAutor  ³Leonardo Azevedo    º Data ³  29/09/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fGrvEnd(cItem,cProduto,cLocal,cNumSeq,cDoc,nQuant,cOp)
	
	Local aCab     	:= {}
	Local aItem    	:= {}
	Local cEndPI     	:= SuperGetMV("ZZ_ENDEPI",,"30")
	Local cEndPA     	:= SuperGetMV("ZZ_ENDEPA",,"30")
	Local aAreaAll	:= Lj7GetArea({"CB0","SDA","SDB","SD3","SA1"})
	Local cEnd			:= ""
	Local cQry			:= ""
	Local nRegs		:= 0
	Private	lMsErroAuto := .F.
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1")+cProduto)
		cEnd := IIF(alltrim(SB1->B1_TIPO)=='PI',cEndPI,IIF(alltrim(SB1->B1_TIPO)=='PA',cEndPA,""))
	Else
		Return
	EndIf
	
	If !Empty(cEnd)
		
		dbSelectArea("SDA")
		dbSetOrder(1)
		if SDA->(dbSeek(xFilial("SDA")+cProduto+cLocal+cNumSeq+cDoc))
			
			aCab:={{"DA_PRODUTO",	SDA->DA_PRODUTO,	nil},;
				{"DA_LOCAL",		SDA->DA_LOCAL,	nil},;
				{"DA_NUMSEQ",		SDA->DA_NUMSEQ,	nil},;
				{"DA_DOC",			SDA->DA_DOC,		nil}}
			
			aItens:={{	{"DB_ITEM",		"0001",	nil},;
				{"DB_LOCALIZ",	cEnd,		nil},;
				{"DB_QUANT",  	nQuant,	nil},;
				{"DB_DATA",		dDataBase,	nil}}}
			
			
			MsExecAuto({|x,y|mata265(x,y)},aCab,aItens)
			
			If lMsErroAuto
				MostraErro()
				RollBackSX8()
				DisarmTransaction()
			Else
				cQry := "SELECT CB0_CODETI"
				cQry += " FROM "+RetSQLName("CB0")
				cQry += " WHERE D_E_L_E_T_ <> '*'"
				cQry += " AND CB0_NUMSEQ = '"+cNumSeq+"'"
				cQry += " AND CB0_OP = '"+cOp+"'"
				
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
	
	EndIf
	
Return
