#Include "Protheus.ch"
#Include 'TopConn.ch'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  º    º Autor º       º Data º  						      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ºPonto de Entrada para atualizar lote na Qualidade (QPK)     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       º Totvs                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MT681INC()

	Local aArea := GetArea()
	Local aAreaQPK := QPK->(GetArea())
	Local aAreaSB8	:= SB8->(GetArea())

	Private aParam	:= {}

	DEFAULT lApp:=.F.

	
	trataParam(aParam)
	
	dbseek(xfilial("SH6")+SH6->H6_OP+SH6->H6_PRODUTO,.F.)
	
	Posicione("QPK",1,xFilial("QPK")+SH6->H6_OP,"QPK_OP")
	While QPK->(!Eof()) .AND. QPK->QPK_FILIAL == xFilial("QPK") .AND. QPK->QPK_OP == SH6->H6_OP;

		RecLock("QPK",.F.) // GRAVAR AS SEGUINTES INFORMACOES NO QPK
		QPK->QPK_LOTE	:= SH6->H6_LOTECTL // NUMERO DO LOTE
		QPK->(MsUnlock())

		QPK->(dbSkip())
	EndDo


	SB8->(DbSetOrder(5)) //B8_FILIAL+B8_PRODUTO+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
	If SB8->(DbSeek(xFilial("SB8") + SH6->H6_PRODUTO + SH6->H6_LOTECTL))
		RecLock("SB8",.F.)
		SB8->B8_ZZOBS := SH6->H6_ZZOBS
		SB8->(MsUnlock())
	EndIf

	//Impressão da Etiqueta
	If ExistBlock("valImpEt") .AND. !lApp
		u_impEtq(.f.)
	EndIf

	RestArea(aAreaSB8)
	RestArea(aAreaQPK)
	RestArea(aArea)

	RestPar(aParam)

Return
/*/{Protheus.doc} impEtq
Imprime a etiqueta de produto intermediário

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			24/07/2015
@return 		nil
/*/
Static Function impEtq()

	Local nQuantEtiq		:= 0
	Local cCampoDiv		:= "B1_QE"
	Local nDivisor		:= Posicione("SB1",1,xFilial("SB1") + SH6->H6_PRODUTO,cCampoDiv)
	Local aParambox		:= {}
	Local nI				:= 0
	Local lImpCabec		:= .F.
	Local cTextoLogo		:= IIF(cFilAnt == "0101","SOLPACK","AGRONET")

	
	if VALTYPE( lApp )=="L"
		return 
		lImpCabec		:= .T.

		If !Empty(MV_PAR02)
			If !CB5SetImp(MV_PAR02)
				MsgStop("Problemas no local de impressão!")
				return
			EndIf
		EndIf

		If nDivisor == 0
			nQuantEtiq := 1
		Else
			nQuantEtiq := Ceiling(SH6->H6_QTDPROD / nDivisor)
		EndIf

		If !Empty(MV_PAR03)
			cTextoLogo := AllTrim(MV_PAR03)
		EndIf


		For nI := 1 to nQuantEtiq
			U_valImpEt(SH6->(alltrim(H6_OP)+H6_IDENT),1,lImpCabec,2,nQuantEtiq,nI)
		Next

		return 

	endif

	Aadd(aParambox,{2,"Imprime dados da Solpack"	,"1",{"SIM","NAO"},50,,.F.})// MV_PAR01
	Aadd(aParambox,{1,"Local de Impressao"	,Space(TamSX3("CB5_CODIGO")[1]),"","",	"CB5","",60,.T.})// MV_PAR02
	Aadd(aParambox,{2,"Logo"	,"1",{cTextoLogo,IIF(cTextoLogo == "SOLPACK","AGRONET","SOLPACK")},60,,.F.})// MV_PAR03

	//Verifica se o usuário vai ou não imprimir
	If ParamBox(aParambox,"IMPRESSÃO DE ETIQUETAS",,,,,,,,"ETQPI_" + GetComputerName(),.T.,.T.)
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

		If nDivisor == 0
			nQuantEtiq := 1
		Else
			nQuantEtiq := Ceiling(SH6->H6_QTDPROD / nDivisor)
		EndIf

		If !Empty(MV_PAR03)
			cTextoLogo := AllTrim(MV_PAR03)
		EndIf


		For nI := 1 to nQuantEtiq
			U_valImpEt(SH6->(alltrim(H6_OP)+H6_IDENT),1,lImpCabec,2,nQuantEtiq,nI)
		Next
	EndIf

Return

/*/{Protheus.doc} trataParam
Trata os parametros

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			15/04/2016
@return 		nil
/*/
Static Function trataParam(aParam)

	Local cSeq			:= "01"
	Local cParametro	:= "MV_PAR" + cSeq
	Local xValor		:= &(cParametro)
	Default aParam		:= {}

	While cSeq <= "60"
		xValor		:= &(cParametro)
		Aadd(aParam,{cParametro,xValor})

		cSeq		:= Soma1(cSeq)
		cParametro	:= "MV_PAR" + cSeq
	EndDo

Return

/*/{Protheus.doc} RestPar
Retorna os valores originais aos parâmetros

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			15/04/2016
@return 		nil
/*/
Static Function RestPar(aParam)

	Local nI		:= 0
	Default aParam	:= {}

	For nI := 1 to Len(aParam)
		&(aParam[nI,1])	:= aParam[nI,2]
	Next

Return

user function tstMT681INC()
	rpcSetEnv("01","0101")
	trataParam()
	RpcClearEnv()
return
