#Include "rwmake.Ch"
#INCLUDE "PROTHEUS.CH"
#include 'topconn.ch'
#include "TOPCONN.CH"
#INCLUDE "JPEG.CH"

user function tstEncerraOP()
	rpcSetEnv("01","0101")

	u_encerraOP()

	rpcClearEnv()
return

/**
* Encerramento de OP
* @author Gesse Santos
* @since 14/09/2015
* Adaptado por Joni Santos para Solpack em 22/04/2019
*
*/
User Function ENCERRAOP()
	local cFields := "C2_NUM*C2_ITEM*C2_SEQUEN*C2_PRODUTO*C2_CLIENTE*C2_QUANT*C2_UM*C2_EMISSAO*C2_DATRF*C2_QUJE"
	local cField  := ""
	local aFields := {}
	local nField := 0
	private _carq := ""
	private cAliasTRB 	:= ""
	private oTempTable	:= nil

	if ask()
		processa({|| _querys()})
		ccadastro:="Encerramento de Ordens de Producao"
		arotina:={}
		aadd(arotina,{"Encerra*" ,'u_WP012DEL',0,3})

		acampos:={}
		aadd(acampos,{ "OK "               ,"",""})
		aadd(acampos,{ "PRO"               ,"","Producao (R$)","@E 999,999,999.99"})
		aadd(acampos,{ "REQ"               ,"","Requisicoes (R$)","@E 999,999,999.99"})
		aadd(acampos,{ "DEV"               ,"","Devolucoes (R$)","@E 999,999,999.99"})
		aadd(acampos,{ "SLD"               ,"","Saldo (Quantidade)","@E 999,999,999.99"})
		aadd(acampos,{ "OP"                ,"","Ordem Produ豫o"})
		aadd(acampos,{ "DSC"               ,"","Produto"})
	
		aFields := strToKarr(cFields,"*")
		for nField := 1 to len(aFields)
			cField := aFields[nField]
			aadd(aFields,{cField,"",getSX3Cache(cField,"X3_TITULO")})
		next nField

		cmarca    :=getmark()
		lgrade    :=.f.
		linverte  :=.f.
		markbrowse(cAliasTRB,"OK",,acampos,@linverte,@cmarca)
		oTempTable:delete()
	endif
Return()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Montagem da query para escolha do que vai estornar
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Static function _querys()
	Local dInicio 		:= Dtos(SuperGetMv("MV_ULMES",.F.,.F.)+1)
	local cQuery 		:= ""
	local cAlias 		:= ""

	procregua(2)
	incproc("Selecionando apontamentos...")

	cQuery += "SELECT" + CRLF
	cQuery += "	DISTINCT" + CRLF
	cQuery += "	'  ' AS OK," + CRLF
	cQuery += "	0 AS DIAS_S_MOV," + CRLF
	cQuery += "	TOTAL.PRO," + CRLF
	cQuery += "	TOTAL.REQ," + CRLF
	cQuery += "	TOTAL.DEV ," + CRLF
	cQuery += "	C2_QUANT - C2_QUJE AS SLD," + CRLF
	cQuery += "	C2_NUM," + CRLF
	cQuery += "	C2_ITEM," + CRLF
	cQuery += "	C2_SEQUEN," + CRLF
	cQuery += "	C2_NUM+C2_ITEM+C2_SEQUEN AS OP," + CRLF
	cQuery += "	C2_QUANT," + CRLF
	cQuery += "	C2_QUJE," + CRLF
	cQuery += "	C2_QTSEGUM," + CRLF
	cQuery += "	C2_EMISSAO," + CRLF
	cQuery += "	C2_DATRF," + CRLF
	cQuery += "	C2_PRODUTO," + CRLF
	cQuery += "	C2_UM," + CRLF
	cQuery += " B1_DESC DSC" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SC2") + CRLF

	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("SD3") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SD3") + CRLF
	cQuery += "	AND D3_OP = C2_NUM + C2_ITEM + C2_SEQUEN" + CRLF
	cQuery += "	AND SUBSTRING(D3_CF, 1, 2) = 'PR'" + CRLF
	cQuery += "	AND D3_EMISSAO BETWEEN '" + dInicio + "' AND '" + dtos(LastDay(mv_par01)) + "'" + CRLF
	cQuery += "	AND D3_ESTORNO = ' '" + CRLF
	cQuery += "	AND " + retSqlDel("SD3") + CRLF

	cQuery += "CROSS APPLY" + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT " + CRLF
	cQuery += "	TOP 1" + CRLF
	cQuery += "	D3_FILIAL AS FILIAL," + CRLF
	cQuery += "	D3_OP AS OP," + CRLF
	cQuery += "	SUM(CASE WHEN SUBSTRING(D3_CF, 1, 2) = 'PR' THEN D3_CUSTO1 ELSE 0 END) AS PRO," + CRLF
	cQuery += "	SUM(CASE WHEN SUBSTRING(D3_CF, 1, 2) = 'RE' THEN D3_CUSTO1 ELSE 0 END) AS DEV," + CRLF
	cQuery += "	SUM(CASE WHEN SUBSTRING(D3_CF, 1, 2) = 'DE' THEN D3_CUSTO1 ELSE 0 END) AS REQ" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + retSqlName("SD3") + " D3" + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SD3") + CRLF
	cQuery += "	AND D3.D3_OP = SD3.D3_OP" + CRLF
	cQuery += "	AND D3_ESTORNO = ' '" + CRLF
	cQuery += "	AND " + retSqlDel("SD3") + CRLF
	cQuery += "GROUP BY" + CRLF
	cQuery += "	D3_FILIAL," + CRLF
	cQuery += "	D3_OP" + CRLF
	cQuery += ") TOTAL" + CRLF
	
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("SB1") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SB1") + CRLF
	cQuery += "	AND B1_COD = C2_PRODUTO" + CRLF
	cQuery += "	AND " + retSqlDel("SB1") + CRLF


	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SC2") + CRLF
	cQuery += "	AND C2_DATRF = '        '" + CRLF
	cQuery += "	AND " + retSqlDel("SC2") + CRLF

	memowrite("\sql\SelectOP_em_Aberto.sql",cQuery)

	tcquery cQuery new alias (cAlias := getNextAlias())

	tcsetfield(cAlias,"C2_QUANT"  	,"N" ,14,2)
	tcsetfield(cAlias,"C2_QUJE"   	,"N" ,14,2)
	tcsetfield(cAlias,"DIAS_S_MOV"	,"N" ,14,1)
	tcsetfield(cAlias,"PRO"			,"N" ,14,2)
	tcsetfield(cAlias,"DEV"			,"N" ,14,2)
	tcsetfield(cAlias,"REQ"			,"N" ,14,2)
	tcsetfield(cAlias,"SLD"			,"N" ,14,2)
	tcsetfield(cAlias,"C2_QTSEGUM"  ,"N" ,16,2)
	tcsetfield(cAlias,"C2_EMISSAO" 	,"D")
	tcsetfield(cAlias,"C2_DATRF"   	,"D")

	incproc("Selecionando apontamentos...")

	cAliasTRB := criaTempTable(cAlias)
	insertTable(cAlias)
	(cAlias)->(dbCloseArea())
return

user function WP012DEL()

	if aviso("[PCP]","Confirma o encerramento das OPs marcadas?",{"Ok","Cancela"}) == 1
		(cAliasTRB)->(dbgotop())
		while !(cAliasTRB)->(eof())
			if (cAliasTRB)->(marked("OK"))
				_xOPEnc := (cAliasTRB)->c2_num+(cAliasTRB)->c2_item+(cAliasTRB)->c2_sequen
				dbselectarea("SC2")
				sc2->(dbseek(xfilial("SC2") + _xOPEnc, .t. ))
				//Busca Apontamento de Produ豫o
				dbselectarea("SD3")
				if (cAliasTRB)->pro <> 0
					sb1->(dbsetorder(1))
					sd3->(dbsetorder(1))
					if sd3->(dbseek(xfilial("SD3") + _xOPEnc, .t. ))
						while !sd3->(eof()) .and. alltrim(sd3->d3_op) == alltrim(_xOPEnc) .and. sd3->d3_filial == xfilial("SD3")
							if substr(sd3->d3_cf,1,2) == "PR"
								if empty(sd3->d3_estorno)
									sc2->(dbseek(xfilial("SC2") + _xOPEnc, .t. ))
									if empty(sc2->c2_datrf)
										lMsErroAuto := .F.
										_aVetor := {{"D3_OP"  , sd3->d3_op		 			, Nil},;
											{"D3_TM"     		  , sd3->d3_tm  	 			, Nil},;
											{"D3_COD"    		  , sd3->d3_cod 	 			, Nil},;
											{"D3_EMISSAO"		  , LastDay(sd3->d3_emissao)  	, Nil},;
											{"D3_DOC"    		  , sd3->d3_doc      			, Nil},;
											{"D3_NUMSEQ" 		  , sd3->d3_numseq   			, Nil}}
										MSExecAuto({|x, y| mata250(x, y)}, _aVetor, 7)
										If lMsErroAuto
											MostraErro()
										EndIf
									endif
								endif
							endif
							sd3->(dbskip())
						end-while
					endif
				endif
				(cAliasTRB)->(dbdelete())
			endif
			(cAliasTRB)->(dbskip())
		end-while

	endif
	(cAliasTRB)->(dbgotop())
	sysrefresh()
return()

static function ask(lPerg)
	local lRet 		:= .t.
	local aParamBox := {}
	local nI		:= 0
	default lPerg 	:= .t.

	aAdd(aParamBox,{1,"Dt Referencia"	,stod("") ,,"","","",60,.t.})

	if lPerg
		lRet := ParamBox(aParamBox,"Parametros",NIL,,,,,,,"_ENCERRAOP",.T.,.t.)
	else
		for nI := 1 to len(aParambox)
			&("MV_PAR"+strzero(nI,2)) := ParamLoad(__cUserID+"_ENCERRAOP",aParamBox,nI,aParamBox[nI,3])
		next nI
	endif

return lRet

static function criaTempTable(cAlias)
	local aStruct := (cAlias)->(dbStruct())
	local nField	:= 1
	local cField 	:= ""
	local cTipo		:= ""
	local nTamanho	:= 0
	local nDecimal	:= 0
	local cAliasTRB	:= getNextAlias()
	local aFieldsTempTable := {}

	for nField := 1 to len(aStruct)

		cField 		:= aStruct[nField, 1]
		cTipo 		:= aStruct[nField, 2]
		nTamanho 	:= aStruct[nField, 3]
		nDecimal 	:= aStruct[nField, 4]

		AADD(aFieldsTempTable, {cField , cTipo,  nTamanho,  nDecimal})
	next nField

	oTempTable := FWTemporaryTable():New(cAliasTRB,aFieldsTempTable)
	oTempTable:AddIndex("01", {"C2_NUM","C2_ITEM","C2_SEQUEN"})
	oTempTable:Create()
return cAliasTRB

static function insertTable(cAlias)
	While (cAlias)->(!Eof())
		RecLock(cAliasTRB, .T.)

		for nField := 1 to (cAlias)->(fCount())
			cField := (cAlias)->(fieldName(nField))

			(cAliasTRB)->(&(cField)) := (cAlias)->(&(cField))
		next nField

		(cAliasTRB)->(MsUnLock())

		(cAlias)->(DBSkip())
	Enddo
return
