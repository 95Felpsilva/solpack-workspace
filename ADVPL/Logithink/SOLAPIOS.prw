#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TBICONN.CH" 
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF Chr(13)+Chr(10)
#DEFINE APIVERSAO "v10226"

#define _OCCURRENCES_ 10 //--MNTA435
#define _INSUMOCORRE_ 11 //--MNTA435

static cQuerySTL	:= nil //--MNTA435
static cQryGrvSTN	:= nil //--MNTA435
static oTmpTblOS	:= nil //--MNTA435
static lPEMNTA435	:= ExistBlock( "MNTA435N" ) //--MNTA435
static oxCabec		:= nil //--MNTA435
static axItens		:= nil //--MNTA435
static cErro		:= ""  //--MNTA435
 
/*/{Protheus.doc} SOLAPIOS
Webservice Rest para API's de integração de O.S.
@author Gustavo Viana
@type WSREST function
@since Set/2025
@version 1.0
/*/
WSRESTFUL SOLAPIOS DESCRIPTION "[Especifico - SOLPACK] APIs - Ordem de Servico - Fev 2026-02-13"

    WSDATA TENANTID     AS String
    WSDATA DataInfo     AS String
	WSDATA T4NOME       AS String
	WSDATA TJORDEM      AS String
	WSDATA TJSOLICI     AS String
	WSDATA TJXCARD      AS String
	WSDATA TJPLANO      AS String
	WSDATA TLCODIGO     AS String
	WSDATA TJCODBEM     AS String
	WSDATA TJDTMPINIDE  AS String
	WSDATA TJDTMPINIATE AS String
	WSDATA TQBZZCOD     AS String 
	WSDATA TQBCODBEM    AS String
	WSDATA TQBSOLICI    AS String
	WSDATA TQBXCARD     AS String
	WSDATA TQBDTABERDE  AS String
	WSDATA TQBDTABERATE AS String
	WSDATA Order       AS String
    WSDATA ProcInfo    AS String
    WSDATA Page        AS Integer
    WSDATA PageSize    AS Integer

    WSMETHOD GET DESCRIPTION "Ordem de Servico - Consulta" WSSYNTAX APIVERSAO
    WSMETHOD POST DESCRIPTION "Ordem de Servico - Processamento" WSSYNTAX APIVERSAO

END WSRESTFUL

/*/{Protheus.doc} GET
Webservice GET
@author Gustavo Viana
@type WS Method
@since Set/2025
@version 1.0
/*/
WSMETHOD GET WSRECEIVE DataInfo,T4NOME,TJORDEM,TJSOLICI,TJXCARD,TJPLANO,TLCODIGO,TJCODBEM,TJDTMPINIDE,TJDTMPINIATE,TQBZZCOD,TQBCODBEM,TQBSOLICI,TQBXCARD,TQBDTABERDE,TQBDTABERATE,Order,Page,PageSize HEADERPARAM TENANTID WSSERVICE SOLAPIOS
    Local aArea        := GetArea()
    Local aLoadEmpFil  := {}
    Local aAPISM0Cmp   := {}
    Local aAPISM0Lst   := {}
    Local aM0Info      := {}
    Local aX3Cmp       := {}
    Local aX3MemoCmp   := {}  
    Local aX3Struct    := {}

    Local cGetAcess    := ""
    Local cCode        := ""
    Local cMessage     := ""
    Local cDetails     := ""
    Local cQry         := ""
	Local cCountQry    := ""
    Local cJsRet       := ""
    Local cJsGet       := ::GetContent() //-- Get com Body com campos Fields/Filter/DEL
    Local cTenantId    := Self:TENANTID  //-- Get informações de empresa e filial
    Local cErrJsGet    := ""
    Local cMemo        := ""
    Local cAPIFUNC     := Self:DataInfo
    Local cAPIFIELD    := "" //-- Coringas #ALLFIELDS processa para todos os campos; #ID para R_E_C_N_O_; #DELETED para quando SetDeleteOn estiver 'true'
    Local cAPIMEMOFIELD:= "" //-- Há tabelas que direcionam os campos do tipo MEMO para tratativas internas
    Local cAPIFILT     := "" //Self:Filter
	Local cT4NOME      := Self:T4NOME
	Local cTJORDEM     := Self:TJORDEM
	Local cTJSOLICI    := Self:TJSOLICI
	Local cTJXCARD     := Self:TJXCARD
	Local cTJPLANO     := Self:TJPLANO
	Local cTLCODIGO    := Self:TLCODIGO
	Local cTJCODBEM    := Self:TJCODBEM
	Local cTJDTMPINIDE := Self:TJDTMPINIDE
	Local cTJDTMPINIATE:= Self:TJDTMPINIATE
	Local cFiltSTJ     := ""
	Local cFiltST4     := ""
	Local cFiltSTL     := ""
	Local cFiltTQB     := ""
	Local cTQBZZCOD    := Self:TQBZZCOD
	Local cTQBCODBEM   := Self:TQBCODBEM
	Local cTQBSOLICI   := Self:TQBSOLICI
	Local cTQBXCARD    := Self:TQBXCARD
	Local cTQBDTABERDE := Self:TQBDTABERDE
	Local cTQBDTABERATE:= Self:TQBDTABERATE
	Local cParamOrder  := Self:Order
	Local cSTLORDEM    := ""
	Local cSTLPLANO    := ""
    Local lRet         := .T.
    Local lSetDelOn    := .F.

    Local nPage        := Self:Page
    Local nPageSize    := Self:PageSize

    Local nX3Cmp    := 0
    Local nX3MemoCmp:= 0
    Local nI        := 0
    Local nJ        := 0
    Local nCount    := 0
    Local nRetEnv   := -1

    Local oJsGet,oJsRet,oResult

    //-- Preparação de ambiente quando informado empresa/filial
    If !Empty(cTenantId)
        aLoadEmpFil := StrToKarr(cTenantId,",")
        RPCSetType(3) 
        RPCSetEnv( aLoadEmpFil[1], aLoadEmpFil[2],/*cEnvUser*/,/*cEnvPass*/,/*cEnvMod*/,/*cFunName*/,/*aTables*/,.F.,.F.,.T.,.F. )
    EndIf

    cGetAcess := SuperGetMV("MV_XTABGET", .F.,"#$#") // Default - Sem tabelas liberadas

    oJsRet  := JsonObject():new()
    oResult := JsonObject():new()
    oJsGet  := JsonObject():new()
    
    If Empty(nPage)
        nPage := 1
    ElseIf nPage < 0
        nPage := 1
    EndIf

	If Empty(nPageSize)
       nPageSize := 50
    ElseIf nPageSize < 0
       nPageSize := 50
	ElseIf nPageSize > 100
       nPageSize := 100
    EndIf

    //-- [Ini] Validações
    If cAPIFUNC <> "TSTCON" 
        If !(cAPIFUNC $ Alltrim(cGetAcess)) //-- Tabelas liberadas para consulta
			If !(cAPIFUNC $ "PAGSTJ#PAGTQB")
				cCode:= "401"
				cMessage := "Unauthorized"
				cDetails := "Erro na solicitacao, DATAINFO ["+cAPIFUNC+"] não liberada para consulta, por favor entrar em contato com o administrador!"
				lRet := .F.
			EndIf
        else
            VarInfo("[SOLAPIOS"+APIVERSAO+"]["+cAPIFUNC+"]  "+Time(),cJsGet)
            lRet := .T.
        EndIf
    Else
        cCode:= "202"
        cMessage := "Accepted"
        cDetails  := "Conexão realizada com sucesso"
        lRet := .F.
    EndIf

	If !(cAPIFUNC $ "PAGSTJ#PAGTQB")
		If Empty(cJsGet) .And. lRet//-- Sem body
			cCode:= "400"
			cMessage := "Bad Request"
			cDetails := "Informe 'body' com informações a serem consultadas, tag 'fields' para campos, 'filter' para filtro e se considera deletados no retorno com 'OnDel' em true."
			lRet := .F.
		Else
			cErrJsGet := oJsGet:fromJson(cJsGet)
			If !Empty(cErrJsGet)
				cCode:= "400"
				cMessage := "Bad Request"
				cDetails := "JSON PARSE ERROR [body] "+cErrJsGet
				lRet := .F.
			ElseIf !('FIELDS' $ cJsGet)
				cCode:= "400"
				cMessage := "Bad Request"
				cDetails := "Tag 'FIELDS' para campos é obrigatória"
				lRet := .F.
			Else
				cAPIFIELD := oJsGet:GetJSonObject('FIELDS') 
				cAPIFILT  := oJsGet:GetJSonObject('FILTER')
				lSetDelOn := oJsGet:GetJSonObject('SETDELETEON')  //-- Se true, considera regitros deletados
				FreeObj(oJsGet)
			EndIf
		EndIf
	Else
		//-- [Ini] Endpoint para paginação em STJ (PAGSTJ#PAGTQB)
		If cAPIFUNC == "PAGSTJ" 
			If !Empty(cT4NOME)
				cFiltST4 += "    AND UPPER(T4_NOME) LIKE '%"+Alltrim(Upper(cT4NOME))+"%' "
				VarInfo("[SOLAPIOS"+APIVERSAO+"][cFiltST4]  "+Time(),cFiltST4)
			EndIf
			
			//-- # Filtrar por ordem
			If !Empty(cTJORDEM)
				cFiltSTJ += "    AND UPPER(TJ_ORDEM) LIKE '%"+Alltrim(Upper(cTJORDEM))+"%' "
			EndIf
			
			//-- # Filtrar por ativo
			If !Empty(cTJCODBEM)
				cFiltSTJ += "    AND UPPER(TJ_CODBEM) LIKE '%"+Alltrim(Upper(cTJCODBEM))+"%' "
			EndIf
			
			//-- # Filtrar por solicitação
			If !Empty(cTJSOLICI)
				cFiltSTJ += "    AND UPPER(TJ_SOLICI)  LIKE '%"+Alltrim(Upper(cTJSOLICI))+"%' "
			EndIf
			
			//-- # Filtrar por status
			If cTJXCARD != Nil 
				cFiltSTJ += "    AND TJ_XCARD = '"+Alltrim(cTJXCARD)+"' "
			EndIf
			
			//-- # Filtrar por data
			If !Empty(cTJDTMPINIDE) .And. !Empty(cTJDTMPINIATE)
				cFiltSTJ += "    AND TJ_DTMPINI BETWEEN '"+Alltrim(cTJDTMPINIDE)+"' AND '"+Alltrim(cTJDTMPINIATE)+"' "
			EndIf

			//-- # Filtrar por Preventiva ou corretiva
			If !Empty(cTJPLANO) 
				If Alltrim(cTJPLANO) == "P"
					cFiltSTJ += "    AND TJ_PLANO <> '000000' "
				ElseIf Alltrim(cTJPLANO) == "C"
					cFiltSTJ += "    AND TJ_PLANO = '000000' "
				EndIf
			EndIf
			
			//--# Filtrar por operador (usando campo da STL)
			If !Empty(cTLCODIGO) .And. Alltrim(cTLCODIGO) <> 'ADMIN' 
				cFiltSTL += " AND EXISTS ( SELECT 1 "
				cFiltSTL += "				FROM "+RetSqlName("STL")+" STL (NOLOCK)"
				cFiltSTL += "				WHERE STL.TL_ORDEM = STJ.TJ_ORDEM "
				cFiltSTL += "					AND STL.TL_CODIGO = '"+Alltrim(cTLCODIGO)+"' "
				cFiltSTL += "					AND STL.D_E_L_E_T_ <> '*' ) "
				VarInfo("[SOLAPIOS"+APIVERSAO+"][cFiltSTL]  "+Time(),cFiltSTL)
			EndIf
			VarInfo("[SOLAPIOS"+APIVERSAO+"][cFiltSTJ]  "+Time(),cFiltSTJ)

		ElseIf cAPIFUNC == "PAGTQB" 
			
			//-- # Filtrar por ordem
			If cTQBZZCOD != Nil 
				cFiltTQB += "    AND UPPER(TQB_ZZCOD) = '"+Alltrim(cTQBZZCOD)+"' "
			EndIf
			
			//-- # Filtrar por ativo
			If !Empty(cTQBCODBEM)
				cFiltTQB += "    AND UPPER(TQB_CODBEM) LIKE '%"+Alltrim(Upper(cTQBCODBEM))+"%' "
			EndIf
			
			//-- # Filtrar por solicitação
			If !Empty(cTQBSOLICI)
				cFiltTQB += "    AND UPPER(TQB_SOLICI)  LIKE '%"+Alltrim(Upper(cTQBSOLICI))+"%' "
			EndIf
			
			//-- # Filtrar por status
			If cTQBXCARD != Nil 
				cFiltTQB += "    AND TQB_XCARD = '"+Alltrim(cTQBXCARD)+"' "
			EndIf

			//-- # Filtrar por data
			If !Empty(cTQBDTABERDE) .And. !Empty(cTQBDTABERATE)
				cFiltTQB += "    AND TQB_DTABER BETWEEN '"+Alltrim(cTQBDTABERDE)+"' AND '"+Alltrim(cTQBDTABERATE)+"' "
			EndIf

			VarInfo("[SOLAPIOS"+APIVERSAO+"][cFiltTQB]  "+Time(),cFiltTQB)

		EndIf
		//-- [Fim] Endpoint para paginação em STJ (PAGSTJ/PAGTQB)
	EndIf
    //-- [Fim] Validações
 

    If lRet
		If cAPIFUNC == "PAGSTJ" //--Endpoint para paginação em STJ (PAGSTJ)
			cAPIFIELD := "TJ_ORDEM,TJ_XCARD,TJ_TIPO,TJ_PLANO,TJ_CODBEM,TJ_DTMPINI,TJ_HOMPINI,TJ_DTPRINI,TJ_HOPRINI,TJ_DTPRFIM,TJ_HOPRFIM,TJ_SOLICI,"
			cAPIFIELD += "T4_NOME,T9_NOME "
			
			cQry := "   FROM "+RetSqlName("STJ")+" STJ (NOLOCK) "
			cQry += "   JOIN "+RetSqlName("ST4")+" ST4 (NOLOCK) "
			cQry += "     ON ST4.D_E_L_E_T_ <> '*' "
			cQry += "    AND T4_FILIAL = TJ_FILIAL "
			cQry += "    AND T4_SERVICO = TJ_SERVICO "
			If !Empty(cFiltST4) 
				cQry += cFiltST4
			EndIf
			cQry += "   JOIN "+RetSqlName("ST9")+" ST9 (NOLOCK) "
			cQry += "     ON ST9.D_E_L_E_T_ <> '*' "
			cQry += "    AND T9_FILIAL = TJ_FILIAL "
			cQry += "    AND T9_CODBEM = TJ_CODBEM "
			cQry += "  WHERE STJ.D_E_L_E_T_ <> '*' "
			If !Empty(cFiltSTJ) 
				cQry += cFiltSTJ
			EndIf
			If !Empty(cFiltSTL) 
				cQry += cFiltSTL
			EndIf
			
			cCountQry := " SELECT Count(*) AS ALLREC "+cQry
			cQry := " SELECT TOP "+Alltrim(Str(1+(nPageSize*nPage)))+" "+cAPIFIELD+cQry
			VarInfo("[SOLAPIOS"+APIVERSAO+"][cQry]  "+Time(),cQry)
			//VarInfo("[SOLAPIOS"+APIVERSAO+"][cCountQry]  "+Time(),cCountQry)
			cQry += " ORDER BY STJ.R_E_C_N_O_ "

			If !Empty(cParamOrder)
				cQry += Upper(cParamOrder)
			Else
				cQry += "DESC"
			EndIf
			cQry := ChangeQuery(cQry)
														
			If Select("SOLAPIOS") > 0
				Dbselectarea("SOLAPIOS")
				SOLAPIOS->(DbClosearea())
			EndIf
														
			TcQuery cQry New Alias "SOLAPIOS"
			SOLAPIOS->(dbGoTop())

			If nPage > 1
				SOLAPIOS->( DbSkip( nPageSize * ( nPage - 1 ) ) )
			EndIf

			If SOLAPIOS->(!Eof()) 
				nCount := 0
				//nRetEnv := ((nPage * nPageSize) - (nPageSize - 1))
				aX3Cmp := StrToKarr(cAPIFIELD,",")
				oJsRet["DATA"] := {}
				While nCount < (nPage * nPageSize) .And. SOLAPIOS->(!Eof())
					nCount++
					//If nCount >= nRetEnv
						oResult := JsonObject():new()
						For nX3Cmp:= 1 to Len(aX3Cmp)
							cX3CmpInfo := Alltrim(aX3Cmp[nX3Cmp])
							//-- Chave em STL
							If cX3CmpInfo == "TJ_ORDEM"
								cSTLORDEM := SOLAPIOS->&(cX3CmpInfo)
							ElseIf cX3CmpInfo == "TJ_PLANO"
								cSTLPLANO := SOLAPIOS->&(cX3CmpInfo)
							EndIf
							If FWSX3Util():GetFieldType( cX3CmpInfo ) == "N"
								oResult[cX3CmpInfo]:= SOLAPIOS->&(cX3CmpInfo)
							ElseIf FWSX3Util():GetFieldType( cX3CmpInfo ) == "D"
								oResult[cX3CmpInfo]:= StoD(SOLAPIOS->&(cX3CmpInfo))
							ElseIf FWSX3Util():GetFieldType( cX3CmpInfo) == "L"
								If "T" $ SOLAPIOS->&(cX3CmpInfo)
									oResult[cX3CmpInfo]:= .T.
								Else
									oResult[cX3CmpInfo]:= .F.
								EndIf
							ElseIf FWSX3Util():GetFieldType( cX3CmpInfo) == "C"
								oResult[cX3CmpInfo]:= Alltrim(UPPER(FwNoAccent(EncodeUTF8(SOLAPIOS->&(aX3Cmp[nX3Cmp]),"cp1252"))))
							EndIf
						Next nX3Cmp
						
						//-- STL
						oResult["ITENS"] := {}
						dbSelectArea("STL")
						STL->(dbSetOrder(03)) 
						STL->(dbGoTop())
						If dbSeek(xFilial('STL')+cSTLORDEM+cSTLPLANO)
							While !EoF() .and. STL->TL_FILIAL == xFilial('STL') .And.;
								STL->TL_ORDEM == cSTLORDEM .And. STL->TL_PLANO == cSTLPLANO
								oJsGet := JsonObject():new()
								oJsGet["TL_CODIGO"] := Alltrim(STL->TL_CODIGO)
								oJsGet["TL_TIPOREG"]:= Alltrim(STL->TL_TIPOREG)
								oJsGet["TL_QUANTID"]:= STL->TL_QUANTID
								aAdd(oResult["ITENS"],oJsGet)	
								STL->(dbSkip())
							End
						EndIf

						aAdd(oJsRet["DATA"],oResult)
					//EndIf
					SOLAPIOS->(dbSkip())
				End
				oJsRet["HASNEXT"] := Iif(nCount == (nPage * nPageSize) .And. SOLAPIOS->(!Eof()),.T.,.F.)
				//-- Total de Registros
                cQry := cCountQry
                cQry := ChangeQuery(cQry)
                                                             
                If Select("SOLAPIOS") > 0
                   Dbselectarea("SOLAPIOS")
                   SOLAPIOS->(DbClosearea())
                EndIf
                                                                
                TcQuery cQry New Alias "SOLAPIOS"
                SOLAPIOS->(dbGoTop())
                If SOLAPIOS->(!Eof())
                   oJsRet["ALLRECORDS"] := SOLAPIOS->ALLREC
                EndIf
			Else
				oResult := JsonObject():new()
				oResult["DETAILS"] := EncodeUTF8("Sem informações","cp1252")
				oJsRet["DATA"] := {}
				aAdd(oJsRet["DATA"],oResult)
			EndIf
			 
			SOLAPIOS->(DbClosearea())
			cJsRet:= FWJsonSerialize(oJsRet,.T.,.T.)
			Self:SetResponse(cJsRet)
			FreeObj(oJsRet)
		ElseIf cAPIFUNC == "PAGTQB" //--Endpoint para paginação em TQB (PAGTQB)
			cAPIFIELD := "TQB_SOLICI,TQB_XCARD,TQB_CODBEM,TQB_CDSERV,TQB_XSERVI,TQB_DTABER,TQB_HOABER,TQB_XDTPRI,TQB_XHRPRI,TQB_ZZCOD,TQB_ORDEM,"
			cAPIFIELD += "T9_NOME,TQB.R_E_C_N_O_ IDRECTOTVS "
			cAPIMEMOFIELD := "TQB_DESCSS"
			
			cQry := "   FROM "+RetSqlName("TQB")+" TQB (NOLOCK) "
			cQry += "   JOIN "+RetSqlName("ST9")+" ST9 (NOLOCK) "
			cQry += "     ON ST9.D_E_L_E_T_ <> '*' "
			cQry += "    AND TQB_FILIAL = T9_FILIAL "
			cQry += "    AND TQB_CODBEM = T9_CODBEM "
			cQry += "  WHERE TQB.D_E_L_E_T_ <> '*' "
			If !Empty(cFiltTQB) 
				cQry += cFiltTQB
			EndIf
			
			cCountQry := " SELECT Count(*) AS ALLREC "+cQry
			cQry := " SELECT TOP "+Alltrim(Str(1+(nPageSize*nPage)))+" "+cAPIFIELD+cQry
			VarInfo("[SOLAPIOS"+APIVERSAO+"][cQry]  "+Time(),cQry)

			cQry += " ORDER BY TQB.TQB_SOLICI "

			If !Empty(cParamOrder)
				cQry += Upper(cParamOrder)
			Else
				cQry += "DESC"
			EndIf
			cQry := ChangeQuery(cQry)
														
			If Select("SOLAPIOS") > 0
				Dbselectarea("SOLAPIOS")
				SOLAPIOS->(DbClosearea())
			EndIf
														
			TcQuery cQry New Alias "SOLAPIOS"
			SOLAPIOS->(dbGoTop())

			If nPage > 1
				SOLAPIOS->( DbSkip( nPageSize * ( nPage - 1 ) ) )
			EndIf

			If SOLAPIOS->(!Eof()) 
				nCount := 0
				//nRetEnv := ((nPage * nPageSize) - (nPageSize - 1))
				aX3Cmp := StrToKarr(cAPIFIELD,",")
				oJsRet["DATA"] := {}
				While nCount < (nPage * nPageSize) .And. SOLAPIOS->(!Eof())
					nCount++
					//If nCount >= nRetEnv
						oResult := JsonObject():new()
						For nX3Cmp:= 1 to Len(aX3Cmp)
							cX3CmpInfo := Alltrim(aX3Cmp[nX3Cmp])

							If FWSX3Util():GetFieldType( cX3CmpInfo ) == "N"
								oResult[cX3CmpInfo]:= SOLAPIOS->&(cX3CmpInfo)
							ElseIf FWSX3Util():GetFieldType( cX3CmpInfo ) == "D"
								oResult[cX3CmpInfo]:= StoD(SOLAPIOS->&(cX3CmpInfo))
							ElseIf FWSX3Util():GetFieldType( cX3CmpInfo) == "L"
								If "T" $ SOLAPIOS->&(cX3CmpInfo)
									oResult[cX3CmpInfo]:= .T.
								Else
									oResult[cX3CmpInfo]:= .F.
								EndIf
							ElseIf FWSX3Util():GetFieldType( cX3CmpInfo) == "C"
								oResult[cX3CmpInfo]:= Alltrim(UPPER(FwNoAccent(EncodeUTF8(SOLAPIOS->&(aX3Cmp[nX3Cmp]),"cp1252"))))
							EndIf
						Next nX3Cmp

						//-- Especifico para tabela TQB
						aX3MemoCmp := StrToKarr(cAPIMEMOFIELD,",")
						For nX3Cmp:= 1 to Len(aX3MemoCmp)
							dbselectArea("TQB")
							TQB->(dbgoto(SOLAPIOS->IDRECTOTVS))
							cMemo := MNT280REL(aX3MemoCmp[nX3Cmp])
							If VALTYPE(DecodeUtf8(cMemo, 'cp1252' )) == "U"
								oResult[aX3MemoCmp[nX3Cmp]]:= Alltrim(UPPER(FwNoAccent(cMemo)))
							Else
								oResult[aX3MemoCmp[nX3Cmp]]:= Alltrim(UPPER(FwNoAccent(EncodeUTF8(cMemo,"cp1252"))))
							EndIf
						Next nX3Cmp  
						
						aAdd(oJsRet["DATA"],oResult)
					//EndIf
					SOLAPIOS->(dbSkip())
				End
				oJsRet["HASNEXT"] := Iif(nCount == (nPage * nPageSize) .And. SOLAPIOS->(!Eof()),.T.,.F.)
				//-- Total de Registros
                cQry := cCountQry
                cQry := ChangeQuery(cQry)
                                                             
                If Select("SOLAPIOS") > 0
                   Dbselectarea("SOLAPIOS")
                   SOLAPIOS->(DbClosearea())
                EndIf
                                                                
                TcQuery cQry New Alias "SOLAPIOS"
                SOLAPIOS->(dbGoTop())
                If SOLAPIOS->(!Eof())
                   oJsRet["ALLRECORDS"] := SOLAPIOS->ALLREC
                EndIf
			Else
				oResult := JsonObject():new()
				oResult["DETAILS"] := EncodeUTF8("Sem informações","cp1252")
				oJsRet["DATA"] := {}
				aAdd(oJsRet["DATA"],oResult)
			EndIf
			//VarInfo("[SOLAPIOS"+APIVERSAO+"][oJsRet]  "+Time(),oJsRet) 
			SOLAPIOS->(DbClosearea())
			cJsRet:= FWJsonSerialize(oJsRet,.T.,.T.)
			Self:SetResponse(cJsRet)
			FreeObj(oJsRet)

		Else //-- Endpoint para Get com Body em
			If "SM0" $ cAPIFUNC+"#"
				If Empty(cAPIFILT)
					aAdd(aM0Info,FWSM0Util():GetSM0Data(,, aAPISM0Cmp) )
				Else
					For nI:= 1 to Len(aAPISM0Lst)
						aAdd(aM0Info,FWSM0Util():GetSM0Data(,aAPISM0Lst[nI], aAPISM0Cmp ) )
					Next nI	
				EndIf
			Else
				If "ALLFIELDS" $ cAPIFIELD
					aX3Struct  := FwSX3Util():GetAllFields(cAPIFUNC,.T.)
				Else
					aX3Struct  := StrToKarr(cAPIFIELD,",")
				EndIf
				
				cAPIFIELD  := ""
				For nX3Cmp := 1 To Len(aX3Struct)
					If aX3Struct[nX3Cmp] != "IDRECTOTVS"
						If GetSX3Cache(aX3Struct[nX3Cmp], "X3_CONTEXT") != "V"
							cAPIFIELD += aX3Struct[nX3Cmp]+","
						ElseIf GetSX3Cache(aX3Struct[nX3Cmp], "X3_TIPO") == "M"
							cAPIMEMOFIELD += aX3Struct[nX3Cmp]+","
						EndIf
					Else    
						cAPIFIELD += aX3Struct[nX3Cmp]+","
					EndIf
				Next nX3Cmp

				VarInfo("[SOLAPIOS"+APIVERSAO+"][APIFIELD]  "+Time(),cAPIFIELD)
				VarInfo("[SOLAPIOS"+APIVERSAO+"][APIMEMOFIELD]  "+Time(),cAPIMEMOFIELD)
				cQry += " SELECT TOP "+Str(1+(nPageSize*nPage))+" "+cAPIFIELD
				If lSetDelOn
					cQry += " IIF("+cAPIFUNC+".D_E_L_E_T_ = '*','TRUE','FALSE') AS DELETED, "
				EndIf
				cQry += " R_E_C_N_O_ IDRECTOTVS "
				cQry += "   FROM "+RetSqlName(cAPIFUNC)+" "+cAPIFUNC+" (NOLOCK) "
				If !Empty(cAPIFILT)
					If "IDRECTOTVS =" $ cAPIFILT .Or. "IDRECTOTVS=" $ cAPIFILT .Or. "IDRECTOTVS IN" $ cAPIFILT 
						cAPIFILT := StrTran(cAPIFILT, "IDRECTOTVS =", cAPIFUNC+".R_E_C_N_O_ = ")
						cAPIFILT := StrTran(cAPIFILT, "IDRECTOTVS=", cAPIFUNC+".R_E_C_N_O_ = ")
						cAPIFILT := StrTran(cAPIFILT, "IDRECTOTVS IN", cAPIFUNC+".R_E_C_N_O_ IN ")
					EndIf
				EndIf
				If !lSetDelOn
					cQry += "  WHERE "+cAPIFUNC+".D_E_L_E_T_ <> '*' "
					If !Empty(cAPIFILT)
						cQry += " AND "+cAPIFILT
					EndIf
				Else
					If !Empty(cAPIFILT)
						cQry += " WHERE "+cAPIFILT
					EndIf
				EndIf
				cQry += " ORDER BY R_E_C_N_O_ "

				cQry := ChangeQuery(cQry)
														
				If Select("SOLAPIOS") > 0
					Dbselectarea("SOLAPIOS")
					SOLAPIOS->(DbClosearea())
				EndIf
														
				TcQuery cQry New Alias "SOLAPIOS"
				SOLAPIOS->(dbGoTop())		
			EndIf

			If "SM0" $ cAPIFUNC+"#"
				For nI:=1 to Len(aM0Info)
					oResult := JsonObject():new()
					For nJ:=1 to Len(aM0Info[nI])
						oResult[aM0Info[nI,nJ,1]]:= aM0Info[nI,nJ,2]
					Next nJ
					aAdd(oJsRet[cAPIFUNC],oResult)
				Next nI
			Else
				aX3Cmp     := StrToKarr(cAPIFIELD,",")
				If SOLAPIOS->(!Eof()) 
					nRetEnv := ((nPage * nPageSize) - (nPageSize - 1))
					nCount := 0
					oJsRet[cAPIFUNC] := {}
					While nCount < (nPage * nPageSize) .And. SOLAPIOS->(!Eof())
						nCount++
						If nCount >= nRetEnv
						oResult := JsonObject():new()
						oResult["IDRECTOTVS"]:= SOLAPIOS->IDRECTOTVS 
						If lSetDelOn
							If "T" $ SOLAPIOS->DELETED 
								oResult["DELETED"]:= .T.
							Else
								oResult["DELETED"]:= .F.
							EndIf
						EndIf
						For nX3Cmp:= 1 to Len(aX3Cmp)
							If FWSX3Util():GetFieldType( aX3Cmp[nX3Cmp] ) == "N"
								oResult[aX3Cmp[nX3Cmp]]:= SOLAPIOS->&(aX3Cmp[nX3Cmp])
							ElseIf FWSX3Util():GetFieldType( aX3Cmp[nX3Cmp] ) == "D"
								oResult[aX3Cmp[nX3Cmp]]:= StoD(SOLAPIOS->&(aX3Cmp[nX3Cmp]))
							ElseIf FWSX3Util():GetFieldType( aX3Cmp[nX3Cmp]) == "L"
								If "T" $ SOLAPIOS->&(aX3Cmp[nX3Cmp])
									oResult[aX3Cmp[nX3Cmp]]:= .T.
								Else
									oResult[aX3Cmp[nX3Cmp]]:= .F.
								EndIf
							ElseIf FWSX3Util():GetFieldType( aX3Cmp[nX3Cmp]) == "C"
								oResult[aX3Cmp[nX3Cmp]]:= Alltrim(UPPER(FwNoAccent(EncodeUTF8(SOLAPIOS->&(aX3Cmp[nX3Cmp]),"cp1252"))))
							ElseIf FWSX3Util():GetFieldType( aX3Cmp[nX3Cmp]) == "M"
								dbselectArea(cAPIFUNC)
								dbgoto(SOLAPIOS->IDRECTOTVS)
								cMemo := cAPIFUNC+"->"+aX3Cmp[nX3Cmp]
								oResult[aX3Cmp[nX3Cmp]]:= Alltrim(UPPER(FwNoAccent(EncodeUTF8(&cMemo,"cp1252"))))
							EndIf
						Next nX3Cmp

							//-- Especifico para tabela TQB/TUM/TUR - SIGAMNT
							If cAPIFUNC $ "TQB/TUM/TUR" .And. !Empty(cAPIMEMOFIELD)
								aX3MemoCmp := StrToKarr(cAPIMEMOFIELD,",")
								For nX3Cmp:= 1 to Len(aX3MemoCmp)
									dbselectArea(cAPIFUNC)
									dbgoto(SOLAPIOS->IDRECTOTVS)
									cMemo := MNT280REL(aX3MemoCmp[nX3Cmp])
									oResult[aX3MemoCmp[nX3Cmp]]:= Alltrim(UPPER(FwNoAccent(EncodeUTF8(cMemo,"cp1252"))))
								Next nX3Cmp  
							EndIf
							aAdd(oJsRet[cAPIFUNC],oResult)
						EndIf
						SOLAPIOS->(dbSkip())
					End
					oJsRet["HASNEXT"] := Iif(nCount == (nPage * nPageSize) .And. SOLAPIOS->(!Eof()),.T.,.F.)
				Else
					oResult := JsonObject():new()
					oResult["DETAILS"] := EncodeUTF8("Sem informações","cp1252")
					oJsRet[cAPIFUNC] := {}
					aAdd(oJsRet[cAPIFUNC],oResult)
				EndIf
			EndIf 
			SOLAPIOS->(DbClosearea())
			cJsRet:= FWJsonSerialize(oJsRet,.T.,.T.)
			Self:SetResponse(cJsRet)
			FreeObj(oJsRet)
		EndIf
    Else
		nStatRet := Val(cCode)
        oResult["CODE"] := cCode
        oResult["MESSAGE"] := EncodeUTF8(cMessage,"cp1252")
        oResult["DETAILS"] := EncodeUTF8(cDetails,"cp1252") 
        oJsRet["status"]   := {}
		aAdd(oJsRet["status"],oResult)
        cJsRet:= FWJsonSerialize(oResult,.T.,.T.)
        Self:SetStatus(nStatRet) 
        Self:SetResponse(cJsRet)
        FreeObj(oJsRet)
    EndIf

    If !Empty(cTenantId)
        RpcClearEnv()
    EndIf

  	RestArea(aArea)

Return lRet

/*/{Protheus.doc} POST
Webservice POST
@author Gustavo Viana
@type WS Method
@since Set/2025
@version 1.0
/*/
WSMETHOD POST WSRECEIVE DataInfo,ProcInfo,Page,PageSize HEADERPARAM TENANTID WSSERVICE SOLAPIOS
    Local aArea       := GetArea()
    Local aRet435     := {}
    Local aX3Struct   := {}
    Local aLoadEmpFil := {}

    Local cStatRet    := 400
    Local cCode       := ""
    Local cMessage    := ""
    Local cDetails    := ""
    Local cTenantId   := Self:TENANTID  //-- Get informações de empresa e filial

    Local lRet        := .T.

    Local nX3Cmp      := 0
	Local nTab        := 0

    Local oJsRet,oResult,oObjRet

    //-- Get via Post
    Local aAPISM0Cmp   := {}
    Local aAPISM0Lst   := {}
    Local aTables      := {}
	Local aJoinFilt    := {} 
    Local aM0Info      := {}
    Local aX3Cmp       := {}
    Local aX3MemoCmp   := {} 
    Local cGetAcess    := ""
	Local cQry        := ""
	Local cCountQry   := ""
    Local cJsRet       := ""
    Local cJsGet       := ::GetContent() //-- Get com Body com campos Fields/Filter/DEL
    Local cErrJsGet    := ""
    Local cMemo        := ""
	Local cDecMemo     := ""
    Local cAPIFUNC     := Self:DataInfo
    Local cAPIFIELD    := "" //-- Coringas #ALLFIELDS processa para todos os campos; #ID para R_E_C_N_O_; #DELETED para quando SetDeleteOn estiver 'true'
	Local cAPIORDER    := ""
	Local cTableCmp    := ""
	Local cAPIJOINFILT := ""
    Local cAPIMEMOFIELD:= "" //-- Há tabelas que direcionam os campos do tipo MEMO para tratativas internas
    Local cAPIFILT     := ""

    Local lSetDelOn    := .F.

    Local nPage        := Self:Page
    Local nPageSize    := Self:PageSize

    Local nX3MemoCmp:= 0
    Local nI        := 0
    Local nJ        := 0
	Local nX        := 0
	Local nItCP     := 0
    Local nCount    := 0
	Local nNegCount := 0
    Local nRetEnv   := -1

    Local oJsGet

    //-- Post
    Local aSolic      := {}
	Local cValidPrd105:= ""
	Local lValidPrd105:= .T.
	Local aMATA105Cab := {}
	Local aMATA105ECab:= {}
	Local aMATA105Inc := {}
	Local aMATA105Exc := {}
	Local cMATA105Num := ""
	Local nMATA105Opc := 0
	Local aProc105    := {}
	Local aTempos     := {}
	Local nSemana     := 0
	Local cSH7COD     := ""
	Local cSTJPLN     := ""
    Local cAlias      := ""
    Local cPostAcess  := "MNTA280#MNTA420#MNTA435"
    Local cChave      := ""
    Local cMField     := ""

    Local l420Grava   := .F.  
	Local lSeq420Exec := .F.

    Local cExecRot   := Self:ProcInfo
    Local cErrJsPost := ""
    Local cErroProc  := ""
    Local cArqLog    := ""
	Local cField     := ""
	Local cFieldInfo := ""
    Local cJsPost    := ::GetContent() //-- Post com Body com campos OPERATION/Campos para a operação
    Local nOperacao  := 0
	Local nRecnSTJ   := -1
	Local lUnicReq   := SuperGetMV('MV_X105UNC',.F.,.F.) //-- Requisição unica ao Armazém

    Private oJsPost

    Private oTQB //-- MNTA280 (4/5)
    Private lFacilit    := .T. //-- MNTA280 (4/5)
    Private c280MemoDg  := ""  //-- MNTA280 (4/5)
    Private lMSHelpAuto := .T. 
    Private lMSErroAuto := .F. 
	Private nSEQRELA    := 0
	Private cErroGeral  := ""

    If !Empty(cAPIFUNC) //-- Get via Post
        //-- Preparação de ambiente quando informado empresa/filial
        If !Empty(cTenantId)
            aLoadEmpFil := StrToKarr(cTenantId,",")
            RPCSetType(3) 
            RPCSetEnv( aLoadEmpFil[1], aLoadEmpFil[2],/*cEnvUser*/,/*cEnvPass*/,/*cEnvMod*/,/*cFunName*/,/*aTables*/,.F.,.F.,.T.,.F. )
        EndIf

        cGetAcess := SuperGetMV("MV_XTABGET", .F.,"#$#") // Default - Sem tabelas liberadas

        oJsRet  := JsonObject():new()
        oResult := JsonObject():new()
        oJsGet  := JsonObject():new()
        
		//-- Tratativas para Pagina informada
        If Empty(nPage)
            nPage := 1
        ElseIf nPage < 0
            nPage := 1
        EndIf

		//-- Tratativas para registros por Pagina informada
        If Empty(nPageSize)
            nPageSize := 20
        ElseIf nPageSize < 0
            nPageSize := 20
		ElseIf nPageSize > 100
            nPageSize := 100
        EndIf

        //-- [Ini] Validações
        If cAPIFUNC <> "TSTCON" 
			aTables  := StrToKarr(cAPIFUNC,",")
			For nTab:= 1 to Len(aTables)
				If !(aTables[nTab] $ Alltrim(cGetAcess)) //-- Tabelas liberadas para consulta
					cCode:= "401"
					cMessage := "Unauthorized"
					cDetails := "Erro na solicitacao, DATAINFO ["+aTables[nTab]+"] não liberada para consulta, por favor entrar em contato com o administrador!"
					lRet := .F.
				EndIf
			Next nTab
        Else
            cCode:= "202"
            cMessage := "Accepted"
            cDetails  := "Conexão realizada com sucesso"
            lRet := .F.
        EndIf

        If Empty(cJsGet) .And. lRet//-- Sem body
            cCode:= "404"
            cMessage := "Bad Request"
            cDetails := "Informe 'body' com informações a serem consultadas, tag 'fields' para campos, 'filter' para filtro e se considera deletados no retorno com 'SetDeleteon' em true."
            lRet := .F.
        Else
            cErrJsGet := oJsGet:fromJson(cJsGet)
            If !Empty(cErrJsGet)
                cCode:= "400"
                cMessage := "Bad Request"
                cDetails := "JSON PARSE ERROR [body] "+cErrJsGet
                lRet := .F.
            ElseIf !('FIELDS' $ cJsGet)
                cCode:= "400"
                cMessage := "Bad Request"
                cDetails := "Tag 'FIELDS' para campos é obrigatória"
                lRet := .F.
            ElseIf 'INSERT ' $ Upper(cJsGet) .OR. 'UPDATE ' $ Upper(cJsGet)
                cCode:= "400"
                cMessage := "Bad Request"
                cDetails := "Processamento inválido"
                lRet := .F.
			ElseIf Len(aTables) > 1 .And. !('JOINFILTER' $ cJsGet)
                cCode:= "400"
                cMessage := "Bad Request"
                cDetails := "Tag 'JOINFILTER' para mais de uma tabela em DataInfo é obrigatória"
                lRet := .F.
            Else
                cAPIFIELD := oJsGet:GetJSonObject('FIELDS') 
                cAPIFILT  := oJsGet:GetJSonObject('FILTER')
				cAPIJOINFILT  := oJsGet:GetJSonObject('JOINFILTER')
				If !Empty(cAPIJOINFILT)
					aJoinFilt    := StrToKarr(cAPIJOINFILT,",")
				EndIf
				cAPIORDER := oJsGet:GetJSonObject('ORDER')
                lSetDelOn := oJsGet:GetJSonObject('SETDELETEON')  //-- Se true, considera regitros deletados
                FreeObj(oJsGet)
            EndIf
        EndIf
        //-- [Fim] Validações

        If lRet
            If "SM0" $ cAPIFUNC+"#"
                If Empty(cAPIFILT)
                    aAdd(aM0Info,FWSM0Util():GetSM0Data(,, aAPISM0Cmp) )
                Else
                    For nI:= 1 to Len(aAPISM0Lst)
                        aAdd(aM0Info,FWSM0Util():GetSM0Data(,aAPISM0Lst[nI], aAPISM0Cmp ) )
                    Next nI	
                EndIf
            Else
				cTableCmp  := ""
				For nTab:= 1 to Len(aTables)
					If "ALLFIELDS" $ cAPIFIELD
						aX3Struct  := FwSX3Util():GetAllFields(aTables[nTab],.T.)
					Else
						aX3Struct  := StrToKarr(cAPIFIELD,",")
					EndIf
					
					For nX3Cmp := 1 To Len(aX3Struct)
						If aX3Struct[nX3Cmp] != "IDRECTOTVS"
							If GetSX3Cache(aX3Struct[nX3Cmp], "X3_CONTEXT") != "V"
								cTableCmp += aX3Struct[nX3Cmp]+","
							ElseIf GetSX3Cache(aX3Struct[nX3Cmp], "X3_TIPO") == "M"
								cAPIMEMOFIELD += aX3Struct[nX3Cmp]+","
							EndIf
						Else    
							cAPIFIELD += aX3Struct[nX3Cmp]+","
						EndIf
					Next nX3Cmp
				Next nTab

                cQry := " SELECT TOP "+Alltrim(Str(1+(nPageSize*nPage)))+" "+cTableCmp
				cCountQry := " SELECT Count(*) AS ALLREC "
				If lSetDelOn
					cQry += " IIF("+aTables[1]+".D_E_L_E_T_ = '*','TRUE','FALSE') AS DELETED, "
				EndIf
				For nTab:= 1 to Len(aTables)
					If nTab == 1
						cQry += aTables[nTab]+".R_E_C_N_O_ IDRECTOTVS "
						cQry += "   FROM "+RetSqlName(aTables[nTab])+" "+aTables[nTab]+" (NOLOCK) "
						cCountQry += "   FROM "+RetSqlName(aTables[nTab])+" "+aTables[nTab]+" (NOLOCK) "
					Else
						cQry += "   JOIN "+RetSqlName(aTables[nTab])+" "+aTables[nTab]+" (NOLOCK) "
						cCountQry += "   JOIN "+RetSqlName(aTables[nTab])+" "+aTables[nTab]+" (NOLOCK) "
						If lSetDelOn
							cQry += "   ON "+aTables[nTAB]+".D_E_L_E_T_ = '*' AND "
							cCountQry += "   ON "+aTables[nTAB]+".D_E_L_E_T_ = '*' AND "
						Else
							cQry += "   ON "+aTables[nTAB]+".D_E_L_E_T_ <> '*' AND "
							cCountQry += "   ON "+aTables[nTAB]+".D_E_L_E_T_ <> '*' AND "
						EndIf
						If !Empty(aJoinFilt)
							cQry += aJoinFilt[nTab-1]
							cCountQry += aJoinFilt[nTab-1]
						EndIf
					EndIf
				Next nTab
				If !Empty(cAPIFILT)
					If "IDRECTOTVS =" $ cAPIFILT .Or. "IDRECTOTVS=" $ cAPIFILT .Or. "IDRECTOTVS IN" $ cAPIFILT 
						cAPIFILT := StrTran(cAPIFILT, "IDRECTOTVS =", aTables[1]+".R_E_C_N_O_ = ")
						cAPIFILT := StrTran(cAPIFILT, "IDRECTOTVS=", aTables[1]+".R_E_C_N_O_ = ")
						cAPIFILT := StrTran(cAPIFILT, "IDRECTOTVS IN", aTables[1]+".R_E_C_N_O_ IN ")
					EndIf
				EndIf
				If !lSetDelOn 
					cQry += "  WHERE "+aTables[1]+".D_E_L_E_T_ <> '*' "
					cCountQry += "  WHERE "+aTables[1]+".D_E_L_E_T_ <> '*' AND "+aTables[1]+".R_E_C_N_O_ > 0"
					If !Empty(cAPIFILT)
						cQry += " AND "+cAPIFILT
						cCountQry += " AND "+cAPIFILT
					EndIf
				Else
					If !Empty(cAPIFILT)
						cQry += " WHERE "+cAPIFILT
						cCountQry += " WHERE "+aTables[1]+".R_E_C_N_O_ > 0 AND "+cAPIFILT
					EndIf
				EndIf
				If !Empty(cAPIORDER)
					If "IDRECTOTVS" $ cAPIORDER
						cAPIORDER := StrTran(cAPIORDER, "IDRECTOTVS", aTables[1]+".R_E_C_N_O_")
					EndIf
					cQry += cAPIORDER
				Else
                	cQry += " ORDER BY "+aTables[1]+".R_E_C_N_O_ "
				EndIf
				If !Empty(cAPIMEMOFIELD)
					VarInfo("[SOLAPIOS"+APIVERSAO+"][APIMEMOFIELD]  "+Time(),cAPIMEMOFIELD)
				EndIf
				VarInfo("[SOLAPIOS"+APIVERSAO+"][cQry]  "+Time(),cQry)

                cQry := ChangeQuery(cQry)
                                                        
                If Select("SOLAPIOS") > 0
                    Dbselectarea("SOLAPIOS")
                    SOLAPIOS->(DbClosearea())
                EndIf
                                                        
                TcQuery cQry New Alias "SOLAPIOS"
                SOLAPIOS->(dbGoTop())		
            EndIf
			cAPIFUNC:= aTables[1]
            If "SM0" $ cAPIFUNC+"#"
                For nI:=1 to Len(aM0Info)
                    oResult := JsonObject():new()
                    For nJ:=1 to Len(aM0Info[nI])
                        oResult[aM0Info[nI,nJ,1]]:= aM0Info[nI,nJ,2]
                    Next nJ
                    aAdd(oJsRet[cAPIFUNC],oResult)
                Next nI
            Else
                aX3Cmp     := StrToKarr(cTableCmp,",")
                If SOLAPIOS->(!Eof()) 
                    nRetEnv := ((nPage * nPageSize) - (nPageSize - 1))
                    nCount := 0
					nNegCount := 0
                    oJsRet[cAPIFUNC] := {}
                    While nCount < (nPage * nPageSize) .And. SOLAPIOS->(!Eof())
                        nCount++
						If SOLAPIOS->IDRECTOTVS > 0
							If nCount >= nRetEnv
								oResult := JsonObject():new()
								oResult["IDRECTOTVS"]:= SOLAPIOS->IDRECTOTVS 
								If lSetDelOn
									If "T" $ SOLAPIOS->DELETED 
										oResult["DELETED"]:= .T.
									Else
										oResult["DELETED"]:= .F.
									EndIf
								EndIf
								For nX3Cmp:= 1 to Len(aX3Cmp)
									If FWSX3Util():GetFieldType( aX3Cmp[nX3Cmp] ) == "N"
										oResult[aX3Cmp[nX3Cmp]]:= SOLAPIOS->&(aX3Cmp[nX3Cmp])
									ElseIf FWSX3Util():GetFieldType( aX3Cmp[nX3Cmp] ) == "D"
										oResult[aX3Cmp[nX3Cmp]]:= StoD(SOLAPIOS->&(aX3Cmp[nX3Cmp]))
									ElseIf FWSX3Util():GetFieldType( aX3Cmp[nX3Cmp]) == "L"
										If "T" $ SOLAPIOS->&(aX3Cmp[nX3Cmp])
											oResult[aX3Cmp[nX3Cmp]]:= .T.
										Else
											oResult[aX3Cmp[nX3Cmp]]:= .F.
										EndIf
									ElseIf FWSX3Util():GetFieldType( aX3Cmp[nX3Cmp]) == "C"
										oResult[aX3Cmp[nX3Cmp]]:= Alltrim(UPPER(FwNoAccent(EncodeUTF8(SOLAPIOS->&(aX3Cmp[nX3Cmp]),"cp1252"))))
									ElseIf FWSX3Util():GetFieldType( aX3Cmp[nX3Cmp]) == "M"
										dbselectArea(cAPIFUNC)
										dbgoto(SOLAPIOS->IDRECTOTVS)
										If SubStr(cAPIFUNC,1,1) == "S"
											If SubStr(cAPIFUNC,2,2)+"_" $ aX3Cmp[nX3Cmp]
												cMemo := cAPIFUNC+"->"+aX3Cmp[nX3Cmp]
												oResult[aX3Cmp[nX3Cmp]]:= Alltrim(UPPER(FwNoAccent(EncodeUTF8(&cMemo,"cp1252"))))
											EndIf
										Else
											If SubStr(cAPIFUNC,1,3)+"_" $ aX3Cmp[nX3Cmp]
												cMemo := cAPIFUNC+"->"+aX3Cmp[nX3Cmp]
												oResult[aX3Cmp[nX3Cmp]]:= Alltrim(UPPER(FwNoAccent(EncodeUTF8(&cMemo,"cp1252"))))
											EndIf
										EndIf
									EndIf
								Next nX3Cmp
								
								If !Empty(cAPIMEMOFIELD)
									aX3MemoCmp := StrToKarr(cAPIMEMOFIELD,",")
									For nX3Cmp:= 1 to Len(aX3MemoCmp)
										dbselectArea(cAPIFUNC)
										dbgoto(SOLAPIOS->IDRECTOTVS)
										//-- Especifico para tabela TQB/TUM/TUR - SIGAMNT
										If cAPIFUNC $ "TQB/TUM/TUR"
											cMemo := MNT280REL(aX3MemoCmp[nX3Cmp])
											oResult[aX3MemoCmp[nX3Cmp]]:= Alltrim(UPPER(FwNoAccent(cMemo)))
										Else
											cMemo := cAPIFUNC+"->"+aX3Cmp[nX3Cmp]
											oResult[aX3Cmp[nX3Cmp]]:= Alltrim(UPPER(FwNoAccent(EncodeUTF8(&cMemo,"cp1252"))))
										EndIf
									Next nX3Cmp  
								EndIf
								aAdd(oJsRet[cAPIFUNC],oResult)
							EndIf
						Else
							nNegCount++
						EndIf
                        SOLAPIOS->(dbSkip())
                    End
                    oJsRet["HASNEXT"] := Iif(nCount == (nPage * nPageSize) .And. SOLAPIOS->(!Eof()),.T.,.F.)

                    //-- Total de Registros
                    cQry := cCountQry
                    cQry := ChangeQuery(cQry)
                                                             
                    If Select("SOLAPIOS") > 0
                       Dbselectarea("SOLAPIOS")
                       SOLAPIOS->(DbClosearea())
                    EndIf
                                                                
                    TcQuery cQry New Alias "SOLAPIOS"
                    SOLAPIOS->(dbGoTop())
                    If SOLAPIOS->(!Eof())
                        oJsRet["ALLRECORDS"] := SOLAPIOS->ALLREC - nNegCount
                    EndIf
                Else
                    oResult := JsonObject():new()
                    oResult["DETAILS"] := EncodeUTF8("Sem informações","cp1252")
                    oJsRet[cAPIFUNC] := {}
                    aAdd(oJsRet[cAPIFUNC],oResult)
                EndIf
            EndIf 
            SOLAPIOS->(DbClosearea())
            cJsRet:= FWJsonSerialize(oJsRet,.T.,.T.)
            Self:SetResponse(cJsRet)
            FreeObj(oJsRet)
        Else
            nStatRet := Val(cCode)
            oResult["CODE"] := cAPIFUNC
            oResult["MESSAGE"] := EncodeUTF8(cMessage,"cp1252") //--MESSAGE
            oResult["DETAILS"] := EncodeUTF8(cDetails,"cp1252") //--DETAILS
            oJsRet["status"]   := {}
            aAdd(oJsRet["status"],oResult)
            cJsRet:= FWJsonSerialize(oResult,.T.,.T.)
            Self:SetStatus(nStatRet) 
            Self:SetResponse(cJsRet)
            FreeObj(oJsRet)
        EndIf

        If !Empty(cTenantId)
            RpcClearEnv()
        EndIf

    ElseIf !Empty(cExecRot) //- Post normal

        //-- Preparação de ambiente quando informado empresa/filial
        If !Empty(cTenantId)
            aLoadEmpFil := StrToKarr(cTenantId,",")
            RPCSetType(3) 
            RPCSetEnv( aLoadEmpFil[1], aLoadEmpFil[2],/*cEnvUser*/,/*cEnvPass*/,/*cEnvMod*/,/*cFunName*/,/*aTables*/,.F.,.F.,.T.,.F. )
        EndIf

        Self:SetContentType("application/json")
        oJsRet  := JsonObject():new()
        oResult := JsonObject():new()
        oJsPost := JsonObject():new()
        
        cErrJsPost := oJsPost:fromJson(cJsPost)

        //-- [Ini] Validações
        If cExecRot <> "TSTCON" 
            If !(cExecRot $ Alltrim(cPostAcess)) //-- Rotinas liberadas para processamento
                cCode:= "401"
                cMessage := "Unauthorized"
                cDetails := "Erro na solicitacao, PROCINFO ["+cExecRot+"] não liberado, por favor entrar em contato com o administrador!"
                lRet := .F.
            else
                VarInfo("[SOLAPIOS"+APIVERSAO+"]["+cExecRot+"]  "+Time(),cJsPost)
                lRet := .T.
            EndIf
        Else
            cCode:= "202"
            cMessage := "Accepted"
            cDetails  := "Conexão realizada com sucesso"
            lRet := .F.
        EndIf

        If !Empty(cErrJsPost) .And. lRet
            cCode:= "400"
            cMessage := "Bad Request"
            cDetails := "JSON PARSE ERROR [body] "+cErrJsPost
            lRet := .F.
        ElseIf !('OPERATION' $ cJsPost)
            cCode:= "400"
            cMessage := "Bad Request"
            cDetails := "Tag 'OPERATION' é obrigatória"
            lRet := .F.
        ElseIf !(Alltrim(Str(oJsPost:GetJSonObject('OPERATION'))) $ "3/4/5/6")
            cCode:= "400"
            cMessage := "Bad Request"
            cDetails := "Tag 'OPERATION' inválida"
            lRet := .F.
        EndIf
        //-- [Fim] Validações
        
        If lRet
			VarInfo("[SOLAPIOS"+APIVERSAO+"][OBJ-REC]  "+Time(),oJsPost)
            If cExecRot == "MNTA280"
                // Execauto em https://tdn.totvs.com/pages/releaseview.action?pageId=73894516
                // Acessado em Set/2025
                // Só operação '3' está em execauto
                nOperacao:= oJsPost:GetJSonObject('OPERATION')
                If nOperacao == 3//-- Inclusão
                    cAlias  := "TQB" //-- Tabela principal para a regra de preenchimento de serviço
                    aSolic  := {}
                    aX3Struct := oJsPost:GetNames()
                    For nX3Cmp := 1 To Len(aX3Struct)
                        If "TQB_" $ aX3Struct[nX3Cmp]
                            If GetSX3Cache(aX3Struct[nX3Cmp], "X3_CONTEXT") != "V"
                                If oJsPost:GetJSonObject(aX3Struct[nX3Cmp]) <> Nil
									If FWSX3Util():GetFieldType(aX3Struct[nX3Cmp]) == "C"
										aAdd( aSolic,{aX3Struct[nX3Cmp],Alltrim(UPPER(FwNoAccent(DecodeUTF8(oJsPost:GetJSonObject(aX3Struct[nX3Cmp]),"cp1252")))),Nil} )
									// Ricardo Yamashiro
									// 13/11/2025
									// Tratativa para campos do tipo data
						            ElseIf GetSX3Cache(aX3Struct[nX3Cmp],"X3_TIPO") == 'D'  
		                                If oJsPost:GetJSonObject(aX3Struct[nX3Cmp]) <> Nil
		                                   aAdd( aSolic,{aX3Struct[nX3Cmp],StoD(StrTran(SUBSTR(oJsPost:GetJSonObject(aX3Struct[nX3Cmp]),1,10),"-","")),Nil} )
						                endif
									Else
                                    	aAdd( aSolic,{aX3Struct[nX3Cmp],oJsPost:GetJSonObject(aX3Struct[nX3Cmp]),Nil} )
									EndIf
                                EndIf
                            ElseIf GetSX3Cache(aX3Struct[nX3Cmp],"X3_TIPO") == 'M' //-- Há campos Virtuais e do tipo memo para o MNTA280 que sua referencia SYP (MEMO ANTIGO)
                                If oJsPost:GetJSonObject(aX3Struct[nX3Cmp]) <> Nil
                                    aAdd( aSolic,{aX3Struct[nX3Cmp],DecodeUTF8(oJsPost:GetJSonObject(aX3Struct[nX3Cmp]), "cp1252"),Nil} )
                                EndIf
                            EndIf
                        EndIf
                    Next nX3Cmp
					
                    /* Orderna arrays conforme dicionários */
                    aSolic := FWVetByDic( aSolic , cAlias )
                    MSExecAuto( {|x,z,y,w| MNTA280(x,z,y,w)},,,aSolic,nOperacao)
                ElseIf nOperacao == 4 .Or. nOperacao == 5 //-- Alteração / Exclusão
                    //-- Baseado em MNTA280.PRW
                    cChave := oJsPost:GetJSonObject("TQB_SOLICI" )
                    If !Empty(cChave)
                        dbselectArea("TQB")
                        TQB->(dbSetOrder(1))
                        If TQB->(dbSeek(xFilial("TQB") + cChave))
                            //If TQB->TQB_SOLUCA == "A" //.and. FindFunction("MNT298AUT")
                                Begin Transaction
                                    RecLock("TQB",.F.)
                                    If  nOperacao == 4 
                                        aX3Struct := oJsPost:GetNames()
                                        For nX3Cmp := 1 To Len(aX3Struct)
                                            If "TQB_" $ aX3Struct[nX3Cmp]
                                                If GetSX3Cache(aX3Struct[nX3Cmp], "X3_CONTEXT") != "V"
                                                    If oJsPost:GetJSonObject(aX3Struct[nX3Cmp]) <> Nil .And. !(aX3Struct[nX3Cmp] $ "TQB_SOLICI/TQB_FILIAL")
                                                        //aAdd( aSolic,{aX3Struct[nX3Cmp],oJsPost:GetJSonObject(aX3Struct[nX3Cmp]),Nil} )
                                                        If GetSX3Cache(aX3Struct[nX3Cmp],"X3_TIPO") $ 'C#M'
															TQB->&(aX3Struct[nX3Cmp]) := DecodeUTF8(oJsPost:GetJSonObject(aX3Struct[nX3Cmp]), "cp1252")
														ElseIf GetSX3Cache(aX3Struct[nX3Cmp],"X3_TIPO") $ 'D#'
															TQB->&(aX3Struct[nX3Cmp]) :=StoD(StrTran(oJsPost:GetJSonObject(aX3Struct[nX3Cmp]),"-",""))
														Else
															TQB->&(aX3Struct[nX3Cmp]) := oJsPost:GetJSonObject(aX3Struct[nX3Cmp])
														EndIf
                                                    EndIf
                                                ElseIf GetSX3Cache(aX3Struct[nX3Cmp],"X3_TIPO") == 'M' //-- Há campos Virtuais e do tipo memo para o MNTA280 que sua referencia SYP (MEMO ANTIGO)
                                                    If oJsPost:GetJSonObject(aX3Struct[nX3Cmp]) <> Nil
														cDecMemo := DecodeUTF8(oJsPost:GetJSonObject(aX3Struct[nX3Cmp]), "cp1252")
                                                        If (Alltrim(aX3Struct[nX3Cmp]) $ "TQB_DESCSS")
                                                            MSMM( TQB->TQB_CODMSS,,,cDecMemo,1,,, "TQB", "TQB_CODMSS" )
                                                        EndIf
                                                    EndIf
                                                EndIf
                                            EndIf
                                        Next nX3Cmp
                                        MNT280GFU(cChave,'02',,,,,,,/*cCodFun*/,/*cCodFilAte*/)
                                    ElseIf nOperacao == 5 
                                        TQB->TQB_SOLUCA := "C"
                                        TQB->(dbDelete())
                                        MNT280GFU(cChave,'03',,,,,,,/*cCodFun*/,/*cCodFilAte*/)
                                    EndIf
                                    TQB->(MsUnlock())
                                End Transaction
                            //Else
                            //    lMsErroAuto := .T.
                            //    cErroProc   := "Erro, a Solicitação "+cChave+" já não está mais em analise!"
                            //EndIf
                        Else
                            lMsErroAuto := .T.
                            cErroProc   := "Erro, a Solicitação "+cChave+" não foi localizada!"
                        EndIf
                    //Else
                    //    lMsErroAuto := .T.
                    //    cErroProc   := "Erro na solicitacao, Campo TQB_SOLICI é obrigatório para a operação"
                    EndIf
                EndIf
                If lMsErroAuto
                    If nOperacao == 3
                        lRet := .F.
                        cCode:= "400"
                        cMessage := "Bad Request"
                        cArqLog  := "MNTA280EXEC_"+DTOS(DATE())+"_"+Left(Time(),2)+SubStr(Time(),4,2)+".LOG"
                        cDetails := MostraErro(GetSrvProfString("Startpath", ""), cArqLog)
                        FErase(GetSrvProfString("Startpath", "")+cArqLog)
                    Else 
                        lRet := .F.
                        cCode:= "400"
                        cMessage := "Bad Request"
                        cDetails := cErroProc
                    EndIf
                Else
                    lRet := .T.
                    cCode:= "200"
					If !Empty(cChave)
						cMessage := "TQB_SOLICI:"+Alltrim(TQB->TQB_SOLICI)
						cField:= "TQB_SOLICI"
						cFieldInfo:= Alltrim(TQB->TQB_SOLICI)
					Endif
                    cDetails := "Processamento efetuado com sucesso!"
                Endif
                
            ElseIf cExecRot == "MNTA420" // Programa para OS corretivas 
                //-- Preparação de informações
                nOperacao:= oJsPost:GetJSonObject('OPERATION')

                If nOperacao == 3 .Or. nOperacao == 4 .Or. nOperacao == 5 .Or. nOperacao == 6
					lRet := .T.
					If nOperacao == 6
						Begin Transaction
							cCodOS	  := oJsPost:STJ:GetJSonObject("TJ_ORDEM") //jBody["STJ"]["TJ_ORDEM"]
                            If Type("cCodOS") == "U"
                                cCodOS := ""
                            EndIf 
							dbSelectArea("STJ")
							If STJ->(FieldPos("TJ_XCARD")) > 0
								STJ->(dbSetOrder(1))
								If STJ->(dbSeek( xFilial("STJ")+cCodOS ))
									cSTJPLN := STJ->TJ_PLANO
									RecLock( "STJ",.F.)
										STJ->TJ_XCARD := oJsPost:STJ:GetJSonObject("TJ_XCARD")
										If oJsPost:STJ:GetJSonObject("TJ_SITUACA") <> Nil
											If STJ->TJ_SITUACA <> 'L' 
												If oJsPost:STJ:GetJSonObject("TJ_SITUACA") == 'L'
													STJ->TJ_SITUACA := "L"
												EndIf
											EndIf
										EndIf
										If oJsPost:STJ:GetJSonObject("TJ_DTPRINI") <> Nil
											//If Empty(STJ->TJ_DTPRINI)
												STJ->TJ_DTPRINI := StoD(StrTran(oJsPost:STJ:GetJSonObject("TJ_DTPRINI"),"-",""))
											//EndIf
										Else
											If Empty(STJ->TJ_DTPRINI)
												STJ->TJ_DTPRINI := dDatabase
											EndIf	
										EndIf
										If oJsPost:STJ:GetJSonObject("TJ_HOPRINI") <> Nil
											//If Empty(STJ->TJ_HOPRINI)
												STJ->TJ_HOPRINI := oJsPost:STJ:GetJSonObject("TJ_HOPRINI")
											//EndIf
										Else
											If Empty(STJ->TJ_HOPRINI)
												STJ->TJ_HOPRINI := Time()
											EndIf
										EndIf
										If oJsPost:STJ:GetJSonObject("TJ_DTPRFIM") <> Nil
											//If Empty(STJ->TJ_DTPRFIM)
												STJ->TJ_DTPRFIM := StoD(StrTran(oJsPost:STJ:GetJSonObject("TJ_DTPRFIM"),"-",""))
											//EndIf
										Else
											If Empty(STJ->TJ_DTPRFIM)
												STJ->TJ_DTPRFIM := dDatabase
											EndIf	
										EndIf
										If oJsPost:STJ:GetJSonObject("TJ_HOPRFIM") <> Nil
											//If Empty(STJ->TJ_HOPRFIM)
												STJ->TJ_HOPRFIM := oJsPost:STJ:GetJSonObject("TJ_HOPRFIM")
											//EndIf
										EndIf
										If oJsPost:STJ:GetJSonObject("TJ_HOMPINI") <> Nil
											//If Empty(STJ->TJ_HOMPINI)
												STJ->TJ_HOMPINI := oJsPost:STJ:GetJSonObject("TJ_HOMPINI")
											//EndIf
										EndIf
									STJ->( MsUnlock() )	
								EndIf
							EndIf
							//oxCabec := oJsPost:GetJSonObject("STJ") //jBody["STJ"]
							axItens	:= oJsPost:GetJSonObject("STL") //jBody["STL"]
							cChave  := ""
							aMATA105Cab := {}
							aMATA105Inc := {}
							nMATA105Opc  := 0
							//Varinfo("axItens",axItens)
							If lUnicReq
								dbSelectArea("STJ")
								//-- Valida se todos os produtos são diferentes
								cValidPrd105 := ""
								lValidPrd105 := .T.
								For nX := 1 to Len(axItens)
									If Alltrim(axItens[nX]["TL_TIPOREG"]) == "P"
										If !(Alltrim(axItens[nX]["TL_CODIGO"]) $ cValidPrd105)
											cValidPrd105 += Alltrim(axItens[nX]["TL_CODIGO"])+"#"
										Else
											If axItens[nX]["IDRECTOTVS"] == 0
												lValidPrd105 := .F.
												Exit
											EndIf
										EndIf
									EndIf
								Next nX

								If lValidPrd105
									
									For nX := 1 to Len(axItens)
										nRecnSTL := axItens[nX]["IDRECTOTVS"]
										aMATA105ECab := {}
										aMATA105Exc  := {}
										nMATA105Opc  := 0
										
										If axItens[nX]["DEL"] == "T"
											STL->(dbGoto(nRecnSTL))  
											If Alltrim(axItens[nX]["TL_TIPOREG"]) == "P"
												cMATA105Num := RetInfCp("CP_OP#CP_PRODUTO",cCodOS+"OS001#"+Alltrim(STL->TL_CODIGO),"CP_NUM")
												If RetInfCp("CP_OP#CP_PRODUTO",cCodOS+"OS001#"+Alltrim(STL->TL_CODIGO),"CP_QUJE") == 0 .And. !Empty(cMATA105Num)										
													nMATA105Opc := 5
													Aadd( aMATA105ECab, { "CP_NUM"     ,cMATA105Num , Nil })
													Aadd( aMATA105ECab, { "CP_EMISSAO" ,dDataBase , Nil })
													
													Aadd( aMATA105Exc, {} )
													Aadd( aMATA105Exc[ Len( aMATA105Exc ) ],{"CP_ITEM"   ,RetInfCp("CP_OP#CP_PRODUTO",cCodOS+"OS001#"+Alltrim(STL->TL_CODIGO),"CP_ITEM")  , Nil } )
													Aadd( aMATA105Exc[ Len( aMATA105Exc ) ],{"CP_PRODUTO",Alltrim(STL->TL_CODIGO)   , Nil } )
													Aadd( aMATA105Exc[ Len( aMATA105Exc ) ],{"CP_QUANT"  ,STL->TL_QUANTID  , Nil } )

													SB1->( dbSetOrder( 1 ) )
													SCP->( dbSetOrder( 1 ) )
													//Varinfo("EXC-aMATA105ECab",aMATA105ECab)
													//Varinfo("EXC- aMATA105Exc",aMATA105Exc)
													//Varinfo("EXC-cMATA105Num",cMATA105Num)
													//Varinfo("EXC-nMATA105Opc",nMATA105Opc)
													lMsErroAuto := .F.
													MsExecAuto( { | x, y, z | Mata105( x, y , z ) }, aMATA105ECab, aMATA105Exc , nMATA105Opc )
													If lMsErroAuto
														lRet := .F.
														cCode:= "400"
														cMessage := "Bad Request"
														cArqLog  := "MATA105EXEC_"+DTOS(DATE())+"_"+Left(Time(),2)+SubStr(Time(),4,2)+".LOG"
														cDetails := MostraErro(GetSrvProfString("Startpath", ""), cArqLog)
														FErase(GetSrvProfString("Startpath", "")+cArqLog)
														DisarmTransaction()
														exit
													EndIf
													cMATA105Num := ""
												ElseIf !Empty(cMATA105Num)
													lRet := .F.
													aMATA105Cab:={}
													cCode:= "400"
													cMessage := "Bad Request"
													cDetails := "1-Requisição do produto "+Alltrim(STL->TL_CODIGO)+" ao almoxarifado totalmente ou parcialmente atendida. Deve-se estornar este movimento para que seja possível a exclusão da OS."
													DisarmTransaction()
													exit
												EndIf
											EndIf
											RecLock("STL", .F.)
											dbDelete()
											STL->(MsUnlock())
										Else
											If nRecnSTL > 0
												STL->(dbGoto(nRecnSTL))  
												If Alltrim(axItens[nX]["TL_TIPOREG"]) == "P" .And. !(Alltrim(axItens[nX]["TL_CODIGO"]) $ cValidPrd105)
													cValidPrd105 += Alltrim(STL->TL_CODIGO)+"#"
													cMATA105Num := RetInfCp("CP_OP#CP_PRODUTO",cCodOS+"OS001#"+Alltrim(STL->TL_CODIGO),"CP_NUM")
													If RetInfCp("CP_OP#CP_PRODUTO",cCodOS+"OS001#"+Alltrim(axItens[nX]["TL_CODIGO"]),"CP_QUJE") == 0  .And. !Empty(cMATA105Num)								
														nMATA105Opc := 5
														Aadd( aMATA105ECab, { "CP_NUM"     ,cMATA105Num , Nil })
														Aadd( aMATA105ECab, { "CP_EMISSAO" ,dDataBase , Nil })
														
														Aadd( aMATA105Exc, {} )
														Aadd( aMATA105Exc[ Len( aMATA105Exc ) ],{"CP_ITEM"   ,RetInfCp("CP_OP#CP_PRODUTO",cCodOS+"OS001#"+Alltrim(STL->TL_CODIGO),"CP_ITEM")  , Nil } )
														Aadd( aMATA105Exc[ Len( aMATA105Exc ) ],{"CP_PRODUTO",Alltrim(STL->TL_CODIGO)   , Nil } )
														Aadd( aMATA105Exc[ Len( aMATA105Exc ) ],{"CP_QUANT"  ,STL->TL_QUANTID  , Nil } )

														SB1->( dbSetOrder( 1 ) )
														SCP->( dbSetOrder( 1 ) )
														MsExecAuto( { | x, y, z | Mata105( x, y , z ) }, aMATA105ECab, aMATA105Exc , nMATA105Opc )
														If lMsErroAuto
															lRet := .F.
															cCode:= "400"
															cMessage := "Bad Request"
															cArqLog  := "MATA105EXEC_"+DTOS(DATE())+"_"+Left(Time(),2)+SubStr(Time(),4,2)+".LOG"
															cDetails := MostraErro(GetSrvProfString("Startpath", ""), cArqLog)
															FErase(GetSrvProfString("Startpath", "")+cArqLog)
															DisarmTransaction()
															exit
														EndIf
														cMATA105Num := ""
													Elseif !Empty(cMATA105Num)		
														lRet := .F.
														cCode:= "400"
														cMessage := "Bad Request"
														cDetails := "2-Requisição do produto "+Alltrim(axItens[nX]["TL_CODIGO"])+" ao almoxarifado totalmente ou parcialmente atendida. Deve-se estornar este movimento para que seja possível a alteração da OS."
														DisarmTransaction()
														aMATA105Cab:={}
														exit
													EndIf
												EndIf
												RecLock("STL",.F.)
												STL->TL_TAREFA   := axItens[nX]["TL_TAREFA"]
												cChave += Alltrim(Str(nRecnSTL))+"#"
											Else
												RecLock("STL",.T.)
												STL->TL_FILIAL := xFilial("STL")
												STL->TL_ORDEM  := cCodOS
												STL->TL_PLANO  := cSTJPLN
												STL->TL_TAREFA := "0     "
												If Alltrim(axItens[nX]["TL_TIPOREG"]) == "P"
													cMATA105Num  := ""
												EndIf
												STL->TL_SEQTARE := RetTLSQTAR(xFilial("STL"),cCodOS,cSTJPLN,axItens[nX]["TL_TIPOREG"],axItens[nX]["TL_CODIGO"]) //-- Retorna o campo TL_SEQTARE
											EndIf
											If STL->TL_SEQRELA == "0"
												STL->TL_TIPOREG  := axItens[nX]["TL_TIPOREG"]
												STL->TL_CODIGO   := axItens[nX]["TL_CODIGO"]
												STL->TL_QUANTID  := axItens[nX]["TL_QUANTID"]
												STL->TL_DTINICI  := StoD(StrTran(axItens[nX]["TL_DTINICI"],"-",""))
												STL->TL_HOINICI  := axItens[nX]["TL_HOINICI"]
												STL->TL_DTFIM    := StoD(StrTran(axItens[nX]["TL_DTFIM"],"-",""))
												STL->TL_HOFIM    := axItens[nX]["TL_HOFIM"]
												STL->TL_SEQRELA := axItens[nX]["TL_SEQRELA"] //Alltrim(Str(nX))
												STL->TL_OBSERVA := Alltrim(UPPER(FwNoAccent(EncodeUTF8(axItens[nX]["TL_OBSERVA"]),"cp1252")))

												If Alltrim(axItens[nX]["TL_TIPOREG"]) == "P"
													STL->TL_DESTINO  := axItens[nX]["TL_DESTINO"]
													STL->TL_UNIDADE  := Posicione("SB1",1,xFilial("SB1")+axItens[nX]["TL_CODIGO"],"B1_UM")
													STL->TL_LOCAL    := SB1->B1_LOCPAD

													If !Empty(cMATA105Num) .And. Empty(aMATA105Cab)
														Aadd( aMATA105Cab, { "CP_NUM",cMATA105Num, Nil })
														Aadd( aMATA105Cab, { "CP_EMISSAO" ,dDataBase , Nil })
													ElseIf Empty(aMATA105Cab)
														Aadd( aMATA105Cab, { "CP_NUM",GetSx8Num('SCP', 'CP_NUM') , Nil })
														Aadd( aMATA105Cab, { "CP_EMISSAO" ,dDataBase , Nil })
													EndIf
													Aadd( aMATA105Inc, {} )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_ITEM"   , StrZero(Len( aMATA105Inc ),2) , Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_PRODUTO", axItens[nX]["TL_CODIGO"] , Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_OP"     , cCodOS+"OS001", Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_CC"     , Posicione("STJ",1,xFilial("STJ")+cCodOS,"TJ_CCUSTO") , Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_QUANT"  , axItens[nX]["TL_QUANTID"] , Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_USER"   , Posicione("TQB",4,xFilial("TQB")+cCodOS,"TQB_CDSOLI") , Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_ZZNOME" , Posicione("TQB",4,xFilial("TQB")+cCodOS,"TQB_USUARI") , Nil } )
												Else
													STL->TL_UNIDADE  := "H"
													STL->TL_USACALE  := "S"
													cSH7COD := Posicione("ST1",1,xFilial("ST1")+axItens[nX]["TL_CODIGO"],"T1_TURNO")
													nSemana := Dow(StoD(StrTran(axItens[nX]["TL_DTINICI"],"-",""))) - 1
													If Dow(StoD(StrTran(axItens[nX]["TL_DTINICI"],"-",""))) == 1 
														nSemana := 7 //-- Domingo
													EndIf	
													aTempos:= aClone(APIcalend(cSH7COD))
													If !Empty(aTempos) .Or. nSemana == 0
														If aTempos[nSemana,3] <> "00:00"
															If Val(SubStr(axItens[nX]["TL_HOINICI"],1, 2)) < Val(SubStr(aTempos[nSemana,1],1, 2)) //.OR. ;
															// Val(SubStr(axItens[nX]["TL_HOFIM"],1, 2)) > Val(SubStr(aTempos[nSemana,2],1, 2))
																If axItens[nX]["DEL"] <> "T"
																	lRet := .F.
																	cCode:= "400"
																	cMessage := "Bad Request"
																	cDetails := "NAO CONFORMIDADE, Horario invalido para o calendário/dia "+DtoC(StoD(StrTran(axItens[nX]["TL_DTINICI"],"-","")))+" do recurso ("+axItens[nX]["TL_CODIGO"]+") "+aTempos[nSemana,1]+" - "+aTempos[nSemana,2]
																	DisarmTransaction()
																	exit
																EndIf
															EndIf
														Else
															If axItens[nX]["DEL"] <> "T"
																lRet := .F.
																cCode:= "400"
																cMessage := "Bad Request"
																cDetails := "NAO CONFORMIDADE, Horario invalido para o calendário/dia "+DtoC(StoD(StrTran(axItens[nX]["TL_DTINICI"],"-","")))+" do recurso ("+axItens[nX]["TL_CODIGO"]+")) "+aTempos[nSemana,1]+" - "+aTempos[nSemana,2]
																DisarmTransaction()
																exit
															EndIf
														EndIf
													Else
														//Varinfo("nSemana",nSemana)
														//Varinfo("aTempos",aTempos)
														//Varinfo("cSH7COD",cSH7COD)
														//Varinfo("TL_DTINICI",StoD(StrTran(axItens[nX]["TL_DTINICI"],"-","")))
														If axItens[nX]["DEL"] <> "T"
															lRet := .F.
															cCode:= "400"
															cMessage := "Bad Request"
															cDetails := "NAO CONFORMIDADE, verifique o cadastro do recurso ("+axItens[nX]["TL_CODIGO"]+") e seu turno) "
															DisarmTransaction()
															exit
														EndIf
													EndIf
												EndIf
											EndIf
											STL->(MsUnlock())
										EndIf
										
									Next nX
									lMsErroAuto := .F.
									//Varinfo("aMATA105Cab",aMATA105Cab)
									//Varinfo("aMATA105Inc",aMATA105Inc)
									//Varinfo("cMATA105Num",cMATA105Num)
									//Varinfo("nMATA105Opc",nMATA105Opc)
									If !Empty(aMATA105Cab) //-- se tiver produtos a serem processados
										If Empty(cMATA105Num)
											nMATA105Opc := 3
										Else
											nMATA105Opc := 4
										Endif
										MsExecAuto( { | x, y, z | Mata105( x, y , z ) }, aMATA105Cab, aMATA105Inc , nMATA105Opc )
										If lMsErroAuto
											lRet := .F.
											cCode:= "400"
											cMessage := "Bad Request"
											cArqLog  := "MATA150EXEC_"+DTOS(DATE())+"_"+Left(Time(),2)+SubStr(Time(),4,2)+".LOG"
											cDetails := MostraErro(GetSrvProfString("Startpath", ""), cArqLog)
											FErase(GetSrvProfString("Startpath", "")+cArqLog)
											DisarmTransaction()
										Else
											ConfirmSx8()
										EndIf
									EndIf
									If lRet
										cCode:= "200"
										cField:= "TJ_ORDEM"
										cFieldInfo:= Alltrim(cCodOS)
										cMessage := "TJ_ORDEM:"+Alltrim(cCodOS)
										cDetails := "Processamento efetuado com sucesso!"							
										//-- Grava TJ_XCARD
										dbSelectArea("STJ")
										If STJ->(FieldPos("TJ_XCARD")) > 0
											STJ->(dbSetOrder(1))
											If STJ->(dbSeek( xFilial("STJ")+cCodOS ))
												RecLock( "STJ",.F.)
												STJ->TJ_XCARD := oJsPost:STJ:GetJSonObject("TJ_XCARD")
												STJ->( MsUnlock() )
											EndIf
										EndIf
									EndIf
								Else
									lRet := .F.
									cCode:= "400"
									cMessage := "Bad Request"
									cDetails := "Requisição inválida: o mesmo código de produto não pode aparecer em múltiplas linhas. Agrupe as quantidades em uma única entrada"
									DisarmTransaction()
								EndIf
							Else
								For nX := 1 to Len(axItens)
									If Alltrim(axItens[nX]["TL_TIPOREG"]) == "P"
										If !(Alltrim(axItens[nX]["TL_CODIGO"]) $ cValidPrd105)
											cValidPrd105 += Alltrim(axItens[nX]["TL_CODIGO"])+"#"
										Else
											If axItens[nX]["IDRECTOTVS"] == 0
												lValidPrd105 := .F.
												Exit
											EndIf
										EndIf
									EndIf
								Next nX

								If lValidPrd105
									cValidPrd105:= ""
									For nX := 1 to Len(axItens) 
										nRecnSTL := axItens[nX]["IDRECTOTVS"]
										aMATA105Cab := {}
										aMATA105Inc := {}
										nMATA105Opc := 0
										//--Tratativas ao Armazém
										If Alltrim(axItens[nX]["TL_TIPOREG"]) == "P" .And. !(Alltrim(axItens[nX]["TL_CODIGO"]) $ cValidPrd105)
											If nRecnSTL == 0
												cMATA105Num := RetInfCp("CP_OP",cCodOS+"OS001","CP_NUM")
												cValidPrd105 += Alltrim(STL->TL_CODIGO)+"#"
												If Empty(cMATA105Num)
													nMATA105Opc := 3
													Aadd( aMATA105Cab, { "CP_NUM",GetSx8Num('SCP', 'CP_NUM') , Nil })
													Aadd( aMATA105Cab, { "CP_EMISSAO" ,dDataBase , Nil })

													Aadd( aMATA105Inc, {} )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_ITEM"   , StrZero(Len( aMATA105Inc ),2) , Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_PRODUTO", axItens[nX]["TL_CODIGO"] , Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_OP"     , cCodOS+"OS001", Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_CC"     , Posicione("STJ",1,xFilial("STJ")+cCodOS,"TJ_CCUSTO") , Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_QUANT"  , axItens[nX]["TL_QUANTID"] , Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_DATPRF" , dDataBase, Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_USER"   , Posicione("TQB",4,xFilial("TQB")+cCodOS,"TQB_CDSOLI") , Nil } )
													//Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_ZZNOME" , Posicione("TQB",4,xFilial("TQB")+cCodOS,"TQB_USUARI") , Nil } )
													dbSelectArea("SC2")
													dbSetOrder(1) //C2_FILIAL+C2_NUM+C2_ITEM
													If !dbSeek( xFilial("SC2") + cCodOS + "OS" )
														//dbSelectArea("STJ")
														//STJ->(dbSetOrder(1))
														//If STJ->(dbSeek( xFilial("STJ")+cCodOS ))
															//If STJ->TJ_SITUACA <> 'L'
															//	RecLock( "STJ",.F.)
															//		STJ->TJ_SITUACA := 'L'
															//	STJ->( MsUnlock() )	
															//EndIf
															//---------------------------------------------------
															//Gera ordem de Producao para a OS
															//---------------------------------------------------
															cUsaIntPc := AllTrim(GetMV("MV_NGMNTPC"))
															//Conout("Verifica se deve gerar O.P...")
															If cUsaIntPc == "S"
																//Irá verificar apenas o primeiro Produto Manutenção do parâmetro
																cCODPRO := If(FindFunction("NGProdMNT"), NGProdMNT("M")[1], GetMv("MV_PRODMNT"))
																dDataIni := MNT420DTOP(STJ->TJ_DTORIGI)
																dDataFim := MNT420DTOP(STJ->TJ_DTORIGI)
																// Busca o C.C. do bem na TPN ou utiliza o C.C. da ordem de serviço quando seja do tipo localização.
																cCusto := "" //IIf( STJ->TJ_TIPOOS == 'B', NGFilTPN( STJ->TJ_CODBEM, STJ->TJ_DTORIGI, SubStr( Time(), 1, 5 ), , xFilial( 'ST9' ) )[2],;
																			//STJ->TJ_CCUSTO )
																// fGERAOPNEW(cPROD,nQTD,cOS,dINI,dFIM,cVLOC,cFil,cCusto,cObs,nOpc,lRetArray)
																//aTypeRet := { .F. , cError }
																Conout("O.P. Gerando...")
																If !fGERAOPNEW(cCODPRO,1,cCodOS,dDataIni,dDataFim,,,cCusto,"PLANO "+Alltrim(STJ->TJ_PLANO))
																	lRet := .F.
																	cCode:= "400"
																	cMessage := "Bad Request"
																	cDetails := "O.P. não gerada, verificar."
																Else
																	Conout("O.P. Geranda")
																EndIf
															//Else
																//Conout("MV_NGMNTPC="+cUsaIntPc)
															EndIf
														//EndIf
													Else
														Conout("O.P. Encontrada:"+SC2->C2_NUM+SC2->C2_ITEM)
													EndIf
												Else 
													nMATA105Opc := 4
													Aadd( aMATA105Cab, { "CP_NUM" ,cMATA105Num , Nil })
													Aadd( aMATA105Cab, { "CP_EMISSAO" ,dDataBase , Nil })
													SCP->(dbSelectArea("SCP"))
													SCP->(dbSetOrder(1))
													If SCP->(dbSeek(xFilial("SCP")+cMATA105Num))
														nItCP := 0
														While SCP->(! Eof()) .And. SCP->(CP_FILIAL+CP_NUM) == xFilial("SCP")+cMATA105Num
															nItCP++
															If RetInfCp("CP_OP#CP_PRODUTO",cCodOS+"OS001#"+Alltrim(SCP->CP_PRODUTO),"CP_QUJE") == 0 
																Aadd( aMATA105Inc, {} )
																Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_ITEM"   ,StrZero(nItCP,2)    , Nil } )
																Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_PRODUTO",Posicione("SB1",1,xFilial("SB1")+SCP->CP_PRODUTO,"B1_COD") , Nil } )
																Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_DESCRI" , Posicione("SB1",1,xFilial("SB1")+SCP->CP_PRODUTO,"B1_DESC")  , Nil } )
																Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_OP"     , cCodOS+"OS001", Nil } )
																If axItens[nX]["TL_CODIGO"] == Alltrim(SCP->CP_PRODUTO)
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_QUANT",axItens[nX]["TL_QUANTID"]  , Nil } )
																Else
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_QUANT",SCP->CP_QUANT  , Nil } )
																EndIf
																Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_DATPRF", dDataBase, Nil } )
																If !Empty(SCP->CP_CC)
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_CC",SCP->CP_CC, Nil } )
																Else
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_CC", Posicione("STJ",1,xFilial("STJ")+cCodOS,"TJ_CCUSTO") , Nil } )
																EndIf
																If !Empty(SCP->CP_CONTA)
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_CONTA",SCP->CP_CONTA, Nil } )
																EndIf
																If !Empty(SCP->CP_USER)
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_USER",SCP->CP_USER, Nil } )
																Else
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_USER"   , Posicione("TQB",4,xFilial("TQB")+cCodOS,"TQB_CDSOLI") , Nil } )
																EndIf
																//If !Empty(SCP->CP_ZZNOME)
																//	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_ZZNOME",SCP->CP_ZZNOME, Nil } )
																//Else
																//	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_ZZNOME" , Posicione("TQB",4,xFilial("TQB")+cCodOS,"TQB_USUARI") , Nil } )
																//EndIf
															ElseIf SCP->CP_QUANT <> axItens[nX]["TL_QUANTID"] .And. Alltrim(STL->TL_CODIGO) == axItens[nX]["TL_CODIGO"]
																lRet := .F.
																aMATA105Cab:={}
																cCode:= "400"
																cMessage := "Bad Request"
																cDetails := "3-Requisição do produto "+Alltrim(STL->TL_CODIGO)+" ao almoxarifado totalmente ou parcialmente atendida. Deve-se estornar este movimento para que seja possível a exclusão da OS."
																DisarmTransaction()
																exit
															EndIf
															SCP->(dbSkip())
														EndDo
													EndIf
													Aadd( aMATA105Inc, {} )
													nItCP++
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_ITEM"   , StrZero(nItCP,2) , Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_PRODUTO", axItens[nX]["TL_CODIGO"] , Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_DESCRI" , Posicione("SB1",1,xFilial("SB1")+Alltrim(axItens[nX]["TL_CODIGO"]),"B1_DESC")  , Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_OP"     , cCodOS+"OS001", Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_CC"     , Posicione("STJ",1,xFilial("STJ")+cCodOS,"TJ_CCUSTO") , Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_QUANT"  , axItens[nX]["TL_QUANTID"] , Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_DATPRF" , dDataBase, Nil } )
													Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_USER"   , Posicione("TQB",4,xFilial("TQB")+cCodOS,"TQB_CDSOLI") , Nil } )
													//Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_ZZNOME" , Posicione("TQB",4,xFilial("TQB")+cCodOS,"TQB_USUARI") , Nil } )
													//Verifica se Gera OP
													//Busca a Sequencia da O.P.
													dbSelectArea("SC2")
													dbSetOrder(1) //C2_FILIAL+C2_NUM+C2_ITEM
													If !dbSeek( xFilial("SC2") + cCodOS + "OS" )
														//dbSelectArea("STJ")
														//STJ->(dbSetOrder(1))
														//If STJ->(dbSeek( xFilial("STJ")+cCodOS ))
															//If STJ->TJ_SITUACA <> 'L'
															//	RecLock( "STJ",.F.)
															//		STJ->TJ_SITUACA := 'L'
															//	STJ->( MsUnlock() )	
															//EndIf
															//---------------------------------------------------
															//Gera ordem de Producao para a OS
															//---------------------------------------------------
															cUsaIntPc := AllTrim(GetMV("MV_NGMNTPC"))
															//Conout("Verifica se deve gerar O.P...")
															If cUsaIntPc == "S"
																//Irá verificar apenas o primeiro Produto Manutenção do parâmetro
																cCODPRO := If(FindFunction("NGProdMNT"), NGProdMNT("M")[1], GetMv("MV_PRODMNT"))
																dDataIni := MNT420DTOP(STJ->TJ_DTORIGI)
																dDataFim := MNT420DTOP(STJ->TJ_DTORIGI)
																// Busca o C.C. do bem na TPN ou utiliza o C.C. da ordem de serviço quando seja do tipo localização.
																cCusto := "" //IIf( STJ->TJ_TIPOOS == 'B', NGFilTPN( STJ->TJ_CODBEM, STJ->TJ_DTORIGI, SubStr( Time(), 1, 5 ), , xFilial( 'ST9' ) )[2],;
																			//STJ->TJ_CCUSTO )
																// fGERAOPNEW(cPROD,nQTD,cOS,dINI,dFIM,cVLOC,cFil,cCusto,cObs,nOpc,lRetArray)
																//aTypeRet := { .F. , cError }
																Conout("O.P. Gerando...")
																If !fGERAOPNEW(cCODPRO,1,cCodOS,dDataIni,dDataFim,,,cCusto,"PLANO "+Alltrim(STJ->TJ_PLANO))
																	lRet := .F.
																	cCode:= "400"
																	cMessage := "Bad Request"
																	cDetails := "O.P. não gerada, verificar."
																Else
																	Conout("O.P. Geranda")
																EndIf
															//Else
																//Conout("MV_NGMNTPC="+cUsaIntPc)
															EndIf
														//EndIf
													//Else
														//Conout("O.P. Encontrada:"+SC2->C2_NUM+SC2->C2_ITEM)
													EndIf
												EndIf
												If lRet
													//SB1->( dbSetOrder( 1 ) )
													//SCP->( dbSetOrder( 1 ) )
													VarInfo('1-aMATA105Cab',aMATA105Cab)
													VarInfo('1-aMATA105Inc',aMATA105Inc)
													VarInfo('1-nMATA105Opc',nMATA105Opc)
													lMsErroAuto := .F.
													MsExecAuto( { | x, y, z | Mata105( x, y , z ) }, aMATA105Cab, aMATA105Inc , nMATA105Opc )
													If lMsErroAuto
														lRet := .F.
														cCode:= "400"
														cMessage := "Bad Request"
														cArqLog  := "MATA150EXEC_"+DTOS(DATE())+"_"+Left(Time(),2)+SubStr(Time(),4,2)+".LOG"
														cDetails := MostraErro(GetSrvProfString("Startpath", ""), cArqLog)
														FErase(GetSrvProfString("Startpath", "")+cArqLog)
														DisarmTransaction()
														Exit
													Else
														If nMATA105Opc == 3
															ConfirmSx8()
														EndIf
													EndIf
												Else
													DisarmTransaction()
													Exit
												EndIf
											Else
												STL->(dbGoto(nRecnSTL))
												cValidPrd105 += Alltrim(STL->TL_CODIGO)+"#"
												If axItens[nX]["DEL"] == "T"
													//-- Analise de Exclusão do item  
													cMATA105Num := RetInfCp("CP_OP#CP_PRODUTO",cCodOS+"OS001#"+Alltrim(STL->TL_CODIGO),"CP_NUM")
													If RetInfCp("CP_OP#CP_PRODUTO",cCodOS+"OS001#"+Alltrim(STL->TL_CODIGO),"CP_QUJE") <> 0 
														lRet := .F.
														cCode:= "400"
														cMessage := "Bad Request"
														cDetails := "4-Requisição do produto "+Alltrim(STL->TL_CODIGO)+" ao almoxarifado totalmente ou parcialmente atendida. Deve-se estornar este movimento para que seja possível a exclusão da OS."
														DisarmTransaction()
														exit
													Else
														nMATA105Opc := 4
														Aadd( aMATA105Cab, { "CP_NUM"     ,cMATA105Num , Nil })
														Aadd( aMATA105Cab, { "CP_EMISSAO" ,dDataBase , Nil })
														dbSelectArea("SCP")
														SCP->(dbSetOrder(1))
														If SCP->(dbSeek(xFilial("SCP")+cMATA105Num))
															nItCP := 0
															While SCP->(! Eof() ) .And. SCP->(CP_FILIAL+CP_NUM) == xFilial("SCP")+cMATA105Num
																nItCP++
																If RetInfCp("CP_OP#CP_PRODUTO",cCodOS+"OS001#"+Alltrim(SCP->CP_PRODUTO),"CP_QUJE") == 0 
																	Aadd( aMATA105Inc, {} )
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_ITEM"   ,StrZero(nItCP,2)   , Nil } )
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_PRODUTO",SCP->CP_PRODUTO , Nil } )
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_QUANT"  ,SCP->CP_QUANT   , Nil } )
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_DATPRF", dDataBase, Nil } )
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_DESCRI" , Posicione("SB1",1,xFilial("SB1")+SCP->CP_PRODUTO,"B1_DESC")  , Nil } )
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_OP"     , cCodOS+"OS001", Nil } )
																	If !Empty(SCP->CP_CC)
																		Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_CC",SCP->CP_CC, Nil } )
																	Else
																		Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_CC", Posicione("STJ",1,xFilial("STJ")+cCodOS,"TJ_CCUSTO") , Nil } )
																	EndIf
																	If !Empty(SCP->CP_CONTA)
																		Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_CONTA",SCP->CP_CONTA, Nil } )
																	EndIf
																	If !Empty(SCP->CP_USER)
																		Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_USER",SCP->CP_USER, Nil } )
																	Else
																		Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_USER"   , Posicione("TQB",4,xFilial("TQB")+cCodOS,"TQB_CDSOLI") , Nil } )
																	EndIf
																	If axItens[nX]["TL_CODIGO"] == Alltrim(SCP->CP_PRODUTO)
																		Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"AUTDELETA" ,'S'             , Nil } )
																	Else
																		Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"AUTDELETA" ,'N'             , Nil } )
																	EndIf
																ElseIf SCP->CP_QUANT <> axItens[nX]["TL_QUANTID"]
																	lRet := .F.
																	aMATA105Cab:={}
																	cCode:= "400"
																	cMessage := "Bad Request"
																	cDetails := "5-Requisição do produto "+Alltrim(STL->TL_CODIGO)+" ao almoxarifado totalmente ou parcialmente atendida. Deve-se estornar este movimento para que seja possível a exclusão da OS."
																	DisarmTransaction()
																	exit
																EndIf
																SCP->(dbSkip())
															EndDo
														EndIf
														SB1->( dbSetOrder( 1 ) )
														SCP->( dbSetOrder( 1 ) )
														lMsErroAuto := .F.
														VarInfo('2-aMATA105Cab',aMATA105Cab)
														VarInfo('2-aMATA105Inc',aMATA105Inc)
														VarInfo('2-nMATA105Opc',nMATA105Opc)
														If !Empty(aMATA105Cab)
															MsExecAuto( { | x, y, z | Mata105( x, y , z ) }, aMATA105Cab, aMATA105Inc , nMATA105Opc )
															If lMsErroAuto
																lRet := .F.
																cCode:= "400"
																cMessage := "Bad Request"
																cArqLog  := "MATA150EXEC_"+DTOS(DATE())+"_"+Left(Time(),2)+SubStr(Time(),4,2)+".LOG"
																cDetails := MostraErro(GetSrvProfString("Startpath", ""), cArqLog)
																FErase(GetSrvProfString("Startpath", "")+cArqLog)
																DisarmTransaction()
															Else
																RecLock("STL", .F.)
																dbDelete()
																STL->(MsUnlock())
															EndIf
														EndIf
													EndIf
												Else
													//-- Analise de Alteração do item e sua quantidade
													cMATA105Num := RetInfCp("CP_OP#CP_PRODUTO",cCodOS+"OS001#"+Alltrim(STL->TL_CODIGO),"CP_NUM")
													If RetInfCp("CP_OP#CP_PRODUTO",cCodOS+"OS001#"+Alltrim(STL->TL_CODIGO),"CP_QUJE") <> 0 .And. ;
														STL->TL_QUANTID <> axItens[nX]["TL_QUANTID"]
														lRet := .F.
														cCode:= "400"
														cMessage := "Bad Request"
														cDetails := "6-Requisição do produto "+Alltrim(STL->TL_CODIGO)+" ao almoxarifado totalmente ou parcialmente atendida. Deve-se estornar este movimento para que seja possível a alteração da OS."
														DisarmTransaction()
														exit
													ElseIf STL->TL_QUANTID <> axItens[nX]["TL_QUANTID"]
														nMATA105Opc := 4
														Aadd( aMATA105Cab, { "CP_NUM"     ,cMATA105Num , Nil })
														Aadd( aMATA105Cab, { "CP_EMISSAO" ,dDataBase , Nil })
														SCP->(dbSelectArea("SCP"))
														SCP->(dbSetOrder(1))
														If SCP->(dbSeek(xFilial("SCP")+cMATA105Num))
															nItCP:= 0
															While SCP->(! Eof()) .And. SCP->(CP_FILIAL+CP_NUM) == xFilial("SCP")+cMATA105Num
																nItCP++
																If RetInfCp("CP_OP#CP_PRODUTO",cCodOS+"OS001#"+Alltrim(SCP->CP_PRODUTO),"CP_QUJE") == 0 
																	Aadd( aMATA105Inc, {} )
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_ITEM"   ,StrZero(nItCP,2)   , Nil } )
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_PRODUTO",Posicione("SB1",1,xFilial("SB1")+SCP->CP_PRODUTO,"B1_COD") , Nil } )
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_DESCRI" , Posicione("SB1",1,xFilial("SB1")+SCP->CP_PRODUTO,"B1_DESC")  , Nil } )
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_OP"     , cCodOS+"OS001", Nil } )
																	If axItens[nX]["TL_CODIGO"] == Alltrim(SCP->CP_PRODUTO)
																		Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_QUANT",axItens[nX]["TL_QUANTID"]  , Nil } )
																	Else
																		Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_QUANT",SCP->CP_QUANT  , Nil } )
																	EndIf
																	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_DATPRF", dDataBase, Nil } )
																	If !Empty(SCP->CP_CC)
																		Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_CC",SCP->CP_CC, Nil } )
																	Else
																		Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_CC", Posicione("STJ",1,xFilial("STJ")+cCodOS,"TJ_CCUSTO") , Nil } )
																	EndIf
																	If !Empty(SCP->CP_CONTA)
																		Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_CONTA",SCP->CP_CONTA, Nil } )
																	EndIf
																	If !Empty(SCP->CP_USER)
																		Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_USER",SCP->CP_USER, Nil } )
																	Else
																		Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_USER"   , Posicione("TQB",4,xFilial("TQB")+cCodOS,"TQB_CDSOLI") , Nil } )
																	EndIf
																	//If !Empty(SCP->CP_ZZNOME)
																	//	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_ZZNOME",SCP->CP_ZZNOME, Nil } )
																	//Else
																	//	Aadd( aMATA105Inc[ Len( aMATA105Inc ) ],{"CP_ZZNOME" , Posicione("TQB",4,xFilial("TQB")+cCodOS,"TQB_USUARI") , Nil } )
																	//EndIf
																EndIf
																SCP->(dbSkip())
															EndDo
														EndIf
														//SB1->( dbSetOrder( 1 ) )
														//SCP->( dbSetOrder( 1 ) )
														VarInfo('3-aMATA105Cab',aMATA105Cab)
														VarInfo('3-aMATA105Inc',aMATA105Inc)
														VarInfo('3-nMATA105Opc',nMATA105Opc)
														lMsErroAuto := .F.
														MsExecAuto( { | x, y, z | Mata105( x, y , z ) }, aMATA105Cab, aMATA105Inc , nMATA105Opc )
														If lMsErroAuto
															lRet := .F.
															cCode:= "400"
															cMessage := "Bad Request"
															cArqLog  := "MATA150EXEC_"+DTOS(DATE())+"_"+Left(Time(),2)+SubStr(Time(),4,2)+".LOG"
															cDetails := MostraErro(GetSrvProfString("Startpath", ""), cArqLog)
															FErase(GetSrvProfString("Startpath", "")+cArqLog)
															DisarmTransaction()
															exit
														Else
															STL->(dbGoto(nRecnSTL))
															RecLock("STL", .F.)
																STL->TL_QUANTID := axItens[nX]["TL_QUANTID"]
															STL->(MsUnlock())
														EndIf
													
													EndIf
												EndIf
											EndIf
										EndIf

										//-- Tratativas ao STL
										lSTLOk := .T.
										If nRecnSTL > 0
											STL->(dbGoto(nRecnSTL))
											If Alltrim(STL->TL_SEQRELA) == '0' .And. axItens[nX]["TL_QUANTID"] <> STL->TL_QUANTID
												RecLock("STL",.F.)
												STL->TL_TAREFA   := axItens[nX]["TL_TAREFA"]
												cChave += Alltrim(Str(nRecnSTL))+"#"
												Conout("STL -> OK:"+Str(nRecnSTL))
											ElseIF Alltrim(axItens[nX]["TL_TIPOREG"]) == "P"
												Conout("STL -> Abort:"+Str(nRecnSTL))	
												lSTLOk := .F.
											Else
												RecLock("STL",.F.)
												STL->TL_TAREFA   := axItens[nX]["TL_TAREFA"]
												cChave += Alltrim(Str(nRecnSTL))+"#"
											EndIf
										Else
											RecLock("STL",.T.)
											STL->TL_FILIAL := xFilial("STL")
											STL->TL_ORDEM  := cCodOS
											STL->TL_PLANO  := cSTJPLN
											STL->TL_TAREFA := "0     "
											STL->TL_SEQRELA := axItens[nX]["TL_SEQRELA"] //Alltrim(Str(nX))
											STL->TL_SEQTARE := RetTLSQTAR(xFilial("STL"),cCodOS,cSTJPLN,axItens[nX]["TL_TIPOREG"],axItens[nX]["TL_CODIGO"]) //-- Retorna o campo TL_SEQTARE
										EndIf
										If lSTLOk
											STL->TL_TIPOREG := axItens[nX]["TL_TIPOREG"]
											STL->TL_CODIGO  := axItens[nX]["TL_CODIGO"]
											STL->TL_QUANTID := axItens[nX]["TL_QUANTID"]
											STL->TL_DTINICI := StoD(StrTran(axItens[nX]["TL_DTINICI"],"-",""))
											STL->TL_HOINICI := axItens[nX]["TL_HOINICI"]
											STL->TL_DTFIM   := StoD(StrTran(axItens[nX]["TL_DTFIM"],"-",""))
											STL->TL_HOFIM   := axItens[nX]["TL_HOFIM"]
											STL->TL_OBSERVA := Alltrim(UPPER(FwNoAccent(DecodeUTF8(axItens[nX]["TL_OBSERVA"],"cp1252"))))
											If Alltrim(axItens[nX]["TL_TIPOREG"]) == "P"
												STL->TL_DESTINO  := axItens[nX]["TL_DESTINO"]
												STL->TL_UNIDADE  := Posicione("SB1",1,xFilial("SB1")+axItens[nX]["TL_CODIGO"],"B1_UM")
												STL->TL_LOCAL    := SB1->B1_LOCPAD
											Else
												STL->TL_UNIDADE  := "H"
												STL->TL_USACALE  := "S"
												cSH7COD := Posicione("ST1",1,xFilial("ST1")+axItens[nX]["TL_CODIGO"],"T1_TURNO")
												nSemana := Dow(StoD(StrTran(axItens[nX]["TL_DTINICI"],"-",""))) - 1
												If Dow(StoD(StrTran(axItens[nX]["TL_DTINICI"],"-",""))) == 1 
													nSemana := 7 //-- Domingo
												EndIf	
												aTempos:= aClone(APIcalend(cSH7COD))
												If !Empty(aTempos) .Or. nSemana == 0
													If aTempos[nSemana,3] <> "00:00"
														If Val(SubStr(axItens[nX]["TL_HOINICI"],1, 2)) < Val(SubStr(aTempos[nSemana,1],1, 2)) //.OR. ;
														// Val(SubStr(axItens[nX]["TL_HOFIM"],1, 2)) > Val(SubStr(aTempos[nSemana,2],1, 2))
															lRet := .F.
															cCode:= "400"
															cMessage := "Bad Request"
															cDetails := "NAO CONFORMIDADE, Horario invalido para o calendário/dia "+DtoC(StoD(StrTran(axItens[nX]["TL_DTINICI"],"-","")))+" do recurso ("+axItens[nX]["TL_CODIGO"]+") "+aTempos[nSemana,1]+" - "+aTempos[nSemana,2]
															DisarmTransaction()
															exit
														EndIf
													Else
														lRet := .F.
														cCode:= "400"
														cMessage := "Bad Request"
														cDetails := "NAO CONFORMIDADE, Horario invalido para o calendário/dia "+DtoC(StoD(StrTran(axItens[nX]["TL_DTINICI"],"-","")))+" do recurso ("+axItens[nX]["TL_CODIGO"]+")) "+aTempos[nSemana,1]+" - "+aTempos[nSemana,2]
														DisarmTransaction()
														exit
													EndIf
												Else
													Varinfo("nSemana",nSemana)
													Varinfo("aTempos",aTempos)
													Varinfo("cSH7COD",cSH7COD)
													Varinfo("TL_DTINICI",StoD(StrTran(axItens[nX]["TL_DTINICI"],"-","")))
													If axItens[nX]["DEL"] <> "T"
														lRet := .F.
														cCode:= "400"
														cMessage := "Bad Request"
														cDetails := "NAO CONFORMIDADE, verifique o cadastro do recurso ("+axItens[nX]["TL_CODIGO"]+") e seu turno) "
														DisarmTransaction()
														exit
													EndIf
												EndIf
											EndIf
											STL->(MsUnlock())
										Else
											lSTLOk := .T.
										EndIf
										If axItens[nX]["DEL"] == "T" .And. Alltrim(axItens[nX]["TL_TIPOREG"]) == "M"
											STL->(dbGoto(nRecnSTL)) 
											RecLock("STL",.F.)
											dbDelete()
											STL->(MsUnlock())
										EndIf
									Next nX
									If lRet					
										//-- Grava TJ_XCARD
										dbSelectArea("STJ")
										STJ->(dbSetOrder(1))
										If STJ->(dbSeek( xFilial("STJ")+cCodOS ))
											//Verifica se Gera OP
											//Busca a Sequencia da O.P.
											dbSelectArea("SC2")
											dbSetOrder(1) //C2_FILIAL+C2_NUM+C2_ITEM
											If !dbSeek( xFilial("SC2") + cCodOS + "OS" )
												If STJ->TJ_SITUACA == 'L'
													//---------------------------------------------------
													//Gera ordem de Producao para a OS
													//---------------------------------------------------
													cUsaIntPc := AllTrim(GetMV("MV_NGMNTPC"))
													If cUsaIntPc == "S"
														//Irá verificar apenas o primeiro Produto Manutenção do parâmetro
														cCODPRO := If(FindFunction("NGProdMNT"), NGProdMNT("M")[1], GetMv("MV_PRODMNT"))
														dDataIni := MNT420DTOP(STJ->TJ_DTORIGI)
														dDataFim := MNT420DTOP(STJ->TJ_DTORIGI)

														// Busca o C.C. do bem na TPN ou utiliza o C.C. da ordem de serviço quando seja do tipo localização.
														cCusto := "" //IIf( STJ->TJ_TIPOOS == 'B', NGFilTPN( STJ->TJ_CODBEM, STJ->TJ_DTORIGI, SubStr( Time(), 1, 5 ), , xFilial( 'ST9' ) )[2],;
																	//STJ->TJ_CCUSTO )
														// fGERAOPNEW(cPROD,nQTD,cOS,dINI,dFIM,cVLOC,cFil,cCusto,cObs,nOpc,lRetArray)
														//aTypeRet := { .F. , cError }
														If !fGERAOPNEW(cCODPRO,1,cCodOS,dDataIni,dDataFim,,,cCusto,"PLANO "+Alltrim(STJ->TJ_PLANO))
															lRet := .F.
															cCode:= "400"
															cMessage := "Bad Request"
															cDetails := "O.P. não gerada, verificar."
															DisarmTransaction()
														Else
															cCode:= "200"
															cField:= "TJ_ORDEM"
															cFieldInfo:= Alltrim(cCodOS)
															cMessage := "TJ_ORDEM:"+Alltrim(cCodOS)
															cDetails := "Processamento efetuado com sucesso!"
														EndIf
													EndIf
												EndIf
											Else
												cCode:= "200"
												cField:= "TJ_ORDEM"
												cFieldInfo:= Alltrim(cCodOS)
												cMessage := "TJ_ORDEM:"+Alltrim(cCodOS)
												cDetails := "Processamento efetuado com sucesso!"
											EndIf
										EndIf
									EndIf
								Else
									lRet := .F.
									cCode:= "400"
									cMessage := "Bad Request"
									cDetails := "Requisição inválida: o mesmo código de produto não pode aparecer em múltiplas linhas. Agrupe as quantidades em uma única entrada"
									DisarmTransaction()
								EndIf
							EndIf
						End Transaction
					Else
						If nOperacao == 4 .Or. nOperacao == 5
							cCodOS	  := oJsPost:STJ:GetJSonObject("TJ_ORDEM") //jBody["STJ"]["TJ_ORDEM"]
                            If Type("cCodOS") == "U"
                                cCodOS := ""
                            EndIf 
							If Empty(cCodOS)
								lRet := .F.
								cCode:= "400"
								cMessage := "Bad Request"
								cDetails := "Ordem [TJ_ORDEM] não informado!"
							Else
								dbSelectArea("STJ")
								STJ->(dbSetOrder(1))
								If STJ->(dbSeek( xFilial("STJ")+cCodOS ))
									If STJ->TJ_SITUACA == 'C'
										lRet := .F.
										cCode:= "400"
										cMessage := "Bad Request"
										cDetails := "Ordem ["+cCodOS+"] cancelada!"
									ElseIf STJ->TJ_TERMINO == 'S'
										lRet := .F.
										cCode:= "400"
										cMessage := "Bad Request"
										cDetails := "Ordem ["+cCodOS+"] finalizada!"
									Else
										//-- Analise de itens já em execução
										lSeq420Exec := .F.
										dbSelectArea("STL")
										dbSetOrder(03)
										If dbSeek(xFilial('STL')+STJ->TJ_ORDEM+STJ->TJ_PLANO,.T.)
											While !EoF() .and. STL->TL_FILIAL == xFilial('STL') .And.;
													STL->TL_ORDEM == STJ->TJ_ORDEM .And. STL->TL_PLANO == STJ->TJ_PLANO
												If Val(STL->TL_SEQRELA) <> 0
													lSeq420Exec := .T.
												EndIf
												STL->(dbSkip())
											End
										EndIf
										If lSeq420Exec
											lRet := .T.
											cField:= "TJ_ORDEM"
											cFieldInfo:= Alltrim(cCodOS)
											cMessage := "TJ_ORDEM: "+Alltrim(cCodOS)
											cDetails := "Inclusão de novos insumos para esta O.S. deve ser feita via sistema Protheus, pois já exitem insumos realizados!"
										EndIf
									EndIf
								Else
									lRet := .F.
									cCode:= "400"
									cMessage := "Bad Request"
									cDetails := "Ordem ["+cCodOS+"] não localizada!"
								EndIf
							EndIf
						EndIf
						oxCabec := oJsPost:GetJSonObject("STJ") //jBody["STJ"]
						axItens	:= oJsPost:GetJSonObject("STL") //jBody["STL"]
						If Valtype(axItens) == "U"
							axItens := {}
						EndIf
						VarInfo("[SOLAPIOS"+APIVERSAO+"][STJ]  "+Time(),oxCabec)
						VarInfo("[SOLAPIOS"+APIVERSAO+"][STL]  "+Time(),axItens)
						cCodOS	  := oJsPost:STJ:GetJSonObject("TJ_ORDEM") //jBody["STJ"]["TJ_ORDEM"]
                        If Type("cCodOS") == "U"
                            cCodOS := ""
                        EndIf 

						If nOperacao <> 3
							for nX := 1 to Len(axItens) 
								if axItens[nX]["TL_TIPOREG"] == "M"
									//-- Validação de datas (inicio)
									If Val(Alltrim(StrTran(axItens[nX]["TL_DTINICI"],"-",""))) > Val(DtoS(date()))
										cErro := "["+axItens[nX]["TL_CODIGO"]+"]:"+Alltrim(Str(nX))+" - Data de inicio inválida [TL_DTINICI]:"+alltrim(axItens[nX]["TL_DTINICI"])
										lRet := .F.
										cCode:= "400"
										cMessage := "Bad Request"
										cDetails := cErro
									EndIf
								EndIf
							Next nX
						EndIf
						//Begin Transaction -- GV removido devido a alguma rotina do 430 que refaz a transação... travando o processo para m.o. iguais
							If lRet .And. !lSeq420Exec
								lRet := .F.
								cCodOS:= oJsPost:STJ:GetJSonObject("TJ_ORDEM")
                                If Type("cCodOS") == "U"
                                    cCodOS := ""
                                EndIf 

								setFunName("MNTA420")
								cCodOS := fnCorretiva(xFilial("STJ"),;
													/*cChave*/,;
													IIf(nOperacao==6,IIF(Empty(cCodOS),3,4),nOperacao),;
													nil,;
													.T.,;
													Date(),;
													Time(),;
													0,;
													Time(),;
													Date(),;
													@cErroProc,;
													oJsPost,;
													IIf(nOperacao==6,.T.,.F.))
						
								If !Empty(cErroProc)
									lMsErroAuto := .T.
									cErroProc   := "Erro:"+cErroProc
								EndIf

								If lMsErroAuto
									lRet := .F.
									cCode:= "400"
									cMessage := "Bad Request"
									cDetails := cErroProc
									//DisarmTransaction()
								ElseIf nOperacao == 6
									Conout("Operação 6 - MNTA420 -> MNTA435")
									//-- INI
									nSEQRELA := 0
									//Begin Transaction -- GV removido devido a alguma rotina do 430 que refaz a transação... travando o processo para m.o. iguais
										If nOperacao == 6
											//oxCabec := oJsPost:GetJSonObject("STJ") //jBody["STJ"]
											//axItens	:= oJsPost:GetJSonObject("STL") //jBody["STL"]
											//VarInfo("[SOLAPIOS"+APIVERSAO+"][STJ-MNTA420]  "+Time(),oxCabec)
											//VarInfo("[SOLAPIOS"+APIVERSAO+"][STJ-MNTA420]  "+Time(),axItens)

											aRet435 := fManutOS(cCodOS,1,.F.)
											VarInfo("[SOLAPIOS"+APIVERSAO+"][aRet435]  "+Time(),aRet435)
											FWFreeObj(oxCabec)
											FWFreeArray(axItens)
											If Len(aRet435) > 3
												If !Empty(aRet435[4])
													lMsErroAuto := .T.
													cErroProc  := aRet435[4]
													cCodOS := ""
												EndIf
											EndIf

											If lMsErroAuto
												lRet := .F.
												cCode:= "400"
												cMessage := "Bad Request"
												cDetails := cErroProc
											Else
												lRet := .T.
												cCode:= "200"
												cField:= "TJ_ORDEM"
												cFieldInfo:= Alltrim(cCodOS)
												cMessage := "TJ_ORDEM:"+Alltrim(cCodOS)
												cDetails := "Processamento efetuado com sucesso!"
												If oJsPost:STJ:GetJSonObject("TJ_XCARD") <> Nil
													//-- Grava TL_SEQRELA
													dbSelectArea("STL")
													STL->(dbSetOrder(1))
													If STL->(dbSeek( xFilial("STL")+cCodOS ))
														While STL->(!EoF())
															If cCodOS == STL->TL_ORDEM .And. STL->TL_TIPOREG == 'M'
																Conout('ok'+STL->TL_ORDEM+STL->TL_ORDEM)
																If oJsPost:STJ:GetJSonObject("TJ_XCARD") <> '1'
																	nSEQRELA++
																Else
																	nSEQRELA := 0
																EndIf
																RecLock("STL",.F.)
																	STL->TL_SEQRELA := Alltrim(Str(nSEQRELA))
																STL->(MsUnlock())
															EndIf
															STL->(dbSkip())
														End
													EndIf

													//-- Grava TJ_XCARD
													dbSelectArea("STJ")
													If STJ->(FieldPos("TJ_XCARD")) > 0
														STJ->(dbSetOrder(1))
														If STJ->(dbSeek( xFilial("STJ")+cCodOS ))
															RecLock( "STJ",.F.)
																STJ->TJ_XCARD := oJsPost:STJ:GetJSonObject("TJ_XCARD")
															STJ->( MsUnlock() )
														EndIf
													EndIf
												EndIf
											Endif
										EndIf
									//End Transaction
									//-- FIM
								Else
									lRet := .T.
									cCode:= "200"
									cField:= "TJ_ORDEM"
									cFieldInfo:= Alltrim(cCodOS)
									cMessage := "TJ_ORDEM:"+Alltrim(cCodOS)
									cDetails := "Processamento efetuado com sucesso!"
									
									//-- Grava TL_SEQRELA
									dbSelectArea("STL")
									STL->(dbSetOrder(1))
									If STL->(dbSeek( xFilial("STL")+cCodOS ))
										While STL->(!EoF())
											If cCodOS == STL->TL_ORDEM .And. STL->TL_TIPOREG == 'M'
												RecLock("STL",.F.)
													STL->TL_SEQRELA := Alltrim(Str(0))
												STL->(MsUnlock())
											EndIf
											STL->(dbSkip())
										End
									EndIf
									
									//-- Grava TJ_XCARD
									dbSelectArea("STJ")
									If STJ->(FieldPos("TJ_XCARD")) > 0
										STJ->(dbSetOrder(1))
										If STJ->(dbSeek( xFilial("STJ")+cCodOS ))
											RecLock( "STJ",.F.)
												STJ->TJ_XCARD := oJsPost:STJ:GetJSonObject("TJ_XCARD")
											STJ->( MsUnlock() )
										EndIf
									EndIf
								Endif
							ElseIf lRet .And. lSeq420Exec
								//-- Grava TJ_XCARD
								dbSelectArea("STJ")
								If STJ->(FieldPos("TJ_XCARD")) > 0
									STJ->(dbSetOrder(1))
									If STJ->(dbSeek( xFilial("STJ")+cCodOS ))
										RecLock( "STJ",.F.)
											STJ->TJ_XCARD := oJsPost:STJ:GetJSonObject("TJ_XCARD")
										STJ->( MsUnlock() )
									EndIf
								EndIf
							EndIf
							//-- Em caso de exclusão 
							If lRet .And. nOperacao == 5
								dbSelectArea("TQB")
								If TQB->(FieldPos("TQB_XCARD")) > 0
									TQB->(dbSetOrder(4))
									If TQB->(dbSeek( xFilial("TQB")+cCodOS ))
										RecLock( "TQB",.F.)
											TQB->TQB_XCARD := "1"
										TQB->( MsUnlock() )
									EndIf
								EndIf
							EndIf
						//End Transaction
					EndIf
                Else
                    lRet := .F.
                    cCode:= "400"
                    cMessage := "Bad Request"
                    cDetails := "Tag 'OPERATION' não reconhecida"
                EndIf
            ElseIf cExecRot == "MNTA435" // Retorno de O.S. Modelo 2
                nOperacao := oJsPost:GetJSonObject('OPERATION')

				If oJsPost:GetJSonObject("STL")  == Nil
					lRet := .F.
					cCode:= "400"
					cMessage := "Bad Request"
					cDetails := "Informar a realização dos insumos para mão de obra (M) [STL] é obrigatório!"
				ElseIf !(Alltrim(Str(nOperacao)) $ "4#6")
					lRet := .F.
                    cCode:= "400"
                    cMessage := "Bad Request"
                    cDetails := "Operação não disponível"
				Else
					oxCabec := oJsPost:GetJSonObject("STJ") //jBody["STJ"]
					axItens	:= oJsPost:GetJSonObject("STL") //jBody["STL"]
					VarInfo("[SOLAPIOS"+APIVERSAO+"][STJ]  "+Time(),oxCabec)
					VarInfo("[SOLAPIOS"+APIVERSAO+"][STL]  "+Time(),axItens)
					cCodOS	  := oJsPost:STJ:GetJSonObject("TJ_ORDEM") //jBody["STJ"]["TJ_ORDEM"]
                    If Type("cCodOS") == "U"
                        cCodOS := ""
                    EndIf 

					for nX := 1 to Len(axItens) 
						if axItens[nX]["TL_TIPOREG"] == "M"
							//-- Validação de datas (inicio)
							If Val(Alltrim(StrTran(axItens[nX]["TL_DTINICI"],"-",""))) > Val(DtoS(date()))
								cErro := "["+axItens[nX]["TL_CODIGO"]+"]:"+Alltrim(Str(nX))+" - Data de inicio inválida [TL_DTINICI]:"+alltrim(axItens[nX]["TL_DTINICI"])
								lRet := .F.
								cCode:= "400"
								cMessage := "Bad Request"
								cDetails := cErro
							ElseIf Val(Alltrim(StrTran(axItens[nX]["TL_DTINICI"],"-",""))) == Val(DtoS(date())) .And. oJsPost:GetJSonObject('OPERATION') == 6
								If Val(Alltrim(StrTran(axItens[nX]["TL_HOINICI"],":",""))) > Val(Alltrim(SubStr(StrTran(Time(),":",""),1,4)))
									cErro := "["+axItens[nX]["TL_CODIGO"]+"]:"+Alltrim(Str(nX))+" - Hora de inicio inválida [TL_HOINICI]:"+alltrim(axItens[nX]["TL_HOINICI"])
									lRet := .F.
									cCode:= "400"
									cMessage := "Bad Request"
									cDetails := cErro
								ElseIf Val(Alltrim(StrTran(axItens[nX]["TL_HOFIM"],":",""))) > Val(Alltrim(SubStr(StrTran(Time(),":",""),1,4)))
									cErro := "["+axItens[nX]["TL_CODIGO"]+"]:"+Alltrim(Str(nX))+" - Hora de fim inválida [TL_HOFIM]:"+alltrim(axItens[nX]["TL_HOFIM"])
									lRet := .F.
									cCode:= "400"
									cMessage := "Bad Request"
									cDetails := cErro
								EndIf
							EndIf
						EndIf
					Next nX
					If lRet 
						dbSelectArea("STJ")
						STJ->(dbSetOrder(1))
						If STJ->(dbSeek( xFilial("STJ")+cCodOS ))
							If STJ->TJ_SITUACA == 'C'
								lRet := .F.
								cCode:= "400"
								cMessage := "Bad Request"
								cDetails := "Ordem ["+cCodOS+"] cancelada!"
							ElseIf STJ->TJ_TERMINO == 'S'
								lRet := .F.
								cCode:= "400"
								cMessage := "Bad Request"
								cDetails := "Ordem ["+cCodOS+"] finalizada!"
							ElseIf (oJsPost:STJ:GetJSonObject("TJ_DTPRFIM") == Nil .Or. oJsPost:STJ:GetJSonObject("TJ_HOPRFIM") == Nil) .And. nOperacao == 6
								lRet := .F.
								cCode:= "400"
								cMessage := "Bad Request"
								cDetails := "Informação de data [TJ_DTPRFIM] e hora [TJ_HOPRFIM] para finalização não informado!"
							Else
								//Begin Transaction
									lFinaliza := oJsPost:GetJSonObject('OPERATION') == 6
									cErro	:= ""
									aRet435 := fManutOS(cCodOS,1,lFinaliza)
									VarInfo("[SOLAPIOS"+APIVERSAO+"][aRet435]  "+Time(),aRet435)
									FWFreeObj(oxCabec)
									FWFreeArray(axItens)
									If Len(aRet435) > 3
										If !Empty(aRet435[4])
											lMsErroAuto := .T.
											cErroProc  := aRet435[4]
											cCodOS := ""
										EndIf
									EndIf

									If lMsErroAuto
										lRet := .F.
										cCode:= "400"
										cMessage := "Bad Request"
										cDetails := cErroProc
									Else
										lRet := .T.
										cCode:= "200"
										cField:= "TJ_ORDEM"
										cFieldInfo:= Alltrim(cCodOS)
										cMessage := "TJ_ORDEM:"+Alltrim(cCodOS)
										cDetails := "Processamento efetuado com sucesso!"
										If lFinaliza
											//-- Grava TJ_XCARD
											dbSelectArea("STJ")
											If STJ->(FieldPos("TJ_XCARD")) > 0
												Conout("TJ_XCARD - Atualização de ["+cCodOS+"] = 3")
												STJ->(dbSetOrder(1))
												If STJ->(dbSeek( xFilial("STJ")+cCodOS ))
													RecLock( "STJ",.F.)
														STJ->TJ_XCARD := oJsPost:STJ:GetJSonObject("TJ_XCARD")
														If oJsPost:STJ:GetJSonObject("TJ_XCARD") == '3'
															STJ->TJ_TERMINO := "S"
														EndIf
													STJ->( MsUnlock() )
												EndIf

												If !Empty(STJ->TJ_SOLICI)
													dbSelectArea("TQB")
													If TQB->(FieldPos("TQB_XCARD")) > 0
														//Conout("TQB_XCARD - Atualização de ["+cCodOS+"]")
														TQB->(dbSetOrder(4))
														If TQB->(dbSeek( xFilial("TQB")+cCodOS ))
															Conout("TQB_XCARD - Atualização de ["+cCodOS+"] = 3")
															RecLock( "TQB",.F.)
																TQB->TQB_XCARD := oJsPost:STJ:GetJSonObject("TJ_XCARD")
																TQB->TQB_DTFECH := Date()
																TQB->TQB_HOFECH := SubStr( Time(), 1, 5 )
															TQB->( MsUnlock() )
														EndIf
													EndIf
												EndIf
											EndIf
										EndIf
									Endif
								//End Transaction
							EndIf
						Else
							lRet := .F.
							cCode:= "400"
							cMessage := "Bad Request"
							cDetails := "Ordem ["+cCodOS+"] não localizada!"
						EndIf
					EndIf
                EndIf
            Else
                lRet := .F.
                cCode:= "400"
                cMessage := "Bad Request"
                cDetails := "Processamento não identificado"
            EndIf
        EndIf
        
        nStatRet := Val(cCode)
        oResult["CODE"] := cExecRot
        oResult["MESSAGE"] := EncodeUTF8(cMessage,"cp1252") //--MESSAGE
        oResult["DETAILS"] := EncodeUTF8(cDetails,"cp1252") //--DETAILS
		If !Empty(cField) .And. !Empty(cFieldInfo)
		    oResult["FIELD"] := EncodeUTF8(cField,"cp1252") //-- Campo
        	oResult["FIELDINFO"] := EncodeUTF8(cFieldInfo,"cp1252") //-- Informativo do campo
		EndIf
        oJsRet["status"]   := {}
        aAdd(oJsRet["status"],oResult)
		
        cJsRet:= FWJsonSerialize(oResult,.T.,.T.)
        Self:SetStatus(nStatRet) 
        Self:SetResponse(cJsRet)
        FreeObj(oJsRet)

        If !Empty(cTenantId)
            RpcClearEnv()
        EndIf
		VarInfo("[SOLAPIOS"+APIVERSAO+"][POST-RESULT]  "+Time(),oResult)
    Else
        lRet := .F.
        cCode:= "400"
        nStatRet := Val(cCode)
        cMessage := "Bad Request"
        cDetails := "Processamento não identificado"
		If !Empty(cExecRot)
        	oResult["CODE"] := cExecRot
		ElseIf!Empty(cAPIFUNC) 
			oResult["CODE"] := cAPIFUNC
		EndIf
        oResult["MESSAGE"] := EncodeUTF8(cMessage,"cp1252")
        oResult["DETAILS"] := EncodeUTF8(cDetails,"cp1252")
        oJsRet["status"]   := {}
        aAdd(oJsRet["status"],oResult)
        cJsRet:= FWJsonSerialize(oJsRet,.T.,.T.)
        Self:SetStatus(nStatRet) 
        Self:SetResponse(cJsRet)
        FreeObj(oJsRet)
    EndIf
	
    RestArea(aArea)

Return lRet

/*/{Protheus.doc} 
fnCorretiva
@author Gustavo Viana
Baseado em FDTKLFR - ivan.caproni
@type WS Method
@since Set/2025
@version 1.0
/*/
//-------------------------------
// [INI] PROCESSOS PARA MNTA420
//-------------------------------

static function fnCorretiva(cCodFil,cCodBem,nOpcx,cTipoOS,lRetCod,dInicio,hInicio,nKM,cHora,dDtIni,cMsgErr,oJsPost,lOper6)
	Local aNGBEGINPRM 	:= If(!IsInCallStack("MNTA420"),NGBEGINPRM(,"MNTA420",/*aChkAlias*/,.F.),{})
	Local cInfoCompl    := ""
	Local cALIASTJ		:= "STJ"
	Local nORDSTJ		:= STJ->(IndexOrd())
	Local nREGSTJ		:= STJ->(Recno())
	Local lPRI420		:= .T.
	Local l420Grava		:= .T.
	Local cCodOS		:= Space(Len(STJ->TJ_ORDEM))
	Local lRetAlte		:= .T.
	Local lMsgExec      := .F.
	Local aAreaSTJ		:= {}
	Local lFuncCont2    := FindFunction("MNTCont2") //FindFunction remover na release GetRPORelease() >= '12.1.027'
    Local aX3Struct     :={}
    Local nX3Cmp        := 0
    Local nSTLLin       := 0 
    Local nSTLIns       := 0
    Local nSTLExc       := 0

	// Define se utiliza produto alternativo
	Local lUsePrAlt     := AllTrim( SuperGetMv( 'MV_MNTPRAL', .F., '2' ) ) == '1' .And. cGerSA == 'N'
	Local nX       := 0
	Local nY	   := 0
	Local lAlterou := .F.
	Local cSeqArqInf:= ""
	Local cChavSTL := ""
	Local cChavTPSTL:= ""
	Local cChavCDSTL:= ""
    Local _cTJOrdem := ""

	//local aDef as array
	local nLin as numeric
	//local cCodNaoApl := GetMv("ZZ_NPLTKTL",,"15449") // NAO APLICAVEL

	Default lRetCod		:= .F.//Indica se retorna codigo da OS
	Default lOper6      := .F.//Indica que vai efetuar processamento do MNTA435 em seguida

	Private nINDSTQ		:= 1, cINSPREV := "P"
    Private aDtSa 	    := {}
	Private cARQUISAI	:= "STJ"
	Private lTEMFACI	:= .F.
	Private lSaveSTQ    := .F.
	Private lSaveTTC    := .F.
	Private lSaveSTN    := .F.
	Private nTIPHEA		:= 0
	Private cUsaIntEs	:= AllTrim(GetMV("MV_NGMNTES"))
	Private nCOPIAOS	:= GetMV("MV_NGCOPOS")
	Private nCODINS		:= 0, nUSACAL := 0 , nDATAIN := 0, nHORAIN := 0
	Private dINI, hINI
	Private vCAMPOS		:= Space(16)
	Private aSize		:= MsAdvSize(,.F.,430), aObjects := {}
	Private aNgTabSCP	:= {} //ATENCAO - Não excluir esta variavel - A variavel está sendo utilizada para armazenar as S.A. que serão gravadas na chamada de um ponto de entrada.
	Private cFilOld		:= cFilAnt
	Private cFILBEM		:= If(Type("cFILBEM")<>"C",xFilial("ST9"),cFILBEM)
	Private lWhenTJBem	:= .T.
	Private lUSATARG	:= If(FindFunction("NGUSATARPAD"),NGUSATARPAD(),.F.)
	Private cPxSeq		:= Space(3),cPxQSeq := cPxSeq
	Private nQTETA		:= 0,nQTARE := 0
	Private lSEQTAR		:= NGCADICBASE("TL_SEQTARE","A","STL",.F.)
	Private nOpcai		:= 0
	Private lObserv 	:= .T. // Indica se deve ou nao apresentar a tela de Observacoes ao fim do processo
	Private aButton		:= IIf(Type("aNgButton") == "A", aClone(aNgButton), {})

	Private nPosNum		:= 0
	Private nPosItem    := 0
	Private aNewSC      := {}
	Private aSComp		:= {}
	
	/*-----------------------------------+
	| Variáveis utilizadas em dicionário |
	+-----------------------------------*/
	Private oGetOcorr
	Private oGetEtapa

	//--------------------------------------------------
	// Carrega array de botões para Ações relacionadas
	// baseados nas tabelas de clique da direita
	//--------------------------------------------------
	If Len( aButton ) == 0
		NGClickBar( @aButton, NGRIGHTCLICK("MNTA420") )
	EndIf

	faltera := (nOpcx == 4)

	MV_PAR01   := Space(6)
	MV_PAR02   := Space(6)
	MV_PAR05   := Space(6)

	vVetMvP    := NGSALVAMVPA()

	If Type("lCorret") <> "L"
		lCorret := .T.
	EndIf

	lTEMFACI := NGINTESTORG()

	Aadd(aObjects,{050,050,.T.,.T.})
	Aadd(aObjects,{100,100,.T.,.T.})

	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.T.)

	If nOpcx == 3
		SetKey(VK_F11,{||NGTAFMNT("M->TJ_CODBEM",.T.)})
		SetKey(VK_F10,{||If(Type("ODLG") == 'U',MNTA420ESB(),.T.)})

		If AllTrim(GetNewPar("MV_NGMNTAT","N")) $ "2/3"
			SetKey(VK_F7 ,{||MNT420F7()})
		EndIf
	EndIf

	//If FindFunction("NGSEQETA")
	//	nINDSTQ := NGSEQETA("STQ",nINDSTQ)
	//EndIf

	aBLO := {{},{},{},{},{}}

	If nOpcx == 4
		If STJ->TJ_TIPOOS = "B"
			If !NGBEMATIV(STJ->TJ_CODBEM)
				Return If(!lRetCod, .F., "")
			EndIf
		EndIf
	EndIf

	INCLUI   := (nOpcx == 3)
	lSITUACA := (nOpcx == 3)

	If nOpcx == 5

		If GetNewPar("MV_NGMNTCC","N") == "S"
			aAreaSTJ := GetArea()
			dbSelectArea("TV9")
			dbSetOrder(1)
			If dbSeek(xFilial("TV9")+STJ->TJ_CODBEM+STJ->TJ_ORDEM)
				//Alert("Medicao Material Rodante nao encontrado")
                cMsgErr := "Medicao Material Rodante nao encontrado"
				Return If(!lRetCod, .F., "TV9")
			EndIf
			RestArea(aAreaSTJ)
		EndIf

		dbSelectArea("STL")
		dbSetOrder(03)
		dbSeek(xFilial('STL')+STJ->TJ_ORDEM+STJ->TJ_PLANO+"1  ",.T.)
		While !EoF() .and. stl->tl_filial == xFilial('STL') .And.;
				stl->tl_ordem == stj->tj_ordem .And. stl->tl_plano == stj->tj_plano

			If Val(stl->tl_seqrela) <> 0
				//Help(" ",1,"HAREPORT")
				dbSelectArea("STJ")
				cMsgErr := "Sequencia de atendimento já iniciada"
				Return If(!lRetCod, .F., "HAREPORT")
			EndIf
			dbSkip()
		End While
	EndIf

	aVARNAO	:= {}
	TIPOACOM	:= .F.
	TIPOACOM2	:= .F.
	cBEMCONT	:= Space(Len(STJ->TJ_CODBEM))

	bNGGRAVA	:= {|| fnCheck(nOpcx,cCodFil) }
	aCHOICE		:= {"TJ_ORDEM"	,"TJ_TIPOOS" ,"TJ_CODBEM" ,"TJ_NOMBEM" ,"TJ_SERVICO","TJ_CODAREA",;
					"TJ_TIPO","TJ_NOMSERV","TJ_DTORIGI","TJ_POSCONT","TJ_HORACO1","TJ_OBSERVA",;
					"TJ_SITUACA","TJ_POSCON2","TJ_HORACO2","TJ_TERCEIR","TJ_DTPRINI","TJ_HOPRINI"}

	/*-----------------------------+
	| Integração SIGAGFR x SIGALOC |
	+-----------------------------*/
	If SuperGetMV( 'MV_NG1LOC', .F., .F. )

		aAdd( aChoice, 'TJ_AS' )
		aAdd( aChoice, 'TJ_PROJETO' )
		aAdd( aChoice, 'TJ_OBRA' )

	EndIf

	If ExistBlock("MNTA4206")
		ExecBlock("MNTA4206",.F.,.F.)
	EndIf

	Private aCHKDEL	:= {}
	Private aTELA[0][0],aGETS[0],aHeader[0],Continua,nUsado:=0
	Private oMenu

	bCampo	:= {|nCPO| Field(nCPO) }
	cSP		:= " "

    If nOPCx <> 3
        _cTJOrdem := oJsPost:STJ:GetJSonObject("TJ_ORDEM")
        If Type("_cTJOrdem") == "U"
            _cTJOrdem := ""
        EndIf 
        dbSelectArea("STJ")
		dbSetOrder(1)
		If dbSeek(xFilial("STJ")+Alltrim(_cTJOrdem))
            nREGSTJ:= STJ->(Recno())
		EndIf
    EndIf

	dbSelectArea("STL")
	RegtoMemory("STL",(nOPCX == 3))

	dbSelectArea("STQ")
	dbSetOrder(nINDSTQ)
	RegtoMemory("STQ",(nOPCX == 3))

	dbSelectArea("STJ")
	RegtoMemory("STJ",(nOPCX == 3))

	//Inicializa campo Observacao
	If !NGCADICBASE("TJ_MMSYP","A","STJ",.F.)
		M->TJ_OBSERVA := Space(50)
	EndIf

	If nOpcx <> 3
		If NGCADICBASE("TJ_MMSYP","A","STJ",.F.)
			M->TJ_OBSERVA := NGMEMOSYP(STJ->TJ_MMSYP)
		Else
			M->TJ_OBSERVA := STJ->TJ_OBSERVA
		EndIf
	EndIf

	//If IsInCallStack("MNTA291")
	//	M->TJ_OBSERVA := NGMEMOSYP(TQB->TQB_CODMSS)
	//EndIf

    //-- Preencimento de O.S. (STJ) via API
    aX3Struct := oJsPost:STJ:GetNames()
    For nX3Cmp := 1 To Len(aX3Struct)
        If "TJ_CODBEM" $ aX3Struct[nX3Cmp]
            cCodBem:= oJsPost:STJ:GetJSonObject(aX3Struct[nX3Cmp])
        EndIf
        If GetSX3Cache(aX3Struct[nX3Cmp], "X3_CONTEXT") != "V"
           If oJsPost:STJ:GetJSonObject(aX3Struct[nX3Cmp]) <> Nil
              If GetSX3Cache(aX3Struct[nX3Cmp],"X3_TIPO") == 'D'
                 &("M->"+aX3Struct[nX3Cmp]) := StoD(StrTran(SUBSTR(oJsPost:STJ:GetJSonObject(aX3Struct[nX3Cmp]),1,10),"-",""))
              Else
                 &("M->"+aX3Struct[nX3Cmp]) := oJsPost:STJ:GetJSonObject(aX3Struct[nX3Cmp])
              EndIf
           EndIf
        ElseIf GetSX3Cache(aX3Struct[nX3Cmp],"X3_TIPO") == 'M'
           If oJsPost:STJ:GetJSonObject(aX3Struct[nX3Cmp]) <> Nil
              &("M->"+aX3Struct[nX3Cmp]) := oJsPost:STJ:GetJSonObject(aX3Struct[nX3Cmp])
           EndIf
        EndIf
    Next nX3Cmp
    
	//Variaveis para carregar TJ_CODBEM e TJ_TIPOOS automaticamente
	If Type("cCodBem420") == "C" .And. Type("cTipoOS420") == "C"
		cCodBem := cCodBem420
		cTipoOS := cTipoOS420
	EndIf

	If ValType(cCodBem) == "C"  .And. INCLUI .And. !IsInCallStack("MNTA985")
		M->TJ_CODBEM := cCodBem
		M->TJ_TIPOOS := If(Empty(cTipoOS),"B",cTipoOS)

		If !(&(X3Valid("TJ_CODBEM")) .And. VldUser("TJ_CODBEM"))
			Return If(!lRetCod, .F., "TJ_CODBEM")
		EndIf

		lWhenTJBem := .F.
	EndIf

	If IsInCallStack("MNTA985")
		Set Key VK_F8 To

		NGDBAREAORDE("ST9",01)
		dbSeek(cCodFil+cCodBem)
		M->TJ_CODBEM := ST9->T9_CODBEM
		M->TJ_DTORIGI := If(IsInCallStack("MNT985ENT"),M->TTI_DTENT,dDatabase)

		TIPOACOM := If(ST9->T9_TEMCONT = "S" .And. M->TJ_DTORIGI <= dDataBase,.T.,.F.)

		If lFuncCont2
			TIPOACOM2 := MNTCont2(cCodFil, cCodBem) .And. M->TJ_DTORIGI <= dDataBase
		Else
			NGDBAREAORDE("TPE",01)
			TIPOACOM2 := If(dbSeek(NGTROCAFILI("TPE",cCodFil)+cCodBem) .And. M->TJ_DTORIGI <= dDataBase ,.T.,.F.)
		EndIf

		M->TJ_TIPOOS := "B"

		If TIPOACOM .And. IsInCallStack("MNT985ENT")
			M->TJ_HORACO1 := M->TTI_HRENT
			M->TJ_POSCONT := If(!FindFunction("NGBlCont") .Or. NGBlCont( cCodBem ), M->TTI_POS1EN, NGTpCont(M->TJ_CODBEM, M->TJ_DTORIGI, M->TJ_HORACO1, M->TTI_POS1EN))//M->TTI_POS1EN
		EndIf

		If TIPOACOM2 .And. IsInCallStack("MNT985ENT")
			M->TJ_HORACO2 := M->TTI_HRENT
			M->TJ_POSCON2 := M->TTI_POS2EN
		EndIf

		cFILBEM := cCodFil
	EndIf

	If IsInCallStack("MNTA902") .And. M->TJ_TIPOOS == "B"
		dbSelectArea("ST9")
		dbSetOrder(1)
		If dbSeek( xFilial("ST9") + cBemAL )
			M->TJ_NOMBEM := ST9->T9_NOME // Carrega descrição do bem
			TIPOACOM     := IIf(ST9->T9_TEMCONT = "S" .And. M->TJ_DTORIGI <= dDataBase,.T.,.F.)
			If lFuncCont2
				TIPOACOM2 := MNTCont2(xFilial("TPE"), cBemAL) .And. M->TJ_DTORIGI <= dDataBase
			Else
				NGDBAREAORDE("TPE",01)
				TIPOACOM2 := If(dbSeek(xFilial("TPE")+cBemAL) .And. M->TJ_DTORIGI <= dDataBase,.T.,.F.)
			EndIf
		EndIf
	EndIf

	//Ponto de Entrada para carregar variaveis em tela
	If ExistBlock("MNTA420J")
		ExecBlock("MNTA420J",.F.,.F.,{nOPCX,cCodbem,cCodFil})
	EndIf

	If nOPCX == 3

		dbSelectArea("STJ")
		dbSetOrder(1)

		//Tratamento para evitar duplicação de número de O.S. em base
		If dbSeek(xFilial("STJ") + M->TJ_ORDEM )

			aArea := GetArea()

			dbSelectArea( "STJ" )
			dbSetOrder( 01 )
			While dbSeek( xFilial( "STJ" ) + M->TJ_ORDEM)
				ConfirmSX8()
				M->TJ_ORDEM := GetSXENum( "STJ","TJ_ORDEM" )
			End

			RestArea( aArea )

		EndIf

	EndIf

	M->TJ_PLANO	  := "000000"
	M->TJ_SEQRELA := '000'

	If Empty(M->TL_SEQRELA)
		M->TL_SEQRELA := "0  "
	EndIf
	If Empty(M->TL_TAREFA)
		M->TL_TAREFA  := "0     "
	EndIf

	nSEQUENC := "0  "
	lRETORNO := .F.
	aHEAINS	 := {}
	aHEAETA	 := {}
	aHEASIN	 := {}
	aHeaOcr  := {}
	aGETINS	 := {}
	aGETETA	 := {}
	aGETSIN	 := {}
	aGetOcr  := {}
	aDATINS	 := {}

	NG420ININS(nOPCX) //-- Carrega Insumos salvos
	NG420INETA(nOPCX) //-- Carrega Etapas salvas

	If TT9->( FieldPos( 'TT9_CARACT' ) ) > 0
		fOcorrGetD( nOPCX )
	EndIf

	If NGCADICBASE('TTC_CODBEM','A','TTC',.F.)
		NG420INSIN(nOPCX)
	EndIf

	// USADO NA ALTERACAO
	aHEAINSAL := ACLONE(aHEAINS)
	aGETINSAL := ACLONE(aGETINS)

    //-- Preencimento de Insumos (STL) - Via API
	If nOPCX == 3 .Or. nOPCX == 4
		If oJsPost:HasProperty("STL")
			For nSTLIns := 1 To Len(aGETINS)
				aGETINS[nSTLIns,Len(aHEAINSAL)+1] := .T.
				If aGETINS[nSTLIns,Len(aHEAINSAL)] > 0
					DbSelectArea("STL")
					STL->( DbGoTo( aGETINS[nSTLIns,Len(aHEAINSAL)] ) )   
					RecLock( "STL", .F. )
						STL->( dbDelete() )
					STL->(MsUnLock())
				EndIf
			Next nSTLIns
			aGETINS:={}
			For nSTLIns := 1 To Len(oJsPost:STL)
				If lOper6
					If oJsPost:STL[nSTLIns]:GetJSonObject("TL_TIPOREG") == "M" 
						Loop
					EndIf
				EndIf
				AADD(aGETINS,{})
				For nX3CMP := 1 to Len(aHeaIns)
					IF aHeaIns[nX3CMP][8] == "C"
						AADD(aGETINS[Len(aGETINS)], SPACE(aHeaIns[nX3CMP][4]))
					ELSEIF aHeaIns[nX3CMP][8] == "N"
						AADD(aGETINS[Len(aGETINS)], 0)
					ELSEIF aHeaIns[nX3CMP][8] == "D"
						AADD(aGETINS[Len(aGETINS)], CTOD('  /  /  '))
					ELSEIF aHeaIns[nX3CMP][8] == "M"
						AADD(aGETINS[Len(aGETINS)], " ")
					ELSE
						AADD(aGETINS[Len(aGETINS)],.F.)
					Endif
				Next nX3CMP
				AADD(aGETINS[Len(aGETINS)],.F.)
			Next nSTLIns

			For nSTLIns := 1 To Len(oJsPost:STL)
				If lOper6
					If oJsPost:STL[nSTLIns]:GetJSonObject("TL_TIPOREG") == "M" 
						nSTLExc--
						Loop
					EndIf
				EndIf
				aX3Struct := oJsPost:STL[nSTLIns]:GetNames()
				For nX3Cmp := 1 To Len(aX3Struct)
					If nX3CMP == 1
						If oJsPost:STL[nSTLIns]:GetJSonObject("TL_TIPOREG") <> Nil
							M->TL_TIPOREG := If(oJsPost:STL[nSTLIns]:GetJSonObject("TL_TIPOREG") <> Nil, oJsPost:STL[nSTLIns]:GetJSonObject("TL_TIPOREG")," ")
						EndIf
						If oJsPost:STL[nSTLIns]:GetJSonObject("TL_CODIGO") <> Nil
							M->TL_CODIGO := If(oJsPost:STL[nSTLIns]:GetJSonObject("TL_CODIGO") <> Nil, oJsPost:STL[nSTLIns]:GetJSonObject("TL_CODIGO"), " ")
						EndIf
					EndIf
					If !Empty(M->TL_TIPOREG) .And. !Empty(M->TL_CODIGO)
							
						//-- Tratativa de U.M.
						nSTLLin := aScan(aHeaIns,{|x| Trim(Upper(x[2])) == "TL_UNIDADE" })
						If Alltrim(M->TL_TIPOREG) == "M"
							dbSelectArea("ST1")
							ST1->(dbSetOrder(1))
							If !(ST1->(dbSeek(xFilial("ST1")+M->TL_CODIGO)))
								cMsgErr := "Cod. Funcionário não encontrado ["+M->TL_CODIGO+"]"
								Return If(!lRetCod, .F., cMsgErr)
							EndIf
							aGETINS[(nSTLIns+nSTLExc),nSTLLin] := "H"
						ElseIf Alltrim(M->TL_TIPOREG) == "P"
							dbSelectArea("SB1")
							SB1->(dbSetOrder(1))
							If SB1->(dbSeek(xFilial("SB1")+M->TL_CODIGO))
								aGETINS[(nSTLIns+nSTLExc),nSTLLin] := SB1->B1_UM
								//-- Tratativa de ArmazeM
								nSTLLin := aScan(aHeaIns,{|x| Trim(Upper(x[2])) == "TL_LOCAL" })
								aGETINS[(nSTLIns+nSTLExc),nSTLLin] := SB1->B1_LOCPAD
								If SB1->B1_MSBLQL == "1"
									cInfoCompl    := M->TL_CODIGO+":Produto Bloqueado"
									cMsgErr := "Produto Bloqueado ["+M->TL_CODIGO+"]"
									Return If(!lRetCod, .F., cMsgErr)
								EndIf
							Else
								//Alert("Medicao Material Rodante nao encontrado")
								cMsgErr := "Produto não encontrado ["+M->TL_CODIGO+"]"
								Return If(!lRetCod, .F., cMsgErr)
							EndIf
						EndIf

						nSTLLin := aScan(aHeaIns,{|x| Trim(Upper(x[2])) == aX3Struct[nX3Cmp] })
						If GetSX3Cache(aX3Struct[nX3Cmp], "X3_CONTEXT") != "V" .And. nSTLLin > 0
							If oJsPost:STL[nSTLIns]:GetJSonObject(aX3Struct[nX3Cmp]) <> Nil
								If aX3Struct[nX3Cmp] == "TL_UNIDADE"
									If Alltrim(M->TL_TIPOREG) == "M"
										dbSelectArea("ST1")
										ST1->(dbSetOrder(1))
										If !(ST1->(dbSeek(xFilial("ST1")+M->TL_CODIGO)))
											cMsgErr := "Cod. Funcionário não encontrado ["+M->TL_CODIGO+"]"
											Return If(!lRetCod, .F., cMsgErr)
										EndIf
										aGETINS[(nSTLIns+nSTLExc),nSTLLin] := "H"
									ElseIf Alltrim(M->TL_TIPOREG) == "P"
										dbSelectArea("SB1")
										SB1->(dbSetOrder(1))
										If SB1->(dbSeek(xFilial("SB1")+M->TL_CODIGO))
											aGETINS[(nSTLIns+nSTLExc),nSTLLin] := SB1->B1_UM
											//-- Tratativa de ArmazeM
											nSTLLin := aScan(aHeaIns,{|x| Trim(Upper(x[2])) == "TL_LOCAL" })
											aGETINS[(nSTLIns+nSTLExc),nSTLLin] := SB1->B1_LOCPAD
											If SB1->B1_MSBLQL == "1"
												cInfoCompl    := M->TL_CODIGO+":Produto Bloqueado"
												cMsgErr := "Produto Bloqueado ["+M->TL_CODIGO+"]"
												Return If(!lRetCod, .F., cMsgErr)
											EndIf
										Else
											//Alert("Medicao Material Rodante nao encontrado")
											cMsgErr := "Produto não encontrado ["+M->TL_CODIGO+"]"
											Return If(!lRetCod, .F., cMsgErr)
										EndIf
									EndIf
								ElseIf GetSX3Cache(aX3Struct[nX3Cmp],"X3_TIPO") == 'D'
									aGETINS[(nSTLIns+nSTLExc),nSTLLin] := StoD(StrTran(oJsPost:STL[nSTLIns]:GetJSonObject(aX3Struct[nX3Cmp]),"-",""))
								ElseIf GetSX3Cache(aX3Struct[nX3Cmp],"X3_TIPO") $ 'C#M'
									aGETINS[(nSTLIns+nSTLExc),nSTLLin] := DecodeUTF8(oJsPost:STL[nSTLIns]:GetJSonObject(aX3Struct[nX3Cmp]), "cp1252")
								Else
									aGETINS[(nSTLIns+nSTLExc),nSTLLin] := oJsPost:STL[nSTLIns]:GetJSonObject(aX3Struct[nX3Cmp])
								EndIf
							EndIf
						ElseIf GetSX3Cache(aX3Struct[nX3Cmp],"X3_TIPO") == 'M' .And. nSTLLin > 0
							If oJsPost:STL[nSTLIns]:GetJSonObject(aX3Struct[nX3Cmp]) <> Nil
								aGETINS[(nSTLIns+nSTLExc),nSTLLin]:= VirtInsumo( M->TL_TIPOREG, M->TL_CODIGO, GDFieldGet( 'TL_LOJA', nSTLIns, .F., aHeaIns, aGETINS ) )
							EndIf
						Else
							Conout("fnCorretiva - Campo não está habilitado para preenchimento "+aX3Struct[nX3Cmp])
						EndIf
					EndIf
				Next nX3Cmp
			Next nSTLIns 
		EndIf
	EndIf

    //"TJ_ORDEM": "000364",
	dbSelectArea( "STJ" )

	aPos1	:= {15,1,120,315}
	nOpca	:= 0

	dINI	:= M->TJ_DTORIGI
	hINI	:= If(!Empty(M->TJ_HOMPINI),M->TJ_HOMPINI,SubStr( Time(),1,5))

	If ExistBlock("MNTA420D")
		If !ExecBlock("MNTA420D",.F.,.F.)
			Return If(!lRetCod, .F., "MNTA420D")
		EndIf
	EndIf

	//Adiciona na posição 4 do aPos1 a area util para utilizacao em tela (largura) para correta adequacao na ver11
	//Este tratamento nao foi feito na criacao do array pois esta alteracao serve apenas quando os botoes nao sao criados
	//no lado direito.
	aPos1[4] := aPosObj[2,4]

	//M->TJ_SERVICO := GetMv("ZZ_OSCTKTL",,"001397")

	M->TJ_CODAREA := Posicione("ST4",1,xFilial("ST4")+M->TJ_SERVICO,"T4_CODAREA")
	M->TJ_TIPO	  := Posicione("ST4",1,xFilial("ST4")+M->TJ_SERVICO,"T4_TIPOMAN")

	// Ricardo Yamashiro
	// 13/11/2025
	TQB->(dbsetorder(1))
	If TQB->(msSeek(fwxFilial("TQB")+STJ->TJ_SOLICI))
		M->TJ_DTPRINI := TQB->TQB_XDTPRI //dInicio
		M->TJ_HOPRINI := TQB->TQB_XHRPRI //Left(hInicio,TamSx3("TJ_HOPRINI")[1])
	Else
		M->TJ_DTPRINI := dInicio
		M->TJ_HOPRINI := Left(hInicio,TamSx3("TJ_HOPRINI")[1])
	EndIf
	nOpca:=1
	If nOPCX == 3 .Or. nOPCX == 4
		if !Eval(bNGGRAVA)
			nOpca := 0
		endif
	EndIf
	// a gravacao desses campos devem estar apos bNGGRAVA para evitar validacoes
	M->TJ_POSCONT := nKM
	M->TJ_HORACO1 := cHora
	if ! Empty(dDtIni)
		M->TJ_DTORIGI := dDtIni
	endif

	If nOPCA != 1
		Set Key VK_F10 To
		Set Key VK_F11 To
		Set Key VK_F8 To
		Set Key VK_F7 To

		STJ->(dbSelectArea(cALIASTJ))
		STJ->(dbSetOrder(nORDSTJ))
		If nOPCx <> 3
			STJ->(dbGoTo(nREGSTJ))
		EndIf

		If __lSX8
			RollbackSx8()
		EndIf

		Return If(!lRetCod, .F., "Cancelado")
	EndIf

	// Caso seja alteração valida se houve alteração nos Insumos
	If nOpcx == 4
		
		If Len(aGetInSal) == Len(aGetIns)
			For nX := 1 to Len(aGetInSal)
				For nY := 1 to Len(aGetInSal[nX])
					If aGetInSal[nX][nY] <> aGetIns[nX][nY]
						lAlterou := .T.
						Exit
					EndIf
				Next nY
			Next nX
		Else
			lAlterou := .T.
		EndIf
	EndIf

	// Caso não seja inclusão e não tenha alteração de Insumo segue com o valor que já possui
	If nOpcx == 3 .Or. lAlterou
		dINI := M->TJ_DTORIGI
		dFIM := M->TJ_DTORIGI
	Else	
		dINI := M->TJ_DTMPINI
		dFIM := M->TJ_DTMPFIM
	EndIf

	hFIM := If(!Empty(M->TJ_HOMPINI),M->TJ_HOMPINI,SubStr( Time(),1,5))
	dMAX := M->TJ_DTORIGI
	hMAX := If(!Empty(M->TJ_HOMPINI),M->TJ_HOMPINI,SubStr( Time(),1,5))
	dMIN := M->TJ_DTORIGI
	hMIN := If(!Empty(M->TJ_HOMPINI),M->TJ_HOMPINI,SubStr( Time(),1,5))

	lnOpcae := .F.

	SB1->( dbSetOrder(RetOrder("SB1","B1_FILIAL+B1_COD")) )
	//VarInfo("aGETINS",aGETINS)
	//aDef := aClone(aGETINS[1])
	nLin := 0

	If lUsePrAlt .And. cUsaIntEs == 'S' .And. M->TJ_SITUACA == 'L'
		aGETINS  := NGALTPROD( aGETINS, aHeaIns, M->TJ_CODBEM, 'TL', 'MNTA420', , IIf( ALTERA, M->TJ_ORDEM, '' ) )
	EndIf
	cChavSTL := M->TJ_ORDEM
	cChavSTL += M->TJ_PLANO
	cChavSTL += M->TL_TAREFA

	//Begin Transaction

        MNT420GAR(nOPCX) //funcao para verificar se o servico tem controle de garantia

        If nOPCX == 3 .or. nOPCX == 4
            NG420CALDF() //Alterado para chamar esta funcao ao inves de NG420DTFIM()
            lPRI420 := .T.
            For ny := 1 To Len(aDATINS)

                If lPRI420 .AND. !Empty(aDATINS[ny][2]) .AND. !Empty(aDATINS[ny][4])
                    lPRI420 := .F.
                    dMIN := aDATINS[ny][2]
                    hMIN := aDATINS[ny][3]
                    dMAX := aDATINS[ny][4]
                    hMAX := aDATINS[ny][5]
                Else
                    If !Empty(aDATINS[ny][2])
                        If aDATINS[ny][2] < dMIN
                            dMIN := aDATINS[ny][2]
                            hMIN := aDATINS[ny][3]
                        Else
                            If aDATINS[ny][3] < hMIN
                                hMIN := aDATINS[ny][3]
                            EndIf
                        EndIf
                    EndIf

                    If !Empty(aDATINS[ny][4])
                        If aDATINS[ny][4] > dMAX
                            dMAX := aDATINS[ny][4]
                            hMAX := aDATINS[ny][5]
                        Else
                            If aDATINS[ny][5] > hMAX
                                hMAX := aDATINS[ny][5]
                            EndIf
                        EndIf
                    EndIf
                EndIf
            Next

            M->TJ_DTMPINI := dMIN
            M->TJ_HOMPINI := hMIN

            nPos1 := aScan(aCHOICE,"TJ_DTMPFIM")

            If nPos1 <= 0 .Or. Empty(M->TJ_DTMPFIM)
                M->TJ_DTMPFIM := dMAX
            EndIf

            M->TJ_HOMPFIM := hMAX

            l420Grava := .T.

            If nOPCX == 3
                
                cBEMRET := M->TJ_CODBEM

                aArea := GetArea()

                dbSelectArea( "STJ" )
                dbSetOrder( 01 )
                While dbSeek( xFilial( "STJ" ) + M->TJ_ORDEM )
                    ConfirmSX8()
                    M->TJ_ORDEM := GETSXENUM( "STJ","TJ_ORDEM" )
                End While

                RestArea( aArea )

                //Verifica se Gera OP
                If M->TJ_SITUACA == 'L'
                    //---------------------------------------------------
                    //Gera ordem de Producao para a OS
                    //---------------------------------------------------
                    cUsaIntPc := AllTrim(GetMV("MV_NGMNTPC"))
                    If cUsaIntPc == "S"
                        //Irá verificar apenas o primeiro Produto Manutenção do parâmetro
                        cCODPRO := If(FindFunction("NGProdMNT"), NGProdMNT("M")[1], GetMv("MV_PRODMNT"))
                        dDataIni := MNT420DTOP(M->TJ_DTORIGI)
                        dDataFim := MNT420DTOP(M->TJ_DTORIGI)

                        // Busca o C.C. do bem na TPN ou utiliza o C.C. da ordem de serviço quando seja do tipo localização.
                        cCusto := IIf( M->TJ_TIPOOS == 'B', NGFilTPN( M->TJ_CODBEM, M->TJ_DTORIGI, SubStr( Time(), 1, 5 ), , xFilial( 'ST9' ) )[2],;
                            M->TJ_CCUSTO )

                        If !fGERAOPNEW(cCODPRO,1,M->TJ_ORDEM,dDataIni,dDataFim,,,cCusto,"PLANO 000000")
                            l420Grava :=  .F.
                        EndIf
                    EndIf
                EndIf

                If l420Grava
                    //Grava a O.S.
                    RecLock("STJ",.T.)
                    For ny := 1 To Fcount()
                        nx := "m->" + FieldName(ny)

                        If "_FILIAL"$Upper(nx)
                            FieldPut(ny, xFilial('STJ'))
                        Else
                            CC := &NX.
                            FieldPut(ny, &nx.)
                        EndIf
                    Next ny
                    STJ->( MsUnlock() )

                    cCodOS    := STJ->TJ_ORDEM
                EndIf

                l420Grava := NG420GRAVA( nOpcX ) //Realiza gravação dos insumos previstos.

                MNT420FIT( .F. ) //Destrava a rotina de gravação de insumos em inclusão.

            ElseIf nOPCX == 4
                dbSelectArea("STJ")
                dbGoto(nREGSTJ)
                cCodOS := STJ->TJ_ORDEM
                // VERIFICA SE CONFIRMOU A ALTERAÇÃO NOS INSUMOS
                lRetAlte := NG420ALTE(.T.)
		    EndIf

            If l420Grava .And. lRetAlte
                /* ATENCAO
                    Esta alteracao foi feita para corrigir um problema pontual com a Geracao de Solicitacao de Compras (funcao 'NGINTCOMPEST()'),
                onde o MNTA420, diferente de outras rotinas (como o MNTA410), gera primeiro a solicitacao, para só depois gravar a O.S.
                Se for alterar, tem que ser avaliado um jeito de mudar a logica de gravacao para ser semelhante a do MNTA410 (O.S. antes da Solicitacao)
                O Problema é a alteracao 'NG420ALTE()' que utiliza o estado anterior da STJ.
                Obs.: Isto nao foi avaliado nesta alteracao, porque o cliente estava parado na producao esperando esta atualizacao.
                */
                //Altera a O.S.

                If nOPCX <> 3
                    RecLock("STJ",.F.)
                    For ny := 1 To Fcount()
                        nx := "m->" + FieldName(ny)

                        If "_FILIAL"$Upper(nx)
                            FieldPut(ny, xFilial('STJ'))
                        Else
                            CC := &NX.
                            FieldPut(ny, &nx.)
                        EndIf
                    Next ny
                    MSUNLOCK("STJ")
                EndIf

                If NGCADICBASE("TJ_MMSYP","A","STJ",.F.)
                    MsMM(M->TJ_MMSYP,80,,M->TJ_OBSERVA,1,,,"STJ","TJ_MMSYP")
                EndIf

                //Grava o status da ordem de servico se o servico for contralado por follow-up
                If nOPCX == 3
                    dbSelectArea("ST4")
                    dbSetOrder(01)
                    If dbSeek(xFilial("ST4")+STJ->TJ_SERVICO)
                        If ST4->T4_FOLLOWU == "S" .And. STJ->TJ_SITUACA == "P" .And. STJ->TJ_TERMINO == "N"
                            dbSelectArea("TQW")
                            dbSetOrder(03)
                            If dbSeek(xFILIAL("TQW")+"6 ")
                                dbSelectArea("STJ")
                                RecLock("STJ",.F.)
                                STJ->TJ_STFOLUP := TQW->TQW_STATUS
                                MsUnlock("STJ")
                            EndIf
                        EndIf

                        //Gera nao-conformidade
                        If Val(STJ->TJ_PLANO) == 0 .And. FindFunction("NGGERAFNC")
                            NGGERAFNC(STJ->TJ_ORDEM,STJ->TJ_CODBEM,STJ->TJ_SERVICO,STJ->TJ_DTORIGI)
                        EndIf
                    EndIf
                EndIf

                //---------------------------------------------------
                //If nOPCX == 3
                    lSTJAchou  := A420STJBUS(M->TJ_CODBEM)

                    dbSelectArea("ST9")
                    dbSetOrder(1)

                    If dbSeek(cFILBEM+M->TJ_CODBEM)
                        RecLock("ST9",.F.)
                        If Empty(ST9->T9_TERCEIR)
                            ST9->T9_TERCEIR := "1"
                        EndIf

                        If M->TJ_TERCEIR = "1" .And. lSTJAchou = .F.
                            ST9->T9_TERCEIR := M->TJ_TERCEIR
                        EndIf

                        If M->TJ_TERCEIR = "2" .Or. lSTJAchou = .T.
                            ST9->T9_TERCEIR := "2"
                        EndIf

                        MsUnlock("ST9")
                    EndIf
                //EndIf
                //---------------------------------------------------

                If nOPCX == 4
                    dbSelectArea("STJ")
                    nRecSTJ := Recno()

                    If Len(aGETINS) > 0 .And. lAlterou
						//If !Empty(aGetInSal[1,1]) //-- GV evita recklock quando ha O.S. é enviada inicialmente sem insumos (opc=3) e depois alterada com insumos(opc=4)
                         	fNG420ATIN() // Gravando os Insumos...
						//EndIf
                    EndIf

					//-- Força uma limpeza na tabela STL e analisa se está tudo certo
					cSeqArqInf := ""
					For nSTLIns := 1 To Len(aGETINS)
						nSTLLin := aScan(aHeaIns,{|x| Trim(Upper(x[2])) == "TL_SEQTARE" })
						cSeqArqInf += aGETINS[(nSTLIns),nSTLLin]+"#"
					Next nSTLIns

				    dbSelectArea("STL")
					STL->(dbSetOrder(3))
					If STL->(dbSeek(xFilial("STL")+STJ->TJ_ORDEM+STJ->TJ_PLANO))
						While STL->(!EoF()) .And. xFilial("STL")+STJ->TJ_ORDEM+STJ->TJ_PLANO == STL->(TL_FILIAL+TL_ORDEM+TL_PLANO)
							If !(STL->TL_SEQTARE $ cSeqArqInf)
								RecLock("STL", .F.)
									dbDelete()
								MsUnlock("STL")
							EndIf
							STL->(dbSkip())
						End
					EndIf

                    dbSelectArea('STJ')
                    dbgoto(nRecSTJ)
                EndIf

                //If lSaveSTQ
                //    NG420ATETA()//Gravando as Etapas...
                //EndIf

                //If lSaveTTC
                //     MNT420ATSI() //Gravando os Sintomas..
                //EndIf

                //If lSaveSTN
                //    fCommitSTN() //Gravando as Ocorrências.. 
                //EndIf

                EvalTrigger() // Processa Gatilhos

                If ExistBlock("MNTA4204")
                    ExecBlock("MNTA4204",.F.,.F.)
                EndIf

                If ExistBlock("NgAddEtapa")
                    ExecBlock("NgAddEtapa",.F.,.F.)
                EndIf

                dbSelectArea("STJ")

                If ExistBlock("NGETAPNEX")
                    ExecBlock("NGETAPNEX",.F.,.F.)
                EndIf

            EndIf

        ElseIf nOPCX == 5 // EXCLUSAO

            dbSelectArea("STJ")
            dbGoto(nREGSTJ)

            cCodOS := STJ->TJ_ORDEM

            //Set Filter to
            If !NGGERCOTAC(STJ->TJ_ORDEM)[1]
                l420Grava := .F.
            EndIf

            //Checa se existe SA com Pre-Requisicao
            If l420Grava .And. !NGCHKSAPR(STJ->TJ_ORDEM,STJ->TJ_PLANO,,.F.,.T.)
                l420Grava := .F.
            EndIf

            If l420Grava .And. ExistBlock("NGTERMOT")
                If !ExecBlock("NGTERMOT",.F.,.F.)
                    l420Grava := .F.
                EndIf
            EndIf

            If l420Grava

                cSALVASTJ := STJ->TJ_CODBEM

                If NGDELETOS( STJ->TJ_ORDEM, STJ->TJ_PLANO )

                    //Exclui o lancamento de contador relacionado ao bem do Contador 1
                    If !EMPTY(STJ->TJ_HORACO1) .And. STJ->TJ_POSCONT > 0
                        MNT470EXCO(STJ->TJ_CODBEM,STJ->TJ_DTORIGI,STJ->TJ_HORACO1,1)
                    EndIf

                    //Exclui o lancamento de contador relacionado ao bem do Contador 2
                    If !EMPTY(STJ->TJ_HORACO2) .And. STJ->TJ_POSCON2 > 0
                        MNT470EXCO(STJ->TJ_CODBEM,STJ->TJ_DTORIGI,STJ->TJ_HORACO2,2)
                    EndIf

                    If ExistBlock("MNTA420G")
                        ExecBlock("MNTA420G",.F.,.F.)
                    EndIf

                    // chama funcao para alteracao do campo Observacao
                    //If lObserv
                        //NG400ALTMM(nREGSTJ) 
                    //EndIf
                Else
                    DisarmTransaction()
                    lMsgExec := .T. // Utiliza somente mensagem de erro do ExecAuto.
                EndIf

            EndIf
		
        EndIf

        dbSelectArea(cALIASTJ)
        lREFRESH := .T.
        Set Key VK_F10 To
        Set Key VK_F11 To
        Set Key VK_F8 To
        Set Key VK_F7 To

        If l420Grava .And. nOPCX == 5 // EXCLUSAO
            lSTJAchou  := A420STJBUS(cSALVASTJ)
            dbSelectArea("ST9")
            dbSetOrder(1)
            If dbSeek(cFILBEM+M->TJ_CODBEM)
                RecLock("ST9",.F.)
                If lSTJAchou = .F.
                    ST9->T9_TERCEIR := "1"
                EndIf
                ST9->(MsUnlock())
            EndIf
        EndIf

        cPxSeq	:= Space(3)
        cPxQSeq	:= Space(3)
        nQTETA	:= 0
        nQTARE	:= 0

        // Ponto de Entrada para execução antes da inclusão, alteração ou exclusão do registro.
        If l420Grava .And. ExistBlock("MNTA420X")
            l420Grava := ExecBlock("MNTA420X",.F.,.F.,{STJ->TJ_ORDEM})
        EndIf

        If l420Grava .And. lRetAlte
            //Confirma a transação
            ConfirmSX8()
            // Ponto de Entrada para execução após inclusão, alteração ou exclusão do registro.
            If ExistBlock("MNTA420P")
                ExecBlock("MNTA420P",.F.,.F.,{nOPCX})
            EndIf
        Else
            RollbackSx8()
            //DisarmTransaction()
            //Caso esteja integrado ao RM efetua a exclusão da O.S.
            If SuperGetMV( "MV_NGINTER",.F.,"N" ) == "M"
                NGMUMntOrd(STJ->(RecNo()),5,.T.)
            EndIf
        Endif

	//End Transaction

	If l420Grava .And. lRetAlte

		If ExistBlock( 'MNTA420Z' )
			
			/*-----------------------------------------------------------------------+
			| Ponto de Entrada similar ao MNTA420P, porém sem controle de transação. |
			+-----------------------------------------------------------------------*/
			ExecBlock( 'MNTA420Z', .F., .F., { nOpcX, aGETINS, aHeaIns, aGetInsAL } )
		
		EndIf

	EndIf

	If !l420Grava .Or. !lRetAlte
		If nOPCX == 3 //Inclusão
			cMsgErr:= "Devido à inconsistência o processo de inclusão não foi efetuado."+CRLF+cInfoCompl
		ElseIf nOPCX == 4 .And. !lMsgExec//Alteração
			cMsgErr:="Devido à inconsistência o processo de alteração não foi efetuado."+CRLF+cInfoCompl
		EndIf
		//Limpa conteúdo da variável cCodOS para manter o legado no Return
		cCodOS := ''
	EndIf

	//Reposicionada gravação para que seja possível realizar rollback em ambiente Oracle
	If l420Grava .And. STJ->TJ_SITUACA = 'L'
		dbSelectArea("STJ")
		dbSetOrder(1)
		If ExistBlock("NGIMPOS")
			If !ExecBlock("NGIMPOS",.F.,.F.,{stj->tj_plano,stj->tj_ordem,stj->tj_dtmpini})
				l420Grava := .F.
				cCodOS 	  := ''
			EndIf
		EndIf
		
		//Chama a funcao especifica para fazer copias da ordem de servico
		If l420Grava .And. nCOPIAOS = 2 .And. nOPCx == 3
			NGCOPIAOS(M->TJ_ORDEM,"000000")
		EndIf
	EndIf

	If l420Grava .And. FindFunction("MNTW215") .AND. (M->TJ_SITUACA == 'L' .AND. nOPCx == 3)
		MNTW215(,{M->TJ_ORDEM})
		//-- para o portal -- precisamos que o 420 grave data e hora fim
		If !lOper6
			cChavSTL := xFilial("STL")+cChavSTL //-- Chave Principal
			For nSTLIns := 1 To Len(oJsPost:STL)
				cChavTPSTL:= oJsPost:STL[nSTLIns]:GetJSonObject("TL_TIPOREG")
				cChavCDSTL:= PadR(oJsPost:STL[nSTLIns]:GetJSonObject("TL_CODIGO"), 15 )
				dbSelectArea("STL")
				STL->(dbSetOrder(1)) //TL_FILIAL+TL_ORDEM+TL_PLANO+TL_TAREFA+TL_TIPOREG+TL_CODIGO+TL_SEQRELA+M->TL_SEQRELA
				If STL->(DbSeek(cChavSTL+cChavTPSTL+cChavCDSTL+"0"))
					RecLock("STL", .F.)
					If oJsPost:STL[nSTLIns]:GetJSonObject("TL_DTFIM") <> Nil
						STL->TL_DTFIM:= StoD(StrTran(oJsPost:STL[nSTLIns]:GetJSonObject("TL_DTFIM"),"-",""))
					EndIf
					If oJsPost:STL[nSTLIns]:GetJSonObject("TL_HOFIM") <> Nil
						STL->TL_HOFIM:= oJsPost:STL[nSTLIns]:GetJSonObject("TL_HOFIM")
					EndIf
					STL->(MsUnlock())
				EndIf
			Next nSTLIns 
		EndIf
	EndIf

	dbSelectArea("STJ")
	dbSetOrder(nORDSTJ)

	//--------------------------------------------------
	//  Retorna conteudo de variaveis padroes
	//--------------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)

	//VarInfo("[SOLAPIOS"+APIVERSAO+"][lRetCod]"+Time(),lRetCod)
	//VarInfo("[SOLAPIOS"+APIVERSAO+"][l420Grava]"+Time(),l420Grava)
	//VarInfo("[SOLAPIOS"+APIVERSAO+"][cCodOS]"+Time(),cCodOS)

return If(!lRetCod, l420Grava, cCodOS)

//----------------------------------------------------------------
//  NG420ININS - Função baseada no MNTA420 para apoio fnCorretiva
//---------------------------------------------------------------
Static Function NG420ININS(nOPCX)

	Local aNAO      := {}
	Local cKEY      := ''
	Local cGETWHILE := '' 
	Local nG        := 0
	Local nTarSTL   := 0

	nQTARE := 0

	cKEY := M->TJ_ORDEM + M->TJ_PLANO + M->TL_SEQRELA
	cGETWHILE := "TL_FILIAL == xFilial('STL') .and. "
	cGETWHILE += "TL_ORDEM  == M->TJ_ORDEM .and. "
	cGETWHILE += "TL_PLANO  == M->TJ_PLANO .and. "
	cGETWHILE += "TL_SEQRELA == m->TL_SEQRELA"

	aNAO := { 	/*"TL_DTFIM"  , "TL_HOFIM"  , */"TL_ORDEM"  , "TL_PLANO"  , "TL_SEQUENC", "TL_SEQRELA", "TL_NOMSEQ" ,;
				"TL_NOMTREG", "TL_CUSTO"  , "TL_CUSTO2" , "TL_CUSTO3" , "TL_CUSTO4" , "TL_CUSTO5" , "TL_CUSENT1",;
				"TL_CUSENT2", "TL_CUSENT3", "TL_CUSENT4", "TL_CUSENT5", "TL_OCORREN", "TL_REPFIM" , "TL_NUMSEQ" ,;
				"TL_CODOBS" , 'TL_PCTHREX', "TL_CONTROL", "TL_ETAPA"  , "TL_GARANTI", "TL_NOMETAP", "TL_NOMLOCA",;
				"TL_NUMLOTE", "TL_LOTECTL", "TL_DTVALID", "TL_NUMSERI", "TL_POSCONT", "TL_POSCON2" }

	/*-----------------------------+
	| Integração SIGAGFR x SIGALOC |
	+-----------------------------*/
	If SuperGetMV( 'MV_NG1LOC', .F., .F. )

		aAdd( aNAO, 'TL_AS' )

	EndIf

	If NGCADICBASE("TL_PERMDOE","A","STL",.F.)
		Aadd(aNAO,"TL_PERMDOE")
	EndIf

	If NGCADICBASE("TL_MOEDA","A","STL",.F.)
		Aadd(aNAO,"TL_MOEDA")
	EndIf

	If !lUSATARG
		cKEY += M->TL_TAREFA
		cGETWHILE += ".and. TL_TAREFA == m->TL_TAREFA"
		Aadd(aNAO,"TL_TAREFA")
		Aadd(aNAO,"TL_NOMTAR")
	EndIf

	dbSelectArea( "STL" )
	dbSetOrder(3)

	If nOPCX == 3  //Codigo para trazer os campos virtuais em branco na inclusao
		dbGoBottom()
		dbSkip()
	EndIf

	aHEAINS := CABECGETD("STL", aNAO,2)

	//Inclui coluna de registro atraves de funcao generica
	ADHeadRec("STL",aHEAINS)

	If nOPCX == 3
		aGETINS := BLANKGETD(aHeaIns)
	Else
		aGETINS := MAKEGETD("STL", cKEY,aHeaIns, cGETWHILE) //-- Forço sempre o envio dos insumos via API
		If Empty(aGETINS)
			aGETINS := BLANKGETD(aHeaIns)
		EndIf

	EndIf

	nSEE := aSCAN(aHEAINS,{|x| AllTrim(Upper(X[2])) == "TL_SEQTARE"})
	For NG := 1 To Len(aGETINS)
		xx := aScan(aHeaIns,{|x| Trim(Upper(x[2])) == "TL_TIPOREG"})
		M->TL_TIPOREG := If(xx > 0, aGETINS[nG][xx], " ")

		xx := aScan(aHeaIns,{|x| Trim(Upper(x[2])) == "TL_CODIGO"})
		M->TL_CODIGO := If(xx > 0, aGETINS[nG][xx], Space(15))

		xx := aScan(aHeaIns,{|x| Trim(Upper(x[2])) == "TL_NOMCODI"})
		If xx > 0

			aGetIns[nG][xx] := VirtInsumo( M->TL_TIPOREG, M->TL_CODIGO, GDFieldGet( 'TL_LOJA', nG, .F., aHeaIns, aGetIns ) )
		
		EndIf

		If nSEE > 0
			If ng = 1
				cPxSeq := aGETINS[ng,nSEE]
			Else
				If aGETINS[ng,nSEE] > cPxSeq
					cPxSeq := aGETINS[ng,nSEE]
				EndIf
			EndIf
			nQTARE ++
		EndIf
	Next

	nQTDHEA := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_QUANTID" })
	nTIPHEA := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_TIPOREG" })

	If nQTDHEA > 0
		aHEAINS[nQTDHEA,6]  := "NAOVAZIO() .And. POSITIVO() .And. NG420QUANT(oGet:aCOLS[oGet:nAt,nTIPHEA],M->TL_QUANTID,oGet:Acols,oGet:nAt)"
	EndIf

	nUSACAL := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_USACALE" })
	nCODINS := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_CODIGO" })
	nDATAIN := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_DTINICI" })
	nHORAIN := aSCAN(aHEAINS, {|x| AllTrim(Upper(X[2])) == "TL_HOINICI" })

	If nUSACAL > 0
		aHEAINS[nUSACAL,6]  := "Pertence('SN') .And. NGCHKCALEN(oGet:aCOLS[oGet:nAt,nCODINS],6,'ST1','T1_TURNO') .And. MNT420ACHO(oGet:Acols,oGet:nAt)"
	EndIf

	If nDATAIN > 0  .And. nHORAIN > 0
		aHEAINS[nDATAIN,6] := "NAOVAZIO() .And. NGDTAINSUIN(M->TL_DTINICI) .And. NGVDTIN420()"
		aHEAINS[nHORAIN,6] := "NG420HOINI( oGet:aCols, oGet:nAt, oGet:aHeader )"
	EndIf

	If nTIPHEA > 0
		aHEAINS[nTIPHEA,6] := "PERTENCE('MPFTE') .And. NGVALTERC(M->TL_TIPOREG) .And. NGRETNOREG(M->TL_TIPOREG) .And. "
		aHEAINS[nTIPHEA,6] += 'MNT420ACHO( oGet:aCols, oGet:nAt ) .And. NGCLEARSTL() .And. NG420VLTR( oGet:aCols, oGet:nAt, oGet:aHeader )'
	EndIf

	If nCODINS > 0
		aHEAINS[nCODINS,6] += " .And. MNT420BSA('','') "
	EndIf

	If ( nPosLocali := aScan( aHEAINS, { |x| AllTrim( Upper( X[2] ) ) == 'TL_LOCALIZ' } ) ) > 0

		aHEAINS[nPosLocali,6]  := "MNTA420LOC( .T. )"
		aHEAINS[nPosLocali,13] := "MNTA420WHE( 'TL_LOCALIZ' )"

	EndIf

	If ( nTarSTL := GDFieldPos( 'TL_TAREFA', aHeaIns ) ) > 0

		aHeaIns[nTarSTL,6]  := "MNTA420Vld( 'TL_TAREFA' )"
		aHeaIns[nTarSTL,9]  := 'TT9COR'
		aHeaIns[nTarSTL,13] := ''

	EndIf

	dbSelectArea( "STL" )
	dbSetOrder(1)

Return Nil

//----------------------------------------------------------------
//  NG420INETA - Função baseada no MNTA420 para apoio fnCorretiva
//---------------------------------------------------------------
Static Function NG420INETA(nOPCX)

	Local aNAO	    := {}
	Local cKEY      := ''
	Local cGETWHILE := ''
	Local nTarSTQ   := 0
	Local nx	    := 0

	nQTETA		:= 0
	cKEY		:= M->TJ_ORDEM + M->TJ_PLANO
	cGETWHILE	:= "TQ_FILIAL == xFilial('STQ') .and. TQ_ORDEM == M->TJ_ORDEM .and. TQ_PLANO == M->TJ_PLANO"
	aNAO		:= {"TQ_ORDEM","TQ_PLANO","TQ_TIPRES","TQ_OPCAO",;
						"TQ_NOMSITU","TQ_OK","TQ_TIPORES","TQ_OPCAO","TQ_CODFUNC"}

	If SuperGetMv( 'MV_NGTARGE', .F., '2' ) == '2'

		aAdd( aNao, 'TQ_TAREFA' )
		aAdd( aNao, 'TQ_NOMTARE' )
	
	ElseIf TT9->( FieldPos( 'TT9_CARACT' ) ) == 0

		aAdd( aNao, 'TQ_NOMTARE' )

	EndIf

	aHEAETA := CABECGETD( 'STQ', aNAO, 2 )

	//Inclui coluna de registro atraves de funcao generica
	ADHeadRec("STQ",aHEAETA)

	If nOPCX == 3
		aGETETA := BLANKGETD(aHeaEta)
	Else
		aGETETA := MAKEGETD("STQ", cKEY,aHeaEta, cGETWHILE)
		If Empty(aGETETA)
			aGETETA := BLANKGETD(aHeaEta)
		EndIf
	EndIf

	nSEE := aSCAN(aHEAETA,{|x| AllTrim(Upper(X[2])) == "TQ_SEQTARE"})
	For nx = 1 To Len(aGETETA)
		If nSEE > 0
			If nx = 1
				cPxQSeq := aGETETA[nx,nSEE]
			Else
				If aGETETA[nx,nSEE] > cPxQSeq
					cPxQSeq := aGETETA[nx,nSEE]
				EndIf
			EndIf
			nQTETA ++
		EndIf
	Next nx

	If ( nTarSTQ := GDFieldPos( 'TQ_TAREFA', aHeaEta ) ) > 0

		aHeaEta[nTarSTQ,6]  := "MNTA420Vld( 'TQ_TAREFA' )"
		aHeaEta[nTarSTQ,9]  := 'TT9COR'
		aHeaEta[nTarSTQ,13] := ''

	EndIf

Return Nil

//----------------------------------------------------------------
//  NG420INSIN - Função baseada no MNTA420 para apoio fnCorretiva
//---------------------------------------------------------------
Static Function NG420INSIN(nOPCX)

    Local aNAO := {},cKEY,cGETWHILE

    cKEY		:= M->TJ_ORDEM + M->TJ_PLANO
    cGETWHILE	:= "TTC_FILIAL == xFilial('TTC') .and. TTC_ORDEM == M->TJ_ORDEM .and. TTC_PLANO == M->TJ_PLANO"
    aNAO		:= {"TTC_CODBEM","TTC_ORDEM","TTC_PLANO","TTC_DATA"}

    If NGCADICBASE("TTC_CDSERV","D","TTC",.F.) //Santa Cruz
        aAdd(aNAO,"TTC_CDSERV");aAdd(aNAO,"TTC_DESERV");aAdd(aNAO,"TTC_DTEXEC");aAdd(aNAO,"TTC_SEREXE")
    EndIf

    aHEASIN := CABECGETD("TTC", aNAO)

    //Inclui coluna de registro atraves de funcao generica
    ADHeadRec("TTC",aHEASIN)

    If nOPCX == 3
        aGETSIN := BLANKGETD(aHEASIN)
    Else
        aGETSIN := MAKEGETD("TTC", cKEY,aHEASIN, cGETWHILE)
        If Empty(aGETSIN)
            aGETSIN := BLANKGETD(aHEASIN)
        EndIf
    EndIf

Return Nil

//----------------------------------------------------------------
//  fnCheck - Função baseada no MNTA420 para apoio fnCorretiva
//---------------------------------------------------------------
static function fnCheck(nOpcx,cFilTroc)
	Local nPOS420 := 0
	Local lRet 	  := .T. //Utilizar a variavel, para fechamento de tabelas no multiempresa
	Local cFilSt9
	//Local cUnidade := ""
	Local nTamTAF  := FWTamSX3( 'TAF_CODNIV' )[1]

	//Verifica a data inicio da ordem de servico
	If !MNT420DTIN()
		lRet :=  .F.
	EndIf

	If M->TJ_DTORIGI == dDatabase .And. M->TJ_DTORIGI >= Date() .And. M->TJ_HORACO1 > Time()
		MsgStop( "A hora do contador 1 não pode ser maior que a hora atual." )
		lRet :=  .F.
	EndIf

	//Verifica as datas de parada da O.S. 
	If (!Empty(M->TJ_HOPRINI) .AND. M->TJ_HOPRINI <> "  :  ") .AND. Empty(M->TJ_DTPRINI)
		ShowHelpDlg("ATENÇÃO",{"Data de Início da Parada não preenchida."},2,{"Preencha todos os campos de data de parada."},2)
		lRet :=  .F.
	ElseIf (Empty(M->TJ_HOPRINI) .OR. M->TJ_HOPRINI == "  :  ") .AND. !Empty(M->TJ_DTPRINI)
		ShowHelpDlg("ATENÇÃO",{"Hora de Início da Parada não preenchida."},2,{"Preencha todos os campos de data de parada."},2)
		lRet :=  .F.
	EndIf

	If lRet .and. M->TJ_SITUACA = "C"
		If !MNT420NIE()
			lRet := .F.
		EndIf
	EndIf

	cFilSt9 := NGTrocaFil("ST9", cFilTroc)

	If lRet .and. nOPCX == 3
		If !NGOSABRVEN(M->TJ_CODBEM,M->TJ_SERVICO,.T.,.T.,.T.,,cFilTroc,,,1)
			lRet := .F.
		EndIf
	EndIf

	If lRet

		If ( nPos420 := aScan(aChoice,{|x| Trim( Upper(x) ) == "TJ_CODAREA"}) ) == 0
			M->TJ_CODAREA := ST4->T4_CODAREA
		EndIf

		If ( nPos420 := aScan(aChoice,{|x| Trim( Upper(x) ) == "TJ_TIPO"}) ) == 0
			M->TJ_TIPO := STE->TE_TIPOMAN
		EndIf

		If nOpcx == 3
			If M->TJ_TIPOOS == 'B'

				dbSelectArea("ST9")
				dbSetOrder(1)
				If dbSeek(cFilSt9 + M->TJ_CODBEM)

					If ( nPos420 := aScan(aChoice, {|x| Trim( Upper(x) ) == "TJ_CCUSTO"}) ) == 0
						M->TJ_CCUSTO := ST9->T9_CCUSTO
					EndIf

					If ( nPos420 := aScan(aChoice, {|x| Trim( Upper(x) ) == "TJ_CENTRAB"}) ) == 0
						M->TJ_CENTRAB := ST9->T9_CENTRAB
					EndIf

					If ( nPos420 := aScan(aChoice, {|x| Trim( Upper(x) ) == "TJ_PRIORID"}) ) == 0
						M->TJ_PRIORID := ST9->T9_PRIORID
					EndIf
				EndIf

			ElseIf M->TJ_TIPOOS == 'L'

				dbSelectArea( 'TAF' )
				dbSetOrder( 7 )
				If msSeek( FWxFilial( 'TAF' ) + 'X2' + SubStr( M->TJ_CODBEM, 1, nTamTAF ) )

					If ( nPos420 := aScan(aChoice, {|x| Trim( Upper(x) ) == "TJ_CCUSTO"}) ) == 0
						M->TJ_CCUSTO := TAF->TAF_CCUSTO
					EndIf

					If ( nPos420 := aScan(aChoice, {|x| Trim( Upper(x) ) == "TJ_CENTRAB"}) ) == 0
						M->TJ_CENTRAB := TAF->TAF_CENTRA
					EndIf
				EndIf

			EndIf
		EndIf

		M->TJ_TERMINO := "N"
		M->TJ_USUARIO := IIf( Len(STJ->TJ_USUARIO) > 15, cUsername, SubStr(cUsuario, 7, 15) )

		cBemRet := M->TJ_CODBEM

	EndIf

	If lRet .and. nOpcx == 3
		If !NGMNTOSCO(M->TJ_TIPOOS,M->TJ_CODBEM,M->TJ_SERVICO,M->TJ_DTORIGI,'Val(STJ->TJ_PLANO) = 0')
			lRet := .F.
		EndIf
	EndIf

	If (nOpcx == 3) .And. lRet

		//Adicionada validação que impede prosseguir com contador preenchido e hora vazio
		/* If lRet .And. !NGCONTRET(M->TJ_DTORIGI,M->TJ_POSCONT,M->TJ_HORACO1,TIPOACOM,;
			M->TJ_DTORIGI,M->TJ_POSCON2,M->TJ_HORACO2,TIPOACOM2,.T.)
			lRet := .F.
		EndIf */

		// INCLUIDO 06/03/03 TESTE DE HISTORICO  - In cio
		If lRet .And. TIPOACOM .and. nOPCX <> 5
			/* If M->TJ_POSCONT > 0
				If !NGCHKHISTO(cBEMRET,M->TJ_DTORIGI,M->TJ_POSCONT,M->TJ_HORACO1,1,,.T.,cFilSt9) .Or.;
						!NGVALIVARD(cBEMRET,M->TJ_POSCONT,M->TJ_DTORIGI,M->TJ_HORACO1,1,.T.,,cFilSt9)
					lRet := .F.
				EndIf
			EndIf */ 

			//Verifica se o veiculo tem viagem escalada
			If lRet .and. !NGCHKTMS(cBEMRET,M->TJ_DTORIGI,M->TJ_HORACO1)
				lRet := .F.
			EndIf
		EndIf

		/* If lRet .And. TipoAcom2 .And. M->TJ_POSCON2 > 0 .And. nOPCX <> 5
			If !NGCHKHISTO(cBEMRET,M->TJ_DTORIGI,M->TJ_POSCON2,M->TJ_HORACO2,2,,.T.,cFilSt9) .Or.;
					!NGVALIVARD(cBEMRET,M->TJ_POSCON2,M->TJ_DTORIGI,M->TJ_HORACO2,2,.T.,,cFilSt9)
				lRet := .F.
			EndIf
		EndIf */
	EndIf

	If lRet .and. !NGCONFBLQBE(M->TJ_CODBEM,"C")
		lRet := .F.
	EndIf

	If lRet .AND. (nOPCX==3 .OR. nOPCX==4)
		//If !MNTA420GAR(aGETINS,aHEAINS)
		//	lRet := .F.
		//EndIf
	EndIf

	If lRet .and. ExistBlock("MNTA4207")
		lRet := ExecBlock("MNTA4207",.F.,.F.)
	EndIf

	If nOpcx == 5

		If lRet	

			/*--------------------------------------------------------------------------------+
			| Consiste se existe SA vinculada diretamente a OS, sem um insumo ter gerado a SA |
			+--------------------------------------------------------------------------------*/
			lRet := MNTVldSAOS( M->TJ_ORDEM )

		EndIf

		If lRet .And. ExistBlock("MNTA420F")
			lRet := ExecBlock("MNTA420F",.F.,.F.)
		EndIf
	
	EndIf

	If lRet .And. Inclui
		dbSelectArea("STJ")
		M->TJ_CONTINI := M->TJ_POSCONT
		M->TJ_USUAINI := cUserName
	EndIf

	//Realiza travamento da rotina de gravação de insumos para inclusões.
	If nOpcX == 3 .And. lRet
		If !MNT420FIT( .T. )
			lRet :=  .F.
		EndIf
	EndIf

	//---------------------------------------------------
	//Mensagm Única - Integra OS gerada com o backoffice
	//---------------------------------------------------
	If lRet
		If AllTrim(GetNewPar("MV_NGINTER","N")) == "M" .And. (nOpcx == 3 .Or. nOpcx == 4) .And. M->TJ_SITUACA == 'L' //Mensagem Unica
			lRet := NGMUMntOrd(STJ->(RecNo()),nOpcx,.T.)
		EndIf
	EndIf
	//---------------------------------------------------

	//Realiza destravamento da rotina de gravação de insumos para inclusões.
	If !lRet .And. nOpcX == 3
		MNT420FIT( .F. )
	EndIf
return lRet

//----------------------------------------------------------------
//  fnChkPrv - Função baseada no MNTA420 para apoio fnCorretiva
//---------------------------------------------------------------
static function fnChkPrv(cCALENMAN)
	Local nI		:= 0

	Private cIntSFC := If( FindFunction("NGINTSFC"), NGINTSFC(.F.), "" )

	dbSelectArea("STF")

	If Inclui //Se for inclusão.
		If !NGOSABRVEN( M->TF_CODBEM,M->TF_SERVICO,.T.,.T.,.T.,, ) //Função que alerta a existência de O.S. vencidas.
			Return .F.
		EndIf
	EndIf
	
	 If !MNT120CAL( cCALENMAN )
		Return .F.
	EndIf

	//Valida se a data informada da OS e um dia util e se tem
	//escecao de calendario
	If !NGVALEXCAL(M->TJ_DTORIGI,cCALENMAN)
		Return .F.
	EndIf


	//Verifica a data inicio da ordem de servico
	If !MNT420DTIN()
		Return .F.
	EndIf
	If !NGPREVBSS(M->TJ_TIPOOS,M->TJ_CODBEM,M->TF_SERVICO,M->TJ_DTORIGI,M->TF_SEQRELA,.T.)
		Return .F.
	EndIf

	// INCLUIDO 06/03/03 TESTE DE HISTORICO  - In cio

	If TIPOACOM
		If !Empty(cBEMRET)
			/* If !NGCONTRET(m->tj_dtorigi,m->tj_poscont,m->tj_horaco1,TIPOACOM,;
			m->tj_dtorigi,m->tj_poscon2,m->tj_horaco2,TIPOACOM2,.T.)
				Return .F.
			EndIf
			If M->TJ_POSCONT > 0
				If !NGCHKHISTO(cBEMRET,M->TJ_DTORIGI,M->TJ_POSCONT,M->TJ_HORACO1,1,,.T.)
					Return .F.
				EndIf
				If !NGVALIVARD(cBEMRET,M->TJ_POSCONT,M->TJ_DTORIGI,M->TJ_HORACO1,1,.T.)
					Return .F.
				EndIf
			EndIf

			If TIPOACOM2 .And. M->TJ_POSCON2 > 0
				If !NGCHKHISTO(cBEMRET,M->TJ_DTORIGI,M->TJ_POSCON2,M->TJ_HORACO2,2,,.T.)
					Return .F.
				EndIf
				If !NGVALIVARD(cBEMRET,M->TJ_POSCON2,M->TJ_DTORIGI,M->TJ_HORACO2,2,.T.)
					Return .F.
				EndIf
			EndIf */
		EndIf
	EndIf

	// VALIDAÇÃO DE INSUMOS QUE ANTECEDE A GRAVAÇÃO DA O.S.
	For nI := 1 To Len( aGetIns )
		If !aGetIns[nI,Len( aGetIns[nI] )] .And. aGetIns[nI,nPosTpReg] == 'P' .And. !NGPROBLQ( aGetIns[nI,nPosCodIn] )
			Return .F.
		EndIf
	Next

	If ExistBlock( 'MNTA4106' )
		If !ExecBlock( 'MNTA4106', .F., .F., { aGetIns, aHeaIns } )
			Return .F.
		EndIf
	EndIf

	// Caso integrado modelo de Chao de Fabrica (SIGASFC)
	// Realiza consistencia de calendário entre MNT x SFC
	If !Empty(cIntSFC) .And. !Empty(NGVRFMAQ(M->TJ_CODBEM)) .And. ( FindFunction("SFCNGVCAL") .And. !SFCNGVCAL(cCalenMan) )
		Return .F.
	EndIf

	If Inclui
		dbSelectArea("STJ")
		M->TJ_CONTINI := M->TJ_POSCONT
		M->TJ_USUAINI := cUserName

	EndIf

	//---------------------------------------------------
	//integra OS gerada no backoffice antes de gerar SC1, SCP e afins para que se mantenha a integridade
	If AllTrim(GetNewPar("MV_NGINTER","N")) == "M" .And. M->TJ_SITUACA == 'L' //Mensagem Unica
		M->TJ_USUARIO := If(Len(STJ->TJ_USUARIO) > 15,cUsername,Substr(cUsuario,7,15))
		M->TJ_SERVICO := STF->TF_SERVICO
		M->TJ_INTPRJ  := ''
		M->TJ_INTTSK  := ''
		lOK := NGMUMntOrd(STJ->(RecNo()),3,.T.)
		If !lOK
			Return .F.
		EndIf
	EndIf

	//+-------------------------------------------------------------------+
	//| Verificar se Gera OP											  |
	//+-------------------------------------------------------------------+
	If M->TJ_SITUACA == 'L'
		//+-------------------------------------------------------------------+
		//| Gera ordem de Producao para a OS                           		  |
		//+-------------------------------------------------------------------+
		cUsaIntPc := AllTrim(GetMV("MV_NGMNTPC"))
		If cUsaIntPc == "S"
			cCODPRO := If(FindFunction("NGProdMNT"), NGProdMNT("M")[1], GetMv("MV_PRODMNT")) //Ira verificar apenas o primeiro Produto Manutencao do parametro
			dDataIni := MNT420DTOP(M->TJ_DTORIGI)
			dDataFim := MNT420DTOP(M->TJ_DTORIGI)
			cCusto := NgFilTPN(M->TJ_CODBEM,M->TJ_DTORIGI,SubStr(Time(),1,5),,xFilial("ST9"))[2] //Buscar o C.C. do bem na TPN
			If !fGERAOPNEW(cCODPRO,1,M->TJ_ORDEM,dDataIni,dDataFim,,,cCusto,"PLANO 000001")
				Return .F.
			EndIf
		EndIf
	EndIf

Return .T.

//----------------------------------------------------------------
//  fOcorrGetD - Função baseada no MNTA420 para apoio fnCorretiva
//---------------------------------------------------------------
Static Function fOcorrGetD( nOpcX )

	Local aNoField := {}
	Local nTarSTN  := 0
	Local nProble  := 0

	aNoField := {'TN_ORDEM', 'TN_PLANO', 'TN_SEQRELA', 'TN_CAUSA',;
		'TN_NOMCAUS', 'TN_SOLUCAO', 'TN_NOMSOLU', 'TN_SEQUENC' }

	If SuperGetMv( 'MV_NGTARGE', .F., '2' ) == '2'

		aAdd( aNoField, 'TN_TAREFA' )
		aAdd( aNoField, 'TN_NOMETAR' )

	EndIf

	FillGetDados( nOpcx, 'STN', , , , , aNoField, , , , { || fColsOcr() }, .T., aHeaOcr )

	If ( nTarSTN := GDFieldPos( 'TN_TAREFA', aHeaOcr ) ) > 0

		aHeaOcr[nTarSTN,6]  := "Mnta420Vld( 'TN_TAREFA' )"
		aHeaOcr[nTarSTN,9]  := "TT9COR"

	EndIf

	If ( nProble := GDFieldPos( 'TN_CODOCOR', aHeaOcr ) ) > 0

		aHeaOcr[nProble,6]  := "MNTA420Vld( 'TN_CODOCOR' )"
		aHeaOcr[nProble,9]  := "ST8420"

	EndIf

	PutFileInEof( 'STN' )

	FWFreeArray( aNoField )

Return

//----------------------------------------------------------------
//  fColsOcr - Função baseada no MNTA420 para apoio fnCorretiva
//---------------------------------------------------------------
Static Function fColsOcr()

	Local aGetAux  := {}
	Local cAlsSTN  := GetNextAlias()
	Local cFields  := "%"
	Local cCast    := ''
	Local cJoin    := "%"
	Local cDbase   := TCGetDB()
	Local lUseTarG := SuperGetMv( 'MV_NGTARGE', .F., '2' ) == '1'

	If lUseTarG

		cFields += " ,STN.TN_TAREFA  "
		cFields += " ,TT9.TT9_DESCRI "

		cJoin += "INNER JOIN "
		cJoin +=	RetSQLName( 'TT9' ) + " TT9 ON "
		cJoin +=		"TT9.TT9_FILIAL = " + ValToSQL( FWxFilial( 'TT9' ) ) + " AND "
		cJoin +=		"TT9.TT9_TAREFA = STN.TN_TAREFA AND "
		cJoin +=		"TT9.D_E_L_E_T_ = ' ' "

	EndIf

	cCast := ", STN.TN_DESCRIC " // INFORMIX

	Do Case
		
		Case cDbase == 'ORACLE'
			
			cCast := ", UTL_RAW.CAST_TO_VARCHAR2( dbms_lob.substr( STN.TN_DESCRIC, 2000, 1 ) ) AS TN_DESCRIC "
		
		Case cDbase == 'POSTGRES'
			
			cCast := ", COALESCE( CAST( CAST( STN.TN_DESCRIC AS bytea ) AS bytea ), '' ) AS TN_DESCRIC "
			
		Case 'MSSQL' $ cDbase

			cCast := ", ISNULL( CAST( CAST( STN.TN_DESCRIC AS VARBINARY( 2000 ) ) AS VARCHAR( 2000 ) ),'') AS TN_DESCRIC "
	
	End Case

	cFields += cCast
	cFields += "%"
	cJoin   += "%"

	BeginSQL Alias cAlsSTN

		SELECT
			STN.TN_CODOCOR,
			ST8.T8_NOME   ,
			STN.R_E_C_N_O_
			%exp:cFields%
		FROM
			%table:STN% STN
		INNER JOIN
			%table:ST8% ST8 ON
				ST8.T8_FILIAL  = %xFilial:ST8%  AND
				ST8.T8_CODOCOR = STN.TN_CODOCOR AND
				ST8.%NotDel%
		%exp:cJoin%
		WHERE
			STN.TN_FILIAL  = %xFilial:STN%     AND
			STN.TN_ORDEM   = %exp:M->TJ_ORDEM% AND
			STN.TN_PLANO   = %exp:M->TJ_PLANO% AND
			STN.TN_SEQRELA = '0'               AND
			STN.%NotDel%

	EndSQL

	If (cAlsSTN)->( !EoF() )
	
		While (cAlsSTN)->( !EoF() )

			aGetAux := {}

			If lUseTarG
				
				aAdd( aGetAux, (cAlsSTN)->TN_TAREFA )
				aAdd( aGetAux, (cAlsSTN)->TT9_DESCRI )

			EndIf

			aAdd( aGetAux, (cAlsSTN)->TN_CODOCOR )
			aAdd( aGetAux, (cAlsSTN)->T8_NOME )
			aAdd( aGetAux, (cAlsSTN)->TN_DESCRIC )
			aAdd( aGetAux, 'STN' )
			aAdd( aGetAux, (cAlsSTN)->R_E_C_N_O_ )
			aAdd( aGetAux, .F. )

			aAdd( aGetOcr, aClone( aGetAux ) )

			(cAlsSTN)->( dbSkip() )

		End

	Else 

		aAdd( aGetOcr, aClone( BlankGetD( aHeaOcr )[1] ) )

	EndIf

	(cAlsSTN)->( dbCloseArea() )

	FWFreeArray( aGetAux )  

Return


//------------------------------------------------------------------------
// GERAOP - Função baseada no MNTUTIL para MNTA420 para apoio fnCorretiva
//------------------------------------------------------------------------
Static Function fGERAOPNEW(cPROD,nQTD,cOS,dINI,dFIM,cVLOC,cFil,cCusto,cObs,nOpc,lRetArray)

	Local aMATA650      := {} //Array com os campos
	Local cUnidade := "", cSequenc := ""
	Local lDelSC2 := .F.
	//Variável para mudança do retorno quando chamado via JOB
	Local aTypeRet  := { .T., '' }
	Local lSX8BKP   := __lSX8
	Local cParam05  := ''
	Local lUsaPar05 := Type( 'MV_PAR05' ) != 'U'

	Private lMsErroAuto     := .F.

	Default cFil := xFilial("SC2")
	Default cVLOC := "", cObs := "", cCusto := ""
	Default nOpc := 3
	//Variável que define se apresentará mensagem de erro (com interface gráfica).
	Default lRetArray := .F.
	Default dFIM      := dDataBase

	__lSX8 := .F. //Travativa para nao confirmar SXE ou SXF de outra tabela

	//Busca Local e Unidade do Produto
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek( xFilial("SB1") + cProd )
		If Empty(cVLOC)
			cVLOC := SB1->B1_LOCPAD
		EndIf
		cUnidade := SB1->B1_UM
	EndIf

	//Busca a Sequencia da O.P.
	dbSelectArea("SC2")
	dbSetOrder(1) //C2_FILIAL+C2_NUM+C2_ITEM
	If dbSeek( xFilial("SC2") + cOS + "OS" )

		While !EoF() .And. xFilial("SC2") == SC2->C2_FILIAL  .And. SC2->C2_NUM == cOS .And. SC2->C2_ITEM == "OS"

			If Alltrim(cPROD) == Alltrim(SC2->C2_PRODUTO) .And. Alltrim(SC2->C2_PRODUTO) == Alltrim(NGProdMNT("M")[1])
				Return IIf( !lRetArray, aTypeRet[1], aTypeRet )
			ElseIf nOpc == 5 .And. Alltrim(cPROD) == Alltrim(SC2->C2_PRODUTO)
				lDelSC2 := .T.
				cSequenc := SC2->C2_SEQUEN
				Exit
			EndIf

			cSequenc := SC2->C2_SEQUEN
			dbSelectArea("SC2")
			dbSkip()
		End

	EndIf

	If Empty(cSequenc)
		cSequenc := "001"
	ElseIf nOpc == 3
		cSequenc := PADR(Soma1(cSequenc),3)
	EndIf

	//Inclusao
	If nOpc == 3
		aMata650  := {  {'C2_FILIAL'   ,cFil      ,NIL},;  //Filial
		                {'C2_PRODUTO'  ,cPROD     ,NIL},;  //Produto
		                {'C2_QUANT'    ,nQTD      ,NIL},;  //Quantidade
		                {'C2_ITEM'     ,"OS"      ,NIL},;  //Item - Default "OS" para Ordem de Serviço do MNT
		                {'C2_NUM'      ,cOS       ,NIL},;  //Numero da O.S.
		                {'C2_SEQUEN'   ,cSequenc  ,NIL},;  //Sequencia - Default "001" para Ordem de Serviço do MNT
		                {'C2_LOCAL'    ,cVLOC     ,NIL},;  //Local do Produto
		                {'C2_UM'       ,cUnidade  ,NIL},;  //Unidade Produto
		                {'C2_DATPRI'   ,dINI      ,NIL},;  //Data Inicio
		                {'C2_DATPRF'   ,dDataBase ,NIL},;  //Data Fim
		                {'C2_EMISSAO'  ,dINI      ,NIL},;  //Data de Emissão 
		                {'C2_PRIOR'    ,"500"     ,NIL},;  //Prioridade - Default "500" para Ordem de Serviço do MNT
		                {'C2_DESTINA'  ,"E"       ,NIL},;  //Destinação da O.P. - Default "E" = Estoque
		                {'C2_DATAJI'   ,dINI      ,NIL},;  //Data Ajustada Inicial
		                {'C2_DATAJF'   ,dFIM      ,NIL},;  //Data Ajustada Final
		                {'C2_SEQPAI'   ,"000"     ,NIL},;  //Sequencia da O.P. pai - Default "000"
		                {'C2_BATCH'    ,"S"       ,NIL},;  //Flag do proc. batch - Default "S"
		                {'C2_CC'       ,cCusto    ,NIL},;  //Centro de custo
		                {'C2_OBS'      ,cObs      ,NIL},;  //Observação da O.P.
		                {'C2_STATUS'   ,"U"       ,NIL},;  //Status da O.P. - Default "U" = Suspendida
                        {'C2_ZZTEAR'   ,"MNT"       ,NIL},; 
                        {'C2_ZRECORI'  ,"MNT"       ,NIL},; 
						{'AUTBACKX8'   ,.F.		  ,Nil}}   //Utilizado para não dar RollBack

		                //+---------------------------------------------------------------+
		                //| Ponto de Entrada para inclusão e alteração de campos passados |
		                //| na geração de Ordem de Produção                               |
		                //+---------------------------------------------------------------+
		                If ExistBlock("NGMNTOP")
		                	aMata650 := ExecBlock("NGMNTOP",.F.,.F.,aMata650)
		                EndIf

		If lUsaPar05

			cParam05 := MV_PAR05

		EndIf

		msExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)

		If lUsaPar05

			MV_PAR05 := cParam05

		EndIf

	ElseIf nOpc == 5 .And. lDelSC2

		dbSelectArea("SC2")
		dbSetOrder(1)
		If dbSeek( xFilial("SC2") + cOs + "OS" + cSequenc )

			aMata650 :=  {  {'C2_SEQUEN' 	, C2_SEQUEN , NIL},;
				            {'C2_ITEM'   	, C2_ITEM    , NIL},;
				            {'C2_NUM'	  	, C2_NUM     , NIL},;
				            {'C2_PRODUTO'   , C2_PRODUTO ,NIL}}

			msExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)
		EndIf

	EndIf

	If lMsErroAuto
		// Apresenta MostraErro() em tela somente quando o retorno for lógico
		// e haja interface com o usuário
		If !(lRetArray .And. IsBlind())
			cArqLog  := "MNTA420EXEC_"+DTOS(DATE())+"_"+Left(Time(),2)+SubStr(Time(),4,2)+".LOG"
            cError := MostraErro(GetSrvProfString("Startpath", ""), cArqLog)
			aTypeRet[1] := .F.
		Else
			cError := MostraErro( GetSrvProfString("Startpath","") , ) // Armazena mensagem de erro na raíz.
			//Array contendo o resultado do MostraErro
			aTypeRet := { .F. , cError }
		EndIf
	EndIf

	__lSX8 := lSX8BKP  //Travativa para nao confirmar SXE ou SXF de outra tabela

Return IIf( lRetArray, aTypeRet, aTypeRet[1] )

//-----------------------------------------------------------
// fNG420ATIN - Função baseada no  MNTA420 para apoio fnCorretiva
//-----------------------------------------------------------
Static Function fNG420ATIN()

	// Ricardo Yamashiro
	// 13/11/2025
	Local dDTFIMINS     := ctod("")

	Local cHRFIMINS		:= ""
	Local cNGUNIDT		:= AllTrim(GetMv("MV_NGUNIDT"))
	Local nPOS4201		:= 0
	Local nCOL			:= 0
	Local nHEA			:= 0
	Local nULT 			:= Len(aGETINS[1])
	Local nTARi 		:= aSCAN(aHeaIns,{|x| AllTrim(Upper(X[2])) == "TL_TAREFA" })
	Local nSETi 		:= aSCAN(aHeaIns,{|x| AllTrim(Upper(X[2])) == "TL_SEQTARE" })
	Local nDtInc 		:= aSCAN(aHeaIns,{|x| AllTrim(Upper(X[2])) == "TL_DTINICI"})
	Local nHoInc 		:= aSCAN(aHeaIns,{|x| AllTrim(Upper(X[2])) == "TL_HOINICI"})
	Local nDtFim 		:= aSCAN(aHeaIns,{|x| AllTrim(Upper(X[2])) == "TL_DTFIM"})
	Local nHoFim 		:= aSCAN(aHeaIns,{|x| AllTrim(Upper(X[2])) == "TL_HOFIM"})
	Local nNumSC		:= aSCAN(aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_NUMSC"})
	Local nPosNum       := aSCAN(aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_NUMSA"})
	Local lMMoeda 		:= NGCADICBASE("TL_MOEDA","A","STL",.F.)
	Local lMNTA420R		:= ExistBlock( 'MNTA420R' )
	Local aCstMoeda		:= {}
	Local aArea         := GetArea()
	Local lLogix := AllTrim( GetNewPar("MV_NGINTER", "N") ) == "L"
	Local aLinhaProd := {}
	Local nAEN := 0

	Private lGeraSA	:= NG420CHKSA()
	Private aSAGer		:= {}
	Private cNumSA		:= Space(Len(SCP->CP_NUM)) // Usado na funcao NGGERASA

	lUSATARG	:= If(FindFunction("NGUSATARPAD").And. nTARi > 0,NGUSATARPAD(),.F.)
	lSEQTAR	:= NGCADICBASE("TL_SEQTARE","A","STL",.F.)

	m->TL_PLANO   := If(FunName() = "MNTA420", "000000",M->TJ_PLANO)
	m->TL_SEQRELA := "0  "
	
	dbSelectArea("STL")
	dbSetOrder(1)
	//ProcRegua(Len(aGETINS))
	For nCOL := 1 to Len(aGETINS)
		If lUSATARG
			M->TL_TAREFA := aGETINS[nCOL][nTARi]
		Else
			M->TL_TAREFA  := "0     "
		EndIf
		//IncProc()
		xx := aScan(aHeaIns,{|x| Trim(Upper(x[2])) == "TL_TIPOREG"})
		M->TL_TIPOREG := If(xx > 0, aGETINS[nCOL][xx], " ")

		xx := aScan(aHeaIns,{|x| Trim(Upper(x[2])) == "TL_CODIGO"})
		M->TL_CODIGO := If(xx > 0, aGETINS[nCOL][xx], Space(15))

		If Empty(aGETINS[nCOL][1])
			Loop
		EndIf

		cChavSTL := m->TJ_ORDEM+m->TL_PLANO+m->TL_TAREFA+m->TL_TIPOREG+m->TL_CODIGO+m->TL_SEQRELA
		If lSEQTAR .And. nSETi <> 0
			cChavSTL += aGETINS[nCOL,nSETi]
		EndIf
		If aGETINS[nCOL][nULT]
			If dbSeek(xFilial("STL")+cChavSTL)
				RecLock("STL", .F.)
				//VarInfo("[SOLAPIOS"+APIVERSAO+"][*dbDelete*]  "+Time(),cChavSTL)
				dbDelete()
				MsUnlock("STL")
			EndIf
			Loop
		EndIf

		cChavSTL := m->TJ_ORDEM+m->TL_PLANO+m->TL_TAREFA+m->TL_TIPOREG+m->TL_CODIGO+m->TL_SEQRELA
		If lSEQTAR
			If Empty(aGETINS[nCOL,nSETi])
				cSEQTARE := If(FindFunction("Soma1Old"),PADR(Soma1Old(cPxSeq),3),;
					PADR(Soma1(cPxSeq),3))
				cChavSTL += cSEQTARE
				cPxSeq := cSEQTARE
				aGETINS[nCOL,nSETi] := cPxSeq
			Else
				cChavSTL += aGETINS[nCOL,nSETi]
				cPxSeq 		:= If(aGETINS[nCOL,nSETi] > cPxSeq,aGETINS[nCOL,nSETi],cPxSeq)
			EndIf
		EndIf

		lNOVOSTL := .F.
		dbSelectArea("STL")
		If !dbSeek(xFilial("STL")+cChavSTL)
			lNOVOSTL := .T.
			RecLock("STL",.T.)
			STL->TL_FILIAL	:= xFilial("STL")
			STL->TL_ORDEM	:= M->TJ_ORDEM
			STL->TL_PLANO	:= M->TL_PLANO
			STL->TL_SEQRELA	:= M->TL_SEQRELA
			STL->TL_TAREFA	:= M->TL_TAREFA
			STL->TL_TIPOHOR	:= cNGUNIDT
			If lSEQTAR
				STL->TL_SEQTARE := aGETINS[nCOL,nSETI]
			EndIf
		EndIf

		If !lNOVOSTL
			RecLock("STL",.F.)
		EndIf

		For nHEA := 1 To Len(aHEAINS)
			If aHEAINS[nHEA][10] != "V"
				If !lNOVOSTL
					If nPosNum > 0
						//Caso os campos estejam vazios não altera seus valores.
						If AllTrim(Upper(aHEAINS[nHEA][2])) $ "TL_NUMSA/TL_ITEMSA" .AND. Empty(aGETINS[nCOL][nPosNum])
							Loop
						EndIf
					EndIf
					//Condição para não "limpar" ITEMSC e NUMSC caso estejam preenchidos na STL
					If nNumSC > 0
						//Caso os campos estejam vazios não altera seus valores.
						If AllTrim(Upper(aHEAINS[nHEA][2])) $ "TL_NUMSC/TL_ITEMSC" .AND. Empty(aGETINS[nCOL][nNumSC])
							Loop
						EndIf
					EndIf
				EndIf
				xx := "STL->" + aHEAINS[nHEA][2]
				yy := aGETINS[nCOL][nHEA]
				&xx. := yy
			EndIf
		Next
		STL->TL_USACALE := If(Empty(STL->TL_USACALE),"N",STL->TL_USACALE)
		If STL->TL_USACALE == "S"
			STL->TL_TIPOHOR := "S"
		Else
			STL->TL_TIPOHOR := cNGUNIDT
		EndIf
		STL->TL_GARANTI := If(Empty(STL->TL_GARANTI),"N",STL->TL_GARANTI)


		If FunName() $ 'MNTA990'
			STL->TL_DTINICI	:= aGETINS[nCOL][nDtInc] //Data Início
			STL->TL_HOINICI	:= aGETINS[nCOL][nHoInc] //Hora Início
			STL->TL_DTFIM	:= aGETINS[nCOL][nDtFim] //Data Fim
			STL->TL_HOFIM	:= aGETINS[nCOL][nHoFim] //Hora Fim
		Else

			nPOS4201  := aScan(aDATINS,{|x| x[1]+x[6]+x[7] = M->TL_CODIGO+M->TL_TIPOREG+If(lSEQTAR,STL->TL_SEQTARE,"")})

			dDTFIMINS := aDATINS[nPOS4201][4]
			cHRFIMINS := aDATINS[nPOS4201][5]

			If STL->TL_TIPOREG = "P"
				STL->TL_DTINICI := M->TJ_DTORIGI
				STL->TL_HOINICI := hINI
				STL->TL_DTFIM   := STL->TL_DTINICI
				STL->TL_HOFIM   := STL->TL_HOINICI
			Else
				
				STL->TL_DTINICI := IIf( STL->TL_USACALE == 'S', STL->TL_DTINICI, M->TJ_DTORIGI )
				If Empty( StrTran( STL->TL_HOINICI, ":", "", 1, ) )
					STL->TL_HOINICI := hINI
				EndIf

				If !Empty(dDTFIMINS)
					STL->TL_DTFIM   := dDTFIMINS
					STL->TL_HOFIM   := cHRFIMINS
				Else
					// Calcula a data e hora fim a partir de uma data e hora início
					vDataHora := NGDTHORFIM( STL->TL_DTINICI,STL->TL_HOINICI,STL->TL_QUANTID )
					STL->TL_DTFIM := vDataHora[1] //Data Fim
					STL->TL_HOFIM := vDataHora[2] //Hora Fim
				EndIf
				
			EndIf
		EndIf

		If lMMoeda .And. FindFunction("NGCALCUSMD")
			aCstMoeda     := NGCALCUSMD(stl->tl_codigo,stl->tl_tiporeg,stl->tl_quantid,stl->tl_local,stl->tl_tipohor,,,stl->tl_quanrec)
			STL->TL_CUSTO := aCstMoeda[1]
			STL->TL_MOEDA := aCstMoeda[2]
		Else
			STL->TL_CUSTO := NGCALCUSTI(stl->tl_codigo,stl->tl_tiporeg,stl->tl_quantid,stl->tl_local,stl->tl_tipohor,,,stl->tl_quanrec)
			If lMMoeda
				STL->TL_MOEDA := "1"
			EndIf
		EndIf

		If lLogix
			nAEN := aScan(aHEAINS,{|x| Trim(upper(x[2])) == "TL_CODAEN"})
			If nAEN > 0
				STL->TL_CODAEN := aGETINS[nCOL][nAEN]
			EndIf
			aAdd(aLinhaProd, {STL->TL_CODIGO, M->TJ_ORDEM, STL->TL_QUANTID, STL->TL_CODAEN})
		EndIf

		STL->(MsUnlock())

		If lMNTA420R

			//ExecBlock( 'MNTA420R', .F., .F., { nCol, aGetIns, aHeaIns } )

		EndIf

	Next

	RestArea(aArea)

Return .T.

//-------------------------------
// [FIM] PROCESSOS PARA MNTA420
//-------------------------------
//-------------------------------
// [INI] PROCESSOS PARA MNTA435
//-------------------------------
/*/{Protheus.doc} 
fnCorretiva
@author Gustavo Viana
Baseado em SPMNTA01 - ivan.caproni
@type WS Method
@since Out/2025
@version 1.0
/*/
/*
user function J_MNTA02(cEmpSet, cFilSet)
	local jBody := JsonObject():new()
	local nLen	as numeric
	local aRet	as array

	default cEmpSet := "01"

	RpcSetEnv(cEmpSet, "0101")

	jBody["OPERATION"] := 4
	jBody["STJ"] := JsonObject():new()
	jBody["STJ"]["TJ_ORDEM"] := "001362"
	//jBody["STJ"]["TJ_SITUACA"] := "L"
	//jBody["STJ"]["TJ_TIPOOS"] := "B"
	//jBody["STJ"]["TJ_CODBEM"] := "PR01"
	//jBody["STJ"]["TJ_SERVICO"] := "SV006"
	//jBody["STJ"]["TJ_XCARD"] := "2"
	//jBody["STJ"]["TJ_SOLICIT"] := "000000"
	//jBody["STJ"]["TJ_OBSERVA"] := "TESTE - REST FUNCTION - 16/10"
	//jBody["STJ"]["TJ_DTPRINI"] := Date()
	//jBody["STJ"]["TJ_HOPRINI"] := "08:00"
	//jBody["STJ"]["TJ_DTPRFIM"] := Date()
	//jBody["STJ"]["TJ_HOPRFIM"] := "10:00"

	jBody["STL"] := {} 
	// item 01
	aAdd(jBody["STL"],JsonObject():new())
	nLen := Len(jBody["STL"])

	//jBody["STL"][nLen]["TL_ORDEM"	] := "001335"
	//jBody["STL"][nLen]["TL_SEQRELA"	] := "2"
	jBody["STL"][nLen]["TL_TIPOREG"	] := "M"
	jBody["STL"][nLen]["TL_CODIGO"	] := "1105"
	jBody["STL"][nLen]["TL_QUANTID"	] := 1
	jBody["STL"][nLen]["TL_DTINICI"	] := "2025-10-23"
	jBody["STL"][nLen]["TL_HOINICI"	] := "09:00"
	jBody["STL"][nLen]["TL_DTFIM"	] := "2025-10-23"
	jBody["STL"][nLen]["TL_HOFIM"	] := "10:00"

	// item 02
	aAdd(jBody["STL"],JsonObject():new())
	nLen := Len(jBody["STL"])
	jBody["STL"][nLen]["TL_TIPOREG"	] := "M"
	jBody["STL"][nLen]["TL_CODIGO"	] := "1297"
	jBody["STL"][nLen]["TL_QUANTID"	] := 2
	jBody["STL"][nLen]["TL_DTINICI"	] := "2025-10-23"
	jBody["STL"][nLen]["TL_HOINICI"	] := "09:00"
	jBody["STL"][nLen]["TL_DTFIM"	] := "2025-10-23"
	jBody["STL"][nLen]["TL_HOFIM"	] := "11:00"

	// item 03
	aAdd(jBody["STL"],JsonObject():new())
	nLen := Len(jBody["STL"])
	jBody["STL"][nLen]["TL_TIPOREG"	] := "M"
	jBody["STL"][nLen]["TL_CODIGO"	] := "717"
	jBody["STL"][nLen]["TL_QUANTID"	] := 2
	jBody["STL"][nLen]["TL_DTINICI"	] := "2025-10-23"
	jBody["STL"][nLen]["TL_HOINICI"	] := "09:00"
	jBody["STL"][nLen]["TL_DTFIM"	] := "2025-10-23"
	jBody["STL"][nLen]["TL_HOFIM"	] := "11:00"

	aRet := U_SPMNTA02(jBody)

	RpcClearEnv()
return

user function SPMNTA02(jBody)
	local cNumOS	:= jBody["STJ"]["TJ_ORDEM"]
	local lFinaliza	:= jBody["OPERATION"] == 6
	Local aRet      := {}
	cErro	:= ""
	oxCabec := jBody["STJ"]
	axItens	:= jBody["STL"]

	aRet:= fManutOS(cNumOS,1,lFinaliza)

	VarInfo("[SPMNTA02][aRet]  "+Time(),aRet)
	
	FWFreeObj(oxCabec)
	FWFreeArray(axItens)
return { Empty(cErro) , cErro }
*/
static function fManutOS(strChave,numIndice,lFinaliza)
	
	// Guarda conteudo e declara variaveis padroes
	Local aNGBEGINPRM := NGBEGINPRM(,,,,.T.)

	// Declaracao das Variaveis dos componentes
	Local nControl  := 0
	Local aPages    := {}
	Local aTitles   := {}
	Local aDadosInd := fMontInd("STJ")
	Local lRetTela  := .F.
	Local lRetTmp   := .F.
	Local aPesq     := {}
	Local aFieldFil := {}

	// Utilizado na tabela temporaria responsável por montar o Browse das O.S.'s
	Local aFields   := {}
	Local aFieldsTMP := {}

	local nX,nCmpSTL

	// Utilizado para validar quando o Browse principial for filtrado
	Private lClearData    := .F.

	Private lArvoreLogica := ( ValType( StrChave ) == "C" .And. ValType( numIndice ) == "N" )
	Private cChave435     := Space(255)

	Private oOrdem
	Private oBtnBuscar
	Private oFolder435
	Private aOrdIx435    := aDadosInd[2]
	Private aBlockInd    := {}
	Private cPrograma    := "MNTA400"
	Private oOk          := LoadBitmap( GetResources(), "ENABLE" )
	Private oVerde       := LoadBitmap( GetResources(), "br_verde" )
	Private oRed         := LoadBitmap( GetResources(), "br_vermelho" )
	Private oLaranja     := LoadBitmap( GetResources(), "br_laranja" )
	Private oAzul        := LoadBitmap( GetResources(), "br_azul" )
	Private oBranco      := LoadBitmap( GetResources(), "LBNO" )
	Private oChecked     := LoadBitmap( GetResources(), "LBOK" )
	Private aSize	     := MsAdvSize(,.F.,420), aObjects := {}
	Private cMarca       := 'XX'
	Private lFoiAlterado := .F.
	Private lCamposSA	 := If(STJ->(FieldPos("TL_NUMSA")) > 0 .And. STJ->(FieldPos("TL_ITEMSA")) > 0, .T., .F.)
	Private Inclui		 := .T.
	Private Altera		 := .T.
	Private lFocusBrw3	 := .F.
	Private aCoBrw2		 := {}
	Private aCoBrw3		 := {}
	Private aCoBrw3_2    := {}
	Private aCoBrw3_3    := {}
	Private aBrw3Old     := {}
	Private aCoBrw4		 := {}
	Private aCoBrw6		 := {}
	Private aCols        := {}
	Private aHoBrw2      := {}
	Private aHoBrw3      := {}
	Private aHoBrw3_2    := {}
	Private aHoBrw3_3    := {}
	Private aHoBrw4      := {}
	Private aHoBrw6      := {}
	Private aHeaExec     := {}
	Private aHeader      := {}
	Private aInsSub      := {}
	Private aCores2      := {}
	Private aTRBK        := {}
	Private aCores       := {} // Cores dos Insumos previstos
	Private noBrw2       := 0
	Private noBrw3       := 0
	Private noBrw4       := 0

	// Flags
	Private lRet435	:= .T. // Flag para indicar se grava os dados ou nao

	// Tamanho de Campos
	Private nLenST1	:= If( Len(ST1->T1_CODFUNC) > 0, Len(ST1->T1_CODFUNC), 6)

	// Tabelas Temporarias
	Private aVETINR := {}
	Private oTmpTbl1
	Private oTmpTbl2
	Private oTmpTbl3
	Private oTmpTbl4
	Private oTmpTbl5
	Private oTmpTbl6
	Private oTmpTbl7
	Private oTmpTbl8
	Private oTmpTbl9

	// Dados Temporarios
	Private aNewSC     := {} // Utilizado no processo de produto alternativo
	Private aOS        := {} // OS do browse principal
	Private aDadosOS   := {} // Espelho do aOS, com dados de insumos, etapas, etc...
	Private aDadosTPZ  := {} // Garantia de Insumos Temporario
	Private aDadosSA   := {} // Registros de S.A.
	Private aVetorCan  := {} // OS canceladas
	Private aVetorFin  := {} // OS finalizadas
	Private aProd435   := {} // PRODUTOS atualizados na rotina. Array utilizado para verificação final do estoque antes de gravar
	Private aLote435   := {} // LOTE atualizados na rotina. Array utilizado para verificação final do estoque antes de gravar
	Private aSubL435   := {} // SUB-LOTE atualizados na rotina. Array utilizado para verificação final do estoque antes de gravar
	Private aEnde435   := {} // ENDERECAMENTO atualizados na rotina. Array utilizado para verificação final do estoque antes de gravar
	Private aNovoSTL   := Nil
	Private aNovoExec  := {}
	Private aNovaOcor  := {}
	Private aTRBQ      := {} // Layout TRB Etapas
	Private aTRBIP     := {} // Layout TRB Insumos Previstos
	Private aEstruAss  := {} // Estrutura da tabela de insumos para associação
	Private aNgBtn     := {}
	Private cOrdemTJ   := Space( Len( STJ->TJ_ORDEM ))
	Private cPlanoTJ   := Space( Len( STJ->TJ_PLANO ))
	Private cCdBemTJ   := Space( Len( STJ->TJ_CODBEM ))
	Private nPosOS	   := 2 // Posição do campo TJ_ORDEM no browse
	Private nPosPL	   := 3 // Posição do campo TJ_PLANO no browse
	Private cFiltSTJ   := "" // Filtro do browse STJ
	Private lChkEtaAnt := .T.

	// Variaveis Utilizadas para o Botao de Conhecimento
	Private cCadastro  := Oemtoansi("Retorno de Ordem de Serviço")
	Private cCadTemp   := cCadastro

	// Variaveis de campo
	Private M->TJ_ORDEM   := cOrdemTJ
	Private M->TJ_PLANO   := cPlanoTJ
	Private M->TJ_CODBEM  := cCdBemTJ
	Private M->TL_TIPOREG := " "
	Private M->TL_DESTINO := " "
	Private M->TL_CODIGO  := Space(Len(stl->tl_codigo))
	Private M->TL_UNIDADE := Space(03)
	Private M->TL_LOCAL   := "  "
	Private M->TL_DTINICI := StoD("")
	Private M->TL_HOINICI := Space(5)
	Private M->TL_DTFIM   := StoD("")
	Private M->TL_HOFIM   := Space(5)
	Private M->TL_QUANTID := 0
	Private M->TL_NUMLOTE := Space(6)
	Private M->TL_LOTECTL := Space(10)
	Private M->TL_LOCALIZ := Space(15)
	Private M->TL_NUMSERI := Space(20)
	Private M->TL_GARANTI := Space(1)
	Private M->TL_TAREFA  := "0     "
	Private M->TL_USACALE := "N"
	Private M->TL_SEQRELA := "0  "

	// Parametros
	Private aARTAR     := {}
	Private lRETORNO   := .F.
	Private cLocaliz   := Space(Len(TPS->TPS_CODLOC))  // Codigo de Localizacao
	Private lNumSeq2   := NGCADICBASE("TL_NUMSEQ2","A","STL",.F.)
	Private aTROCAF3   := {}
	Private cUSAINT1   := AllTrim( GETMv( "MV_NGMNTPC" )) // Integração PCP
	Private cUsaInt2   := AllTrim( GetMv( "MV_NGMNTCM" )) // Integração Compras
	Private cUsaInt3   := AllTrim( GetMv( "MV_NGMNTES" )) // Integração Estoque
	Private cUIntHis   := AllTrim( GetMv( "MV_NGHISES" ))
	Private cUsaGeRe   := " "
	Private lESTNEGA   := If(AllTrim(GETMV("MV_ESTNEG")) == "S",.T.,.F.)
	Private cTENDFLAHA := AllTrim(GETMv("MV_NGTNDFL"))
	Private cGERAPREV  := AllTrim(GETMv("MV_NGGERPR"))
	Private lCUSTO     := If(cUsaInt3 == "N",.T.,.F.)
	Private cVALPECRE  := AllTrim(GETMv("MV_NGCOQPR"))
	Private cParSX6Ret := SuperGetMv("MV_NGREPRE",.F.," ")
	Private cRet400    := SuperGetMv("MV_NGUSUAL",.F.," ")
	Private dDtUlMes   := SuperGetMv('MV_ULMES', .F., " " )
	Private oMenu
	Private cNGINSPREA := "R" // Indica se o insumo e realizado ou previsto, nao deve ser retirado
	Private lOrPai435  := .F. // Indica se apresenta indices de Ordem e Bem Pai
	Private lIntSFC    := FindFunction("NGINTSFC") .And. NGINTSFC() // Verifica se ha integracao com modulo Chao de Fabrica [SIGASFC]
	Private lMMoeda    := NGCADICBASE("TL_MOEDA","A","STL",.F.) // Multi-Moeda

	// Declaracao das Variaveis dos Objetos
	Private lStartVar := .F.
	Private oDlg1
	Private oSay1
	Private oSay2
	Private oSay3
	Private oGet1
	Private oBrw1
	Private oBtn1
	Private oBtn2
	Private oBtn3
	Private oBtn4
	private oBtn5
	Private oChv435
	Private oBrw2
	Private oGrp2
	Private oGd435Ocr
	Private oGd435Ass
	Private oGrp3
	private oBrw4
	Private oBrw5
	Private oBrw6
	Private oBrw7
	Private oGrp4
	Private oGrp5
	Private oSay4
	Private oSay5
	Private oSay6
	Private oSay7
	Private oSay8
	Private oSay9
	Private oGet3
	Private oGet4
	Private oGet5
	Private oGet6
	Private oGet7

	Private bOSLine1
	Private oFont1	  := TFont():New( "Arial",0,-19,,.F.,0,,400,.F.,.F.,,,,,, )
	Private oFont2	  := TFont():New( "Arial",0,-13,,.F.,0,,400,.F.,.F.,,,,,, )
	Private oFont3	  := TFont():New( "Arial",0,-11,,.T.,0,,400,.F.,.F.,,,,,, )
	Private lCORRET	  := .T. // Indica que a OS é corretiva
	Private nControGD := 0   // Variavel para controle da ultima GETDADOS editada devido ao problema de que quando se esta editando a getdados
	// e depois clica direto no OK nao e executado o CODBLOCK de LOSTFOCUS da GETDADOS.

	// Variaveis de Posicionamento  Objetos
	Private nTipoVert
	Private nTipoHorz
	Private nPorcVert
	Private nPorcHorz
	Private nFolIniI
	Private nFolColI
	Private nFolLarg
	Private nFolAltu
	Private nBOSIniI
	Private nBOSColI
	Private nBOSLarg
	Private nBOSAltu
	Private nIPrIniI
	Private nIPrColI
	Private nIPrLarg
	Private nIPrAltu
	Private nFO1IniI
	Private nFO1ColI
	Private nFO1Larg
	Private nFO1Altu
	Private nFO2IniI
	Private nFO2ColI
	Private nFO2Larg
	Private nFO2Altu
	private nFO3IniI
	Private nFO3ColI
	Private nFO3Larg
	Private nFO3Altu
	Private nFO4IniI
	Private nFO4ColI
	Private nFO4Larg
	Private nFO4Altu
	Private nBtCeLin
	Private nBtCeCol
	Private nBtEtLin
	Private nBtEtCol
	Private nSalBtn
	Private nLaToLin
	Private nLaToCol
	Private nBtDista
	Private nFZ2ColI
	Private nFZ2Larg
	Private nTamBotao

	Private lPendInput := .T.
	Private lPartInput := .T.
	Private lTotInput := .T.

	// Variaveis para Ponto de Entrada
	Private aInsNaoGra := {}	//Utilizada no Ponto de Entrada MNTA4353 e MNTA4354
	Private aNBaixaEst := {}	//Ponto de Entrada MNT4356 - Variável para bloqueio de movimentação do estoque
	Private lVldExcG   := .T.	//Flag utilizada em P.E. para que a validação da exclusao do insumo não seja executado duas vezes.
	Private cCodFunc   := ""	//De acordo com a utilização do Ponto de Entrada MNTA435G para gravação do código do funcionário padrão
	Private nIndStq435 := 3  // Índice utilizado para ordenação de etapas

	//Botões da Barra de botões a ser declarado na funcao MNTA435BAR
	Private oBtCalc
	Private oBtSpl
	Private oBtAjd
	Private oBtVsl
	Private oBtImp
	Private oBtRdz
	private oBtRto
	Private oBtCOS
	Private oBtFOS
	Private oBtLgd
	Private oBtBCn
	Private oBtGrv
	Private oBtPEt
	Private oBtRMR
	Private oBtOK
	Private oBtCan
	Private oBtBus

	//Otimização da tela principal
	Private oPanelPrin
	Private oPanelUP1
	Private oPanelUP2
	Private oPanelUP3
	Private oPanelUP31
	Private oPanelUP32
	Private oPanelUP33
	Private oPnlUP34
	Private oPnlUP342
	Private oPnlUP343
	Private oPanelUP4
	Private oPanelUP41
	Private oPanelUP42
	Private oPanelUP43
	Private oPanelUP44
	Private oPnlUP442
	Private oPnlUP443
	Private oPnlUP4431
	Private oPanelUP6
	Private oPnlInput
	Private oPending
	Private oPartially
	Private oTotally

	Private lIntRM := AllTrim(GetNewPar("MV_NGINTER","N")) == "M"
	Private cMsgfValidOK := ""

	/*----------------------------------------------------------------+
	| Valor padrão das perguntas de parametrização da rotina MNTA435. |
	+----------------------------------------------------------------*/
	Pergunte( 'MNT435', .F. )

	/*--------------------------------------------------+
	| Atribuição da váriavel de controle das perguntas. |
	+--------------------------------------------------*/
	cMVPAR01 := cValToChar( MV_PAR01 )

	If ExistBlock( "MNTA4357" )
		cErro := "Foi identificada a existência do Ponto de Entrada MNTA4357 compilado neste ambiente. Informamos que este ponto de entrada foi descontinuado. Para validações adicionais utilize o PE MNTA435N."
	EndIf

	If ExistBlock( 'MNTA4006' )
		cErro := "Foi identificada a existência do Ponto de Entrada MNTA4006 compilado neste ambiente. Informamos que este ponto de entrada foi descontinuado. Para validações adicionais utilize o Ponto de Entrada MNTA400O."
		Return aRet := {lRetTela,aClone(aVetorCan),aClone(aVetorFin),cErro,""}
	EndIf

	If ExistBlock( 'MNTA435H' )
		cErro := "Foi identificada a existência do Ponto de Entrada MNTA435H compilado neste ambiente. Informamos que este ponto de entrada foi descontinuado. Para validações adicionais utilize o Ponto de Entrada MNTA435Q." 
		Return aRet := {lRetTela,aClone(aVetorCan),aClone(aVetorFin),cErro,""}
	EndIf

	If !NGCADICBASE("TB0_FILORD","A","TB0",.F.) .And. NGFUNCRPO("SgaMntEst",.F.) .And. GetMv("MV_SGAMNT") == "S" .And. GetMv("MV_NGSGAES") <> "N"
		If !NGINCOMPDIC("UPDSGA01","00000015391/2010")
			cErro := "UPDSGA01 - 00000015391/2010"
			Return aRet := {lRetTela,aClone(aVetorCan),aClone(aVetorFin),cErro,""}
		EndIf
	EndIf

	If !AMiIN(19,56) //Somente autorizado para o MNT/SGA
		cErro := "Somente autorizado para o MNT/SGA"
		Return aRet := {lRetTela,aClone(aVetorCan),aClone(aVetorFin),cErro,""}
	EndIf

	// Declaracao das Variaveis de dimensionamento de tela
	aAdd(aObjects,{050,050,.T.,.T.})
	aAdd(aObjects,{100,100,.T.,.F.})
	aAdd(aObjects,{100,100,.T.,.F.})

	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.T.)

	// Cores dos insumos previstos
	aAdd(aCores,{"(cTRBIP)->STATUS == '0'","BR_VERMELHO"  })
	aAdd(aCores,{"(cTRBIP)->STATUS == '1'","BR_LARANJA"})
	aAdd(aCores,{"(cTRBIP)->STATUS == '2'","BR_VERDE"   })

	// Alias Tabelas Temporárias
	Private cTRBZ400  := GetNextAlias()
	Private cTRBK400  := GetNextAlias()
	Private cTRBQ400  := GetNextAlias()
	Private cTRBTAR	  := GetNextAlias()
	Private cTRB3400  := GetNextAlias()
	Private cTRBIP	  := GetNextAlias()
	Private cAliOS435 := GetNextAlias()
	Private cAlsExecu := GetNextAlias()
	Private cAlsAssoc := GetNextAlias()
	Private cAlsOcor  := GetNextAlias()

	// Define posicionamento dos objetos
	fPosObjet()

	// Carrega os campos definidos para serem apresentados em tela
	LoadFldSTJ( @aFields )

	// Cabecalho e linha vazia para Motivo Atraso
	aHoBrw4 := NGHeader("TPL", {"TPL_FILIAL","TPL_ORDEM"}, .F. )

	nPosDtF := aScan(aHoBrw4,{|x| Trim(Upper(x[2])) == "TPL_DTFIM" })

	aCoBrw4 := BLANKGETD(aHoBrw4)

	/*------------------------------------+
	| Centraliza montagem dos cabeçalhos. |
	+------------------------------------*/
	fCriaGetD()

	If TT9->( FieldPos( 'TT9_CARACT' ) ) > 0

		/*-----------------------------------------------------+
		| Monta estrutura da tabela temporária de ocorrências. |
		+-----------------------------------------------------*/
		fTrbOcorr()

	EndIf

	// Monta Arq para Insumos
	PutFileInEof("STL")
	fTrbInsPre()

	// Monta Arq para Etapas da OS
	fTrbEtapa()

	Private nTpRg435 := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_TIPOREG"})

	// Variáveis do F3 de Ocorrências (Cauxa X Problema X Solução)
	Private aHeaderSTN := {}

	If aScan( aHeader, { |x| Trim( Upper( x[2] ) ) == "TN_CODOCOR" } ) > 0
		aHeaderSTN := aHeader
	Else
		aHeaderSTN := aHoBrw3
	EndIf

	// Variáveis do F3 de Ocorrências (Cauxa X Problema X Solução)
	Private nCodOcor := aScan( aHeaderSTN, { |x| Trim( Upper( x[2] ) ) == "TN_CODOCOR" })

	// Cria tabela temporária
	fCriaTRB( cAliOS435, aFields, @aPesq, @aFieldFil )

	// Carrega tabela temporária com as O.S.
	fLoadBrw( .F., aFields, .T., strChave )
	If !Empty(cErroGeral)
		return aRet := {lRetTela,aClone(aVetorCan),aClone(aVetorFin),cErroGeral}
	EndIf
	// Objetos para criação das colunas do Browse.
	aColumns	:= fGerCol(aFields)

	//----------------------------------
	// Criação do Browse
	//----------------------------------
	// fRefreshOS( (cAliOS435)->TJ_ORDEM, (cAliOS435)->TJ_PLANO, 1 )

	// Montagem dos FOLDERS
	aTitles  := {"Insumos","Etapas","Ocorrências","Motivo de Atraso"}
	aPages   := {"HEADER 1","HEADER 2","HEADER 3","HEADER 4"}
	nControl := 4

	// Indice para listar os insumos por ordem de aplicação
	IndRegua((cTRBIP),CriaTrab(Nil, .F.),"STATUS",,.F.)

	// Insumos Realizados da Ordem de Servico
	dbSelectArea("STL")
	aCols := aClone(aCoBrw6)

	nTipR := aScan(aHoBrw6,{|x| Trim(Upper(x[2])) == "TL_TIPOREG"})
	cVal3 := x3valid("TL_TIPOREG")

	aHoBrw6[nTipR,6] := StrTran( cVal3, 'NGCLEARSTL()', 'fValDel435(.T.) .And. NGCLEARSTL()' )

	nNumS   := aScan(aHoBrw6,{|x| Trim(Upper(x[2])) == "TL_NUMSEQ"})
	aHeader := aClone(aHoBrw6)

	// Ponto de Entrada para selecionar o executante padrão das etapas de O.S.
	If ExistBlock("MNTA435G")
		cCodFunc := ExecBlock("MNTA435G",.F.,.F.)
	EndIf

	dbSelectArea(cTRBTAR)

	// Montagem do Motivo de Atraso da Ordem de Servico
	aCols   := aClone(aCoBrw4)
	aHeader := aClone(aHoBrw4)

	// Fim da montagem dos folders

	aCols   := aClone(aCoBrw6)
	aHeader := aClone(aHoBrw6)

	lStartVar := .T.

	// Botoes para transformar o insumo previsto em realizado
	/* if Len(aCoBrw2) > 0 // tem insumos
		MNT435CALLB( 1 )
		AdjDtTime()

		// Salvar
		if ! lFinaliza
			If fValidOK(@lRetTmp,.F.)
				fGrava435(,.T.)
			else
				lRetTmp := .F.
			endif
		endif
	endif */

	//nPProd1 := aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_CODIGO" })
	//nPProdM := aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_TIPOREG" })

	if !lFinaliza
		aFieldsTMP := BlankGetD( aHoBrw2 )
		aDadosOS[Len(aDadosOS),5] := Array(Len(axItens)) //BlankGetD( aHoBrw2 ) //aClone(aCoBrw2) //-- Pego os Previstos //-- GV
		for nX := 1 to Len(aDadosOS[Len(aDadosOS),5] )
			If Valtype(aDadosOS[Len(aDadosOS),5,nX] ) == "U"
				aDadosOS[Len(aDadosOS),5,nX] := {}
			EndIf
			for nCmpSTL:= 1 to Len(aFieldsTMP[1])
				aAdd(aDadosOS[Len(aDadosOS),5,nX],aFieldsTMP[1,nCmpSTL])
			Next nCmpSTL
		Next nX
	Else
		If Valtype(aCoBrw6) == "A"
			aDadosOS[Len(aDadosOS),5] := aClone(aCoBrw6)
		EndIf
	EndIf

	Varinfo("aDadosOS",aDadosOS)
	//VarInfo("aHoBrw2",aHoBrw2)
	//VarInfo("aCoBrw2",aCoBrw2)
	//VarInfo("aCoBrw6",aCoBrw6)
	nPRef := 0
	if !lFinaliza
		for nX := 1 to Len(axItens) 
			/* OLD
			if axItens[nX]["TL_TIPOREG"] == "M"

				nP1 := aScan(aCoBrw2,{|x| Alltrim(x[nPProd1]) == Alltrim(axItens[nX]["TL_CODIGO"]) })
				nPM := aScan(aCoBrw2,{|x| Alltrim(x[nPProdM]) == Alltrim(axItens[nX]["TL_TIPOREG"]) })
				nP2 := aScan(aCoBrw6,{|x| Alltrim(x[nPProd2]) == Alltrim(axItens[nX]["TL_CODIGO"]) })

				if nP1 > 0
					N := nP1
					if axItens[nX]["TL_TIPOREG"] == "M"
						nPRef := nP1
						If !Empty(axItens[nX]["TL_CODIGO"])
							dbSelectArea("ST1")
							ST1->(dbSetOrder(1))
							If !(ST1->(dbSeek(xFilial("ST1")+axItens[nX]["TL_CODIGO"])))
								cErro := "Cod. Funcionário não encontrado ["+axItens[nX]["TL_CODIGO"]+"]"
								return aRet := {lRetTela,aClone(aVetorCan),aClone(aVetorFin),cErro}
							EndIf
						EndIf
						MNT435CALLB(2)
						//-- Validação de datas
						If StoD(StrTran(axItens[nX]["TL_DTINICI"],"-","")) > date()
							cErro := "["+axItens[nX]["TL_CODIGO"]+"] - Data de inicio inválida [TL_DTINICI]"
							return aRet := {lRetTela,aClone(aVetorCan),aClone(aVetorFin),cErro}
						EndIf
						If StoD(StrTran(axItens[nX]["TL_DTFIM"],"-","")) > date()
							cErro := "["+axItens[nX]["TL_CODIGO"]+"] - Data fim inválida [TL_DTFIM]"
							return aRet := {lRetTela,aClone(aVetorCan),aClone(aVetorFin),cErro}
						EndIf
						aEval(aHoBrw6,{|x,y| aTail(aCoBrw6)[y] := Iif(axItens[nX]:hasProperty(x[2]),axItens[nX][x[2]],CriaVar(x[2])) })
						if ! lFinaliza
							if axItens[nX]["TL_QUANTID"] <> aDadosOS[1][5][nX][8]
								aDadosOS[1][5][nX][8]:= axItens[nX]["TL_QUANTID"]
							EndIf
							if StoD(StrTran(axItens[nX]["TL_DTINICI"],"-","")) <> aDadosOS[1][5][nX][12]
								aDadosOS[1][5][nX][12]:= StoD(StrTran(axItens[nX]["TL_DTINICI"],"-",""))
							EndIf
							if axItens[nX]["TL_HOINICI"] <> aDadosOS[1][5][nX][13]
								aDadosOS[1][5][nX][13]:= axItens[nX]["TL_HOINICI"]
							EndIf
							if StoD(StrTran(axItens[nX]["TL_DTFIM"],"-","")) <> aDadosOS[1][5][nX][14]
								aDadosOS[1][5][nX][14]:= StoD(StrTran(axItens[nX]["TL_DTFIM"],"-",""))
							EndIf
							if axItens[nX]["TL_HOFIM"] <> aDadosOS[1][5][nX][15]
								aDadosOS[1][5][nX][15]:= axItens[nX]["TL_HOFIM"]
							EndIf
							//aDadosOS[1][5][nX][38] := StrZero(Len(aDadosOS[1,5])+1,3)
							aDadosOS[1][5][nX][41] := Alltrim(Str(Len(aDadosOS[1,5])))
						EndIf
					elseif axItens[nX]["TL_TIPOREG"] $ "PT"
						cErro := "Item pendente de realizar a baixa de pre-requisicao, Por favor realize a baixa da pre-requisição que foi gerada sobre a solicitação ao armazem."
						return aRet := {lRetTela,aClone(aVetorCan),aClone(aVetorFin),cErro}
					endif
		
				ElseIf nPM > 0
					aAdd(aDadosOS[1,5],aClone(aCoBrw2[nPM]))
					N := Len(aDadosOS[1,5])
					if axItens[nX]["TL_TIPOREG"] == "M"
						If !Empty(axItens[nX]["TL_CODIGO"])
							dbSelectArea("ST1")
							ST1->(dbSetOrder(1))
							If !(ST1->(dbSeek(xFilial("ST1")+axItens[nX]["TL_CODIGO"])))
								cErro := "Cod. Funcionário não encontrado ["+axItens[nX]["TL_CODIGO"]+"]"
								return aRet := {lRetTela,aClone(aVetorCan),aClone(aVetorFin),cErro}
							EndIf
						EndIf
						MNT435CALLB(2)
						//-- Validação de datas
						If StoD(StrTran(axItens[nX]["TL_DTINICI"],"-","")) > date()
							cErro := "["+axItens[nX]["TL_CODIGO"]+"] - Data de inicio inválida [TL_DTINICI]"
							return aRet := {lRetTela,aClone(aVetorCan),aClone(aVetorFin),cErro}
						EndIf
						If StoD(StrTran(axItens[nX]["TL_DTFIM"],"-","")) > date()
							cErro := "["+axItens[nX]["TL_CODIGO"]+"] - Data fim inválida [TL_DTFIM]"
							return aRet := {lRetTela,aClone(aVetorCan),aClone(aVetorFin),cErro}
						EndIf
						aEval(aHoBrw6,{|x,y| aTail(aCoBrw6)[y] := Iif(axItens[nX]:hasProperty(x[2]),axItens[nX][x[2]],CriaVar(x[2])) })
						if ! lFinaliza
							if axItens[nX]["TL_CODIGO"] <> aDadosOS[1][5][Len(aDadosOS[1,5])][4]
								aDadosOS[1][5][Len(aDadosOS[1,5])][4] := axItens[nX]["TL_CODIGO"]
							EndIf
							if axItens[nX]["TL_QUANTID"] <> aDadosOS[1][5][nX][8]
								aDadosOS[1][5][Len(aDadosOS[1,5])][8]:= axItens[nX]["TL_QUANTID"]
							EndIf
							if StoD(StrTran(axItens[nX]["TL_DTINICI"],"-","")) <> aDadosOS[1][5][nX][12]
								aDadosOS[1][5][Len(aDadosOS[1,5])][12]:= StoD(StrTran(axItens[nX]["TL_DTINICI"],"-",""))
							EndIf
							if axItens[nX]["TL_HOINICI"] <> aDadosOS[1][5][nX][13]
								aDadosOS[1][5][Len(aDadosOS[1,5])][13]:= axItens[nX]["TL_HOINICI"]
							EndIf
							if StoD(StrTran(axItens[nX]["TL_DTFIM"],"-","")) <> aDadosOS[1][5][nX][14]
								aDadosOS[1][5][Len(aDadosOS[1,5])][14]:= StoD(StrTran(axItens[nX]["TL_DTFIM"],"-",""))
							EndIf
							if axItens[nX]["TL_HOFIM"] <> aDadosOS[1][5][nX][15]
								aDadosOS[1][5][Len(aDadosOS[1,5])][15]:= axItens[nX]["TL_HOFIM"]
							EndIf
							aDadosOS[1][5][Len(aDadosOS[1,5])][38] := StrZero(Len(aDadosOS[1,5])+1,3)
							aDadosOS[1][5][Len(aDadosOS[1,5])][41] := Alltrim(Str(Len(aDadosOS[1,5])))
						EndIf
					endif
				else
					if nP2 == 0
						aAdd(aCoBrw6,Array(Len(aTail(aCoBrw6))))
						aEval(aHoBrw6,{|x,y| aTail(aCoBrw6)[y] := Iif(axItens[nX]:hasProperty(x[2]),axItens[nX][x[2]],CriaVar(x[2])) })
					endif
				endif
			EndIf
			*/
			if axItens[nX]["TL_TIPOREG"] == "M"
				nPProd1 := aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_CODIGO" })
				nPProdM := aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_TIPOREG" })
				If !Empty(axItens[nX]["TL_CODIGO"])
					dbSelectArea("ST1")
					ST1->(dbSetOrder(1))
					If !(ST1->(dbSeek(xFilial("ST1")+axItens[nX]["TL_CODIGO"])))
						cErro := "Cod. Funcionário não encontrado ["+axItens[nX]["TL_CODIGO"]+"]"
						return aRet := {lRetTela,aClone(aVetorCan),aClone(aVetorFin),cErro}
					Else
						aDadosOS[1][5][nX][nPProd1]:= axItens[nX]["TL_CODIGO"]
						aDadosOS[1][5][nX][nPProdM]:= axItens[nX]["TL_TIPOREG"]
					EndIf
					nPProdM := aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_TAREFA" })
					aDadosOS[1][5][nX][nPProdM]:= '0     '
					nPProdM := aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_UNIDADE" })
					aDadosOS[1][5][nX][nPProdM]:= 'H'
					nPProdM := aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_GARANTI" })
					aDadosOS[1][5][nX][nPProdM]:= 'N'
					nPProdM := aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_SEQTARE" })
					aDadosOS[1][5][nX][nPProdM] := StrZero(nX,3)
				EndIf
				//-- Validação de datas
				//If Val(Alltrim(StrTran(axItens[nX]["TL_DTINICI"],"-",""))) > Val(DtoS(date()))
				//	cErro := Alltrim(Str(nX))+":["+axItens[nX]["TL_CODIGO"]+"] - Data de inicio inválida [TL_DTINICI]:"+alltrim(axItens[nX]["TL_DTINICI"])
				//	return aRet := {lRetTela,aClone(aVetorCan),aClone(aVetorFin),cErro}
				//Else
					nPProdM := aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_DTINICI" })
					If nPProdM > 0
						aDadosOS[1][5][nX][nPProdM]:= StoD(StrTran(axItens[nX]["TL_DTINICI"],"-","")) 
					EndIf
					nPProdM := aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_HOINICI" })
					If nPProdM > 0
						aDadosOS[1][5][nX][nPProdM]:= axItens[nX]["TL_HOINICI"]
					EndIf
				//EndIf
				// Ricardo Yamashiro
				// 13/11/2025
				// Retirar validação de data/hora finais
				// Exemplo: Data/Hora inicial 01/01/2020 11:50
				//			Data/Hora final   02/01/2020 02:50

				//If StoD(StrTran(axItens[nX]["TL_DTFIM"],"-","")) > date()
				//	cErro := "["+axItens[nX]["TL_CODIGO"]+"] - Data fim inválida [TL_DTFIM]"
				//	return aRet := {lRetTela,aClone(aVetorCan),aClone(aVetorFin),cErro}
				//Else
					nPProdM := aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_DTFIM" })
					If nPProdM > 0
						aDadosOS[1][5][nX][nPProdM]:= StoD(StrTran(axItens[nX]["TL_DTFIM"],"-","")) 
					EndIf
					nPProdM := aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_HOFIM" })
					If nPProdM > 0
						aDadosOS[1][5][nX][nPProdM]:= axItens[nX]["TL_HOFIM"]
					EndIf
				//EndIf

				nPProdM := aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_QUANTID" })
				aDadosOS[1][5][nX][nPProdM]:= axItens[nX]["TL_QUANTID"]
				aDadosOS[1][5][nX][41] := Alltrim(Str(Len(aDadosOS[1,5])))
			EndIf
		next nX
		MNT435CALLB(2)
	EndIf
	Varinfo("aDadosOS-Fim",aDadosOS)
	AdjDtTime()

	// Salvar
	if !lFinaliza
		If fValidOK(@lRetTmp,.F.)
			fGrava435(,.T.)
		else
			lRetTmp := .F.
		endif
	endif

	// Finalizar OS
	if lFinaliza .and. fValidOk(.F.,.F.)
		Mnt435Fin()
	endif

	// Confirmar - no video fiquei na duvida se ele clicou no confirmar (check verde)
	If lRetTmp .and. fValidOK(@lRetTela,.F.)
		fGrava435(,.F.,.F.)
	else
		lRetTela := .F.
		If !Empty(cMsgfValidOK)
			return aRet := {lRetTela,aClone(aVetorCan),aClone(aVetorFin),cMsgfValidOK}
		EndIf
	endif

	// Deleção de Tabelas Temporárias
	oTmpTbl3:Delete()
	oTmpTbl6:Delete()
	oTmpTbl4:Delete()
	oTmpTbl5:Delete()
	oTmpTblOS:Delete()

	If TT9->( FieldPos( 'TT9_CARACT' ) ) > 0
		oTmpTbl7:Delete()
	EndIf
	
	NGRETURNPRM(aNGBEGINPRM)

	aRet := {lRetTela,aClone(aVetorCan),aClone(aVetorFin),cErro}

Return aRet

Static Function fMontInd(cAliasInd)
	Local aRet := { {} , {} }

	dbSelectArea("SIX")
	dbSetOrder(1)
	dbSeek(cAliasInd)
	While !EoF() .And. SIX->INDICE == cAliasInd
		aAdd(aRet[2], Alltrim(SIX->DESCRICAO) )
		aAdd(aRet[1], Alltrim(SIX->CHAVE) )
		dbSkip()
	End

Return aRet

Static Function fPosObjet()

	Local lFlatMode := If(FindFunction("FLATMODE"),FlatMode(),SetMDIChild())

	nTipoVert := 1 //1024
	nTipoHorz := 1 //1280
	nPorcVert := 1 //% em relação a resolucao maxima
	nPorcHorz := 1 //% em relação a resolucao maxima
	//Verifica resolução Vertical
	If aSize[6] >= 934
		nTipoVert := 1 //1024          1
		nPorcVert := 1
	ElseIf aSize[6] >= 870
		nTipoVert := 2 //960
		nPorcVert := 0.93
	ElseIf aSize[6] >= 774
		nTipoVert := 3 //864
		nPorcVert := 0.82
	ElseIf aSize[6] >= 678
		nTipoVert := 4 //768
		nPorcVert := 0.70 //678/934
	ElseIf aSize[6] >= 630
		nTipoVert := 5 //720
		nPorcVert := 0.65
	ElseIf aSize[6] >= 510
		nTipoVert := 6 //600
		nPorcVert := 0.62
	Else
		nTipoVert := 6 //600
		nPorcVert := 0.42
	EndIf
	//Verifica resolução Horizontal
	If aSize[5] >= 1272
		nTipoHorz := 1 //1280
		nPorcHorz := 1
	ElseIf aSize[5] >= 1144
		nTipoHorz := 2 //1152
		nPorcHorz := 0.9
	ElseIf aSize[5] >= 1016
		nTipoHorz := 3 //1024
		nPorcHorz := 0.8
	Else	//If aSize[5] >= 792
		nTipoHorz := 4 //800
		nPorcHorz := 0.62
	EndIf

	// ------------- Folder -----------------
	nFolIniI := 11 * nPorcVert  //Linha Inicio
	nFolColI := 0.7             //Coluna Inicio (FIXO)
	nFolLarg := 616 * nPorcHorz //Largura
	nFolAltu := 320 * nPorcVert //Altura
	If lFlatMode .And. nTipoVert <= 4
		nFolAltu := 320 * (nPorcVert * 0.9) //Altura
	EndIf
	// ------------- Browse OS --------------
	nBOSIniI := 28              //Linha Inicio (FIXO)
	nBOSColI := 4               //Coluna Inicio (FIXO)
	nBOSLarg := 616 * nPorcHorz //Largura
	nBOSAltu := 110 * nPorcVert //Altura
	If nTipoVert == 2
		nBOSAltu := nBOSAltu * 0.98
	ElseIf nTipoVert == 3
		nBOSAltu := nBOSAltu * 0.94
	ElseIf nTipoVert == 4
		nBOSAltu := nBOSAltu * 0.90
	ElseIf nTipoVert == 5
		nBOSAltu := nBOSAltu * 0.85
	ElseIf nTipoVert == 6
		nBOSAltu := nBOSAltu * 0.80
	EndIf
	// ---------- Folder1 - Insumos ----------

	// ---------- Insumos Previstos ---------
	nIPrIniI := 1/*40 * nPorcVert*/ //Linha Inicio
	nIPrColI := 1//4               //Coluna Inicio (FIXO)
	nIPrLarg := 298 * nPorcHorz //Largura
	nIPrAltu := nFolAltu - 26   //Altura

	// --------- Insumos Realizados ---------
	nFO1IniI := 1/*40 * nPorcVert*/ //Linha Inicio
	nFO1ColI := 326 * nPorcHorz //Coluna Inicio
	nFO1Larg := 615 * nPorcHorz //Largura
	nFO1Altu := nFolAltu - 26   //Altura

	// ---------- Folder2 - Etapas ----------
	nFO2IniI := 1               //Linha Inicio (FIXO)
	nFO2ColI := 1               //Coluna Inicio (FIXO)
	nFO2Larg := 284 * nPorcHorz //Largura
	nFO2Altu := nFolAltu - 26   //Altura
	If nTipoHorz == 4
		nFO2Larg := nFO2Larg * 0.95
	EndIf
	nFZ2ColI := 328 * nPorcHorz //Coluna Inicio (FIXO)
	nFZ2Larg := nFO2Larg
	If nTipoHorz == 2
		nFZ2ColI := nFZ2ColI * 1.017
		nFZ2Larg := nFO2Larg * 0.98
	ElseIf nTipoHorz == 3
		nFZ2ColI := nFZ2ColI * 1.02
		nFZ2Larg := nFO2Larg * 0.97
	ElseIf nTipoHorz == 4
		nFZ2ColI := nFZ2ColI * 1.03
		nFZ2Larg := nFO2Larg
	EndIf
	// ------- Folder3 - Ocorrrencias -------
	nFO3IniI := 1               //Linha Inicio (FIXO)
	nFO3ColI := 1               //Coluna Inicio (FIXO)
	nFO3Larg := 612 * nPorcHorz //Largura
	nFO3Altu := nFolAltu - 26   //Altura
	// ------- Folder4 - Mot. Atrasos -------
	nFO4IniI := 1               //Linha Inicio (FIXO)
	nFO4ColI := 1               //Coluna Inicio (FIXO)
	nFO4Larg := 612 * nPorcHorz //Largura
	nFO4Altu := nFolAltu - 26   //Altura
	// ----------- Botões Centrais ----------
	nBtCeLin := 135 * nPorcVert //Linha
	nBtDista := 35
	nBtCeCol := 612 * nPorcHorz //Coluna
	If nTipoVert == 2
		nBtCeLin := nBtCeLin * 0.98
	ElseIf nTipoVert == 3
		nBtCeLin := nBtCeLin * 0.96
	ElseIf nTipoVert == 4
		nBtCeLin := nBtCeLin * 0.93
	ElseIf nTipoVert == 5
		nBtCeLin := nBtCeLin * 0.90
	ElseIf nTipoVert == 6
		nBtCeLin := nBtCeLin * 0.87
		nBtDista := 31
		nBtCeCol := nBtCeCol - 5
	EndIf

	// ----------- Botões Etapas ------------
	nBtEtLin := 11 //Linha
	nBtEtCol := 289 * nPorcHorz //Coluna
	nSalBtn  := 16
	nTamBotao := 11

	If nTipoVert == 6
		If lFlatMode .And. aSize[6] >= 600
			nSalBtn   := 10
			nTamBotao := 10
		Else
			nSalBtn   := 10
			nBtEtLin  := 2 //Linha
			nTamBotao := 9
		EndIf
	ElseIf nTipoVert == 4 .Or. nTipoVert == 5
		nSalBtn := 12
	EndIf
	If nTipoHorz == 4
		nBtEtCol := nBtEtCol * 0.96
	EndIf
	// ----------- Label TOTAL ------------
	nLaToLin := 285 * nPorcVert //Linha
	nLaToCol := 480 * nPorcHorz //Coluna

Return

Static Function LoadFldSTJ( aFields )

	Local nFields    := 0
	Local aHeaderSTJ := NGHeader( 'STJ',, .F. )
	Local aFieldForc := { 'TJ_ORDEM', 'TJ_PLANO' } // Campos que são obrigatorios há apresentação em tela

	For nFields := 1 To Len( aHeaderSTJ )

		cCampo  := AllTrim( aHeaderSTJ[ nFields, 2 ] )

		If Posicione( 'SX3', 2, cCampo, 'X3_BROWSE' ) == 'S' .Or. ( aScan( aFieldForc, { | x | x == cCampo } ) > 0 )

			// Tratativa para o campo Memo
			If cCampo == 'TJ_OBSERVA'
				aAdd( aFields, { cCampo, aHeaderSTJ[ nFields, 1 ], 'C', 200, aHeaderSTJ[ nFields, 3 ] } )
			Else
				// Campo, Titulo, Tipo, Tamanho, Picture
				aAdd( aFields, { cCampo, aHeaderSTJ[ nFields, 1 ], aHeaderSTJ[ nFields, 8 ], aHeaderSTJ[ nFields, 4 ], aHeaderSTJ[ nFields, 3 ] } )
			EndIf

		EndIf

	Next nFields

	// Ponto de Entrada para eliminar ou adicionar campos da STJ ao mostrar na Tela Inicial
	If ExistBlock( 'MNTA435Q' )
		aFields := ExecBlock( 'MNTA435Q', .F., .F., aFields )
	EndIf

Return

Static Function fCriaGetD()

	Local aNoSTL   := {}
	Local aHeaPadr := {}
	Local aBkpCo   := {}
	Local nPosBrw  := 0

	If TT9->( FieldPos( 'TT9_CARACT' ) ) > 0

		/*------------------------------------------------------------+
		| Lista de campos não apresentados na GetDados de Ocorrências |
		+------------------------------------------------------------*/
		aNoFld := { 'TN_FILIAL', 'TN_ORDEM', 'TN_PLANO', 'TN_SEQUENC', 'TN_SEQRELA' }

		/*-------------------------------+
		| Monta o aHeader de ocorrências |
		+-------------------------------*/
		aHoBrw3 := CabecGetD( 'STN', aNoFld, 2, .T. )

		aNovaOcor := BlankGetD( aHoBrw3 )

		aDel( aNovaOcor[1] , Len( aNovaOcor[1] ) )

		aSize( aNovaOcor[1], Len( aNovaOcor[1] ) - 1 )

		aAdd( aNovaOcor[1] , {} )
								
		aAdd( aNovaOcor[1] , .F. )

		If ( nPosBrw := GDFieldPos( 'TN_TAREFA', aHoBrw3 ) ) > 0

			aHoBrw3[nPosBrw,6]  := "MNA435Vlda( 'TN_TAREFA' )"

		EndIf

		If ( nPosBrw := GDFieldPos( 'TN_CODOCOR', aHoBrw3 ) ) > 0

			aHoBrw3[nPosBrw,6]  := "MNA435Vlda( 'TN_CODOCOR' )"
			aHoBrw3[nPosBrw,9]  := "ST8435"

		EndIf

		If ( nPosBrw := GDFieldPos( 'TN_CAUSA', aHoBrw3 ) ) > 0

			aHoBrw3[nPosBrw,6]  := "MNA435Vlda( 'TN_CAUSA' )"
			aHoBrw3[nPosBrw,9]  := "ST8435"

		EndIf

		If ( nPosBrw := GDFieldPos( 'TN_SOLUCAO', aHoBrw3 ) ) > 0

			aHoBrw3[nPosBrw,6]  := "MNA435Vlda( 'TN_SOLUCAO' )"
			aHoBrw3[nPosBrw,9]  := "ST8435"

		EndIf

		/*--------------------------------------------------------+
		| Lista de campos não apresentados na GetDados de insumos |
		+--------------------------------------------------------*/
		aNoFld := { 'TL_ORDEM'  , 'TL_PLANO'  , 'TL_SEQUENC', 'TL_NOMSEQ' , 'TL_NOMTREG', 'TL_CUSTO2' , 'TL_OBSERVA',;
					'TL_CUSTO3' , 'TL_CUSTO4' , 'TL_CUSTO5' , 'TL_CUSENT1', 'TL_CUSENT2', 'TL_CUSENT3', 'TL_CUSENT4',;
					'TL_CUSENT5', 'TL_OCORREN', 'TL_REPFIM' , 'TL_NUMSEQ' , 'TL_CODOBS' , 'TL_PCTHREX', 'TL_CONTROL',;
					'TL_ETAPA'  , 'TL_GARANTI', 'TL_NOMETAP', 'TL_NOMLOCA', 'TL_NUMLOTE', 'TL_LOTECTL', 'TL_DTVALID',;
					'TL_NUMSERI', 'TL_POSCONT', 'TL_POSCON2', 'TL_LOCALIZ', 'TL_TAREFA' , 'TL_NOMTAR' ,	'TL_LOCAPLI',;
					'TL_NUMSC'  , 'TL_ITEMSC' , 'TL_NOTFIS' , 'TL_SERIE'  , 'TL_FORNEC' , 'TL_LOJA'   ,;
					'TL_NUMSA'  , 'TL_ITEMSA' , 'TL_SEQTARE', 'TL_PERMDOE', 'TL_CODAEN'  }

		aHoBrw3_2 := CabecGetD( 'STL', aNoFld, 2 )

		/*-----------------------------------------------------------+
		| Move o campo TL_SEQRELA para a ultima posição do cabeçalho |
		+-----------------------------------------------------------*/
		If ( nPosBrw := GDFieldPos( 'TL_SEQRELA', aHoBrw3_2 ) ) > 0

			aBkpCo := aClone( aHoBrw3_2[nPosBrw] )

			aDel( aHoBrw3_2 , nPosBrw )

			aSize( aHoBrw3_2, Len( aHoBrw3_2 ) - 1 )

			aAdd( aHoBrw3_2 , aClone( aBkpCo ) )

		EndIf

		/*-------------------------------------------+
		| Cabec. de insumos associados à ocorrencia. | 
		+-------------------------------------------*/
		If ( nPosBrw := GDFieldPos( 'TL_CODIGO' , aHoBrw3_2 ) ) > 0

			aHoBrw3_2[nPosBrw,6] := "MNA435Vlda( 'TL_CODIGO', oGd435Ass )"

		EndIf

		If ( nPosBrw := GDFieldPos( 'TL_QUANTID', aHoBrw3_2 ) ) > 0

			aHoBrw3_2[nPosBrw,6] := "MNA435Vlda( 'TL_QUANTID', oGd435Ass )"

		EndIf

		If ( nPosBrw := GDFieldPos( 'TL_DTINICI', aHoBrw3_2 ) ) > 0

			aHoBrw3_2[nPosBrw,6] := "MNA435Vlda( 'TL_DTINICI', oGd435Ass )"
			aHoBrw3_2[nPosBrw,12] := "CTOD( '' )"

		EndIf

		If ( nPosBrw := GDFieldPos( 'TL_HOINICI', aHoBrw3_2 ) ) > 0

			aHoBrw3_2[nPosBrw,6] := "MNA435Vlda( 'TL_HOINICI', oGd435Ass )"

		EndIf

		If ( nPosBrw := GDFieldPos( 'TL_DTFIM'  , aHoBrw3_2 ) ) > 0

			aHoBrw3_2[nPosBrw,6] := "MNA435Vlda( 'TL_DTFIM', oGd435Ass )"
			aHoBrw3_2[nPosBrw,12] := "CTOD( '' )"

		EndIf

		If ( nPosBrw := GDFieldPos( 'TL_HOFIM'  , aHoBrw3_2 ) ) > 0

			aHoBrw3_2[nPosBrw,6] := "MNA435Vlda( 'TL_HOFIM', oGd435Ass )"

		EndIf

		If ( nPosBrw := GDFieldPos( 'TL_USACALE', aHoBrw3_2 ) ) > 0

			aHoBrw3_2[nPosBrw,12] := "'N'"

		EndIf

		If ( nPosBrw := GDFieldPos( 'TL_TIPOREG', aHoBrw3_2 ) ) > 0

			aHoBrw3_2[nPosBrw,6]  := "MNA435Vlda( 'TL_TIPOREG', oGd435Ass )"
			aHoBrw3_2[nPosBrw,11] := "M=Mão de Obra;P=Produto"

		EndIf

		/*--------------------------------------------------------+
		| Lista de campos não apresentados na GetDados de insumos |
		+--------------------------------------------------------*/
		aNoFld := { 'TL_ORDEM'  , 'TL_PLANO'  , 'TL_SEQUENC', 'TL_NOMSEQ' , 'TL_NOMTREG', 'TL_CUSTO2' , 'TL_OBSERVA',;
					'TL_CUSTO3' , 'TL_CUSTO4' , 'TL_CUSTO5' , 'TL_CUSENT1', 'TL_CUSENT2', 'TL_CUSENT3', 'TL_CUSENT4',;
					'TL_CUSENT5', 'TL_OCORREN', 'TL_REPFIM' , 'TL_NUMSEQ' , 'TL_CODOBS' , 'TL_PCTHREX', 'TL_CONTROL',;
					'TL_ETAPA'  , 'TL_GARANTI', 'TL_NOMETAP', 'TL_NOMLOCA', 'TL_NUMLOTE', 'TL_LOTECTL', 'TL_DTVALID',;
					'TL_NUMSERI', 'TL_POSCONT', 'TL_POSCON2', 'TL_LOCAL'  , 'TL_LOCALIZ', 'TL_TAREFA' , 'TL_NOMTAR' ,;
					'TL_LOCAPLI', 'TL_NUMSC'  , 'TL_ITEMSC' , 'TL_NOTFIS' , 'TL_SERIE'  , 'TL_FORNEC' , 'TL_LOJA'   ,;
					'TL_NUMSA'  , 'TL_ITEMSA' , 'TL_SEQTARE', 'TL_PERMDOE', 'TL_CODAEN'  }

		aHoBrw3_3 := CabecGetD( 'STL', aNoFld, 2 )

		/*-----------------------------------------------------------+
		| Move o campo TL_SEQRELA para a ultima posição do cabeçalho |
		+-----------------------------------------------------------*/
		If ( nPosBrw := GDFieldPos( 'TL_SEQRELA', aHoBrw3_3 ) ) > 0

			aCopSeq := aClone( aHoBrw3_3[nPosBrw] )
			
			aDel( aHoBrw3_3 , nPosBrw )
			
			aSize( aHoBrw3_3, Len( aHoBrw3_3 ) - 1 ) 
			
			aAdd( aHoBrw3_3 , aClone( aCopSeq ) )

		EndIf

	Else

		aHoBrw3   := NGHeader( 'STN', { 'TN_FILIAL', 'TN_TAREFA', 'TN_NOMETAR', 'TN_ORDEM', 'TN_PLANO', 'TN_SEQRELA', 'TN_SEQUENC' }, .F. )

		aNovaOcor := BlankGetD( aHoBrw3 )

	EndIf

	/*--------------------------------------------------------+
	| Lista de campos não apresentados na GetDados de insumos |
	+--------------------------------------------------------*/
	aNoSTL := { "TL_ORDEM"  , "TL_PLANO"  , "TL_SEQUENC", "TL_NOMSEQ" , "TL_NOMTREG", "TL_CUSTO2" , 'TL_NOMTAR' ,;
				"TL_CUSTO3" , "TL_CUSTO4" , "TL_CUSTO5" , "TL_CUSENT1", "TL_CUSENT2", "TL_CUSENT3", "TL_CUSENT4",;
				"TL_CUSENT5", "TL_OCORREN", "TL_REPFIM" , "TL_NUMSEQ" , "TL_CODOBS" , 'TL_PCTHREX', "TL_CONTROL",;
				"TL_ETAPA"  , "TL_GARANTI", "TL_NOMETAP", "TL_NOMLOCA", "TL_NUMLOTE", "TL_LOTECTL", "TL_DTVALID",;
				"TL_NUMSERI", "TL_POSCONT", "TL_POSCON2", 'TL_QUANREC', 'TL_DESTINO', 'TL_LOCAL'  , 'TL_LOCALIZ',;
				'TL_LOCAPLI', 'TL_NUMSC'  , 'TL_ITEMSC' , 'TL_NOTFIS' , 'TL_SERIE'  , 'TL_FORNEC' , 'TL_LOJA'   ,;
				'TL_NUMSA'  , 'TL_ITEMSA' , 'TL_SEQTARE', 'TL_PERMDOE', 'TL_CODAEN' , 'TL_TAREFA'  }

	/*---------------------------+
	| Monta o aHeader de insumos |
	+---------------------------*/
	aHeaPadr  := CabecGetD( 'STL', aNoSTL, 2 )

	/*-----------------------------------------------------------+
	| Move o campo TL_SEQRELA para a ultima posição do cabeçalho |
	+-----------------------------------------------------------*/
	If ( nPosBrw := GDFieldPos( 'TL_SEQRELA', aHeaPadr ) ) > 0

		aBkpCo := aClone( aHeaPadr[nPosBrw] )

		aDel( aHeaPadr , nPosBrw )

		aSize( aHeaPadr, Len( aHeaPadr ) - 1 )

		aAdd( aHeaPadr , aClone( aBkpCo ) )

	EndIf

	/*--------------------------------+
	| Cópia do cabec para executantes |
	+--------------------------------*/
	aHeaExec  := aClone( aHeaPadr )

	/*--------------------------------------+
	| Monta o aCols padrão para executantes |
	+--------------------------------------*/
	aNovoExec := BlankGetD( aHeaExec )

	/*--------------------------------+
	| Cabec. de executantes da etapa. | 
	+--------------------------------*/
	If ( nPosBrw := GDFieldPos( 'TL_CODIGO' , aHeaExec ) ) > 0

		aHeaExec[nPosBrw,6] := "MNA435Vlda( 'TL_CODIGO', oGD435In2 )"

	EndIf

	If ( nPosBrw := GDFieldPos( 'TL_QUANTID', aHeaExec ) ) > 0

		aHeaExec[nPosBrw,6] := "MNA435Vlda( 'TL_QUANTID', oGD435In2 )"

	EndIf

	If ( nPosBrw := GDFieldPos( 'TL_DTINICI', aHeaExec ) ) > 0

		aHeaExec[nPosBrw,6]  := "MNA435Vlda( 'TL_DTINICI', oGD435In2 )"
		aHeaExec[nPosBrw,12] := "CTOD( '' )"

	EndIf

	If ( nPosBrw := GDFieldPos( 'TL_HOINICI', aHeaExec ) ) > 0

		aHeaExec[nPosBrw,6] := "MNA435Vlda( 'TL_HOINICI', oGD435In2 )"

	EndIf

	If ( nPosBrw := GDFieldPos( 'TL_DTFIM'  , aHeaExec ) ) > 0

		aHeaExec[nPosBrw,6] := "MNA435Vlda( 'TL_DTFIM', oGD435In2 )"
		aHeaExec[nPosBrw,12] := "CTOD( '' )"

	EndIf

	If ( nPosBrw := GDFieldPos( 'TL_HOFIM'  , aHeaExec ) ) > 0

		aHeaExec[nPosBrw,6] := "MNA435Vlda( 'TL_HOFIM', oGD435In2 )"

	EndIf

	If ( nPosBrw := GDFieldPos( 'TL_USACALE'  , aHeaExec ) ) > 0

		aHeaExec[nPosBrw,12] := "'N'"

		aNovoExec[1,nPosBrw] := "N"

	EndIf

	If ( nPosBrw := GDFieldPos( 'TL_TIPOREG', aHeaExec ) ) > 0

		aHeaExec[nPosBrw,6]  := "MNA435Vlda( 'TL_TIPOREG', oGD435In2 )"
		aHeaExec[nPosBrw,11] := "M=Mão de Obra"
		aHeaExec[nPosBrw,12] := "'M'"
		aHeaExec[nPosBrw,13] := ".F."

		aNovoExec[1,nPosBrw] := "M"

	EndIf

	FWFreeArray( aBkpCo )
	FWFreeArray( aHeaPadr )
	FWFreeArray( aNoSTL )

Return

Static Function fTrbOcorr()

	Local nInd1     := 0
	Local aEstruOcr := {}

	aAdd( aEstruOcr, { 'TRB_OK'    , 'C' , 02, 0 } )

	For nInd1 := 1 To Len( aHoBrw3_3 )

		aAdd( aEstruOcr, { AllTrim( aHoBrw3_3[nInd1,2] ), aHoBrw3_3[nInd1,8],;
			aHoBrw3_3[nInd1,4], aHoBrw3_3[nInd1,5] } )

		aAdd( aEstruAss, { aHoBrw3_3[nInd1,1], Alltrim( aHoBrw3_3[nInd1,2] ), aHoBrw3_3[nInd1,8],;
			aHoBrw3_3[nInd1,4], aHoBrw3_3[nInd1,5], aHoBrw3_3[nInd1,3] } )

	Next nInd1

	/*------------------------------------------------------------------------+
	| Cria tabela temporária para insumos listados no processo de associação. |
	+------------------------------------------------------------------------*/
	oTmpTbl7 := FWTemporaryTable():New( cAlsAssoc, aEstruOcr )
	oTmpTbl7:AddIndex( '1', { 'TL_SEQRELA' } )
	oTmpTbl7:AddIndex( '2', { 'TRB_OK' } )
	oTmpTbl7:Create() 

	aEstruOcr:= {}

	For nInd1 := 1 To Len( aHoBrw3 )

		If aHoBrw3[nInd1,10] != 'V'

			aAdd( aEstruOcr, { AllTrim( aHoBrw3[nInd1,2] ), aHoBrw3[nInd1,8],;
				aHoBrw3[nInd1,4], aHoBrw3[nInd1,5] } )

		EndIf

	Next nInd1

	aAdd( aEstruOcr, { 'TN_ORDEM'  , 'C', 6 , 0 } )
	aAdd( aEstruOcr, { 'TN_PLANO'  , 'C', 6 , 0 } )
	aAdd( aEstruOcr, { 'TN_SEQRELA', 'C', 3 , 0 } )
	aAdd( aEstruOcr, { 'RECSTN'    , 'N', 10, 0 } )

	/*------------------------------------------------------------------------+
	| Cria tabela temporária para insumos listados no processo de associação. |
	+------------------------------------------------------------------------*/
	oTmpTbl8 := FWTemporaryTable():New( cAlsOcor, aEstruOcr )
	oTmpTbl8:AddIndex( '1', { 'TN_ORDEM' , 'TN_PLANO'  , 'TN_SEQRELA', 'TN_TAREFA' , 'TN_CODOCOR', 'TN_CAUSA', 'TN_SOLUCAO' } )
	oTmpTbl8:AddIndex( '2', { 'TN_TAREFA', 'TN_CODOCOR', 'TN_CAUSA'  , 'TN_SOLUCAO', 'TN_ORDEM'  , 'TN_PLANO' } )
	oTmpTbl8:Create()

	FWFreeArray( aEstruOcr )

Return

Static Function fTrbInsPre()

	Local aLine := {}
	Local nXX
	Local nInd1 := 1
	Local aNAO  := {"TL_FILIAL","TL_ORDEM", "TL_PLANO", "TL_REPFIM",;
		"TL_NUMOP", "TL_ITEMOP", "TL_SEQUEOP", "TL_CODBEM",;
	  	"TL_SERVICO", "TL_SEQMAN", "TL_POSCONT", "TL_POSCON2", "TL_TIPOHOR", "TL_SEQUENC", "TL_SEQRMAN",;
	  	"TL_DOC", "TL_ITEM", "TL_ORIGNFE", "TL_SDOC", "TL_HREXTRA ", "TL_NOMTREG", "TL_NOMSEQ "}

	//Ponto de entrada utilizado para Inibir campos da tabela STL na GetDados.
	If ExistBlock ( "MNTA435E" )
		aNAO := ExecBlock("MNTA435E",.F.,.F.,aNAO)
	EndIf

	aHoBrw2 := CabecGetD( 'STL', aNao, 2 )

	nPosXXX := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_SEQRELA"})
	If nPosXXX > 0
		aTemp := aClone(aHoBrw2[nPosXXX])
		aDel(aHoBrw2,nPosXXX)
		aSize(aHoBrw2,Len(aHoBrw2)-1)
		aAdd(aHoBrw2 , aClone(aTemp) )
	EndIf

	aDBF   := {}
	aTRBIP := {}
	aAdd(aDBF,  {"TL_OK"     ,"C",02, 0 })
	aAdd(aDBF,  {"STATUS","C",01,0})
	aAdd(aTRBIP,{"TL_OK"     ,Nil," "    ,})
	For nXX := 1 To Len(aHoBrw2)
		aAdd(aDBF,  {Alltrim(aHoBrw2[nXX,2]),aHoBrw2[nXX,8],aHoBrw2[nXX,4], aHoBrw2[nXX,5] })
		If aHoBrw2[nXX,8] == "N"
			aAdd(aTRBIP,{Alltrim(aHoBrw2[nXX,2]),Nil,aHoBrw2[nXX,1],aHoBrw2[nXX,3] })
		Else
			If "TL_USACALE" == Alltrim(aHoBrw2[nXX,2])
				aAdd(aTRBIP,{"XX_USACAL",Nil,aHoBrw2[nXX,1],})
			ElseIf "TL_DESTINO" == Alltrim(aHoBrw2[nXX,2])
				aAdd(aTRBIP,{"XX_DESTIN",Nil,aHoBrw2[nXX,1],})
			ElseIf "TL_GARANTI" == Alltrim(aHoBrw2[nXX,2])
				aAdd(aTRBIP,{"XX_TEMGAR",Nil,aHoBrw2[nXX,1],})
			ElseIf "TL_TIPOREG" == Alltrim(aHoBrw2[nXX,2])
				aAdd(aTRBIP,{"XX_NOMINS",Nil,aHoBrw2[nXX,1],})
			Else
				aAdd(aTRBIP,{Alltrim(aHoBrw2[nXX,2]),Nil,aHoBrw2[nXX,1],})
			EndIf
		EndIf

		If "TL_CODIGO" == Alltrim(aHoBrw2[nXX,2])
			nPosTReg := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_TIPOREG"})
			nPosTReg := Alltrim(Str(nPosTReg,6))
			nPosDTF := Alltrim(Str(aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_DTFIM"}) ,6))
			nPosCOD := Alltrim(Str(aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_CODIGO"}) ,6))
			aHoBrw2[nXX,6] := 'If(!Empty(M->TL_CODIGO), fValDel435( .T. ) .And. NGPROD435() .And. ' +;
			"If(aCOLS[n]["+nPosTReg+"] = 'M' .And. !Empty(aCOLS[n]["+nPosDTF+"]) ,NGFUNCRH(M->TL_CODIGO,.T.,aCOLS[n]["+nPosDTF+"],.F.),.T.) .And. MNT435CUS(), .T.)"
		ElseIf "TL_QUANTID" == Alltrim(aHoBrw2[nXX,2])
			aHoBrw2[nXX,6] := 'fValDel435( .T. ) .And. NGQUANT435() .And. MNT435CUS()'
		ElseIf "TL_DTINICI" == Alltrim(aHoBrw2[nXX,2])
			aHoBrw2[nXX,6] := 'fValDel435( .T. ) .And. NG435DTINI() .And. ' +;
			"If(aCOLS[n]["+nPosTReg+"] = 'M' ,NGFUNCRH(aCOLS[n]["+nPosCOD+"],.T.,M->TL_DTINICI,.F.),.T.) .And. MNT435CUS()"
		ElseIf "TL_HOINICI" == Alltrim(aHoBrw2[nXX,2])
			aHoBrw2[nXX,6] := 'fValDel435( .T. ) .And. NG435HOINI() .And. MNT435CUS()'
		ElseIf "TL_DTFIM"   == Alltrim(aHoBrw2[nXX,2])
			aHoBrw2[nXX,6] := 'fValDel435( .T. ) .And. NG435DTFIM() .And. ' +;
			"If(aCOLS[n]["+nPosTReg+"] = 'M' ,NGFUNCRH(aCOLS[n]["+nPosCOD+"],.T.,M->TL_DTFIM,.F.),.T.) .And. MNT435CUS()"
		ElseIf "TL_HOFIM"   == Alltrim(aHoBrw2[nXX,2])
			aHoBrw2[nXX,6] := 'fValDel435( .T. ) .And. NG435HOFIM() .And. MNT435CUS()'
		ElseIf "TL_LOTECTL" == Alltrim(aHoBrw2[nXX,2])
			aHoBrw2[nXX,6] := 'fValDel435( .T. ) .And. NG435LOTCT()'
		ElseIf "TL_NUMLOTE" == Alltrim(aHoBrw2[nXX,2])
			aHoBrw2[nXX,6] := 'fValDel435( .T. ) .And. NG435NUMLO()'
		ElseIf "TL_LOCALIZ" == Alltrim(aHoBrw2[nXX,2])
			aHoBrw2[nXX,6] := 'fValDel435( .T. ) .And. NG435LOCAL()'
		ElseIf "TL_GARANTI" == Alltrim(aHoBrw2[nXX,2])
			aHoBrw2[nXX,6] := "fValDel435( .T. ) .And. PERTENCE( 'SN' ) .And. fNgGar435( 'S' )"
		ElseIf "TL_TIPOREG" == Alltrim(aHoBrw2[nXX,2])
			aHoBrw2[nXX,6] := 'fValDel435( .T. ) .And. NGRETNO435( M->TL_TIPOREG ) .And. MNT435CUS()'
		ElseIf "TL_QUANREC" == Alltrim(aHoBrw2[nXX,2])
			aHoBrw2[nXX,6] := If( Empty( aHoBrw2[nXX,6] ) , "MNT435CUS()" , Alltrim(aHoBrw2[nXX,6]) + " .And. MNT435CUS()" )
		ElseIf "TL_LOCAL" == Alltrim(aHoBrw2[nXX,2])
			aHoBrw2[nXX,6] := 'fValDel435( .T. ) .And. NGVALALMOX() .And. MNT435CUS()'
		EndIf
	Next nXX
	aAdd(aDBF,  {"XTL_SA"  ,"N",6, 0 }) //Tem SA
	aAdd(aDBF,  {"XX_USACAL"  ,"C",3, 0 })
	aAdd(aDBF,  {"XX_DESTIN"  ,"C",12, 0 })
	aAdd(aDBF,  {"XX_TEMGAR"  ,"C",3, 0 })
	aAdd(aDBF,  {"XX_NOMINS"  ,"C",15, 0 })

	oTmpTbl6 := NGFwTmpTbl(cTRBIP,aDBF,{{ "TL_TAREFA","TL_TIPOREG","TL_CODIGO","TL_SEQRELA" }})

	aHoBrw6 := aClone( aHoBrw2 )

	If Len( aCoBrw6 ) == 0

		aCoBrw6 := BlankGetD( aHoBrw6 )

		aCoBrw6[1,Len( aCoBrw6[1] )] := {}
		
		aAdd( aCoBrw6[1], .F. )

		aCoBrw2 := aClone( aCoBrw6 )

		PutFileInEof( 'STL' )
		
		For nInd1 := 1 To Len( aHoBrw6 )
			
			If aHoBrw6[nInd1,2] == 'TL_SEQRELA'
			
				aCoBrw6[1,nInd1] := PADR( '1', 3 )
			
			Else
			
				aCoBrw6[1,nInd1] := CriaVar( AllTrim( aHoBrw6[nInd1,2] ) )
			
			EndIf

		Next nInd1

		If Empty( aNovoSTL )

			aNovoSTL := aClone( aCoBrw6 )
		
		EndIf
	
	EndIf
	
	FWFreeArray( aLine )

Return

Static Function fTrbEtapa()

	Local aHoBrws  	:= NGHeader("STQ", {"TQ_FILIAL","TQ_NOMSITU", "TQ_OK"}, .F.)
	Local nInd1     := 0
	Local nInd     	:= 0
	Local nTot     	:= 0
	Local nTamanho 	:= 0
	Local nDecimal 	:= 0
	Local cCampo   	:= ""
	Local cArquivo 	:= ""
	Local cTipo    	:= ""
	Local aInd435a  := {}

	aDBF  := {}
	aTRBQ := {}

	aAdd( aDBF, { 'TQ_OK', 'C', 02, 0 } )

	For nInd1 := 1 To Len(aHoBrws)

		If Trim( aHoBrws[nInd1,2] ) == 'TQ_NOMETAP'

			aHoBrws[nInd1,4] := 40

		ElseIf Trim( aHoBrws[nInd1,2] ) == 'TQ_CODFUNC'

			aHoBrws[nInd1,1] := "Executante"

		ElseIf Trim( aHoBrws[nInd1,2] ) == 'TQ_ORDEM' .Or.;
			Trim( aHoBrws[nInd1,2] ) == 'TQ_PLANO'

			aAdd( aDBF, { Trim( aHoBrws[nInd1,2] ), aHoBrws[nInd1,8], aHoBrws[nInd1,4], aHoBrws[nInd1,5] } )

			Loop

		EndIf

		aAdd( aDBF , { Trim( aHoBrws[nInd1,2] ), aHoBrws[nInd1,8], aHoBrws[nInd1,4], aHoBrws[nInd1,5] } )

		aAdd( aTRBQ, { aHoBrws[nInd1,1], Trim( aHoBrws[nInd1,2] ), aHoBrws[nInd1,8], aHoBrws[nInd1,4],;
			aHoBrws[nInd1,5], aHoBrws[nInd1,3]} )

	Next nInd1

	//Campos de uso exclusivo da Legenda
	aAdd( aDBF, { 'CODBEM'	  , 'C', 16, 0 } )
	aAdd( aDBF, { 'SEQRELA'	  , 'N', 03, 0 } )
	aAdd( aDBF, { 'QUANTID'	  , 'N', 09, 0 } )
	aAdd( aDBF, { 'STATUS'	  , 'C', 01, 0 } )
	aAdd( aDBF, { 'TQ_MARK'   , 'C', 02, 0 } )
	aAdd( aDBF, { 'TQ_SEQRELA', 'C', 03, 0 } )
	aAdd( aDBF, { 'RECSTQ'    , 'N', 10, 0 } )

	aInd435a := { 	{ 'TQ_TAREFA' , 'TQ_SEQETA', 'TQ_ETAPA' },;
					{ 'TQ_TAREFA' , 'TQ_ETAPA' , 'TQ_SEQETA', 'TQ_SEQTARE' },;
					{ 'TQ_SEQTARE', 'TQ_SEQETA', 'TQ_TAREFA', 'TQ_ETAPA' },;
					{ 'TQ_ORDEM'  , 'TQ_PLANO' , 'TQ_TAREFA', 'TQ_ETAPA', 'TQ_SEQRELA' },;
					{ 'TQ_MARK' } ,;
					{ 'TQ_SEQRELA' } }

	//Criação Tabela Temporária
	oTmpTbl3 := NGFwTmpTbl( cTRBQ400, aDBF, aInd435a )

	/*------------------------------------------------------------------------+
	| Cria tabela temporária para insumos listados no processo de associação. |
	+------------------------------------------------------------------------*/
	oTmpTbl9 := FWTemporaryTable():New( cAlsExecu, aDBF )
	oTmpTbl9:Create()

	aDBFTar := {}
	aAdd(aDBFTar,{"TAREFA" ,"C",06,0})
	aAdd(aDBFTar,{"NOMETAR","C",20,0})
	aAdd(aDBFTar,{"ETAPA"  ,"C",06,0})
	aAdd(aDBFTar,{"NOMEETA","C",40,0})
	aAdd(aDBFTar,{"ORDEM"  ,"C",06,0})
	aAdd(aDBFTar,{"DTMPINI","D",08,0})

	//Indice Tabela Temporária
	aInd435d := {{"DTMPINI","TAREFA","ETAPA","ORDEM"},{"TAREFA","ETAPA"}}
	//Criação Tabela Temporária
	oTmpTbl4 := NGFwTmpTbl(cTRBTAR,aDBFTar,aInd435d)

	aDBF3 := TPC->( dbStruct() )

	aAdd(aDBF3,{"TPC_RESPOS","C",TAMSX3( 'TPQ_RESPOS' )[1],0})
	aAdd(aDBF3,{"TPC_OK"    ,"C",2,0})
	aAdd(aDBF3,{"TPC_TAREFA","C",6,0})

	aCposAlTPQ := {}
	If ExistBlock("NG405CPU")
		aCposAlTPQ := ExecBlock("NG405CPU",.F.,.F.)
	EndIf

	//--------------------------------------------------------
	//Agrega no array aHeader os campos de Usuarios...
	//--------------------------------------------------------
	nTot := Len(aCposAlTPQ)
	For nInd := 1 To nTot

		cCampo   := aCposAlTPQ[nInd]
		cArquivo := Posicione("SX3",2,cCampo,"X3_ARQUIVO")
		If (cArquivo)->(FieldPos(cCampo)) > 0

			cTipo    := Posicione("SX3",2,cCampo,"X3_TIPO")
			nTamanho := TAMSX3(cCampo)[1]
			nDecimal := TAMSX3(cCampo)[2]

			aAdd(aDBF3,{cCampo,cTipo,nTamanho,nDecimal})

		EndIf

	Next nInd

	//Criação Tabela Temporária
	oTmpTbl5 := NGFwTmpTbl(cTRB3400,aDBF3,{{ "TPC_ETAPA","TPC_TAREFA","TPC_OPCAO" }})

Return .T.

Static Function fCriaTRB( cAliasTRB, aFldSTJ, aPesq, aFieldFil )

	Local aDBF   := {}
	Local nIndex := 0

	// Cria estrutura do TRB com base no dicionário
	For nIndex := 1 To Len( aFldSTJ )
		aAdd( aDBF, { aFldSTJ[ nIndex, 1 ], aFldSTJ[ nIndex, 3 ], aFldSTJ[ nIndex, 4 ], 0 } )
		aAdd( aFieldFil, { aFldSTJ[ nIndex, 1 ], aFldSTJ[ nIndex, 2 ], aFldSTJ[ nIndex, 3 ], aFldSTJ[ nIndex, 4 ], 0, '' } )
	Next nIndex

	// Adiciona campos essenciais para o funcionamento da rotina
	If aScan( aFldSTJ, { | x | x[ 1 ] == 'TJ_DTPPINI' } ) == 0
		aAdd( aDBF,	{ 'TJ_DTPPINI', 'D', TamSx3( 'TJ_DTPPINI' )[ 1 ], 0 } )
		aAdd( aFieldFil, { 'TJ_DTPPINI', FwX3Titulo( 'TJ_DTPPINI' ),'D', TamSx3( 'TJ_DTPPINI' )[ 1 ], 0, '' } )
	EndIf

	If aScan( aFldSTJ, { | x | x[ 1 ] == 'TJ_DTMPFIM' } ) == 0
		aAdd( aDBF,	{ 'TJ_DTMPFIM', 'D', TamSx3( 'TJ_DTMPFIM' )[ 1 ], 0 } )
		aAdd( aFieldFil, { 'TJ_DTMPFIM', FwX3Titulo( 'TJ_DTMPFIM' ),'D', TamSx3( 'TJ_DTMPFIM' )[ 1 ], 0, '' } )
	EndIf

	If aScan( aFldSTJ, { | x | x[ 1 ] == 'TJ_TIPORET' } ) == 0
		aAdd( aDBF, { 'TJ_TIPORET', 'C', TamSx3( 'TJ_TIPORET' )[ 1 ], 0 } )
		aAdd( aFieldFil, { 'TJ_TIPORET', FwX3Titulo( 'TJ_TIPORET' ),'C', TamSx3( 'TJ_TIPORET' )[ 1 ], 0, '' } )
	EndIf

	aAdd( aDBF, { 'RECNO', 'N', 16, 0 } )

	// Instancia classe FWTemporaryTable
	oTmpTblOS := FWTemporaryTable():New( cAliasTRB, aDBF )

	/*----------------------------------------+
	| Inclui os indices na tabela temporária. |
	+----------------------------------------*/
	fAddIndex( aDBF, @aPesq )

	oTmpTblOS:Create()

Return

Static Function fLoadBrw( lClearTemp, aFldSTJ, lLoadOS, cChv902 )

	Local cSerefor  := Alltrim( SuperGetMv( 'MV_NGSEREF', .F., '' ) )
	Local aServRef  := StrTokArr( cSerefor, ';' )
	Local cSercons  := Alltrim( SuperGetMv( 'MV_NGSECON', .F., '' ) )
	Local aServCon  := StrTokArr( cSercons, ';' )
	Local cAliasQry := GetNextAlias()
	Local cCodPai   := Space( TamSX3( 'TJ_ORDEPAI' )[ 1 ] )
	Local cBanco    := AllTrim( TCGetDB() )
	Local cFilter   := "%"
	Local cCast     := ''
	Local cFilPE    := ''
	Local lValidTUA := .F.
	Local lObserva  := .F.
	Local nSumFields
	Local nCount
	Local nX
	Local aVrtFlds  := {}
	Local aIniSTJ   := {}
	Local oHashSTJ

	// Tratamento criado para que por padrão seja verificado a ST9, pois quando a chamada
	// é feita pela Planta(MNTA907 ) deverá ser validado pela TAF.
	Local cInnerJoin := ''
	Local cFields    := "% "
	Local lPlantaGra := IsInCallStack('MNTA907')

	Default cChv902 := ''

	If lClearTemp

		// Limpa Tabela Temporária para apresentar corretamente os dados da consulta
		NGZap( oTmpTblOS:GetRealName() )

		aDadosOS := {}

	EndIf

	// Se a chamada for pelo MNTA435 diretamente, faz o carregamento dos dados
	// Caso a chamada for do MNTA902 ou MNTA904, valida permissões de acesso à informações
	If lLoadOS .Or. ( !Empty( cChv902 ) .And. ( lValidTUA := NGValidTUA( 'STJ' ) ) )

		If ExistBlock( 'MNTA400O' )
			cFilPE := " AND " + ExecBlock( 'MNTA400O', .F., .F. )
		EndIf

		If IsInCallStack( 'MNTA902' )

			// Tratamento para carregar corretamente as informações para quando a O.S. for de uma localização
			cInnerJoin := "% LEFT JOIN " + RetSQLName( 'TAF' ) + " TAF "
			cInnerJoin += " ON ( TAF.TAF_FILIAL = " + ValToSQL( FwxFilial( 'TAF' ) ) + " AND STJ.TJ_CODBEM = TAF.TAF_CODNIV AND STJ.TJ_TIPOOS = 'L' AND TAF.TAF_MODMNT = 'X' AND  TAF.D_E_L_E_T_= ' ' ) "
			cInnerJoin += " LEFT JOIN " + RetSQLName( 'ST9' ) + " ST9 "
			cInnerJoin += "ON ( ST9.T9_FILIAL = " + ValToSQL( FwxFilial( 'ST9' ) ) + " AND STJ.TJ_CODBEM = ST9.T9_CODBEM AND STJ.TJ_TIPOOS = 'B' AND ST9.D_E_L_E_T_= ' ' ) %"

			// Filtro aplicado na Query
			cFilter    += " STJ.TJ_ORDEM = " + ValToSQL( cChv902 )
			cFilter    += cFilPE
			cFilter    += " AND STJ.D_E_L_E_T_= ' ' %"

		ElseIf lPlantaGra
			// Inner Join com TAF
			cInnerJoin := "% INNER JOIN " + RetSQLName( 'TAF' ) + " TAF "
			cInnerJoin += " ON ( TAF.TAF_FILIAL = " + ValToSQL( FwxFilial( 'TAF' ) ) + " AND STJ.TJ_CODBEM = TAF.TAF_CODNIV AND TAF.TAF_MODMNT = 'X' AND TAF.D_E_L_E_T_= ' ' ) %"

			// Filtro aplicado na Query
			cFilter += " STJ.TJ_TIPOOS || STJ.TJ_CODBEM = " + ValToSQL( cChv902 )
			cFilter += 	cFilPE
			cFilter += " AND STJ.TJ_SITUACA = 'L' "
			cFilter += " AND STJ.TJ_TERMINO = 'N' "
			cFilter += " AND STJ.D_E_L_E_T_= ' ' %"
		Else
			// Ao carregar o retorno modelo 2, deve-se apresentar O.S. abertas tanto para bens quanto para localizações
			cInnerJoin := "% LEFT JOIN " + RetSQLName( 'ST9' ) + " ST9 ON ( ST9.T9_FILIAL = " + ValToSQL( FwxFilial( 'ST9' ) ) + " AND STJ.TJ_CODBEM = ST9.T9_CODBEM AND STJ.TJ_TIPOOS = 'B' AND ST9.D_E_L_E_T_= ' ' ) "
			cInnerJoin += " LEFT JOIN " + RetSQLName( 'TAF' ) + " TAF ON ( TAF.TAF_FILIAL = " + ValToSQL( FwxFilial( 'TAF' ) ) + " AND STJ.TJ_CODBEM = TAF.TAF_CODNIV AND STJ.TJ_TIPOOS = 'L' AND TAF.TAF_MODMNT = 'X' AND TAF.D_E_L_E_T_= ' ' ) %"

			// Filtro aplicado na Query
			If !Empty( cChv902 )

				cFilter += " STJ.TJ_ORDEM = " + ValToSQL( cChv902 ) + " AND "

			EndIf

			//Preenche a variavel cSerefor com todos os serviços do parametro MV_NGSEREF
			If !Empty(cSerefor)

				For nX := 1 To Len(aServRef)
					If nX == 1
						cSerefor := "'"+aServRef[nX]+"'"
					Else
						cSerefor += ",'"+aServRef[nX]+"'"
					EndIf
				Next nX

			Else

				//Garante que a aspas vão certas para a Query
				cSerefor := "' '"

			EndIf

			//Preenche a variavel cSercons com todos os serviços do parametro MV_NGSECON
			If !Empty(cSercons)

				For nX := 1 To Len(aServCon)
					If nX == 1
						cSercons := "'"+aServCon[nX]+"'"
					Else
						cSercons += ",'"+aServCon[nX]+"'"
					EndIf
				Next nX

			Else

				//Garante que a aspas vão certas para a Query
				cSercons := "' '"

			EndIf

			cFilter += " STJ.TJ_SITUACA = 'L' "
			cFilter += " AND STJ.TJ_TERMINO = 'N' "
			cFilter += " AND STJ.TJ_ORDEPAI = " + ValToSQL( cCodPai )
			cFilter += " AND STJ.TJ_LUBRIFI <> 'S' "
			cFilter += " AND STJ.TJ_SERVICO NOT IN( " + cSerefor + ", " + cSercons + " ) "
			cFilter += 	cFilPE
			cFilter += " AND STJ.D_E_L_E_T_= ' ' %"

		EndIf

		// Realiza contagem de campos que serão apresentados no Browse
		nSumFields := Len( aFldSTJ )

		// Adiciona na query os campos que serão apresentados em tela
		For nCount := 1 To nSumFields

			If Posicione( 'SX3', 2, aFldSTJ[ nCount, 1 ], 'X3_CONTEXT' ) == 'V' .And.;
				aFldSTJ[ nCount, 1 ] != 'TJ_NOMSERV' .And. aFldSTJ[ nCount, 1 ] != 'TJ_NOMBEM'

				aAdd( aVrtFlds, aFldSTJ[ nCount, 1 ] )

				// Monta estrutura de inicialização padrão dos campos apresentados em tela
				If ExistIni( aFldSTJ[ nCount, 1 ] )
					aAdd( aIniSTJ, { aFldSTJ[ nCount, 1 ], Posicione( 'SX3', 2, aFldSTJ[ nCount, 1 ], 'X3_RELACAO' ) } )
				Else
					aAdd( aIniSTJ, { aFldSTJ[ nCount, 1 ], Space( TamSX3( aFldSTJ[ nCount, 1 ] )[ 1 ] ) } )
				EndIf

			EndIf

			If aFldSTJ[ nCount, 1 ] == 'TJ_NOMSERV'

				cFields += ", CASE "
				cFields +=    " WHEN STJ.TJ_SERVICO = 'HISTOR' THEN 'Historico'" //+ ValToSql(STR0406)
				cFields +=    " ELSE ST4.T4_NOME "
				cFields += " END AS TJ_NOMSERV "

			ElseIf aFldSTJ[ nCount, 1 ] == 'TJ_NOMBEM'

				If lPlantaGra
					// Caso venha da planta Gráfica, adiciona o campo TAF
					cFields += ', TAF.TAF_NOMNIV AS TJ_NOMBEM '
				Else
					cFields += ", CASE "
					cFields +=    " WHEN STJ.TJ_TIPOOS = 'B' THEN ST9.T9_NOME "
					cFields +=    " ELSE TAF.TAF_NOMNIV "
					cFields += " END AS TJ_NOMBEM "
				EndIf

			ElseIf  aFldSTJ[ nCount, 1 ] == 'TJ_DTPPINI' .Or.;
					aFldSTJ[ nCount, 1 ] == 'TJ_DTMPINI' .Or.;
					aFldSTJ[ nCount, 1 ] == 'TJ_DTMPFIM'
					// Devido a possibilidade de alteração dos campos, foi necessário realizar uma tratativa
					// para que mesmo se o usuário remover os campos eles sejam carregados ao menos no TRB.
					// pois são campos utilizados em validações/filtros ou afins da rotina.
				cFields += ''

			ElseIf aScan( aVrtFlds , { | x | x == aFldSTJ[ nCount, 1 ] } ) == 0

				cFields +=  ', STJ.' + aFldSTJ[ nCount, 1 ]

			EndIf

		Next nCount

		cCast := ", STJ.TJ_OBSERVA " // INFORMIX

		Do Case

			Case cBanco == 'ORACLE'

				cCast := ", UTL_RAW.CAST_TO_VARCHAR2( dbms_lob.substr( STJ.TJ_OBSERVA, 2000, 1 ) ) AS TJ_OBSERVA "

			Case cBanco == 'POSTGRES'

				cCast := ", COALESCE( CAST( ENCODE( STJ.TJ_OBSERVA, 'ESCAPE' ) AS VARCHAR( 8000 ) ), '' ) AS TJ_OBSERVA "

			Case 'MSSQL' $ cBanco

				cCast := ", ISNULL( CAST( CAST( STJ.TJ_OBSERVA AS VARBINARY( 8000 ) ) AS VARCHAR( 8000 ) ),'') AS TJ_OBSERVA "

		End Case

		cFields += cCast

		// Inicializa objeto e adiciona os valores
		oHashSTJ := HmNew()
		oHashSTJ := aToHM(aIniSTJ)
		aIniSTJ  := {}

		// Tratamento para que ao retornar a query seja passado o valor correto do campo observação para o TRB
		If ( nCount := aScan( aFldSTJ , { | x | x[ 1 ] == 'TJ_OBSERVA' } ) ) > 0
			aDel( aFldSTJ , nCount )
			aSize( aFldSTJ , Len( aFldSTJ ) - 1 )
			nSumFields--
			lObserva := .T.
		EndIf

		// Fecha condição de execução do BeginSQL
		cFields += ' %'

		BeginSQL Alias cAliasQry

			SELECT  STJ.TJ_FILIAL,
					STJ.TJ_TIPORET,
					STJ.TJ_DTPPINI,
					STJ.TJ_DTMPINI,
					STJ.TJ_DTMPFIM,
					STJ.R_E_C_N_O_ AS RECNO
					%exp:cFields%
			FROM %table:STJ% STJ
			%Exp:cInnerJoin%
			LEFT JOIN %table:ST4% ST4
				ON ( ST4.T4_FILIAL = %xFilial:ST4% AND STJ.TJ_SERVICO = ST4.T4_SERVICO AND ST4.%NotDel% )
			WHERE   STJ.TJ_FILIAL = %xFilial:STJ%
				AND %exp:cFilter%

		EndSQL

		Do While (cAliasQry)->( !EoF() )

			// Utilizado no inicializador padrão
			STJ->( dbGoTo( (cAliasQry)->RECNO ) )

			RecLock( cAliOS435, .T. )
			// Adiciona na query os campos que serão apresentados em tela
			For nCount := 1 To nSumFields

				If aScan( aVrtFlds , { | x | x == aFldSTJ[ nCount, 1 ] } ) == 0
					If aFldSTJ[ nCount, 3 ] == 'D'
						&( cAliOS435 + '->' + aFldSTJ[ nCount, 1 ] ) := StoD( &( cAliasQry + '->' + aFldSTJ[ nCount, 1 ] ) )
					Else
						&( cAliOS435 + '->' + aFldSTJ[ nCount, 1 ] ) := &( cAliasQry + '->' + aFldSTJ[ nCount, 1 ] )
					EndIf
				Else
					// Captura valor do campo a ser inicializado
					If HmGet( oHashSTJ, aFldSTJ[ nCount, 1 ], @aIniSTJ)
						&( cAliOS435 + '->' + aFldSTJ[ nCount, 1 ] ) := &( aIniSTJ[ 1, 2 ] )
					EndIf
				EndIf

			Next nCount

			(cAliOS435)->TJ_DTMPFIM := StoD((cAliasQry)->TJ_DTMPFIM)
			(cAliOS435)->TJ_TIPORET := (cAliasQry)->TJ_TIPORET
			(cAliOS435)->RECNO      := (cAliasQry)->RECNO

			If lObserva
				(cAliOS435)->TJ_OBSERVA := (cAliasQry)->TJ_OBSERVA
			EndIf

			(cAliOS435)->( MsUnlock() )

			aAdd( aDadosOS, {;
				(cAliasQry)->TJ_ORDEM,;
				(cAliasQry)->TJ_PLANO,;
				Nil                  ,;
				Nil                  ,;
				Nil                  ,;
				Nil                  ,;
				Nil                  ,;
				Nil                  ,;
				Nil                  ,;
				{} } )                 // Ocorrências

			(cAliasQry)->( dbSkip() )

		End Do

		// Limpa os dados do HashMap
		HMClean( oHashSTJ )

		// Libera o objeto de HashMap
		FreeObj( oHashSTJ )

		// Limpa os dados do Array
		FWFreeArray( aIniSTJ )

		(cAliasQry)->( dbCloseArea() )

		If lLoadOS

			// Atualiza abas relacionadas a primeira O.S. posicionada no browse
			If !Empty( aDadosOS )
				fRefreshOS( (cAliOS435)->TJ_ORDEM, (cAliOS435)->TJ_PLANO, 1 )
			Else
				MsgInfo(cErro := "Não foram encontradas O.S. abertas para essa pesquisa.","Atenção")
				cErroGeral := cErro
			EndIf

		EndIf

	EndIf

Return

Static Function fGerCol( aFields )

	Local aColu := {}
	Local nInd 	:= 0

	//Cria Colunas do Browse
	For nInd := 1 To Len( aFields )
		aAdd( aColu, fCreateCol( "{ | | (cAliOS435)->" + aFields[ nInd, 1 ] + " }", aFields[ nInd ] ) )
	Next nInd

Return aColu

Static Function fCreateCol( cDadosCol, aFieldSTJ )

	Local aArea		  := GetArea()
	// Objeto de criação das colunas do Browse
	Local oColumn
	// [LGPD] Caso o usuário não possua acesso ao(s) campo(s), deve-se ofuscá-lo(s)
	Local lOfuscar := FindFunction( 'FWPDCanUse' ) .And. FwPdCanUse( .T. );
				  	 .And. Len( FwProtectedDataUtil():UsrAccessPDField( __CUSERID, { aFieldSTJ[ 1 ] } ) ) == 0

	//Adiciona as colunas do Browse
	oColumn := FWBrwColumn():New()      // Cria objeto
	oColumn:SetData( &( cDadosCol ) )   // Define valor
	oColumn:SetEdit( .F. )	      	    // Indica se é editavel
	oColumn:SetTitle( aFieldSTJ[ 2 ] )  // Define titulo
	oColumn:SetType( aFieldSTJ[ 3 ] )   // Define tipo
	oColumn:SetSize( aFieldSTJ[ 4 ] )	// Define tamanho
	oColumn:SetPicture( aFieldSTJ[ 5 ] )// Define picture
	oColumn:SetReadVar( aFieldSTJ[ 1 ] )// Define o nome da coluna
	If lOfuscar
		oColumn:SetObfuscateCol( .T. )  // Define que coluna será ofuscada
	EndIf

	RestArea(aArea)

Return oColumn

Static Function MNT435CALLB( nOp )

	Local lRet  := .F.

	If ExistBlock( "MNTA4358" )
		lRet := ExecBlock( "MNTA4358",.F.,.F., { nOp,(cTRBIP) } )
		If !lRet
			Return .F.
		EndIf
	EndIf

	If nOp == 1 // "Incluir todos os insumos previstos."
		fPrgNext()
	ElseIf nOp == 2 // "Incluir o insumo previsto."
		f435Next()
	ElseIf nOp == 3 // "Excluir o insumo realizado."
		fDelInsumo( .F. )
	ElseIf nOp == 4 // "Excluir todos os insumos realizados."
		fDelInsumo( .T. )
	EndIf

Return

Static Function fPrgNext()

	Local aCodFunc 	:= {}
	Local cProdBloq := ''
	Local cCodInsum := ''
	Local cNGMNTES	:= SuperGetMv( 'MV_NGMNTES', .F., 'N' )
	Local cLocPad   := SuperGetMV( 'MV_NGLOCPA', .F., '01' )
	Local cNGUNIDT  := SuperGetMV( 'MV_NGUNIDT', .F., 'S' )
	Local lTemSC1 	:= .F.
	Local nYY 		:= 0
	Local nZZZ 		:= 0
	Local nQtdCvrt  := 0
	Local nSeqTmp 	:= 0
	Local nLenBrw6	:= 0
	Local nCustIns  := 0
	Local lMNTA435O	:= ExistBlock( 'MNTA435O' )
	Local lMNTA435R := ExistBlock( 'MNTA435R' )

	Local nPos 		:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_TIPOREG"})
	Local nPox 		:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_CODIGO" })
	Local nPoZ 		:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_NOMCODI"})
	Local nPoQ 		:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_QUANREC"})
	Local nPoY 		:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_TAREFA" })
	Local nPos18 	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_SEQRELA"})
	Local nDtIni 	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_DTINICI"})
	Local nDtFim 	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_DTFIM"  })
	Local nCpoGar 	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_GARANTI"})
	Local nNumSa  	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_NUMSA"  })
	Local nITEMSa  	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_ITEMSA" })
	Local nQuanti  	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_QUANTID"})

	Local nPosCust  := GDFieldPos( 'TL_CUSTO'  , aHoBrw2 )
	Local nPosAlmo  := GDFieldPos( 'TL_LOCAL'  , aHoBrw2 )
	Local nPosSeqT  := GDFieldPos( 'TL_SEQTARE', aHoBrw2 )

	lRet435 := .T.

	nLenBr6 := Len(aCoBrw6)
	If nLenBr6 == 1
		If Empty(aCoBrw6[1,nPox])
			aCoBrw6 := {}
		EndIf
	ElseIf nLenBr6 > 1
		If Empty(aCoBrw6[nLenBr6,nPox])
			aDel(aCoBrw6,nLenBr6)
			aSize(aCoBrw6,nLenBr6-1)
			oBrw6:lNewLine := .F.
		EndIf
	EndIf

	lFirstMsg := .T.
	dbSelectArea(cTRBIP)
	dbGoTop()
	While !EoF()

		nYY := aScan( aCoBrw2, { |x| x[nPoY] + x[nPos] + x[nPox] + x[nPos18] + x[nPosSeqT] == (cTRBIP)->TL_TAREFA + (cTRBIP)->TL_TIPOREG +;
			(cTRBIP)->TL_CODIGO + (cTRBIP)->TL_SEQRELA + (cTRBIP)->TL_SEQTARE } )

		If nYY > Len(aCoBrw2)

			dbSelectArea(cTRBIP)
			dbSkip()

			Loop

		EndIf

		lTemSC1 := .F.

		//Verifica se o Insumo possui Solicitação de Armazem
		If aCoBrw2[nYY,nPos] $ "PT" .And. cUsaInt2 == "S" .And. cUsaInt3 == "S"

			If nNumSa > 0 .And. nITEMSa > 0
				dbSelectArea("SCP")
				dbSetOrder(2) //CP_FILIAL+CP_PRODUTO+CP_NUM+CP_ITEM
				If dbSeek( xFilial("SCP") + aCoBrw2[nYY,nPox] + aCoBrw2[nYY,nNumSa] + aCoBrw2[nYY,nITEMSa])

					ShowHelpDlg("ATENCAO", {cErro := "O insumo " + Alltrim(aCoBrw2[nYY,nPoZ]) + "esta relacionado a Solicitação "+;
					"ao Armazem numero " + SCP->CP_NUM},1,;
					{"Realizar a aplicação do insumo utilizando a rotina de Baixa Pré-Requisição(MATA185)."+;
					" Excluir/Alterar a Solicitação ao Armazem"},1)
					dbSelectArea(cTRBIP)
					dbSkip()
					Loop

				EndIf
			EndIf

			dbSelectArea("SC1")
			dbSetOrder(4) //C1_FILIAL+C1_OP+C1_NUM+C1_ITEM
			If dbSeek( xFilial("SC1") + cOrdemTJ+"OS001")
				While !Eof() .And. SC1->C1_FILIAL == xFilial("SC1") .And. Alltrim(SC1->C1_OP) == cOrdemTJ+"OS001"

					If SC1->C1_PRODUTO == aCoBrw2[nYY,nPox] .And. aCoBrw2[nYY,nQuanti] == SC1->C1_QUANT

						If !MsgYesNo("O insumo " +Alltrim(aCoBrw2[nYY,nPoZ])+ " está relacionado a Solicitação de Compra numero "+;
						SC1->C1_NUM +". Deseja incluir como realizado ? ")

							lTemSC1 := .T.
							Exit

						EndIf

					EndIf

					dbSelectArea("SC1")
					dbSkip()

				End

			EndIf

			If lTemSC1
				dbSelectArea(cTRBIP)
				dbSkip()
				Loop
			EndIf

		EndIf

		If aCoBrw2[nYY,nPos] == "P"
			//Verificar os produtos que estao bloqueados
			dbSelectArea("SB1")
			dbSetOrder(1)
			If dbSeek(xFilial("SB1")+aCoBrw2[nYY,nPox])
				If SB1->B1_MSBLQL == "1"
					If !Empty(cProdBloq)
						cProdBloq += ", "
					EndIf
					cProdBloq += Alltrim(aCoBrw2[nYY,nPox])
					dbSelectArea(cTRBIP)
					dbSkip()
					Loop
				EndIf
			EndIf

			M->TL_SEQRELA := aCoBrw2[nYY,nPos18]
			M->TL_TIPOREG := aCoBrw2[nYY,nPos]
			M->TL_CODIGO  := aCoBrw2[nYY,nPox]
			MNT400CHKGAR()
			MNT400PCKGAR()
		EndIf
		If cUsaGeRe == "EST" .And. aCoBrw2[nYY,nPos] == "P"
			If lFirstMsg
				MsgInfo(cErro := "Para insumo produto somente poderá ser gerado SA (Solicitação ao Armazém).") //
				lFirstMsg := .F.
			EndIf
			dbSelectArea(cTRBIP)
			dbSkip()
			Loop
		Else
			
			If aCoBrw2[nYY,nPos] == "E"

				aCodFunc := fPFiltro(aCoBrw2[nYY,nPox], aCoBrw2[nYY,nPoQ], aCoBrw2[nYY,nDtFim])

				If ValType(aCodFunc) <> "A"
					dbSelectArea(cTRBIP)
					dbSkip()
					Loop
				EndIf

				For nZZZ := 1 to Len(aCodFunc)

					nPosBrw := aScan(aCoBrw6 ,{|x| x[nPoY] == aCoBrw2[nYY,nPoY] .And. x[nPos] == "M" .And. ;
					x[nPox] == aCodFunc[nZZZ] .And. !x[Len(x)] })
					If nPosBrw > 0
						fInsChange(aCoBrw2[nYY],nPosBrw,@nSeqTmp,nPos18)
					Else
						aAdd(aCoBrw6 , aClone(aCoBrw2[nYY]) )
						nLenBrw6 := Len(aCoBrw6)
						aCoBrw6[ nLenBrw6 , nPos ] := "M"
						aCoBrw6[ nLenBrw6 , nPox ] := aCodFunc[nZZZ]

						dbSelectArea("ST1")
						dbSetOrder(1)
						dbSeek(xFilial("ST1") + aCodFunc[nZZZ])

						GDFieldPut( 'TL_NOMCODI', ST1->T1_NOME             , nLenBrw6, aHoBrw2, aCoBrw6 )
						GDFieldPut( 'TL_QUANREC', 0                        , nLenBrw6, aHoBrw2, aCoBrw6 )
						GDFieldPut( 'TL_SEQRELA', MNT435SEQ( aCoBrw6, .T. ), nLenBrw6, aHoBrw2, aCoBrw6 )

						If cNGMNTES != 'S'
						
							If !Empty( ST1->T1_SALARIO )

								GDFieldPut( 'TL_CUSTO', ( ST1->T1_SALARIO * GDFieldGet( 'TL_QUANTID', nLenBrw6, .F.,;
									aHoBrw2, aCoBrw6 ) ), nLenBrw6, aHoBrw2, aCoBrw6 )
							
							Else

								GDFieldPut( 'TL_CUSTO', 0, nLenBrw6, aHoBrw2, aCoBrw6 )
							
							EndIf

						Else
						
							cCodInsum := MntGetPrdM()

							If lIntRM

								NGMUStoLvl( cCodInsum, cLocPad, .T., 'M', ST1->T1_CODFUNC )

							EndIf

							nQtdCvrt := NGCONVERHORA( aCoBrw2[nYY,nQuanti], cNGUNIDT, 'D' )

							nCustIns := Round( NGCALCUSTI( cCodInsum, 'P', nQtdCvrt, , , , , aCoBrw2[nYY,nPoQ], 1 ), 2 )

							GDFieldPut( 'TL_CUSTO', nCustIns, nLenBrw6, aHoBrw2, aCoBrw6 )

						EndIf

					EndIf

				Next nZZZ

			Else
				If aCoBrw2[nYY,nPos] == "T"
					If !NGVALTERC("T",cUsaInt3)
						dbSelectArea(cTRBIP)
						dbSkip()
						Loop
					EndIf
				EndIf
				nPosBrw := aScan(aCoBrw6 ,{|x| x[nPoY] == aCoBrw2[nYY,nPoY] .And. x[nPos] == aCoBrw2[nYY,nPos] .And. ;
				x[nPox] == aCoBrw2[nYY,nPox] .And. !x[Len(x)] })
				If nPosBrw > 0
					fInsChange(aCoBrw2[nYY],nPosBrw,@nSeqTmp,nPos18)
				Else
					If !Empty( aCoBrw2[nYY,1] )

						aAdd( aCoBrw6, aClone( aCoBrw2[nYY] ) )

						nTempXX := Len(aCoBrw6)

						If aCoBrw6[nTempXX,nPos] == 'P' .And. !Empty( nPosCust )

							aCoBrw6[nTempXX,nPosCust] := Round( NGCALCUSTI( aCoBrw6[nTempXX,nPox], aCoBrw6[nTempXX,nPos], aCoBrw6[nTempXX,nQuanti],;
								aCoBrw6[nTempXX,nPosAlmo], , , , aCoBrw6[nTempXX,nPoQ], '1' ), 2 )

						EndIf

						If lMNTA435R

							/*------------------------------------+
							| P.E. para alterar conteudo do aCols |
							+------------------------------------*/
							aCoBrw6 := aClone( ExecBlock( 'MNTA435R', .F., .F.,;
								{ aHoBrw2, aCoBrw6, nTempXX } ) )

						EndIf

						aCoBrw6[ nTempXX ,nPos18] := MNT435SEQ(aCoBrw6,.T.)

						If aCoBrw6[nTempXX,nPos] == "P"
							M->TL_CODIGO  := aCoBrw6[nTempXX,nPox]
							M->TL_GARANTI := aCoBrw6[nTempXX,nCpoGar]
							strDescIns    := aCoBrw6[nTempXX,nPoZ]
							tmpSeqRela    := aCoBrw6[nTempXX,nPos18]
							tmpDtInic     := aCoBrw6[nTempXX,nDtIni]
							tmpDtFim      := aCoBrw6[nTempXX,nDtFim]
							fNgGar435("S",.T.,M->TL_GARANTI,strDescIns,tmpSeqRela,tmpDtInic,tmpDtFim) //Verifica se tem garantia de peça de reposição
							aCoBrw6[nTempXX,nCpoGar] := M->TL_GARANTI
						EndIf
					EndIf
					//Se possuir o PE e integração ao estoque deverá validar
					If lMNTA435O .And. cUsaInt3 == 'S' .And. aCoBrw6[nTempXX,nPos] == "M"

						//Se o P.E. retornar .F. e se a chave atual nao esteja relacionada como bloqueio.
						//não deverá realizar a baixa no estoque, sendo assim deverá ser adicionada no aNBaixaEst
						If !ExecBlock("MNTA435O",.F.,.F.,{ aCoBrw6[nTempXX], aHoBrw2 }) .And. ;
								MNT435CANB(cOrdemTJ + cPlanoTJ + aCoBrw6[nTempXX,nPos18] + aCoBrw6[nTempXX,nPoY] + aCoBrw6[nTempXX,nPos] + aCoBrw6[nTempXX,nPox])
							aAdd(aNBaixaEst,{cOrdemTJ,;  //TL_ORDEM
							cPlanoTJ,;			         //TL_PLANO
							aCoBrw6[nTempXX,nPos18] ,;	 //TL_SEQRELA
							aCoBrw6[nTempXX,nPoY] ,;	 //TL_TAREFA
							aCoBrw6[nTempXX,nPos] ,;	 //TL_TIPOREG
							aCoBrw6[nTempXX,nPox] })	 //TL_CODIGO
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		dbSelectArea(cTRBIP)
		dbSkip()

	End

	If ExistBlock("MNTB4351")
		ExecBlock("MNTB4351")
	EndIf

	dbSelectArea(cTRBIP)
	dbGoTop()

	If Len( aCoBrw6 ) == 0
		aCoBrw6 := aClone( aNovoSTL )
	EndIf

	//Mostra os Produtos bloqueados
	If !Empty(cProdBloq)
		MsgInfo(cErro := "Produto(s) blqueado(s) : " + cProdBloq  )
	EndIf

Return

Static Function f435Next()

	Local aCodFunc 	:= {}
	Local cProdBloq := ''
	Local cCodInsum := ''
	Local cNGMNTES	:= SuperGetMv("MV_NGMNTES", .F., "N")
	Local cLocPad   := SuperGetMV( 'MV_NGLOCPA', .F., '01' )
	Local cNGUNIDT  := SuperGetMV( 'MV_NGUNIDT', .F., 'S' )
	Local lTemSC1 	:= .F.
	Local lMNTA435O	:= ExistBlock("MNTA435O")
	Local lMNTA435R := ExistBlock( 'MNTA435R' )
    Local nSeqTmp 	:= 0
    Local nYY  		:= 0
	Local nZZZ 		:= 0
	Local nLenBrw6 	:= 0
	Local nQtdCvrt  := 0
	Local nPos 		:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_TIPOREG"})
	Local nPox 		:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_CODIGO" })
	Local nPoZ 		:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_NOMCODI"})
	Local nPoQ 		:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_QUANREC"})
	Local nPoY 		:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_TAREFA" })
	Local nPos18 	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_SEQRELA"})
	Local nDtIni 	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_DTINICI"})
	Local nDtFim 	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_DTFIM"  })
	Local nCpoGar 	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_GARANTI"})
	Local nNumSa  	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_NUMSA"  })
	Local nITEMSa  	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_ITEMSA" })
	Local nQuanti  	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_QUANTID"})

	Local nPosCust  := GDFieldPos( 'TL_CUSTO'  , aHoBrw2 )
	Local nPosAlmo  := GDFieldPos( 'TL_LOCAL'  , aHoBrw2 )
	Local nPosSeqT  := GDFieldPos( 'TL_SEQTARE', aHoBrw2 )

	lRet435 := .T.

	If ! lRet435 //Problema encontrado em alguma rotina de validacao da LinhaOK
		Return .F.
	EndIf

	nLenBr6 := Len(aCoBrw6)
	If nLenBr6 == 1
		If Empty(aCoBrw6[1,nPox])
			aCoBrw6 := {}
		EndIf
	ElseIf nLenBr6 > 1
		If Empty(aCoBrw6[nLenBr6,nPox])
			aDel(aCoBrw6,nLenBr6)
			aSize(aCoBrw6,nLenBr6-1)
		EndIf
	EndIf

	lFirstMsg := .T.

	dbSelectArea(cTRBIP)
	dbGoTop()
	While (cTRBIP)->( !EoF() )

		nYY := aScan( aCoBrw2, { |x| x[nPoY] + x[nPos] + x[nPox] + x[nPos18] + x[nPosSeqT] == (cTRBIP)->TL_TAREFA + (cTRBIP)->TL_TIPOREG +;
			(cTRBIP)->TL_CODIGO + (cTRBIP)->TL_SEQRELA + (cTRBIP)->TL_SEQTARE } )

		If nYY > Len(aCoBrw2) .Or. Empty((cTRBIP)->TL_OK)

			dbSelectArea(cTRBIP)
			dbSkip()

			Loop

		EndIf

		lTemSC1 := .F.

		//Verifica se o Insumo possui Solicitação de Armazem ou Solicitacao de Compras
		If aCoBrw2[nYY,nPos] $ "PT" .And. cUsaInt2 == "S" .And. cUsaInt3 == "S"

			If nNumSa > 0 .And. nITEMSa > 0
				dbSelectArea("SCP")
				dbSetOrder(2) //CP_FILIAL+CP_PRODUTO+CP_NUM+CP_ITEM
				If dbSeek( xFilial("SCP") + aCoBrw2[nYY,nPox] + aCoBrw2[nYY,nNumSa] + aCoBrw2[nYY,nITEMSa])

					ShowHelpDlg("ATENCAO", {cErro := "O insumo " + Alltrim(aCoBrw2[nYY,nPoZ]) + "esta relacionado a Solicitação "+;
					"ao Armazem numero " + SCP->CP_NUM},1,;
					{"Realizar a aplicação do insumo utilizando a rotina de Baixa Pré-Requisição(MATA185)."+;
					" Excluir/Alterar a Solicitação ao Armazem"},1)
					dbSelectArea(cTRBIP)
					dbSkip()
					Loop

				EndIf
			EndIf

			dbSelectArea("SC1")
			dbSetOrder(4) //C1_FILIAL+C1_OP+C1_NUM+C1_ITEM
			If dbSeek( xFilial("SC1") + cOrdemTJ+"OS001")
				While !Eof() .And. SC1->C1_FILIAL == xFilial("SC1") .And. Alltrim(SC1->C1_OP) == cOrdemTJ+"OS001"

					If SC1->C1_PRODUTO == aCoBrw2[nYY,nPox] .And. aCoBrw2[nYY,nQuanti] == SC1->C1_QUANT

						If !MsgYesNo("O insumo " +Alltrim(aCoBrw2[nYY,nPoZ])+ " está relacionado a Solicitação de Compra numero "+;
						SC1->C1_NUM +". Deseja incluir como realizado ? ")

							lTemSC1 := .T.
							Exit

						EndIf

					EndIf

					dbSelectArea("SC1")
					dbSkip()

				End

			EndIf

			If lTemSC1
				dbSelectArea(cTRBIP)
				dbSkip()
				Loop
			EndIf

		EndIf

		If aCoBrw2[nYY,nPos] == "P"
			//Verificar se o Produto esta bloqueado
			dbSelectArea("SB1")
			dbSetOrder(1)
			If dbSeek(xFilial("SB1")+aCoBrw2[nYY,nPox])
				If SB1->B1_MSBLQL == "1"
					If !Empty(cProdBloq)
						cProdBloq += ", "
					EndIf
					cProdBloq += Alltrim(aCoBrw2[nYY,nPox])
					dbSelectArea(cTRBIP)
					dbSkip()
					Loop
				EndIf
			EndIf
			M->TL_SEQRELA := aCoBrw2[nYY,nPos18]
			M->TL_TIPOREG := aCoBrw2[nYY,nPos]
			M->TL_CODIGO  := aCoBrw2[nYY,nPox]
			MNT400CHKGAR()
			MNT400PCKGAR()
		EndIf
		If cUsaGeRe == "EST" .And. aCoBrw2[nYY,nPos] == "P"
			If lFirstMsg
				MsgInfo(cErro := "Para insumo produto somente poderá ser gerado SA (Solicitação ao Armazém).")
				lFirstMsg := .F.
			EndIf
			dbSelectArea(cTRBIP)
			dbSkip()
			Loop
		Else
			If aCoBrw2[nYY,nPos] == "E"
				aCodFunc := fPFiltro(aCoBrw2[nYY,nPox], aCoBrw2[nYY,nPoQ], aCoBrw2[nYY,nDtFim])
				If ValType(aCodFunc) <> "A"
					dbSelectArea(cTRBIP)
					dbSkip()
					Loop
				EndIf
				For nZZZ := 1 to Len(aCodFunc)
					nPosBrw := aScan(aCoBrw6 ,{|x| x[nPoY] == aCoBrw2[nYY,nPoY] .And. x[nPos] == "M" .And. ;
					x[nPox] == aCodFunc[nZZZ] .And. !x[Len(x)] })
					If nPosBrw > 0

						fInsChange(aCoBrw2[nYY],nPosBrw,@nSeqTmp,nPos18)

					Else

						aAdd(aCoBrw6 , aClone(aCoBrw2[nYY]) )
						nLenBrw6 := Len(aCoBrw6)
						aCoBrw6[nLenBrw6 , nPos ] := "M"
						aCoBrw6[nLenBrw6 , nPox ] := aCodFunc[nZZZ]

						dbSelectArea("ST1")
						dbSetOrder(1)
						dbSeek(xFilial("ST1") + aCodFunc[nZZZ])

						GDFieldPut( 'TL_NOMCODI', ST1->T1_NOME             , nLenBrw6, aHoBrw2, aCoBrw6 )
						GDFieldPut( 'TL_QUANREC', 0                        , nLenBrw6, aHoBrw2, aCoBrw6 )
						GDFieldPut( 'TL_SEQRELA', MNT435SEQ( aCoBrw6, .T. ), nLenBrw6, aHoBrw2, aCoBrw6 )

						If cNGMNTES != 'S'
							
							If !Empty( ST1->T1_SALARIO )

								GDFieldPut( 'TL_CUSTO', ( ST1->T1_SALARIO * GDFieldGet( 'TL_QUANTID', nLenBrw6, .F.,;
									aHoBrw2, aCoBrw6 ) ), nLenBrw6, aHoBrw2, aCoBrw6 )

							Else
							
								GDFieldPut( 'TL_CUSTO', 0, nLenBrw6, aHoBrw2, aCoBrw6 )

							EndIf

						Else
							
							cCodInsum := MntGetPrdM()

							//Atualiza saldo e custo do produto relacionado a mão de obra
							If lIntRM

								NGMUStoLvl( cCodInsum, cLocPad, .T., 'M', ST1->T1_CODFUNC )

							EndIf

							nQtdCvrt := NGCONVERHORA( aCoBrw2[nYY,nQuanti], cNGUNIDT, 'D' )

							nCustIns := Round( NGCALCUSTI( cCodInsum, 'P', nQtdCvrt, , , , , aCoBrw2[nYY,nPoQ], 1 ), 2 )

							GDFieldPut( 'TL_CUSTO', nCustIns, nLenBrw6, aHoBrw2, aCoBrw6 )

						EndIf

					EndIf

				Next nZZZ

			Else
				If aCoBrw2[nYY,nPos] == "T"
					If !NGVALTERC("T",cUsaInt3)
						dbSelectArea(cTRBIP)
						dbSkip()
						Loop
					EndIf
				EndIf
				nPosBrw := aScan(aCoBrw6 ,{|x| x[nPoY] == aCoBrw2[nYY,nPoY] .And. x[nPos] == aCoBrw2[nYY,nPos] .And. ;
				x[nPox] == aCoBrw2[nYY,nPox] .And. !x[Len(x)] })

				If nPosBrw > 0
					fInsChange(aCoBrw2[nYY],nPosBrw,@nSeqTmp,nPos18)
				Else

					If !Empty(aCoBrw2[nYY,1])

						aAdd(aCoBrw6 , aClone( aCoBrw2[nYY] ) )

						nTempXX := Len(aCoBrw6)

						If aCoBrw6[nTempXX,nPos] == 'P' .And. !Empty( nPosCust )

							aCoBrw6[nTempXX,nPosCust] := Round( NGCALCUSTI( aCoBrw6[nTempXX,nPox], aCoBrw6[nTempXX,nPos], aCoBrw6[nTempXX,nQuanti],;
								aCoBrw6[nTempXX,nPosAlmo], , , , aCoBrw6[nTempXX,nPoQ], '1' ), 2 )

						EndIf

						If lMNTA435R

							/*------------------------------------+
							| P.E. para alterar conteudo do aCols |
							+------------------------------------*/
							aCoBrw6 := aClone( ExecBlock( 'MNTA435R', .F., .F.,;
								{ aHoBrw2, aCoBrw6, nTempXX } ) )

						EndIf

						aCoBrw6[ nTempXX ,nPos18] := MNT435SEQ(aCoBrw6,.T.)

						If aCoBrw6[nTempXX,nPos] == "P"
							M->TL_CODIGO  := aCoBrw6[nTempXX,nPox]
							M->TL_GARANTI := aCoBrw6[nTempXX,nCpoGar]
							strDescIns    := aCoBrw6[nTempXX,nPoZ]
							tmpSeqRela    := aCoBrw6[nTempXX,nPos18]
							tmpDtInic     := aCoBrw6[nTempXX,nDtIni]
							tmpDtFim      := aCoBrw6[nTempXX,nDtFim]
							fNgGar435("S",.T.,M->TL_GARANTI,strDescIns,tmpSeqRela,tmpDtInic,tmpDtFim) //Verifica se tem garantia de peça de reposição
							aCoBrw6[nTempXX,nCpoGar] := M->TL_GARANTI
						EndIf

						//Se possuir o PE e integração ao estoque deverá validar
						If lMNTA435O .And. cUsaInt3 == 'S' .And. aCoBrw6[nTempXX,nPos] == "M"

							//Se o P.E. retornar .F. e se a chave atual nao esteja relacionada como bloqueio.
							//não deverá realizar a baixa no estoque, sendo assim deverá ser adicionada no aNBaixaEst
							If !ExecBlock("MNTA435O",.F.,.F.,{ aCoBrw6[nTempXX], aHoBrw2 }) .And. ;
									MNT435CANB(cOrdemTJ + cPlanoTJ + aCoBrw6[nTempXX,nPos18] + aCoBrw6[nTempXX,nPoY] + aCoBrw6[nTempXX,nPos] + aCoBrw6[nTempXX,nPox])
								aAdd(aNBaixaEst,{cOrdemTJ,; //TL_ORDEM
								cPlanoTJ,;			        //TL_PLANO
								aCoBrw6[nTempXX,nPos18] ,;	//TL_SEQRELA
								aCoBrw6[nTempXX,nPoY] ,;	//TL_TAREFA
								aCoBrw6[nTempXX,nPos] ,;	//TL_TIPOREG
								aCoBrw6[nTempXX,nPox] })	//TL_CODIGO
							EndIf
						EndIf

					EndIf
				EndIf
			EndIf
		EndIf

		dbSelectArea(cTRBIP)
		dbSkip()
	End

	If ExistBlock("MNTB4352")
		ExecBlock("MNTB4352")
	EndIf

	dbSelectArea(cTRBIP)
	dbGoTop()

	If Len( aCoBrw6 ) == 0

		aCoBrw6 := aClone( aNovoSTL )
		
	EndIf

	//Mostra os Produtos bloqueados
	If !Empty(cProdBloq)
		MsgInfo(cErro := "Produto(s) blqueado(s) : " + cProdBloq  )
	EndIf

Return

Static Function Mnt435Fin()

	Local nXX,nYY
	Local dMINSTL,dMAXSTL,dMAXF,hMINSTL,hMAXSTL,hMAXF
	Local cOrdem
	Local cPlano
	Local nPox      := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_CODIGO"  })
	Local nPos      := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_TIPOREG" })
	Local nPoY      := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_TAREFA"  })
	Local nPoQ      := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_QUANTID" })
	Local nDtI      := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_DTINICI" })
	Local nHoI      := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_HOINICI" })
	Local nDtF      := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_DTFIM" })
	Local nHoF      := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_HOFIM" })
	Local aFin2P    := {}
	Local aFinTmp   := {}
	Local lTemIReal := .F. //indica se tem insumo realizado
	Local lSemIns   := .F.
	Local lRet 		:= .T.
	Local lSoProd	:= .T. //Indica que só tem insumo do tipo Produto

	Local nDatFim   := aScan(aHoBrw4,{|x| Trim(Upper(x[2])) == "TPL_DTFIM"})
	Local nHorFim   := aScan(aHoBrw4,{|x| Trim(Upper(x[2])) == "TPL_HOFIM"})
	Local nJ        := 0
	Local nNumSa    := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_NUMSA" })

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada que indica se a O.S ³
	//³podera ser finalizada sem insumos    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("NGSEMINS")
		lSemIns := ExecBlock("NGSEMINS",.F.,.F.)
		lSemIns := If(ValType(lSemIns) == "L",lSemIns,.F.)
	EndIf

	If !Empty(aCoBrw4)
		For nJ := 1 To Len(aCoBrw4)
			If lRet .And. !Empty(aCoBrw4[nJ][1]) .And. (Empty(aCoBrw4[nJ][nDatFim]) .Or. Empty(aCoBrw4[nJ][nHorFim]))
				ShowHelpDlg("ATENCAO", {cErro := "Existe(m) motivo(s) de atraso(s) reportado(s) para a ordem de serviço sem a data ou a hora final informados."}, 2,;
				{"Favor, informar uma data fim/hora fim para o(s) motivo(s) em questão para proceder com a finalização da O.S."}, 2)
				lRet := .F.
			EndIf
		Next nJ
	EndIf

	If lRet .And. !Empty( (cAliOS435)->TJ_ORDEM )

		cOrdem := (cAliOS435)->TJ_ORDEM
		cPlano := (cAliOS435)->TJ_PLANO
		dbSelectArea("STJ")
		dbSetOrder(01)
		If dbSeek(xFilial("STJ")+cOrdem+cPlano)

			//-----------------------------------------------------------
			// Verifica se não há pneus aguardando aplicação
			//-----------------------------------------------------------
			If FindFunction( 'MNTVLDFIN' ) .And. !MNTVLDFIN( STJ->TJ_ORDEM )[1]
				lRet := .F.
			EndIf

			If lRet .And. NGFUNCRPO("NGRESPETAEX",.F.)
				If !NGRESPETAEX( STJ->TJ_ORDEM, .T., oTmpTbl3:GetRealName(), .F. )
					lRet := .F.
				EndIf
			EndIf

			//Valida se o usuario tem permissão
			/*
			If lRet .And. !Empty(cRet400)
				If !(Upper(AllTrim(cUsername)) $ Upper(AllTrim(cRet400)))
					MsgStop("Usuário não autorizado para encerrar a O.S.","ATENÇÃO")
					lRet := .F.
				EndIf
			EndIf
			*/
			//Valida se existir ponto de entrada
			If lRet .And. ExistBlock("MNT40011")
				lRet := ExecBlock("MNT40011",.F.,.F.)
			EndIf

			//Valida se tem ordem de producao
			If lRet .And. cUsaInt3 == "S"
				dbSelectArea("SC2")
				dbSetOrder(01)
				If !dbSeek(xFilial("SC2")+STJ->TJ_ORDEM+"OS001")
					MsgInfo(cErro := "A Ordem de Serviço  "+STJ->TJ_ORDEM+" não poderá ser finalizada, pois" + ;
					chr(13)+chr(10)+"não existe Ordem de Produção para a mesma.","ATENÇÃO")
					lRet := .F.
				EndIf
			EndIf


			If lRet .And. !lSemIns // Verifica se pode finalizar a O.S. sem insumo //Nao tem insumo
				//Valida se tem algum insumo reportado
				nPDR := aScan(aCoBrw6 ,{|x| !Empty(x[nPoY]) .And. !Empty(x[nPos]) .And. !Empty(x[nPox]) .And. !x[Len(x)] })
				If nPDR == 0
					//-- GV -- Removido, pois no padrão é permitido esta finalizar.
					//MsgInfo(cErro := "A Ordem de Serviço "+STJ->TJ_ORDEM+" não poderá ser finalizada, pois"+;
					//chr(13)+chr(10)+"não existe insumo realizado.","ATENÇÃO")
					//lRet := .F.
				EndIf
			EndIf

			If lRet
				//Se MV_NGREPRE = S, verifica se tem algum insumo faltando reportar a quantidade prevista
				lRetNgRep := If(cParSX6Ret == Nil .Or. Empty(cParSX6Ret) .Or. Alltrim(cParSX6Ret) == "N",.F.,.T.)
				If lRetNgRep
					lINSUSRET := .F.
					For nYY := 1 To Len(aCoBrw2)
						nQUATINS := 0
						If aCoBrw2[nYY,nPos] != "E"
							For nXX := 1 To Len(aCoBrw6)
								If ((nNumSa > 0 .And. !Empty(aCoBrw2[nYY,nNumSa])) .Or. aCoBrw6[nXX,nPoY] == aCoBrw2[nYY,nPoY]) .And.;
									aCoBrw6[nXX,nPos] == aCoBrw2[nYY,nPos] .And. aCoBrw6[nXX,nPox] == aCoBrw2[nYY,nPox]  .And.;
									!aCoBrw6[nXX, Len(aCoBrw6[nXX])]

									nQUATINS += aCoBrw6[nXX,nPoQ]
								EndIf
							Next nXX
						EndIf
						If nQUATINS < aCoBrw2[nYY,nPoQ] .And. aCoBrw2[nYY,nPos] != "E"
							lINSUSRET := .T.
							Exit
						EndIf
					Next nYY
					If lINSUSRET //Nao reportou tudo que foi previsto
						If !MsgYesNo("Para alguns insumos não foram reportadas a quantidade prevista."+;
						chr(13)+chr(10)+"Deseja finalizar assim mesmo?","ATENÇÃO")
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf

			If lRet
				//Localiza Data/Hora fim da OS
				lSEQUEN0 := .T.
				//Varinfo('aCoBrw6',aCoBrw6)
				For nXX := 1 To Len(aCoBrw6)
					If aCoBrw6[nXX, Len(aCoBrw6[nXX]) ]
						Loop
					EndIf
					If Valtype(aCoBrw6[nXX,nDtI]) == "C"
						aCoBrw6[nXX,nDtI] := StoD(aCoBrw6[nXX,nDtI])
					EndIf
					If Valtype(aCoBrw6[nXX,nDtF]) == "C"
						aCoBrw6[nXX,nDtF]:= StoD(aCoBrw6[nXX,nDtF])
					EndIf
					lTemIReal := .T.
					If aCoBrw6[nXX,nPos] == "P"
						If Len(aFin2P) == 0
							aFin2P := {aCoBrw6[nXX,nDtI],aCoBrw6[nXX,nHoI],aCoBrw6[nXX,nDtI],aCoBrw6[nXX,nHoI]}
						Else
							If DtoS(aCoBrw6[nXX,nDtI]) + aCoBrw6[nXX,nHoI] > DtoS(aFin2P[3])+aFin2P[4]
								aFin2P[3] := aCoBrw6[nXX,nDtI]
								aFin2P[4] := aCoBrw6[nXX,nHoI]
							EndIf
							If DtoS(aCoBrw6[nXX,nDtI]) + aCoBrw6[nXX,nHoI] < DtoS(aFin2P[1])+aFin2P[2]
								aFin2P[1] := aCoBrw6[nXX,nDtI]
								aFin2P[2] := aCoBrw6[nXX,nHoI]
							EndIf
						EndIf
						Loop
					Else //Se possuir insumo diferente de produto atribui .F. para a variavel
						lSoProd := .F.
					EndIf
					If lSEQUEN0
						dMINSTL := aCoBrw6[nXX,nDtI]
						If Valtype(dMINSTL) == "C"
							dMINSTL := StoD(dMINSTL)
						EndIf
						hMINSTL := aCoBrw6[nXX,nHoI]
						dMAXSTL := aCoBrw6[nXX,nDtF]
						If Valtype(dMAXSTL) == "C"
							dMAXSTL := StoD(dMAXSTL)
						EndIf
						hMAXSTL := aCoBrw6[nXX,nHoF]
						lSEQUEN0 := .F.
					EndIf
					If aCoBrw6[nXX,nDtI] < dMINSTL
						dMINSTL := aCoBrw6[nXX,nDtI]
						hMINSTL := aCoBrw6[nXX,nHoI]
					ElseIf aCoBrw6[nXX,nDtI] = dMINSTL
						hMINSTL := If(aCoBrw6[nXX,nHoI] < hMINSTL,aCoBrw6[nXX,nHoI],hMINSTL)
					EndIf
					dMAXF := aCoBrw6[nXX,nDtF]
					hMAXF := aCoBrw6[nXX,nHoF]
					If dMAXF > dMAXSTL
						dMAXSTL := dMAXF
						hMAXSTL := hMAXF
					ElseIf dMAXF = dMAXSTL
						dMAXSTL := If(dMAXF > dMAXSTL,dMAXF,dMAXSTL)
						hMAXSTL := If(hMAXF > hMAXSTL,hMAXF,hMAXSTL)
					EndIf
				Next nXX
			EndIf

			//Se possuir vários tipos de insumos deve validar com o produto, pois os produtos estão no array aFin2P
			If Len( aFin2P ) > 0

				//Verifica se a data do produto é menor a do outro insumo, se for deve pegar a data e horário desse produto
				If aFin2P[1] < dMINSTL

					dMINSTL := aFin2P[1]
					hMINSTL := aFin2P[2]

				//Se a data do produto for igual ao do outro insumo, deve verificar qual possui o menor horário para ser considerado
				ElseIf aFin2P[1] == dMINSTL .And. aFin2P[2] <= hMINSTL

					hMINSTL := aFin2P[2]

				EndIf

				//Verifica se a data do produto é menor a do outro insumo, se for deve pegar a data e horário desse produto
				If aFin2P[3] > dMAXSTL

					dMAXSTL := aFin2P[3]
					hMAXSTL := aFin2P[4]

				//Se a data do produto for igual ao do outro insumo, deve verificar qual possui o menor horário para ser considerado
				ElseIf aFin2P[3] == dMAXSTL .And. aFin2P[4] >= hMAXSTL

						hMAXSTL := aFin2P[4]

				EndIf

			EndIf

			//Valida se tem Data/Hora FIM OS
			If lRet .And. !lSemIns .And. !lTemIReal
				MsgInfo(cErro := "A Ordem de Serviço "+stj->tj_ordem+" não poderá ser finalizada, pois"+;
				chr(13)+chr(10)+"não existe insumo realizado.","ATENÇÃO")
				lRet := .F.
			EndIf

			// Se estiver integrado ao SIGASFC
			// Verifica se é possível finalizar a O.S.
			If lRet .And. lIntSFC .And. !NGSFCATPRD(STJ->TJ_ORDEM,{{"CZ2_LGMN",.F.}},.F.,.F.)
				NGSFCSNDML(4, {{STJ->TJ_ORDEM}})
				lRet := .F.
			EndIf

			If lRet
				/*--------------+
				| Finaliza O.S. |
				+--------------*/
				aFinTmp := { dMINSTL, hMINSTL, dMAXSTL, hMAXSTL, lSoProd }
				nRET    := 0

				grvFN435( 'STJ', (cAliOS435)->RECNO, 4, aFinTmp, , aFin2P )

				If nRET == 1
					aAdd( aVetorFin , { cOrdem, cPlano } )
				EndIf
			EndIf

		Else
			MsgInfo(cErro := "Nenhuma ordem de serviço foi selecionada.")
		EndIf
	EndIf

	If lRet .And. !lArvoreLogica
		PutFileInEof("STN")
		PutFileInEof("TPL")
		PutFileInEof("STL")
	EndIf

Return lRet

static function grvFN435(cALIAS,nREG,nOPCX,aVetData,nOSnAt,_aFin2P) // fFina435

	Local nRecnSTJ, nCont
	Local cTipoCon   := " "
	Local lSoProduto := aVetData[5]
	Local cLanex     := IIf(FindFunction('NGUSELANEX'), NGUSELANEX( STJ->TJ_CODBEM ) , ;
						AllTrim( SuperGetMv( 'MV_NGLANEX', .F., '' ) )  )

	Local lSemIns := ExistBlock("NGSEMINS")

	Private bNGGRAVA, aCHKDEL     := {}
	Private TipoAcom, TipoAcom2, lFimOsWhen  := Nil

	Store .F. To TipoAcom, TipoAcom2

	nRET := 0

	dDTMRINI := STJ->TJ_DTMRINI
	dDTMRFIM := STJ->TJ_DTMRFIM
	cHOMRINI := STJ->TJ_HOMRINI
	cHOMRFIM := STJ->TJ_HOMRFIM
	nCONTOL1 := STJ->TJ_POSCONT
	nCONTOL2 := STJ->TJ_POSCON2

	dbSelectArea("STJ")
	dbSetOrder(1)
	dbSeek( xFilial("STJ") + cOrdemTJ + cPlanoTJ )

	nINDSTJ  := IndexOrd()
	nRECSTJ  := Recno()
	nREGFIM  := Recno()

	cBemRet  := Space( TAMSX3("TJ_CODBEM")[1] )
	cBemRet  := NGTBEMPAI( STJ->TJ_CODBEM, cBemRet)
	cBemRet  := IIf( Empty(cBEMRET), STJ->TJ_CODBEM, cBemRet )

	cTIPOCON := NGSEEK("ST9",cBEMRET,1,"T9_TEMCONT")
	TIPOACOM := ( cTIPOCON == "S" )
	nCONTBEM := ST9->T9_POSCONT
	nCONTSTJ := 0
	//FindFunction remover na release GetRPORelease() >= '12.1.027'
	If FindFunction("MNTCont2")
		TipoAcom2 := MNTCont2(xFilial("TPE"), cBemRet )
	Else
		dbSelectArea("TPE")
		dbSetOrder( 1 )
		TipoAcom2 := ( dbSeek( xFilial("TPE") + cBemRet ) )
	EndIf

	dbSelectArea("STJ")
	//VERIFICA A DATA E HORA FINAL PARA O.S. COM INSUMOS REAL
	dDTINI := aVetData[1]
	hORINI := aVetData[2]
	dDTFIM := aVetData[3]
	hORFIM := aVetData[4]

	If lSoProduto
		If Len(_aFin2P) == 0
			dDTFIM := dDataBase
			hORFIM := Time()
		EndIf
	EndIf

	vCONLA := NGACUMEHIS(cBEMRET,dDTFIM,hORFIM,1,IIf( !Empty(cLanex), "E", "P" ) )
	aCHOICE := {"TJ_ORDEM", "TJ_DTPRINI", "TJ_DTPRFIM", "TJ_HOPRINI", "TJ_HOPRFIM", "TJ_POSCONT",;
	"TJ_HORACO1", "TJ_POSCON2", "TJ_HORACO2", "TJ_DTMRINI", "TJ_HOMRINI", "TJ_DTMRFIM",;
	"TJ_HOMRFIM", "TJ_OBSERVA"}

	If ExistBlock("MNT40017")
		ExecBlock("MNT40017",.F.,.F.)
	EndIf

	If lSoProduto .Or. lSemIns //Verifica se existe só insumo do tipo produto ou utilizar o P.E. NGSEMINS
		lFimOsWhen := .T.
	EndIf

	aRELAC  := { { "TJ_POSCONT", "vCONLA[1]" },;
					( IIf( TipoAcom, { "TJ_HORACO1", "hORFIM" }, { "TJ_HORACO1", "''" } ) ),;
					{ "TJ_DTMRINI", "dDTINI" },;
					{ "TJ_HOMRINI", "hORINI" },;
					{ "TJ_DTMRFIM", "dDTFIM" },;
					{ "TJ_HOMRFIM", "hORFIM" },;
					( IIf( TipoAcom2, { "TJ_HORACO2", "hORFIM" }, { "TJ_HORACO2", "''" } ) ) }

	If cTENDFLAHA <> "N" .And. STJ->TJ_PLANO == "000000" //os corretiva
		aAdd( aCHOICE, "TJ_IRREGU" )
		aAdd( aCHOICE, "TJ_NIRREGU" )
	EndIf

	If ExistBlock("MNT40012")
		aRelacPE := ExecBlock("MNT40012",.F.,.F.,{aHoBrw6, aCoBrw6})
	EndIf

	If(Type("aRelacPE") == "A")
		If Len(aRelacPE) > 0
			For nCont := 1 To Len(aRelacPE)
				aAdd(aRELAC,aRelacPE[nCont])
			Next
		EndIf
	EndIf

	dbSelectArea("STJ")
	bNGGRAVA := { || NG435CHK( nOSnAt, lSoProduto ) .And. fInteg( cOrdemTJ ) }

	Inclui      := .F.
	nRet        :=  grvDados("STJ") // NGCAD01(,nREG,4)
	Inclui      := .T.
	bNGGRAVA    := {}

	dbSelectArea("STJ")
	nRECNSTJ := Recno()
	If nRET == 1
		/*Ponto de entrada disponível para customização específica na Finalização do Retorno da Ordem de Serviço. SS: 021345*/
		If ExistBlock("MNTA4352")
			nRet := ExecBlock("MNTA4352",.F.,.F., { nRET })
		EndIf
		/*-----------------------------+
		| Integração SIGAGFR x SIGALOC |
		+-----------------------------*/
		If SuperGetMV( 'MV_NG1LOC', .F., .F. ) .And.;
			FindFunction( 'LOCM001' )

			 LOCM001()
		endif
	EndIf

	If nRET == 1
		cAORDEM   := STJ->TJ_ORDEM
		cAPLANO   := STJ->TJ_PLANO
		cACODBEM  := STJ->TJ_CODBEM
		cASERVICO := STJ->TJ_SERVICO
		nASEQUENC := STJ->TJ_SEQRELA
		nCONTSTJ  := STJ->TJ_POSCONT
		nDIFX     := nCONTSTJ - nCONTBEM
		nDIF      := IIf( nDIFX > 0, nDIFX, 0 )

		NGFINAL( STJ->TJ_ORDEM, STJ->TJ_PLANO, STJ->TJ_DTPRINI, STJ->TJ_HOPRINI,;
		STJ->TJ_DTPRFIM, STJ->TJ_HOPRFIM, STJ->TJ_POSCONT, STJ->TJ_POSCON2,;
		cBEMRET, STJ->TJ_HORACO1, STJ->TJ_HORACO2, nDIF)

		lSTJAchou := A400STJBUS(cACODBEM)
		dbSelectArea("ST9")
		dbSetOrder(1)
		If dbSeek(xFilial("ST9")+cACODBEM)
			RecLock("ST9",.F.)
			If lSTJAchou = .F.
				ST9->T9_TERCEIR := "1"
			EndIf
			ST9->(MsUnlock())
		EndIf

		lOSPOST := ( AllTrim( GetMv("MV_NGREPRO") ) == "S" )
		If STJ->TJ_DTMRFIM <> STJ->TJ_DTMPFIM .And. Val(STJ->TJ_PLANO) > 0 .And. lOSPost
			NGOSREPROG( STJ->TJ_CODBEM, STJ->TJ_SERVICO, STJ->TJ_SEQRELA, STJ->TJ_DTMRFIM, STJ->TJ_DTMPFIM )
		EndIf

		dbSelectArea("STJ")
		dbGoto(nRECSTJ)
		If ExistBlock("NG400FI1")
			ExecBlock("NG400FI1",.F.,.F.)
		EndIf

		dbSelectArea("STJ")
		nREGFIM := Recno()
		dbGoto(nRECSTJ)

		// Fechamento de solicitacao de servico
		// utiliza o PE MNTA400N para nao abrir tela
		fNGFECHASS(stj->tj_ordem)
	EndIf

	dbSelectArea("STJ")
	dbSetOrder(nINDSTJ)
	lREFRESH := .T.

Return (nRet == 1)

Static Function fAddIndex( aFields, aPesq )

	Local aIndAux := {}
	Local aValInd := {}
	Local aIndSIX := FWSIXUtil():GetAliasIndexes( 'STJ' )
	Local nInd1   := 0

	/*-----------------------------------------------------+
	| Valida todos os indices disponiveis para tabela STJ. |
	+-----------------------------------------------------*/
	For nInd1 := 1 To Len( aIndSIX )

		If !Empty( aIndAux := fIndTRB( aFields, aIndSIX[ nInd1 ] ) )

			/*-------------------------------------------------------------------+
			| Realiza a validação dos indices antes de inclui-los na temporária. |
			+-------------------------------------------------------------------*/
			fValInd( aIndAux, @aValInd )

		EndIf

	Next nInd1

	/*--------------------------------------------------+
	| Inclui os indices validados na tabela temporária. |
	+--------------------------------------------------*/
	For nInd1 := 1 To Len( aValInd )

		If !Empty( aValInd[nInd1] )

			oTmpTblOS:AddIndex( cValToChar( nInd1 ), aClone( aValInd[nInd1] ) )

			aAdd( aPesq, { aOrdIx435[nInd1], { { '', 'C', 255, 0, '', '@!' } }, 2 } )

		EndIf

	Next nInd1

	FWFreeArray( aIndAux )
	FWFreeArray( aValInd )
	FWFreeArray( aIndSIX )

Return

Static Function fIndTRB( aDBF, aSIX )

	Local aIndTRB := {}
	Local cField  := ''
	Local nQtdSIX := Len( aSIX )
	Local nFldSIX

	For nFldSIX := 1 To nQtdSIX

		If 'DTOS' $ Upper( aSIX[ nFldSix ] )
			cField := StrTran( SubStr( aSIX[ nFldSix ], 6, Len( aSIX[ nFldSix ] ) ), ')', '' )
		Else
			cField := aSIX[ nFldSIX ]
		EndIf

		If ( nPosFld := aScan( aDBF, { | x | x[ 1 ] == cField } ) ) > 0
			aAdd( aIndTRB, cField )
		EndIf

	Next nFldSIX

Return aIndTRB

Static Function fValInd( aIndAdd, aIndOld )

	Local nInd     := 0
	Local nInd2    := 0
	Local lReturn  := .T.
	Local nSizInd1 := Len( aIndAdd ) // Tamanho do novo indice

	/*------------------------------------------------------------+
	| Percorre todos os índices já inclusos no array de controle. |
	+------------------------------------------------------------*/
	For nInd := 1 To Len( aIndOld )

		nSizInd2 := Len( aIndOld[ nInd ] ) // Tamanho do indice atual

		If nSizInd2 == 0

			Loop

		EndIf

		lReturn := .F.

		/*----------------------------------------------------------------------------------+
		| Percorre todos os campos do índice posiciona que já incluso no array de controle. |
		+----------------------------------------------------------------------------------*/
		For nInd2 := 1 To nSizInd2

			/*-------------------------------------------------------------------------------+
			| Se o tamanho do indice incluso é menor que o índice posiciona, encerra o loop. |
			+-------------------------------------------------------------------------------*/
			If nInd2 > nSizInd1

				Exit

			EndIf

			/*--------------------------------------------------------------------------------------------+
			| Se existirem campos diferentes entre o indice incluso e o índice posiciona, encerra o loop. |
			+--------------------------------------------------------------------------------------------*/
			If aIndOld[ nInd, nInd2 ] != aIndAdd[ nInd2 ]

				lReturn := .T.

				Exit

			EndIf

		Next nInd2

		If !lReturn

			/*-----------------------------------------------------------------------------------------------+
			| Se o indice incluso sobrepõe um indice no array de controle, sobrescreve o array de controle. |
			+-----------------------------------------------------------------------------------------------*/
			If nSizInd1 > nSizInd2

				/*----------------------------------------------------------+
				| Zera o índice na posição sobreposta do array de controle. |
				+----------------------------------------------------------*/
				aIndOld[nInd] := {}

				lReturn := .T.

			EndIf

			Exit

		EndIf

	Next nInd

	If lReturn

		/*----------------------------------------+
		| Adiciona o índice no array de controle. |
		+----------------------------------------*/
		aAdd( aIndOld, aIndAdd )

	Else

		/*-----------------------------------------------------------------------------------------------+
		| Adiciona o posição vazia no array de controle. Para manter a ordem dos indices dentro do array |
		+-----------------------------------------------------------------------------------------------*/
		aAdd( aIndOld, {} )

	EndIf

Return

Static Function fRefreshOS( cTJ_ORDEM, cTJ_PLANO, nLinSTL, lRatIns )

	Local lRet		:= .T.
	Local nLinOS	:= 0

	//Controle dos parâmetros MV_PAR01, MV_PAR02 e MV_PAR05
	Private cPar01 := Space(6)
	Private cPar02 := Space(6)
	Private cPar05 := Space(3)

	Default lRatIns := .F.

	If !( IsIncallStack("NGMUStoLvl") .Or. IsIncallStack("NGMUGetSit") )

		//Se o número da OS nao existir no array
		nLinOS := aScan( aDadosOS, {| x| x[1] + x[2] == cTJ_ORDEM + cTJ_PLANO } )

		If nLinOS == 0

			// Limpa tabelas temporárias quando não houver O.S. para serem apresentadas
			NGZap( oTmpTbl3:GetRealName() )

			NGZap( oTmpTbl4:GetRealName() )

			NGZap( oTmpTbl5:GetRealName() )
			
			NGZap( oTmpTbl6:GetRealName() )
		
			// Tratamento para o correto carregamento dos insumos realizados
			lClearData := .T.

			If Type( 'oBrw5' ) == 'O'

				// Insumos realizados
				aCoBrw6     := aClone( aNovoSTL )
				oBrw6:aCols := aClone( aCoBrw6 )
				oBrw6:oBrowse:Refresh()
				oBrw6:oBrowse:SetFocus()

				// Ocorrencias
				oGd435Ocr:aCols := BlankGetD( aHoBrw3 )
				oGd435Ocr:ForceRefresh()

				If TT9->( FieldPos( 'TT9_CARACT' ) ) > 0

					oGd435Ass:aCols := BlankGetD( aHoBrw3_2 )
					oGd435Ass:ForceRefresh()

				EndIf

				// Motivo de Atraso
				aCoBrw4 := BLANKGETD(aHoBrw4)
				oBrw5:oBrowse:Refresh()
				oBrw5:oBrowse:SetFocus()

				// Etapas
				oBrw4:Refresh()

			EndIf

			Return .T.
		EndIf

		If Empty(cTJ_ORDEM)
			Return .T.
		EndIf

		dbSelectArea("STJ")
		dbSetOrder(01)
		dbSeek(xFilial("STJ")+cTJ_ORDEM+cTJ_PLANO)
		dbSelectArea("STF")
		dbSetOrder(01)
		dbSeek(xFilial("STF")+STJ->TJ_CODBEM+STJ->TJ_SERVICO+STJ->TJ_SEQRELA)
		M->TF_CODBEM  := STJ->TJ_CODBEM
		M->TF_SERVICO := STJ->TJ_SERVICO
		M->TF_SEQRELA := STJ->TJ_SEQRELA
		M->TJ_ORDEM   := STJ->TJ_ORDEM
		M->TJ_PLANO   := STJ->TJ_PLANO
		M->TJ_CODBEM  := STJ->TJ_CODBEM
		cOrdemTJ      := M->TJ_ORDEM
		cPlanoTJ      := M->TJ_PLANO
		cCdBemTJ      := M->TJ_CODBEM
		M->TL_TIPOREG := Space(01)
		MV_PAR01      := STJ->TJ_CODBEM
		MV_PAR02      := STJ->TJ_SERVICO
		MV_PAR05      := STJ->TJ_SEQRELA
		cPar01			:= MV_PAR01
		cPar02 		:= MV_PAR02
		cPar05 		:= MV_PAR05
		lCORRET       := If( Val(STJ->TJ_PLANO) == 0 , .T. , .F. )  //Indica que a OS é corretiva ou nao

		If STJ->TJ_TIPOOS == "B"
			If !NGBEMATIV(STJ->TJ_CODBEM)
				lRet := .F.
			EndIf
			If !NGMANATIV(STJ->TJ_CODBEM,STJ->TJ_SERVICO,STJ->TJ_SEQRELA)
				lRet := .F.
			EndIf
		EndIf

		/*---------------+
		| Carrega Etapas |
		+---------------*/
		LoadEtapas(cTJ_ORDEM, cTJ_PLANO, nLinOS)

		/*-----------------------+
		| Carrega Motivos Atraso |
		+-----------------------*/
		LoadMotAtr(cTJ_ORDEM, cTJ_PLANO, nLinOS)

		If TT9->( FieldPos( 'TT9_CARACT' ) ) > 0
		
			/*--------------------+
			| Carrega Ocorrências |
			+--------------------*/
			fLoadOcorr( nLinOS, 1 )

		EndIf

		/*----------------+
		| Carrega Insumos |
		+----------------*/
		LoadInsum(cTJ_ORDEM, cTJ_PLANO, nLinOS, nLinSTL, lRatIns )

		//Atualiza texto do cabecalho
		cCadastro := cCadTemp + " O.S.: "+cTJ_ORDEM

		//Verifica se o parâmetro MV_NGHISES está como "N" para permitir a alteração do custo do insumo
		dbSelectArea("STJ")
		dbSetOrder(1)
		If dbSeek(xFilial("STJ") + cTJ_ORDEM + cTJ_PLANO)
			If STJ->TJ_SERVICO == "HISTOR"
				If cUIntHis == "N" .And. cUsaInt3 == 'S'
					lCusto := .T.
				Else
					lCusto := .F.
				EndIf
			ElseIf cUsaInt3 == 'S'
				lCusto := .F.
			EndIf
		EndIf

	EndIf

Return

Static Function fValidOK(lRetTela,lSetFocBt)

	Local nXX, nYY, nZZZ, nEE
	Local lRet := .T.
	Local nPosTip := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_TIPOREG"})
	Local nPosCod := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_CODIGO" })
	Local nPosLoc := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_LOCAL"  })
	Local nPosQtd := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_QUANTID"})
	Local nPos02  := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_DTINICI"})
	Local nPos03  := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_HOINICI"})
	Local nPos04  := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_DTFIM" })
	Local nPos05  := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_HOFIM" })
	Local nPosSub := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_NUMLOTE"})
	Local nPosLot := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_LOTECTL"})
	Local nPosEnd := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_LOCALIZ"})
	Local nPosNuS := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_NUMSERI"})
	Local dTratDtIn := Stod("") //-- GV Tratativas para datas
	Local dTratDtFm := Stod("") //-- GV tratativa para datas
	Local cTmpCod,cTmpOrdem,cTmpPlano
	Local cPosAnt := ""
	Local aVRET  := {.F.," "}

	If lSetFocBt
		If !NGLostFocus()
			Return .F.
		EndIf
	EndIf

	If Empty( (cAliOS435)->TJ_CODBEM )
		MsgInfo(cErro := "Não há registros a serem salvos!", 'Atenção' )
		Return .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida estoque dos produtos              ³
	//ÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//variavel nDiffoS representa, nesse ponto, a diferenca do que havia sido aplicado antes da alteracao
	//e o que está sendo aplicado após alteração
	nDiffOS := 0

	/*-------------------------------------------------------------------------------------------------+
	| Quando existir o param. MV_MNTREQ as validações de estoque são realizadas pelo ExecAuto MATA241. |
	+-------------------------------------------------------------------------------------------------*/
	If Len(aProd435) > 0 .And. !lESTNEGA .And. cUsaInt3  == "S" .And. !lHasMNTREQ

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida Saldo Lote                        ³
		//ÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			cChvPrAlm := "Nil"
			For nZZZ := 1 To Len(aLote435)
				nDiffOS := 0
				cChvPrAlm := aLote435[nZZZ,1] + aLote435[nZZZ,2] + aLote435[nZZZ,3]
				For nXX := 1 To Len(aDadosOS)
					If ValType(aDadosOS[nXX,4]) == "A" .And. ValType(aDadosOS[nXX,5]) == "A"
						For nYY := 1 To Len(aDadosOS[nXX,4])
							If aDadosOS[nXX,4,nYY,nPosTip] == "P"
								If aDadosOS[nXX,4,nYY,nPosCod]+aDadosOS[nXX,4,nYY,nPosLoc]+aDadosOS[nXX,4,nYY,nPosLot] == cChvPrAlm
									nDiffOS -= aDadosOS[nXX,4,nYY,nPosQtd]
								EndIf
							EndIf
						Next nYY
						For nYY := 1 To Len(aDadosOS[nXX,5])
							If aDadosOS[nXX,5,nYY,Len(aDadosOS[nXX,5,nYY])]
								Loop //Deletado
							EndIf
							If aDadosOS[nXX,5,nYY,nPosTip] == "P"
								If aDadosOS[nXX,5,nYY,nPosCod]+aDadosOS[nXX,5,nYY,nPosLoc]+aDadosOS[nXX,5,nYY,nPosLot] == cChvPrAlm
									nDiffOS += aDadosOS[nXX,5,nYY,nPosQtd]
									cPosAnt := aDadosOS[nXX,1]+aDadosOS[nXX,2]
								EndIf
							EndIf
						Next nYY
					EndIf
				Next nXX

				//Analisa se existe retiradas do estoque na tela e desconta do saldo atual.
				If nDiffOS > 0
					dbSelectArea("SB8")
					dbSetOrder(03)
					If dbSeek(xFilial("SB8")+cChvPrAlm)
						nSaldo:=SaldoLote(aLote435[nZZZ,1],aLote435[nZZZ,2],aLote435[nZZZ,3],NIL,.F.,.T.,NIL,dDataBase)
						If QtdComp(nSaldo) < QtdComp(nDiffOS)
							cHelp:="Produto "+AllTrim(aLote435[nZZZ,1])+chr(13)+"Local "+aLote435[nZZZ,2]+chr(13)+"Saldo Disponível ";
							+Alltrim(Transform(nSaldo,PesqPictQt("B8_SALDO", 14)))+chr(13)+"Lote "+Alltrim(aLote435[nZZZ,3])
							Help(" ",1,"A240LOTENE",,cHelp,4,1)
							lRet := .F.
						EndIf
					EndIf
				EndIf
				If !lRet
					Exit
				EndIf
			Next nZZZ
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida Saldo Sub-Lote                    ³
		//ÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			cChvPrAlm := "Nil"
			For nZZZ := 1 To Len(aSubL435)
				nDiffOS := 0
				cChvPrAlm := aSubL435[nZZZ,1] + aSubL435[nZZZ,2] + aSubL435[nZZZ,3] + aSubL435[nZZZ,4]
				For nXX := 1 To Len(aDadosOS)
					If ValType(aDadosOS[nXX,4]) == "A" .And. ValType(aDadosOS[nXX,5]) == "A"
						For nYY := 1 To Len(aDadosOS[nXX,4])
							If aDadosOS[nXX,4,nYY,nPosTip] == "P"
								If aDadosOS[nXX,4,nYY,nPosCod]+aDadosOS[nXX,4,nYY,nPosLoc]+aDadosOS[nXX,4,nYY,nPosLot]+aDadosOS[nXX,4,nYY,nPosSub] == cChvPrAlm
									nDiffOS -= aDadosOS[nXX,4,nYY,nPosQtd]
								EndIf
							EndIf
						Next nYY
						For nYY := 1 To Len(aDadosOS[nXX,5])
							If aDadosOS[nXX,5,nYY,Len(aDadosOS[nXX,5,nYY])]
								Loop //Deletado
							EndIf
							If aDadosOS[nXX,5,nYY,nPosTip] == "P"
								If aDadosOS[nXX,5,nYY,nPosCod]+aDadosOS[nXX,5,nYY,nPosLoc]+aDadosOS[nXX,5,nYY,nPosLot]+aDadosOS[nXX,5,nYY,nPosSub] == cChvPrAlm
									nDiffOS += aDadosOS[nXX,5,nYY,nPosQtd]
									cPosAnt := aDadosOS[nXX,1]+aDadosOS[nXX,2]
								EndIf
							EndIf
						Next nYY
					EndIf
				Next nXX

				//Analisa se existe retiradas do estoque na tela e desconta do saldo atual.
				If nDiffOS > 0
					dbSelectArea("SB8")
					dbSetOrder(02)
					If dbSeek(xFilial("SB8")+aSubL435[nZZZ,4]+aSubL435[nZZZ,3]+aSubL435[nZZZ,1]+aSubL435[nZZZ,2])
						nSaldoLote := SB8Saldo(.F.,.T.,NIL,NIL,NIL,NIL,NIL,dDataBase)
						If QtdComp(nSaldoLote) < QtdComp(nDiffOS)
							cHelp:="Produto "+AllTrim(aSubL435[nZZZ,1])+chr(13)+"Local "+aSubL435[nZZZ,2]+chr(13)+"Saldo Disponível ";
							+Alltrim(Transform(nSaldoLote,PesqPictQt("B8_SALDO", 14)))+chr(13)+"Lote "+Alltrim(aSubL435[nZZZ,3]);
							+chr(13)+"Sub-lote "+Alltrim(aSubL435[nZZZ,4])
							Help(" ",1,"A240LOTENE",,cHelp,4,1)
							cMsgfValidOK := "A240LOTENE - "+cHelp
							lRet := .F.
						EndIf
					EndIf
				EndIf
				If !lRet
					Exit
				EndIf
			Next nZZZ
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida Saldo Enderecamento               ³
		//ÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			cChvPrAlm := "Nil"
			For nZZZ := 1 To Len(aEnde435)
				nDiffOS := 0
				nEmpenho:= 0
				cChvPrAlm := aEnde435[nZZZ,1] + aEnde435[nZZZ,2] + aEnde435[nZZZ,3] + aEnde435[nZZZ,4] + aEnde435[nZZZ,5] + aEnde435[nZZZ,6]
				For nXX := 1 To Len(aDadosOS)
					If ValType(aDadosOS[nXX,3]) == "A" .And. ValType(aDadosOS[nXX,5]) == "A"
						For nEE := 1 To Len(aDadosOS[nXX,3])
							If aDadosOS[nXX,3,nEE,nPosTip] == "P"
								If aDadosOS[nXX,3,nEE,nPosCod] + aDadosOS[nXX,3,nEE,nPosLoc] == aEnde435[nZZZ,1] + aEnde435[nZZZ,2]
									nEmpenho += aDadosOS[nXX,3,nEE,nPosQtd]
									cOPEMP := aDadosOS[nXX,1]+"OS001"
									cOPCOD := aDadosOS[nXX,3,nEE,nPosCod]
								EndIf
							EndIf
						Next nEE
					EndIf
					If ValType(aDadosOS[nXX,4]) == "A" .And. ValType(aDadosOS[nXX,5]) == "A"
						For nYY := 1 To Len(aDadosOS[nXX,4])
							If aDadosOS[nXX,4,nYY,nPosTip] == "P"
								If aDadosOS[nXX,4,nYY,nPosCod]+aDadosOS[nXX,4,nYY,nPosLoc]+aDadosOS[nXX,4,nYY,nPosEnd]+;
								aDadosOS[nXX,4,nYY,nPosNuS]+aDadosOS[nXX,4,nYY,nPosLot]+aDadosOS[nXX,4,nYY,nPosSub] == cChvPrAlm

									nDiffOS -= aDadosOS[nXX,4,nYY,nPosQtd]
								EndIf
							EndIf
						Next nYY
						For nYY := 1 To Len(aDadosOS[nXX,5])
							If aDadosOS[nXX,5,nYY,Len(aDadosOS[nXX,5,nYY])]
								Loop //Deletado
							EndIf
							If aDadosOS[nXX,5,nYY,nPosTip] == "P"
								If aDadosOS[nXX,5,nYY,nPosCod]+aDadosOS[nXX,5,nYY,nPosLoc]+aDadosOS[nXX,5,nYY,nPosEnd]+;
								aDadosOS[nXX,5,nYY,nPosNuS]+aDadosOS[nXX,5,nYY,nPosLot]+aDadosOS[nXX,5,nYY,nPosSub] == cChvPrAlm

									nDiffOS += aDadosOS[nXX,5,nYY,nPosQtd]
									cPosAnt := aDadosOS[nXX,1]+aDadosOS[nXX,2]
								EndIf
							EndIf
						Next nYY
					EndIf
				Next nXX

				//Analisa se existe retiradas do estoque na tela e desconta do saldo atual.
				If nDiffOS > 0
					If QtdComp(SaldoSBF(aEnde435[nZZZ,2],aEnde435[nZZZ,3],aEnde435[nZZZ,1],aEnde435[nZZZ,4],aEnde435[nZZZ,5],;
					aEnde435[nZZZ,6],.F.)) + nEmpenho < QtdComp(nDiffOS)
						//Help(" ",1,"SALDOLOCLZ")
						cMsgfValidOK := "SALDOLOCLZ"
						lRet := .F.
					EndIf
				EndIf
				If !lRet
					Exit
				EndIf
			Next nZZZ
		EndIf

	EndIf

	//Valida as etapas
	If lRet
		lRet := MNTA435EFI()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida mao de obra alocada no mesmo horario
	//ÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		For nXX := 1 To Len(aDadosOS)
			If aVRET[1]
				Exit
			EndIf
			If ValType(aDadosOS[nXX,5]) == "A" //Se [insumos realizados] foi editado pelo usuario
				For nYY := 1 To Len(aDadosOS[nXX,5])
					If aVRET[1]
						Exit
					EndIf
					If aDadosOS[nXX,5][nYY,Len(aDadosOS[nXX,5][nYY])]
						Loop //Deletado
					EndIf
					cTmpCod   := aDadosOS[nXX,5,nYY,nPosCod]
					cTmpOrdem := aDadosOS[nXX,1]
					cTmpPlano := aDadosOS[nXX,2]
					cTmpTipoR := aDadosOS[nXX,5,nYY,nPosTip]
					If Valtype(aDadosOS[nXX,5][nYY,nPos02]) == "C"
						dTratDtIn:= StoD(aDadosOS[nXX,5][nYY,nPos02])
						aDadosOS[nXX,5][nYY,nPos02] := dTratDtIn
					EndIf
					If Valtype(aDadosOS[nXX,5][nYY,nPos04]) == "C"
						dTratDtFm:= StoD(aDadosOS[nXX,5][nYY,nPos04])
						aDadosOS[nXX,5][nYY,nPos04] := dTratDtIn
					EndIf
					lPROPLSTL := f435VlFun(cTmpCod,cTmpOrdem,cTmpPlano,aDadosOS[nXX,5][nYY,nPos02],aDadosOS[nXX,5][nYY,nPos03],;
											aDadosOS[nXX,5][nYY,nPos04],aDadosOS[nXX,5][nYY,nPos05],nXX,nYY,cTmpTipoR,.F.)
					If !lPROPLSTL
						aVRET := {.T.,"Registro informado ja existe"}
						cPosAnt := aDadosOS[nXX,1]+aDadosOS[nXX,2]
					EndIf
				Next nYY
			EndIf
		Next nXX
		If aVRET[1]
			lRet := .F.
			PutFileInEof("STL")
		EndIf
	EndIf

	//---------------------------------------------------------------
	//Realiza chamada do ponto de entrada para validações adicionais
	//---------------------------------------------------------------
	//If lRet .And. lPEMNTA435
	//	lRet := ExecBlock( "MNTA435N", .F., .F., { "VALID_CONFIRM", aDadosOS } )
	//EndIF

	lRetTela := .T.

Return lRet

Static Function LoadEtapas(_cOrdem,_cPlano, nLinOS)

	Local i,xx
	Local nInd1     := 0
	Local nInd2     := 0
	Local nPosResp  := 0
	Local cAliasQry := ''
	Local lTemTb8   := Type( 'aDadosOS[' + AllTrim( Str( nLinOS ) ) + ',8]' ) != 'A'
	Local lTemTb9   := Type("aDadosOS["+Alltrim(Str(nLinOS))+",9]") != "A"
	Local aTempCab
    Local cBanco  := Upper(TCGetDB())
	Local aSql := {'', ''}

	// [aDadosOS]
	// 1-Ordem / 2-Plano / 3-Previstos SALVO[] / 4-Realizados SALVO[] / 5-Realizados NOVO[]
	// 6-Motivos Atraso SALVO[] / 7-Motivos Atraso NOVO[] / 8-Etapas NOVO[] / 9-Etapas Outras OS[]

	If cBanco == 'ORACLE'
        aSql[2] := ' OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY '
    ElseIf cBanco $  'POSTGRES/MYSQL'
        aSql[2] := ' LIMIT 1 '
    Else
        aSql[1] := ' TOP 1 '
	EndIf

	NGZap( oTmpTbl3:GetRealName() )

	NGZap( oTmpTbl4:GetRealName() )
	
	NGZap( oTmpTbl5:GetRealName() )
	
	dbSelectArea("STJ")
	dbSetOrder(1)
	dbSeek(xFilial("STJ")+_cOrdem+_cPlano)

	Inclui := .F.

	//+----------------------------------+
	//| Carregando etapas de outras OS   |
	//+----------------------------------+
	If lTemTb9

		If cMVPAR01 $ '1/3'

			cAliasQry := GetNextAlias()

			If cMVPAR01 == '1'

				cQuery := " SELECT STQ.TQ_TAREFA, STQ.TQ_ETAPA, STQ.TQ_ORDEM, STJ.TJ_CODBEM,"
				cQuery += " STJ.TJ_SERVICO, STJ.TJ_SEQRELA,STJ.TJ_DTMPINI, STJ.TJ_PLANO, TPA.TPA_DESCRI,"

				If SuperGetMv( 'MV_NGTARGE', .F., '1' ) == '1'

					cQuery += "    ( SELECT TT9_DESCRI FROM " + RetSqlName( 'TT9' ) + " WHERE TT9_FILIAL = " + ValToSql( FWxFilial( 'TT9' ) )
					cQuery += "            AND TT9_TAREFA = STQ.TQ_TAREFA AND D_E_L_E_T_ = ' ' )"
					cQuery += " AS TARDESCRI "

				Else

					cQuery += " CASE WHEN STJ.TJ_PLANO = '000000' THEN ' '
					cQuery += " ELSE
					cQuery += "    ( SELECT " + aSql[1] + " T5_DESCRIC FROM " + RetSqlName( 'ST5' ) + " WHERE T5_FILIAL = " + ValToSql( FWxFilial( 'ST5' ) )
					cQuery += "            AND T5_CODBEM = STJ.TJ_CODBEM AND T5_TAREFA = STQ.TQ_TAREFA "
					cQuery += "            AND T5_SERVICO = STJ.TJ_SERVICO AND D_E_L_E_T_ = ' ' " + aSql[2] + " )"
					cQuery += " END AS TARDESCRI "

				EndIf
				cQuery += " FROM " + RetSQLName("STQ") + " STQ"
				cQuery += " INNER JOIN "+RetSqlName("STJ")+" STJ"
				cQuery += " ON (STQ.TQ_ORDEM = STJ.TJ_ORDEM) "
				cQuery += " INNER JOIN " + RetSQLName( "TPA" ) + " TPA "
				cQuery += " ON ( TPA.TPA_ETAPA = STQ.TQ_ETAPA )"
				cQuery += " WHERE STJ.TJ_CODBEM = '"+STJ->TJ_CODBEM+"'"
				cQuery += " AND STQ.TQ_OK = ''"
				cQuery += " AND (STQ.TQ_TAREFA <> '' OR STQ.TQ_ETAPA <> '') "
				cQuery += " AND STJ.TJ_ORDEM <> '"+_cOrdem+"' AND STJ.TJ_TERMINO = 'S' "
				cQuery += " AND STQ.TQ_FILIAL = " + ValToSQL( FWxFilial("STQ") ) + " AND STQ.D_E_L_E_T_ = ' ' "
				cQuery += " AND STJ.TJ_FILIAL = " + ValToSQL( FWxFilial("STJ") ) + " AND STJ.D_E_L_E_T_ = ' ' "
				cQuery += " AND TPA.TPA_FILIAL = " + ValToSQL( FWxFilial( 'TPA' ) ) + " AND TPA.D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

			Else

				BeginSQL Alias cAliasQry

					SELECT  STQ.TQ_TAREFA,
							STQ.TQ_ETAPA,
							STQ.TQ_ORDEM,
							STJ.TJ_CODBEM,
							STJ.TJ_SERVICO,
							STJ.TJ_SEQRELA,
							STJ.TJ_DTMPINI,
							STJ.TJ_PLANO,
							TPA.TPA_DESCRI,
							CASE
								WHEN STJ.TJ_PLANO = '000000' THEN ( SELECT TT9_DESCRI
																	FROM   %table:TT9%
																	WHERE  TT9_FILIAL = %xFilial:TT9%
																	AND TT9_TAREFA = STQ.TQ_TAREFA
																	AND %NotDel% )
								ELSE ( SELECT T5_DESCRIC
									FROM   %table:ST5%
									WHERE  T5_FILIAL = %xFilial:ST5%
											AND T5_CODBEM  = STJ.TJ_CODBEM
											AND T5_TAREFA  = STQ.TQ_TAREFA
											AND T5_SERVICO = STJ.TJ_SERVICO
											AND %NotDel% )
							END AS TARDESCRI
							FROM   %table:STJ% STJ
								INNER JOIN %table:STQ% STQ
										ON ( STJ.TJ_FILIAL = STQ.TQ_FILIAL
												AND STJ.TJ_ORDEM  = STQ.TQ_ORDEM
												AND STJ.TJ_CODBEM = %exp:STJ->TJ_CODBEM% )
								INNER JOIN %table:TPA% TPA
										ON ( TPA.TPA_ETAPA = STQ.TQ_ETAPA )
							WHERE  STQ.TQ_OK = ' '
								AND STJ.TJ_TERMINO = 'S'
								AND STJ.TJ_ORDEM  != %exp:_cOrdem%
								AND STQ.TQ_FILIAL  = %xFilial:STQ%
								AND STQ.%NotDel%
								AND STJ.TJ_FILIAL  = %xFilial:STJ%
								AND STJ.%NotDel%
								AND STJ.TJ_DTMRFIM || STJ.TJ_HOMRFIM = ( SELECT Max( STJ1.TJ_DTMRFIM || STJ1.TJ_HOMRFIM )
																		FROM  %table:STQ% STQ1
									INNER JOIN %table:STJ% STJ1
											ON ( STQ1.TQ_FILIAL = STJ1.TJ_FILIAL
													AND STQ1.TQ_ORDEM = STJ1.TJ_ORDEM )
									WHERE  STQ1.TQ_OK = ' '
										AND STQ1.TQ_FILIAL  = %xFilial:STQ%
										AND STQ1.%NotDel%
										AND STJ1.TJ_FILIAL  = %xFilial:STJ%
										AND STJ1.%NotDel%
										AND STJ1.TJ_TERMINO = 'S'
										AND STJ1.TJ_CODBEM  = %exp:STJ->TJ_CODBEM%
										AND STJ1.TJ_DTMRFIM || STJ1.TJ_HOMRFIM < %exp:DToS( dDataBase ) + SubStr( Time(), 1, 5 )%
										AND STQ1.TQ_TAREFA  = STQ.TQ_TAREFA
										AND STQ1.TQ_ETAPA   = STQ.TQ_ETAPA )
										AND STQ.TQ_TAREFA NOT IN ( SELECT STQ2.TQ_TAREFA
															FROM   %table:STQ% STQ2
																	INNER JOIN %table:STJ% STJ2
																			ON ( STQ2.TQ_FILIAL = STJ2.TJ_FILIAL
																				AND STQ2.TQ_ORDEM = STJ2.TJ_ORDEM )
															WHERE  STQ2.TQ_OK != ' '
																	AND STJ2.TJ_DTMRFIM || STJ2.TJ_HOMRFIM >=
																		STJ.TJ_DTMRFIM  || STJ.TJ_HOMRFIM
																	AND STQ2.TQ_FILIAL  = %xFilial:STQ%
																	AND STQ2.%NotDel%
																	AND STJ2.TJ_FILIAL  = %xFilial:STJ%
																	AND STJ2.%NotDel%
																	AND STJ2.TJ_TERMINO = 'S'
																	AND STJ2.TJ_CODBEM  = %exp:STJ->TJ_CODBEM%
																	AND STQ2.TQ_TAREFA  = STQ.TQ_TAREFA
																	AND STQ2.TQ_ETAPA   = STQ.TQ_ETAPA  )

								AND STQ.TQ_ETAPA NOT IN (SELECT STQ2.TQ_ETAPA
															FROM   %table:STQ% STQ2
																INNER JOIN %table:STJ% STJ2
																		ON ( STQ2.TQ_FILIAL = STJ2.TJ_FILIAL
																				AND STQ2.TQ_ORDEM = STJ2.TJ_ORDEM )
															WHERE  STQ2.TQ_OK != ' '
																AND STJ2.TJ_DTMRFIM || STJ2.TJ_HOMRFIM >= STJ.TJ_DTMRFIM || STJ.TJ_HOMRFIM
																AND STQ2.TQ_FILIAL  = %xFilial:STQ%
																AND STQ2.%NotDel%
																AND STJ2.TJ_FILIAL  = %xFilial:STJ%
																AND STJ2.%NotDel%
																AND STJ2.TJ_TERMINO = 'S'
																AND STJ2.TJ_CODBEM  = %exp:STJ->TJ_CODBEM%
																AND STQ2.TQ_TAREFA  = STQ.TQ_TAREFA
																AND STQ2.TQ_ETAPA   = STQ.TQ_ETAPA  )

								AND TPA.TPA_FILIAL = %xFilial:TPA%
								AND TPA.%NotDel%
				EndSQL
			EndIf

			aTempCab := {}
			dbSelectArea(cTRBTAR)
			(cAliasQry)->( dbGoTop() )
			While (cAliasQry)->( !EoF() )

				(cTRBTAR)->(DbAppend())
				(cTRBTAR)->TAREFA  := (cAliasQry)->TQ_TAREFA
				(cTRBTAR)->NOMETAR := (cAliasQry)->TARDESCRI
				(cTRBTAR)->ETAPA   := (cAliasQry)->TQ_ETAPA
				(cTRBTAR)->NOMEETA := (cAliasQry)->TPA_DESCRI
				(cTRBTAR)->ORDEM   := (cAliasQry)->TQ_ORDEM
				(cTRBTAR)->DTMPINI := STOD( (cAliasQry)->TJ_DTMPINI )

				aAdd( aTempCab, {   (cTRBTAR)->TAREFA,;
									(cTRBTAR)->NOMETAR,;
									(cTRBTAR)->ETAPA,;
									(cTRBTAR)->NOMEETA,;
									(cTRBTAR)->ORDEM,;
									(cTRBTAR)->DTMPINI } )

				(cAliasQry)->( dbSkip() )
			EndDo

			(cAliasQry)->( dbCloseArea() )

			If Len(aTempCab) == 0
				aAdd( aTempCab , { " ",;
				" ",;
				" ",;
				" ",;
				" ",;
				StoD("") } )
			EndIf

		EndIf

		If Type("aTempCab") == "A"
			aDadosOS[nLinOS,9] := aClone(aTempCab)
		Else
			aDadosOS[nLinOS,9] := Nil
		EndIf
	Else
		dbSelectArea(cTRBTAR)
		For i := 1 to Len(aDadosOS[nLinOS,9])
			(cTRBTAR)->(DbAppend())
			(cTRBTAR)->TAREFA  := aDadosOS[nLinOS,9,i,1]
			(cTRBTAR)->NOMETAR := aDadosOS[nLinOS,9,i,2]
			(cTRBTAR)->ETAPA   := aDadosOS[nLinOS,9,i,3]
			(cTRBTAR)->NOMEETA := aDadosOS[nLinOS,9,i,4]
			(cTRBTAR)->ORDEM   := aDadosOS[nLinOS,9,i,5]
			(cTRBTAR)->DTMPINI := aDadosOS[nLinOS,9,i,6]
		Next i
	EndIf

	//+---------------------------------------+
	//| Carregando etapas previstas desta OS  |
	//+---------------------------------------+
	If lTemTb8

		aTempCab := {}
		dbSelectArea("STQ")
		dbSetOrder(1)
		dbSeek(xFilial("STQ")+_cOrdem+_cPlano)
		While !EoF() .And. STQ->TQ_FILIAL == xFilial("STQ") .And. STQ->TQ_ORDEM == _cOrdem .And. STQ->TQ_PLANO == _cPlano

			If Empty(STQ->TQ_TAREFA) .And. Empty(STQ->TQ_ETAPA)
				dbSelectArea("STQ")
				dbSkip()
				Loop
			EndIf

			aTemp := {}

			RecLock( cTRBQ400, .T. )

				For nInd1 := 1 To Len( aTRBQ )

					xx := aTRBQ[nInd1,2]

					If Posicione( 'SX3', 2, aTRBQ[nInd1,2] , 'X3_CONTEXT' ) == 'V'

						(cTRBQ400)->( &xx. ) := CriaVar( AllTrim( xx ) )

					Else

						(cTRBQ400)->( &xx. ) := STQ->( &xx. )

					EndIf

					aAdd( aTemp, (cTRBQ400)->( &xx. ) )

				Next nInd1

				If STQ->( FieldPos( 'TQ_SEQRELA' ) ) > 0

					(cTRBQ400)->TQ_SEQRELA := STQ->TQ_SEQRELA

				Else

					(cTRBQ400)->TQ_SEQRELA := '0'

				EndIf
				
				If !Empty( STQ->TQ_OK )

					(cTRBQ400)->TQ_OK := cMarca
				
				EndIf

				(cTRBQ400)->TQ_ORDEM := STQ->TQ_ORDEM
				(cTRBQ400)->TQ_PLANO := STQ->TQ_PLANO
				(cTRBQ400)->CODBEM	 := STJ->TJ_CODBEM
				(cTRBQ400)->RECSTQ   := STQ->( RecNo() )

			MsUnLock()

			//Adicionando opcoes da etapa
			aOpcEtapa := {}
			dbSelectArea("TPQ")
			dbSetOrder(1)
			dbSeek(xFilial("TPQ") + _cOrdem +_cPlano + STQ->TQ_TAREFA + STQ->TQ_ETAPA )
			While !EoF() .And. TPQ->TPQ_FILIAL == xFilial("TPQ") .And.;
			TPQ->TPQ_ORDEM == _cOrdem .And. TPQ->TPQ_PLANO == _cPlano .And. ;
			TPQ->TPQ_TAREFA == STQ->TQ_TAREFA .And. TPQ->TPQ_ETAPA == STQ->TQ_ETAPA

				aAdd( aOpcEtapa , { "XX" , TPQ->TPQ_OPCAO , TPQ->TPQ_RESPOS } )

				RecLock( cTRB3400, .T. )
				
					(cTRB3400)->TPC_ETAPA  := STQ->TQ_ETAPA
					(cTRB3400)->TPC_TAREFA := STQ->TQ_TAREFA
					(cTRB3400)->TPC_OK     := "XX"
					(cTRB3400)->TPC_OPCAO  := TPQ->TPQ_OPCAO
					(cTRB3400)->TPC_RESPOS := TPQ->TPQ_RESPOS

				MsUnLock()

				dbSelectArea("TPQ")
				dbSkip()

			End

			/*----------------------------------------+
			| Define as cores para legenda de etapas. |
			+----------------------------------------*/
			fLegendEt( (cTRBQ400)->TQ_ORDEM + (cTRBQ400)->TQ_PLANO + (cTRBQ400)->TQ_TAREFA +;
				(cTRBQ400)->TQ_ETAPA + (cTRBQ400)->TQ_SEQRELA, 4 )

			aAdd( aTemp, (cTRBQ400)->TQ_OK )
			aAdd( aTemp, (cTRBQ400)->TQ_SEQRELA )
			aAdd( aTemp, (cTRBQ400)->RECSTQ )
			aAdd( aTemp, aOpcEtapa )
			aAdd( aTemp, (cTRBQ400)->STATUS )//STATUS#//MANTER A CRIAÇÃO DO CAMPO STATUS SEMPRE COMO ULTIMO NA TRB

			aAdd( aTempCab , aTemp )

			dbSelectArea("STQ")
			dbSkip()

		EndDo
	
		aDadosOS[nLinOS,8] := aClone(aTempCab)

	Else

		nPosResp := Len( aTrbQ ) + 4

		For nInd1 := 1 To Len( aDadosOS[nLinOS,8] )

			RecLock( (cTRBQ400), .T. )

				For nInd2 := 1 To Len( aTrbQ )

					cField := aTrbQ[nInd2,2]

					(cTRBQ400)->( &cField. ) := aDadosOS[nLinOS,8,nInd1,nInd2]
				
				Next nInd2
			
				(cTRBQ400)->TQ_OK      := aDadosOS[nLinOS,8,nInd1,nInd2++]
				(cTRBQ400)->TQ_SEQRELA := aDadosOS[nLinOS,8,nInd1,nInd2++]
				(cTRBQ400)->RECSTQ     := aDadosOS[nLinOS,8,nInd1,nInd2++]
				(cTRBQ400)->STATUS     := aDadosOs[nLinOS,8,nInd1,Len(aDadosOS[nLinOS,8,nInd1])]
				(cTRBQ400)->TQ_ORDEM   := _cOrdem
				(cTRBQ400)->TQ_PLANO   := _cPlano
				(cTRBQ400)->CODBEM	   := STJ->TJ_CODBEM

			MsUnLock()

			For nInd2 := 1 To Len( aDadosOS[nLinOS,8,nInd1,nPosResp] )

				RecLock( cTRB3400, .T. )
					
					(cTRB3400)->TPC_ETAPA  := (cTRBQ400)->TQ_ETAPA
					(cTRB3400)->TPC_TAREFA := (cTRBQ400)->TQ_TAREFA
					(cTRB3400)->TPC_OK     := aDadosOS[nLinOS,8,nInd1,nPosResp,nInd2,1]
					(cTRB3400)->TPC_OPCAO  := aDadosOS[nLinOS,8,nInd1,nPosResp,nInd2,2]
					(cTRB3400)->TPC_RESPOS := aDadosOS[nLinOS,8,nInd1,nPosResp,nInd2,3]

				MsUnLock()
			
			Next nInd2

		Next nInd1

	EndIf

	If cMVPAR01 == '3'

		dbSelectArea(cTRBQ400)
		dbSetOrder(2)
		dbGotop()
		While !EoF()
			dbSelectArea(cTRBTAR)
			dbSetOrder(2)
			If dbSeek( (cTRBQ400)->TQ_TAREFA + (cTRBQ400)->TQ_ETAPA )
				RecLock((cTRBTAR),.F.)
				dbDelete()
				(cTRBTAR)->(MsUnLock())
			EndIf

			dbSelectArea(cTRBQ400)
			dbSkip()
		EndDo

	EndIf

	Inclui := .T.

	dbSelectArea( cTRBQ400 )
	dbSetOrder( 3 ) // ordena visualização das etapas pela sequencia tarefa + etapa

	dbSelectArea(cTRBTAR)
	dbSetOrder(1)
	dbGotop()

Return .T.

Static Function LoadMotAtr(_cOrdem,_cPlano, nLinOS)
	Local cGETWHILE := "TPL_ORDEM == '"+  cOrdemTJ  +"'"
	Local lTemIns := .T.
	Local lTemAlt := .T.

	// [aDadosOS]
	// 1-Ordem / 2-Plano / 3-Previstos SALVO[] / 4-Realizados SALVO[] / 5-Realizados NOVO[]
	// 6-Motivos Atraso SALVO[] / 7-Motivos Atraso NOVO[] / 8-Etapas NOVO[] / 9-Etapas Outras OS[]

	If Type("aDadosOS["+Alltrim(Str(nLinOS))+",6]") <> "A"
		lTemIns := .F.
	EndIf
	If Type("aDadosOS["+Alltrim(Str(nLinOS))+",7]") <> "A"
		lTemAlt := .F.
	EndIf

	If lTemAlt
		aCoBrw4 := aClone(aDadosOS[nLinOS,7])
	Else
		dbSelectArea("TPL")
		dbSetOrder(1)
		Inclui := .F.
		aCoBrw4 := MAKEGETD("TPL", _cOrdem,  aHoBrw4, cGETWHILE,,.F.)

		If Len(aCoBrw4) == 0
			aCoBrw4 := BLANKGETD(aHoBrw4)
		EndIf

		Inclui := .T.
		aDadosOS[nLinOS,7] := aClone(aCoBrw4)
	EndIf

	If !lTemIns
		aDadosOS[nLinOS,6] := aClone(aCoBrw4)
	EndIf

	PutFileInEof("TPL")

	n:=1
	aCols   := aClone(aCoBrw4)
	aHeader := aClone(aHoBrw4)

Return .T.

Static Function LoadInsum(cTJ_ORDEM, cTJ_PLANO, nLinOS, nLinSTL, lRatIns )

	Local aBind     := {}
	Local aTemp     := {}
	Local cKEY      := ''
	Local cGETWHILE := ''
	Local cAlsOrd   := ''
	Local nG        := 0
	Local i         := 0
	Local nX2       := 0
	Local nPosNomCod:= 0
	Local nPosLoja 	:= 0
	Local nPosCod	:= 0
	Local nPosTipReg:= 0
	Local lTemIns   := .T.
	Local lTemAlt   := .T.
	Local lMNTA435P	:= ExistBlock("MNTA435P")
	Local cAliasSTL := ''
	Local cField    := ''

	Default lRatIns := .F.

	n:=1

	If Len(aDadosOS) == 0
		Return .T.
	ElseIf nLinOS == 0
		nLinOS := 1
	EndIf

	// [aDadosOS]
	// 1-Ordem / 2-Plano / 3-Previstos SALVO[] / 4-Realizados SALVO[] / 5-Realizados NOVO[]
	// 6-Motivos Atraso SALVO[] / 7-Motivos Atraso NOVO[] / 8-Etapas NOVO[] / 9-Etapas Outras OS[]
	If Type("aDadosOS["+Alltrim(Str(nLinOS))+",3]") <> "A" .Or. Type("aDadosOS["+Alltrim(Str(nLinOS))+",4]") <> "A"
		lTemIns := .F.
	EndIf
	If Type("aDadosOS["+Alltrim(Str(nLinOS))+",5]") <> "A"
		lTemAlt := .F.
	EndIf

	NGZap( oTmpTbl6:GetRealName() )

	dbSelectArea("STJ")
	dbSetOrder(1)
	dbSeek(xFilial("STJ")+cTJ_ORDEM+cTJ_PLANO,.T.)

	If !Empty(cTJ_ORDEM)

		//Carrega Insumos Previstos
		aCoBrw2 := {}
		If lTemIns
			aCoBrw2 := aClone(aDadosOS[nLinOS,3])
			For nX2 := 1 To Len(aCoBrw2)
				(cTRBIP)->(DbAppend())
				(cTRBIP)->TL_OK      := "  "
				(cTRBIP)->STATUS := "2"
				For i := 1 To Len(aHoBrw2)
					xx := aHoBrw2[i][2]
					(cTRBIP)->(&xx.) := aCoBrw2[nX2,i]
				Next i
				(cTRBIP)->XX_USACAL := If((cTRBIP)->TL_USACALE=="S","Sim",If((cTRBIP)->TL_USACALE=="N","Nao",(cTRBIP)->TL_USACALE))
				(cTRBIP)->XX_DESTIN := If((cTRBIP)->TL_DESTINO=="A","Apoio",If((cTRBIP)->TL_DESTINO=="S","Substituicao",If((cTRBIP)->TL_DESTINO=="T","Troca",(cTRBIP)->TL_DESTINO)))
				(cTRBIP)->XX_TEMGAR := If((cTRBIP)->TL_GARANTI=="S","Sim",If((cTRBIP)->TL_GARANTI=="N","Nao",(cTRBIP)->TL_GARANTI))
				(cTRBIP)->XX_NOMINS := GetNomeTip((cTRBIP)->TL_TIPOREG)
			Next nX2
		Else

			cAlsOrd := GetNextAlias()
			Inclui  := .F.

			BeginSQL Alias cAlsOrd

				SELECT
					STL.R_E_C_N_O_
				FROM
					%table:STL% STL
				WHERE
					STL.TL_FILIAL  = %xFilial:STL%       AND
					STL.TL_ORDEM   = %exp:cTJ_ORDEM%     AND
					STL.TL_PLANO   = %exp:cTJ_PLANO%     AND
					STL.TL_SEQRELA = '0  '               AND
					STL.%NotDel%
				ORDER BY
					STL.TL_SEQTARE

			EndSQL

			While (cAlsOrd)->( !EoF() )

				dbSelectArea( 'STL' )
				dbGoTo( (cAlsOrd)->R_E_C_N_O_ )

				(cTRBIP)->(DbAppend())
				(cTRBIP)->TL_OK  := "  "
				(cTRBIP)->STATUS := "2"
				aTemp := {}
				For i := 1 To Len(aHoBrw2)
					xx := aHoBrw2[i][2]
					If Posicione("SX3",2,xx ,"X3_CONTEXT") == "V"
						(cTRBIP)->(&xx.) := CriaVar( AllTrim(xx) )
					Else
						If xx == "TL_GARANTI"
							Inclui := .T.
							(cTRBIP)->(&xx.) := CriaVar( AllTrim(xx) )
							Inclui := .F.
						ElseIf Posicione("SX3",2,xx ,"X3_CONTEXT") != "V"
							(cTRBIP)->(&xx.) := STL->(&xx.)
						EndIf
					EndIf
					aAdd( aTemp , (cTRBIP)->(&xx.) )
				Next i
				
				(cTRBIP)->XX_USACAL := If((cTRBIP)->TL_USACALE=="S","Sim",If((cTRBIP)->TL_USACALE=="N","Nao",(cTRBIP)->TL_USACALE))
				(cTRBIP)->XX_DESTIN := If((cTRBIP)->TL_DESTINO=="A","Apoio",If((cTRBIP)->TL_DESTINO=="S","Substituicao",If((cTRBIP)->TL_DESTINO=="T","Troca",(cTRBIP)->TL_DESTINO)))
				(cTRBIP)->XX_TEMGAR := If((cTRBIP)->TL_GARANTI=="S","Sim",If((cTRBIP)->TL_GARANTI=="N","Nao",(cTRBIP)->TL_GARANTI))
				(cTRBIP)->XX_NOMINS := GetNomeTip((cTRBIP)->TL_TIPOREG)

				aAdd( aTemp  , {}  )
				aAdd( aTemp  , .F. )
				aAdd( aCoBrw2, aTemp )

				(cAlsOrd)->( dbSkip() )

			End

			(cAlsOrd)->( dbCloseArea() )

			Inclui := .T.

			nPosTipReg	:= aScan( aHoBrw2, {|x| Trim( Upper( x[2] ) ) == 'TL_TIPOREG' } )
			nPosCod		:= aScan( aHoBrw2, {|x| Trim( Upper( x[2] ) ) == 'TL_CODIGO' } )
			nPosLoja	:= aScan( aHoBrw2, {|x| Trim( Upper(x[2] ) ) == 'TL_LOJA' } )
			nPosNomCod	:= aScan( aHoBrw2, {|x| Trim( Upper( x[2] ) ) == 'TL_NOMCODI' } )

			For nG := 1 To Len( aCoBrw2 )

				M->TL_TIPOREG := aCoBrw2[nG, nPosTipReg]
				M->TL_CODIGO := aCoBrw2[nG, nPosCod]

				If nPosLoja > 0

					M->TL_LOJA := aCoBrw2[nG, nPosLoja]

				Else

					M->TL_LOJA := Space( Len( STL->TL_LOJA ) )

				EndIf


				If nPosNomCod > 0
					aCoBrw2[nG, nPosNomCod] := VirtInsumo( M->TL_TIPOREG, M->TL_CODIGO, M->TL_LOJA )
				EndIf
			Next
		EndIf

		cGETWHILE := "TL_FILIAL == xFilial('STL') .And. "
		cGETWHILE += "TL_ORDEM  == '"+cTJ_ORDEM+"' .And. "
		cGETWHILE += "TL_PLANO  == '"+cTJ_PLANO+"'"
		cKEY      := cTJ_ORDEM + cTJ_PLANO

		//Carrega Insumos Realizados
		aCoBrw6 := {}
		
		If !lClearData .And. lTemAlt

			aCoBrw6 := aClone(aDadosOS[nLinOS,5])

		ElseIf !lClearData .And. lTemIns

			aCoBrw6 := aClone(aDadosOS[nLinOS,4])

		Else
			
			Inclui := .F.

			If Empty( cQuerySTL )

				cQuerySTL := " SELECT"
				cQuerySTL += "    STL.R_E_C_N_O_ AS RECNO"
				cQuerySTL += " FROM " + RetSqlName( 'STL' ) + " STL"
				cQuerySTL += " WHERE  STL.TL_FILIAL  = ?"
				cQuerySTL += "    AND STL.TL_ORDEM   = ?"
				cQuerySTL += "    AND STL.TL_PLANO   = ?"
				cQuerySTL += "    AND STL.TL_SEQRELA > '0'"
				cQuerySTL += "    AND STL.D_E_L_E_T_ = ' '"
				cQuerySTL += " ORDER BY"
				cQuerySTL += "    STL.TL_SEQTARE"

			EndIf

			aBind := {}
			aAdd( aBind, FwxFilial( 'STL' ) )
			aAdd( aBind, cTJ_ORDEM )
			aAdd( aBind, cTJ_PLANO )
			
			cAliasSTL := GetNextAlias()

			dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQuerySTL, aBind ), cAliasSTL, .T., .T. )
			
			Do While (cAliasSTL)->( !EoF() )
				
				aTemp := {}
				
				STL->( DbGoTo( (cAliasSTL)->RECNO ) )

				For i := 1 To Len( aHoBrw6 )

					cField := aHoBrw6[ i, 2 ]

					If aHoBrw6[ i, 10 ] == 'V'
						
						aAdd( aTemp , CriaVar( AllTrim( aHoBrw6[ i, 2 ] ) ) )

					Else
						
						aAdd( aTemp , STL->( &cField. ) )

					EndIf

				Next i
				
				aAdd( aTemp , {} )
				aAdd( aTemp , .F. )
				aAdd( aCoBrw6 , aTemp )

				(cAliasSTL)->( dbSkip() )

			EndDo

			(cAliasSTL)->( dbCloseArea() )

			Inclui := .T.

			//Ponto de Entrada customizar ordenamento dos insumos
			If lMNTA435P
				aCoBrw6 := ExecBlock("MNTA435P",.F.,.F., {aCoBrw6,aHoBrw2})
			Else
				//Ordena pelo campo TL_SEQRELA
				nPos18 := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_SEQRELA"})
				If nPos18 > 0
					aSort(aCoBrw6,,,{|x,y| x[nPos18] < y[nPos18] })
				EndIf

			EndIf

		EndIf

		If Len( aCoBrw6 ) == 0

			aCoBrw6 := aClone( aNovoSTL )

		EndIf

		//Atualiza Insumos Previstos
		(cTRBIP)->(dbGoTop())

		//----------------------------------------------
		//Atualiza legenda/status dos insumos previstos
		//----------------------------------------------
		fStatus()

		//Atualiza Insumos Previstos
		(cTRBIP)->(dbGoTop())

		If !lTemIns
			aDadosOS[nLinOS,3] := aClone(aCoBrw2)
			aDadosOS[nLinOS,4] := aClone(aCoBrw6)
		EndIf

		fLoadSTL( nLinSTL )

		PutFileInEof("STL")

		lClearData := .F.

	EndIf

	FwFreeArray( aBind )

Return .T.

Static Function fLoadOcorr( nLinOS, nLinOcr )

	Local aLine   := {}
	Local nInd1   := 0
	Local nPosTar := GDFieldPos( 'TN_TAREFA' , aHoBrw3 )
	Local nPosPro := GDFieldPos( 'TN_CODOCOR', aHoBrw3 )
	Local nPosCau := GDFieldPos( 'TN_CAUSA'  , aHoBrw3 )
	Local nPosSol := GDFieldPos( 'TN_SOLUCAO', aHoBrw3 )
	Local nPosOcr := 0


	If !Empty( aDadosOS[nLinOS,_OCCURRENCES_] )

	Else

		SetInclui( .F. )

		/*---------------------------------------------------+
		| Carga inicial, busca as informações da tabela STN. |
		+---------------------------------------------------*/
		dbSelectArea( 'STN' )
		dbSetOrder( 1 ) // TN_FILIAL + TN_ORDEM + TN_PLANO + TN_TAREFA + TN_SEQRELA + TN_CODOCOR + TN_CAUSA + TN_SOLUCAO
		If msSeek( FWxFilial( 'STN' ) + cOrdemTJ + cPlanoTJ )

			While STN->( !EoF() ) .And. STN->TN_ORDEM == cOrdemTJ .And.;
				STN->TN_PLANO == cPlanoTJ

				RecLock( cAlsOcor, .T. )

					(cAlsOcor)->TN_ORDEM   := STN->TN_ORDEM   
					(cAlsOcor)->TN_PLANO   := STN->TN_PLANO  
					(cAlsOcor)->TN_TAREFA  := STN->TN_TAREFA 
					(cAlsOcor)->TN_SEQRELA := STN->TN_SEQRELA
					(cAlsOcor)->TN_CODOCOR := STN->TN_CODOCOR
					(cAlsOcor)->TN_CAUSA   := STN->TN_CAUSA  
					(cAlsOcor)->TN_SOLUCAO := STN->TN_SOLUCAO
					(cAlsOcor)->TN_DESCRIC := STN->TN_DESCRIC
					(cAlsOcor)->RECSTN     := STN->( RecNo() )

				MsUnLock()

				If ( nPosOcr := aScan( aDadosOS[nLinOS,_OCCURRENCES_], { |x| x[nPosTar] == STN->TN_TAREFA .And.;
					x[nPosPro] == STN->TN_CODOCOR .And.	x[nPosCau] == STN->TN_CAUSA .And. x[nPosSol] == STN->TN_SOLUCAO } ) ) == 0

					aLine := {}

					For nInd1 := 1 To Len( aHoBrw3 )
							
						If Posicione( 'SX3', 2, aHoBrw3[nInd1,2], 'X3_CONTEXT' ) == 'V'

							aAdd( aLine, CriaVar( AllTrim( aHoBrw3[nInd1,2] ) ) )

						ElseIf aHoBrw3[nInd1,2] == 'LEGENDA'

							If Trim( STN->TN_SEQRELA ) == '0'

								aAdd( aLine, 'BR_VERMELHO' )

							Else

								aAdd( aLine, 'BR_VERDE' )
								
							EndIf

						Else

							cField := aHoBrw3[nInd1,2]
							aAdd( aLine, &cField. )

						Endif
						
					Next nInd1

					aAdd( aLine, {} )

					aAdd( aLine, .F. )

					aAdd( aDadosOS[nLinOS,_OCCURRENCES_], aClone( aLine ) )

					/*----------------------------------------+
					| Posição da última ocorrência carregada. |
					+----------------------------------------*/
					nPosOcr := Len( aDadosOS[nLinOS,_OCCURRENCES_] )

				EndIf

				
				If Trim( STN->TN_SEQRELA ) != '0'

					/*------------------------------------------+
					| Carga de insumos associados à ocorrência. |
					+------------------------------------------*/
					fLoadAssoc( nLinOS, nPosOcr, STN->TN_TAREFA, STN->TN_CODOCOR,;
						STN->TN_CAUSA, STN->TN_SOLUCAO )

					/*--------------------------------------------------------+
					| Atualiza legenda para ocorrências com insumo associado. |
					+--------------------------------------------------------*/
					aDadosOS[nLinOS,_OCCURRENCES_,nPosOcr,1] := 'BR_VERDE'

				EndIf
				
				STN->( dbSkip() )

			End

		EndIf

		SetInclui( .T. )

		If !Empty( aDadosOS[nLinOS,_OCCURRENCES_] )
			
			aCoBrw3	 := aClone( aDadosOS[nLinOS,_OCCURRENCES_] )
			aBrw3Old := aClone( aCoBrw3 )

		Else

			aCoBrw3  := aClone( aNovaOcor )
			aBrw3Old := {}

		EndIf

	EndIf

	aCols    := aClone( aCoBrw3 )
	aHeader  := aClone( aHoBrw3 )

	FWFreeArray( aLine )
	
Return

Static Function fStatus()

	Local nIndex     := 0
	Local nPCodigo   := aScan( aHoBrw6, { | x | Trim( Upper( x[ 2 ] ) ) == "TL_CODIGO" } )
	Local nPTarefa   := aScan( aHoBrw6, { | x | Trim( Upper( x[ 2 ] ) ) == "TL_TAREFA" } )
	Local nPTiporeg  := aScan( aHoBrw6, { | x | Trim( Upper( x[ 2 ] ) ) == "TL_TIPOREG" } )
	Local nPQuantid  := aScan( aHoBrw6, { | x | Trim( Upper( x[ 2 ] ) ) == "TL_QUANTID" } )
	Local nNSA       := GDFieldPos( 'TL_NUMSA' , aHoBrw6 )
	Local nISA       := GDFieldPos( 'TL_ITEMSA', aHoBrw6 )
	Local nNSC       := GDFieldPos( 'TL_NUMSC' , aHoBrw6 )
	Local nISC       := GDFieldPos( 'TL_ITEMSC' , aHoBrw6 )
	Local nLine      := 0
	Local nQuantid   := 0 //quantidade do insumo realizado
	Local cCodigo    := "" //código do insumo realizado
	Local cTiporeg   := "" //tipo do insumo realizado
	Local nSizeField := TamSx3( "T2_CODFUNC" )[ 1 ]
	Local cStatus    := ""

	dbSelectArea( cTRBIP )
	dbGoTop()
	While !(cTRBIP)->( EoF() )

		nQuantid := 0


		// Somente para insumos do tipo Produto e que possuam vinculo com uma S.A.
		If (cTRBIP)->TL_TIPOREG == 'P' .And. ( nNSA > 0 .And. !Empty( (cTRBIP)->TL_NUMSA ) ) .And.;
			( nISA .And. !Empty( (cTRBIP)->TL_ITEMSA ) )

			nLine := 0

			// Considera a quantidade somente de insumos aplicados vinculados a mesma S.A.
			If nNSA > 0 .And. nISA > 0 .And. ( ( nLine := aScan( aCoBrw6, { |x| x[nNSA] == (cTRBIP)->TL_NUMSA .And.;
				x[nISA] == (cTRBIP)->TL_ITEMSA } ) ) > 0 )

				nQuantid := aCoBrw6[nLine,nPQuantid]

			EndIf

		ElseIf lIntRM .And. (cTRBIP)->TL_TIPOREG $ 'P\T' .And. ( nNSC > 0 .And. !Empty( (cTRBIP)->TL_NUMSC ) ) .And.;
			( nISC .And. !Empty( (cTRBIP)->TL_ITEMSC ) )

			// Considera a quantidade somente de insumos aplicados vinculados a mesma S.C.
			If nNSC > 0 .And. nISC > 0 .And. ( ( nLine := aScan( aCoBrw6, { |x| x[nNSC] == (cTRBIP)->TL_NUMSC .And.;
				x[nISC] == (cTRBIP)->TL_ITEMSC } ) ) > 0 )

				nQuantid := aCoBrw6[nLine,nPQuantid]

			EndIf

		Else

			For nIndex := 1 To Len( aCoBrw6 )

				cTiporeg := aCoBrw6[ nIndex, nPTiporeg ]
				cCodigo  := aCoBrw6[ nIndex, nPCodigo ]

				//----------------------------------------------------
				//Comparação de insumos previstos x insumos realizados
				//----------------------------------------------------
				If AllTrim( (cTRBIP)->TL_TAREFA ) == AllTrim( aCoBrw6[ nIndex, nPTarefa ] ) ;
					.And. ( ( Alltrim( (cTRBIP)->TL_TIPOREG ) == "E" .And. AllTrim( cTiporeg ) == "M" ;
					.And. NGIFDBSEEK( "ST2", Padr( cCodigo, nSizeField )  + Alltrim( (cTRBIP)->TL_CODIGO ), 1 ) ) ;
					.Or. ( AllTrim( (cTRBIP)->TL_TIPOREG ) == AllTrim( cTiporeg ) ;
					.And. AllTrim( (cTRBIP)->TL_CODIGO ) == AllTrim( cCodigo ) ) )

					//Soma a quantidade de insumos que já foram aplicados
					nQuantid += aCoBrw6[ nIndex, nPQuantid ]
				EndIf
			Next nIndex

		EndIf

		If nQuantid == 0
			cStatus := "0" //'0' - Não aplicado
		ElseIf nQuantid < (cTRBIP)->TL_QUANTID
			cStatus := "1" //'1' - Parcialmente Aplicado
		ElseIf nQuantid >= (cTRBIP)->TL_QUANTID
			cStatus := "2" //'2' - Totalmente aplicado
		EndIf

		//----------------------------------------------
		//Atualiza legenda/status dos insumos previstos
		//----------------------------------------------
		RecLock( (cTRBIP), .F. )
		(cTRBIP)->STATUS := cStatus
		MsUnLock()

		(cTRBIP)->( dbSkip() )

	EndDo

Return

Static Function fLoadSTL( nLinSTL )

	Local cKEY,cGETWHILE
	Local lTemIns    := .F.
	Local nPosFld    := 0
	Local nPosTp     := 1
	
	If ValType( nLinSTL ) == 'N' .And. Len( aCoBrw6 ) >= nLinSTL

		nPosTp := nLinSTL

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_TIPOREG', aHoBrw6 ) ) > 0

		M->TL_TIPOREG := aCoBrw6[nPosTp,nPosFld]

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_DESTINO', aHoBrw6 ) ) > 0

		M->TL_DESTINO := aCoBrw6[nPosTp,nPosFld]

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_CODIGO', aHoBrw6 ) ) > 0

		M->TL_CODIGO  := aCoBrw6[nPosTp,nPosFld]

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_UNIDADE', aHoBrw6 ) ) > 0

		M->TL_UNIDADE := aCoBrw6[nPosTp,nPosFld]

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_LOCAL', aHoBrw6 ) ) > 0

		M->TL_LOCAL   := aCoBrw6[nPosTp,nPosFld]

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_DTINICI', aHoBrw6 ) ) > 0

		M->TL_DTINICI := aCoBrw6[nPosTp,nPosFld]

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_HOINICI', aHoBrw6 ) ) > 0

		M->TL_HOINICI := aCoBrw6[nPosTp,nPosFld]

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_DTFIM', aHoBrw6 ) ) > 0

		M->TL_DTFIM   := aCoBrw6[nPosTp,nPosFld]

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_HOFIM', aHoBrw6 ) ) > 0

		M->TL_HOFIM   := aCoBrw6[nPosTp,nPosFld]

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_QUANTID', aHoBrw6 ) ) > 0

		M->TL_QUANTID := aCoBrw6[nPosTp,nPosFld]

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_NUMLOTE', aHoBrw6 ) ) > 0

		M->TL_NUMLOTE := aCoBrw6[nPosTp,nPosFld]

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_LOTECTL', aHoBrw6 ) ) > 0

		M->TL_LOTECTL := aCoBrw6[nPosTp,nPosFld]

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_LOCALIZ', aHoBrw6 ) ) > 0

		M->TL_LOCALIZ := aCoBrw6[nPosTp,nPosFld]

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_NUMSERI', aHoBrw6 ) ) > 0

		M->TL_NUMSERI := aCoBrw6[nPosTp,nPosFld]

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_GARANTI', aHoBrw6 ) ) > 0

		M->TL_GARANTI := aCoBrw6[nPosTp,nPosFld]

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_TAREFA', aHoBrw6 ) ) > 0

		M->TL_TAREFA  := aCoBrw6[nPosTp,nPosFld]

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_USACALE', aHoBrw6 ) ) > 0

		M->TL_USACALE := aCoBrw6[nPosTp,nPosFld]

	EndIf

	If ( nPosFld := GDFieldPos( 'TL_SEQRELA', aHoBrw6 ) ) > 0

		aCoBrw6[nPosTp,nPosFld] := MNT435SEQ( aCoBrw6, .F., nPosTp )

		M->TL_SEQRELA := aCoBrw6[nPosTp,nPosFld]

	EndIf
	
	aColsAtu := aClone( aCoBrw6 )
	nPosAtu  := 1

	If !Empty(cOrdemTJ)
		dbSelectArea("STJ")
		dbSetOrder(01)
		dbSeek(xFilial("STJ")+cOrdemTJ+cPlanoTJ)

		If ValType(aColsAtu[ nPosTp , Len(aColsAtu[nPosTp])-1 ]) == "A"
			If Len( aColsAtu[ nPosTp , Len(aColsAtu[nPosTp])-1 ] ) > 0
				lTemIns := .T.
			EndIf
		Else
			aAdd( aColsAtu[nPosTp] , aColsAtu[ nPosTp , Len(aColsAtu[nPosTp]) ] )
			aColsAtu[ nPosTp , Len(aColsAtu[nPosTp])-1 ] := {}
		EndIf

		If TT9->( FieldPos( 'TT9_CARACT' ) ) == 0

			aCoBrw3 := {}

			If lTemIns
				aCoBrw3 := aClone( aColsAtu[ nPosTp , Len(aColsAtu[nPosTp])-1 ] )
			Else
				If !Empty(M->TL_SEQRELA)
					cKEY  := cOrdemTJ + cPlanoTJ + M->TL_TAREFA + M->TL_SEQRELA
					cGETWHILE := "TN_ORDEM   == '"+  cOrdemTJ  +"' .And. "
					cGETWHILE += "TN_PLANO   == '"+  cPlanoTJ  +"' .And. "
					cGETWHILE += "TN_TAREFA  == '"+M->TL_TAREFA +"' .And. "
					cGETWHILE += "TN_SEQRELA == '"+M->TL_SEQRELA+"'"
					dbSelectArea("STN")
					dbSetOrder(1)
					Inclui := .F.
					aHoBrw3 := NGHeader("STN", {"TN_FILIAL", "TN_TAREFA","TN_NOMETAR","TN_ORDEM","TN_PLANO","TN_SEQRELA", "TN_SEQUENC"}, .F. )
					aCoBrw3 := MAKEGETD("STN", cKEY,  aHoBrw3, cGETWHILE,,.F.)
					Inclui := .T.
				EndIf
			EndIf

			If Len(aCoBrw3) == 0
				aCoBrw3 := BLANKGETD(aHoBrw3)
			EndIf

			aCols           := aClone( aCoBrw3 )
			aHeader         := aClone( aHoBrw3 )

		EndIf

		aCols	:= aClone( aColsAtu )
		aHeader	:= aClone( aHoBrw6 )
		aCoBrw6 := aClone( aColsAtu )


		If !lTemIns

			aCols[nPosTp,Len(aCols[nPosTp])-1] := aClone( aCoBrw3 )

		EndIf

		PutFileInEof( 'STN' )

	EndIf

	dbSelectArea("STJ")
	dbSetOrder(01)
	dbSeek(xFilial("STJ")+cOrdemTJ+cPlanoTJ)

	If STJ->TJ_SERVICO == "HISTOR"
		If cUIntHis == "N" .And. cUsaInt3 == 'S' .And. M->TL_TIPOREG $ ( 'P/M' )
			lCusto := .T.
		Else
			lCusto := .F.
		EndIf
	ElseIf cUsaInt3 == 'S'
		lCusto := .F.
	EndIf

Return

Static Function MNT435SEQ( aColsSqe, lChange, nLnAt )

	Local nFor
	Local oldaCols, oldaHeader
	Local lPRIMLO := .T.
	Local nPos18  := aScan( aHoBrw2,{|x| Trim( Upper(x[2]) ) == "TL_SEQRELA" })
	Local nPosTp  := 0
	Local cSeqAtu := "0  "

	Default nLnAt := 0

	If nLnAt == 0

		nPosTp := 1

	Else

		nPosTp := nLnAt

	EndIf


	If lChange .Or. (  Len(aColsSqe) >= nPosTp .And. ;
	( AllTrim(aColsSqe[ nPosTp , nPos18 ]) == "0" .Or. Empty(aColsSqe[ nPosTp , nPos18 ]) ))
		//Define maior sequencia atual
		For nFor := 1 To Len(aColsSqe)
			If Empty(aColsSqe[nFor,nPos18])
				Loop
			EndIf
			If Val(aColsSqe[nFor,nPos18]) > 0
				If Val(aColsSqe[nFor,nPos18]) > Val(cSeqAtu)
					cSeqAtu := aColsSqe[nFor,nPos18]
				EndIf
			ElseIf !IsDigit(Substr(aColsSqe[nFor,nPos18],1,1))
				cSeqAtu := If(lPRIMLO,aColsSqe[nFor,nPos18],If(aColsSqe[nFor,nPos18] > cSeqAtu,aColsSqe[nFor,nPos18],cSeqAtu))
				lPRIMLO := .F.
			EndIf
		Next nFor

		//Adiciona 1 à sequencia atual
		If Alltrim(cSeqAtu) == "0" .Or. Empty(cSeqAtu)
			cSeqAtu := PADR("1",3)
		Else
			If !lPRIMLO
				If FindFunction("Soma1Old")
					cSeqAtu := PADR(Soma1Old(cSeqAtu),3)
				Else
					cSeqAtu := PADR(Soma1(cSeqAtu),3)
				EndIf
			Else
				If FindFunction("Soma1Old")
					cSeqAtu := IIf( Val( cSeqAtu ) == 0,PADR( "1", 3),PADR( Soma1Old( cSeqAtu ), 3 ))
				Else
					cSeqAtu := IIf( Val( cSeqAtu ) == 0,PADR( "1", 3),PADR( Soma1( cSeqAtu ), 3 ))
				EndIf
			EndIf
		EndIf
	ElseIf Len(aColsSqe) >= nPosTp
		cSeqAtu := aColsSqe[ nPosTp , nPos18 ]
	EndIf

	oldaCols   := aClone(aColsSqe)
	oldaHeader := aClone(aHeader)

Return cSeqAtu

Static Function GetNomeTip(cTIPREG)
	Local cRet := Space(15)

	If cTIPREG == "M"
		cRet := "Mao de obra"
	ElseIf cTIPREG == "P"
		cRet := "Produto"
	ElseIf cTIPREG == "F"
		cRet := "Ferramenta"
	ElseIf cTIPREG == "T"
		cRet := "Terceiros"
	ElseIf cTIPREG == "E"
		cRet := "Especialidade"
	EndIf

Return cRet

Static Function MNTA435EFI()

	Local aAreaTRB := (cTRBQ400)->( GetArea() )
	Local aAreaTPA := TPA->( GetArea() )
	Local aAreaTPQ := TPQ->( GetArea() )

	dbSelectArea(cTRBQ400)
	dbGotop()
	While !EoF()
		If !Empty((cTRBQ400)->TQ_OK)

			dbSelectArea("TPA")
			dbSetOrder(1)
			If dbSeek(xFilial("TPA")+(cTRBQ400)->TQ_ETAPA)

				If TPA->TPA_OPCOES <> '0'

					dbSelectArea(cTRB3400)
					dbSetOrder(1)
					If dbSeek((cTRBQ400)->TQ_ETAPA)

						lREPOS := .F.

						While !EoF() .And. (cTRB3400)->TPC_ETAPA = (cTRBQ400)->TQ_ETAPA
							If !Empty((cTRB3400)->TPC_OK)
								lREPOS := .T.
								Exit
							EndIf
							dbSkip()
						End

						If !lREPOS
							MsgInfo(cErro := "Não foi selecionado as respostas das opcões da etapa" + " " + (cTRBQ400)->TQ_ETAPA + "  " + "Tarefa" + " " + (cTRBQ400)->TQ_TAREFA, "NÃO CONFORMIDADE" )
							Return .F.
						EndIf
					Else
						dbSelectArea("TPQ")
						dbSetOrder(1)
						If !dbSeek( xFilial("TPQ") + STJ->TJ_ORDEM + STJ->TJ_PLANO + (cTRBQ400)->TQ_TAREFA + (cTRBQ400)->TQ_ETAPA )
							MsgInfo(cErro := "Não foi selecionado as respostas das opcões da etapa" + " " + (cTRBQ400)->TQ_ETAPA + "  " + "Tarefa" + " " + (cTRBQ400)->TQ_TAREFA, "NÃO CONFORMIDADE" )
							Return .F.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		dbSelectArea(cTRBQ400)
		dbSkip()
	EndDo

	RestArea(aAreaTPQ)
	RestArea(aAreaTPA)
	RestArea(aAreaTRB)

Return .T.

Static Function fGrava435( nIniOS, lRefBrow, lLoadIns, lCanOrFin )

	Local nIndOS 		:= 0
	Local nIndTL 		:= 0
	Local nX			:= 0
	Local nErro         := 0
	Local nIndTPL		:= 0
	Local nYtmp			:= 0
    Local nIndSTN		:= 0
	Local nIndOS2		:= 0
	Local nxSA			:= 0
	Local nXX			:= 0
	Local i				:= 0
	Local nXtmp			:= 0
	Local nPosArray 	:= 0
	Local nCopy         := 0
	Local nItemSA   	:= 0
	Local nPosAux   	:= 0
	Local nPosArr       := 0
	Local nOkSTQ        := Len( aTrbQ ) + 1
	Local nSeqSTQ       := Len( aTrbQ ) + 2
	Local nRecSTQ       := Len( aTrbQ ) + 3
	Local nPos01    	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_TIPOREG"})
	Local nPos02 		:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_DESTINO"})
	Local nPos03   	 	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_CODIGO" })
	Local nPos05    	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_LOCAL"  })
	Local nPos06    	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_DTINICI"})
	Local nPos08    	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_DTFIM"  })
	Local nPos10    	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_QUANTID"})
	Local nPos11    	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_NUMLOTE"})
	Local nPos12    	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_LOTECTL"})
	Local nPos13    	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_LOCALIZ"})
	Local nPos14    	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_NUMSERI"})
	Local nPos15    	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_GARANTI"})
	Local nPos16    	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_TAREFA" })
	Local nPos18    	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_SEQRELA"})
	Local nPos19    	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_OBSERVA"})
	Local nPos20    	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_ETAPA"})
	Local nPos21    	:= aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_CUSTO"})
	Local nPosGrt   	:= aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_GARANTI"}) //Verifica se esta focado no browse de insumos realizados
	Local nMotCo    	:= aScan(aHoBrw4,{|x| Trim(Upper(x[2])) == "TPL_CODMOT"})
	Local nMotDI    	:= aScan(aHoBrw4,{|x| Trim(Upper(x[2])) == "TPL_DTINIC"})
	Local nMotHI    	:= aScan(aHoBrw4,{|x| Trim(Upper(x[2])) == "TPL_HOINIC"})
	Local nMotDF    	:= aScan(aHoBrw4,{|x| Trim(Upper(x[2])) == "TPL_DTFIM" })
	Local nMotHF    	:= aScan(aHoBrw4,{|x| Trim(Upper(x[2])) == "TPL_HOFIM" })
	Local nOcoCo    	:= aScan(aHoBrw3,{|x| Trim(Upper(x[2])) == "TN_CODOCOR"})
	Local nOcoCa    	:= aScan(aHoBrw3,{|x| Trim(Upper(x[2])) == "TN_CAUSA"  })
	Local nOcoSo    	:= aScan(aHoBrw3,{|x| Trim(Upper(x[2])) == "TN_SOLUCAO"})
	Local nEtaTa    	:= aScan( aTRBQ ,{ |x| Trim( Upper( x[2] ) ) == 'TQ_TAREFA'  } )
	Local nEtapa    	:= aScan( aTRBQ ,{ |x| Trim( Upper( x[2] ) ) == 'TQ_ETAPA'   } )
	Local nEtSeq        := aScan( aTRBQ ,{ |x| Trim( Upper( x[2] ) ) == 'TQ_SEQETA'  } )
	Local nLinOS        := 0
    Local lDelGarant	:= .F.
	Local lAltGarant	:= .F.
	Local lTpGeraOS		:= .F.
	Local lTPGeraSS		:= .F.
	Local lCondicao		:= .F.
	Local lMNTB4354		:= ExistBlock( 'MNTB4354' )
	Local lMNTA4353		:= ExistBlock( 'MNTA4353' )
	Local lMNTA435I		:= ExistBlock( 'MNTA435I' )
	Local lMNTA435M     := ExistBlock( 'MNTA435M' )
	Local lNGCALCUSTI   := ExistBlock( 'NGCALCUSTI' )
	Local lProcSTL  	:= .T.
	Local lRet          := .T.
    Local lOSHESTO  	:= .F. //Variavel que indica se terá integração com o estoque quando TJ_SERVICO = 'HISTOR'
	Local lSerRef		:= .F.
    Local cOrdem		:= ""
	Local cPlano		:= ""
	Local cForm			:= ""
	Local cResp			:= ""
	Local cServCar		:= ""
	Local cTipoMan		:= ""
	Local cTpcMark  	:= ''
	Local cMsgSS		:= ''
	Local cAliIns		:= ''
	Local cQueryIns		:= ''
	Local cRMTaref      := ''
	Local cRMTipoR      := ''
	Local cRMCodIn      := ''
	Local cRMSeqre      := ''
	Local cRMNumse      := ''
	Local cNGUNIDT		:= AllTrim( SuperGetMv( 'MV_NGUNIDT', .F., 'S' ) )
	Local cNGMNTAS		:= SuperGetMV("MV_NGMNTAS",.F.,"2")
	Local cNumSA    	:= Space( TAMSX3('CP_NUM')[ 1 ] )
	Local cNumCP    	:= cNumSA
	Local cAlsSTN       := GetNextAlias()
	Local cMemoQry      := TCConfig( 'GETMEMOINQUERY' )
	Local cCast         := ''
	Local cDbase        := TCGetDB()
	Local aBind			:= {}
    Local aReqSD3   	:= {}
	Local aTRBZ435  	:= {}
	Local aTempAux  	:= {}
	Local aSolic    	:= {}
	Local aLogRM        := {}
	Local aLogNoCanc    := {}
	Local aNoCopy       := {}
	Local aRollBack     := {}
	Local aRetSD3       := {}
	Local aAreaAlOs     := (cAliOS435)->( GetArea() )
	Local aAreaSTJ      := STJ->( GetArea() )
	Local lPrimVez  	:= .T.
	Local lOSRepet  	:= .F.
	Local cChavAnt  	:= ""

	Private aTRBZ   	:= {}

	Default lLoadIns 	:= .T.
	Default lCanOrFin   := .F.

	Store .F. To lTpGeraOS, lTPGeraSS, lCondicao

	//Ordena S.A. pelo campo Ordem + Plano
	aSort( aDadosSA,,,{|x,y| x[1]+x[2] < y[1]+y[2] })

	//Ordena Garantia pelo campo Ordem + Plano
	aSort( aDadosTPZ,,,{|x,y| x[5]+x[6] < y[5]+y[6] })

	aArray  := {}
	aArray2 := {}
	fCriaOsGer(@aTRBZ435)

	CursorWait()

	aInsNaoGra := {}
	aReqSD3    := {} //Salva requisicoes para executar no final da gravacao
	ProcRegua( (cAliOS435)->( RecCount() ) )

	//Begin Transaction

		If !lCanOrFin
			DbSelectArea( cAliOS435 )
			dbSetOrder( 1 )
			dbGoTop()
		EndIf
		
		Do While (cAliOS435)->( !EoF() )

			IncProc()
			cOrdem := (cAliOS435)->TJ_ORDEM
			cPlano := (cAliOS435)->TJ_PLANO

			//Se o numero da OS nao existir
			dbSelectArea("STJ")
			dbSetOrder(1)
			If !dbSeek( xFilial("STJ") + cOrdem + cPlano )
				Loop
			EndIf

			If STJ->TJ_SITUACA == 'C'
				aAdd( aLogNoCanc, { STJ->TJ_ORDEM, STJ->TJ_PLANO } )
				Loop
			EndIf

			lOSHESTO := .F.

			If cUsaInt3 == 'S' .And. cUIntHis == "N" .And. STJ->TJ_SERVICO == "HISTOR"
				lOSHESTO := .T.
			EndIf

			cCodBem := STJ->TJ_CODBEM
			
			//Se o numero da OS nao existir no array
			nLineOS := aScan(aDadosOS, {|x|x[1]+x[2] == cOrdem+cPlano })

			If nLineOS == 0
				Loop
			EndIf

			//Gravacao Motivos de Atraso
			If ValType( aDadosOS[nLineOS,7] ) == "A"

				//Excluindo os motivos que foram retirados da tela
				dbSelectArea("TPL")
				dbSetOrder(1)
				dbSeek( xFilial("TPL") + cOrdem )
				While !EoF() .And. xFilial("TPL")+cOrdem == TPL->TPL_FILIAL+TPL->TPL_ORDEM
					If aScan(aDadosOS[nLineOS,7], {|x| x[nMotCo]          == TPL->TPL_CODMOT .And.;
					x[nMotDI] == TPL->TPL_DTINIC .And. x[nMotHI] == TPL->TPL_HOINIC .And.;
					x[nMotDF] == TPL->TPL_DTFIM  .And. x[nMotHF] == TPL->TPL_HOFIM  .And. !ATail(x) }) == 0

						RecLock("TPL", .F.)
						dbDelete()
						TPL->(MsUnLock())
					EndIf

					dbSelectArea("TPL")
					dbSkip()
				EndDo

				//Os registros deletados serão os primeiros da lista
				aSort(aDadosOS[nLineOS,7],,,{|x,y| ATail(x) .And. !ATail(y) })

				For nIndOS := 1 To Len(aDadosOS[nLineOS,7])

					If Empty( aDadosOS[nLineOS,7,nIndOS,nMotCo] ) //Nao validar se codigo vazio
						Loop
					EndIf

					cKeyTPL := xFilial("TPL") + cOrdem
					cKeyTPL += aDadosOS[nLineOS,7,nIndOS,nMotCo] + DtoS(aDadosOS[nLineOS,7,nIndOS,nMotDI])
					cKeyTPL += aDadosOS[nLineOS,7,nIndOS,nMotHI] + DtoS(aDadosOS[nLineOS,7,nIndOS,nMotDF])
					cKeyTPL += aDadosOS[nLineOS,7,nIndOS,nMotHF]

					//Se nao for deletado
					If !aDadosOS[nLineOS,7][nIndOS][Len(aDadosOS[nLineOS,7][nIndOS])]

						lTPL_Lock := .T.
						dbSelectArea("TPL")
						dbSetOrder(1) // TPL_FILIAL+TPL_ORDEM+TPL_CODMOT+DTOS(TPL_DTINIC)+TPL_HOINIC+DTOS(TPL_DTFIM)+TPL_HOFIM
						lTPL_Lock := !dbSeek(cKeyTPL)
						RecLock("TPL",lTPL_Lock)

						For nIndTPL := 1 To FCount()
							If Alltrim(FieldName(nIndTPL)) $ "TPL_FILIAL/TPL_ORDEM"
								Loop
							EndIf

							nPosTmp := aScan(aHoBrw4, {|x| AllTrim(Upper(X[2])) == FieldName(nIndTPL) })
							y  := "TPL->" + FieldName(nIndTPL)

							If nPosTmp > 0
								x  := "M->" + FieldName(nIndTPL)
								&x.:= aDadosOS[nLineOS,7,nIndOS,nPosTmp]
								&y := &x
							ElseIf lTPL_Lock
								&y := CriaVar(FieldName(nIndTPL))
							EndIf
						Next nIndTPL

						TPL->TPL_FILIAL := xFilial("TPL")
						TPL->TPL_ORDEM  := cOrdem
						TPL->(MsUnLock())
					Else

						dbSelectArea("TPL")
						dbSetOrder(1)
						//TPL_FILIAL + TPL_ORDEM + TPL_CODMOT + DTOS(TPL_DTINIC) + TPL_HOINIC + DTOS(TPL_DTFIM) + TPL_HOFIM
						If dbSeek( cKeyTPL )
							RecLock( "TPL", .F. )
							dbDelete()
							TPL->(MsUnLock())
						EndIf
					EndIf
				Next nIndOS
			EndIf //Fim Gravacao Motivos

			//Gravacao dos Insumo
			lAlteraSTL := .F.

			If ValType( aDadosOS[nLineOS,5] ) == "A"
				//Verifica se algo foi alterado
				nTemGar := aScan(aDadosTPZ, {|x| x[5]+x[6] == cOrdem+cPlano })

				If Len(aDadosOS[nLineOS,4]) <> Len( aDadosOS[nLineOS,5] ) .Or. nTemGar > 0
					lAlteraSTL := .T.
				Else
					For nXtmp := 1 to Len(aDadosOS[nLineOS,5])
						If Len(aDadosOS[nLineOS,4,nXtmp]) <> Len(aDadosOS[nLineOS,5,nXtmp])
							lAlteraSTL := .T.
							Exit
						EndIf
						If  Empty(aDadosOS[nLineOS,4,nXtmp,1]) .And. Empty(aDadosOS[nLineOS,4,nXtmp,3]) .And. Empty(aDadosOS[nLineOS,4,nXtmp,5]) .And. ;
						Empty(aDadosOS[nLineOS,5,nXtmp,1]) .And. Empty(aDadosOS[nLineOS,5,nXtmp,3]) .And. Empty(aDadosOS[nLineOS,5,nXtmp,5])
							Loop
						EndIf

						For nYtmp := 1 to Len(aDadosOS[nLineOS,5,nXtmp])
							If nYtmp == Len(aDadosOS[nLineOS,5,nXtmp]) - 1
								Loop
							EndIf

							If ValType(aDadosOS[nLineOS,5,nXtmp,nYtmp]) <> ValType(aDadosOS[nLineOS,4,nXtmp,nYtmp])
								lAlteraSTL := .T.
								Exit
							EndIf

							If aDadosOS[nLineOS,5,nXtmp,nYtmp] <> aDadosOS[nLineOS,4,nXtmp,nYtmp]
								lAlteraSTL := .T.
								Exit
							EndIf
						Next nYtmp

						If lAlteraSTL
							Exit
						EndIf
					Next nXtmp
				EndIf
			EndIf

			If lAlteraSTL

				lSerRef := AllTrim( STJ->TJ_SERVICO ) == SuperGetMV("MV_NGSERPN", .F., "")

				RecLock("STJ", .F.)

					STJ->TJ_TIPORET := 'S' //Para legenda entender que contem insumo aplicado

				STJ->( MsUnlock() )


				//Excluindo os insumos que foram retirados da tela
				dbSelectArea("STL")
				dbSetOrder(1)
				dbSeek(xFilial("STL")+cOrdem+cPlano)
				While !EoF() .And. xFilial("STL")+cOrdem+cPlano == STL->(TL_FILIAL+TL_ORDEM+TL_PLANO)
					If !Empty(STL->TL_SEQRELA) .And. AllTrim( STL->TL_SEQRELA ) != '0'  .And. ;
					aScan(aDadosOS[nLineOS,5] ,{|x| x[nPos16]   == STL->TL_TAREFA  .And. x[nPos01]    == STL->TL_TIPOREG .And. ;
					x[nPos03] == STL->TL_CODIGO .And. x[nPos18] == STL->TL_SEQRELA .And. !ATail(x) }) == 0

						//Verificar se o insumo foi gerado atraves de uma requisicao do estoque e nao deleta
						If !lIntRM .And. STL->TL_ORIGNFE == "SD3" .Or. STL->TL_ORIGNFE == "SD1"
							dbSelectArea("STL")
							dbSkip()
							Loop
						ElseIf cUsaInt3 == 'S' .And. ; // integração com estoque
								lSerRef .And.; // serviço mov. pneu
								( nPosDOS := aScan(aDadosOS,{|x| Trim(Upper(x[1])) == cOrdemTJ}) ) > 0 .And.; // posição da ordem
								( nPosSav := aScan(aDadosOS[nPosDOS,4] ,{|x| ; // posição do insumo
											x[nPos01] == aCols[n][nPos01] .And.;
											x[nPos03] == aCols[n][nPos03] .And.;
											x[nPos18] == aCols[n][nPos18] }) ) > 0 .And.;
								aDadosOs[nPosDOS,4,nPosSav,nPos01] == 'P' .And. ; // insumo produto
								Val( aDadosOs[nPosDOS,4,nPosSav,nPos18] ) .And.; // insumo realizado
								ProdutoPn( aDadosOs[nPosDOS,4,nPosSav,nPos03],; // é um pneu
											aDadosOs[nPosDOS,4,nPosSav,nPos05], STJ->TJ_ORDEM )

							dbSelectArea("STL")
							dbSkip()
							Loop

						EndIf

						If !Empty(STL->TL_NUMSEQ)
							//Faz devoulucao para o estoque
							dbSelectArea("SD3")
							dbSetOrder(4)
							If dbSeek( xFilial( 'SD3' ) + STL->TL_NUMSEQ )

								aRetSD3 := MntGeraD3( 'DE1', , , .T., .F., .T. )

								If aRetSD3[2]

									If NGPRODESP( SD3->D3_COD, .F., 'M' )
										NGAtuErp( 'SD3', 'INSERT' )
									EndIf

								Else

									aAdd( aLogRM, { aRetSD3[3], STL->TL_ORDEM, STL->TL_PLANO, STL->TL_TAREFA,;
										STL->TL_TIPOREG, STL->TL_CODIGO, STL->TL_SEQRELA, STL->TL_NUMSEQ } )

									STL->( dbSkip() )
									Loop

								EndIf

							EndIf
						EndIf

						If STL->TL_TIPOREG == "P"
							//MOSTRA OS REGISTROS DO HISTORICO PARA EXECLUIR
							NGDELINSLAN( STJ->TJ_CODBEM, STL->TL_DTINICI, STL->TL_HOINICI )
						EndIf

						fNgGarDelete(cOrdem,cPlano,STL->TL_SEQRELA)

							dbSelectArea("STN")
							dbSetOrder(1)
							dbSeek( xFilial("STN") + STL->(TL_ORDEM+TL_PLANO+TL_TAREFA+TL_SEQRELA) )
							While !EoF() .And. STL->(TL_ORDEM + TL_PLANO + TL_TAREFA + TL_SEQRELA ) == STN->( TN_ORDEM + TN_PLANO + TN_TAREFA + TN_SEQRELA ) .And. ;
							xFilial("STN") == STN->TN_FILIAL

								RecLock("STN",.F.)
								dbDelete()
								STL->(MsUnLock())

								dbSelectArea("STN")
								dbSkip()
							EndDo

						dbSelectArea("STL")
						RecLock("STL",.F.)
						dbDelete()
						STL->(MsUnLock())
						If lMNTB4354
							ExecBlock("MNTB4354")
						EndIf
					EndIf

					dbSelectArea("STL")
					dbSetOrder(1)
					STL->(dbSkip())
				EndDo

				//Ordena pelo campo TL_SEQRELA
				aSort(aDadosOS[nLineOS,5],,,{|x,y| x[nPos18] < y[nPos18] })

				//Os registros deletados serão os primeiros da lista
				aSort(aDadosOS[nLineOS,5],,,{|x,y| x[Len(x)] .And. !y[Len(y)] })

				//Ultima Sequencia
				M->TL_ORDEM := cOrdem
				M->TL_PLANO := cPlano

				For nIndOS := 1 to Len(aDadosOS[nLineOS,5])
					If aDadosOS[nLineOS,5,nIndOS,nPos01] == "M"
						aDadosOS[nLineOS,5,nIndOS,nPos18] := "2" //--TL_SEQRELA
					Else
						Exit
					EndIf
					//Verifica se o insumo foi gerado atraves do estoque e altera a tarefa
					dbSelectArea( "STL" )
					dbSetOrder( 02 ) //TL_FILIAL+TL_TIPOREG+TL_SEQRELA+TL_CODIGO+TL_ORDEM+TL_PLANO
					If dbSeek( xFilial( "STL" )+aDadosOS[nLineOS,5,nIndOS,nPos01]+aDadosOS[nLineOS,5,nIndOS,nPos18]+aDadosOS[nLineOS,5,nIndOS,nPos03]+cOrdem+cPlano)
						If ( STL->TL_ORIGNFE == "SD3" .Or. STL->TL_ORIGNFE == "SD1" ) .And. aDadosOS[nLineOS,5,nIndOS,nPos16] <> STL->TL_TAREFA
							RecLock( "STL",.F. )
							STL->TL_TAREFA := aDadosOS[nLineOS,5,nIndOS,nPos16]
							MsUnLock( "STL" )
							Loop
						ElseIf cUsaInt3 == 'S' .And. ; // integração com estoque
								lSerRef .And.; // serviço mov. pneu
								( nPosDOS := aScan(aDadosOS,{|x| Trim(Upper(x[1])) == cOrdemTJ}) ) > 0 .And.; // posição da ordem
								( nPosSav := aScan(aDadosOS[nPosDOS,4] ,{|x| ; // posição do insumo
											x[nPos01] == aCols[n][nPos01] .And.;
											x[nPos03] == aCols[n][nPos03] .And.;
											x[nPos18] == aCols[n][nPos18] }) ) > 0 .And.;
								aDadosOs[nPosDOS,4,nPosSav,nPos01] == 'P' .And. ; // insumo produto
								Val( aDadosOs[nPosDOS,4,nPosSav,nPos18] ) .And.; // insumo realizado
								ProdutoPn( aDadosOs[nPosDOS,4,nPosSav,nPos03],; // é um pneu
											aDadosOs[nPosDOS,4,nPosSav,nPos05], STJ->TJ_ORDEM )

							RecLock( "STL",.F. )
							STL->TL_TAREFA := aDadosOS[nLineOS,5,nIndOS,nPos16]
							STL->TL_DESTINO := aDadosOS[nLineOS,5,nIndOS,nPos02]
							MsUnLock( "STL" )
							Loop

						EndIf

						RecLock( "STL",.F. )
						STL->TL_ETAPA := aDadosOS[nLineOS,5,nIndOS,nPos20]
						MsUnLock( "STL" )
					EndIf

					If Empty(aDadosOS[nLineOS,5,nIndOS,nPos03]) //Nao validar se codigo vazio
						Loop
					EndIf

					cTIPOMAN := IIf( Val(STJ->TJ_PLANO) == 0, "C", "P")

					cKeySTL  := xFilial("STL")+cOrdem+cPlano
					cKeySTL  += aDadosOS[nLineOS,5,nIndOS,nPos16] + aDadosOS[nLineOS,5,nIndOS,nPos01]
					cKeySTL  += aDadosOS[nLineOS,5,nIndOS,nPos03] + aDadosOS[nLineOS,5,nIndOS,nPos18]

					//Se nao for deletado
					If !aDadosOS[nLineOS,5][nIndOS][Len(aDadosOS[nLineOS,5][nIndOS])]

						lProcSTL := .T.

						If lMNTA4353
							aTempAux := aClone(ExecBlock("MNTA4353",.F.,.F.,{.F.,aHoBrw6,aDadosOS[nLineOS,5][nIndOS]}))
							If aTempAux[1]
								nPosAux := aScan(aInsNaoGra, {|x| AllTrim(x[1])+AllTrim(x[2]) == AllTrim(aDadosOS[nLineOS][1])+AllTrim(aDadosOS[nLineOS][2])})
								If nPosAux == 0
									aAdd(aInsNaoGra,{aDadosOS[nLineOS][1], aDadosOS[nLineOS][2], {aTempAux[2]}})
								Else
									aAdd(aInsNaoGra[nPosAux][3], aTempAux[2])
								EndIf
								lProcSTL := .F.
							EndIf
						EndIf

						If lProcSTL
							lDelGarant := .F. //Indica se foi retirada a garantia
							lAltGarant := .F. //Indica se foi alterada a data da garantia
							lSTL_Lock  := .T.
							dbSelectArea("STL")
							dbSetOrder(1) //TL_FILIAL+TL_ORDEM+TL_PLANO+TL_TAREFA+TL_TIPOREG+TL_CODIGO+TL_SEQRELA
							If !Empty(aDadosOS[nLineOS,5,nIndOS,nPos18]) .And. AllTrim( aDadosOS[ nLineOS, 5, nIndOS, nPos18 ] ) != '0' //Se nao vazio TL_SEQRELA
								lSTL_Lock := !dbSeek(cKeySTL)
							EndIf

							RecLock("STL",lSTL_Lock)

							If !lSTL_Lock //Verifica se foi retirada a garantia na alteração do STL
								If STL->TL_GARANTI == "S" .And. aDadosOS[nLineOS,5,nIndOS,nPos15] == "N"
									lDelGarant := .T.
								EndIf
								dDtTmp01 := If(Empty(STL->TL_DTFIM),STL->TL_DTINICI,STL->TL_DTFIM)
								dDtTmp02 := If(Empty(aDadosOS[nLineOS,5,nIndOS,nPos08]),aDadosOS[nLineOS,5,nIndOS,nPos06],aDadosOS[nLineOS,5,nIndOS,nPos08])
								If dDtTmp01 <> dDtTmp02
									lAltGarant := .T.
								EndIf
							EndIf

							For nIndTL := 1 TO FCount()
								If Alltrim(FieldName(nIndTL)) $ "TL_FILIAL/TL_ORDEM/TL_PLANO/TL_REPFIM/TL_NUMSEQ/TL_SEQRELA/TL_OBSERVA/TL_USERLGI/TL_USERLGA"
									Loop
								EndIf

								nPosTmp := aScan(aHoBrw6, {|x| AllTrim(Upper(X[2])) == FieldName(nIndTL) })
								y  := "STL->" + FieldName(nIndTL)
								If nPosTmp > 0
									x  := "M->" + FieldName(nIndTL)
									&x.:= aDadosOS[nLineOS,5,nIndOS,nPosTmp]
									&y := &x
								ElseIf lSTL_Lock
									&y := CriaVar(FieldName(nIndTL))
								EndIf
							Next nIndTL

							STL->TL_FILIAL  := xFilial("STL")
							STL->TL_ORDEM   := cOrdem
							STL->TL_PLANO   := cPlano
							STL->TL_SEQRELA := aDadosOS[nLineOS,5,nIndOS,nPos18]
							STL->TL_REPFIM  := "S"
							STL->TL_USACALE := If(STL->TL_USACALE <> "S","N",STL->TL_USACALE)
							If STL->TL_TIPOREG <> "P"
								STL->TL_TIPOHOR := If(STL->TL_USACALE == "S","S", cNGUNIDT)
							Else
								STL->TL_TIPOHOR := cNGUNIDT
								STL->TL_DTFIM   := STL->TL_DTINICI
								STL->TL_HOFIM   := STL->TL_HOINICI
							EndIf

							If nPos19 > 0
								STL->TL_OBSERVA := aDadosOS[nLineOS,5,nIndOS,nPos19]
							EndIf

							// Caso o campo não esteja em tela, persiste o calculo e gravação.
							If nPos21 == 0
								STL->TL_CUSTO := Round( NGCALCUSTI( STL->TL_CODIGO, STL->TL_TIPOREG, STL->TL_QUANTID, STL->TL_LOCAL, , , , STL->TL_QUANREC, '1' ), 2 )
							EndIf

							STL->(MsUnLock())

							//PE para que seja possível alterar um insumo após a gravação da STL
							If lMNTA435I
								ExecBlock("MNTA435I",.F.,.F.)
							EndIf

							If STL->TL_GARANTI == "S" //Grava garantia
								nLineSA := aScan(aDadosTPZ, {|x| x[2] + x[3] == STL->TL_TIPOREG + STL->TL_CODIGO .And. ;
								x[5] + x[6] == STL->TL_ORDEM   + STL->TL_PLANO  .And. ;
								x[7]== STL->TL_SEQRELA })

								If nLineSA > 0
									fNgGarInsert(nLineSA,cOrdem,cPlano,STL->TL_SEQRELA, If(Empty(STL->TL_DTFIM),STL->TL_DTINICI,STL->TL_DTFIM) )
								EndIf
							EndIf

							If lSTL_Lock //Incluir
								If cUsaInt3 == "S" .And. !lOSHESTO
									If STL->TL_TIPOREG $ "PM"
										If MNT435CANB() // Caso não haja bloqueio para a movimentação no estoque
											aAdd( aReqSD3 , { STL->(Recno()) , .F. } )
										EndIf
									EndIf
								EndIf
							Else
								If lDelGarant //Retira Garantia
									fNgGarDelete(cOrdem,cPlano,STL->TL_SEQRELA)
								EndIf
								If lAltGarant //Altera data da garantia
									fNgGarUpdate(cOrdem,cPlano,STL->TL_SEQRELA, If(Empty(STL->TL_DTFIM),STL->TL_DTINICI,STL->TL_DTFIM) )
								EndIf

								If cUsaInt3 == "S" .And. STL->TL_TIPOREG $ 'PT' .And. !lOSHESTO

									nPosSav := aScan( aDadosOS[nLineOS,4], { |x| x[nPos16] == aDadosOS[nLineOS,5,nIndOS,nPos16] .And. x[nPos01] == aDadosOS[nLineOS,5,nIndOS,nPos01] .And.;
										x[nPos03] == aDadosOS[nLineOS,5,nIndOS,nPos03] .And. x[nPos18] == aDadosOS[nLineOS,5,nIndOS,nPos18] } )
									
									lProSD3 := .T.

									If nPosSav > 0

										lProSD3 := .F.

										If lIntRM .And. !Empty( STL->TL_NUMSA )

											If aDadosOS[nLineOS,4,nPosSav,nPos10] != STL->TL_QUANTID

												dbSelectArea("SD3")
												dbSetOrder(4)
												If dbSeek( xFilial( 'SD3' ) + STL->TL_NUMSEQ )

													RecLock( 'SD3', .F. )
														SD3->D3_QUANT  := STL->TL_QUANTID
														SD3->D3_CUSTO1 := STL->TL_CUSTO
													MsUnLock()

													If !NGMUStoTuO( SD3->( RecNo() ), 'SD3', .F., 4 )

														/* Não foi identificado forma de obter retorno negativo do RM para está MU.
															aRetSD3 := { '', .F., '' }
														*/
					
													EndIf

												EndIf
												
											EndIf

										Else

											If aDadosOS[nLineOS,4,nPosSav,nPos10] <> STL->TL_QUANTID .Or. aDadosOS[nLineOS,4,nPosSav,nPos06] <> STL->TL_DTINICI .Or. ;
												aDadosOS[nLineOS,4,nPosSav,nPos05] <> STL->TL_LOCAL   .Or. aDadosOS[nLineOS,4,nPosSav,nPos12] <> STL->TL_LOTECTL .Or. ;
												aDadosOS[nLineOS,4,nPosSav,nPos11] <> STL->TL_NUMLOTE .Or. aDadosOS[nLineOS,4,nPosSav,nPos14] <> STL->TL_NUMSERI .Or. ;
												aDadosOS[nLineOS,4,nPosSav,nPos13] <> STL->TL_LOCALIZ

												lProSD3 := .T.

											EndIf

										EndIf

									EndIf

									If lProSD3

										If !Empty( STL->TL_NUMSEQ )
											//Faz devoulucao para o estoque
											dbSelectArea("SD3")
											dbSetOrder(4)
											If dbSeek( xFilial( 'SD3' ) + STL->TL_NUMSEQ )
  
												aRetSD3 := MntGeraD3( 'DE1', , , .T., .F., .T. )

												If aRetSD3[2]

													If NGPRODESP( SD3->D3_COD, .F., 'M' )
														NGAtuErp( 'SD3', 'INSERT' )
													EndIf

												Else

													aAdd( aLogRM, { aRetSD3[3], STL->TL_ORDEM, STL->TL_PLANO, STL->TL_TAREFA,;
														STL->TL_TIPOREG, STL->TL_CODIGO, STL->TL_SEQRELA, STL->TL_NUMSEQ } )
													Loop

												EndIf

											EndIf
										EndIf

										If MNT435CANB() // Caso não haja bloqueio para a movimentação no estoque

											aAdd( aReqSD3 , { STL->(Recno()) , nil } ) //Faz uma nova requisicao no estoque - MNTGERAD3("RE0")
											
										Else
											If !Empty(STL->TL_NUMSEQ)
												Reclock("STL", .F.)
													STL->TL_NUMSEQ := Space(Len(STL->TL_NUMSEQ))
												MsUnlock()
											EndIf
										EndIf

									EndIf

								EndIf

							EndIf
						EndIf
					Else
						If !Empty(aDadosOS[nLineOS,5,nIndOS,nPos18]) .And. AllTrim( aDadosOS[ nLineOS, 5, nIndOS, nPos18] ) != '0' //Se nao vazio TL_SEQRELA

							lProcSTL := .T.

							If lMNTA4353
								aTempAux := aClone(ExecBlock("MNTA4353",.F.,.F.,{.T.,aHoBrw6,aDadosOS[nLineOS,5][nIndOS]}))
								If aTempAux[1]
									nPosAux := aScan(aInsNaoGra, {|x| AllTrim(x[1])+AllTrim(x[2]) == AllTrim(aDadosOS[nLineOS][1])+AllTrim(aDadosOS[nLineOS][2]) })
									If nPosAux == 0
										aAdd(aInsNaoGra, { aDadosOS[nLineOS][1], aDadosOS[nLineOS][2], {aTempAux[2]} })
									Else
										aAdd(aInsNaoGra[nPosAux][3], aTempAux[2])
									EndIf
									lProcSTL := .F.
								EndIf
							EndIf

							//Excluir Registro
							If lProcSTL
								dbSelectArea("STL")
								dbSetOrder(1) //TL_FILIAL+TL_ORDEM+TL_PLANO+TL_TAREFA+TL_TIPOREG+TL_CODIGO+TL_SEQRELA
								If dbSeek(cKeySTL)
									If !Empty(STL->TL_NUMSEQ)
										//Faz devoulucao para o estoque
										dbSelectArea("SD3")
										dbSetOrder(4)
										If dbSeek(xFilial("SD3")+STL->TL_NUMSEQ)

											aRetSD3 := MntGeraD3( 'DE1', , , .T., .F., .T. )

											If aRetSD3[2]

												If NGPRODESP( SD3->D3_COD, .F., 'M' )
													NGAtuErp( 'SD3', 'INSERT' )
												EndIf

											Else

												aAdd( aLogRM, { aRetSD3[3], STL->TL_ORDEM, STL->TL_PLANO, STL->TL_TAREFA,;
													STL->TL_TIPOREG, STL->TL_CODIGO, STL->TL_SEQRELA, STL->TL_NUMSEQ } )
												Loop

											EndIf

										EndIf
									EndIf
									If STL->TL_TIPOREG == "P"
										//MOSTRA OS REGISTROS DO HISTORICO PARA EXECLUIR
										NGDELINSLAN(STJ->TJ_CODBEM,STL->TL_DTINICI,STL->TL_HOINICI)
									EndIf
									fNgGarDelete(cOrdem,cPlano,STL->TL_SEQRELA)

									dbSelectArea("STN")
									dbSetOrder(1)
									dbSeek( xFilial("STN") + STL->(TL_ORDEM+TL_PLANO+TL_TAREFA+TL_SEQRELA) )
									While !EoF() .And. STL->(TL_ORDEM+TL_PLANO+TL_TAREFA+TL_SEQRELA) == STN->(TN_ORDEM+TN_PLANO+TN_TAREFA+TN_SEQRELA) .And. ;
										xFilial("STN") == STN->TN_FILIAL

										RecLock("STN",.F.)
											dbDelete()
										STL->(MsUnLock())
										dbSkip()
									EndDo

									dbSelectArea("STL")
									RecLock("STL",.F.)
									dbDelete()
									STL->(MsUnLock())
									If lMNTB4354
										ExecBlock("MNTB4354")
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf

				Next nIndOS

				//Retoma a ordenção pelo campo TL_SEQRELA
				aSort( aDadosOS[nLineOS,5],,,{ |x,y| x[nPos18] < y[nPos18] } )

				If Empty(cQueryIns)

					cQueryIns := "SELECT COUNT( STL.TL_ORDEM ) AS QTD_INS "
					cQueryIns += "FROM "+ RetSqlName( 'STL' ) +" STL "
					cQueryIns += "WHERE STL.TL_FILIAL = ? AND "
					cQueryIns += "STL.TL_ORDEM = ? 		  AND "
					cQueryIns += "STL.TL_SEQRELA > ?      AND "
					cQueryIns += "STL.D_E_L_E_T_ = ' '        "

					cQueryIns := ChangeQuery( cQueryIns )

				EndIf

				aBind := {}
				aAdd( aBind, FwxFilial( 'STL' ) )
				aAdd( aBind, aDadosOs[nLineOs,1] )
				aAdd( aBind, '0' )

				cAliIns := GetNextAlias()

				dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQueryIns, aBind ), cAliIns, .T., .T. )

				//Se não encontrou, coloca o TJ_TIPORET como vazio
				If ( cAliIns )->QTD_INS == 0

					DbSelectArea( 'STJ' )
					//TJ_FILIAL+TJ_ORDEM+TJ_PLANO+TJ_TIPOOS+TJ_CODBEM+TJ_SERVICO+TJ_SEQRELA
					DbSetOrder(1)
					If DbSeek(FwxFilial('STJ') + aDadosOs[nLineOs,1])

						RecLock('STJ',.F.)

							STJ->TJ_TIPORET := ' '

						STJ->( MsUnlock() )

					EndIf

				EndIf

				( cAliIns )->( dbCloseArea() )

			EndIf //Fim gravacao insumos

			/*-------------------------+
			| Gravacao das Ocorrencias |
			+-------------------------*/
			If TT9->( FieldPos( 'TT9_CARACT' ) ) > 0

				If ( cMemoQry == 'OFF' )

					/*-------------------------------------+
					| Habilita retorno de campos tipo memo |
					+-------------------------------------*/
					TCConfig( 'SETMEMOINQUERY=ON' )

				EndIf

				If Empty( cQryGrvSTN )

					cCast := " STN.TN_DESCRIC, " // INFORMIX

					Do Case
						
						Case cDbase == 'ORACLE'
							
							cCast := " UTL_RAW.CAST_TO_VARCHAR2( dbms_lob.substr( STN.TN_DESCRIC, 2000, 1 ) ) AS TN_DESCRIC "
						
						Case cDbase == 'POSTGRES'
							
							cCast := " COALESCE( CAST( CAST( STN.TN_DESCRIC AS bytea ) AS bytea ), '' ) AS TN_DESCRIC "
							
						Case 'MSSQL' $ cDbase

							cCast := " ISNULL( CAST( CAST( STN.TN_DESCRIC AS VARBINARY( 2000 ) ) AS VARCHAR( 2000 ) ),'') AS TN_DESCRIC "
					
					End Case

					cQryGrvSTN := "SELECT "
					cQryGrvSTN += 	"STN.TN_ORDEM  , "
					cQryGrvSTN += 	"STN.TN_PLANO  , "
					cQryGrvSTN += 	"STN.TN_SEQRELA, "
					cQryGrvSTN += 	"STN.TN_TAREFA , "
					cQryGrvSTN += 	"STN.TN_CODOCOR, "
					cQryGrvSTN += 	"STN.TN_CAUSA  , "
					cQryGrvSTN += 	"STN.TN_SOLUCAO, "
					cQryGrvSTN += 	"STN.RECSTN    , "
					cQryGrvSTN += 	"STN.D_E_L_E_T_ AS DELSTN, "
					cQryGrvSTN +=	cCast 
					cQryGrvSTN += "FROM "
					cQryGrvSTN += 	oTmpTbl8:GetRealName() + " STN "
					cQryGrvSTN += "WHERE "
					cQryGrvSTN += 	"STN.TN_ORDEM   = ? AND "
					cQryGrvSTN += 	"STN.TN_PLANO   = ? "

					cQryGrvSTN := ChangeQuery( cQryGrvSTN )

				EndIf

				aBind := {}

				aAdd( aBind, cOrdem )
				aAdd( aBind, cPlano )

				dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQryGrvSTN, aBind ), cAlsSTN, .T., .T. )
				
				If (cAlsSTN)->( !EoF() )
					
					While (cAlsSTN)->( !EoF() )
						
						/*--------------------------------------+
						| Posiciona na ocorrência para gravação |
						+--------------------------------------*/
						If !( lFound := Empty( (cAlsSTN)->RECSTN ) )

							dbSelectArea( 'STN' )
							dbGoTo( (cAlsSTN)->RECSTN )

						EndIf

						/*------------------------+
						| Exclusão de ocorrências |
						+------------------------*/
						If !Empty( (cAlsSTN)->DELSTN )

							If !Empty( (cAlsSTN)->RECSTN )
							
								RecLock( 'STN', .F. )

									dbDelete()

								STN->( MsUnLock() )

							EndIf

						/*-------------------------------------+
						| Inclusão ou Alteração de ocorrências |
						+-------------------------------------*/
						Else

							RecLock( 'STN', lFound )

								STN->TN_FILIAL  := FWxFilial( 'STN' )
								STN->TN_ORDEM   := (cAlsSTN)->TN_ORDEM
								STN->TN_PLANO   := (cAlsSTN)->TN_PLANO
								STN->TN_TAREFA  := (cAlsSTN)->TN_TAREFA
								STN->TN_SEQRELA := (cAlsSTN)->TN_SEQRELA
								STN->TN_CODOCOR := (cAlsSTN)->TN_CODOCOR
								STN->TN_CAUSA   := (cAlsSTN)->TN_CAUSA
								STN->TN_SOLUCAO := (cAlsSTN)->TN_SOLUCAO
								STN->TN_DESCRIC := (cAlsSTN)->TN_DESCRIC

							STN->( MsUnLock() )

						EndIf

						(cAlsSTN)->( dbSkip() )

					End

					If ( nLinOS := aScan( aDadosOS, { |x| x[1] + x[2] == cOrdem + cPlano } ) )
						
						aDadosOS[nLinOS,_OCCURRENCES_] := {}

					EndIf

					/*--------------------------------------------+
					| Faz o reset das informações de ocorrências. |
					+--------------------------------------------*/
					NGZap( oTmpTbl8:GetRealName(), "TN_ORDEM = " + ValToSQL( cOrdem ) +;
						" AND TN_PLANO = " + ValToSQL( cPlano ) )

				EndIf

				(cAlsSTN)->( dbCloseArea() )

				If ( cMemoQry == 'OFF' )

					/*-------------------------------------+
					| Habilita retorno de campos tipo memo |
					+-------------------------------------*/
					TCConfig( 'SETMEMOINQUERY=OFF' )

				EndIf

			Else

				If ValType( aDadosOS[nLineOS,5] ) == 'A'

					For nIndOS := 1 to Len(aDadosOS[nLineOS,5])
						
						aArrayTmp := aDadosOS[ nLineOS,5,nIndOS, Len(aDadosOS[nLineOS,5,nIndOS])-1  ]
						If Valtype(aArrayTmp) <> "A" .Or. aDadosOS[ nLineOS,5,nIndOS, Len(aDadosOS[nLineOS,5,nIndOS]) ]
							Loop
						EndIf

						//Excluindo os motivos que foram retirados da tela
						//TN_FILIAL+TN_ORDEM+TN_PLANO+TN_TAREFA+TN_SEQRELA+TN_CODOCOR+TN_CAUSA+TN_SOLUCAO
						dbSelectArea("STN")
						dbSetOrder(1)
						dbSeek(xFilial("STN")+cOrdem+cPlano+aDadosOS[nLineOS,5,nIndOS,nPos16]+aDadosOS[nLineOS,5,nIndOS,nPos18])
						While !EoF() .And. xFilial("STN")+cOrdem+cPlano      == STN->(TN_FILIAL+TN_ORDEM+TN_PLANO) .And. ;
						aDadosOS[nLineOS,5,nIndOS,nPos16] == STN->TN_TAREFA .And. ;
						aDadosOS[nLineOS,5,nIndOS,nPos18] == STN->TN_SEQRELA

							If aScan(aArrayTmp ,{|x| x[nOcoCo] == STN->TN_CODOCOR .And. x[nOcoCa] == STN->TN_CAUSA .And. ;
							x[nOcoSo] == STN->TN_SOLUCAO .And. !x[Len(x)] }) == 0
								RecLock("STN",.F.)
								dbDelete()
								STN->(MsUnLock())
							EndIf

							dbSelectArea("STN")
							dbSkip()
						EndDo

						//Os registros deletados serão os primeiros da lista
						aSort(aArrayTmp,,,{|x,y| x[Len(x)] .And. !y[Len(y)] })
						For nIndOS2 := 1 to Len(aArrayTmp)

							If Empty(aArrayTmp[nIndOS2,nOcoCo]) //Nao validar se codigo vazio
								Loop
							EndIf

							cKeySTN := xFilial("STN")+cOrdem+cPlano+aDadosOS[nLineOS,5,nIndOS,nPos16]+aDadosOS[nLineOS,5,nIndOS,nPos18]
							cKeySTN += aArrayTmp[nIndOS2,nOcoCo] + aArrayTmp[nIndOS2,nOcoCa] + aArrayTmp[nIndOS2,nOcoSo]

							//Se nao for deletado
							If !aArrayTmp[nIndOS2][Len(aArrayTmp[nIndOS2])]

								lSTN_Lock := .T.
								dbSelectArea("STN")
								dbSetOrder(1)
								lSTN_Lock := !dbSeek(cKeySTN)
								RecLock("STN",lSTN_Lock)

								For nIndSTN := 1 TO FCount()
									If Alltrim(FieldName(nIndSTN)) $ "TN_FILIAL/TN_ORDEM/TN_PLANO/TN_TAREFA/TN_SEQRELA"
										Loop
									EndIf
									nPosTmp := aScan(aHoBrw3, {|x| AllTrim(Upper(X[2])) == FieldName(nIndSTN) })
									y  := "STN->" + FieldName(nIndSTN)
									If nPosTmp > 0
										x  := "M->" + FieldName(nIndSTN)
										&x.:= aArrayTmp[nIndOS2,nPosTmp]
										&y := &x
									ElseIf lSTN_Lock
										&y := CriaVar(FieldName(nIndSTN))
									EndIf
								Next nIndSTN
								STN->TN_FILIAL  := xFilial("STN")
								STN->TN_ORDEM   := cOrdem
								STN->TN_PLANO   := cPlano
								STN->TN_TAREFA  := aDadosOS[nLineOS,5,nIndOS,nPos16]
								STN->TN_SEQRELA := aDadosOS[nLineOS,5,nIndOS,nPos18]
								STN->(MsUnLock())
							Else

								dbSelectArea("STN")
								dbSetOrder(1)
								If dbSeek(cKeySTN)
									RecLock("STN",.F.)
									dbDelete()
									STN->(MsUnLock())
								EndIf

							EndIf

						Next nIndOS2
					Next nIndOS

				EndIf

			EndIf

			//Gerar SA
			If Len(aDadosSA) > 0
				nLineSA := aScan(aDadosSA, {|x|x[1]+x[2] == cOrdem+cPlano })
				If nLineSA > 0
					For nxSA := nLineSA To Len(aDadosSA)
						//Se terminar as SA da OS
						If aDadosSA[nxSA,1]+aDadosSA[nxSA,2] != cOrdem+cPlano
							Exit
						EndIf

						//Se estiver deletado
						If !aDadosSA[nxSA,13]
							Loop
						EndIf

						nItemSA++

						dbSelectArea("SCP")
						If nItemSA > 99
							nItemSA := 1
							cNumSA  := " "
						EndIf

						RecLock("SCP",.T.)
						SCP->CP_FILIAL  := xFilial("SCP")

						If Empty(cNumSA)
							cNumSA := GetSxeNum("SCP","CP_NUM")
							ConfirmSX8()
						EndIf
						SCP->CP_NUM     := cNumSA
						SCP->CP_ITEM    := StrZero(nItemSA,2)
						SCP->CP_PRODUTO := aDadosSA[nxSA,03]
						SCP->CP_UM      := aDadosSA[nxSA,04]
						SCP->CP_QUANT   := aDadosSA[nxSA,05]
						SCP->CP_DATPRF  := aDadosSA[nxSA,06]
						SCP->CP_LOCAL   := aDadosSA[nxSA,07]
						SCP->CP_OP      := aDadosSA[nxSA,08]
						SCP->CP_CC      := aDadosSA[nxSA,09]
						SCP->CP_EMISSAO := aDadosSA[nxSA,10]
						SCP->CP_DESCRI  := aDadosSA[nxSA,11]
						SCP->CP_SOLICIT := aDadosSA[nxSA,12]

						SCP->(MsUnLock())

						//Mensagem Unica
						If AllTrim(GetNewPar("MV_NGINTER","N")) == "M"
							If cNGMNTAS == "1"
								cNumCP := SCP->CP_NUM
							Else
								NGMUReques(SCP->(RecNo()),"SCP",.F.,3)
							EndIf
						EndIf

					Next nxSA
				Endif

				If AllTrim(GetNewPar("MV_NGINTER","N")) == "M"
					If cNGMNTAS == "1"
						If !Empty(cNumCP) .And. NGIFDBSEEK( "SCP",cNumCP,01,.F. )
							NGMUReques( SCP->( RecNo()),"SCP",.F.,3 )
						EndIf
					EndIf
				EndIf
			EndIf//Fim Geracao SA

			/*-------------------+
			| Gravação de Etapas |
			+-------------------*/
			If ValType(aDadosOS[nLineOS,8]) == "A"

				//Excluindo as etapas que foram retirados da tela
				dbSelectArea("STQ")
				dbSetOrder(1)
				dbSeek( xFilial("STQ") + cOrdem + cPlano )
				While !EoF() .And. xFilial("STQ") + cOrdem + cPlano == STQ->( TQ_FILIAL + TQ_ORDEM + TQ_PLANO )

					If aScan( aDadosOS[nLineOS,8], { |x| !Empty( x[nRecSTQ] ) .And.;
						x[nRecSTQ] == STQ->( RecNo() ) } ) == 0
						
						dbSelectArea("TPQ")
						dbSetOrder(1)
						If dbSeek( xFilial("TPQ") + cOrdem + cPlano + STQ->TQ_TAREFA + STQ->TQ_ETAPA )
							While !EoF() .And. TPQ->TPQ_FILIAL == xFilial("TPQ") .And.;
							TPQ->TPQ_ORDEM == cOrdem .And. TPQ->TPQ_PLANO == cPlano .And.;
							TPQ->TPQ_TAREFA == STQ->TQ_TAREFA .And. TPQ->TPQ_ETAPA  == STQ->TQ_ETAPA

								RecLock("TPQ", .F.)
								dbDelete()
								TPQ->( MsUnLock() )

								dbSelectArea("TPQ")
								dbSkip()
							EndDo

						EndIf

						RecLock( 'STQ', .F. )

							dbDelete()

						STQ->( MsUnLock() )

					EndIf

					dbSelectArea("STQ")
					dbSkip()

				End

				For nIndOS := 1 to Len(aDadosOS[nLineOS,8])

					aVetTemp  := aDadosOS[nLineOS,8,nIndOS]
					nPosArray := aScan( aVetTemp, { |x| ValType( x ) == 'A' } )

					If Empty(aVetTemp[nEtaTa]) .And. Empty(aVetTemp[nEtapa])
						Loop
					EndIf

					cORDSTJ := STJ->TJ_ORDEM
					cPLASTJ := STJ->TJ_PLANO
					cBEMSTJ := STJ->TJ_CODBEM
					cSERSTJ := STJ->TJ_SERVICO
					nSEQSTJ := STJ->TJ_SEQRELA
					nSEQOLD := STJ->TJ_SEQRELA
					cBEMOLD := STJ->TJ_CODBEM
					cSEROLD := STJ->TJ_SERVICO

					nSEQSTJ := nSEQOLD

					If Empty( aVetTemp[nRecSTQ] )
						
						RecLock( 'STQ', .T. )

							STQ->TQ_FILIAL  := FWxFilial( 'STQ' )
							STQ->TQ_ORDEM   := cOrdem
							STQ->TQ_PLANO   := cPlano
							STQ->TQ_OK      := aVetTemp[nOkSTQ]

							If STQ->( FieldPos( 'TQ_SEQRELA' ) ) > 0
								
								STQ->TQ_SEQRELA := aVetTemp[nSeqSTQ]

							EndIf

							For i := 1 To Len( aTRBQ )

								If !( AllTrim( aTRBQ[i,2] ) $ 'TQ_FILIAL/TQ_ORDEM/TQ_PLANO' ) .And.;
									Posicione( 'SX3', 2, aTRBQ[i,2], 'X3_CONTEXT' ) != 'V'

									xx := AllTrim( aTRBQ[i,2] )
									&( 'STQ->' + xx ) := aVetTemp[i]

								EndIf

							Next i

						STQ->( MsUnLock() )

					Else

						STQ->( msGoTo( aVetTemp[nRecSTQ] ) )

						RecLock( 'STQ', .F. )

							STQ->TQ_OK := aVetTemp[nOkSTQ]

							If STQ->( FieldPos( 'TQ_SEQRELA' ) ) > 0
								
								STQ->TQ_SEQRELA := aVetTemp[nSeqSTQ]

							EndIf

							For i := 1 To Len( aTRBQ )

								If !( Alltrim(aTRBQ[i,2] ) $ 'TQ_FILIAL/TQ_ORDEM/TQ_PLANO/TQ_TAREFA/TQ_ETAPA/TQ_OK' ) .And.;
									Posicione( 'SX3', 2, aTRBQ[i,2], 'X3_CONTEXT' ) != 'V'

									xx := AllTrim( aTRBQ[i,2] )
									&( 'STQ->' + xx ) := aVetTemp[i]

								EndIf

							Next i

						STQ->( MsUnLock() )

					EndIf

					If STQ->( FieldPos( 'TQ_SEQRELA' ) ) > 0

						/*----------------------------------------+
						| Define as cores para legenda de etapas. |
						+----------------------------------------*/
						fLegendEt( STQ->TQ_ORDEM + STQ->TQ_PLANO + STQ->TQ_TAREFA +;
							STQ->TQ_ETAPA + STQ->TQ_SEQRELA, 4 )

					Else

						/*----------------------------------------+
						| Define as cores para legenda de etapas. |
						+----------------------------------------*/
						fLegendEt( STQ->TQ_TAREFA + STQ->TQ_ETAPA + STQ->TQ_SEQETA )

					EndIf

					//Opções de resposta das etapas. Verifica se house marcação anteriormente
					aArray  := {}
					aArray2 := {}
					
					If Empty( aVetTemp[nOkSTQ] )

						dbSelectArea("TPQ")
						dbSetOrder(1)
						dbSeek(xFilial("TPQ")+cOrdem+cPlano+aVetTemp[nEtaTa]+aVetTemp[nEtapa])
						While !EoF() .And. TPQ->TPQ_FILIAL == xFilial("TPQ") .And.;
						TPQ->TPQ_ORDEM == cOrdem .And. TPQ->TPQ_PLANO == cPlano .And. ;
						TPQ->TPQ_TAREFA == aVetTemp[nEtaTa] .And. TPQ->TPQ_ETAPA  == aVetTemp[nEtapa]

							RecLock("TPQ",.F.)
							dbDelete()
							TPQ->(MsUnLock())
							dbSelectArea("TPQ")
							dbSkip()
						EndDo

					Else

						//Excluindo as opções retiradas da tela
						dbSelectArea("TPQ")
						dbSetOrder(1)
						dbSeek(xFilial("TPQ") + cOrdem + cPlano + aVetTemp[nEtaTa] + aVetTemp[nEtapa])
						While !EoF() .And. TPQ->TPQ_FILIAL == xFilial("TPQ") .And.;
						TPQ->TPQ_ORDEM == cOrdem .And. TPQ->TPQ_PLANO == cPlano .And. ;
						TPQ->TPQ_TAREFA == aVetTemp[nEtaTa] .And. TPQ->TPQ_ETAPA  == aVetTemp[nEtapa]

							If aScan(aVetTemp[nPosArray] ,{|x| !Empty(x[1]) .And. x[2] == TPQ->TPQ_OPCAO }) == 0
								dbSelectArea("TPQ")

								RecLock("TPQ",.F.)
								dbDelete()
								TPQ->(MsUnLock())
							EndIf

							dbSelectArea("TPQ")
							dbSkip()
						EndDo

						lPrimVez := .T.
						For nXX := 1 To Len(aVetTemp[nPosArray])

							If Empty( aVetTemp[nPosArray , nXX , 1] )
								Loop
							EndIf

							nSEQSTF   := nSEQOLD
							cBEMSTJ   := cBEMOLD
							lTpGeraOS := .F.
							lTPGeraSS := .F.

							cTpcMark   := aVetTemp[nPosArray,nXX,1]
							cTpcRespos := aVetTemp[nPosArray,nXX,3]
							cTpcOpcao  := aVetTemp[nPosArray,nXX,2]

							dbSelectArea("TPC")
							dbSetOrder(1)
							If !dbSeek(xFilial("TPC") + aVetTemp[nEtapa] + cTpcOpcao )
								Loop
							EndIf

							lAltTPQ := .F. //Indica se a Resposta da Etapa é nova ou foi modificada
							lTPQ_OS := .F. //Indica se a Resposta da Etapa que está sendo modificada, já tinha gerado OS antes
							lGerTPQ := .F. //Indica se a Resposta da Etapa que está sendo modificada não deve gerar OS

							dbSelectArea("TPQ")
							dbSetOrder(1)
							If !dbSeek(xFilial("TPQ")+ cOrdem+ cPlano+ aVetTemp[nEtaTa]+ aVetTemp[nEtapa]+ cTpcOpcao )
								RecLock("TPQ",.T.)
								TPQ->TPQ_FILIAL := xFilial("TPQ")
								TPQ->TPQ_ORDEM  := cOrdem
								TPQ->TPQ_PLANO  := cPlano
								TPQ->TPQ_TAREFA := aVetTemp[nEtaTa]
								TPQ->TPQ_ETAPA  := aVetTemp[nEtapa]
								TPQ->TPQ_OPCAO  := cTpcOpcao
								TPQ->TPQ_RESPOS := cTpcRespos
								TPQ->TPQ_OK     := cTpcMark
								TPQ->(MsUnLock())
								lAltTPQ := .T.
							Else
								RecLock("TPQ",.F.)
								If Alltrim(TPQ->TPQ_RESPOS) <> Alltrim(cTpcRespos)
									lAltTPQ := .T.
									If !Empty(TPQ->TPQ_ORDEMG)
										lTPQ_OS := .T.
									EndIf
								EndIf
								TPQ->TPQ_RESPOS := cTpcRespos
								TPQ->TPQ_OK     := cTpcMark
								TPQ->(MsUnLock())
							EndIf

							cSerSTJ := TPC->TPC_SERVIC

							If TPC->TPC_TPMANU == '1'
								lTpGeraOS := .T.
								cTipoMan  := NGSEEK( "ST4", TPC->TPC_SERVIC, 1, "T4_TIPOMAN")
								cServCar  := NGSEEK( "STE", cTipoMan, 1, "TE_CARACTE")

							ElseIf TPC->TPC_TPMANU == '2'
								lTPGeraSS := .T.
							EndIf

							//Identificação da geração da Ordem
							If TPC->TPC_PORBEM == '2'
								cBemOr := Space( TAMSX3("T9_CODBEM")[1] )

								If !Empty(TPC->TPC_DESCRI)

									cBemOr := SubStr( TPC->TPC_DESCRI, 1, TAMSX3("T9_CODBEM")[1] )

									dbSelectArea("ST9")
									dbSetOrder(1)
									If !dbSeek(xFilial("ST9") + cBEMOR)
										cBemOr := Space( TAMSX3("T9_CODBEM")[1] )
									Else
										If lTpGeraOS
											If cServCar == 'P' // O.S. Preventiva
												nSeqSTJ := IIf( Alltrim(nSeqSTJ) == "0", "1  ", nSeqSTJ )
												dbSelectArea("STF")
												dbSetOrder(1)
												If !dbSeek(xFilial("STF") + cBemOr + cSerSTJ + nSeqSTJ)
													cBemOr := Space( TAMSX3("T9_CODBEM")[1] )
												EndIf
											EndIf
										EndIf
									EndIf
								EndIf
								cBemSTJ := IIf( Empty(cBemOr), cBemSTJ, cBemOr )
							EndIf

							//Processa a geração de O.S.
							If !NG400VALOS(,TPC->TPC_SERVIC, .T.)
								If TPC->TPC_TIPRES == '2' .And. lAltTPQ // INFORMADA
									If !Empty(cTpcRespos)

										dbSelectArea("TPC")
										dbSetOrder(1)
										If dbSeek( xFilial("TPC") + aVetTemp[nEtapa] + cTPCOpcao )

											lCondicao := .F.

											Do Case
												Case TPC->TPC_TIPCAM == "L"
												cResp := AllTrim( cTpcRespos )
												Case TPC->TPC_TIPCAM == "N"
												cResp := cValToChar( Val( cTpcRespos ) )
												Case TPC->TPC_TIPCAM == "D"
												cResp := "'" + DToS( cToD( cTpcRespos ) ) + "'"
												Case TPC->TPC_TIPCAM == "C"
												cResp := "'" + AllTrim( cTpcRespos ) + "'"
											EndCase

											cForm := StrTran( TPC->TPC_FORMUL, '#RESP#', cResp )

											lCondicao := &( cForm )
										EndIf
									EndIf
								EndIf

								If lCondicao .Or. ( TPC->TPC_TIPRES == '1' .And. lAltTPQ )
									xx := aScan(aArray, {|x|(x[1]+x[2]) == cTpcOpcao + aVetTemp[nEtaTa] })
									xy := aScan(aArray2,{|x|(x[1]+x[2]) == cTpcRespos + aVetTemp[nEtaTa] })

									If lTPGeraOs
										If cServCar $ "P/O" .And. xx == 0  .And. xy == 0

											//--inicio--OS 024720 //
											/*
											Verifica se é a primeira que está passando por esse for.
											Caso for, lPrimVez se torna false para o proximo loop, assim como
											cChavAnt recebe a chave atual do OS. (Codigo do Bem e Serviço).
											Caso não seja a primeira vez, irá verificar se a chave atual é a mesma
											que a chave anterior, caso seja, considerará que está repetindo a OS, setando
											para True a váriavel lOSRepet, para que não faça a inclusão de uma nova OS
											para a mesma chave.
											Casa não seja a mesma chave a ser gerada, lOSRepet recebe False, para fazer
											uma nova inclusão de OS. E a chave atual se torna a chave anterior.
											Logica feita tanto para OSs Preventivas, quanto para Corretivas.
											SS: 024720
											Autor: Maicon André Pinheiro
											Data 11/02/2016
											*/
											If lPrimVez
												lPrimVez := .F.
												cChavAnt := STJ->TJ_CODBEM+STJ->TJ_SERVICO
											Else

												If STJ->TJ_CODBEM+STJ->TJ_SERVICO == cChavAnt
													lOSRepet := .T.
												Else
													lOSRepet := .F.
													cChavAnt := STJ->TJ_CODBEM+STJ->TJ_SERVICO
												EndIf
											EndIf
											//---fim----OS 024720 //

											//Deve gerar OS
											lGerTPQ := .T.

											//Se nao tinha gerado OS
											If !lTPQ_OS .And. lOSRepet == .F.
												cVPREVEN := fNG435GPRE( '2', cOrdem, nEtaTa, nEtapa, cServCar)
												If cVPREVEN[1]
													dbSelectArea("TPQ")
													dbSetOrder(1)
													If dbSeek(xFilial("TPQ") + cOrdem + cPlano + aVetTemp[nEtaTa] + aVetTemp[nEtapa] + cTpcOpcao )
														RecLock("TPQ", .F.)
														TPQ->TPQ_ORDEMG := cVPREVEN[2]
														TPQ->(MsUnLock())
													EndIf
												EndIf
											EndIf
										ElseIf cServCar == "C" .And. xx == 0  .And. xy == 0

											//--inicio--OS 024720 //
											If lPrimVez
												lPrimVez := .F.
												cChavAnt := STJ->TJ_CODBEM+STJ->TJ_SERVICO
											Else

												If STJ->TJ_CODBEM+STJ->TJ_SERVICO == cChavAnt
													lOSRepet := .T.
												Else
													lOSRepet := .F.
													cChavAnt := STJ->TJ_CODBEM+STJ->TJ_SERVICO
												EndIf
											EndIf
											//---fim----OS 024720 //

											//Deve gerar OS
											lGerTPQ := .T.

											//Se não tinha gerado OS
											If !lTPQ_OS .And. lOSRepet == .F.
												cVOSCORR := fNG435GCOR( '2', cOrdem, nEtaTa, nEtapa, cServCar)
												If cVOSCORR[1]
													dbSelectArea("TPQ")
													dbSetOrder(1)
													If dbSeek(xFilial("TPQ") + cOrdem + cPlano + aVetTemp[nEtaTa] + aVetTemp[nEtapa]+ cTpcOpcao )
														RecLock("TPQ", .F.)
														TPQ->TPQ_ORDEMG := cVOSCORR[2]
														TPQ->(MsUnLock())
													EndIf
												EndIf
											EndIf
										EndIf
									ElseIf lTPGeraSS

										cMsgSS := "O.S. Origem" + ": " + STJ->TJ_ORDEM + Chr(13) + Chr(10)
										cMsgSS += "Etapa" + ": " + aVetTemp[nEtapa] + Chr(13) + Chr(10)
										cMsgSS += "Opção" + ": " + cTpcOpcao + Chr(13) + Chr(10)

										If TPC->TPC_TIPRES == '2'
											cMsgSS += "Resposta" + ": " + cTpcRespos
										Else
											cMsgSS += "Marcou" + ": " + "Sim"
										EndIf

										If lMNTA435M
											cMsgSS += ExecBlock( "MNTA435M",.F.,.F.,{ cMsgSS, STJ->TJ_CODBEM, STJ->TJ_ORDEM, STJ->TJ_PLANO, ;
																					aVetTemp[nEtaTa], aVetTemp[nEtapa], aVetTemp[nEtSeq] } )
										EndIf

										// aSolic := { Código do Bem, Ramal, Descrição da Solicitação, Serviço }
										aSolic := { { "TQB_CODBEM", cBemSTJ, Nil },;
										{ "TQB_RAMAL" , "0000", Nil },;
										{ "TQB_DESCSS", cMsgSS, Nil },;
										{ "TQB_CDSERV", TPC->TPC_SERVIC, Nil } }

										lMSHelpAuto := .T. // Não apresenta erro em tela
										lMSErroAuto := .F. // Caso a variável torne-se .T. apos MsExecAuto, apresenta erro em tela

										MSExecAuto( {|x,z,y,w| MNTA280(x,z,y,w)},,, aSolic )

										If lMsErroAuto
											MostraErro()

										ElseIf !Empty( TQB->TQB_SOLICI )
											MsgInfo(cErro := "Foi gerada uma S.S. conforme a resposta da etapa!" )

											dbSelectArea("TPQ")
											dbSetOrder(01)
											If dbSeek( xFilial("TPQ") + cOrdem + cPlano + aVetTemp[nEtaTa] + aVetTemp[nEtapa] + cTpcOpcao )
												RecLock( "TPQ", .F.)
												TPQ->TPQ_ORDEMG := TQB->TQB_SOLICI
												MsUnlock("TPQ")
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf

							If !lGerTPQ //Se esta Resposta não deve gerar OS
								If lTPQ_OS //Se esta Resposta gerou OS anteriormente
									dbSelectArea("TPQ")
									dbSetOrder(01)
									If dbSeek(xFilial("TPQ") + cOrdem + cPlano + aVetTemp[nEtaTa] + aVetTemp[nEtapa] + cTpcOpcao )
										RecLock("TPQ",.F.)
										TPQ->TPQ_ORDEMG := Space( TAMSX3("TPQ_ORDEMG")[1] )
										TPQ->(MsUnLock())
									EndIf
								EndIf
							EndIf

						Next nXX //Fim laço das opções da etapa/tarefa
					EndIf //Fim se estiver concluido etapa/tarefa
				Next nIndOS //Fim laço etapa/tarefa
			EndIf

			//Retira da getdados os registros deletados
			If lRefBrow .And. ValType(aDadosOS[nLineOS,5]) == "A"

				aTmpCol := aClone( aDadosOS[nLineOS, 5] )
				aDadosOS[nLineOS,5] := {}

				//Inclue no array de insumos, somente os que não estão deletados
				For nIndOS := 1 to Len( aTmpCol )

					If !aTmpCol[nIndOS, Len( aTmpCol[nIndOS] )]
						aAdd( aDadosOS[nLineOS,5] , aClone( aTmpCol[nIndOS] ) )
					EndIf

				Next nIndOS

				//Caso algum insumo tenha apresentado erro ao ser deletado, este será mantido no array de insumos.
				If !Empty( aLogRM )

					For nErro := 1 to Len( aLogRM )

						If aDadosOS[nLineOS, 1] == aLogRM[nErro, 2] .And. aDadosOS[nLineOS, 2] == aLogRM[nErro, 3]

							nFound  := aScan( aTmpCol, { |x| x[nPos18] == aLogRM[nErro, 7] } )

							If nFound > 0 .And. aScan( aDadosOS[nLineOS,5], { |x| x[nPos18] == aLogRM[nErro, 7] } ) == 0

								//Armazena posição do insumo e o array do insumo para que este não seja copiado para o array de insumos já gravados
								aNoCopy := { nFound, aDadosOS[nLineOS, 4, nFound] }

								aAdd( aDadosOS[nLineOS,5] , aClone( aTmpCol[nFound] ) )

							EndIf

						EndIf

					Next nErro

				EndIf

				// Reordena aCols conforme TL_SEQRELA
				If nPos18 > 0
					aSort( aDadosOS[nLineOS,5],,, { |x,y| x[nPos18] < y[nPos18] } )
				EndIf

				//Faz a copia do conteudo do Array de insumos alterados [5] para o array de insumos já gravados [4]
				If Len(aDadosOS[nLineOS,5]) > 0

					/*-----------------------------------------------------------------------------------+
					| Em caso de inconsitência nos processos a seguir, o array de controle é restaurado. |
					+-----------------------------------------------------------------------------------*/
					aAdd( aRollBack, { nLineOS, aClone( aDadosOS[nLineOS] ) } )

					aDadosOS[nLineOS,4] := aClone(aDadosOS[nLineOS,5])

					//Caso tenha algum que não pode ser gavado efetivamente, retorna o backup da posição correta do insumo.
					If !Empty( aNoCopy )

						//Importante que para o funcionamento os arrays estejam ordenados por TL_SEQRELA.
						For nCopy := 1 To Len( aNoCopy )

							aDadosOS[nLineOS, 4, aNoCopy[1]] := aClone( aNoCopy[2] )

						Next nCopy

					EndIf

				Else

					/*-----------------------------------------------------------------------------------+
					| Em caso de inconsitência nos processos a seguir, o array de controle é restaurado. |
					+-----------------------------------------------------------------------------------*/
					aAdd( aRollBack, { nLineOS, aDadosOS[nLineOS] } )

					aDadosOS[nLineOS,4] := aClone( aNovoSTL )
					
					aDadosOS[nLineOS,5] := Nil

				EndIf

			EndIf

			If lCanOrFin
				exit
			Else
				(cAliOS435)->( dbSkip() )
			EndIf

		EndDo

		//Executa as requisicoes de uma so vez
		For nX := 1 To Len(aReqSD3)
			dbSelectArea("STL")
			dbSetOrder(1)
			dbGoTo(aReqSD3[nX,1])
			If !EoF() .And. !Bof()

				// Posicionamento na STJ exigido, devido ao processo de gravacao da função MNTGERAD3
				If NGIFDBSEEK("STJ",STL->TL_ORDEM + STL->TL_PLANO,1)

					/*----------------------------------------------------------------------------------------------------+
					| Salva valores da STL antes da função MntGeraD3, pois ao integrar com RM o registro pode ser perdido |
					+----------------------------------------------------------------------------------------------------*/
					cRMTaref := STL->TL_TAREFA
					cRMTipoR := STL->TL_TIPOREG
					cRMCodIn := STL->TL_CODIGO
					cRMSeqre := STL->TL_SEQRELA
					cRMNumse := STL->TL_NUMSEQ

					aRetSD3 := MntGeraD3( 'RE0', aReqSD3[nX,2], , .T., .F., .T. )

					If aRetSD3[2]

						dbSelectArea( 'STL' )
						RecLock( 'STL', .F. )

							STL->TL_NUMSEQ := aRetSD3[1]

							If !lNGCALCUSTI

								STL->TL_CUSTO  := SD3->D3_CUSTO1

							EndIf

							If lMMoeda
								STL->TL_MOEDA := '1'
							EndIf

						STL->( MsUnLock() )

						If NGPRODESP( SD3->D3_COD, .F., 'M' )
							NGAtuErp( 'SD3', 'INSERT' )
						EndIf

					Else

						aAdd( aLogRM, { aRetSD3[3], STJ->TJ_ORDEM, STJ->TJ_PLANO, cRMTaref,;
							cRMTipoR, cRMCodIn, cRMSeqre, cRMNumse } )

						If lRefBrow

							If nPosArr := aScan( aRollBack, { |x| x[2,1] == STJ->TJ_ORDEM } )

								aDadosOS[aRollBack[nPosArr,1],4] := aClone( aRollBack[nPosArr,2,4] )

							EndIf

						EndIf

						Loop

					EndIf

				EndIf
			EndIf
		Next nX

		//Retira da getdados os registros deletados
		If lRefBrow

			aTmpCol := aClone( aCoBrw6 )
			aCoBrw6 := {}

			For nX := 1 To Len( aTmpCol )

				If !aTmpCol[nX,Len(aTmpCol[nX])]
					aAdd( aCoBrw6, aClone( aTmpCol[nX] ) )
				EndIf

			Next nX

			//Caso algum registro não pode ser deletado, ele retorno com a mesma condição.
			If !Empty( aLogRM )

				For nErro := 1 to Len( aLogRM )

					If cOrdem == aLogRM[nErro, 2] .And. cPlano == aLogRM[nErro, 3]

						nFound := aScan( aTmpCol, { |x| x[nPos18] == aLogRM[nErro, 7] } )

						If nFound > 0
							aAdd( aCoBrw6 , aClone( aTmpCol[nFound] ) )
						EndIf

					EndIf

				Next nErro

			EndIf

			// Reordena aCols conforme TL_SEQRELA
			If nPos18 > 0
				aSort( aCoBrw6,,, { |x,y| x[nPos18] < y[nPos18] } )
			EndIf

			If Len( aCoBrw6 ) == 0

				aCoBrw6 := aClone( aNovoSTL )

			EndIf

			If nPosGrt > 0 .And. Len(aCols) > 0

				If Len(aCols[1]) >= nPosGrt

					aTmpCol := aClone( aCols )
					aCols   := {}

					For nX := 1 To Len( aTmpCol )

						If !aTmpCol[nX,Len( aTmpCol[nX] )]
							aAdd( aCols , aClone( aTmpCol[nX] ) )
						EndIf
					Next nX

					//Caso algum registro não pode ser deletado, ele retorno com a mesma condição.
					If !Empty( aLogRM )

						For nErro := 1 to Len( aLogRM )

							If cOrdem == aLogRM[nErro, 2] .And. cPlano == aLogRM[nErro, 3]

								nFound := aScan( aTmpCol, { |x| x[nPos18] == aLogRM[nErro, 7] } )

								If nFound > 0
									aAdd( aCols , aClone( aTmpCol[nFound] ) )
								EndIf

							EndIf

						Next nErro

					EndIf

					// Reordena aCols conforme TL_SEQRELA
					If nPos18 > 0
						aSort( aCols,,, { |x,y| x[nPos18] < y[nPos18] } )
					EndIf

					If Len( aCols ) == 0

						aCols := aClone( aNovoSTL )

					EndIf

				EndIf
			EndIf

		EndIf

		// Apresentação em lote de inconsitências encontradas.
		If !Empty( aLogRM ) .Or. !Empty( aLogNoCanc )

			MNTA435Log( aLogRM, aLogNoCanc )

			DisarmTransaction()
			lRet := .F.

		EndIf

	//End Transaction

	// Corrige posicionamento do browse
	RestArea( aAreaAlOs )
	RestArea( aAreaSTJ )

	If ExistBlock("MNTA4354")
		ExecBlock("MNTA4354",.F.,.F.,{aHoBrw6,aInsNaoGra})
	EndIf

	CursorArrow()

	/*-----------------------------------------------------
	Mostra browse com as OS geradas atraves das etapas
	-----------------------------------------------------*/
	dbSelectArea(cTRBZ400)
	dbGoTop()
	If !EoF()
		aTRBZ := aClone(aTRBZ435)
		NGMOSTTRBZ()
	EndIf

	dbSelectArea(cTRBK400)
	dbGotop()
	If Reccount() > 0
		NGTRBKMOST()
	EndIf

	//Deleção Tabela Temporária
	oTmpTbl1:Delete()
	oTmpTbl2:Delete()

	lFoiAlterado := .F.

	aProd435   := {} //Produtos atualizados na rotina. Array utilizado para verificação final do estoque antes de gravar
	aLote435   := {} //LOTE atualizados na rotina. Array utilizado para verificação final do estoque antes de gravar
	aSubL435   := {} //SUB-LOTE atualizados na rotina. Array utilizado para verificação final do estoque antes de gravar
	aEnde435   := {} //ENDERECAMENTO atualizados na rotina. Array utilizado para verificação final do estoque antes de gravar
	aDadosTPZ  := {} //Garantia de Insumos Temporario
	aNBaixaEst := {} //Insumos que não efetuarão baixa no estoque - Ponto de Entrada MNT4356

	PutFileInEOF( 'STL' )
	PutFileInEOF( 'STN' )
	PutFileInEOF( 'STQ' )
	PutFileInEOF( 'TPL' )

	/*-------------------------------------------------------------------------------------------+
	| Não deve carregar informações quando ação do click vier dos botões: oBtOK, oBtCOS, oBtFOS. |
	+-------------------------------------------------------------------------------------------*/
	If lLoadIns

		/*-------------------------------------------------------------------+
		| Recarrega informações de insumos realizados para O.S. posicionada. |
		+-------------------------------------------------------------------*/
		LoadInsum( M->TJ_ORDEM , M->TJ_PLANO, aScan( aDadosOS, { |x| x[1] + x[2] == M->TJ_ORDEM + M->TJ_PLANO } ), 1 )

		/*-------------------------------------------------------+
		| Recarrega informações de etapas para O.S. posicionada. |
		+-------------------------------------------------------*/
		LoadEtapas( M->TJ_ORDEM, M->TJ_PLANO, aScan( aDadosOS, { |x| x[1] + x[2] == M->TJ_ORDEM + M->TJ_PLANO } ) )
		
		If TT9->( FieldPos( 'TT9_CARACT' ) ) > 0

			/*---------------------------------------------------------------------------------+
			| Recarrega informações de ocorrências e insumos associados para O.S. posicionada. |
			+---------------------------------------------------------------------------------*/
			fLoadOcorr( aScan( aDadosOS, { |x| x[1] + x[2] == M->TJ_ORDEM + M->TJ_PLANO } ), 1 )

		EndIf

	EndIf

Return lRet

Static Function fCriaOsGer(aTRBZ435)

	Local aDBFZ := {}
	Local aDBFK := {}

	aAdd(aDBFZ,{"ORDEM"  ,"C", 06, 0 })
	aAdd(aDBFZ,{"PLANO"  ,"C", 06, 0 })
	aAdd(aDBFZ,{"CODBEM" ,"C", 16, 0 })
	aAdd(aDBFZ,{"NOMBEM" ,"C", 30, 0 })
	aAdd(aDBFZ,{"SERVICO","C", 06, 0 })
	aAdd(aDBFZ,{"NOMSER" ,"C", 30, 0 })
	aAdd(aDBFZ,{"SEQRELA","C", 03, 0 })
	aAdd(aDBFZ,{"ETAPA"  ,"C", 06, 0 })
	aAdd(aDBFZ,{"OPCAO"  ,"C", 15, 0 })
	aAdd(aDBFZ,{"TIPOET" ,"C", 01, 0 })
	aAdd(aDBFZ,{"RESPOS" ,"C", TAMSX3( 'TPQ_RESPOS' )[1], 0 })
	aAdd(aDBFZ,{"OSORIG" ,"C", 06, 0 })

	aAdd(aTRBZ435,{"Ordem"			, "ORDEM"  , "C", 06, 0,"@!"})
	aAdd(aTRBZ435,{"Plano"			, "PLANO"  , "C", 06, 0,"@!"})
	aAdd(aTRBZ435,{"Bem"			, "CODBEM" , "C", 16, 0,"@!"})
	aAdd(aTRBZ435,{"Nome Bem"		, "NOMBEM" , "C", 30, 0,"@!"})
	aAdd(aTRBZ435,{"Servico"		, "SERVICO", "C", 06, 0,"@!"})
	aAdd(aTRBZ435,{"Nome Servico"	, "NOMSER" , "C", 30, 0,"@!"})
	aAdd(aTRBZ435,{"Sequen"			, "SEQRELA", "C", 03, 0,"@!"})

	//Criação Tabela Temporária
	oTmpTbl1 := NGFwTmpTbl(cTRBZ400,aDBFZ,{{ "ORDEM" }})

	aAdd(aDBFK,{"ORDEM"   , "C", TamSx3("TJ_ORDEM")[1], 0 })
	aAdd(aDBFK,{"PLANO"   , "C", TamSx3("TJ_PLANO")[1], 0 })
	aAdd(aDBFK,{"BEM"     , "C", 16, 0 })
	aAdd(aDBFK,{"ETAPA"   , "C", 06, 0 })
	aAdd(aDBFK,{"OPCAO"   , "C", 15, 0 })
	aAdd(aDBFK,{"RESPOSTA", "C", TAMSX3( 'TPQ_RESPOS' )[1], 0 })
	aAdd(aDBFK,{"INFORMOU", "C", 10, 0 })
	aAdd(aDBFK,{"PERCENTO", "N", 06, 2 })
	aAdd(aDBFK,{"VLRMENOR", "N", 12, 2 })
	aAdd(aDBFK,{"VLRMAIOR", "N", 12, 2 })
	aAdd(aDBFK,{"OBSERVA" , "C", 50, 0 })

	aAdd(aTRBK,{"Ordem"			, "ORDEM"   , "C", TamSx3("TJ_ORDEM")[1],0,"@!"})
	aAdd(aTRBK,{"Plano"			, "PLANO"   , "C", TamSx3("TJ_PLANO")[1],0,"@!"})
	aAdd(aTRBK,{"Bem"			, "BEM"     , "C", 16,0,"@!"})
	aAdd(aTRBK,{"Etapa"			, "ETAPA"   , "C", 06,0,"@!"})
	aAdd(aTRBK,{"Opcao"			, "OPCAO"   , "C", 15,0,"@!"})
	aAdd(aTRBK,{"Informado"		, "INFORMOU", "C", 10,0,"@!"})
	aAdd(aTRBK,{"Resposta"		, "RESPOSTA", "C", TAMSX3( 'TPQ_RESPOS' )[1],0,"@!"})
	aAdd(aTRBK,{"Observacao"	, "OBSERVA" , "C", 40,0,"@!"})
	aAdd(aTRBK,{"Percent."		, "PERCENTO", "N", 06,2,"@E 999.99"})
	aAdd(aTRBK,{"Vlr Menor"		, "VLRMENOR", "N", 12,2,"@E 999,999,999.99"})
	aAdd(aTRBK,{"Vlr Maior"		, "VLRMAIOR", "N", 12,2,"@E 999,999,999.99"})

	//Criação Tabela Temporária
	oTmpTbl2 := NGFwTmpTbl(cTRBK400,aDBFK,{{ "BEM","ETAPA" }})

Return .T.

static function grvDados(cAlias)

	Local bCampo	:= {|nCPO| Field(nCPO) }
	local ny		as numeric
	Local nIndex	:= (cAlias)->(IndexOrd())

	dbSelectArea(cALIAS)
	dbSetOrder(1)
	FOR ny := 1 TO FCount()
		M->&(EVAL(bCampo,ny)) := &(EVAL(bCampo,ny))
	Next ny

	// preenche os campos conforme os dados recebidos no json
	aEval(oxCabec:getNames(),{|cNomeCpo| M->&cNomeCpo := oxCabec[cNomeCpo] })
	//-- Tratativa para campos DATA em JSON -- GV
	/*
	If !Empty(M->TJ_DTPPINI)
		If Valtype(M->TJ_DTPPINI) == "C"
			M->TJ_DTPPINI := StoD(StrTran(M->TJ_DTPPINI,"-",""))
		EndIf
	EndIf
	If !Empty(M->TJ_DTPPFIM)
		If Valtype(M->TJ_DTPPFIM) == "C"
			M->TJ_DTPPFIM := StoD(StrTran(M->TJ_DTPPFIM,"-",""))
		EndIf
	EndIf
	*/
	If !Empty(M->TJ_DTPRINI)
		If Valtype(M->TJ_DTPRINI) == "C"
			M->TJ_DTPRINI := StoD(StrTran(M->TJ_DTPRINI,"-",""))
		EndIf
	EndIf
	If !Empty(M->TJ_DTPRFIM)
		If Valtype(M->TJ_DTPRFIM) == "C"
			M->TJ_DTPRFIM := StoD(StrTran(M->TJ_DTPRFIM,"-",""))
		EndIf
	EndIf
	/*
	If !Empty(M->TJ_DTMPINI)
		If Valtype(M->TJ_DTMPINI) == "C"
			M->TJ_DTMPINI := StoD(StrTran(M->TJ_DTMPINI,"-",""))
		EndIf
	EndIf
	If !Empty(M->TJ_DTMPFIM)
		If Valtype(M->TJ_DTMPFIM) == "C"
			M->TJ_DTMPFIM := StoD(StrTran(M->TJ_DTMPFIM,"-",""))
		EndIf
	EndIf
	If !Empty(M->TJ_DTMRINI)
		If Valtype(M->TJ_DTMRINI) == "C"
			M->TJ_DTMRINI := StoD(StrTran(M->TJ_DTMRINI,"-",""))
		EndIf
	EndIf
	If !Empty(M->TJ_DTMRFIM)
		If Valtype(M->TJ_DTMRFIM) == "C"
			M->TJ_DTMRFIM := StoD(StrTran(M->TJ_DTMRFIM,"-",""))
		EndIf
	EndIf
	If !Empty(M->TJ_DTULTMA)
		If Valtype(M->TJ_DTULTMA) == "C"
			M->TJ_DTULTMA := StoD(StrTran(M->TJ_DTULTMA,"-",""))
		EndIf
	EndIf
	If !Empty(M->TJ_DTORIGI)
		If Valtype(M->TJ_DTORIGI) == "C"
			M->TJ_DTORIGI := StoD(StrTran(M->TJ_DTORIGI,"-",""))
		EndIf
	EndIf
	*/
	//Ponto de Entrada para retirar campos da STJ ao mostrar na Tela Inicial
	If ExistBlock("NGUTILAB")
		aChoice := ExecBlock("NGUTILAB",.F.,.F.,aChoice)
	EndIf

	nOpca := 1
	If ! Eval(bNGGRAVA)
		nOpca := 0
	EndIf

	If nOPCA == 1
		DbSelectArea(cALIAS)

		RecLock(cAlias,Inclui)
		For ny := 1 To FCOUNT()
			nx := "m->" + FieldName(ny)
			FieldPut(ny,&nx.)
		Next ny
		(cALIAS)->(MSUNLOCK())

		EvalTrigger() // Processa Gatilhos
	Endif

	If ExistBlock("NGCAD01F")
		ExecBlock( "NGCAD01F", .F., .F., {cAlias, nReg, nOpcX, nOPCA, FunName()} )
	Endif

	lRefresh := .T.

	(cAlias)->(dbSetorder(nIndex))

return nOPCa

Static Function fInteg( cOServ )

	Local cOProd   := PadR( cOServ + 'OS001', FwTamSX3( 'D4_OP' )[1] )
	Local lRet     := .T.

	// a funcao MntUseExec foi descontinuada pelo padrao. Ela fazia a verificacao se alguns campos
	// obrigatorios do padrao estavam marcados como 'Usado' no dicionario de dados
	If NgVldRpo( { { 'MNTUTIL.prx', SToD( '20221103' ), '12:00' } } )// .And. MntUseExec( 'SD4' )

		//BEGIN TRANSACTION

			dbSelectArea( 'SD4' )
			dbSetOrder( 2 ) // D4_FILIAL + D4_OP + D4_COD + D4_LOCAL
			If msSeek( FWxFilial( 'SD4' ) + cOProd )

				/*-------------------------------------------------------+
				| ExecAuto MATA381 para zerar os espenhos remanescentes. |
				+-------------------------------------------------------*/
				lRet := MntExecSD4( cOProd, , 0 )[1]

				If !lRet

					DisarmTransaction()

					BREAK

				EndIf

			EndIf

		//END TRANSACTION

	EndIf

Return lRet

static function AdjDtTime()
	local nX 		as numeric
	local nLin		as numeric
	local cCodPrd	as character
	local lSeqIns	:= axItens[1]:hasProperty("TL_INSUMO")
	local nPProd	:= aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_CODIGO" })
	local nPDtIni	:= aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_DTINICI" })
	local nPHrIni	:= aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_HOINICI" })
	local nPDtFin	:= aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_DTFIM" })
	local nPHrFin	:= aScan(aHoBrw2,{|x| Alltrim(Upper(x[2])) == "TL_HOFIM" })

	for nX := 1 to Len(axItens)
		cCodPrd := Alltrim(axItens[nX]["TL_CODIGO"])

		if lSeqIns
			nLin := axItens[nX]["TL_INSUMO"]
		else
			nLin := aScan(aCoBrw2,{|x| Alltrim(x[nPProd]) == cCodPrd })
		endif

		if nLin > 0

			aCoBrw2[nLin][nPDtIni]	:= axItens[nX]["TL_DTINICI"]
			aCoBrw2[nLin][nPHrIni]	:= axItens[nX]["TL_HOINICI"]
			aCoBrw2[nLin][nPDtFin]	:= axItens[nX]["TL_DTFIM"]
			aCoBrw2[nLin][nPHrFin]	:= axItens[nX]["TL_HOFIM"]

		endif
	next nX
return

Static Function f435VlFun(cTmpCod,cTmpOrdem,cTmpPlano,dTmpDtIni,cTmpHoIni,dTmpDtFim,cTmpHoFim,nLineOS,nPosCols,cTipoSTL,lRowCall)
	Local lRet := .T.
	/*
	Local nYY, nXX, nXArq
	Local nPosTip := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_TIPOREG"})
	Local nPosCod := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_CODIGO" })
	Local nPos02 := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_DTINICI"})
	Local nPos03 := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_HOINICI"})
	Local nPos04 := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_DTFIM" })
	Local nPos05 := aScan(aHoBrw2,{|x| Trim(Upper(x[2])) == "TL_HOFIM" })
	Local aVRET  := {.F.," "}
	Local vARQSTL := {}
	Local nQUATISH4 := 0
	Local nQUATFEU  := 1
	Local cOldAlias := Alias()
	Local cAlsTTL   := ''
	Local aAreaSTJ  := STJ->(GetArea())

	Local cAliasQry := ''

	aAdd( vARQSTL , {"STL",8,"STL->TL_FILIAL","STL->TL_CODIGO",;
	"STL->TL_SEQRELA","STL->TL_ORDEM",;
	"STL->TL_PLANO","STL->TL_DTINICI",;
	"STL->TL_DTFIM","STL->TL_HOINICI",;
	"STL->TL_HOFIM","STL->TL_TIPOREG","STL->TL_QUANREC"} )
	aAdd( vARQSTL , {"STT",3,"STT->TT_FILIAL","STT->TT_CODIGO",;
	"STT->TT_SEQRELA","STT->TT_ORDEM",;
	"STT->TT_PLANO","STT->TT_DTINICI",;
	"STT->TT_DTFIM","STT->TT_HOINICI",;
	"STT->TT_HOFIM","STT->TT_TIPOREG","STT->TT_QUANREC"})
	
	If cTipoSTL == "F"
		dbSelectArea("SH4")
		dbSetOrder(1)
		If dbSeek(xFilial("SH4")+SubStr(cTmpCod,1,6))
			nQUATISH4 := SH4->H4_QUANT
		EndIf

	ElseIf cTipoSTL == 'M'

		cAlsTTL := GetNextAlias()
		
		BeginSql Alias cAlsTTL

			SELECT
				TTL.TTL_DTINI,
				TTL.TTL_HRINI,
				TTL.TTL_DTFIM,
				TTL.TTL_HRFIM
			FROM
				%table:TTL% TTL
			WHERE
				TTL.TTL_CODFUN = %exp:cTmpCod% AND
				( ( %exp:dToS( dTmpDtIni )% || %exp:cTmpHoIni% <= TTL.TTL_DTFIM || TTL.TTL_HRFIM ) AND
				  ( %exp:dToS( dTmpDtFim )% || %exp:cTmpHoFim% >= TTL.TTL_DTINI || TTL.TTL_HRINI ) ) AND
				TTL.TTL_FILIAL = %xFilial:TTL% AND
				%NotDel%

		EndSql

		If (cAlsTTL)->( !EoF() )

			cHelpMsg := "Já existe aplicação de insumo no intervalo de Data/Hora informada." + Chr( 13 ) + Chr( 13 ) 
			cHelpMsg += "["+cTmpCod+"]"
			/*+; // Já existe aplicação de insumo no intervalo de Data/Hora informada.
						STR0205 + ': ' + cTmpCod + Chr( 13 ) +; // Código Insumo
						STR0206 + '....: ' + cTmpOrdem + Chr( 13 ) +; // Ordem Serv
						STR0050 + '..............: ' + cTmpPlano + Chr( 13 ) +; // Plano
						STR0200 + '......: ' + dToC( dTmpDtIni ) + Chr( 13 ) +; // Data Inicio
						STR0201 + '......: ' + SubStr( cTmpHoIni, 1, 5 ) + Chr( 13 ) +; // Hora Inicio
						STR0202 + '.........: ' + dToC( dTmpDtFim ) + Chr( 13 ) +; // Data Fim
						STR0203 + '.........: ' + SubStr( cTmpHoFim, 1, 5 ) + Chr( 13 ) + Chr( 13 ) +; // Hora Fim
						STR0387 + Chr( 13 ) + Chr( 13 ) +; // Aplicação do insumo já existente:
						STR0200 + '.....: ' + dToC( sToD( (cAlsTTL)->TTL_DTINI ) ) + Chr( 13 ) +; // Data Inicio
						STR0201 + '.....: ' + SubStr( (cAlsTTL)->TTL_HRINI, 1, 5 ) + Chr( 13 ) +; // Hora Inicio
						STR0202 + '........: ' + dToC( sToD( (cAlsTTL)->TTL_DTFIM ) ) + Chr( 13 ) +; // Data Fim
						STR0203 + '........: ' + SubStr( (cAlsTTL)->TTL_HRFIM, 1, 5 ) // Hora Fim

			aVRet := { .T., cHelpMsg }
			cMsgfValidOK := cHelpMsg
		EndIf

		(cAlsTTL)->( dbCloseArea() )

	EndIf

	If !aVRET[1]

		For nXX := 1 To Len(aDadosOS)

			If nLineOS != nXX .Or. !lRowCall
				If ValType(aDadosOS[nXX,5]) == "A"
					For nYY := 1 To Len(aDadosOS[nXX,5])
						If aDadosOS[nXX,5][nYY,Len(aDadosOS[nXX,5][nYY])]
							Loop //Deletado
						EndIf
						If !lRowCall
							If nLineOS == nXX .And. nPosCols == nYY
								Loop
							EndIf
						EndIf
						If aDadosOS[nXX,5,nYY,nPosTip] == cTipoSTL .And. PadR(aDadosOS[nXX,5,nYY,nPosCod],nLenST1) == Padr(cTmpCod,nLenST1)
							If aDadosOS[nXX,5][nYY,nPos02] == dTmpDtIni .And. aDadosOS[nXX,5][nYY,nPos03] == cTmpHoIni .And. ;
							aDadosOS[nXX,5][nYY,nPos04] == dTmpDtFim .And. aDadosOS[nXX,5][nYY,nPos05] == cTmpHoFim

								If cTipoSTL == "M"
									aVRET := {.T.,"Registro informado ja existe"} //"Registro informado ja existe"
									Exit
								ElseIf cTipoSTL == "F"
									nQUATFEU++
									If nQUATFEU > nQUATISH4
										cHelpMsg := "Não há disponibilidade da ferramenta no intervalo:"/* + chr(13)+chr(13); //"Não há disponibilidade da ferramenta no intervalo:"
										+STR0200 + ".....: " + dtoc(dTmpDtIni)+chr(13); //"Data Inicio"
										+STR0201 + ".....: " + Substr(cTmpHoIni,1,5)+chr(13); //"Hora Inicio"
										+STR0202 + "........: " + dtoc(dTmpDtFim)+chr(13); //"Data Fim"
										+STR0203 + "........: " + Substr(cTmpHoFim,1,5) //"Hora Fim"
										aVRET := {.T.,cHelpMsg}
										cMsgfValidOK := cHelpMsg
										Exit
									EndIf
								EndIf

							ElseIf DtoS(dTmpDtIni)+cTmpHoIni < DtoS(aDadosOS[nXX,5][nYY,nPos04])+aDadosOS[nXX,5][nYY,nPos05] .And.;
								DtoS(dTmpDtFim)+cTmpHoFim > DtoS(aDadosOS[nXX,5][nYY,nPos02])+aDadosOS[nXX,5][nYY,nPos03]

								If cTipoSTL == "M"
									cHelpMsg := "Já existe aplicação de insumo no intervalo de Data/Hora informada."/*+ chr(13)+chr(13); //"Já existe aplicação de insumo no intervalo de Data/Hora informada."
									+ STR0205 + ": " + cTmpCod + chr(13); //"Código Insumo"
									+ STR0206 + "....: " + cTmpOrdem + chr(13); //"Ordem Serv"
									+ STR0050 + "..............: " + cTmpPlano + chr(13); //"Plano"
									+ STR0200 + "......: " + dtoc(dTmpDtIni) + chr(13); //"Data Inicio"
									+ STR0201 + "......: " + Substr(cTmpHoIni,1,5) + chr(13); //"Hora Inicio"
									+ STR0202 + ".........: " + dtoc(dTmpDtFim) + chr(13); //"Data Fim"
									+ STR0203 + ".........: " + Substr(cTmpHoFim,1,5) + chr(13)+chr(13); //"Hora Fim"
									+ STR0207 + chr(13)+chr(13); //"Aplicação do insumo já existente:"
									+ STR0206 + "....: " + aDadosOS[nXX,1] + chr(13); //"Ordem Serv"
									+ STR0050 + ".............: " + aDadosOS[nXX,2] + chr(13); //"Plano"
									+ STR0200 + ".....: " + dtoc(aDadosOS[nXX,5][nYY,nPos02]) + chr(13); //"Data Inicio"
									+ STR0201 + ".....: " + Substr(aDadosOS[nXX,5][nYY,nPos03],1,5) + chr(13); //"Hora Inicio"
									+ STR0202 + "........: " + dtoc(aDadosOS[nXX,5][nYY,nPos04]) + chr(13); //"Data Fim"
									+ STR0203 + "........: " + Substr(aDadosOS[nXX,5][nYY,nPos05],1,5) //"Hora Fim"
									aVRET := {.T.,cHelpMsg}
									cMsgfValidOK := cHelpMsg
									Exit
								ElseIf cTipoSTL == "F"
									nQUATFEU++
									If nQUATFEU > nQUATISH4
										cHelpMsg := "Não há disponibilidade da ferramenta no intervalo:"/* + chr(13)+chr(13); //"Não há disponibilidade da ferramenta no intervalo:"
										+STR0200 + ".....: " + dtoc(dTmpDtIni)+chr(13); //"Data Inicio"
										+STR0201 + ".....: " + Substr(cTmpHoIni,1,5)+chr(13); //"Hora Inicio"
										+STR0202 + "........: " + dtoc(dTmpDtFim)+chr(13); //"Data Fim"
										+STR0203 + "........: " + Substr(cTmpHoFim,1,5) //"Hora Fim"
										aVRET := {.T.,cHelpMsg}
										cMsgfValidOK := cHelpMsg
										Exit
									EndIf
								EndIf
							EndIf
						EndIf
					Next nYY
				ElseIf ValType(aDadosOS[nXX,4]) == "A" .And. lRowCall
					For nYY := 1 To Len(aDadosOS[nXX,4])
						If aDadosOS[nXX,4][nYY,Len(aDadosOS[nXX,4][nYY])]
							Loop //Deletado
						EndIf
						If aDadosOS[nXX,4,nYY,nPosTip] == cTipoSTL .And. PadR(aDadosOS[nXX,4,nYY,nPosCod],nLenST1) == PadR(cTmpCod,nLenST1)
							If aDadosOS[nXX,4][nYY,nPos02] == dTmpDtIni .And. aDadosOS[nXX,4][nYY,nPos03] == cTmpHoIni .And. ;
							aDadosOS[nXX,4][nYY,nPos04] == dTmpDtFim .And. aDadosOS[nXX,4][nYY,nPos05] == cTmpHoFim

								If cTipoSTL == "M"
									aVRET := {.T.,"Registro informado ja existe"} //"Registro informado ja existe"
									cMsgfValidOK := cHelpMsg
									Exit
								ElseIf cTipoSTL == "F"
									nQUATFEU++
									If nQUATFEU > nQUATISH4
										cHelpMsg := "Não há disponibilidade da ferramenta no intervalo:"/* + chr(13)+chr(13); //"Não há disponibilidade da ferramenta no intervalo:"
										+STR0200 + ".....: " + dtoc(dTmpDtIni)+chr(13); //"Data Inicio"
										+STR0201 + ".....: " + Substr(cTmpHoIni,1,5)+chr(13); //"Hora Inicio"
										+STR0202 + "........: " + dtoc(dTmpDtFim)+chr(13); //"Data Fim"
										+STR0203 + "........: " + Substr(cTmpHoFim,1,5) //"Hora Fim"
										aVRET := {.T.,cHelpMsg}
										cMsgfValidOK := cHelpMsg
										Exit
									EndIf
								EndIf

							ElseIf DtoS(dTmpDtIni)+cTmpHoIni < DtoS(aDadosOS[nXX,4][nYY,nPos04])+aDadosOS[nXX,4][nYY,nPos05] .And.;
							DtoS(dTmpDtFim)+cTmpHoFim > DtoS(aDadosOS[nXX,4][nYY,nPos02])+aDadosOS[nXX,4][nYY,nPos03]

								If cTipoSTL == "M"
									cHelpMsg := "Já existe aplicação de insumo no intervalo de Data/Hora informada."/*+ chr(13)+chr(13); //"Já existe aplicação de insumo no intervalo de Data/Hora informada."
									+ STR0205 + ": " + cTmpCod + chr(13); //"Código Insumo"
									+ STR0206 + "....: " + cTmpOrdem + chr(13); //"Ordem Serv"
									+ STR0050 + "..............: " + cTmpPlano + chr(13); //"Plano"
									+ STR0200 + "......: " + dtoc(dTmpDtIni) + chr(13); //"Data Inicio"
									+ STR0201 + "......: " + Substr(cTmpHoIni,1,5) + chr(13); //"Hora Inicio"
									+ STR0202 + ".........: " + dtoc(dTmpDtFim) + chr(13); //"Data Fim"
									+ STR0203 + ".........: " + Substr(cTmpHoFim,1,5) + chr(13)+chr(13); //"Hora Fim"
									+ STR0207 + chr(13)+chr(13); //"Aplicação do insumo já existente:"
									+ STR0206 + "....: " + aDadosOS[nXX,1] + chr(13); //"Ordem Serv"
									+ STR0050 + ".............: " + aDadosOS[nXX,2] + chr(13); //"Plano"
									+ STR0200 + ".....: " + dtoc(aDadosOS[nXX,4][nYY,nPos02]) + chr(13); //"Data Inicio"
									+ STR0201 + ".....: " + Substr(aDadosOS[nXX,4][nYY,nPos03],1,5) + chr(13); //"Hora Inicio"
									+ STR0202 + "........: " + dtoc(aDadosOS[nXX,4][nYY,nPos04]) + chr(13); //"Data Fim"
									+ STR0203 + "........: " + Substr(aDadosOS[nXX,4][nYY,nPos05],1,5) //"Hora Fim"
									cMsgfValidOK := cHelpMsg
									aVRET := {.T.,cHelpMsg}
									Exit
								ElseIf cTipoSTL == "F"
									nQUATFEU++
									If nQUATFEU > nQUATISH4
										cHelpMsg := "Não há disponibilidade da ferramenta no intervalo:"/* + chr(13)+chr(13); //"Não há disponibilidade da ferramenta no intervalo:"
										+STR0200 + ".....: " + dtoc(dTmpDtIni)+chr(13); //"Data Inicio"
										+STR0201 + ".....: " + Substr(cTmpHoIni,1,5)+chr(13); //"Hora Inicio"
										+STR0202 + "........: " + dtoc(dTmpDtFim)+chr(13); //"Data Fim"
										+STR0203 + "........: " + Substr(cTmpHoFim,1,5) //"Hora Fim"
										aVRET := {.T.,cHelpMsg}
										cMsgfValidOK := cHelpMsg
										Exit
									EndIf
								EndIf
							EndIf
						EndIf
					Next nYY
				EndIf
			Else
				For nYY := 1 To Len(aCols)
					If aCols[nYY,Len(aCols[nYY])]
						Loop //Deletado
					EndIf
					If aCols[nYY,nPosTip] == cTipoSTL .And. nYY <> nPosCols .And. PadR(aCols[nYY,nPosCod],nLenST1) == PadR(cTmpCod,nLenST1)
						If aCols[nYY,nPos02] == dTmpDtIni .And. aCols[nYY,nPos03] == cTmpHoIni .And. ;
						aCols[nYY,nPos04] == dTmpDtFim .And. aCols[nYY,nPos05] == cTmpHoFim

							If cTipoSTL == "M"
								aVRET := {.T.,"Registro informado ja existe"} //"Registro informado ja existe"
								cMsgfValidOK := "Registro informado ja existe"
								Exit
							ElseIf cTipoSTL == "F"
								nQUATFEU++
								If nQUATFEU > nQUATISH4
									cHelpMsg := "Não há disponibilidade da ferramenta no intervalo:" + chr(13)+chr(13)/*; //"Não há disponibilidade da ferramenta no intervalo:"
									+STR0200 + ".....: " + dtoc(dTmpDtIni)+chr(13); //"Data Inicio"
									+STR0201 + ".....: " + Substr(cTmpHoIni,1,5)+chr(13); //"Hora Inicio"
									+STR0202 + "........: " + dtoc(dTmpDtFim)+chr(13); //"Data Fim"
									+STR0203 + "........: " + Substr(cTmpHoFim,1,5) //"Hora Fim"
									aVRET := {.T.,cHelpMsg}
									cMsgfValidOK := cHelpMsg
									Exit
								EndIf
							EndIf

						ElseIf DtoS(dTmpDtIni)+cTmpHoIni < DtoS(aCols[nYY,nPos04])+aCols[nYY,nPos05] .And.;
						DtoS(dTmpDtFim)+cTmpHoFim > DtoS(aCols[nYY,nPos02])+aCols[nYY,nPos03]

							If cTipoSTL == "M"
								cHelpMsg := "Já existe aplicação de insumo no intervalo de Data/Hora informada."/*+ chr(13)+chr(13); //"Já existe aplicação de insumo no intervalo de Data/Hora informada."
								+ STR0205 + ": " + cTmpCod + chr(13); //"Código Insumo"
								+ STR0206 + "....: " + cTmpOrdem + chr(13); //"Ordem Serv"
								+ STR0050 + "..............: " + cTmpPlano + chr(13); //"Plano"
								+ STR0200 + "......: " + dtoc(dTmpDtIni) + chr(13); //"Data Inicio"
								+ STR0201 + "......: " + Substr(cTmpHoIni,1,5) + chr(13); //"Hora Inicio"
								+ STR0202 + ".........: " + dtoc(dTmpDtFim) + chr(13); //"Data Fim"
								+ STR0203 + ".........: " + Substr(cTmpHoFim,1,5) + chr(13)+chr(13); //"Hora Fim"
								+ STR0207 + chr(13)+chr(13); //"Aplicação do insumo já existente:"
								+ STR0206 + "....: " + cTmpOrdem + chr(13); //"Ordem Serv"
								+ STR0050 + ".............: " + cTmpPlano + chr(13); //"Plano"
								+ STR0200 + ".....: " + dtoc(aCols[nYY,nPos02]) + chr(13); //"Data Inicio"
								+ STR0201 + ".....: " + Substr(aCols[nYY,nPos03],1,5) + chr(13); //"Hora Inicio"
								+ STR0202 + "........: " + dtoc(aCols[nYY,nPos04]) + chr(13); //"Data Fim"
								+ STR0203 + "........: " + Substr(aCols[nYY,nPos05],1,5) //"Hora Fim"
								aVRET := {.T.,cHelpMsg}
								cMsgfValidOK := cHelpMsg
								Exit
							ElseIf cTipoSTL == "F"
								nQUATFEU++
								If nQUATFEU > nQUATISH4
									cHelpMsg := "Não há disponibilidade da ferramenta no intervalo:" + chr(13)+chr(13)/*; //"Não há disponibilidade da ferramenta no intervalo:"
									+STR0200 + ".....: " + dtoc(dTmpDtIni)+chr(13); //"Data Inicio"
									+STR0201 + ".....: " + Substr(cTmpHoIni,1,5)+chr(13); //"Hora Inicio"
									+STR0202 + "........: " + dtoc(dTmpDtFim)+chr(13); //"Data Fim"
									+STR0203 + "........: " + Substr(cTmpHoFim,1,5) //"Hora Fim"
									aVRET := {.T.,cHelpMsg}
									cMsgfValidOK := cHelpMsg
									Exit
								EndIf
							EndIf
						EndIf
					EndIf
				Next nYY
			EndIf

			If aVRET[1]
				Exit
			EndIf
		Next nXX

	EndIf

	If !aVRET[1]
		For nXArq := 1 to 2
			If nXArq == 1

				cAliasQry	:= GetNextAlias()
				cQuery		:= " SELECT STL.TL_ORDEM,"
				cQuery		+= "	STL.TL_PLANO, "
				cQuery		+= "    STL.TL_DTINICI, "
				cQuery		+= "    STL.TL_HOINICI, "
				cQuery		+= "    STL.TL_DTFIM, "
				cQuery		+= "    STL.TL_HOFIM, "
				cQuery		+= "    STL.TL_TIPOREG "
				cQuery		+= " FROM " +RetSqlName("STL")+ " STL "
				cQuery		+= " JOIN " + RetSqlName("STJ")+" STJ ON  STL.TL_ORDEM = STJ.TJ_ORDEM "
				cQuery		+= " AND STL.TL_PLANO = STJ.TJ_PLANO AND STJ.D_E_L_E_T_ = ' ' "
				cQuery		+= " WHERE STL.TL_FILIAL = '" +xFilial("STL")+ "' "
				cQuery		+= " AND (STL.TL_TIPOREG = 'M' OR  STL.TL_TIPOREG = 'F') "
				cQuery		+= " AND STL.TL_CODIGO = '"+cTmpCod+ "'"
				cQuery		+= " AND STL.TL_SEQRELA <> '0'
				cQuery		+= " AND ( '" +DtoS(dTmpDtIni)+cTmpHoIni+ "' < (STL.TL_DTFIM || STL.TL_HOFIM)
				cQuery		+= "	AND  '"+DtoS(dTmpDtFim)+cTmpHoFim+ "' >  (STL.TL_DTINICI || STL.TL_HOINICI) )
				cQuery		+= " AND STJ.TJ_SITUACA <> 'C'
				cQuery		+= " AND STL.D_E_L_E_T_ = ' ' "

			Else

				cAliasQry	:= GetNextAlias()

				cQuery		:= " SELECT STT.TT_ORDEM TL_ORDEM,"
				cQuery		+= "	STT.TT_PLANO TL_PLANO, "
				cQuery		+= "    STT.TT_DTINICI TL_DTINICI, "
				cQuery		+= "    STT.TT_HOINICI TL_HOINICI, "
				cQuery		+= "    STT.TT_DTFIM TL_DTFIM, "
				cQuery		+= "    STT.TT_HOFIM TL_HOFIM, "
				cQuery		+= "    STT.TT_TIPOREG TL_TIPOREG "
				cQuery		+= " FROM " +RetSqlName("STT")+ " STT "
				cQuery		+= " JOIN " + RetSqlName("STS")+" STS ON  STT.TT_ORDEM = STS.TS_ORDEM "
				cQuery		+= " AND STT.TT_PLANO = STS.TS_PLANO AND STS.D_E_L_E_T_ = ' ' "
				cQuery		+= " WHERE STT.TT_FILIAL = '" +xFilial("STT")+ "' "
				cQuery		+= " AND (STT.TT_TIPOREG = 'M' OR  STT.TT_TIPOREG = 'F') "
				cQuery		+= " AND STT.TT_CODIGO = '"+cTmpCod+ "'"
				cQuery		+= " AND STT.TT_SEQRELA <> '0'
				cQuery		+= " AND ( '" +DtoS(dTmpDtIni)+cTmpHoIni+ "' < (STT.TT_DTFIM || STT.TT_HOFIM)
				cQuery		+= "	AND  '"+DtoS(dTmpDtFim)+cTmpHoFim+ "' >  (STT.TT_DTINICI || STT.TT_HOINICI) )
				cQuery		+= " AND STS.TS_SITUACA <> 'C'
				cQuery		+= " AND STT.D_E_L_E_T_ = ' ' "

			EndIf

			cQuery		:= ChangeQuery( cQuery )
			dbUseArea(	.T., "TOPCONN", TCGENQRY( , , cQuery ), cAliasQry, .F., .T. )

			While !Eof()

				nLineTmp := aScan(aDadosOS, {|x| x[1]+x[2] == (cAliasQry)->TL_ORDEM+(cAliasQry)->TL_PLANO })
				If nLineTmp > 0
					If lRowCall
						If ValType(aDadosOS[nLineTmp,4]) == "A" .Or. ValType(aDadosOS[nLineTmp,5]) == "A" .Or. nLineOS == nLineTmp
							dbSelectArea(cAliasQry)
							dbSkip()
							Loop
						EndIf
					Else
						If ValType(aDadosOS[nLineTmp,5]) == "A" .Or. nLineOS == nLineTmp
							dbSelectArea(cAliasQry)
							dbSkip()
							Loop
						EndIf
					EndIf
				EndIf

				If (cAliasQry)->TL_TIPOREG == "M"

					cHelpMsg := "Já existe aplicação de insumo no intervalo de Data/Hora informada."
					/*+ chr(13)+chr(13); //"Já existe aplicação de insumo no intervalo de Data/Hora informada."
					+"Código Insumo: " + cTmpCod + chr(13); //"Código Insumo"
					+"Ordem Serv....: " + cTmpOrdem + chr(13); //"Ordem Serv"
					+"Plano..............: " + cTmpPlano + chr(13); //"Plano"
					+ STR0200 + "......: " + dtoc(dTmpDtIni) + chr(13); //"Data Inicio"
					+ STR0201 + "......: " + Substr(cTmpHoIni,1,5) + chr(13); //"Hora Inicio"
					+ STR0202 + ".........: " + dtoc(dTmpDtFim) + chr(13); //"Data Fim"
					+ STR0203 + ".........: " + Substr(cTmpHoFim,1,5) + chr(13)+chr(13); //"Hora Fim"
					+ STR0207 + chr(13)+chr(13); //"Aplicação do insumo já existente:"
					+ STR0206 + "....: " + (cAliasQry)->TL_ORDEM + chr(13); //"Ordem Serv"
					+ STR0050 + ".............: " + (cAliasQry)->TL_PLANO + chr(13); //"Plano"
					+ STR0200 + ".....: " + dtoc(StoD((cAliasQry)->TL_DTINICI)) + chr(13); //"Data Inicio"
					+ STR0201 + ".....: " + Substr((cAliasQry)->TL_HOINICI,1,5) + chr(13); //"Hora Inicio"
					+ STR0202 + "........: " + dtoc(StoD((cAliasQry)->TL_DTFIM)) + chr(13); //"Data Fim"
					+ STR0203 + "........: " + Substr((cAliasQry)->TL_HOFIM,1,5) //"Hora Fim"
					aVRET := {.T.,cHelpMsg}
					cMsgfValidOK := cHelpMsg
					Exit
				ElseIf (cAliasQry)->TL_TIPOREG == "F"
					nQUATFEU++
					If nQUATFEU > nQUATISH4
						cHelpMsg := "Não há disponibilidade da ferramenta no intervalo:" /*+ chr(13)+chr(13); //"Não há disponibilidade da ferramenta no intervalo:"
						+"Data Inicio.....: " + dtoc(dTmpDtIni)+chr(13); //"Data Inicio"
						+"Hora Inicio.....: " + Substr(cTmpHoIni,1,5)+chr(13); //"Hora Inicio"
						+"Data Fim........: " + dtoc(dTmpDtFim)+chr(13); //"Data Fim"
						+"Hora Fim........: " + Substr(cTmpHoFim,1,5) //"Hora Fim"
						aVRET := {.T.,cHelpMsg}
						cMsgfValidOK := cHelpMsg
						Exit
					EndIf
				EndIf

				dbSelectArea( cAliasQry )
				dbSkip()
			End

			If aVRET[1]
				Exit
			EndIf

			(cAliasQry)->( DbCloseArea() )

		Next nXArq
	EndIf

	If aVRET[1]
		//MsgInfo(aVRET[2],"Atenção") //"Atenção"
		Varinfo("Atenção",aVRET[2])
		lRet := .F.
	EndIf

	PutFileInEof("STL")
	RestArea(aAreaSTJ)
	dbSelectArea(cOldAlias)
		*/
Return lRet

Static Function MNT435CANB(cKeySTL)

	Local lCanScan := Type("aNBaixaEst") == "A" .And. Len( aNBaixaEst ) > 0
	Local lRet     := .T.

	Default cKeySTL := STL->TL_ORDEM + STL->TL_PLANO + STL->TL_SEQRELA + STL->TL_TAREFA + STL->TL_TIPOREG + STL->TL_CODIGO

	lRet := !lCanScan .Or. ( aScan( aNBaixaEst,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] == cKeySTL }) == 0)

Return lRet

Static Function fNgGarDelete(cOrdem,cPlano,cTL_SEQRELA)

	dbSelectArea("TPZ")
	dbSetOrder(2)
	If dbSeek(xFilial("TPZ")+cOrdem+cPlano+cTL_SEQRELA)
		While !EoF() .And. TPZ->(TPZ_FILIAL+TPZ_ORDEM+TPZ_PLANO+TPZ_SEQREL) == xFilial("TPZ")+cOrdem+cPlano+cTL_SEQRELA
			RecLock("TPZ",.F.)
			DbDelete()
			TPZ->(MsUnLock())
			TPZ->(dbSkip())
		End
	EndIf

Return .T.

Static Function fNGFECHASS(cVORDFSS,lMsgTela)

	Local cSolici
	Local aOldNGBtn
	Local nOS     := 0
	Local aAreaSS := GetArea()
	Local cMsg    := ""
	Local lFinSS  := .F. // Váriavel que define se apresentará a tela de finalização da SS - É mudada apenas no PE MNTA400N

	Private aNgButton

	Default lMsgTela := .F.

	dbSelectArea("STJ")
	dbSetOrder(1)
	dbSeek(xFilial("STJ")+cVORDFSS)

	If AllTrim(GetNewPar("MV_NGSSWRK","N")) == "S"
		If AllTrim(GetNewPar("MV_NGMULOS","N")) <> "S"
			dbSelectArea("TQB")
			dbSetOrder(04)
			If dbSeek(xFilial("TQB")+cVORDFSS)
				MNW29502(TQB->TQB_CDSOLI)
			EndIf
		Else
			dbSelectArea("TT7")
			dbSetOrder(2)
			If dbSeek(xFilial("TT7")+cVORDFSS)
				dbSelectArea("TQB")
				dbSetOrder(1)
				dbSeek(xFilial("TQB")+TT7->TT7_SOLICI)
				MNW29502(TQB->TQB_CDSOLI)
			EndIf
		EndIf
	EndIf

		aOldNGBtn := If(Type("aNGButton") == "A",ACLONE(aOldNGBtn),{})
		aNgButton := {}

		If ExistBlock("MNTA4012")
			ExecBlock("MNTA4012",.F.,.F.)
		ElseIf !Empty(cVORDFSS)
			If AllTrim(GetNewPar("MV_NGMULOS","N")) <> "S"
				dbSelectArea("TQB")
				dbSetOrder(04)
				If dbSeek(xFilial("TQB")+cVORDFSS)
					If TQB->TQB_SOLUCA == "D"

						//Ponto de entrada para não apresentar tela de finalização de SS.
						//If ExistBlock("MNTA400N")
						//	lFinSS := ExecBlock("MNTA400N",.F.,.F.)
						//EndIf

						If lFinSS
						//	MNTA290FEC(STR0149+" "+cVORDFSS, 3)
						EndIf

					Else
						cMsg := "'"+NGRETTITULO("TQB_SOLUCA")+"' "+"da SS "+cVORDFSS+" não está como"+" '"+NGRETSX3BOX("TQB_SOLUCA","D")+"'."  //"da SS "##" não está como"
					EndIf
				Else
					cMsg := "Não existe SS para a OS "+cVORDFSS+"."  //"Não existe SS para a OS "
				EndIf
			Else
				dbSelectArea("TT7")
				dbSetOrder(2)
				If dbSeek(xFilial("TT7")+cVORDFSS)
					cSolici := TT7->TT7_SOLICI
					RecLock("TT7",.F.)
					TT7->TT7_TERMIN := "S"
					MsUnLock("TT7")

					dbSelectArea("TT7")
					dbSetOrder(1)
					dbSeek(xFilial("TT7")+cSolici)
					While !EoF() .And. TT7->TT7_FILIAL == xFilial("TT7") .And. TT7->TT7_SOLICI == cSolici
						dbSelectArea("STJ")
						dbSetOrder(1)
						dbSeek(xFilial("STJ")+TT7->TT7_ORDEM)
						If STJ->TJ_TERMINO == "N"
							nOS++
						EndIf
						dbSelectArea("TT7")
						dbSkip()
					End
					If nOs == 0
						dbSelectArea("TQB")
						dbSetOrder(01)
						If dbSeek(xFilial("TQB")+cSolici)
							If TQB->TQB_SOLUCA = "D"

								//Ponto de entrada para não apresentar tela de finalização de SS.
								//If ExistBlock("MNTA400N")
								//	lFinSS := ExecBlock("MNTA400N",.F.,.F.)
								//EndIf

								If lFinSS
								//	MNTA290FEC(STR0149+" "+cSolici, 3)
								EndIf

							EndIf
						EndIf
					Else
						cMsg := "Ainda existe ao menos uma O.S. não terminada para a SS "+cSolici+"."  //"Ainda existe ao menos uma O.S. não terminada para a SS "
					EndIf
				Else
					cMsg := "Não existe SS para a OS "+cVORDFSS+"."  //"Não existe SS para a OS "
				EndIf
			EndIf
		EndIf

		If lMsgTela .And. !Empty(cMsg)
			Conout(cMsg)
		EndIF

		aNgButton := aClone(aOldNGBtn)

	RestArea(aAreaSS)

Return cMsg

Static Function fLegendEt( cChave, nIndic )

	Local cCodFam	:= ""
	Local cTempMed	:= ""
	Local aAreaSTQ  := STQ->( FWGetArea() )
	Local aAreaSTL  := STL->( FWGetArea() )
	Local aAreaTRB  := (cTRBQ400)->( FWGetArea() )

	Default nIndic  := 2 // TQ_TAREFA + TQ_ETAPA + TQ_SEQETA

	dbSelectarea( cTRBQ400 )
	dbSetOrder( nIndic )
	msSeek( cChave )

	cCodFam  := NGSEEK("ST9", STJ->TJ_CODBEM, 1, "T9_CODFAMI")
	cTempMed := NGSEEK("TVT", cCodFam + (cTRBQ400)->TQ_ETAPA, 2, "TVT_TEMPO")
	cTempMed := Val(cTempMed)

	RecLock(cTRBQ400, .F.)
	dbSelectArea("STL")
	dbSetOrder(1)
	If dbSeek(xFilial("STL")+(cTRBQ400)->TQ_ORDEM + (cTRBQ400)->TQ_PLANO + (cTRBQ400)->TQ_TAREFA + "M")
		(cTRBQ400)->QUANTID := 0
		(cTRBQ400)->SEQRELA := 0
		While !EoF() .And. STL->TL_FILIAL == xFilial("STL") .And. STL->TL_ORDEM == (cTRBQ400)->TQ_ORDEM .And. STL->TL_PLANO == (cTRBQ400)->TQ_PLANO;
				.And. STL->TL_TAREFA == (cTRBQ400)->TQ_TAREFA .And. STL->TL_TIPOREG == "M"

			If STL->TL_ETAPA != (cTRBQ400)->TQ_ETAPA .Or. STL->TL_SEQRELA == '0'
				dbSelectArea("STL")
				dbSkip()
				Loop
			EndIf

			dbSelectArea( cTRBQ400 )
			dbSetOrder( nIndic )
			If msSeek( cChave )
				(cTRBQ400)->QUANTID	+= STL->TL_QUANTID
			Else
				(cTRBQ400)->QUANTID	:= STL->TL_QUANTID
			EndIf

			(cTRBQ400)->SEQRELA	:= Val(STL->TL_SEQRELA)

			dbSelectArea("STL")
			dbSkip()

		EndDo
		If !Empty((cTRBQ400)->TQ_OK)
			(cTRBQ400)->STATUS := '1'
		ElseIf Empty((cTRBQ400)->TQ_OK) .And. (cTRBQ400)->SEQRELA != 0 .And. !Empty(cTempMed)
			If (cTRBQ400)->QUANTID	<= cTempMed
				(cTRBQ400)->STATUS := '3'
			Else
				(cTRBQ400)->STATUS := '4'
			EndIf
		ElseIf Empty((cTRBQ400)->TQ_OK) .And. (cTRBQ400)->SEQRELA != 0 .And. Empty(cTempMed)
			(cTRBQ400)->STATUS := '2'
		ElseIf Empty((cTRBQ400)->TQ_OK)
			(cTRBQ400)->STATUS := '2'
		EndIf
	Else

		dbSelectArea( cTRBQ400 )
		dbSetOrder( nIndic )
		If msSeek( cChave )

			If !Empty((cTRBQ400)->TQ_OK)
				(cTRBQ400)->STATUS := '1'
			ElseIf Empty((cTRBQ400)->TQ_OK)
				(cTRBQ400)->STATUS := '2'
			EndIf

		EndIf

	EndIf

	(cTRBQ400)->(MsUnlock())

	FWRestArea( aAreaTRB )
	FWRestArea( aAreaSTL )
	FWRestArea( aAreaSTQ )

Return

//-------------------------------
// [FIM] PROCESSOS PARA MNTA435
//-------------------------------
Static Function RetInfCp(cSCPCMP,cSCPINFO,cSCPRET)
	Local aArea     := GetArea()
  	Local cAliasSCP := GetNextAlias()
  	Local cQuery    := ""
	Local cCampo   := ""
	Local nInfo     := 0
	Local xRet      := Nil
	
	Default cSCPCMP := ""
	Default cSCPINFO:= ""
	Default cSCPRET := ""

	aCmp := StrTokArr2( cSCPCMP, "#" )
	aInfo:= StrTokArr2( cSCPINFO, "#" )
	cCampo := cSCPRET
	If !Empty(cSCPCMP) .And. !Empty(cSCPINFO) .And. !Empty(cSCPRET) 
		cQuery := " SELECT "+cCampo
		cQuery += "   FROM "+RetSqlName("SCP")+" SCP (NOLOCK)"
		cQuery += "  WHERE SCP.D_E_L_E_T_ = '' "
		For nInfo:= 1 to Len(aInfo)
			cQuery += " AND "+aCmp[nInfo]+" = '"+Alltrim(aInfo[nInfo])+"' "
		Next nInfo
		cQuery := ChangeQuery(cQuery)
		VarInfo("cQuery-SCP",cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSCP, .F., .T.)
		(cAliasSCP)->(DbGoTop())
		If (cAliasSCP)->(!EoF())
			If FWSX3Util():GetFieldType(cCampo) == "D"
               xRet := StoD((cAliasSCP)->&(cCampo))
			Else
				xRet := (cAliasSCP)->&(cCampo)
			EndIf
		Else
			If FWSX3Util():GetFieldType(cCampo) == "N"
               xRet := 0
        	ElseIf FWSX3Util():GetFieldType(cCampo) == "D"
               xRet := StoD(Space(8))
        	ElseIf FWSX3Util():GetFieldType(cCampo) == "C"
                xRet := ""
            EndIf
		EndIf
		VarInfo("cQuery-SCP-xRet",xRet)
		(cAliasSCP)->(DbCloseArea())
	EndIf
	RestArea(aArea)
	
Return xRet

//-- Validação de turnos
Static Function APIcalend(cCod)
	Local aDIA    := {}, Hor, Qtd, Pos := 1, INI, FIM, Dia, Tot,x, i
	Local aOCI    := {}, lSIMULT := .T.

	SH7->(DbSetOrder(1))
	SH7->(DbSeek(xFilial("SH7")))
	If !SH7->(DbSeek(xFilial("SH7") + cCod))
		Return aDIA
	EndIf

	aDia := {}
	Hor  := sh7->h7_aloc
	Qtd  := Len(Hor)/7

	///nPreSel := Posicione("SX1",1,"MTA78001","X1_PRESEL") //X1_GRUPO

	//If !Empty(nPreSel) .And. nPreSel != 1
	//	lSIMULT := .F.
	//EndIf

	Rep := SubStr(Hor,pos,qtd)
	For i := 1 to 7
		Dia := SubStr(Hor,pos,qtd)
		Tot := 0
		Ini := 999
		Fim := 0
		pos+= qtd
		aOCI:= {}
		nOI := 999
		nOF := 0
		If (i < 6) .and. lSIMULT
			//Dia := Rep
		Endif
		For x := 1 to Len(Dia)
			If !Empty(SubStr(DIa,x,1))
				Tot += (1440/Len(Dia))
				Fim := ( (1440/Len(Dia)) * x )
				Ini := If(Ini == 999,(Fim - (1440/Len(Dia))),Ini)
				If nOI != 999
					AAdd(aOCI,{nOI, nOF})
					nOI := 999
					nOF := 0
				EndIf
			Else
				nOF := ( (1440/Len(Dia)) * x )
				nOI := If(nOI == 999,(nOF - (1440/Len(Dia))),nOI)
			Endif
		Next
		If nOI != 999
			AAdd(aOCI,{nOI, nOF})
			nOI := 999
			nOF := 0
		EndIf
		Ini := If(Ini == 999,0,Ini)
		AAdd(aDia,{MtoH(INI), MtoH(FIM), MtoH(TOT), aOCI })
	Next

Return aDIA

Static function RetTLSQTAR(cFil,cOS,cPLN,cTIPOREG,cCODIGO)

	Local aArea     := GetArea()
  	Local cAliasSTL := GetNextAlias()
  	Local cQuery    := ""
	Local cRet := ""
	
	Default cFil := ""
	Default cOS  := ""
	Default cPLN := ""
	Default cTIPOREG := ""
	Default cCODIGO  := ""

	If !Empty(cFil) .And. !Empty(cOS) .And. !Empty(cPLN) 
		cQuery := " SELECT TOP(1) TL_SEQTARE "
		cQuery += "   FROM "+RetSqlName("STL")+" STL (NOLOCK)"
		cQuery += "  WHERE STL.TL_FILIAL = '"+cFil+"' "
		cQuery += "    AND STL.TL_ORDEM = '"+cOS+"' "
		cQuery += "    AND STL.TL_PLANO = '"+cPLN+"' "
		cQuery += "    AND STL.TL_TIPOREG = '"+cTIPOREG+"' "
		cQuery += "    AND STL.TL_CODIGO = '"+cCODIGO+"' "
		cQuery += " ORDER BY STL.R_E_C_N_O_ DESC"

		cQuery := ChangeQuery(cQuery)
		VarInfo("cQuery-STL-TL_SEQTARE",cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSTL, .F., .T.)
		(cAliasSTL)->(DbGoTop())
		If (cAliasSTL)->(!EoF())
			cRet := Soma1(Alltrim((cAliasSTL)->TL_SEQTARE))
		Else
			cRet := "001"	
		EndIf
		VarInfo("cQuery-STL-cRet",cRet)
		(cAliasSTL)->(DbCloseArea())
	EndIf
	RestArea(aArea)
	
Return cRet
