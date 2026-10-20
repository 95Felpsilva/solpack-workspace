#include 'Protheus.ch'

user function tstRelAbsenteismo()
    RpcSetType(3)
    RpcClearEnv()
    RpcSetEnv("01","0101")

    u_RelAbsenteismo()

    RpcClearEnv()
return

user function RelAbsenteismo()
    local oSql 			:= nil
    private cFuncDe     := ""
    private cFuncAte    := ""
    private dPeriodoDe  := stod("")
    private dPeriodoAte := stod("")

    if ask()
        oSql := SQL():new()
        oSql:setQuery(getQuery())
        MsgRun('Gerando EXCEL','Aguarde...',	{||oSQL:showExcel("Absenteismo")})
        oSql:destroy()
        msgInfo("Excel gerado com sucsso!")
    endif
return

static function getQuery()
    local cQuery            := ""
    local cCaseWhenPeriodo  := getQryCWPeriodo()
    local cQryPeriodo       := getQryPeriodo(getPeriodo())
    local cQry1A30Periodo   := getQryPeriodo(get1A30Periodo())

    cQuery += "SELECT" + CRLF
    cQuery += "	RA_MAT," + CRLF
    cQuery += "	RA_NOME," + CRLF
    cQuery += "	RA_ADMISSA," + CRLF
    cQuery += "	RA_DEMISSA," + CRLF
    cQuery += "	RA_CC," + CRLF
    cQuery += "	CTT_DESC01 AS DESC_CENTRO_CUSTO," + CRLF
    cQuery += "	MOTIVO," + CRLF
    cQuery += "	COMPETENCIA," + CRLF
    cQuery += "	PC_DATA," + CRLF
    cQuery += "	PC_QUANT AS TOTAL," + CRLF
    cQuery += "	MOTIVO_ABONO," + CRLF
    cQuery += "	COALESCE(MESES_PROPORCIONAL,0) AS MESES_PROPORCIONAL" + CRLF
    //cQuery += "	SUM(PC_QUANT) AS TOTAL" + CRLF
    cQuery += "FROM " + CRLF
    cQuery += "	" + retSqlTab("SRA") + CRLF

    cQuery += "INNER JOIN" + CRLF
    cQuery += "	" + retSqlTab("CTT") + CRLF
    cQuery += "ON 1=1" + CRLF
    cQuery += "	AND CTT_FILIAL = RA_FILIAL" + CRLF
    cQuery += "	AND CTT_CUSTO = RA_CC" + CRLF
    cQuery += "	AND " + retSqlDel("CTT") + CRLF

    cQuery += "INNER JOIN	" + CRLF
    cQuery += "(" + CRLF
    cQuery += "SELECT" + CRLF
    cQuery += "	X.*," + CRLF
    cQuery += "	COALESCE(P9_CODIGO + '-' + P9_DESC,PC_PD) AS MOTIVO," + CRLF
    cQuery += "	COALESCE(SP6.P6_CODIGO + '-' + SP6.P6_DESC,'')  AS MOTIVO_ABONO," + CRLF
    cQuery += cCaseWhenPeriodo + " AS COMPETENCIA" + CRLF
    cQuery += "FROM " + CRLF
    cQuery += "(" + CRLF
    cQuery += "SELECT" + CRLF
    cQuery += "	'SPC - MENSAL' AS TABELA," + CRLF
    cQuery += "	PC_FILIAL," + CRLF
    cQuery += "	PC_MAT," + CRLF
    cQuery += "	PC_DATA," + CRLF
    cQuery += "	PC_PD," + CRLF
    cQuery += "	CASE WHEN PC_QUANTI <> 0 THEN PC_QUANTI ELSE PC_QUANTC END AS PC_QUANT," + CRLF
    cQuery += "	PC_ABONO" + CRLF
    cQuery += "FROM " + CRLF
    cQuery += "	" + retSqlTab("SPC") + CRLF

    cQuery += "INNER JOIN" + CRLF
    cQuery += "	" + retSqlTab("SP9") + CRLF
    cQuery += "ON 1=1" + CRLF
    cQuery += "	AND " + retSqlFil("SP9") + CRLF
    cQuery += "	AND P9_CODIGO = PC_PD" + CRLF
    cQuery += "	AND P9_TIPOCOD = '2' -- 1=PROVENTO;2=DESCONTO" + CRLF
    cQuery += "	AND " + retSqlDel("SP9") + CRLF

    cQuery += "WHERE 1=1" + CRLF
    cQuery += "	AND PC_MAT BETWEEN '" + cFuncDe + "' AND '" + cFuncAte + "'" + CRLF
    cQuery += "	AND PC_DATA BETWEEN '" + dtos(dPeriodoDe) + "' AND '" + dtos(dPeriodoAte) + "'" + CRLF
    cQuery += "	AND PC_ABONO NOT IN ('029')--RED.JORNADA PLANO EMERGEN" + CRLF
    cQuery += "	AND " + retSqlDel("SPC") + CRLF

    cQuery += "UNION ALL" + CRLF

    cQuery += "SELECT " + CRLF
    cQuery += "	'SPH - ACUMULADO' AS TABELA," + CRLF
    cQuery += "	PH_FILIAL," + CRLF
    cQuery += "	PH_MAT," + CRLF
    cQuery += "	PH_DATA," + CRLF
    cQuery += "	PH_PD," + CRLF
    cQuery += "	CASE WHEN PH_QUANTI <> 0 THEN PH_QUANTI ELSE PH_QUANTC END AS PC_QUANT," + CRLF
    cQuery += "	PH_ABONO" + CRLF
    cQuery += "FROM " + CRLF
    cQuery += "	" + retSqlTab("SPH") + CRLF

    cQuery += "INNER JOIN" + CRLF
    cQuery += "	" + retSqlTab("SP9") + CRLF
    cQuery += "ON 1=1" + CRLF
    cQuery += "	AND " + retSqlFil("SP9") + CRLF
    cQuery += "	AND P9_CODIGO = PH_PD" + CRLF
    cQuery += "	AND P9_TIPOCOD = '2' -- 1=PROVENTO;2=DESCONTO" + CRLF
    cQuery += "	AND " + retSqlDel("SP9") + CRLF

    cQuery += "WHERE 1=1" + CRLF
    cQuery += "	AND PH_MAT BETWEEN '" + cFuncDe + "' AND '" + cFuncAte + "'" + CRLF
    cQuery += "	AND PH_DATA BETWEEN '" + dtos(dPeriodoDe) + "' AND '" + dtos(dPeriodoAte) + "'" + CRLF
    cQuery += "	AND PH_ABONO NOT IN ('029')--RED.JORNADA PLANO EMERGEN" + CRLF
    cQuery += "	AND " + retSqlDel("SPH") + CRLF

    cQuery += "UNION ALL" + CRLF

    cQuery += "SELECT " + CRLF
    cQuery += "	'SR8 - AFASTAMENTO' AS TABELA," + CRLF
    cQuery += "	R8_FILIAL," + CRLF
    cQuery += "	R8_MAT," + CRLF
    cQuery += "	CASE " + CRLF
    cQuery += "		WHEN INICIO > R8_DATAINI THEN INICIO" + CRLF
    cQuery += "		ELSE R8_DATAINI" + CRLF
    cQuery += "	END," + CRLF
    cQuery += "	RCM_DESCRI," + CRLF
    cQuery += "	(DATEDIFF(day,CAST(CASE " + CRLF
    cQuery += "		WHEN INICIO > R8_DATAINI THEN INICIO" + CRLF
    cQuery += "		ELSE R8_DATAINI" + CRLF
    cQuery += "	END AS DATE)," + CRLF
    cQuery += "	CAST (CASE " + CRLF
    cQuery += "		WHEN FIM > R8_DATAFIM THEN R8_DATAFIM" + CRLF
    cQuery += "		ELSE FIM" + CRLF
    cQuery += "	END AS DATE))+1) * RA_HRSDIA AS DIF_DIAS," + CRLF
    cQuery += "	'' AS MOTIVO_ABONO" + CRLF
    cQuery += "FROM " + CRLF
    cQuery += "	" + retSqlTab("SR8") + CRLF

    cQuery += "INNER JOIN" + CRLF
    cQuery += "	" + retSqlTab("SRA") + CRLF
    cQuery += "ON 1=1" + CRLF
    cQuery += "	AND RA_FILIAL = R8_FILIAL" + CRLF
    cQuery += "	AND RA_MAT = R8_MAT" + CRLF
    cQuery += "	AND " + retSqlDel("SRA") + CRLF

    cQuery += "INNER JOIN" + CRLF
    cQuery += "	" + retSqlTab("RCM") + CRLF
    cQuery += "ON 1=1" + CRLF
    cQuery += "	AND " + retSqlFil("RCM") + CRLF
    cQuery += "	AND RCM_TIPO = SR8.R8_TIPOAFA " + CRLF
    cQuery += "	AND RCM_TIPOAF <> '4' --1=Afastamento;2=Outras Ausencias;3=Informativo;4=Controle de Dias de Direito" + CRLF
    cQuery += "	AND " + retSqlDel("RCM") + CRLF

    cQuery += "INNER JOIN" + CRLF
    cQuery += "(" + CRLF
    cQuery += cQryPeriodo + CRLF
    cQuery += ")X" + CRLF
    cQuery += "ON 1=1" + CRLF
    cQuery += "AND (INICIO BETWEEN R8_DATAINI AND R8_DATAFIM OR FIM BETWEEN R8_DATAINI AND R8_DATAFIM)" + CRLF
    cQuery += "WHERE 1=1" + CRLF
    cQuery += "	AND " + retSqlFil("SR8") + CRLF
    cQuery += "	AND R8_MAT BETWEEN '" + cFuncDe + "' AND '" + cFuncAte + "'" + CRLF
    cQuery += "	AND CASE " + CRLF
    cQuery += "		WHEN INICIO > R8_DATAINI THEN INICIO" + CRLF
    cQuery += "		ELSE R8_DATAINI" + CRLF
    cQuery += "	END BETWEEN '" + dtos(dPeriodoDe) + "' AND '" + dtos(dPeriodoAte) + "'" + CRLF
    cQuery += "	AND " + retSqlDel("SR8") + CRLF
    cQuery += ")X" + CRLF

    cQuery += "LEFT JOIN" + CRLF
    cQuery += "	" + retSqlTab("SP9") + CRLF
    cQuery += "ON 1=1" + CRLF
    cQuery += "	AND " + retSqlFil("SP9") + CRLF
    cQuery += "	AND P9_CODIGO = PC_PD" + CRLF
    cQuery += "	AND " + retSqlDel("SP9") + CRLF

    cQuery += "LEFT JOIN" + CRLF
    cQuery += "	" + retSqlTab("SP6") + CRLF
    cQuery += "ON 1=1" + CRLF
    cQuery += "	AND " + retSqlFil("SP6") + CRLF
    cQuery += "	AND P6_CODIGO = PC_ABONO" + CRLF
    cQuery += "	AND " + retSqlDel("SP6") + CRLF
    cQuery += ") FALTAS" + CRLF
    cQuery += "ON 1=1" + CRLF
    cQuery += "	AND FALTAS.PC_FILIAL = RA_FILIAL" + CRLF
    cQuery += "	AND FALTAS.PC_MAT = SRA.RA_MAT" + CRLF
    cQuery += "	AND FALTAS.PC_DATA BETWEEN '" + dtos(dPeriodoDe) + "' AND '" + dtos(dPeriodoAte) + "'" + CRLF

    cQuery += "LEFT JOIN" + CRLF
    cQuery += "(" + CRLF
    cQuery += "SELECT" + CRLF
    cQuery += "	RA_FILIAL AS FILIAL," + CRLF
    cQuery += "	RA_MAT AS MATRICULA," + CRLF
    cQuery += "	COUNT(CASE " + CRLF
    cQuery += "			WHEN RA_ADMISSA BETWEEN INICIO AND FIM THEN DATEDIFF(DAY,CAST(RA_ADMISSA AS DATE),CAST(CASE WHEN RA_DEMISSA < FIM AND RA_DEMISSA <> ' ' THEN RA_DEMISSA ELSE FIM END AS DATE))+1" + CRLF
    cQuery += "			WHEN NOT RA_ADMISSA BETWEEN INICIO AND FIM THEN DATEDIFF(DAY,CAST(INICIO AS DATE),CAST(CASE WHEN RA_DEMISSA < FIM AND RA_DEMISSA <> ' ' THEN RA_DEMISSA ELSE FIM END AS DATE))+1" + CRLF
    cQuery += "			ELSE 0" + CRLF
    cQuery += "		 END) AS MESES_PROPORCIONAL" + CRLF
    cQuery += "FROM " + CRLF
    cQuery += "	" + retSqlTab("SRA") + CRLF
  
    cQuery += "INNER JOIN" + CRLF
    cQuery += "(" + CRLF
    cQuery += "" + cQry1A30Periodo
    cQuery += ")X" + CRLF
    cQuery += "ON 1=1" + CRLF
    cQuery += "	AND (INICIO BETWEEN RA_ADMISSA AND CASE WHEN RA_DEMISSA = ' ' THEN '99999999' ELSE RA_DEMISSA END OR FIM BETWEEN RA_ADMISSA AND CASE WHEN RA_DEMISSA = ' ' THEN '99999999' ELSE RA_DEMISSA END)" + CRLF
  
    cQuery += "WHERE 1=1" + CRLF
    cQuery += " AND " + retSqlFil("SRA") + CRLF
    cQuery += " AND CASE " + CRLF
    cQuery += " 		WHEN RA_ADMISSA BETWEEN INICIO AND FIM THEN DATEDIFF(DAY,CAST(RA_ADMISSA AS DATE),CAST(CASE WHEN RA_DEMISSA < FIM AND RA_DEMISSA <> ' ' THEN RA_DEMISSA ELSE FIM END AS DATE))+1" + CRLF
    cQuery += " 		WHEN NOT RA_ADMISSA BETWEEN INICIO AND FIM THEN DATEDIFF(DAY,CAST(INICIO AS DATE),CAST(CASE WHEN RA_DEMISSA < FIM AND RA_DEMISSA <> ' ' THEN RA_DEMISSA ELSE FIM END AS DATE))+1" + CRLF
    cQuery += " 		ELSE 0" + CRLF
    cQuery += "	    END >= 15 --QTD DE DIAS TRABALHADOS PARA CONSIDERAR O PGTO DE 1 MES NO PLR" + CRLF   
    cQuery += " AND " + retSqlDel("SRA") + CRLF
    cQuery += "	GROUP BY" + CRLF
    cQuery += "RA_FILIAL," + CRLF
    cQuery += "RA_MAT" + CRLF
    cQuery += ") MESES_TRABALHADOS" + CRLF
    cQuery += "ON 1=1" + CRLF
    cQuery += " AND RA_FILIAL = FILIAL" + CRLF
    cQuery += " AND RA_MAT = MATRICULA" + CRLF
 
    cQuery += "WHERE 1=1" + CRLF
    cQuery += "	AND RA_MAT BETWEEN '" + cFuncDe + "' AND '" + cFuncAte + "'" + CRLF
    cQuery += "	AND ((RA_SITFOLH = 'D' AND RA_DEMISSA LIKE '" + cValToChar(year(date())) + "%') OR RA_SITFOLH <> 'D')" + CRLF
    cQuery += "	AND " + retSqlDel("SRA") + CRLF
    /*
    cQuery += "GROUP BY" + CRLF
    cQuery += "	RA_MAT," + CRLF
    cQuery += "	RA_NOME," + CRLF
    cQuery += "	RA_ADMISSA," + CRLF
    cQuery += "	RA_DEMISSA," + CRLF
    cQuery += "	RA_SITFOLH," + CRLF
    cQuery += "	MOTIVO," + CRLF
    cQuery += "	COMPETENCIA" + CRLF
    */
    cQuery += "ORDER BY " + CRLF
    cQuery += "CASE WHEN RA_SITFOLH = 'D' THEN 2 ELSE 1 END , RA_NOME,COMPETENCIA" + CRLF

return cQuery

static function getQryPeriodo(aPeriodo)
    local cQuery        := ""
    local cInicio       := ""
    local cFim          := ""
    local cCompetencia  := ""
    local nMes          := 0
    local nMeses        := len(aPeriodo)

    for nMes := 1 to nMeses
        cInicio         := aPeriodo[nMes,1]
        cFim            := aPeriodo[nMes,2]
        cCompetencia    := aPeriodo[nMes,3]

        cQuery += "SELECT" + CRLF
        cQuery += "	'" + cInicio + "' AS INICIO," + CRLF
        cQuery += "	'" + cFim + "' AS FIM," + CRLF
        cQuery += "	'" + cCompetencia + "' AS COMPETENCIA" + CRLF
        if nMes <> nMeses
            cQuery += "UNION ALL" + CRLF
        endif
    next nMes

return cQuery

static function getQryCWPeriodo()
    local cQuery        := ""
    local aPeriodo      := getPeriodo()
    local cInicio       := ""
    local cFim          := ""
    local cCompetencia  := ""
    local nMes          := 0
    local nMeses        := len(aPeriodo)

    cQuery += "CASE " + CRLF

    for nMes := 1 to nMeses
        cInicio         := aPeriodo[nMes,1]
        cFim            := aPeriodo[nMes,2]
        cCompetencia    := aPeriodo[nMes,3]

        cQuery += "WHEN PC_DATA BETWEEN '" + cInicio + "' AND '" + cFim + "' THEN '" + cCompetencia + "'" + CRLF
    next nMes
    cQuery += "END" + CRLF
return cQuery

static function getPeriodo()
    local aPerProtheus  := getPerApontamento()
    local cDiaIni       := aPerProtheus[1]
    local cDiaFim       := aPerProtheus[2]
    local nMeses        := 12
    local nAno          := year(date())
    local cInicio       := ""
    local cFim          := ""
    local cCompetencia  := ""
    local aPeriodo      := {}
    local nMes          := 0

    for nMes := 1 to nMeses

        if nMes == 1
            cInicio := cValToChar(nAno-1) + "12" + cDiaIni
        else
            cInicio := cValToChar(nAno) + padL(cValToChar(nMes-1),2,"0") + cDiaIni
        endif

        cFim := cValToChar(nAno) + padL(cValToChar(nMes),2,"0") + cDiaFim

        cCompetencia := padL(cValToChar(nMes),2,"0") +"/" + cValToChar(nAno)
        aAdd(aPeriodo,{cInicio,cFim,cCompetencia})
    next nMes

return aPeriodo

static function get1A30Periodo()
    local nMeses        := 12
    local nAno          := year(date())
    local cInicio       := ""
    local cFim          := ""
    local cCompetencia  := ""
    local aPeriodo      := {}
    local nMes          := 0

    for nMes := 1 to nMeses
        cInicio := cValToChar(nAno) + padL(cValToChar(nMes),2,"0") + "01"
        cFim    := dtos(Lastday(stod(cInicio)))//ultimo dia do mes
        cCompetencia := padL(cValToChar(nMes),2,"0") +"/" + cValToChar(nAno)
        aAdd(aPeriodo,{cInicio,cFim,cCompetencia})
    next nMes

return aPeriodo

static function getPerApontamento()
    local cPeriodo := getMV("MV_PAPONTA")
    local aPeriodo := StrToKarr(cPeriodo,"/")
return aPeriodo

static function ask(lPerg)
    local lRet 		:= .t.
    local aParamBox := {}
    local nI		:= 0
    local cID       := "_RelAbsenteismo"
    default lPerg 	:= .t.

    Aadd(aParambox,{1,"Funcionario De"	,Space(TamSX3("RA_MAT")[1]),"","",	"SRA","",60,.F.})// MV_PAR02
    Aadd(aParambox,{1,"Funcionario Até"	,Space(TamSX3("RA_MAT")[1]),"","",	"SRA","",60,.T.})// MV_PAR02

    aAdd(aParamBox,{1,"Periodo de"		,stod("")					,"@E 99/9999","","","",50,.F.})
    aAdd(aParamBox,{1,"Periodo Ate"		,stod("")					,"@E 99/9999","","","",50,.T.})

    if lPerg
        lRet := ParamBox(aParamBox,"Absenteismo",NIL,,,,,,,cID,.T.,.t.)
    else
        for nI := 1 to len(aParambox)
            &("MV_PAR"+strzero(nI,2)) := ParamLoad(__cUserID+cID,aParamBox,nI,aParamBox[nI,3])
        next nI
    endif

    if lRet
        cFuncDe     := MV_PAR01
        cFuncAte    := MV_PAR02
        dPeriodoDe  := MV_PAR03
        dPeriodoAte := MV_PAR04
    endif
return lRet
