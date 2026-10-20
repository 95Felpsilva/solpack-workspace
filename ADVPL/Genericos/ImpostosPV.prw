#include 'totvs.ch'
#include 'TopConn.ch'

/*/{Protheus.doc} ImpostosPV
classe responsável por realizar o cálculo dos impostos para o pedido de vendas
@author Tiago Faria
@since 25/08/2015
@version 12.1.33
@type class
/*/
class ImpostosPV
	data cAliasCabec as string
	data cAliasItem as string
	data lRestore as logical
	data lMemory as logical
	method new() CONSTRUCTOR
	method run(cAliasCabec,cAliasCabec)
	method getTotalPedido()

	method addCabec()
	method addItem()
	method getImposto()
	method destroy()

	method getAliasCabec()
	method setAliasCabec()
	method getAliasItem()
	method setAliasItem()
	method getValueItem()
	method getValueCabec()
endclass
/*/{Protheus.doc} new
Metodo construtor da classe ImspotosPV
@type method
@author Tiago Faria
@since 25/08/2015
@version 12.1.33
@param cAliasCabec, character, alias do cabeçalho do pedido de vendas
@param cAliasItem, character, alias dos itens do pedido de vendas
/*/
method new(cAliasCabec,cAliasItem,lMemory) class ImpostosPV
	::setAliasCabec(cAliasCabec)
	::setAliasItem(cAliasItem)
	::lRestore := .f.
	::lMemory := lMemory
return self
/*/{Protheus.doc} getAliasCabec
getter do atributo cAliasCabec
@author Tiago Faria
@type method
@since 25/08/2015
@version 12.1.33
@return character, retorna o alias do cabeçalho do pedido de vendas
/*/
method getAliasCabec() class ImpostosPV
return ::cAliasCabec
/*/{Protheus.doc} setAliasCabec
setter do atributo cAliasCabec
@author Tiago Faria
@since 25/08/2015
@version 12.1.33
@type method
/*/
method setAliasCabec(cAliasCabec) class ImpostosPV
	default cAliasCabec := ""
	::cAliasCabec := cAliasCabec
return
/*/{Protheus.doc} getAliasItem
getter do atributo cAliasItem
@author Tiago Faria
@since 25/08/2015
@version 12.1.33
@return character, retorna o alias do item do pedido de vendas
@type method
/*/
method getAliasItem() class ImpostosPV
return ::cAliasItem
/*/{Protheus.doc} setAliasItem
setter do atributo cAliasItem
@author Tiago Faria
@since 25/08/2015
@version 12.1.33
@type method
/*/
method setAliasItem(cAliasItem) class ImpostosPV
	default cAliasItem := ""
	::cAliasItem := cAliasItem
return
/*/{Protheus.doc} addCabec
método responsável por executar a funcao mafisini.
para funcionamento do método é necessario que o alias contenha os seguintes campos:
C5_CLIENTE
C5_LOJAENT
C5_TIPO
C5_TIPOCLI
C5_NUM
C5_LOJACLI
C5_TPFRETE
C5_TRANSP
@author Tiago Faria
@since 25/08/2015
@version 12.1.33
@type method
/*/
method addCabec() class ImpostosPV
	local aTransp := {}

	Posicione("SA4",1,xFilial("SA4")+::getValueCabec("C5_TRANSP"),"!Eof()")

	aTransp := {SA4->A4_EST,SA4->A4_TPTRANS}

	MaFisIni(;
		::getValueCabec("C5_CLIENTE"),;
		::getValueCabec("C5_LOJAENT"),;
		IIf(::getValueCabec("C5_TIPO") $ 'DB',"F","C"),;
		::getValueCabec("C5_TIPO"),;
		::getValueCabec("C5_TIPOCLI"),;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		"MATA461",;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		aTransp,;
		nil,;
		::getValueCabec("C5_NUM"),;
		::getValueCabec("C5_CLIENTE"),;
		::getValueCabec("C5_LOJACLI"),;
		::getTotalPedido(),;
		::getValueCabec("C5_TPFRETE");
		)

	If ( ( cPaisLoc == "PER" .Or. cPaisLoc == "COL" ) .And. ::getValueCabec("C5_FRETE") == "F" ) .Or. ( cPaisLoc != "PER" .And. cPaisLoc != "COL" )
		//MaFisAlt("NF_PESO",nTotPeso)
		MaFisAlt("NF_FRETE",::getValueCabec("C5_FRETE"))
	EndIf
	MaFisAlt("NF_VLR_FRT",::getValueCabec("C5_VLR_FRT"))
	MaFisAlt("NF_SEGURO",::getValueCabec("C5_SEGURO"))
	MaFisAlt("NF_AUTONOMO",::getValueCabec("C5_FRETAUT"))
	MaFisAlt("NF_DESPESA",::getValueCabec("C5_DESPESA"))
	If cPaisLoc == "PTG"
		MaFisAlt("NF_DESNTRB",::getValueCabec("C5_DESNTRB"))
		MaFisAlt("NF_TARA",::getValueCabec("C5_TARA"))
	Endif
return
/*/{Protheus.doc} addItem
método responsável por executar a funcao mafisadd
C6_PRODUTO
C6_TES
C6_QTDVEN
C6_QTDENT
C6_PRUNIT
C6_VALDESC
C6_VALOR
C6_ITEM
C6_CF
C6_ABATISS
C6_LOTECTL
C6_NUMLOTE
C6_CLASFIS
@author Tiago Faria
@since 25/08/2015
@version 12.1.33
@type method
/*/
method addItem(nLine,nItem) class ImpostosPV
	default nLine := 1
	nItem++

	posicione("SC6",1,xFilial("SC6")+::getValueCabec("C5_NUM")+::getValueItem("C6_ITEM",nLine),"!Eof()")
	posicione("SB1",1,xFilial("SB1")+::getValueItem("C6_PRODUTO",nLine),"!Eof()")

	MaFisAdd(::getValueItem("C6_PRODUTO",nLine),;   	// 1-Codigo do Produto ( Obrigatorio )
	::getValueItem("C6_TES",nLine),;	   				// 2-Codigo do TES ( Opcional )
	::getValueItem("C6_QTDVEN",nLine)-::getValueItem("C6_QTDENT",nLine),;  	// 3-Quantidade ( Obrigatorio )
	::getValueItem("C6_PRUNIT",nLine),;		  	// 4-Preco Unitario ( Obrigatorio )
	::getValueItem("C6_VALDESC",nLine),; 	// 5-Valor do Desconto ( Opcional )
	"",;	   			// 6-Numero da NF Original ( Devolucao/Benef )
	"",;				// 7-Serie da NF Original ( Devolucao/Benef )
	0,;					// 8-RecNo da NF Original no arq SD1/SD2
	0,;					// 9-Valor do Frete do Item ( Opcional )
	0,;					// 10-Valor da Despesa do item ( Opcional )
	0,;					// 11-Valor do Seguro do item ( Opcional )
	0,;					// 12-Valor do Frete Autonomo ( Opcional )
	::getValueItem("C6_VALOR",nLine),;		// 13-Valor da Mercadoria ( Obrigatorio )
	0,;					// 14-Valor da Embalagem ( Opiconal )
	,;					// 15
	,;					// 16
	::getValueItem("C6_ITEM",nLine),; 		// 17
	0,;					// 18-Despesas nao tributadas - Portugal
	0,;					// 19-Tara - Portugal
	::getValueItem("C6_CF",nLine),; 		// 20-CFO
	NIL,;            // 21-Array para o calculo do IVA Ajustado (opcional)
	"",;				// 22-Codigo Retencao - Equador
	::getValueItem("C6_ABATISS",nLine),; 	//23-Valor Abatimento ISS
	::getValueItem("C6_LOTECTL",nLine),; 	// 24-Lote Produto
	::getValueItem("C6_NUMLOTE",nLine),;	// 25-Sub-Lote Produto
	,;
		,;
		::getValueItem("C6_CLASFIS",nLine),; 	// 28-Classificação fiscal
	,; //29
	,; //30
	,; //31
	,; //32
	::getValueItem("C6_OPER",nLine)) // 33 - Tipo de Operação.


	//nPeso := ::getValueItem("C6_QTDVEN",nLine)-::getValueItem("C6_QTDENT",nLine) * SB1->B1_PESO

	//MaFisLoad("IT_PESO",nQtdPeso,nItem)
	//MaFisLoad("IT_PRCUNI",nPrcLista,nItem)
	//MaFisLoad("IT_VALMERC",nValMerc,nItem)

return
/*/{Protheus.doc} getImposto
método responsável por executar a funcao mafisret
@author Tiago Faria
@since 25/08/2015
@version 12.1.33
@return variant, retorno de acordo com os parametros passados
@type method
/*/
method getImposto(nItem,cCampo) class ImpostosPV
	local xRet := nil

	xRet := MaFisRet(nItem,cCampo)
return xRet
/*/{Protheus.doc} destroy
método responsável por executar a funcao mafisend
@author Tiago Faria
@since 25/08/2015
@version 12.1.33
@type method
/*/
method destroy() class ImpostosPV
	MaFisEnd()

	if ::lRestore
		maFisRestore()
	endif
return
/*/{Protheus.doc} getTotalPedido
metodo responsável por retornar o valor total do pedido que está sendo analisado
@author Tiago Faria
@since 25/08/2015
@version 12.1.33
@return numeric, retorna valor total do pedido
@type method
/*/
method getTotalPedido() class ImpostosPV
	local nTotal := 0
	local cQuery := ""
	local cAlias := ""
	local aArea	 := getArea()
	local nPTotal := 0
	if ::lMemory
		nPTotal := gdFieldPos("C6_VALOR")
		aEval(aCols,{|x| nTotal += a410Arred( If(x[Len(x)],0,x[nPTotal]+(x[nPTotal]*M->C5_ACRSFIN/100)),"D2_TOTAL")})
		nTotal+= (M->C5_FRETE+M->C5_DESPESA+M->C5_SEGURO)
	else
		cQuery += "SELECT SUM(C6_VALOR+(C6_VALOR*SC5.C5_ACRSFIN/100)+C5_FRETE+C5_DESPESA+C5_SEGURO) AS VLR_TOTAL" + CRLF
		cQuery += "FROM " + retSqlName("SC6") + " C6" + CRLF
		cQuery += "INNER JOIN " + retSqlName("SC5") + " SC5 ON SC5.C5_FILIAL = C6.C6_FILIAL" + CRLF
		cQuery += "AND SC5.C5_NUM = C6.C6_NUM" + CRLF
		cQuery += "AND SC5.D_E_L_E_T_ <> '*'" + CRLF
		cQuery += "WHERE C6.C6_FILIAL = '" + xFilial("SC5") + "'" + CRLF
		cQuery += "  AND C6.C6_NUM = '" + ::getValueCabec("C5_NUM") + "'" + CRLF
		cQuery += "  AND C6.D_E_L_E_T_ <> '*'	" + CRLF

		tcQuery cQuery new Alias (cAlias:=getNextAlias())

		nTotal := (cAlias)->(VLR_TOTAL)
	endif
	restArea(aArea)
return nTotal
/*/{Protheus.doc} ImpostosPV::run
Percore os alias recebido por parametro e monta as rotinas mafis para calculo dos impostos
@type method
@version 12.1.33
@author Tiago Faria
@since 04/11/2021
@param cAliasCabec, character, Alias do cabeçalho
@param cAliasItem, character, Alias do item
/*/
method run(cAliasCabec,cAliasItem,lMemory) class ImpostosPV
	local nLine := 0
	local nItem := 0
	default cAliasCabec := ""
	default cAliasItem := ""

	if !empty(cAliasItem)
		::setAliasItem(cAliasItem)
	endif

	if !empty(cAliasCabec)
		::setAliasCabec(cAliasCabec)
	endif

	if !empty(lMemory)
		::lMemory := lMemory
	endif

	If MaFisFound()
		MaFisSave()
		::lRestore := .t.
		MaFisEnd()
	endif

	::addCabec()
	if ::lMemory
		for nLine := 1 to len(aCols)
			if gdDeleted(nLine)
				loop
			endif
			::addItem(nLine,@nItem)
		next nLine
	else
		while (::getAliasItem())->(!Eof()) .and. (::getAliasItem())->(C6_FILIAL+C6_NUM) == (::getAliasItem())->(C5_FILIAL+C5_NUM)
			::addItem(,@nItem)

			(::getAliasItem())->(dbskip())
		enddo
	endif
return

method getValueItem(cField,nLine) class ImpostosPV
	local xRet := nil
	if ::lMemory
		if gdFieldPos(cField) > 0
			xRet := gdFieldGet(cField,nLine)
		else
			xRet := SC6->(&(cField))
		endif
	else
		xRet := ::getValueCabec(cField)
	endif
return xRet

method getValueCabec(cField) class ImpostosPV
	local xRet := nil

	xRet := &(::getAliasCabec() + "->(" + cField + ")")
return xRet
