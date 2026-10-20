#include 'protheus.ch'
#include 'topconn.ch' 
/*/{Protheus.doc} ImpEtq
Reimpressao de etiquetas
@author Sergio Braz
@since 28/03/18
@version 1.0
@return nil

@type function
/*/
user function ImpEtq(lReImp)
	Local aDados 		:= {}
	local nI			:= 0
	local lImpressao	:= .f.
	local lProcImp		:= .t.
	local aBKPParam		:= {}
	local lImpEtq		:= u_isImpEtq()
	private nQtdEtqReImp:= 0
	private lPA			:= ""
	private lImpCabec 	:= .f.
	private cImpressora := ""
	private nQtdEtq		:= 0
	private nDivisor	:= 0
	private lReImpressao:= .f.
	default lReImp := .t.
	default lApp:=.F.
	default CODIMPR:=""
	default QTNETI:=0
	default IMPCAB:=.F.
	if lApp
		cImpressora:=iif(type("CODIMPR")=="U","",CODIMPR)
		nQtdEtq:=iif(type("QTNETI")=="U",0,QTNETI)
		lImpCabec:=iif(type("IMPCAB")=="U",.F.,IMPCAB)
	endif
	
	bkpParam(aBKPParam)

	lReImpressao := lReImp

	lImpressao := !lReImpressao
	lPA := posicione("SB1",1,xFilial("SB1")+SH6->H6_PRODUTO,"B1_TIPO == 'PA'")
	nDivisor := SB1->B1_QE

	lProcImp := (lImpressao .and. lImpEtq) .or. lReImpressao

	if  lProcImp .and. iif(lApp ,.T.,ask())
		AADD(aDados,SH6->(alltrim(H6_OP)+H6_IDENT))
		AADD(aDados,SH6->H6_PRODUTO)
		AADD(aDados,SH6->H6_LOTECTL)
		AADD(aDados,Posicione("SB1",1,xFilial("SB1") + SH6->H6_PRODUTO,"B1_DESC"))
		AADD(aDados,DToC(SH6->H6_DTAPONT) + " - " + AllTrim(SH6->H6_HORAFIN))
		AADD(aDados,SH6->H6_OPERADO)
		AADD(aDados,SH6->H6_RECURSO)
		AADD(aDados,SH6->H6_OP)
		AADD(aDados,SH6->H6_QTDPROD)
		AADD(aDados,SH6->H6_ZQTPRO2)

		CB5SEtImp(cImpressora,IsTelnet())
		if !lApp
			If nDivisor == 0
				nQtdEtq := 1
			Else
				nQtdEtq := Ceiling(SH6->H6_QTDPROD / nDivisor)
			EndIf

			if !lPA
				nQtdEtq  := 1
			endif
		
			if lReImpressao
				nQtdEtq := nQtdEtqReImp
			endif
		endif 
		For nI := 1 to nQtdEtq
			if lReImpressao .AND. !lApp
				U_valImpEt(SH6->(alltrim(H6_OP)+H6_IDENT),1,lImpCabec,2,Ceiling(SH6->H6_QTDPROD / nDivisor),nI)
			else
				U_valImpEt(SH6->(alltrim(H6_OP)+H6_IDENT),1,lImpCabec,2,nQtdEtq,nI)
			endif
		Next

		//U_EtqOrPrd(lImpCabec,{aDados},nQtdEtq)
	endif

	RestPar(aBKPParam)
Return

static function ask()
	Local aPergs := {}
	Local lRet := .f.

	AADD(aPergs,{1,"Local de impressao",Space(TamSX3("CB5_CODIGO")[1]),"@!",'.T.','CB5','.T.',60,.T.})
	if lPA
		Aadd(aPergs,{2,"Imp. dados da empresa","1",{"SIM","NAO"},50,,.T.})// MV_PAR01
		if lReImpressao
			AADD(aPergs,{1,"Qtd Etiquetas",CriaVar("H6_QTDPROD",.F.),getSX3Cache("H6_QTDPROD","X3_PICTURE"),'.T.','','.T.',60,.T.})
		endif
	endif

	If ParamBox(aPergs,"Parametros",,,,,,,,"IMPETQ_" + GetComputerName(),.t.,.t.)//ParamBox(aPergs,"Parametros",{})

		lRet := .t.
		cImpressora := MV_PAR01

		if lPA
			lImpCabec	:= MV_PAR02 == "SIM"
			if lReImpressao
				nQtdEtqReImp := MV_PAR03
			else
				nQtdEtqReImp := 0
			endif
		else
			lImpCabec 	:= .f.
			nQtdEtq		:= 1
		endif
	endif
return lRet

/*
Valida se deve ou não imprimir a etiqueta.
Autor: Tiago Faria
Data: 14/05/2019
*/
static function isImpEtq(cOP,cProduto,cOperac)
	local cQuery 		:= ""
	local cAlias 		:= ""
	local aArea	 		:= Lj7GetArea({"SC2","SG2"})
	local lRet	 		:= .t.
	default cOP 		:= SH6->H6_OP
	default cProduto 	:= SH6->H6_PRODUTO
	default cOperac 	:= SH6->H6_OPERAC

	cQuery += "SELECT" + CRLF
	cQuery += "	MAX(G2_CODIGO) AS G2_CODIGO" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SC2") + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("SG2") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SG2") + CRLF
	cQuery += "	AND G2_PRODUTO = C2_PRODUTO" + CRLF
	cQuery += "	AND G2_CODIGO = C2_ROTEIRO" + CRLF
	cQuery += "	AND C2_EMISSAO BETWEEN G2_DTINI AND CASE WHEN G2_DTFIM = '        ' THEN 'ZZZZZZZZ' ELSE G2_DTFIM END" + CRLF
	cQuery += "	AND G2_ZZIMPET = 'S'" + CRLF
	//cQuery += "	AND G2_OPERAC = '" + SH6->H6_OPERAC + "'" + CRLF
	cQuery += "	AND " + retSqlDel("SG2") + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SC2") + CRLF
	cQuery += "	AND C2_NUM+C2_ITEM+C2_SEQUEN = '" + cOP + "'" + CRLF
	cQuery += "	AND " + retSqlDel("SC2") + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	if (cAlias)->(Eof()) .or. empty((cAlias)->(G2_CODIGO))
		lRet := u_getLastOperac(cProduto) == cOperac
	else
		lRet := (cAlias)->(G2_CODIGO) == cOperac
	endif 

	(cAlias)->(dbCloseArea())

	Lj7RestArea(aArea)
return lRet

/*/{Protheus.doc} trataParam
Trata os parametros

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			15/04/2016
@return 		nil
/*/
Static Function bkpParam(aParam)

	Local cSeq			:= "01"
	Local cParametro	:= "MV_PAR" + cSeq
	Local xValor		:= &(cParametro)
	Default aParam		:= {}

	While cSeq <= "60"

		xValor		:= &(cParametro)
		Aadd(aParam,{cParametro,xValor})

		cSeq		:= Soma1(cSeq)
		cParametro	:= "MV_PAR" + cSeq
	EndDo

Return
/*/{Protheus.doc} RestPar
Retorna os valores originais aos parâmetros

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			15/04/2016
@return 		nil
/*/
Static Function RestPar(aParam)

	Local nI		:= 0
	Default aParam	:= {}

	For nI := 1 to Len(aParam)
		&(aParam[nI,1])	:= aParam[nI,2]
	Next

Return
