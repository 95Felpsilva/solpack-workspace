#include "totvs.ch"
/*
Ponto de entrada da rotina mata270 (Inventário)
Utilizado para incluir no menu do browse um botão para 
importar registros de um arquivo CSV gerado pelo sistema da DNP e gravá-los na tabela SB7 via Rotina automatica.
Desenvolvido por Sergio Braz
Em 02/02/12
*/
User Function MTA270MNU
AADD(aRotina,{"Imp. Arq. Invent","U_ImpInvent",0,3})
Return

User Function ImpInvent
Local cArq
Local nRegs,i
Private aCampos:={}
Private aRegs:={}
cArq:=cGetFile( 'Arquivos Texto (*.CSV)|*.CSV|', '' )
If File(cArq)
	If MsgYesNo("Confirma Importação de registros CSV?")
		FT_FUSE(cArq)
		nRegs:=FT_FLASTREC()
		Processa({|| LeCSV(nRegs)},"Aguarde! Lendo arquivo texto.")
		FT_FUSE()
		Processa({|| Importa(aRegs)},"Aguarde! Importando dados para tabela SB7")
	EndIf
EndIf
Return

//Função que le as linhas e atribui a primeira linha ao array com os campos e as demais ao array de dados a serem importadsos
Static Function LeCSV(nRegs)
Local i
Local cLinha:=""
ProcRegua(nRegs)
For i:=1 to nRegs
	cLinha:=FT_FREADLN()
	If i==1
		aCampos:=LeLinha(cLinha)
	Else
		AADD(aRegs,LeLinha(cLinha))
	EndIf
	FT_FSKIP()
Next
Return

//Função utilizada pela Lecsv, quebra cada linha lida em um array com os valores dos campos
Static Function LeLinha(cLinha)
Local i:=0
Local n
Local aLinha:={}
Local xValor
While .T.
	n:=At(";",cLinha)
	If n==0
		n:=Len(cLinha)+1
	EndIf
	xValor:=Left(cLinha,n-1)
	xValor:=ConvType(xValor,++i)
	AADD(aLinha,xValor)
	cLinha:=SubStr(cLinha,n+1)
	If cLinha==""
		If Len(aLinha)<Len(aCampos)
			xValor:=ConvType(xValor,++i)
			AADD(aLinha,xValor)
		EndIf
		Exit
	EndIf
End
Return aLinha

//Função utilizada pela Lelinha, verifica cada tipo de dados pelo cabeçalho e faz a conversão para o tipo do SX3
Static Function ConvType(xValor,i)
If Len(aCampos)>0
	If Type(aCampos[i])=="N"
		xValor:=Val(xValor)
	ElseIf Type(aCampos[i])=="D"
		xValor:=Stod(xValor)
	ElseIf Type(aCampos[i])=="L"
		xValor:=If("S"$Upper(xValor).or."T"$Upper(xValor).or."Y"$Upper(xValor),.T.,.F.)
	Endif
	If ValType(xValor)=="U"
		xValor:=CriaVar(aCampos[i])
	EndIf
EndIf
Return xValor

//Função que grava cada linha na SB7
Static Function Importa(aRegs)
Local aArea:=GetArea()
Local aAreaSB7:=SB7->(GetArea())
Local aSB7:={}
Local i,j
Local nDoc		:= aScan(aCampos,{|x| X=="B7_DOC"})
Local nCod      := aScan(aCampos,{|x| X=="B7_COD"})
Local nLocal    := aScan(aCampos,{|x| X=="B7_LOCAL"})
Local nQuant    := aScan(aCampos,{|x| X=="B7_QUANT"})
Local nData     := aScan(aCampos,{|x| X=="B7_DATA"})
//Local nFilial	:= aScan(aCampos,{|x| "_FILIAL"$x}) 
Local cDoc
Local cCod
Local cLocal
Local lGrava	:= .T.
Private lMsErroAuto:=.F.
SB7->(DbSetOrder(3))
For i:=1 to Len(aRegs)
	aSB7:={}
	For j:=1 to Len(aCampos)
		AADD(aSB7,{aCampos[j],aRegs[i,j],NIL})
	Next
	//If aRegs[i,nFilial]==cFilAnt //não grava registros de outras filiais
		lGrava	:=.T.
		cDoc	:= PadR(aRegs[i,nDoc],TamSX3("B7_DOC")[1])
		cCod	:= PadR(aRegs[i,nCod],TamSX3("B7_COD")[1])
		cLocal	:= PadR(aRegs[i,nLocal],TamSX3("B7_LOCAL")[1])    
		If SB7->(DbSeek(xFilial()+cDoc+cCod+cLocal))  //B7_FILIAL+B7_DOC+B7_COD+B7_LOCAL
			While SB7->(B7_FILIAL+B7_DOC+B7_COD+B7_LOCAL==xFilial()+cDoc+cCod+cLocal.AND.!Eof())
				If SB7->(B7_QUANT==aRegs[i,nQuant].and.B7_DATA==aRegs[i,nData])// Verifica se o registro não existe, se existir é porque já foi importado
					lGrava:=.F.
				Endif
				SB7->(DbSkip())
			End
		Endif
		If lGrava
			lMsErroAuto:=.F.
			//Mata270(aSB7)//executa a rotina automatica de inventário
			MSExecAuto({|x,y| mata270(x,y)},aSB7,3) //Inclusao
			If lMsErroAuto
				MostraErro()
			Endif
		Endif
	//Endif
Next
SB7->(RestArea(aAreaSB7))
RestArea(aArea)
Return
