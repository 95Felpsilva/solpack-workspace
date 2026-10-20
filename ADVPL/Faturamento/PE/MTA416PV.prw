#include "Protheus.ch"
#include "Topconn.ch"
#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MTA416PV  º Autor ³Diego Jacometti 	  º Data ³ 16/05/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada na aprovação do orçamento, usado para pre-º±±
±±º          ³ encher a descrição conforme orçamento                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±                         
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MTA416PV()
	Local aArea		:= GetArea()
	Local nPosDesc	:= aScan(_aHeader, {|x| AllTrim(x[2]) == "C6_ZZDESCR"})
	Local nPosLista	:= aScan(_aHeader, {|x| AllTrim(x[2]) == "C6_PRUNIT"})
	Local nAux := PARAMIXB
	Local nLista := Posicione("DA1",1,xFilial("DA1")+"001"+SCK->CK_PRODUTO,"DA1_PRCVEN")

	M->C5_TIPOCLI := SA1->A1_TIPO

	M->C6_DESCRI    := SCK->CK_DESCRI
	_aCols[nAux][nPosDesc]   := SCK->CK_ZZDESCR
//cLista := Posicione("SA1",1,xFilial("SA1")+SCK->CK_CLIENTE+SCK->CK_LOJA,"A1_TABELA")  
	_aCols[nAux][nPosLista]   := nLista
/*
Local cNUM		:= SCK->CK_NUM   
Local nPosDesc	:= aScan(_aHeader, {|x| AllTrim(x[2]) == "C6_DESCRIC"}) 
Local nItem		:= 1

dbSelectArea("SCK")
dbGoTop()  
dbSeek(xFilial("SCK") + cNUM)

while alltrim(cNUM) == alltrim(SCK->CK_NUM)
	_aCols[nItem][nPosDesc] := SCK->CK_DESCRI
	nItem++
dbskip()   
EndDo       
*/

	RestArea(aArea)
return
