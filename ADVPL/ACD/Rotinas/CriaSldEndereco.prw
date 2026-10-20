#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} CriaSldEndereco
Rotina que irá criar os saldos por endereço

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			17/07/2015
@return 		nil
/*/
User Function CriaSldEndereco()
	
	Local aAreaAtu		:= GetArea()
	Local aParambox		:= {}
	
	Aadd(aParambox,{1,"Endereço"	,Space(TamSX3("BE_LOCALIZ")[1]),"","",	"SBE","",70,.T.})		//MV_PAR01
	Aadd(aParambox,{1,"Armazem De"	,Space(TamSX3("NNR_CODIGO")[1]),"","",	"NNR","",50,.F.})		//MV_PAR02
	Aadd(aParambox,{1,"Armazem Ate"	,Space(TamSX3("NNR_CODIGO")[1]),"","",	"NNR","",50,.F.})		//MV_PAR03
	
	//Valida o endereço que será gerado os saldos
	If ParamBox(aParambox,"ENDEREÇO SALDO",,,,,,,,"ENDSLD",.T.,.T.)
		Processa({||geraSldEnd()})
	EndIf
	
	RestArea(aAreaAtu)
	
Return

/*/{Protheus.doc} geraSldEnd
Inicia a geração de saldo por endereço

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			17/07/2015
@return 		nil
/*/
Static Function geraSldEnd()
	
	Local cQry				:= ""
	Local lOk				:= .F.
	Local nContador		:= 0
	Local nQuantReg		:= 0
	Local nQuant			:= 0
	Local aAreaSB2		:= SB2->(GetArea())
	Local aAreaSBF		:= SBF->(GetArea())
	
	Local nPosProd	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DA_PRODUTO"})
	Local nPosLocal	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DA_LOCAL"})
	Local nPosEnder	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DB_LOCALIZ"})
	Local nPosQuant	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DB_QUANT"})
	Local nPosLote	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DA_LOTECTL"})
	
	Private cAlias		:= GetNextAlias()
	Private aColsBase		:= aClone(aCols[1])
	Private aColsTmp		:= aClone(aCols)
	
	cQry += "SELECT" + CRLF
	cQry += "		B2_COD, B2_LOCAL, B2_QATU, B1_RASTRO," + CRLF
	cQry += "		B1_DESC, B8_SALDO, B8_LOTECTL" + CRLF
	cQry += "FROM" + CRLF
	cQry += "		" + RetSqlName("SB2") + " AS SB2" + CRLF
	cQry += "INNER JOIN" + CRLF
	cQry += "		" + RetSqlName("SB1") + " AS SB1" + CRLF
	cQry += "ON" + CRLF
	cQry += "		B1_FILIAL = '" + xFilial("SB1") + "' AND" + CRLF
	cQry += "		B1_COD = B2_COD AND" + CRLF
	cQry += "		B1_LOCALIZ = 'S' AND" + CRLF
	cQry += "		B1_MSBLQL = '2' AND " + CRLF
	cQry += "		SB1.D_E_L_E_T_ = ' '" + CRLF
	cQry += "LEFT JOIN" + CRLF
	cQry += "		" + RetSqlName("SB8") + " AS SB8" + CRLF
	cQry += "ON" + CRLF
	cQry += "		B8_FILIAL = '" + xFilial("SB8") + "' AND" + CRLF
	cQry += "		B8_PRODUTO = B2_COD AND" + CRLF
	cQry += "		B8_SALDO > 0 AND" + CRLF
	cQry += "		B8_LOCAL = B2_LOCAL AND" + CRLF
	cQry += "		SB8.D_E_L_E_T_ = ' '" + CRLF
	cQry += "WHERE" + CRLF
	cQry += "		B2_FILIAL = '" + xFilial("SB2") + "' AND" + CRLF
	cQry += "		B2_QATU > 0 AND" + CRLF
	cQry += "		B2_LOCAL BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' AND " + CRLF
	cQry += "		SB2.D_E_L_E_T_ = ' '" + CRLF
	cQry += "ORDER BY" + CRLF
	cQry += "		B2_COD, B2_LOCAL" + CRLF
	
	TcQuery cQry New Alias &cAlias
	
	Count to nQuantReg
	(cAlias)->(DbGoTop())
	
	ProcRegua(nQuantReg)
	
	//Percorre toda a SB2
	While (cAlias)->(!Eof())
		
		SBF->(DbSetOrder(2)) //BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI
		
		//Só executa caso o produto ainda não estiver endereçado
		If !SBF->(DbSeek(xFilial("SBF") + (cAlias)->B2_COD + (cAlias)->B2_LOCAL))
			
			nContador++	//Incrementa a quantidade de registros
			//se produto controla lote, tem que ser preenchido a quantidade do lote
			If (cAlias)->B1_RASTRO == "L"
				nQuant := (cAlias)->B8_SALDO
			Else
				nQuant := (cAlias)->B2_QATU
			EndIf
			
			If nContador == 1
				aCols[1,nPosProd] 	:= (cAlias)->B2_COD
				aCols[1,nPosLocal]	:= (cAlias)->B2_LOCAL
				aCols[1,nPosEnder] 	:= MV_PAR01
				aCols[1,nPosLote]		:= (cAlias)->B8_LOTECTL
				aCols[1,nPosQuant]	:= nQuant
			Else
				aColsBase[nPosProd] 	:= (cAlias)->B2_COD
				aColsBase[nPosLocal]	:= (cAlias)->B2_LOCAL
				aColsBase[nPosEnder] := MV_PAR01
				aColsBase[nPosLote]	:= (cAlias)->B8_LOTECTL
				aColsBase[nPosQuant]	:= nQuant
				
				Aadd(aCols,aColsBase)
				aColsBase := aClone(aColsTmp[1])
			EndIf
		EndIf
		
		IncProc("Processando produto " + AllTrim((cAlias)->B2_COD) + " [" + AllTrim((cAlias)->B1_DESC) + "]...")
		
		(cAlias)->(DbSkip())
	EndDo
	
	(cAlias)->(DbCloseArea())
	
	RestArea(aAreaSBF)
	RestArea(aAreaSB2)
	
Return
