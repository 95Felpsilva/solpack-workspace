#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#include "rwmake.ch"

/***********************************************************************************
* Funcao	    :	MTA410
* Autor	    :	Roudineli Lourenço
* Data		    : 	25/06/2015
* Descricao	:	Faz a soma do aCols para preencher os campos
* Retorno	    : 	Nenhum
**********************************************************************************/
User Function MTA410()
	Local aArea		:= GetArea()
	Local aAreaSB1	:= SB1->(GetArea())
	Local nPProduto	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
	Local nQtdVen	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
	Local cProduto	:= ""
	Local nQtd		:= 0
	Local nPesoBrut	:= 0
	Local nVolume	:= 0
	Local lRet		:= .T.
	Local i			:= 0
	
	IF !INCLUI .AND. !ALTERA
		Return lRet
	endif
	
	dbSelectarea("SB1")
	dbSetOrder(1)
	
	nPesoLiq := 0
	nPesoBrut := 0
	for i := 1 to len(aCols)
		If (!aCols[i][Len(aCols[i])]) //deletado
			
			cProduto	:=	aCols[i][nPProduto]
			nQtd		:=	aCols[i][nQtdVen]
			
			if DbSeek(xFilial("SB1")+cProduto)
				nPesoLiq += SB1->B1_PESO*nQtd
				nPesoBrut += SB1->B1_PESBRU*nQtd
				
				If SB1->B1_RASTRO == "L"
					If AllTrim(SubStr(SB1->B1_COD,1,2)) == "31"
						nVolume += nQtd  // alterado de nQtde para nQtde por Evandro Mulla 14/10/15
					Else
						nVolume += 1
					EndIf
				Else
					nVolume += Ceiling(nQtd / SB1->B1_QE)
				EndIf
				
			endif
		endif
	next
	
	M->C5_PESOL := nPesoLiq
	M->C5_PBRUTO := nPesoBrut
	M->C5_VOLUME1 := nVolume
	if empty(M->C5_ESPECI1)
		M->C5_ESPECI1 := "VOLUMES"
	endif
	
	RestArea(aAreaSB1)
	RestArea(aArea)
	
return (lRet)
