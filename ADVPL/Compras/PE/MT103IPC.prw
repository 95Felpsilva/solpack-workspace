#include "rwmake.ch"

//.==============================================================.
//|                           TOTVS                              |
//|--------------------------------------------------------------|
//| Programa : MT103IPC.PRW     | Autor: Microsiga               |
//|--------------------------------------------------------------|
//| Descricao: Ponto de Entrada da Nota Fiscal Entrada para      |
//| buscar descricao do pedido de compra e gravar na descricao   |
//| da nota fiscal.                                              |
//|--------------------------------------------------------------|
//| Uso especifico para Protheus 11                              |
//.==============================================================.

User Function MT103IPC()

Local aArea		:= GetArea()
Local aAreaSC7	:= SC7->(GetArea())
Local nPosCod   := 0
Local nPosPed   := 0
Local nPosItPed := 0   
Local xSnc      := 0
Local x			:= 0

//------------------------------------------------//
// Busca posicao de campos especificos no aCols   //
//------------------------------------------------//
for x:=1 to len(aCols)
	nPosDesc  := Ascan(aHeader,{|x| "D1_ZDESCPR" $ x[2]})
	nPosPed   := Ascan(aHeader,{|x| "D1_PEDIDO"  $ x[2]})
	nPosItPed := Ascan(aHeader,{|x| "D1_ITEMPC"  $ x[2]})
	aCols[x,nPosDesc] := posicione("SC7",1,xFilial("SC7")+aCols[x,nPosPed]+aCols[x,nPosItPed],"C7_DESCRI")
next

RestArea(aArea)
RestArea(aAreaSC7)

Return
