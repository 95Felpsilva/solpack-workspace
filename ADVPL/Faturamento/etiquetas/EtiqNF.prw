#include 'totvs.ch'
#include 'topconn.ch'

static VELOCIDADE_IMPRESSORA := 3

/*/{Protheus.doc} EtiqNF
Imprime etiqueta NF
@type function
@author Tiago Faria
@since 25/05/2021
/*/
user function EtiqNF(cRecnos,aQtd)
	private cLocalImp := getNewPar("ZZ_IMPNF","000010")
	default aQtd := {}
	if setImpressora()
		impEtiqueta(cRecnos,aQtd)
	else
		msgAlert("Erro ao configurar o local de impressão " + cLocalImp)
	endif
return

static function impEtiqueta(cRecnos,aQtd)
	local nQtdEtiq := 1
	local cZPL     := ""
	local cAlias   := u_QryEtiqNF(.f./*lRetQuery*/,cRecnos/*cRecnos*/,.t.)
	local aDesc	   := {}
	local nQtdDesc := 0
	local cDoc	   := ""
	local cMsg	   := ""
	if (cAlias)->(eof())
		msgAlert("Não há dados para imprimir as etiquetas!")
		return
	endif

	while (cAlias)->(!Eof())
		nQtdEtiq := (cAlias)->(QTD_ETIQUETA)
		nPos := aScan(aQtd,{|X|X[1] == (cAlias)->(D2RECNO)})

		if nPos > 0
			nQtdEtiq := aQtd[nPos,2]
		endif

		aDesc := charToImp(alltrim((cAlias)->(DESCRICAO)),35)
		cDoc  := cValToChar(val((cAlias)->(DOC)))
		nQtdDesc := len(aDesc)
		MSCBBEGIN(nQtdEtiq,VELOCIDADE_IMPRESSORA)
		MSCBWrite("~SD10")

		MSCBSAY(1/*nXmm*/,1/*nYmm*/,alltrim(SM0->M0_NOMECOM)/*cTexto*/,"N"/*cRotacao*/,"0"/*cFonte*/,"030"/*cTam*/,/*lReverso*/,/*lSerial*/,/*cIncr*/,/*lZerosL*/,.t./*lNoAlltrim*/)
		if nQtdDesc >= 1
			MSCBSAY(1/*nXmm*/,5/*nYmm*/,aDesc[1]/*cTexto*/,"N"/*cRotacao*/,"0"/*cFonte*/,"045"/*cTam*/,/*lReverso*/,/*lSerial*/,/*cIncr*/,/*lZerosL*/,.t./*lNoAlltrim*/)
		endif

		if nQtdDesc >= 2
			MSCBSAY(1/*nXmm*/,11/*nYmm*/,aDesc[2]/*cTexto*/,"N"/*cRotacao*/,"0"/*cFonte*/,"045"/*cTam*/,/*lReverso*/,/*lSerial*/,/*cIncr*/,/*lZerosL*/,.t./*lNoAlltrim*/)
		endif

		MSCBSAY(3/*nXmm*/,17.5/*nYmm*/,cDoc/*cTexto*/,"N"/*cRotacao*/,"0"/*cFonte*/,"130"/*cTam*/,/*lReverso*/,/*lSerial*/,/*cIncr*/,/*lZerosL*/,.t./*lNoAlltrim*/)
		
		if !empty((cAlias)->(EAN))
			MSCBSAYBAR(55/*nXmm*/,17.5/*nYmm*/,alltrim((cAlias)->(EAN))/*cConteudo*/,"N"/*cRotacao*/,"MB07"/*cTypePrt*/,12.5/*nAltura*/,.f./*lDigVer*/,.f./*lLinha*/,.f./*lLinBaixo*/,/*cSubSetIni*/,2/*nLargura*/,3/*nRelacao*/,.F./*lCompacta*/,.F./*lSerial*/,/*cIncr*/,/*lZerosL*/)
			MSCBSAY(55/*nXmm*/,30.625/*nYmm*/,alltrim((cAlias)->(EAN))/*cTexto*/,"N"/*cRotacao*/,"0"/*cFonte*/,"030"/*cTam*/,/*lReverso*/,/*lSerial*/,/*cIncr*/,/*lZerosL*/,.t./*lNoAlltrim*/)
		endif

		MSCBInfoEti("ETQ_NF","100X100")

		cZPL := MSCBEND()
		memoWrite("c:\temp\etq_solpack.txt",cZPL)

		MSCBCLOSEPRINTER()

		(cAlias)->(dbSkip())
	enddo
	
	if !empty(cMsg)
		msgAlert(cMsg)
	endif
	(cAlias)->(dbCloseArea())
return

static function setImpressora()
	local lRet := .t.
	If !CB5SetImp(cLocalImp)
		MsgStop("Problemas no local de impressão!")
		lRet := .f.
	EndIf
return lRet

/*
Converte string em array considerando o limite de caracteres recebido no parametro nQtdChar, a quebra é realizada sem cortar as palavras
Autor: Tiago Faria
Data: 06/08/2018
*/
static function charToImp(cString ,nQtdChar)
	local aRet 			:= {}
	local nLine 		:= 0
	local nCount 		:= MlCount( cString,nQtdChar )

	if nCount == 0
		aRet := {""}
	else
		for nLine := 1 to nCount
			aadd(aRet,alltrim(MemoLine(cString,nQtdChar,nLine)))
		next nLine
	endif
return aRet
