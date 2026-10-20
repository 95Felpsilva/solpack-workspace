#Include "Protheus.ch"
#Include "TOPCONN.ch"

#DEFINE NLININI	090
#DEFINE NQUEBNOR	004
#DEFINE NQUEBGRA	006
#DEFINE VELOCIDADE_IMPRESSORA 4
/*/{Protheus.doc} EtqOrPrd
Impressão de etiqueta de Ordem de produção
@type function
@version 12.1.27
@author Julio Lisboa
@since 19/06/2015
/*/
User Function EtqOrPrd(lImpCabeb,aParam,nQtdEtiq)
	Local cRotina       := "REIMPETQ"
	Local nI            := 0
	Local nQuebra       := NQUEBNOR
	Local nLinha        := NLININI
	Local nColCompl     := 095
	Local cUnidMed      := ""
	Local cTipoMedida   := ""
	local cInf := ''
	local cDescCient    := ""
	private cAlias      := ""
	Private cCodBar     := ""
	Private cProduto    := ""
	Private cLote       := ""
	Private cDescProd   := ""
	Private cArtigo     := ""
	Private cDataFab    := DToC(STOD(""))
	Private cConferente := ""
	Private cRecurso    := ""
	Private cOrdProd    := ""
	Private nPeso       := 0
	Private nQuant      := 0
	Private cOperador   := ""
	Private lEtqAvulsa  := FwIsInCallStack("U_ReEtqAvulsa")
	Default lImpCabeb   := .T.
	Default aParam      := Array(1)
	Default nQtdEtiq    := 0

	For nI := 1 to Len(aParam)

		If nQtdEtiq == 0
			return
		EndIf

		iniVariaveis(nI,aParam)

		/*
		If !IsInCallStack("U_IMG01")
		MSCBPRINTER("ZPL",cPorta,,,.F.,,,,,,.t.)
		MSCBCHKSTATUS(.f.) //Seta ou visualiza o status do sistema com a impressora
		EndIf
		*/

		MSCBBEGIN(nQtdEtiq,VELOCIDADE_IMPRESSORA)
		MSCBWrite("^LL800")

		If FunName()==cRotina .or. Posicione("SB1",1,xFilial("SB1") + cProduto,"B1_TIPO == 'PA'")

			If lImpCabeb
				//Cabeçalho
				//Alteração solicitada pelo Ralph - 21/07/2015
				If cFilAnt == "0101"
				//	MSCBSAY(nLinha,005,"SOLPACK","R","0","050",,,,,.t.)
				//	MSCBSAY(nLinha,31.25,"AGRONET","R","0","025",,,,,.t.)
				ElseIf cFilAnt == "0201"
				//	MSCBSAY(nLinha,005,"AGRONET","R","0","050",,,,,.t.)
				EndIf
				// LOGO RECICLAGEM
//				//MSCBWrite("^FO500,700^GFA,2037,5572,28,:Z64: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:3166^FO715,40^GFA,1089,2880,12,:Z64:eJy11D9vEzEUAPB3NepFDPEXQEkkvkDHIJ0aBj4C3Sv1E3TLEHFXgVS2MDLRjlUnRgaknOgQhqq3MoCwGgQSQuIqlqt6OuM/z36+khQ64OmnF8fPfn5ngJtGLJvAVYcspPA+uaq8p9DzTkbTDN3syoX3jrzM0fVc1rhQXBWy2UZfHEi5gf41k/K180jKl+jzwItUyg/or9d8ekt/dOuntH6YV/vNkn1eHtD+LwtZO9ffZOXOqOpw4c7eDOU7VxPZA+7rtp8l3ieSaitk7l0DeMsM/uNgc0m5CjIvKG/sPYgpPuTkqkcuk7j4bB2JMS8OrFleeXefC36Gnt4TsY2vR2ebgHN4JPreWcUzdJyP42c4ny2SnS7Go/mLsselXfMsExPnvsobozf5XuniicrgPH71IEd3Lk6TTM3X4d6O2AQmTcf3oey7cnTVfnxp8vHc+f58eA5wfKS9O41yfXe2OCzDe4zKhDszMVZLc+M4r3obaJ4t3o6dYfF+gvO76h+qPnnf1q3kgdfJA70a2ceBrJsOHWnjfKbbjq/y95k39iQTE7d/dbvJamMdmAis48y+P2vgPgg9Jl4s+AyMGa4Z7qHlyueNPuXe9uwYl+XS+XheyhU6XhI3Z0eb8wZ28xc6bnfACuU7QAZytLX12Phnoo9o6yP/dHaDo2boDUcDsh10j53AXVh+13/pB4CkbddvPIhzXZ8vKcVxPzyhN60Vp14amVzWKd4vuDj2TBr0xsg/oip+VUJruCZ69NCvE9l7b/zP3NX5H4w9b23ud2RseiDr32ixKj4hm1xA7gSGwHePZ8FZ7Lute9vZ1NR67fgwOEu1wnW7JtfKZwd9m8DoLmBU+dpCWl2vM/ZqTm6ArK8r/JbDd2bVW7SkP6NWf0LbcfDWrXzfwvXLlOJLbO6ufGJ8mtD8wtj2Q6FqFQu0/t5FQsYStly3rerTOKv61EFcO0JXxpW3eWTUfPsV2O/LW8WFs3uwrEVg/Jj0XXOzKdsDPOgNLkPb+ugsfbM+kz90eGYXvafzznxeLqeB9wM/9Y7lnvXALC9cYdQWtuF2I5x/eMv/qvEbaf+8tg==:BE1C")
				//-->MSCBWrite("^FO740,40^GFA,1708,1708,7,,:::::01JF8,01IFE02,01IF83FF8,01IF0FEFE,01FFE3C0078,01FFCF0FE3E,01FF9C7FF8E,01FF98IFE7,01FF31JF38,01FE33JF98,01FC67JFCC,01FCEKFEC,01FCCKFE6,01F88KFE6,01F8DLF6,01F99LF6,01F99LF3,:::01F99LF7,01F89KFE6,01FCCKFE6,01FCCKFEE,01FC67JFCC,01FE67JF98,01FE73JF18,01FF39IFE38,01FF9C7FFC7,01FF8E3FF0A,01FFC78003C,01FFE1E00F,01IF0IFE,01IF83FF,01JF,01JFE,,::::::00F1FFC,01F3FFC,03F3FFE,01F3FFE,03F3FFE,::01F3F7E,03F3E7E,:03F3A7E,01F3E7E,03F3E7E,::01F3E7E,03F3E7E,03FFE7E,:01FFE7E,03FFE7E,::01FFE7C,00FFC78,,::002IA,01JFC,01JFE,:03JFE,::01JFE,03F007E,::01F007E,03F007E,::01F007E,03F007E,:03FAAFE,01JFE,03JFE,::01JFC,:00JF8,,::00JFE,01JFE,:03JFE,::01JFE,03JFE,03F,:01F,03F,::01F,03E,01,,1K5,3KFC,:3KFE,::::K07E,02I07E,038007E,03F007E,01F007E,03F007E,::01F007E,03F007E,03F91FE,03JFE,01JFE,03JFE,::01JFC,00JF8,,::00JF,01JFC,03JF8,03JFC,::::03E00FC,03E007C,:::::03C007C,02I07C,K07C,02IAFC,03JFC,:::::03JF8,,::00JF8,01JFC,:03JFE,::01JFE,03FAAFE,03F007E,:01F007E,03F007E,::01F007E,03F007E,::01FC1FE,03FC1FE,:03FC1FA,01FC1FE,01FC0FC,01F80FC,00380F,,::03LF8,01LF,03LF,03KFE,:01KFC,03KFC,01KF8,I03F,I03F8,I03FE,I03FF,I03FF8,I03FFC,I03FFE,I07IF8,03FFEFF8,01FFEFF8,03FFE3F8,03FFE1F8,03FFE0F8,01FFE078,03FFE038,03FF8018,,::L018,L028,,:::^FS")
				MSCBWrite("^FO710,40^GFA,3852,3852,12,,::::U038,S030383,S0703838,S038383,S038387,Q0181C38703,Q0381C38E07,Q01C1C38E0F,R0E0E00E1E,R0F0C0043C,R078J038,R038J07018,P0701K0203C,P07CN0F8,P03FM03F,Q0F8L07C,Q038L03,Q018,,gG03,O01F8N0FF,O03FEN0FF,P0FEN0F,Q02,,:g08,P01EN0FE,O01FEN0FF8,O01FEN01F,O01C,L03,L078J07FK03,L07EI01FFEJ038,L0FFI07IFJ03E,L0FFC00JF8I01F8,K01FFC01JFCJ07C,K01FF801JFE003018,K03FF003JFE0078,K03FF003KF003C,K03FE007KF061C,K03FE007KF8E0E,K03FE00LF8707,K07FC00IF3FF87038,K07FC01FFC0FF8702,K07FC01FFC0FF838,K07FC03FF80FFC38,K07FC03FF807FC38,K07FE07FF007FC18,K07FE0IF00FF8,K03KFE00FF8,:K03KFC00FF8,K03KFC01FF8,K01KF801FF8,K01KF803FF,L0KF003FF,L07JFI0FF,L03IFEI03E,L01IFCI01C,M07FF,M01FC,,O03FF,N01IFE,N07JF8,N0KFE,M03LF8,M07LFC,M0MFE,L01NF,L03NF8,L07NF8,L07NFC,L0JF83IFE,L0IFC007FFE,K01IFI01IF,K01FFEJ0IF,K03FFCJ07FF,K03FF8J07FF8,K03FF8J03FF8,K03FFK01FF8,K07FFK01FF8,K07FEK01FF8,K07FEL0FF8,:K07FEL0FFC,K07FEL0FF8,K07FEK01FF8,K07FFK01FF8,K03FFK01FF8,K03FFK03FF8,K03FF8J03FF8,K03FFCJ07FF8,K03FFCJ0IF,K01IFI01IF,K01IF8003FFE,L0IFE01IFE,L0OFC,L07NFC,L03NF8,L01NF,L01MFE,M0MFC,M03LF8,M01LF,N0KFC,N03JF,O07FFC,,::K01TF8,K03TFC,:::::::::,::::0UF,:::::::::L07IFC7IF8,L07FFC007FFC,L0IFI03FFC,L0FFEJ0FFE,K01FFCJ07FF,K01FF8J07FF,K03FF8J03FF,K03FFK01FF8,:K03FEK01FF8,K07FEL0FF8,::K07FEL0FFC,K07FEK01FF8,K07FFK01FF8,:K03FFK03FF8,K03FF8J03FF8,K03FFCJ07FF8,K03FFCJ0IF8,K01FFEI01IF,K01IF8003IF,L0IFE01IFE,L0OFE,L07NFC,L07NF8,L03NF,L01NF,M0MFE,M07LF8,M01LF,N0KFE,N03JF8,O0IFC,,:O01FF,N01IFE,N07JFC,M01LF,M03LF8,M0MFC,L01MFE,L03NF,L03NF8,L07NFC,L0OFC,L0JF01IFE,K01IFC007IF,K01IFI01IF,K03FFEJ0IF,K03FFCJ07FF8,K03FF8J07FF8,K03FFK03FF8,K07FFK01FF8,:K07FEK01FF8,K07FEL0FFC,K07FEL0FF8,::K03FEK01FF8,K03FFK01FF8,:K03FFK03FF8,K03FF8J03FF,K01FFCJ07FF,K01FFEJ0FFE,L0IFI01FFE,L07FF8007FFC,L07IF03IF8,L07NF8,K03PF,::::::::K01PF,,::O07FFC,N03JF,N07JFC,M01LF,M03LF8,M07LFC,M0MFE,L01NF,L03NF8,L07NF8,L07NFC,L0JF01IFE,K01IF8007FFE,K01IFI01IF,K01FFEJ0IF,K03FFCJ07FF8,K03FF8J03FF8,K03FFK03FF8,K03FFK01FF8,K07FFK01FF8,K07FEK01FF8,K07FEL0FF8,K07FEL0FFC,:K07FEL0FF8,K07FEK01FF8,K07FFK01FF8,K03FFK01FF8,K03FFK03FF8,K03FF8J07FF8,K03FFCJ07FF,K01FFEJ0IF,K01IFI01IF,L0IFC003FFE,L0IFE003FFE,L07FFC001FFC,L07FFC001FF8,L03FF8I0FF8,L01FF8I0FF,M0FFJ07E,M07FJ07C,M03EJ038,N0E,N04,,:K03TFC,:::::::::P07FC,:O01FFE,O03IF,O07IF8,N01JFC,N03JFE,N07KF8,M01LFC,M03LFE,M07MF,L01NF8,L03JF1IFC,L07IFC0IFE,K01JF807IF,K03JF003IF,K03IFC001IF,K03IF8I07FF,K03IFJ03FF,K03FFEJ01FF,K03FF8K0FF,K03FFL07F,K03FEL03F,K03F8L01F,K03FN0F,K03EN07,K03CN01,K03,,:::::::^FS")
				//MSCBWrite("^FO550,750^GFA,1721,5080,20,:Z64:eJytmMtq7DgQhuVGhuBVFsf7Q6+Cn0IBz94B633MWYV+CtMroaecukoluWcYyKiDO5Yrn/666OI49+N2y/ns+/y6rl3XlKGltm+M0La2L1NriSu1cMFBs31z5NaKuwLXnT8GqLicjgsu7r06bNVuLS1ccMblIZa2vbArnvjKKzE0ZmXgaFrvrfXY4FSgHVYFjpa3vbDLKm83n6s8FTjHq8BXdut6FdjanU30tnEDdGjcTY+0iF2JXliDF15NbnV4bHlb6+6UJnG4ZsMHreql1ZcbdwPxYmN3TqiPHC6RQ33w3bibamBiqy+2YZnSQwKzdvpCFz6x0/D9hTz0PdTwPXJaSJ/heYnfWu1gSNGXCm8bkDdwxWj47jlN6cZ2Gr6A+hzz1O5D9aWSjv39Be8DeXflSd2BOorfKnZ/cv42+kaatjH6WfzdxQ6Cc1vyI/EN64Orx1rhG7JLDkK8JNaXOb2bG7ZPw6P0ult6PmD0xfJcgADih24WzinYQZ3mytuRB9l1DW9CXiks0ReUVvWBOPAiPSxvRt741fDyE314PpSHNbcHrBaN38J5ADvQZ3hxjmOcpf72Us6PvHT6VvbWmfixXZq+LS/GcQfe14WXeh7XjI0f2CUswZYHv3T+YqRBQJNfhHiZH1YfrRoNDzzehs5fHPmucZH687vf2vgx76pv3Nt6UX22Xljfurb6Mk25Vh9W4edX7PTl9NS6MvHzXfxY44UXeeo1vDy9yEdTfzJuvvK2eIkfri8lH2Xv6ONnFFreJX6ZstvG7x/0aet3o4u/xc7Wn/Je2f2E9zN9Gr+17MD/om8rK3XlnXXlN/VnfmV9yeyIyjMHj8LjvsXygj3IyLNkTxTC09ON5enpxvLUzs4P7Zsqr5yqhso7te9W4xe0z9X4HaWv8koX3gmv9i1FX+3zqs+ccyflmXPuoDxjd1NelUe7Mdmdvd0sR6COV9x4I0eIV9UJbxK7D/TicMojm3ek4S3zUP+J1/vBt55OLD7gFQR4iR/G7YkqeXVDAJXeJ379wu2YeAnlP/FrcWzn0V0P2/mqAcQHYDAlhzIb3hzceySNA/N4wLfldHcKjPBYogRQ7cgV9zzYbobwDZgRuAyGd8OMwOV+GB6hAn2xvhNR0BL64ZQ3kh2nWXlgt+Dgd7FDHh6EUCS6zPEDJ8nVjBfhQdAAQ9ErPLbD6FUe5xWvVV+xO07Dmyl0s/s0vIXoC9aB5VG1+BK/g54D+XhzDc/p1fDoZ/lv+lxq9ZG/ny/8rfqC8HbStxsemn7LuCPmg/zdiz6bt99tPii/3tX8ah3QuIl5Wi804TZjB9DfWH9J6mU19ReknmmKAOxgu5HquYSPePRggRMl2oqdk/nhdX4EsQOnyzxKAhjiIKvMKOd7nm8nzfWJz/cYjz3IK62nd2Cev38wF98HTxcKmIhznB6xm6jj7aD0cMCkYvSOJi6uQGzNq81s38qdvh+dpo8X11/d+keQbp1kD816OvIr+tSuu4kj1qzPgR816zjZDe16v8lQh5HHYu3+Ud9XiyPlb9r9qBlLNByuE1h+nerAi2od7X5Z38/PMqyi7f4b6tOj+wtX/q8xV7LumDezJSrGbnWTPLc78Shb5pfx/MYHDnMAcBjBVU4vofTVs8tR+uqZqHSZs07tK2esijOv/LXPXXEVeJg+f8HVl2Db15yKWmDb5y44lmj+2fQ/t78BxLLrKQ==:7560")
//				MSCBWrite("^FO500,700^GFA,2037,5572,28,:Z64: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:3166")
				nQuebra 	:= NQUEBNOR
				nLinha 	+= 2

				/*
				MSCBSAY(nLinha,045,"Embalagens Manuais e Automaticas, Redes Tecidas e Extrusadas,","R","0","034",,,,,.t.)
				nLinha 	-= nQuebra
				MSCBSAY(nLinha,045,"Telas Agricolas e Decorativas","R","0","034",,,,,.t.)
				*/
				//Informações da Empresa
				nLinha		-= 7
				MSCBSAY(nLinha,005,SM0->M0_FILIAL,"R","0","030",,,,,.t.)
				nLinha		-= nQuebra
				MSCBSAY(nLinha,005,AllTrim(SM0->M0_ENDCOB) + ", " + AllTrim(SM0->M0_COMPCOB),"R","0","030",,,,,.t.)
				nLinha		-= nQuebra
				MSCBSAY(nLinha,005,"CEP. : " + Transform(SM0->M0_CEPCOB,"@R 99999-999") + " - " + AllTrim(SM0->M0_CIDENT) + " - " + AllTrim(SM0->M0_ESTENT),"R","0","030",,,,,.t.)
				nLinha		-= nQuebra
				MSCBSAY(nLinha,005,"Fone.: " + SM0->M0_TEL,"R","0","030",,,,,.t.)
				nLinha		-= nQuebra
				MSCBSAY(nLinha,005,"CNPJ.: " + Transform(SM0->M0_CGC,PesqPict("SA1","A1_CGC")) + " - www.solpack.com.br","R","0","030",,,,,.t.)
				nLinha		-= nQuebra
				MSCBSAY(nLinha,005,"I.E. : " + Transform(SM0->M0_INSC,PesqPict("SA2","A2_INSCR")),"R","0","030",,,,,.t.)
				nQuebra 	:= NQUEBNOR
				nLinha		-= nQuebra + 03
			Else
				nLinha 	:= NLININI
				nQuebra 	:= NQUEBGRA
			EndIf

			cUnidMed 		:= Lower(AllTrim(Posicione("SB1",1,xFilial("SB1") + cProduto,"B1_UM")))
			cTipoMedida	:= IIF(cUnidMed == "KG","Peso.:  ","Medida.:  ")
			If !Empty(cProduto)
				cArtigo := Posicione("SB5",1,xFilial("SB5") + cProduto,"B5_DES")
			EndIf

			nLinha -= (nQuebra + 2) * 2
			//MSCBSAY(nLinha,005,"Desc.: " + cDescProd,"R","0","100",,,,,.t.)
			//cDescCient 		:= AllTrim(Posicione("SB1",1,xFilial("SB1") + cProduto,"B1_ZZCEME"))
			cDescProd := alltrim(cDescProd)
			if len(cDescProd) <= 50
				MSCBSAY(nLinha,005,cDescProd,"R","0","110,50",,,,,.t.)
			elseif len(cDescProd) <= 69
				MSCBSAY(nLinha,005,cDescProd,"R","0","110,40",,,,,.t.)
			elseif len(cDescProd) <= 79
				MSCBSAY(nLinha,005,cDescProd,"R","0","110,35",,,,,.t.)
			else 
			    cDescCient := substr(cDescProd,1,93)
				MSCBSAY(nLinha,005,cDescCient,"R","0","110,30",,,,,.t.)
			endif
//			MSCBSAY(nLinha,005,cDescCient,"R","0","110,35",,,,,.t.)

			//Se estiver habilitado, imprime quantidade
			If GetNewPar("ZZ_IMPQTDE",.F.)
				nLinha -= (nQuebra * 2) + 4
				MSCBSAY(nLinha,005,"Quant:  " + AllTrim(Transform(nQuant,PesqPict("SH6","H6_QTDPROD"))) + Space(01) + cUnidMed,"R","0","110,50",,,,,.t.)
			EndIf


			//Informações do Produto
			nLinha -= nQuebra
			MSCBSAY(nLinha,005,"Produto :  " + cProduto,"R","0","035",,,,,.t.)

			//Numero da OP
			nLinha -= nQuebra
			MSCBSAY(nLinha,005,"Ordem de Prod.:  " + cOrdProd,"R","0","035",,,,,.t.)

			If !Empty(cLote)
				MSCBSAY(nLinha,nColCompl,"OF/LOTE :  " + cLote,"R","0","035",,,,,.t.)
			EndIf

			if !empty(cArtigo)
				nLinha -= nQuebra
				MSCBSAY(nLinha,005,"Artigo .:  " + cArtigo,"R","0","035",,,,,.t.)
			endif
			nLinha -= nQuebra
			MSCBSAY(nLinha,005,"Dt Fab .:  " + cDataFab,"R","0","035",,,,,.t.)
			MSCBSAY(nLinha,nColCompl,cRecurso,"R","0","035",,,,,.t.)

			nLinha -= nQuebra
			//MSCBSAY(nLinha,005,"Oper ...:  " + cConferente,"R","0","035",,,,,.t.)
			MSCBSAY(nLinha,005,"Conferente.:  " + cConferente,"R","0","035",,,,,.t.)
			If !Empty(cOperador)
				nLinha -= nQuebra
				MSCBSAY(nLinha,005,"Operador.:  " + RetField("SZZ",1,xFilial("SZZ")+cOperador,"ZZ_COD + '-' + ZZ_NOME"),"R","0","035",,,,,.t.)
			Endif

			If !Empty(cCodBar)
				if !empty(cArtigo)
					MSCBSAY(nLinha+nQuebra,112.5,cCodBar,"R","0","035",,,,,.t.)
				else
					MSCBSAY(nLinha,112.5,cCodBar,"R","0","035",,,,,.t.)
				endif

				//Lateral
				MSCBSAYBAR(040,168.75,cCodBar,"N","MB07",12,.f.,.f.,.f.,,2,2,.F.)

				//Normal
				MSCBSAYBAR(002,nColCompl,cCodBar,"R","MB07",12,.f.,.f.,.f.,,2,2,.F.)


				/*
				//Lateral
				MSCBSAYBAR(060,170,cCodBar,"N","MB07",12,.f.,.t.,.t.,,3,2,.t.)

				//Normal
				MSCBSAYBAR(004,nColCompl,cCodBar,"R","MB07",15,.f.,.t.,.t.,,3,2,.t.)
				*/
			EndIf
			cInf := "^FO500,800^GFA,3477,10528,28,:Z64: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:ACC9"
			MSCBWrite(cInf)
				
		Else
			dbselectarea("SH6")
			cCodBar		    := aParam[nI,01]
			cProduto		:= aParam[nI,02]
			cLote			:= aParam[nI,03]
			cDescProd		:= aParam[nI,04]
			cDataFab		:= aParam[nI,05]
			cConferente		:= aParam[nI,06]
			cRecurso		:= aParam[nI,07]
			cOrdProd		:= aParam[nI,08]
			nPeso			:= IIf(SH6->H6_QTDPROD>0,SH6->H6_QTDPROD,SH6->H6_ZQTPRO2)//aParam[nI,09]
			nQuant			:= aParam[nI,10]
			if len(aParam[nI]) >= 11
				cOperador := aParam[nI,11]
			else
				cOperador := SH6->H6_ZZOPER
			endif
			dEmissao        := SH6->H6_DTAPONT
			cHrIni         := SH6->H6_HORAINI
			cHrFin         := SH6->H6_HORAFIN
			dDtIni          := SH6->H6_DATAINI
			dDtFin          := SH6->H6_DATAFIN
			MSCBBEGIN(nQtdEtiq,VELOCIDADE_IMPRESSORA)
			EtqZPL()

		//cInf = "^BY2,3,100^FT60,800^BCR,,Y,N^FH\^FD>:" + cProduto + "^FS^PQ1,0,1,Y"
		//MSCBWrite(cInf)
		Endif
		// COD BARRAS PRODUTO
		MSCBInfoEti("ETQ_OP","100X100")
		cZPL := MSCBEND()
		//tstZPL(cZPL)
		memoWrite("c:\temp\etq_solpack.txt",cZPL)

		MSCBCLOSEPRINTER()

		nLinha := NLININI

	Next

Return

/*/{Protheus.doc} iniVariaveis
Inicia as variáveis para impressão da etiqueta

@author Julio Lisboa - FSW TOTVS IP Campinas
@since 22/06/2015
@version 1.0
@return nil
/*/
Static Function iniVariaveis(nI,aParam)

	cCodBar			:= aParam[nI,01]
	cProduto		:= aParam[nI,02]
	cLote			:= aParam[nI,03]
	cDescProd		:= aParam[nI,04]
	cDataFab		:= aParam[nI,05]
	cConferente		:= aParam[nI,06]
	cRecurso		:= aParam[nI,07]
	cOrdProd		:= aParam[nI,08]
	nPeso			:= aParam[nI,09]
	nQuant			:= aParam[nI,10]
	if len(aParam[nI]) >= 11
		cOperador		:= aParam[nI,11]
	else
		cOperador		:= SH6->H6_ZZOPER
	endif

	cAlias := getNivel1Estrut()
Return

static function getNivel1Estrut()
	local cAlias := ''
	local cQuery := ''

	cQuery += "SELECT" + CRLF
	cQuery += "	G1_COMP," + CRLF
	cQuery += "	B1_DESC," + CRLF
	cQuery += "	G1_QUANT * 100 AS QTD" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + RetSqlTab('SG1') + CRLF

	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + RetSqlTab('SB1') + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + RetSqlFil('SB1') + CRLF
	cQuery += "	AND B1_COD = G1_COMP" + CRLF
	cQuery += "	AND " + RetSqlDel('SB1') + CRLF

	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + RetSqlFil('SG1') + CRLF
	cQuery += "	AND G1_QUANT > 0" + CRLF
	cQuery += "	AND G1_COD = '" + cProduto + "'" + CRLF
	cQuery += "	AND " + RetSqlDel('SG1') + CRLF
	cQuery += "ORDER BY G1_QUANT" + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())
return cAlias

// Alteração 28/02/2024 --> Solon

Static Function EtqZPL()
	local nLenBox  	:= 0.5
	local tm		:= 1
	local nTxt     	:= 0
	local nLinAtu  	:= 0
	local nLinha 	:= 0
	Private nDensi 	:= 10

	posicione("SC2",1,xFilial("SC2")+SH6->H6_OP,"!Eof()")
	
	// Say(0.5,9.5,cDescProd,40,40,"R")

	//Say(0.5,9.5,AllTrim(SubStr(cDescProd+space(40), 1,40)),40,40,"R")
    //Say(0.5,9.0,AllTrim(SubStr(cDescProd+space(40),40,40)),40,40,"R")

	Say(0.5,9.5,AllTrim(SubStr(cDescProd+space(41), 1,41)),40,40,"R")
    Say(0.5,9.0,AllTrim(SubStr(cDescProd+space(41),41,41)),40,40,"R")

	nLinha := 8.5
	Say(0.5,nLinha,"PRODUTO:",35,35,"R")
	Say(2.6,nLinha,cProduto,35,35,"R")

	nLinha := 7.9
	Say(0.5,nLinha,"EXTRUSORA: "+cRecurso,35,35,"R")

	nLinha := 6.7
	Say(0.5,nLinha,"ORDEM DE PRODUÇÃO:",35,30,"R")
	Say(4.7,nLinha,cOrdProd,35,30,"R")

	nLinha := 6.1
	Say(0.5,nLinha,"DATA EMISSÃO:",35,30,"R")
	Say(3.7,nLinha, dtoc(dEmissao) ,35,30,"R")

	// COMPOSIÇÃO DA MISTURA

	nLinha := 5.5
	Say(0.5,nLinha,"COMPOSIÇÃO DA MISTURA:",35,30,"R")
	
	nReg      := 0
	nLinPar   := 0
	nLinImpar := 0
	nCol      := 0.5
	while (cAlias)->(!Eof())
		nReg++
		if nReg > 3
			nLinPar++
			nLinAtu := nLinPar
			nLinha  := 9.7 
			nColuna := 5.2 //6.5
		else
			nLinImpar++
			nLinAtu := nLinImpar
			nLinha  := 0.8
			nColuna := 5.2 //6.5
		endif

		nColuna := nColuna - (nCol * nLinAtu)

		nEspacoTxt := 0
		Box(nLinha + nEspacoTxt,nColuna,nLinha + nEspacoTxt + 1.1 ,nColuna + nLenBox)
		Say(nLinha + nEspacoTxt + 0.1,nColuna,cValToChar((cAlias)->(QTD)) + "%",35,30,"R")

		aTxt := charToImp(alltrim((cAlias)->(B1_DESC)),40)
		//aTxt := charToImp("POLIMERO RECUPERADO AMARELO 990MI (10) INFINITY 123",40)

		nEspacoTxt := 1.1
		for nTxt := 1 to len(aTxt)
			Say(nLinha + nEspacoTxt + 0.1,nColuna,alltrim(aTxt[nTxt]),35,30,"R")
			//só imprime a 1ª linha
			exit
		next nTxt

		(cAlias)->(dbSkip())

		if nReg == 6
			exit
		endif
	enddo

	Say(0.5,2.9,"DATA INI:",35,35,"R")
	Say(2.5,2.9,dtoc(dDtIni),35,30,"R")
	
	Say(5,2.9,"HORA INI:",35,35,"R")
	Say(7,2.9,cHrIni,35,35,"R")
	
	Say(0.5,2.3,"DATA FIN:",35,35,"R")
	Say(2.5,2.3,dtoc(dDtFin),35,30,"R")

   	Say(5,2.3,"HORA FIN:",35,35,"R")
	Say(7,2.3,cHrFin,35,35,"R")

	Say(0.5,1.1,"PESO LIQ. KG:",35,35,"R")
	SAy(3.5,1.1,cValToChar(nPeso),35,35,"R")
	
	Say(0.5,1.7,"QTD. CORTES / EMENDAS:",35,30,"R")
	if !lEtqAvulsa
		Say(5,1.7,cValToChar(SH6->H6_ZQCORTE),35,30,"R")
	endif

	//Box(4.5,7.3,6.5,8)
	Say(0.5,7.3,"DESTINO:",35,35,"R")
	if !lEtqAvulsa
		Say(2.6,7.3,SC2->C2_ZZTEAR,35,35,"R")
	endif

	if !lEtqAvulsa
		Say(4.6,7.3,SH6->H6_ZTRAMA,35,35,"R")
	endif
	
	if !lEtqAvulsa .and. Posicione("SZZ",1,xFilial("SZZ")+SH6->H6_ZZOPER,"!Eof()")
		Say(0.5,0.5,"OPERADOR: " + SZZ->ZZ_NOME,35,35,"R")
	endif
Return

Static Function Say(l,c,t,H,W,R)  //Linha,Coluna,Texto,Altura,Largura,Rotacao
	Default W := H
	Default R := "N"
	L*=nDensi
	C*=nDensi
	MSCBSAY(c,l,t,R,"0",StrZero(H,3)+","+StrZero(W,3))
Return

Static Function Box(l1,c1,l2,c2,w) //Linha1,Coluna1,Linha2,Coluna2,Grossura                                                                           
	Default W := 1
	l1*=nDensi
	l2*=nDensi
	c1*=nDensi
	c2*=nDensi
	//c2-=c1
	//l2-=l1
	MsCbBox(c1,l1,c2,l2,2)
Return

static function tstZPL(cZPL)
	local cURL := "http://api.labelary.com/v1/printers/8dpmm/labels/5x8/0/" + strtran(cZPL,CRLF,"")
	local cFile := "c:\temp\etq_solpack_" + fwTimeStamps() + ".png"
	cRet := httpGet(cURL)

	memoWrite(cFile,cRet)Á

	shellexecute("Open",cFile,"","",1)
return

static function charToImp(cString ,nQtdChar)
	local aRet 			:= {}
	local nLine 		:= 0
	local nCount 		:= MlCount( cString,nQtdChar )

	if nCount == 0
		aRet := {""}
	else
		for nLine := 1 to nCount
			aAdd(aRet,MemoLine(cString,nQtdChar,nLine))
		next nLine
	endif
return aRet
