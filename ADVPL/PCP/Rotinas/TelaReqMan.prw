#Include "Protheus.ch"
#Include "Topconn.ch"

#DEFINE	NPOS_TM			001
#DEFINE	NPOS_CODIGO		002
#DEFINE	NPOS_ORDPRO		003
#DEFINE	NPOS_UNMED		004
#DEFINE	NPOS_QTDORI		005
#DEFINE	NPOS_QUANT		006
#DEFINE	NPOS_FATCON		007
#DEFINE	NPOS_TPDECI		008
#DEFINE	NPOS_LOCAL		009
#DEFINE	NPOS_LOTE		010
#DEFINE	NPOS_ENDERE		011

#DEFINE	CPO_QTD_ESTRU	"ZZ_QTDESTRU"
#DEFINE	CPO_FAT_CORRI	"ZZ_FATCORRI"

USER FUNCTION TSTREQMAN()
	RpcSetEnv("01","0101")
	M->H6_OP := "02296501001"
	M->H6_QTDPROD := 10
	M->H6_PRODUTO := "40.10.01.0672  "
	M->H6_QTDPRO2 := 10

	implog("TESTSE")
	return
	u_TELAREQMAN()
	RpcClearEnv()
RETURN

/*/{Protheus.doc}	TelaReqMan
Tela com os dados para chamada da rotina automática MATA241

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since				07/12/2015
@return				lRetorno
/*/
User Function TelaReqMan()

	Local aAreaAtu		:= GetArea()
	Local aAreaSC2		:= SC2->(GetArea())
	Local aAreaSD3		:= SD3->(GetArea())
	Local aAreaSB1		:= SB1->(GetArea())

	Private lOnPerson	:= GetNewPar("ZZ_ONREQM",.F.)
	Private lOnTela		:= GetNewPar("ZZ_TELAREQ",.T.)
	Private lEmpenho	:= .F.
	Private aCabec		:= {}
	Private aItens		:= {}
	Private lRetorno	:= .T.

	If !lOnPerson
		lRetorno := .T.
	Else
		If SC2->(FieldPos("C2_ZZEMPEN")) > 0
			lEmpenho := Posicione("SC2",1,xFilial("SC2") + M->H6_OP,"C2_ZZEMPEN") == "1"
			AbreTela()
		EndIf
	EndIf

	RestArea(aAreaSB1)
	RestArea(aAreaSD3)
	RestArea(aAreaSC2)
	RestArea(aAreaAtu)

Return (lRetorno)

/*/{Protheus.doc}	AbreTela
Abre a Tela com os dados

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since				07/12/2015
@return				nil
/*/
Static Function AbreTela()

	Local cTitulo		:= "Requisição Manual"
	Local cValid		:= "AlwaysTrue()"
	Local aEditCpo	:= {}

	Private aHeader		:= {}
	Private oDlg			:= nil
	Private oGetDados		:= nil

	If lOnTela
		MsgRun("Aguarde...",FunDesc(),{|| GetHeader(),BuscaDados()})

		Define MsDialog oDlg From 0,0 to 300,880 Pixel Title cTitulo Style 128
		oDlg:lEscClose     := .F.
		oGetDados :=	MsNewGetDados():New(010,2,122,440,GD_UPDATE,cValid,cValid,"",aEditCpo,,,,,,oDlg,aHeader,aItens)
		@ 135,300 Button "Confirmar"     	of oDlg Size 40,10 Pixel Action (ExecReq())
		@ 135,350 Button "Sair"      		of oDlg Size 40,10 Pixel Action (lRetorno := .F.,oDlg:End())
		Activate MsDialog oDlg Centered
	Else
		BuscaDados()
		ExecReq()
	EndIf

Return

/*/{Protheus.doc}	GetHeader
Monta o cabeçalho

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since				07/12/2015
@return				nil
/*/
Static Function GetHeader()
	Local nI			:= 0
	Local aCampos		:= {"D3_TM","D3_COD","D3_OP","D3_UM","D3_QUANT","B1_CONV","B1_TIPODEC","D3_LOCAL","D3_LOTECTL","D3_LOCALIZ"}
	local cCampo		:= ""
	local cTitulo		:= ""
	local cIDField		:= ""
	
	For nI := 1 to Len(aCampos)
		cCampo := aCampos[nI]
		If cCampo == "D3_QUANT"
			cIDField := CPO_QTD_ESTRU
			If lEmpenho
				cTitulo := "Quant.Empenho"
			Else
				cTitulo := "Quant.Estrut."
			EndIf
		EndIf

		If cCampo == "B1_CONV"
			cTitulo := "Fator Corrigido"
			cIDField  := CPO_FAT_CORRI
		Else
			cTitulo 	:= getSX3Cache(cCampo,"X3_TITULO")
			cIDField 	:= AllTrim(getSX3Cache(cCampo,"X3_CAMPO"))
		EndIf

		Aadd(aHeader,{cTitulo,cIDField,getSX3Cache(cCampo,"X3_PICTURE"),getSX3Cache(cCampo,"X3_TAMANHO"),getSX3Cache(cCampo,"X3_DECIMAL"),,getSX3Cache(cCampo,"X3_TIPO"),getSX3Cache(cCampo,"X3_F3")})
	Next
Return

/*/{Protheus.doc}	BuscaDados
Busca os dados para montar a tela

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since				07/12/2015
@return				nil
/*/
Static Function BuscaDados()

	Local aAreaSB1	:= SB1->(GetArea())
	Local cQuery		:= ""
	Local cAlias		:= GetNextAlias()
	Local cTM			:= GetNewPar("ZZ_CODTM","")
	Local cArqui		:= CriaTrab(,.F.)
	Local cEndereco		:= ""

	Local cUnidMed	:= ""
	Local nQtd			:= 0
	Local cArmazem	:= ""
	Local nQuantOP	:= 0
	Local nQuantApont	:= M->H6_QTDPROD
	Local nFatConv	:= 0

	Private nEstru	:= 0

	If lEmpenho
		cQuery		+= "SELECT " + CRLF
		cQuery		+= "	*" + CRLF
		cQuery		+= "FROM " + CRLF
		cQuery		+= "	" + RetSqlName("SD4") + " AS SD4 " + CRLF
		cQuery		+= "WHERE " + CRLF
		cQuery		+= "	D4_FILIAL = '" + xFilial("SD4") + "' AND " + CRLF
		cQuery		+= "	D4_OP = '" + M->H6_OP + "' AND " + CRLF
		cQuery		+= "	SD4.D_E_L_E_T_ = ' ' " + CRLF
		cQuery		+= "ORDER BY " + CRLF
		cQuery		+= "	D4_COD " + CRLF

		TcQuery cQuery New Alias &cAlias

		If (cAlias)->(!Eof())
			nFatConv	:= Posicione("SB1",1,xFilial("SB1") + M->H6_PRODUTO,"B1_CONV")
			While (cAlias)->(!Eof())

				SB1->(DbSetOrder(1))	//B1_FILIAL+B1_COD
				If SB1->(DbSeek(xFilial("SB1") + (cAlias)->D4_COD))

					nQuantOP	:= Posicione("SC2",1,xFilial("SC2") + M->H6_OP,"C2_QUANT")
					cUnidMed	:= SB1->B1_UM
					nQtd		:= (nQuantApont / nQuantOP) * (cAlias)->D4_QTDEORI

					//cArmazem	:= IIF(Empty(SB1->B1_ZZLOCPR),SB1->B1_LOCPAD,SB1->B1_ZZLOCPR)
					cArmazem	:= (cAlias)->D4_LOCAL

					//Busca a Localização do Produto
					If SB1->B1_LOCALIZ == "S"
						cEndereco	:= Posicione("NNR",1,xFilial("NNR") + cArmazem,"NNR_ZZEND")
					Else
						cEndereco	:= ""
					EndIf

					Aadd(aItens,{;
						cTM,;							// 01 - Tipo de Movimentação
					(cAlias)->D4_COD,;					// 02 - Código do Produto
					M->H6_OP,;							// 03 - Ordem de Produção
					cUnidMed,;							// 04 - Unidade de Medida
					(cAlias)->D4_QTDEORI,;				// 05 - Quantidade Original
					nQtd,;								// 06 - Quantidade
					nFatConv,;							// 07 - Fator de Conversão
					SB1->B1_TIPODEC,;					// 08 - Tipo de Decimais
					cArmazem,;							// 09 - Armazem
					(cAlias)->D4_LOTECTL,;				// 10 - Lote
					cEndereco,;							// 11 - Endereço
					.F.;								// 12 - Deletado
					})
				EndIf

				(cAlias)->(DbSkip())
			EndDo
		EndIf
		(cAlias)->(DbCloseArea())
	Else

		cArqui			:= Estrut2(M->H6_PRODUTO,nQuantApont,cAlias)
		nFatConv		:= PesoTotal(cAlias)

		If Select(cAlias) > 0
			(cAlias)->(dbGoTop())
			//nFatConv	:= Posicione("SB1",1,xFilial("SB1") + M->H6_PRODUTO,"B1_CONV")	//TODO

			While (cAlias)->(!Eof())

				If (cAlias)->NIVEL == StrZero(1,Len((cAlias)->NIVEL))
					SB1->(DbSetOrder(1))	//B1_FILIAL+B1_COD
					If SB1->(DbSeek(xFilial("SB1") + (cAlias)->COMP))

						nQuantOP	:= Posicione("SC2",1,xFilial("SC2") + M->H6_OP,"C2_QUANT")
						cUnidMed	:= SB1->B1_UM
						nQtd		:= ((M->H6_QTDPRO2 / nQuantApont) / nFatConv) * (cAlias)->QUANT

						If SB1->B1_TIPODEC == "I"
							nQtd	:= Int(nQtd)
						EndIf

						cArmazem	:= IIF(Empty(SB1->B1_ZZLOCPR),SB1->B1_LOCPAD,SB1->B1_ZZLOCPR)

						//Busca a Localização do Produto
						If SB1->B1_LOCALIZ == "S"
							cEndereco	:= Posicione("NNR",1,xFilial("NNR") + cArmazem,"NNR_ZZEND")
						Else
							cEndereco	:= ""
						EndIf

						Aadd(aItens,{;
							cTM,;							// 01 - Tipo de Movimentação
						(cAlias)->COMP,;					// 02 - Código do Produto
						M->H6_OP,;							// 03 - Ordem de Produção
						cUnidMed,;							// 04 - Unidade de Medida
						(cAlias)->QUANT,;					// 05 - Quantidade Original
						nQtd,;								// 06 - Quantidade
						nFatConv,;							// 07 - Fator de Conversão
						SB1->B1_TIPODEC,;					// 08 - Tipo de Decimais
						cArmazem,;							// 09 - Armazem
						"",;								// 10 - Lote
						cEndereco,;							// 11 - Endereço
						.F.;								// 12 - Deletado
						})
					EndIf
				EndIf

				(cAlias)->(DbSkip())
			EndDo
		EndIf
	EndIf

	RestArea(aAreaSB1)

Return

/*/{Protheus.doc}	ExecReq
Executa a rotina automática

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since				07/12/2015
@return				nil
/*/
Static Function ExecReq()

	Local aCabecTMP		:= {}
	Local aItensTMP		:= {}
	Local nZ				:= 1
	Local cTM				:= GetNewPar("ZZ_CODTM","")

	Private lMsHelpAuto	:= .T. // Se .T. direciona as mensagens de Help
	Private lMsErroAuto	:= .F. // Necessario a criacao

	For nZ := 1 to Len(aItens)
		Aadd(aItensTMP,{;
			{"D3_COD",			aItens[nZ,NPOS_CODIGO],	nil},;
			{"D3_UM",			aItens[nZ,NPOS_UNMED],	nil},;
			{"D3_QUANT",		aItens[nZ,NPOS_QUANT],	nil},;
			{"D3_OP",			aItens[nZ,NPOS_ORDPRO],	nil},;
			{"D3_LOCAL",		aItens[nZ,NPOS_LOCAL],	nil},;
			{"D3_LOCALIZ",		aItens[nZ,NPOS_ENDERE],	nil},;
			{"D3_LOTECTL",		aItens[nZ,NPOS_LOTE],	nil};
			})
	Next

	aCabecTMP	:= {{"D3_TM",cTM,nil},{"D3_EMISSAO",dDataBase,nil}}

	Begin Transaction

		MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabecTMP,aItensTMP,3)

		If lMsErroAuto

			ImpLog(Replicate("*",25))
			ImpLog("ERRO")
			ImpLog(Replicate("*",25))

			lRetorno := .F.
			Mostraerro()
			DisarmTransaction()
		Else
			lRetorno	:= .T.

			ImpLog(Replicate("*",25))
			ImpLog("ROTINA MATA241 - Executada com Sucesso !")
			ImpLog(Replicate("*",25))

			If lOnTela
				oDlg:End()
			EndIf
		EndIf

	End Transaction

Return

/*/{Protheus.doc}	PesoTotal
Busca o Peso Total de todos os Insumos

@type				Function
@author				Julio Lisboa - FSW TOTVS IP Campinas
@since				02/02/2016
@return				nTotal
/*/
Static Function PesoTotal(cAlias)

	Local nTotal			:= 0

	If Select(cAlias) > 0
		(cAlias)->(dbGoTop())
		While (cAlias)->(!Eof())

			If (cAlias)->NIVEL == StrZero(1,Len((cAlias)->NIVEL))
				nTotal	+= (cAlias)->QUANT
			EndIf

			(cAlias)->(DbSkip())
		EndDo
	EndIf

	(cAlias)->(DbGoTop())

return (nTotal)

/*/{Protheus.doc}	ImpLog
Gera Informação no Log

@type		Function
@author 	Julio Lisboa - FSW TOTVS IP Campinas
@since		15/04/2016
@return		nil
/*/
Static Function ImpLog(cTexto)
	Default cTexto		:= ""

	If !Empty(cTexto)
		FwLogMsg("INFO", /*cTransactionId*/, "TELAREQMAN", FunName(), "", "01", "REQUISIÇÃO MANUAL - " + cTexto, 0, seconds() , {}) // nStart é declarada no inicio da função
		//Conout("[" + cData + " " + cHora + "] REQUISIÇÃO MANUAL - " + cTexto)
	EndIf
Return
