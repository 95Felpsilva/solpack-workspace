#include "totvs.ch"
#include "TopConn.ch"

//.==============================================================.
//|                           TOTVS                              |       
//|--------------------------------------------------------------|
//| Funcao: SOLPCP02          | Autor: Felipe Campos           |
//|--------------------------------------------------------------|
//| Descricao: Essa rotina tem como objetivo encerrar/ excluir   |
//|            as Ordens de Producao em abertas                  |          
//|--------------------------------------------------------------|
//| Data criacao  : 29/06/2012  | ultima alteracao:              |
//|--------------------------------------------------------------|
//|                                                              |
//.==============================================================.


//INICIO JONI

User Function SOLPCP02()
	Local cPerg  	:= "SOLPCP02"
	Local aParBox  := {}

	AADD( aParBox,{1, "De OP" 			,CriaVar("C2_NUM")		,   ""			,'.T.'	,"SC2"    	,'.T.',60	,.F.})//MV_PAR01
	AADD( aParBox,{1, "Até OP"			,CriaVar("C2_NUM")		,   ""			,'.T.'	,"SC2"    	,'.T.',60	,.T.})//MV_PAR02
	AADD( aParBox,{1,"De Produto"       ,CriaVar("C2_PRODUTO")  ,"@!"					,'.T.'	,"SB1"		,'.T.',60	,.F.})//MV_PAR03
	AADD( aParBox,{1,"Até Produto"      ,CriaVar("C2_PRODUTO")  ,"@!"					,'.T.'	,"SB1"		,'.T.',60	,.T.})//MV_PAR04

	If ParamBox(aParBox,"Encerra OP",,,,,,,,cPerg,.T.,.T.)
		Processa({|| U_CloseOP()})
	EndIf

Return
//FIM JONI


User Function CloseOP()

	Local aCampos		:={}
	Private cCadastro 	:= "Encerramento OP/ Close OP"
	Private aRotina   	:= {}
	private cAliasTRB	:= getNextAlias()
	Private oTempTable 	:= nil

	AADD(aRotina,{"Processa"	,"U_processa",0,3})
	AADD(aCampos,{"OK"         ,NIL,"Ok"                ,"@!"})
	AADD(aCampos,{"OP"         ,NIL,"OP            "    ,"@!"})
	AADD(aCampos,{"PRODUTO"    ,NIL,"Produto       "    ,"@!"})
	AADD(aCampos,{"QTDE"       ,NIL,"Quantidade    "    ,"@E 999,999,999.99"})
	AADD(aCampos,{"ENTREGUE"   ,NIL,"Qtde Entregue "    ,"@E 999,999,999.99"})
	AADD(aCampos,{"EMISSAO"    ,NIL,"Data Emissao  "    ,"99/99/99"})

	CriaTemp()

	MarkBrow(cAliasTRB,"OK","",aCampos,,GetMark())
	oTempTable:delete()
Return

//|--------------------------------------------------------------|
//| Funcao: Processa            | Autor: Felipe Campos           |
//|--------------------------------------------------------------|
//| Descricao: Funcao responsavel pelo processamento dos itens   |
//|            selecionados no MarkBrowse                        |
//|--------------------------------------------------------------|
//| Data criacao  : 28/06/2012  | ultima alteracao:              |
//|--------------------------------------------------------------|
//|                                                              |
//.==============================================================.

User Function Processa(cAlias,nReg,nOpc)
	(cAliasTRB)->(DbGoTop())
	While (cAliasTRB)->(!Eof())
		If (cAliasTRB)->OK==ThisMark()
			EncerraOP((cAliasTRB)->OP)
		Endif
		(cAliasTRB)->(DbSkip())
	End
Return

//|--------------------------------------------------------------|
//| Funcao: CriaTemp            | Autor: Felipe Campos           |
//|--------------------------------------------------------------|
//| Descricao: Funcao responsavel por carregar as OPs na tela    |
//|            para selecao                                      |
//|--------------------------------------------------------------|
//| Data criacao  : 29/06/2012  | ultima alteracao:              |
//|--------------------------------------------------------------|
//|                                                              |
//.==============================================================.

Static Function CriaTemp()
	Local aStru	:={}
	Local cQuery:= ''

	&& Seleciona as Ordens de Producao em abertas
	cQuery := " SELECT * "
	cQuery += " FROM " + RetSqlName("SC2")
	cQuery += " WHERE "
	cQuery += " C2_FILIAL  = '"+xFilial("SC2")+"' AND"
	cQuery += " C2_DATRF = '        ' AND "
	cQuery += " C2_NUM >= '" + MV_PAR01 + "' AND " + CRLF //JONI
	cQuery += " C2_NUM <= '" + MV_PAR02 + "' AND " + CRLF //JONI
	cQuery += " C2_PRODUTO >= '" + MV_PAR03 + "' AND " + CRLF //JONI
	cQuery += " C2_PRODUTO <= '" + MV_PAR04 + "' AND " + CRLF //JONI
	cQuery += " D_E_L_E_T_  = ' '  "
	cQuery += " ORDER BY C2_NUM, C2_ITEM,C2_SEQUEN"

	TcQuery cQuery New Alias "ZZZ1"

	dbSelectArea("ZZZ1")

	TCSETFIELD("ZZZ1","C2_EMISSAO","D",8,0)

	AADD(aStru,{"OK"		,"C",2					,0})
	AADD(aStru,{"OP"		,"C",13					,0})
	AADD(aStru,{"PRODUTO"	,"C",TamSx3("B1_COD")[1],0})
	AADD(aStru,{"QTDE"		,"N",14					,2})
	AADD(aStru,{"ENTREGUE"	,"N",14					,2})
	AADD(aStru,{"EMISSAO"	,"D",8					,0})

	oTempTable := FWTemporaryTable():New(cAliasTRB,aStru)
	oTempTable:AddIndex("01", {"OP"})
	oTempTable:Create()

	While ZZZ1->(!Eof())
		RecLock(cAliasTRB,.t.)
		(cAliasTRB)->OP		:= ZZZ1->C2_NUM + ZZZ1->C2_ITEM + ZZZ1->C2_SEQUEN
		(cAliasTRB)->PRODUTO	:= ZZZ1->C2_PRODUTO
		(cAliasTRB)->QTDE      := ZZZ1->C2_QUANT
		(cAliasTRB)->ENTREGUE  := ZZZ1->C2_QUJE
		(cAliasTRB)->EMISSAO	:= ZZZ1->C2_EMISSAO
		(cAliasTRB)->(MsUnlock())
		ZZZ1->(DbSkip())
	End
	ZZZ1->(DbCloseArea())
Return

//|--------------------------------------------------------------|
//| Funcao: EncerraOP           | Autor: Felipe Campos           |
//|--------------------------------------------------------------|
//| Descricao: Funcao responsavel pelo encerramento/ exclusao    |
//|            das Ordens de Producao                            |
//|--------------------------------------------------------------|
//| Data criacao  : 29/06/2012  | ultima alteracao:              |
//|--------------------------------------------------------------|
//|                                                              |
//.==============================================================.

Static Function EncerraOP(cOP)

	Local aVetor := {}

	&& Seleciona os dados da ordem de producao marcada para exclusao
	cQuery := " SELECT * "
	cQuery += " FROM " + RetSqlName("SC2")
	cQuery += " WHERE "
	cQuery += " C2_FILIAL  = '"+xFilial("SC2")+"' AND"
	cQuery += " C2_NUM = '"+substr(cOP,1,6)+"' AND C2_ITEM ='"+substr(cOP,7,2)+"' AND C2_SEQUEN = '"+substr(cOP,9,3)+"' AND"
	cQuery += " D_E_L_E_T_  = ' '  "
	cQuery += " ORDER BY C2_NUM, C2_ITEM,C2_SEQUEN"

	TcQuery cQuery New Alias "S01"
	dbSelectArea("S01")

	&& Verifica se tem algum apontamento de produção para esta ordem de produção.
	cQuery := " SELECT * "
	cQuery += " FROM " + RetSqlName("SD3")
	cQuery += " WHERE "
	cQuery += " D3_FILIAL  = '"+xFilial("SD3")+"' AND "
	cQuery += " D3_OP      = '"+S01->C2_NUM+S01->C2_ITEM+S01->C2_SEQUEN+"' AND "
	cQuery += " D3_TM = '010' AND "
	cQuery += " D3_CF = 'PR0' AND "
	cQuery += " D_E_L_E_T_ = ' '  "

	TcQuery cQuery New Alias "S02"
	dbSelectARea("S02")

	Count to nTotPr0
	dbSelectArea("S02")
	dbGotop()
	If nTotPr0   > 0
		&& Tem apontamento de produção para esta ordem de produção
		&& Tem com encerrar a mesma .

		aVetor:={;
			{"D3_FILIAL" , xFilial("SD3")  ,Nil},;
			{"D3_DOC"    , S02->D3_DOC	   ,Nil},;
			{"D3_PRODUTO", S02->D3_COD	   ,Nil},;
			{"D3_QUANT"  , S02->D3_QUANT   ,Nil},;
			{"D3_CC"  	 , S02->D3_CC      ,Nil},;
			{"D3_CONTA"  , S02->D3_CONTA   ,Nil},;
			{"D3_UM"  	 , S02->D3_UM      ,Nil},;
			{"D3_EMISSAO", S02->D3_EMISSAO ,Nil},;
			{"D3_LOCAL"  , S02->D3_LOCAL   ,Nil},;
			{"D3_OP"  	 , S02->D3_OP      ,Nil}}

		lMsErroAuto := .F.

		dbSelectArea("SD3")
		dbGoto(S02->R_E_C_N_O_)

		MsgRun("Encerrando a Ordem de Produção",,{|| MSExecAuto({|x,y| Mata250(x,y)},aVetor,7) })

		If lMsErroAuto
			MostraErro()
		Else
			recLock(cAliasTRB,.F.)  && Remove o registro do markbrowse apos encerramento da ordem de producao pelo ExecAuto
			(cAliasTRB)->(dbDelete())
			(cAliasTRB)->(msUnlock())
			(cAliasTRB)->(dbGoTop())
		Endif

	Else

		&& Não tem apontamento de produção para esta ordem de produção
		&& Não tem com encerrar a mesma, deveremos exclui a ordem de produção.

		aVetor:={;
			{"C2_FILIAL" , xFilial("SC2")   ,Nil},;
			{"C2_NUM"    , S01->C2_NUM   	,Nil},;
			{"C2_ITEM"   , S01->C2_ITEM     ,Nil},;
			{"C2_SEQUEN" , S01->C2_SEQUEN   ,Nil},;
			{"C2_PRODUTO", S01->C2_PRODUTO	,Nil},;
			{"C2_LOCAL"  , S01->C2_LOCAL    ,Nil},;
			{"C2_QUANT"  , S01->C2_QUANT    ,Nil},;
			{"C2_UM"     , S01->C2_UM       ,Nil},;
			{"C2_DATPRI" , S01->C2_DATPRI   ,Nil},;
			{"C2_DATPRF" , S01->C2_DATPRF   ,Nil},;
			{"C2_EMISSAO", S01->C2_EMISSAO  ,Nil},;
			{"C2_PRIOR"  , S01->C2_PRIOR    ,Nil},;
			{"C2_TPOP"   , S01->C2_TPOP     ,Nil},;
			{"C2_ROTEIRO", S01->C2_ROTEIRO  ,Nil},;
			{"AUTEXPLODE", "S"              ,Nil}}

		lMsErroAuto := .F.

		dbSelectArea("SC2")
		dbSetOrder(1)
		dbSeek(xFilial("SC2")+S01->C2_NUM+S01->C2_ITEM+S01->C2_SEQUEN)

		MsgRun("Excluindo a Ordem de Produção",,{|| MSExecAuto({|x,y| Mata650(x,y)},aVetor,5) })

		If lMsErroAuto
			MostraErro()
		Else
			recLock("(cAliasTRB)",.F.) && Remove o registro do markbrowse apos exclusao da ordem de producao pelo ExecAuto
			(cAliasTRB)->(dbDelete())
			(cAliasTRB)->(msUnlock())
		Endif

		lMsErroAuto := .F.

	Endif

	if select("S01") > 0
		S01->(dbCloseArea())
	endif

	if select("S02") > 0
		S02->(dbCloseArea())
	endif

Return
