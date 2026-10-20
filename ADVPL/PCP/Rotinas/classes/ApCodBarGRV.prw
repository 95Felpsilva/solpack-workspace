#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

#Define ID_MODEL_FORM	"MODEL_FORM_SH6"

//-------------------------------------------------------------------
/*/{Protheus.doc} ApCodBarGRV
Classe interna implementando o FWModelEvent
Intern class inherited from FWModelEvent.
@author Tiago Faria
@since 19/10/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class ApCodBarGRV FROM FWModelEvent
	Method AfterTTS()
	Method New() constructor
End Class

Method New() Class ApCodBarGRV
Return

Method AfterTTS(oModel, cModelId) Class ApCodBarGRV
	FWMsgRun( ,{ || lRet := runMata681(oModel) } ,"APCODBAR", "Aguarde realizando o apontamento de produção"  )
Return

static function runMata681(oModel)
	local lRet 	:= .t.
	local oForm := oModel:getModel(ID_MODEL_FORM) 
	local aSH6	:= {}
	local nOpc 	:= 3
	local oTime	:= nil
	local aDate	:= {}
	local dDtFim:= stod("")
	local cHrFim:= ""
	local cCodBar 		:= alltrim(FwFldGet("ZZCODBAR")) 
	local cIdent		:= Right(cCodBar,getSX3Cache("H6_IDENT","X3_TAMANHO"))
	local cOP			:= subStr(cCodBar,1,len(cCodBar)-len(cIdent))

	private lMsErroAuto := .f.

	aAdd(aSH6,{"H6_OP"		,oForm:getValue("H6_OP")		,nil})
	aAdd(aSH6,{"H6_PRODUTO"	,oForm:getValue("H6_PRODUTO")	,nil})
	aAdd(aSH6,{"H6_OPERAC"	,oForm:getValue("H6_OPERAC")	,nil})
	aAdd(aSH6,{"H6_RECURSO"	,oForm:getValue("H6_RECURSO")	,nil})
	aAdd(aSH6,{"H6_DATAINI"	,oForm:getValue("H6_DATAINI")	,nil})
	aAdd(aSH6,{"H6_HORAINI"	,oForm:getValue("H6_HORAINI")	,nil})

	if oForm:getValue("H6_HORAINI") == substr(time(),1,5)
		oTime := Time():new(time())
		aDate := oTime:sumTimeHour(dDataBase,oTime:getcHora(),"00:01")
		dDtFim := aDate[1]

		if len(aDate[3]) >= 8
			cHrFim := substr(aDate[3],1,5)
		else
			cHrFim := aDate[3]
		endif
		aAdd(aSH6,{"H6_DATAFIN"	,dDtFim							,nil})
		aAdd(aSH6,{"H6_HORAFIN"	,cHrFim							,nil})
	elseif substr(time(),1,5) <= oForm:getValue("H6_HORAINI") 
		oTime := Time():new(oForm:getValue("H6_HORAINI"))
		aDate := oTime:sumTimeHour(dDataBase,oTime:getcHora(),"00:01")
		dDtFim := aDate[1]

		if len(aDate[3]) >= 8
			cHrFim := substr(aDate[3],1,5)
		else
			cHrFim := aDate[3]
		endif
		aAdd(aSH6,{"H6_DATAFIN"	,dDtFim							,nil})
		aAdd(aSH6,{"H6_HORAFIN"	,cHrFim							,nil})
	else
		aAdd(aSH6,{"H6_DATAFIN"	,dDataBase						,nil})
		aAdd(aSH6,{"H6_HORAFIN"	,substr(time(),1,5)				,nil})	
	endif

	aAdd(aSH6,{"H6_LOCAL"	,oForm:getValue("H6_LOCAL")		,nil})
	aAdd(aSH6,{"H6_QTDPROD"	,oForm:getValue("H6_QTDPROD")	,nil})
	aAdd(aSH6,{"H6_ZQTPRO2"	,oForm:getValue("H6_ZQTPRO2")	,nil})
	aAdd(aSH6,{"H6_ZZMULTP"	,oForm:getValue("H6_ZZMULTP")	,nil})
	aAdd(aSH6,{"H6_ZZOPER"	,oForm:getValue("H6_ZZOPER")	,nil})
	aAdd(aSH6,{"H6_ZZIDENT"	,cIdent							,nil})

	cAlias := u_qryTotApont02(,cOP)

	if ((cAlias)->(SALDO_OP)) < 0
		nQtdMaior := oForm:getValue("H6_QTDPROD")
	else
		nQtdMaior := (cAlias)->(TOTAL_OPER02) + oForm:getValue("H6_QTDPROD") - (cAlias)->(C2_QUANT)
	endif

	if nQtdMaior > 0
		aAdd(aSH6,{"H6_QTMAIOR"	,nQtdMaior							,nil})
	endif

	(cAlias)->(dbCloseArea())

	aSH6 		:= FwVetByDic(aSH6,"SH6")

	MSExecAuto({|x,y| MATA681(x,y)},aSH6,nOpc)

	if lMsErroAuto
		mostraErro()
		lRet := .f.
	else
		cAlias := u_qryTotApont02(cIdent,cOP)

		if (cAlias)->(H6_ZZREVIS) .and. (cAlias)->(QTD_APONT01 == TOTAL_OPER02) 
			SH6->(dbGoTo((cALias)->(RECSH6)))
			recLock("SH6",.f.)
			if SH6->(fieldPos("H6_ZZDTREV")) > 0
				SH6->H6_ZZDTREV := date()
			endif
			SH6->H6_ZZREVIS := .f.
			SH6->(msUnlock())
		endif

		(cAlias)->(dbCloseArea())
	endif
return lRet
