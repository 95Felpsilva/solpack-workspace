#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} M460FIM
Este P.E. e' chamado apos a Gravacao da NF de Saida, e fora da transação.
@type function
@author Julio Lisboa - FSW TOTVS IP Campinas
@since 12/06/2015
@version 1.0
/*/
User Function M460FIM()

	Local aAreaAtu	:= GetArea()
	Local aAreaSD2	:= SD2->(GetArea())
	Local aAreaSC5	:= SC5->(GetArea())
	Local aAreaSA1	:= SA1->(GetArea())
	Local aAreaSF2	:= SF2->(GetArea())

	Local nPLiqui 	:= 0
	Local nPBruto		:= 0
	Local nQtde		:= 0
	Local nVolume		:= 0
	Local lContLote	:= .F.

	Private cA1_MENSAGE	:= CriaVar("A1_MENSAGE")
	Private cC5_MENPAD	:= CriaVar("C5_MENPAD")
	Private cC5_MENNOTA	:= CriaVar("C5_MENNOTA")
	Private cF2_ZZMARCA	:= CriaVar("F2_ZZMARCA")
	Private cF2_ZZPLACA	:= CriaVar("F2_ZZPLACA")
	Private cF2_ZZNUMER  := CriaVar("F2_ZZNUMER")
	Private cF2_ZZUFPLA  := CriaVar("F2_ZZUFPLA")
	Private cMensTES	:= ""

	Private F2_TRANSP, F2_REDESP, F2_PLIQUI, F2_PBRUTO, F2_VOLUME1, F2_ESPECI1

	//trava a nota fiscal para impedir a transmissão para o SEFAZ antes do usuário preencher/validar as informações referente ao peso
	recLock("SF2",.f.)

	// inicio calculo do peso liquido
	SD2->(dbSetOrder(3))
	SD2->(dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
	Do While !SD2->(EOF()) .and. SD2->D2_FILIAL == xFilial("SD2") .and. SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
		nPLiqui += SD2->D2_QUANT * Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_PESO")
		nPBruto += SD2->D2_QUANT * Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_PESBRU")

		nQtde		:= Ceiling(SD2->D2_QUANT / Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_QE"))
		lContLote	:= Posicione("SB1",1,xFilial("SB1") + SD2->D2_COD,"B1_RASTRO") == "L"

		If lContLote
			nVolume += 1
		Else
			nVolume += nQtde
		EndIf

		recLock("SD2",.f.)
		if SD2->(fieldPos("D2_ZZPESLI")) > 0
			SD2->D2_ZZPESLI := SB1->B1_PESO
			SD2->D2_ZZPESBR := SB1->B1_PESBRU
		endif
		SD2->(msUnlock())

		SD2->(dbSkip())
	Enddo
	// fim
	// inicio template mensagens da NF
	SD2->(dbSetOrder(3))
	SD2->(dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))

	buscaMsgTes(xFilial("SD2") + SD2->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA))

	SC5->(dbSetOrder(1))
	SC5->(dbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
	cC5_MENPAD		:= SC5->C5_MENPAD
	cC5_MENPAD		:= Posicione("SM4",1,xFilial("SM4") + cC5_MENPAD,"M4_DESCR")
	cC5_MENNOTA	:= SC5->C5_MENNOTA

	//Trata as informações do veiculo
	trataVeiculo()

	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1") + SC5->(C5_CLIENTE + C5_LOJACLI)))
	cA1_MENSAGE	:= SA1->A1_MENSAGE
	cA1_MENSAGE	:= Posicione("SM4",1,xFilial("SM4") + cA1_MENSAGE,"M4_DESCR")

	M->F2_TRANSP  := SC5->C5_TRANSP
	M->F2_REDESP  := SC5->C5_REDESP
	M->F2_PLIQUI  := nPLiqui
	M->F2_PBRUTO  := nPBruto
	M->F2_VOLUME1 := IIF(nVolume == 0,SF2->F2_VOLUME1,nVolume)
	M->F2_ESPECI1 := IIF(Empty(SC5->C5_ESPECI1),"VOLUMES",SC5->C5_ESPECI1)

	Define MsDialog oDlg From 0,0 to 370,750 Title "Dados da NF " + SF2->(F2_DOC + "/" + F2_SERIE) Pixel

	@ 005,05 Say   "Transp.     :"    of oDlg Pixel
	@ 004,55 MsGet M->F2_TRANSP  of oDlg VALID {||iif(!Empty(M->F2_TRANSP),ExistCpo("SA4",M->F2_TRANSP),.t.)} F3 "SA4" Pixel

	@ 020,05 Say   "Redesp.     :"    of oDlg Pixel
	@ 019,55 MsGet M->F2_REDESP  of oDlg VALID {||iif(!Empty(M->F2_REDESP),ExistCpo("SA4",M->F2_REDESP),.t.)} F3 "SA4" Pixel

	@ 035,05 Say   "Peso Liq.   :"    of oDlg Pixel
	@ 034,55 MsGet M->F2_PLIQUI  of oDlg VALID {||Positivo()} Picture PesqPict("SF2","F2_PLIQUI") Pixel

	@ 050,05 Say   "Peso Brut.  :"    of oDlg Pixel
	@ 049,55 MsGet M->F2_PBRUTO  of oDlg VALID {||Positivo()} Picture PesqPict("SF2","F2_PBRUTO") Pixel

	@ 065,05 Say   "Volume      :"    of oDlg Pixel
	@ 064,55 MsGet M->F2_VOLUME1 of oDlg VALID {||Positivo()} Picture PesqPict("SF2","F2_VOLUME1") Pixel

	@ 080,05 Say   "Especie     :"    of oDlg Pixel
	@ 079,55 MsGet M->F2_ESPECI1 of oDlg Pixel Picture "@!"

	//Julio Lisboa
	@ 095,05 Say   "Mens.TES:"    of oDlg Pixel
	@ 094,55 MsGet cMensTES of oDlg When .F. Pixel Picture "@!"

	@ 110,05 Say   "Mens.Cli.   :"    of oDlg Pixel
	@ 109,55 MsGet cA1_MENSAGE of oDlg When .F. Pixel Picture "@!"

	@ 125,05 Say   "Mens.Pedido.:"    of oDlg Pixel
	@ 124,55 MsGet cC5_MENPAD of oDlg When .F. Pixel Picture "@!"

	@ 140,05 Say   "Mens.Nota   :"    of oDlg Pixel
	@ 139,55 MsGet cC5_MENNOTA of oDlg Pixel Picture "@!"

	//Dados do Veiculo
	@ 005,155 Say   "Placa       :"    of oDlg Pixel
	@ 004,185 MsGet cF2_ZZPLACA of oDlg VALID {||cF2_ZZPLACA := upper(cF2_ZZPLACA),.t.} Picture "@R XXX-9999" Pixel

	@ 020,155 Say   "UF Placa    :"    of oDlg Pixel
	@ 019,185 MsGet cF2_ZZUFPLA of oDlg VALID {||iif(!Empty(cF2_ZZUFPLA),ExistCpo("SX5","12"+cF2_ZZUFPLA),.t.)} Pixel Picture "@!"

	//@ 035,155 Say   "Marca       :"    of oDlg Pixel
	//@ 034,185 MsGet cF2_ZZMARCA of oDlg Pixel

	//@ 050,155 Say   "Numero      :"    of oDlg Pixel
	//@ 049,185 MsGet cF2_ZZNUMER of oDlg Pixel

	Define sButton Type 1 From 165,105 Enable of oDlg Pixel Action oDlg:End()
	Define sButton Type 2 From 165,135 Enable of oDlg Pixel Action oDlg:End()

	Activate MsDialog oDlg Centered

	Grava()
	
	//dispara e-mail do suframa para o usuario
	u_MailStatusPIN()

	impEtqNF()

	u_estornaLibCredito()

	RestArea(aAreaSF2)
	RestArea(aAreaSA1)
	RestArea(aAreaSC5)
	RestArea(aAreaSD2)
	RestArea(aAreaAtu)

Return

/*/{Protheus.doc} Grava
Realiza a gravação na SF2 e SC5
@type function
@author Julio Lisboa - FSW TOTVS IP Campinas
@since 19/06/2015
@version 1.0
/*/
Static Function Grava()

	//RecLock("SF2",.f.)
	SF2->F2_TRANSP := M->F2_TRANSP
	SF2->F2_REDESP := M->F2_REDESP
	SF2->F2_PLIQUI := M->F2_PLIQUI
	SF2->F2_PBRUTO := M->F2_PBRUTO
	SF2->F2_VOLUME1:= M->F2_VOLUME1
	SF2->F2_ESPECI1:= M->F2_ESPECI1

	SF2->F2_ZZMARCA := cF2_ZZMARCA
	SF2->F2_ZZPLACA := cF2_ZZPLACA
	SF2->F2_ZZNUMER := cF2_ZZNUMER
	SF2->F2_ZZUFPLA := cF2_ZZUFPLA

	if u_IsClienteSuframa(SF2->F2_CLIENTE,SF2->F2_LOJA)
		SF2->F2_ZZSTPIN := "BR_VERMELHO"
	else
		SF2->F2_ZZSTPIN := "BR_AZUL"
	endif

	// tratativa para gravar o conteudo do C5_MENNOTA no F2_MENNOTA,
	// pois no nfesefaz.prw a prioridade para levar o conteudo no danfe é
	// do SF2->F2_MENNOTA
	if SF2->(FieldPos("F2_MENNOTA")) > 0
		SF2->F2_MENNOTA := cC5_MENNOTA
	endif

	SF2->(MsUnlock())

	RecLock("SC5",.F.)
	SC5->C5_TRANSP 	:= SF2->F2_TRANSP
	SC5->C5_REDESP 	:= SF2->F2_REDESP
	SC5->C5_ESPECI1	:= SF2->F2_ESPECI1
	SC5->C5_MENNOTA	:= cC5_MENNOTA
	SC5->(MsUnlock())

Return
/*/{Protheus.doc} buscaMsgTes
Busca as Mensagens da TES
@type function
@author Julio Lisboa - FSW TOTVS IP Campinas
@since 19/06/2015
@version 1.0
/*/
Static Function buscaMsgTes(cWhere)

	Local aAreaSF4	:= SF4->(GetArea())
	Local aAreaSD2	:= SD2->(GetArea())
	Local cTexto		:= ""

	SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	SF4->(DbSetOrder(1)) //F4_FILIAL+F4_CODIGO

	If SD2->(DbSeek(cWhere))
		While SD2->(!Eof()) .AND. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == cWhere

			//Posiciona na TES
			If SF4->(DbSeek(xFilial("SF4") + SD2->D2_TES))
				cTexto := Posicione("SM4",1,xFilial("SM4") + SF4->F4_FORMULA,"M4_DESCR")
				If !(Empty(cTexto))
					//Verifica se o texto ja está contido
					If !(cTexto $ cMensTES)
						cMensTES += IIF(Empty(cMensTES),cTexto,"-" + cTexto)
					EndIf
				EndIf
			EndIf

			SD2->(DbSkip())
		EndDo
	EndIf

	RestArea(aAreaSD2)
	RestArea(aAreaSF4)

Return
/*/{Protheus.doc} trataVeiculo
Trata as informações do veículo
@type function
@author Julio Lisboa - FSW TOTVS IP Campinas
@since 19/06/2015
@version 1.0
/*/
Static function trataVeiculo()

	Local aAreaDA3		:= DA3->(GetArea())

	DA3->(dbSetOrder(1))	//DA3_FILIAL+DA3_COD

	If !(Empty(SC5->C5_VEICULO))
		If DA3->(DbSeek(xFilial("DA3") + SC5->C5_VEICULO))
			cF2_ZZPLACA := DA3->DA3_PLACA
			cF2_ZZUFPLA := DA3->DA3_ESTPLA
		EndIf
	EndIf

	RestArea(aAreaDA3)

return

static function impEtqNF()
	local lAtivo := getNewPar("ZZ_ETQNFAT",.t.)
	local lExibeTela := getNewPar("ZZ_ETQNFTL",.f.)
	local lAtivaM460 := getNewPar("ZZ_ETIMPPE",.f.)

	if lAtivo .and. lAtivaM460
		if lExibeTela
			u_ReImpNFEtq(.t./*lMark*/)
		else
			u_EtiqNF()
		endif
	endif
return
