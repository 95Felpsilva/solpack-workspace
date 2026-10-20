#Include "Protheus.ch"

#DEFINE _CODPRODUT	02
#DEFINE _DESCRADIC	25

/*/{Protheus.doc}	PE01NFESEFAZ
PE localizado na função XmlNfeSef do rdmake NFESEFAZ. Através deste ponto é possível realizar manipulações nos dados do produto,
mensagens adicionais, destinatário, dados da nota, pedido de venda ou compra, antes da montagem do XML, no momento da transmissão da NFe.
@type function
@author			Julio Lisboa
@since				12/06/2015
@return			array, retorna array com os valores alterados
/*/
User Function PE01NFESEFAZ()

	Local aAreaAtu		:= GetArea()
	Local aAreaSF2		:= SF2->(GetArea())
	Local aAreaSD2		:= SD2->(GetArea())
	Local aAreaSC6		:= SC6->(GetArea())

	Local aProd			:= PARAMIXB[01]
	Local cMensCli		:= PARAMIXB[02]
	Local cMensFis		:= PARAMIXB[03]
	Local aDest			:= PARAMIXB[04]
	Local aNota   		:= PARAMIXB[05]
	Local aInfoItem		:= PARAMIXB[06]
	Local aDupl			:= PARAMIXB[07]
	Local aTransp		:= PARAMIXB[08]
	Local aEntrega		:= PARAMIXB[09]
	Local aRetirada		:= PARAMIXB[10]
	Local aVeiculo		:= PARAMIXB[11]
	Local aReboque		:= PARAMIXB[12]
	Local aNfrural		:= PARAMIXB[13] //adicionado Joni Santos após mudança. Usar somente com Nfesefaz atualizado após 02/01/2017
	Local aEspVol		:= PARAMIXB[14] //adicionado Joni Santos após mudança. Usar somente com Nfesefaz atualizado após 17/05/2017
	Local aNfVinc		:= PARAMIXB[15] //adicionado Joni Santos para nfe 4.0 25/07/2018
	Local aDetPag		:= PARAMIXB[16] //adicionado Joni Santos para nfe 4.0 25/07/2018
	Local aObsCont      := PARAMIXB[17] //adicionado Joni Santos para nfe 4.0 25/07/2018

	Local cSerie		:= aNota[01]
	Local cDoc			:= aNota[02]
	Local cTipoDoc		:= IIf(aNota[04] == "1", "S", "E")			// E = Entrada / S = Saída
	//Local cTipoNF		:= aNota[05]								// NDBICP

	//Joni Santos
	Local cEndEnt 	:= ""
	Local cBairEnt 	:= ""
	Local cMunEnt 	:= ""
	Local cCepEnt	:= ""
	Local cEstEnt	:= ""
	Local cEndPed 	:= ""//SC5->C5_ZZEND //Joni 16/05/2017
	Local cZZTFRET	:= ""

	Posicione("SC5",1,xFilial("SC5")+ParamIxb[6][1][1],"!Eof()")  //Joni 16/05/2017
	cEndPed 	:= SC5->C5_ZZEND
	
	// prenche tipo do frete de redespacho
	IF Alltrim(SC5->C5_ZZTFRET) == 'F'
		cZZTFRET = 'Frete Redespacho: FOB'
	ElseIF Alltrim(SC5->C5_ZZTFRET) == 'C'
		cZZTFRET = 'Frete Redespacho: CIF'
	ElseIF Alltrim(SC5->C5_ZZTFRET) == 'T'
		cZZTFRET = 'Frete Redespacho: Por conta de terceiros'
	EndIf


	If cTipoDoc == "S"
		//Customização Joni Santos
		cEndEnt 	:= IIF(!Empty(allTrim(SA1->A1_ENDENT)),allTrim(SA1->A1_ENDENT),"")
		cBairEnt 	:= IIF(!Empty(allTrim(SA1->A1_BAIRROE)),allTrim(SA1->A1_BAIRROE),allTrim(SA1->A1_BAIRRO))
		cMunEnt 	:= IIF(!Empty(allTrim(SA1->A1_MUNE)),allTrim(SA1->A1_MUNE),allTrim(SA1->A1_MUN))
		cCepEnt		:= IIF(!Empty(allTrim(transform(SA1->A1_CEPE,"@R 99999-999"))),allTrim(transform(SA1->A1_CEPE,"@R 99999-999")),allTrim(transform(SA1->A1_CEP,"@R 99999-999")))
		cEstEnt		:= IIF(!Empty(alltrim(SA1->A1_ESTE)),alltrim(SA1->A1_ESTE),alltrim(SA1->A1_EST))

		cMensFis := "PEDIDO: " + AllTrim(SD2->D2_PEDIDO) + if(!empty(cMensFis), " - " + cMensFis,"")

		/*
		Incluido o campo C5_MENNOTA via PE01NFESEFAZ pois no parametro MV_CMPUSR esta informado o campo C5_ZZIFCPL
		*/
		if !empty(SC5->C5_MENNOTA) .and. !(alltrim(SC5->C5_MENNOTA) $ cMensCli )
			cMensCli += " " + alltrim(SC5->C5_MENNOTA)
		endif

		If Empty(cEndPed) //acrescentado por Joni Santos 16/05/2017. As vezes o cliente quer entrega em endereço alternativo ao endereço de entrega da SA1.
			IF !Empty(cEndEnt)
				cMensCli += " Endereço de Entrega: " + cEndEnt
				cMensCli += "-" + cBairEnt + "- CEP:" + cCepEnt + " - " + cMunEnt+"-" + cEstEnt
			Endif
		Else
			cMensCli +=	" Endereço de Entrega: " + cEndPed
		Endif


		/*
		valida se a nota fiscal nao está em uso por outro usuário
		Pois no PE M460FIM é exibido uma tela para o usuário preencher algumas informações e validar se o peso está correto
		e há casos que o usuário não clica no confirmar e outro usuário realiza a transmissão da NF antes do preenchimento do PESO LIQUIDO e BRUTO
		*/
		recLock("SF2",.f.)
		SF2->(msUnlock())
		SF2->(dbSkip())

		SF2->(DbSetOrder(1))
		If SF2->(DbSeek(xFilial("SF2") + cDoc + cSerie))
			if posicione("SA4",1,xFilial("SA4")+SF2->F2_TRANSP,"!eof()")
				if !empty(SA4->A4_COMPLEM)
					cMensCli += "Complemento Transp: " + SA4->A4_COMPLEM
				endif
			endif
			// Inicio Mensagem de Redespacho
			If !Empty(SF2->F2_REDESP)
				Posicione('SA4',1,xfilial('SA4')+SF2->F2_REDESP,'A4_COD')
				cMensCli += " "+cZZTFRET+" Transportadora responsável pelo trecho subsequente/redespacho: "+Alltrim(SA4->A4_NOME)+" CNPJ: "+Alltrim(SA4->A4_CGC)+" IE: "+Alltrim(SA4->A4_INSEST)+" END.: "+Alltrim(SA4->A4_END)+" CIDADE: "+Alltrim(SA4->A4_MUN)+" COMPL.: "+Alltrim(SA4->A4_COMPLEM)
			endif
			// Fim Mensagem Redespacho
			If Len(aVeiculo) > 0
				aVeiculo[01] := SF2->F2_ZZPLACA
				aVeiculo[02] := SF2->F2_ZZUFPLA
			Else
				If !Empty(SF2->F2_ZZPLACA) .AND. !Empty(SF2->F2_ZZUFPLA)
					Aadd(aVeiculo,SF2->F2_ZZPLACA)
					Aadd(aVeiculo,SF2->F2_ZZUFPLA)
					Aadd(aVeiculo,"")
				EndIf
			EndIf

			validPesoLiquidoBruto(@aEspVol)
		EndIf
	EndIf

	PARAMIXB[01]  := aProd
	PARAMIXB[02]  := cMensCli
	PARAMIXB[03]  := cMensFis
	PARAMIXB[04]  := aDest
	PARAMIXB[05]  := aNota
	PARAMIXB[06]  := aInfoItem
	PARAMIXB[07]  := aDupl
	PARAMIXB[08]  := aTransp
	PARAMIXB[09]  := aEntrega
	PARAMIXB[10]  := aRetirada
	PARAMIXB[11]  := aVeiculo
	PARAMIXB[12]  := aReboque
	PARAMIXB[13]  := aNfrural
	PARAMIXB[14]  := aEspVol
	PARAMIXB[15]  := aNfVinc
	PARAMIXB[16]  := aDetPag
	PARAMIXB[17]  := aObsCont

	RestArea(aAreaSC6)
	RestArea(aAreaSD2)
	RestArea(aAreaSF2)
	RestArea(aAreaAtu)

Return(PARAMIXB)

/*/{Protheus.doc} validPesoLiquidoBruto
Valida se o peso liquido e bruto que estão no array aEspVol está diferente do valor gravado na SF2
Necessário pois o peso bruto e liquido é calculo no PE M460FIM exibindo uma tela para conferencia do usuário.
Há casos que o usuário não clica no confirmar e outro usuário realiza a transmissão da NF antes do preenchimento do PESO LIQUIDO e BRUTO

@type function
@version  1.0
@author Tiago Faria
@since 20/01/2021
@param aEspVol, array, array com os pesos da NF
/*/
static function validPesoLiquidoBruto(aEspVol)
	local nEspVol 		:= 1
	local nPesoLiquido 	:= 0
	local nPesoBruto	:= 0
	local nVolume		:= 0

	if len(aEspVol) > 0
		nVolume 		:= aEspVol[nEspVol,2]
		nPesoLiquido	:= aEspVol[nEspVol,3]
		nPesoBruto 		:= aEspVol[nEspVol,4]

		if (nPesoLiquido > 0 .or. nPesoBruto > 0 .or. nVolume > 0) .and.;
				(nPesoLiquido <> SF2->F2_PLIQUI .or. nPesoBruto <> SF2->F2_PBRUTO .or. nVolume <> SF2->F2_VOLUME1)

			aEspVol[nEspVol,2] := SF2->F2_VOLUME1
			aEspVol[nEspVol,3] := SF2->F2_PLIQUI
			aEspVol[nEspVol,4] := SF2->F2_PBRUTO
		endif
	else
		aadd(aEspVol,{ SF2->F2_ESPECI1, SF2->F2_VOLUME1 , SF2->F2_PLIQUI , SF2->F2_PBRUTO, ""/*cMarca*/, ""/*cNumeracao*/})
	endif
return
