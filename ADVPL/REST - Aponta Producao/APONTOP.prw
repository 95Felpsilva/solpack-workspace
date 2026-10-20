#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#Include 'FWMVCDEF.ch'
#Include "RestFul.CH"
#INCLUDE "TOPCONN.CH"
#include "rwmake.ch"
#include "tbiconn.ch"

/*=========================================================================//
// Programa  | APONTOP  | Autor | Rafael C Augusto	 | Data |  11/05/2022  //
//=========================================================================//
// Descricao | Criando uma função para que o PRW possa ser compilado       //
//           | Dummy Function - Funcao Fantasma.                           //
//=========================================================================//
// Uso       | Protheus - Solpack - CRM Services                           //
//=========================================================================//
//=========================================================================*/

User Function APONTOP()
Return

//=========================================================================//
// WSRESTFUL - Criando a estrutura do webservice		                       //
//=========================================================================//

WSRESTFUL XUSERS DESCRIPTION "Serviço REST para exibir os dados dos usuarios logados"
	WSMETHOD GET DESCRIPTION "Serviço REST para exibir os dados dos usuarios logados" WSSYNTAX "/REST/XUSERS || /REST/XUSERS"
END WSRESTFUL

WSRESTFUL PRODUCAO DESCRIPTION "Serviço REST para inclusão e consulta da Produção - OP" FORMAT "APPLICATION/JSON"
	WSMETHOD POST DESCRIPTION "Lança produção e retorna a confirmação" 	WSSYNTAX "/REST/PRODUCAO"
	WSMETHOD GET DESCRIPTION "Lista os dados da Ordem de Produção" 	WSSYNTAX "/REST/PRODUCAO || /REST/PRODUCAO/{cNumOP}"
END WSRESTFUL

WSRESTFUL PRODUCAO2 DESCRIPTION "Serviço REST para inclusão e consulta da Produção - OP" FORMAT "APPLICATION/JSON"
	WSMETHOD POST DESCRIPTION "Lança produção e retorna a confirmação" 	WSSYNTAX "/REST/PRODUCAO2"

END WSRESTFUL

WSRESTFUL ESTORNO DESCRIPTION "Serviço rest para fazer estorno de apontamento" FORMAT "APPLICATION/JSON"
	WSMETHOD POST DESCRIPTION "faz estorno de apontamento" 	WSSYNTAX "/REST/ESTORNO"

END WSRESTFUL

WSRESTFUL IMPRIME DESCRIPTION "Serviço rest para fazer IMPRIMIR etiquetas" FORMAT "APPLICATION/JSON"
	WSMETHOD POST DESCRIPTION "faz estorno de apontamento" 	WSSYNTAX "/REST/IMPRIME"

END WSRESTFUL



WSRESTFUL TOTEMP DESCRIPTION "Serviço REST para exibir os apontamento das OP"
	WSMETHOD GET DESCRIPTION "Serviço REST para exibir os apontamento das OP" WSSYNTAX "/REST/TOTEMP || /REST/TOTEMP/{cNumOP}"
END WSRESTFUL

WSRESTFUL TOTEMP2 DESCRIPTION "Serviço REST para exibir os apontamento das OP - Detalhada"
	WSMETHOD GET DESCRIPTION "Serviço REST para exibir os apontamento das OP - Detalhada" WSSYNTAX "/REST/TOTEMP2 || /REST/TOTEMP2/{cNumOP}{cOperac}{cRecurso}"
END WSRESTFUL

WSRESTFUL TOTEMP3 DESCRIPTION "Serviço REST para exibir os apontamento das OP - Detalhada"
	WSMETHOD GET DESCRIPTION "Serviço REST para exibir os apontamento das OP - Detalhada" WSSYNTAX "/REST/TOTEMP3 || /REST/TOTEMP3/{cNumOP}{OPERACAO}{RECURSO}{TURNO}"
END WSRESTFUL


WSRESTFUL DADOSOP DESCRIPTION "Serviço REST para exibir os dados especificos da OP"
	WSMETHOD GET DESCRIPTION "Serviço REST para exibir os dados especificos da OP" WSSYNTAX "/REST/DADOSOP || /REST/DADOSOP/{cNumOP}"
END WSRESTFUL

WSRESTFUL OPSB5 DESCRIPTION "Serviço REST para exibir os dados especificos da OP - SB5"
	WSMETHOD GET DESCRIPTION "Serviço REST para exibir os dados especificos da OP - SB5" WSSYNTAX "/REST/OPSB5 || /REST/OPSB5/{cNumOP}"
END WSRESTFUL

WSRESTFUL OPSB52 DESCRIPTION "Serviço REST para exibir os dados especificos da OP - SB5 modelo 2"
	WSMETHOD GET DESCRIPTION "Serviço REST para exibir os dados especificos da OP - SB5 modelo 2 " WSSYNTAX "/REST/OPSB52 || /REST/OPSB52/{cNumOP}"
END WSRESTFUL


WSRESTFUL RECURSO DESCRIPTION "Serviço REST para exibir todos os recursos cadastrador"
	WSMETHOD GET DESCRIPTION "Serviço REST para exibir todos os recursos cadastrador" WSSYNTAX "/REST/RECURSO || /REST/RECURSO"
END WSRESTFUL

WSRESTFUL impressoes DESCRIPTION "Serviço REST para exibir todos a lista de impressões"
	WSMETHOD GET DESCRIPTION "Serviço REST para exibir todos os lista de impressoes" WSSYNTAX "/REST/impressoes || /REST/impressoes"
END WSRESTFUL

WSRESTFUL RECURSO_SETOR DESCRIPTION "Serviço REST para exibir todos os recursos cadastrador com filtro de setor"
	WSMETHOD GET DESCRIPTION "Serviço REST para exibir todos os recursos cadastrador com filtro de setor" WSSYNTAX "/REST/RECURSO_SETOR || /REST/RECURSO_SETOR/{cSETOR}{cTipo}"
END WSRESTFUL

WSRESTFUL IMPROD DESCRIPTION "Serviço REST para inclusão da perda da OP" FORMAT "APPLICATION/JSON"
	WSMETHOD POST DESCRIPTION "Serviço REST para inclusão da perda da OP" 	WSSYNTAX "/REST/IMPROD"
END WSRESTFUL

WSRESTFUL MOTIMPROD DESCRIPTION "Lista os motivos de parada de producao" FORMAT "APPLICATION/JSON"
	WSMETHOD GET DESCRIPTION "Lista os motivos de parada de producao" 	WSSYNTAX "/REST/MOTIMPROD"
END WSRESTFUL

WSRESTFUL CONSOPERADOR DESCRIPTION "Lista os motivos o cadastro dos operadores" FORMAT "APPLICATION/JSON"
	WSMETHOD GET DESCRIPTION "Lista os motivos o cadastro dos operadores" 	WSSYNTAX "/REST/CONSOPERADOR"
END WSRESTFUL

WSRESTFUL CONSOPERADOR_SETOR DESCRIPTION "Lista os motivos o cadastro dos operadores com filtro do setor" FORMAT "APPLICATION/JSON"
	WSMETHOD GET DESCRIPTION "Lista os motivos o cadastro dos operadores com filtro do setor" 	WSSYNTAX "/REST/CONSOPERADOR/{cSETOR}"
END WSRESTFUL

WSRESTFUL PRODUTOS_APP DESCRIPTION "Lista o cadastro dos produtos" FORMAT "APPLICATION/JSON"
	WSMETHOD GET DESCRIPTION "Lista o cadastro dos produtos" WSSYNTAX "/REST/PRODUTOS_APP"
END WSRESTFUL

WSRESTFUL AGENDAPARADA DESCRIPTION "Serviço REST para inclusão da agendas de parada" FORMAT "APPLICATION/JSON"
	WSMETHOD POST DESCRIPTION "Serviço REST para inclusão da agendas de parada" WSSYNTAX "/REST/AGENDAPRADA"
END WSRESTFUL

WSRESTFUL TROCATURNO DESCRIPTION "Serviço REST para inclusão das trocas de turnos" FORMAT "APPLICATION/JSON"
	WSMETHOD POST DESCRIPTION "Serviço REST para inclusão das trocas de turnos" WSSYNTAX "/REST/TROCATURNO"
END WSRESTFUL

WSRESTFUL CONQUALIDADE DESCRIPTION "Serviço REST para inclusão do controle de qualidade" FORMAT "APPLICATION/JSON"
	WSMETHOD POST DESCRIPTION "Serviço REST para inclusão do controle de qualidade" WSSYNTAX "/REST/CONQUALIDADE"
END WSRESTFUL

WSRESTFUL ABEROP DESCRIPTION "Serviço REST para inclusão da abertura da OP" FORMAT "APPLICATION/JSON"
	WSMETHOD POST DESCRIPTION "Serviço REST para inclusão da abertura da OP" WSSYNTAX "/REST/ABEROP"
END WSRESTFUL

WSRESTFUL SETOR DESCRIPTION "Lista cadastro de setor" FORMAT "APPLICATION/JSON"
	WSDATA  type As String OPTIONAL

	WSMETHOD GET DESCRIPTION "Lista cadastro de setor" WSSYNTAX "/REST/SETOR"
END WSRESTFUL

WSRESTFUL CORBOBINA DESCRIPTION "Lista de cor de bobina" FORMAT "APPLICATION/JSON"
	WSMETHOD GET DESCRIPTION "Lista de cor de bobina" WSSYNTAX "/REST/CORBOBINA"
END WSRESTFUL

WSRESTFUL APARA DESCRIPTION "Cadastra Apara" FORMAT "APPLICATION/JSON"
	WSMETHOD POST DESCRIPTION "Rotina para cadastrar apara" WSSYNTAX "/REST/APARA"
END WSRESTFUL

WSRESTFUL OPAPARA DESCRIPTION "Cadastro de OP apta a cadastrar aparas" FORMAT "APPLICATION/JSON"
	WSDATA  type As String OPTIONAL
	WSDATA  resource As String OPTIONAL

	WSMETHOD GET DESCRIPTION "Retornar lista da OP apta a cadastrar apara" WSSYNTAX "/REST/OPAPARA"
END WSRESTFUL

WSRESTFUL MOTIVO DESCRIPTION "Retorna motivo de perda" FORMAT "APPLICATION/JSON"
	WSMETHOD GET DESCRIPTION "Retorna motivo de perda" WSSYNTAX "/REST/MOTIVO"
END WSRESTFUL

WSRESTFUL CENTROTRABALHO DESCRIPTION "Retorna centro de trabalho" FORMAT "APPLICATION/JSON"
	WSMETHOD GET DESCRIPTION "Retorna centro de trabalho" WSSYNTAX "/REST/CENTROTRABALHO"
END WSRESTFUL

WSRESTFUL GETOPERACAO DESCRIPTION "Retorna a operação com base no Produto" FORMAT "APPLICATION/JSON"
	WSMETHOD GET DESCRIPTION "Retorna a operação com base no Produto" WSSYNTAX "/REST/GETOPERACAO"
END WSRESTFUL

WSRESTFUL GETOPERADOR DESCRIPTION "Busca operador " FORMAT "APPLICATION/JSON"
	WSMETHOD GET DESCRIPTION "Operador amarrado ao turno
END WSRESTFUL

WSRESTFUL TURNOS DESCRIPTION "Busca turnos " FORMAT "APPLICATION/JSON"
	WSMETHOD GET DESCRIPTION "Busca turnos"
END WSRESTFUL

WSRESTFUL GETMULT DESCRIPTION "Busca multiplicador " FORMAT "APPLICATION/JSON"
	WSMETHOD GET DESCRIPTION "retorna o multiplicador " WSSYNTAX "/REST/GETMULT"
END WSRESTFUL


WSRESTFUL LOCALIMPR DESCRIPTION "Busca preferencia de impressão " FORMAT "APPLICATION/JSON"
	WSMETHOD GET DESCRIPTION "Busca preferencias de impressão " WSSYNTAX "/REST/LOCALIMPR"
END WSRESTFUL

WSRESTFUL USUARIOLOGADO DESCRIPTION "Busca Acessos Usuario Logado" FORMAT "APPLICATION/JSON"
	WSMETHOD GET DESCRIPTION "Busca Acessos Usuario Logado" WSSYNTAX "/REST/USUARIOLOGADO"
END WSRESTFUL

WSRESTFUL CONSOPERADOR_RECURSO DESCRIPTION "Lista os operadores cadastrados com filtro de recurso e turno" FORMAT "APPLICATION/JSON"
	WSMETHOD GET DESCRIPTION "Lista os operadores cadastrados com filtro de recurso e turno" 	WSSYNTAX "/REST/CONSOPERADOR_RECURSO/{TURNO}{RECURSO}"
END WSRESTFUL

//---------------------------------------------------------------------------------------------------//
// Método GET - Retorna os da Ordem de Produção Especifica.                                          //
//---------------------------------------------------------------------------------------------------//

WSMETHOD GET WSSERVICE XUSERS

	Local aUsers        := {}
	Local lRet 			    := .T.

	conout("Rotina: GET XUSERS - Retorna os dados dos usuarios.")

	::SetContentType("application/json")

	AAdd( aUsers, PswChave(RetCodUsr()) )
	AAdd( aUsers, RetCodUsr() )

	cJson := FWJsonSerialize(aUsers, .T., .T.,,.F.)
	::SetResponse(cJson)

Return (lRet)

//---------------------------------------------------------------------------------------------------//
// Método GET - Retorna os produtos cadastrados.                                                     //
//---------------------------------------------------------------------------------------------------//

WSMETHOD GET WSSERVICE PRODUTOS_APP

	Local aProdutos   := {}
	Local nTotReg     := 0    // Quantidade de registros retornados da Query
	Local lRet 		:= .T.

	conout("Rotina: GET PRODUTOS_APP - Retorna os produtos cadastrados.")

	::SetContentType("application/json")

	// Inicio tratativa para verificar o preenchimento da Operação no momento da caonsulta do Empenho - 24/11/2021
	if Select("QryProduto") > 0
		DbSelectArea("QryProduto")
		QryProduto->(DbCloseArea())
	endif

	// Qry para retornar os dados Ordem de Produção em questão
	QryProduto := "SELECT B1_COD, B1_DESC FROM " + RetSqlName("SB1") + " AS SB1 "
	QryProduto += " WHERE SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' AND SB1.D_E_L_E_T_ = '' "

	conout("Qry dados produto: " + QryProduto)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QryProduto),"QryProduto",.T.,.T.)

	dbSelectArea("QryProduto")

	Count To nTotReg          // Quantidade de registros retornados pela query

	dbSelectArea("QryProduto")
	dbgotop()

	While !EoF()
		aColunas := {}
		AAdd( aColunas, QryProduto->B1_COD )
		AAdd( aColunas, QryProduto->B1_DESC )
		AAdd( aProdutos , aColunas )
		QryProduto->(dbSkip())
	EndDo

	QryProduto->(DbCloseArea())

	cJson := FWJsonSerialize(aProdutos, .T., .T.,,.F.)
	::SetResponse(cJson)

Return (lRet)

//---------------------------------------------------------------------------------------------------//
// Método GET - Retorna os recursos cadastrados.                                                     //
//---------------------------------------------------------------------------------------------------//

WSMETHOD GET WSSERVICE RECURSO

	Local aRecurso      := {}
	Local nTotReg       := 0    // Quantidade de registros retornados da Query
	Local lRet 			    := .T.

	conout("Rotina: GET RECURSO - Retorna os recursos cadastrados.")

	::SetContentType("application/json")

	// Inicio tratativa para verificar o preenchimento da Operação no momento da caonsulta do Empenho - 24/11/2021
	if Select("QrRecurso") > 0
		DbSelectArea("QrRecurso")
		QrRecurso->(DbCloseArea())
	endif

	// Qry para retornar os dados Ordem de Produção em questão
	cQrRecurso := "SELECT * "
	cQrRecurso += " FROM " + RetSqlName("SH1") + " AS SH1 "
	cQrRecurso += " WHERE SH1.H1_FILIAL = '" + FWxFilial('SH1') + "' AND SH1.D_E_L_E_T_ = '' "

	conout("Qry dados op: " + cQrRecurso)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrRecurso),"QrRecurso",.T.,.T.)

	dbSelectArea("QrRecurso")

	Count To nTotReg          // Quantidade de registros retornados pela query

	dbSelectArea("QrRecurso")
	dbgotop()

	While !EoF()
		aColunas := {}
		AAdd( aColunas, QrRecurso->H1_CODIGO )
		AAdd( aColunas, EncodeUTF8(QrRecurso->H1_DESCRI, "cp1252") )
		AAdd( aRecurso , aColunas )
		QrRecurso->(dbSkip())
	EndDo

	QrRecurso->(DbCloseArea())

	cJson := FWJsonSerialize(aRecurso, .T., .T.,,.F.)
	::SetResponse(cJson)

Return (lRet)

//---------------------------------------------------------------------------------------------------//
// Método GET - Retorna os recursos cadastros com filtro do setor.                                   //
//---------------------------------------------------------------------------------------------------//

WSMETHOD GET QUERYPARAM cSETOR WSSERVICE RECURSO_SETOR

	Local aFiltros      := Self:aQueryString
	Local aRecurso      := {}
	Local nTotReg       := 0    // Quantidade de registros retornados da Query
	Local lRet 			    := .T.

	conout("Rotina: GET RECURSO - Retorna os recursos cadastrados.")

	::SetContentType("application/json")

	IF Len(aFiltros) > 0

		// Inicio tratativa para verificar o preenchimento da Operação no momento da caonsulta do Empenho - 24/11/2021
		if Select("QrRecurso") > 0
			DbSelectArea("QrRecurso")
			QrRecurso->(DbCloseArea())
		endif

		// Qry para retornar os dados Ordem de Produção em questão
		cQrRecurso := "SELECT * "
		cQrRecurso += " FROM " + RetSqlName("SH1") + " AS SH1 "
		cQrRecurso += " WHERE SH1.H1_FILIAL = '" + FWxFilial('SH1') + "' AND SH1.D_E_L_E_T_ = '' "
		cQrRecurso += " AND H1_ZZSETOR = '" + aFiltros[1][2] + "' "
		If Len(aFiltros) > 1
			cQrRecurso += " AND H1_CTRAB = '" + aFiltros[2][2] + "' "
		EndIf
		cQrRecurso += " ORDER BY H1_DESCRI "

		conout("Qry dados op: " + cQrRecurso)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrRecurso),"QrRecurso",.T.,.T.)

		dbSelectArea("QrRecurso")

		Count To nTotReg          // Quantidade de registros retornados pela query

		dbSelectArea("QrRecurso")
		dbgotop()

		While !EoF()
			aColunas := {}
			AAdd( aColunas, QrRecurso->H1_CODIGO )
			AAdd( aColunas, EncodeUTF8(QrRecurso->H1_DESCRI, "cp1252") )
			AAdd( aRecurso , aColunas )
			QrRecurso->(dbSkip())
		EndDo

		QrRecurso->(DbCloseArea())

		cJson := FWJsonSerialize(aRecurso, .T., .T.,,.F.)
		::SetResponse(cJson)
	ENDIF
Return (lRet)

//---------------------------------------------------------------------------------------------------//
// Método GET - Retorna os da Ordem de Produção Especifica.                                          //
//---------------------------------------------------------------------------------------------------//

WSMETHOD GET QUERYPARAM CNUMOP WSSERVICE PRODUCAO

	Local aFiltros      := Self:aQueryString
	Local aEmpenho      := {}
	Local aColunas      := {}
	Local nTotReg       := 0    // Quantidade de registros retornados da Query
	Local lRet 			    := .T.

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')	// 20/01/2022 - Definição do padrão de Data (dd/mm/yyyy) - Colocado p/ resolver problema com a exibição de Data qdo utilizado o REST

	conout("Rotina: GET PRODUCAO - Retorna os dados da OP.")

	::SetContentType("application/json")

	if Len(aFiltros) > 0

		// Inicio tratativa para verificar o preenchimento da Operação no momento da caonsulta do Empenho - 24/11/2021
		if Select("QrPrdOpr") > 0
			DbSelectArea("QrPrdOpr")
			QrPrdOpr->(DbCloseArea())
		endif

		// Qry para retornar os dados Ordem de Produção em questão
		cQrPrdOpr := "SELECT * "
		cQrPrdOpr += " FROM " + RetSqlName("SC2") + " AS SC2 "
		cQrPrdOpr += " WHERE SC2.C2_FILIAL = '" + FWxFilial('SC2') + "' AND SC2.D_E_L_E_T_ = '' "
		cQrPrdOpr += " AND C2_NUM = '" + aFiltros[1][2] + "' "

		conout("Qry dados op: " + cQrPrdOpr)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrPrdOpr),"QrPrdOpr",.T.,.T.)

		dbSelectArea("QrPrdOpr")

		Count To nTotReg          // Quantidade de registros retornados pela query

		dbSelectArea("QrPrdOpr")
		dbgotop()

		While !EoF()
			aColunas := {}
			AAdd( aColunas, QrPrdOpr->C2_NUM )
			AAdd( aColunas, QrPrdOpr->B1_DESC )
			AAdd( aColunas, QrPrdOpr->D4_QTDEORI )
			AAdd( aColunas, QrPrdOpr->B1_RASTRO )
			AAdd( aColunas, QrPrdOpr->D4_LOCAL )      // 18/11/2021
			AAdd( aEmpenho , aColunas )
			QRYSD4->(dbSkip())
		EndDo

		QRYSD4->(DbCloseArea())

		cJson := FWJsonSerialize(aEmpenho, .T., .T.,,.F.)
		::SetResponse(cJson)

	ENDIF
Return (lRet)

//---------------------------------------------------------------------------------------------------//
// Método GET - Retorna os dados especificos da Ordem de Produção.                                   //
//---------------------------------------------------------------------------------------------------//

WSMETHOD GET QUERYPARAM CNUMOP WSSERVICE DADOSOP

	Local aFiltros      := Self:aQueryString
	Local aEmpenho      := {}
	Local aColunas      := {}
	Local nTotReg       := 0    // Quantidade de registros retornados da Query
	Local lRet 			    := .T.

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')	// 20/01/2022 - Definição do padrão de Data (dd/mm/yyyy) - Colocado p/ resolver problema com a exibição de Data qdo utilizado o REST

	conout("Rotina: GET DADOSOP - Retorna os dados da OP.")

	::SetContentType("application/json")

	if Len(aFiltros) > 0

		// Inicio tratativa para verificar o preenchimento da Operação no momento da caonsulta do Empenho - 24/11/2021
		if Select("QrPrdOpr") > 0
			DbSelectArea("QrPrdOpr")
			QrPrdOpr->(DbCloseArea())
		endif

		// Qry para retornar os dados Ordem de Produção em questão
		cQrPrdOpr := "SELECT * "
		cQrPrdOpr += " FROM " + RetSqlName("SC2") + " AS SC2 "
		cQrPrdOpr += " WHERE SC2.C2_FILIAL = '" + FWxFilial('SC2') + "' AND SC2.D_E_L_E_T_ = '' "
		cQrPrdOpr += " AND C2_NUM = '" + aFiltros[1][2] + "' "

		conout("Qry dados op: " + cQrPrdOpr)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrPrdOpr),"QrPrdOpr",.T.,.T.)

		dbSelectArea("QrPrdOpr")

		Count To nTotReg          // Quantidade de registros retornados pela query

		dbSelectArea("QrPrdOpr")
		dbgotop()

		While !EoF()
			aColunas := {}
			AAdd( aColunas, QrPrdOpr->C2_NUM )
			AAdd( aColunas, QrPrdOpr->B1_DESC )
			AAdd( aColunas, QrPrdOpr->D4_QTDEORI )
			AAdd( aColunas, QrPrdOpr->B1_RASTRO )
			AAdd( aColunas, QrPrdOpr->D4_LOCAL )      // 18/11/2021
			AAdd( aEmpenho , aColunas )
			QRYSD4->(dbSkip())
		EndDo

		QRYSD4->(DbCloseArea())

		cJson := FWJsonSerialize(aEmpenho, .T., .T.,,.F.)
		::SetResponse(cJson)

	ENDIF
Return (lRet)

//---------------------------------------------------------------------------------------------------//
// Método GET - Retorna os dados especificos da Ordem de Produção.                                   //
//---------------------------------------------------------------------------------------------------//

WSMETHOD GET QUERYPARAM CNUMOP WSSERVICE OPSB5

	Local aFiltros      := Self:aQueryString
	Local aOpSB5        := {}
	Local aColunas      := {}
	Local nTotReg       := 0    // Quantidade de registros retornados da Query
	Local lRet 			    := .T.

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')	// 20/01/2022 - Definição do padrão de Data (dd/mm/yyyy) - Colocado p/ resolver problema com a exibição de Data qdo utilizado o REST

	conout("Rotina: GET OPSB5 - Retorna os dados da OP.")

	::SetContentType("application/json")

	if Len(aFiltros) > 0

		// Inicio tratativa para verificar o preenchimento da Operação no momento da caonsulta do Empenho - 24/11/2021
		if Select("cQrOpSB5") > 0
			DbSelectArea("cQrOpSB5")
			cQrOpSB5->(DbCloseArea())
		endif

		// Qry para retornar os dados Ordem de Produção em questão
		cQrOpSB5 := "SELECT * "
		cQrOpSB5 += " FROM " + RetSqlName("SC2") + " AS SC2, "  + RetSqlName("SB1") + " AS SB1 "
		cQrOpSB5 += " WHERE SC2.C2_FILIAL = '" + FWxFilial('SC2') + "' "
		cQrOpSB5 += " AND SB1.D_E_L_E_T_ = '' AND SC2.D_E_L_E_T_ = '' "
		cQrOpSB5 += " AND SB1.B1_COD = SC2.C2_PRODUTO "
		cQrOpSB5 += " AND SC2.C2_NUM = '" + SubStr(aFiltros[1][2],1,6) + "' "
		cQrOpSB5 += " AND SC2.C2_ITEM = '" + SubStr(aFiltros[1][2],7,2) + "' "
		cQrOpSB5 += " AND SC2.C2_SEQUEN = '" + SubStr(aFiltros[1][2],9,3) + "' "

		conout("Qry dados op: " + cQrOpSB5)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrOpSB5),"cQrOpSB5",.T.,.T.)

		dbSelectArea("cQrOpSB5")

		Count To nTotReg          // Quantidade de registros retornados pela query

		dbSelectArea("cQrOpSB5")
		dbgotop()

		While !EoF()
			aColunas := {}
			AAdd( aColunas, cQrOpSB5->C2_NUM )
			AAdd( aColunas, cQrOpSB5->C2_PRODUTO + " - " + ALLTRIM(Posicione("SB1",1,FWxFilial('SB1') + cQrOpSB5->C2_PRODUTO, "B1_DESC")))
			AAdd( aColunas, cQrOpSB5->B1_ZZMED)	//Medida Especificada
			AAdd( aColunas, cQrOpSB5->B1_ZZSOMB)	//Sombra Especificada
			AAdd( aColunas, cQrOpSB5->B1_ZZQTDFA)	//Qtdade Fardo
			AAdd( aColunas, cQrOpSB5->B1_ZZLARG)	//Largura Especificada
			AAdd( aColunas, cQrOpSB5->B1_ZZCOMP)	//Comprimento Especificado
			AAdd( aColunas, cQrOpSB5->B1_ZZPESA)	//Pesagem Especificada
			AAdd( aColunas, cQrOpSB5->C2_ZZTEAR)	//Tear utilizado OP
			AAdd( aColunas, cQrOpSB5->B1_PESO)	//Peso Liquido
			AAdd( aOpSB5 , aColunas )
			cQrOpSB5->(dbSkip())
		EndDo

		cQrOpSB5->(DbCloseArea())

		cJson := FWJsonSerialize(aOpSB5, .T., .T.,,.F.)
		::SetResponse(cJson)

	ENDIF
Return (lRet)

//------------------------------------------------------------------------------------------------------------------------------------------//
// Método GET - Retorna as quantidades apontadas de produção por Operação assim como o % da produção que representa do total da O.P.        //
//------------------------------------------------------------------------------------------------------------------------------------------//

WSMETHOD GET QUERYPARAM CNUMOP WSSERVICE TOTEMP

	Local aFiltros      := Self:aQueryString
	Local aEmpenho      := {}
	Local aColunas      := {}
	Local _nCnt         := 1
	Local _nOperAnt     := 0

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

	conout("Rotina: GET TOTEMP - Qtde apontadas Prod. por Operação")

	::SetContentType("application/json")

	If Len(aFiltros) > 0

		If Select("QRYSD4") > 0
			DbSelectArea("QRYSD4")
			QRYSD4->(DbCloseArea())
		EndIf

		cQuery2 := "SELECT H6_RECURSO, H6_PRODUTO, B1_DESC, C2_UM, H6_OP, "
		cQuery2 += " SUBSTRING(C2_EMISSAO,7,2) + '/' + SUBSTRING(C2_EMISSAO,5,2) + '/' + SUBSTRING(C2_EMISSAO,1,4) EMISSAO, "
		cQuery2 += " SUBSTRING(C2_DATPRI,7,2) + '/' + SUBSTRING(C2_DATPRI,5,2) + '/' + SUBSTRING(C2_DATPRI,1,4) PREV_INI, "
		cQuery2 += " SUBSTRING(C2_DATPRF,7,2) + '/' + SUBSTRING(C2_DATPRF,5,2) + '/' + SUBSTRING(C2_DATPRF,1,4) PREV_FIM, "
		cQuery2 += " H6_OPERAC, G2_DESCRI, SUM(H6_QTDPROD) QTD_PROD, SC2.C2_QUANT, ((SUM(H6_QTDPROD) / SC2.C2_QUANT) * 100) PERC "
		cQuery2 += " FROM " + RetSqlName("SH6") + " AS SH6, " + RetSqlName("SG2") + " AS SG2, " + RetSqlName("SC2") + " AS SC2, " + RetSqlName("SB1") + " AS SB1 "
		cQuery2 += " WHERE SH6.H6_FILIAL = '" + FWxFilial('SH6') + "' AND SH6. D_E_L_E_T_ = '' "
		cQuery2 += " AND SH6.H6_TIPO = 'P' "
		cQuery2 += " AND SG2.G2_FILIAL = '" + FWxFilial('SG2') + "' AND SG2.D_E_L_E_T_ = '' "
		cQuery2 += " AND SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' AND SB1.D_E_L_E_T_ = '' "
		cQuery2 += " AND SH6.H6_PRODUTO = SB1.B1_COD "
		cQuery2 += " AND SH6.H6_OPERAC = SG2.G2_OPERAC "
		cQuery2 += " AND SH6.H6_PRODUTO = SG2.G2_PRODUTO "
		cQuery2 += " AND SC2.C2_ROTEIRO = SG2.G2_CODIGO "
		cQuery2 += " AND SC2.C2_FILIAL = '" + FWxFilial('SC2') + "' AND SC2. D_E_L_E_T_ = '' "
		cQuery2 += " AND SUBSTRING(H6_OP,1,6) = C2_NUM "
		cQuery2 += " AND SUBSTRING(H6_OP,7,2) = C2_ITEM "
		cQuery2 += " AND SUBSTRING(H6_OP,9,3) = C2_SEQUEN "
		cQuery2 += " AND SUBSTRING(SH6.H6_OP,1,6) = '" + aFiltros[1][2] + "' "  //aFiltros[1][2] + "' "
		cQuery2 += " GROUP BY H6_OP,H6_OPERAC,G2_DESCRI,SC2.C2_QUANT, H6_RECURSO, H6_PRODUTO, B1_DESC, C2_UM, C2_EMISSAO, C2_DATPRI, C2_DATPRF "
		cQuery2 += " ORDER BY H6_OPERAC"

		conout("Query Tot. Emp.: " + cQuery2)

		// Transpilando o código SQL para o Banco configurado e criando o ALIAS que será utilizado
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),"QRYSD4",.T.,.T.)

		dbSelectArea("QRYSD4")
		dbGoTop()

		_nCnt     := 1                // Contador auxiliar para controle qtde produzida na Operação Anterior
		_nOperAnt := 0                // Qtde Produzida na Operação Anterior

		While !EoF()
			aColunas := {}
			AAdd( aColunas, QRYSD4->H6_OPERAC )
			AAdd( aColunas, QRYSD4->G2_DESCRI )
			AAdd( aColunas, QRYSD4->H6_RECURSO )
			AAdd( aColunas, QRYSD4->H6_PRODUTO )
			AAdd( aColunas, QRYSD4->B1_DESC )
			AAdd( aColunas, QRYSD4->C2_UM )
			AAdd( aColunas, QRYSD4->H6_OP )
			AAdd( aColunas, QRYSD4->EMISSAO )
			AAdd( aColunas, QRYSD4->PREV_INI )
			AAdd( aColunas, QRYSD4->PREV_FIM )
			AAdd( aColunas, QRYSD4->C2_QUANT )
			AAdd( aColunas, QRYSD4->QTD_PROD )

			AAdd( aEmpenho , aColunas )

			_nOperAnt := QRYSD4->QTD_PROD

			QRYSD4->(dbSkip())
			_nCnt++
		EndDo

		cJson := FWJsonSerialize(aEmpenho, .T., .T.,,.F.)

		::SetResponse(cJson)
	EndIf

Return .T.

//------------------------------------------------------------------------------------------------------------------------------------------//
// Método GET - Retorna as quantidades apontadas de produção por Operação assim como o % da produção que representa do total da O.P.        //
//------------------------------------------------------------------------------------------------------------------------------------------//

WSMETHOD GET QUERYPARAM CNUMOP, COPERAC, CRECURSO WSSERVICE TOTEMP2

	Local aFiltros      := Self:aQueryString
	Local aEmpenho      := {}
	Local aColunas      := {}
	Local _nCnt         := 1
	Local _nOperAnt     := 0

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

	conout("Rotina: GET TOTEMP2 - Qtde apontadas Prod. por Operação detalhados")

	::SetContentType("application/json")

	If Len(aFiltros) > 0

		If Select("QRYSH6") > 0
			DbSelectArea("QRYSH6")
			QRYSH6->(DbCloseArea())
		EndIf

		Conout(LEN(aFiltros))

		cQuery2 := "SELECT H6_OP, H6_PRODUTO, B1_DESC, C2_UM,  "
		cQuery2 += " SUBSTRING(H6_DATAINI,7,2) + '/' + SUBSTRING(H6_DATAINI,5,2) + '/' + SUBSTRING(H6_DATAINI,1,4) DATA_INI, "
		cQuery2 += " H6_HORAINI, "
		cQuery2 += " SUBSTRING(H6_DATAFIN,7,2) + '/' + SUBSTRING(H6_DATAFIN,5,2) + '/' + SUBSTRING(H6_DATAFIN,1,4) DATA_FIM, "
		cQuery2 += " H6_HORAFIN, "
		cQuery2 += " H6_OPERAC, G2_DESCRI, H6_OPERADO, H6_QTDPROD, H6_RECURSO"
		cQuery2 += " FROM " + RetSqlName("SH6") + " AS SH6, " + RetSqlName("SG2") + " AS SG2, " + RetSqlName("SC2") + " AS SC2, " + RetSqlName("SB1") + " AS SB1 "
		cQuery2 += " WHERE SH6.H6_FILIAL = '" + FWxFilial('SH6') + "' AND SH6. D_E_L_E_T_ = '' "
		cQuery2 += " AND SH6.H6_TIPO = 'P' "
		cQuery2 += " AND SG2.G2_FILIAL = '" + FWxFilial('SG2') + "' AND SG2.D_E_L_E_T_ = '' "
		cQuery2 += " AND SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' AND SB1.D_E_L_E_T_ = '' "
		cQuery2 += " AND SH6.H6_PRODUTO = SB1.B1_COD "
		cQuery2 += " AND SH6.H6_OPERAC = SG2.G2_OPERAC "
		cQuery2 += " AND SH6.H6_PRODUTO = SG2.G2_PRODUTO "
		cQuery2 += " AND SC2.C2_ROTEIRO = SG2.G2_CODIGO "
		cQuery2 += " AND SC2.C2_FILIAL = '" + FWxFilial('SC2') + "' AND SC2. D_E_L_E_T_ = '' "
		cQuery2 += " AND SUBSTRING(H6_OP,1,6) = C2_NUM "
		cQuery2 += " AND SUBSTRING(H6_OP,7,2) = C2_ITEM "
		cQuery2 += " AND SUBSTRING(H6_OP,9,3) = C2_SEQUEN "
		cQuery2 += " AND SUBSTRING(SH6.H6_OP,1,6) = '" + aFiltros[1][2] + "' "
		cQuery2 += " AND H6_OPERAC = '" + aFiltros[2][2] + "' "
		cQuery2 += " AND H6_RECURSO = '" + aFiltros[3][2] + "' "
		cQuery2 += " ORDER BY DATA_INI"

		conout("Query Tot. Emp.: " + cQuery2)

		// Transpilando o código SQL para o Banco configurado e criando o ALIAS que será utilizado
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),"QRYSH6",.T.,.T.)

		dbSelectArea("QRYSH6")
		dbGoTop()

		_nCnt     := 1                // Contador auxiliar para controle qtde produzida na Operação Anterior
		_nOperAnt := 0                // Qtde Produzida na Operação Anterior

		While !EoF()
			aColunas := {}
			AAdd( aColunas, QRYSH6->H6_OP )
			AAdd( aColunas, QRYSH6->H6_PRODUTO )
			AAdd( aColunas, QRYSH6->B1_DESC )

			AAdd( aColunas, QRYSH6->DATA_INI )
			AAdd( aColunas, QRYSH6->H6_HORAINI )

			AAdd( aColunas, QRYSH6->DATA_FIM )
			AAdd( aColunas, QRYSH6->H6_HORAFIN )

			AAdd( aColunas, QRYSH6->G2_DESCRI )
			AAdd( aColunas, QRYSH6->H6_OPERADO )

			AAdd( aColunas, QRYSH6->H6_QTDPROD )

			AAdd( aEmpenho , aColunas )

			QRYSH6->(dbSkip())
			_nCnt++
		EndDo

		cJson := FWJsonSerialize(aEmpenho, .T., .T.,,.F.)

		::SetResponse(cJson)
	EndIf

Return .T.

//----------------------------------------------------------------------------------------------------------------------------//
// Método GET - Retorna os motivos de parada de producao, para utilizar no apontamento das horas improdutivas.                //
//----------------------------------------------------------------------------------------------------------------------------//

WSMETHOD GET WSSERVICE MOTIMPROD

	// Local aFiltros      := Self:aQueryString
	Local aEmpenho      := {}
	Local aColunas      := {}
	Local _nCnt         := 1          // Contador auxiliar para controle qtde produzida na Operação Anterior
	Local _nOperAnt     := 0          // Qtde Produzida na Operação Anterior
	Local cQuery2       := ""

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')	// 20/01/2022 - Definição do padrão de Data (dd/mm/yyyy) - Colocado p/ resolver problema com a exibição de Data qdo utilizado o REST

	conout("Rotina: GET MOTIMPROD - Motivos de paradas de producao")

	::SetContentType("application/json")

	If Select("QRYCYN") > 0
		DbSelectArea("QRYCYN")
		QRYCYN->(DbCloseArea())
	EndIf

	cQuery2 := "SELECT CYN_CDSP, CYN_DSSP "
	cQuery2 += " FROM " + RetSqlName("CYN") + " AS CYN"
	cQuery2 += " WHERE CYN.CYN_FILIAL = '" + FWxFilial('CYN') + "' AND CYN. D_E_L_E_T_ = '' "
	cQuery2 += " ORDER BY CYN_CDSP"

	conout("Query Mot. Parada: " + cQuery2)

	// Transpilando o código SQL para o Banco configurado e criando o ALIAS que será utilizado
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),"QRYCYN",.T.,.T.)

	dbSelectArea("QRYCYN")
	dbGoTop()

	_nCnt     := 1                // Contador auxiliar para controle qtde produzida na Operação Anterior
	_nOperAnt := 0                // Qtde Produzida na Operação Anterior

	While !EoF()
		aColunas := {}
		AAdd( aColunas, QRYCYN->CYN_CDSP      )
		AAdd( aColunas, QRYCYN->CYN_DSSP  )

		AAdd( aEmpenho , aColunas )

		QRYCYN->(dbSkip())
		_nCnt++
	EndDo

	cJson := FWJsonSerialize(aEmpenho, .T., .T.,,.F.)

	::SetResponse(cJson)

Return .T.

//-------------------------------------------------------------------------//
// Método GET - Retorna a lista do cadastro dos operadores.                //
//-------------------------------------------------------------------------//

WSMETHOD GET WSSERVICE CONSOPERADOR

	// Local aFiltros      := Self:aQueryString
	Local aOperador     := {}
	Local aColunas      := {}
	Local _nCnt         := 1          // Contador auxiliar para controle qtde produzida na Operação Anterior
	Local _nOperAnt     := 0          // Qtde Produzida na Operação Anterior
	Local cQuery2       := ""

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')	// 20/01/2022 - Definição do padrão de Data (dd/mm/yyyy) - Colocado p/ resolver problema com a exibição de Data qdo utilizado o REST

	conout("Rotina: GET CONSOPERADOR - Cadastro Operadores")

	::SetContentType("application/json")

	If Select("QRYSZZ") > 0
		DbSelectArea("QRYSZZ")
		QRYSZZ->(DbCloseArea())
	EndIf

	cQuery2 := "SELECT ZZ_COD, ZZ_NOME "
	cQuery2 += " FROM " + RetSqlName("SZZ") + " AS SZZ"
	cQuery2 += " WHERE SZZ.ZZ_FILIAL = '" + FWxFilial('SZZ') + "' AND SZZ.D_E_L_E_T_ = '' "
	cQuery2 += " ORDER BY SZZ.ZZ_COD"

	conout("Query Operador: " + cQuery2)

	// Transpilando o código SQL para o Banco configurado e criando o ALIAS que será utilizado
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),"QRYSZZ",.T.,.T.)

	dbSelectArea("QRYSZZ")
	dbGoTop()

	_nCnt     := 1                // Contador auxiliar para controle qtde produzida na Operação Anterior
	_nOperAnt := 0                // Qtde Produzida na Operação Anterior

	While !EoF()
		aColunas := {}
		AAdd( aColunas, QRYSZZ->ZZ_COD      )
		AAdd( aColunas, QRYSZZ->ZZ_NOME  )

		AAdd( aOperador , aColunas )

		QRYSZZ->(dbSkip())
		_nCnt++
	EndDo

	cJson := FWJsonSerialize(aOperador, .T., .T.,,.F.)

	::SetResponse(cJson)

Return .T.

//-----------------------------------------------------------------------------------//
// Método GET - Retorna a lista do cadastro dos operadores com filtro de setor.      //
//-----------------------------------------------------------------------------------//

WSMETHOD GET QUERYPARAM cSETOR WSSERVICE CONSOPERADOR_SETOR

	Local aFiltros      := Self:aQueryString
	Local aOperador     := {}
	Local aColunas      := {}
	Local _nCnt         := 1          // Contador auxiliar para controle qtde produzida na Operação Anterior
	Local _nOperAnt     := 0          // Qtde Produzida na Operação Anterior
	Local cQuery2       := ""

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')	// 20/01/2022 - Definição do padrão de Data (dd/mm/yyyy) - Colocado p/ resolver problema com a exibição de Data qdo utilizado o REST

	conout("Rotina: GET CONSOPERADOR_SETOR - Cadastro Operadores")

	::SetContentType("application/json")

	If Len(aFiltros) > 0

		If Select("QRYSZZ") > 0
			DbSelectArea("QRYSZZ")
			QRYSZZ->(DbCloseArea())
		EndIf

		cQuery2 := "SELECT ZZ_COD, ZZ_NOME "
		cQuery2 += " FROM " + RetSqlName("SZZ") + " AS SZZ"
		cQuery2 += " WHERE SZZ.ZZ_FILIAL = '" + FWxFilial('SZZ') + "' AND SZZ.D_E_L_E_T_ = '' "
		cQuery2 += " AND ZZ_SETOR = '" + aFiltros[1][2] + "' "
		cQuery2 += " ORDER BY SZZ.ZZ_COD"

		conout("Query Operador: " + cQuery2)

		// Transpilando o código SQL para o Banco configurado e criando o ALIAS que será utilizado
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),"QRYSZZ",.T.,.T.)

		dbSelectArea("QRYSZZ")
		dbGoTop()

		_nCnt     := 1                // Contador auxiliar para controle qtde produzida na Operação Anterior
		_nOperAnt := 0                // Qtde Produzida na Operação Anterior

		While !EoF()
			aColunas := {}
			AAdd( aColunas, QRYSZZ->ZZ_COD      )
			AAdd( aColunas, QRYSZZ->ZZ_NOME  )

			AAdd( aOperador , aColunas )

			QRYSZZ->(dbSkip())
			_nCnt++
		EndDo

		cJson := FWJsonSerialize(aOperador, .T., .T.,,.F.)

		::SetResponse(cJson)
	ENDIF
Return .T.

//------------------------------------------------------------------------------------------------------------------------------------------//
// Método POST - Realiza o apontamento de Produção por Operação (Modelo 2) - Via ExecAuto: MATA681                                          //
//------------------------------------------------------------------------------------------------------------------------------------------//

WSMETHOD POST WSSERVICE PRODUCAO

	Local cJSON 		:= Self:GetContent() // Pega a string do JSON
	Local oParseJSON 	:= Nil
	Local cJsonRet 		:= " "
	Local cErro 		:= " "
	Local aLog        	:= {}         // Array para receber erro log da rotina executada via MsExecAuto
	Local nCntLog     	:= 0          // Contador do laço de repetição para tratativa de possivel erro log
	Local lRet 			:= .F.        // Var. de Retorno, caso tenha efetuado o ajuste de empenho com SUCESSO retorna .T. = True, senão .F. = False
	Local aCabec 		:= {}
	Local _nQtdPro    	:= 0          // Qtde Produzida
	Local _nQtdPer    	:= 0          // Qtde de Perda
	Local _nQtdFal    	:= 0          // Qtde Faltante para terminar OP (C2_QUANT - C2_QUJE - C2_PERDA) // 23/05/2021 - MAC
	Local _cUpdDtPr   	:= ''         // Update no campo H6_DTPROD para ficar com a mesma data do H6_DTAPONT
	Local _cLocPrd    	:= ''         // Local da Produção
	Local _dDatLot    	:= StoD('')   // Data do Lote
	Local _cIdent     	:= ''         // Nro do campo D3_IDENT
	Local _cNrSeq     	:= ''         // Nro do campo D3_NUMSEQ
	Local _cQrInfMv   	:= ''         // Query para retornar os campos D3_IDENT e D3_NUMSEQ do movimento a ser modificado a data

	Private lMsErroAuto     := .F.
	Private lMsHelpAuto     := .F.
	Private _cNumOP         := " "
	Private _cOper          := " "
	Private _cProdut        := " "
	Private lAutoErrNoFile  := .T.

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')	// 20/01/2022 - Definição do padrão de Data (dd/mm/yyyy) - Colocado p/ resolver problema com a exibição de Data qdo utilizado o REST

	conout("Rotina: POST PRODUCAO - Apont. Prod. por Operação - MATA681")

	oParseJSON := JSonObject():New()
	cErr  	   := oParseJSON:fromJson(cJSON)

	if !empty(cErr)
		conout('Erro: ' + cErr)
		SetRestFault(400, cErr)
		lRet := .F.
		Return(lRet)
	endif

	_cNumOP   := oParseJSON:GetJSonObject('NUMOP')
	_cOper    := oParseJSON:GetJSonObject('OPERACAO')
	_cRecur   := oParseJSON:GetJSonObject('RECURSO')
	_cOperado := oParseJSON:GetJSonObject('OPERADOR')
	_hHrIni   := oParseJSON:GetJSonObject('HRINIC')
	_hHrFim   := oParseJSON:GetJSonObject('HRFINAL')
	_hHrTotal := oParseJSON:GetJSonObject('tempo_total')
	_dDtIni   := oParseJSON:GetJSonObject('DTINIC')
	_dDtFim   := oParseJSON:GetJSonObject('DTFINAL')
	_dDtApon  := oParseJSON:GetJSonObject('DTFINAL')
	_nQtdPro  := Val(StrTran(oParseJSON:GetJSonObject('QTDPROD'),",","."))

	IF !Empty(oParseJSON:GetJSonObject('QTDPERDA'))
		_nQtdPer  := Val(StrTran(oParseJSON:GetJSonObject('QTDPERDA'),",","."))
	ELSE
		_nQtdPer  := 0
	ENDIF

	DbSelectArea("SC2")
	DbSetOrder(1)
	DbGoToP()

	if MsSeek( FWxFilial('SC2') + _cNumOP )
		_cProdut  := SC2->C2_PRODUTO
		_nQtdFal  := SC2->C2_QUANT
		_cLocPrd  := SC2->C2_LOCAL
	endif

	SC2->(DbCloseArea())

	_nPas:=0
	DbSelectArea("SH6")
	DbSetOrder(1)       // ORDEM 1: H6_FILIAL+H6_OP+H6_PRODUTO+H6_OPERAC+H6_SEQ+DTOS(H6_DATAINI)+H6_HORAINI+DTOS(H6_DATAFIN)+H6_HORAFIN
	DbGotop()

	conout("CHAVE: " + FWxFilial('SH6') + PADR(_cNumOP,14,' ') + _cProdut)

	Aadd(aCabec, {"H6_FILIAL"   , FWxFilial('SH6')			, Nil })
	Aadd(aCabec, {"H6_OP"		, _cNumOP	        	    , Nil })
	Aadd(aCabec, {"H6_OPERAC"	, _cOper				   	, Nil })
	aAdd(aCabec, {"H6_RECURSO"	, _cRecur 					, Nil })
	aAdd(aCabec, {"H6_PRODUTO"	, _cProdut     	    		, Nil })
	aAdd(aCabec, {"H6_OPERADO"	, _cOperado    	    		, Nil })
	Aadd(aCabec, {"H6_DTAPONT"	, cValToChar(_dDtApon)	    , Nil })
	Aadd(aCabec, {"H6_DTPROD"   , cValToChar(_dDtApon)		, Nil })
	Aadd(aCabec, {"H6_DATAINI"	, cValToChar(_dDtIni)		, Nil })
	//Aadd(aCabec, {"H6_HORAINI"	, _hHrIni					, Nil })
	Aadd(aCabec, {"H6_DATAFIN"	, cValToChar(_dDtFim)		, Nil })
	//Aadd(aCabec, {"H6_HORAFIN"	, _hHrFim					, Nil })
	Aadd(aCabec, {"H6_TEMPO"	, _hHrTotal				    , Nil })
	Aadd(aCabec, {"H6_QTDPROD"	, _nQtdPro 			        , Nil })
	aAdd(aCabec, {"H6_QTDPERD"	, _nQtdPer     				, Nil })
	aAdd(aCabec, {"H6_OBSERVA"	, "APP PRODUCAO"  , Nil })

	_cSaldo := U_CONSALDO()

	Begin Transaction
		if _cSaldo
			SetFunName("MATA681")
			MsExecAuto({|x, y| MATA681(x, y)} , aCabec , 3 ) //Inclusao
		else
			DisarmTransaction()			// Efetua um RollBack da transacao, desfaz as alteracoes (apontamento por operação)
			conout("ORDEM DE PRODUCAO NAO TEM SALDO!")
			SetRestFault(400, "ORDEM DE PRODUCAO NAO TEM SALDO!")
			lRet := .F.
			Return(lRet)
		endif

		if lMsErroAuto
			DisarmTransaction()			// Efetua um RollBack da transacao, desfaz as alteracoes (apontamento por operação)
			aLog  := GetAutoGRLog()

			for nCntLog := 1 To Len(aLog)
				if !Empty(cErro)
					cErro += CRLF
				endif
				cErro += aLog[nCntLog]
			next nCntLog

			conout("Falha MATA681")
			conout(cErro)
			SetRestFault(400, cErro)
			lRet := .F.

		else
			if Posicione("SB1",1,FWxFilial('SB1') + _cProdut, "B1_RASTRO" ) = "L"
				_cLote  := Posicione("SH6",2,FWxFilial('SH6') + _cProdut + _cNumOP, "H6_LOTECTL")
			else
				_cLote  := ''
			endif

			_cIdent   := ''
			_cNrSeq   := ''
			_cQrInfMv := ''

			if Select("QrInfMv") > 0
				Dbselectarea("QrInfMv")
				QrInfMv->(DbClosearea())
			endif

			_cQrInfMv := "SELECT D3_IDENT,D3_NUMSEQ "
			_cQrInfMv += "FROM " + RetSqlName("SD3") + " "
			_cQrInfMv += "WHERE D3_FILIAL = '" + FWxFilial('SD3') + "' AND D3_OP = '" + _cNumOP + "' "
			_cQrInfMv += "AND D3_TM = '110' AND D3_COD = '" + _cProdut + "' "
			_cQrInfMv += "AND D3_LOTECTL = '" + _cLote + "' AND " + RetSqlName("SD3") + ".D_E_L_E_T_ = ''  AND D3_ESTORNO <> 'S' "
			_cQrInfMv += "AND D3_EMISSAO = CONVERT(VARCHAR(8),GETDATE(),112) AND D3_QUANT = " + cValToChar(_nQtdPro) + ""
			_cQrInfMv := ChangeQuery(_cQrInfMv)

			TcQuery _cQrInfMv New Alias "QrInfMv"
			DbSelectArea("QrInfMv")
			QrInfMv->(DbGoTop())
			While !(QrInfMv->(Eof()))
				_cIdent := QrInfMv->D3_IDENT
				_cNrSeq := QrInfMv->D3_NUMSEQ
				DbSelectArea("QrInfMv")
				DbSkip()
			EndDo
			QrInfMv->(DbClosearea())

			// Altera data do campo D3_EMISSAO para igual data do campo H6_DTAPONT e H6_DTPROD
			_cUpdDtPr := "UPDATE " + RetSqlName("SD3") + " "
			_cUpdDtPr += "SET D3_EMISSAO = '" + DtoS(_dDtApon) + "' "
			_cUpdDtPr += "WHERE D3_FILIAL = '" + FWxFilial('SD3') + "' AND D3_OP = '" + _cNumOP + "' "
			_cUpdDtPr += "AND D3_IDENT = '" + _cIdent + "' "
			_cUpdDtPr += "AND " + RetSqlName("SD3") + ".D_E_L_E_T_ = ''  AND D3_ESTORNO <> 'S'"

			// Será executado o UPDATE apenas se o apontamento por operação for efetuado com êxito no EXECAUTO - UPDATE na tabela SD3
			conout('Qry atualiza SD3: ' + _cUpdDtPr)
			if TCSQLExec(_cUpdDtPr) < 0
				conout("TCSQLError: " + TCSQLError())
				DisarmTransaction()			// Efetua um RollBack da transacao, desfaz as alteracoes (apontamento por operação)
			else
				conout("UPDATE SD3 executado com sucesso!!!")

				if AllTrim(_cLote) <> ''
					_cUpdDtPr := ""

					// Altera data do campo D5_DATA para igual data do campo H6_DTAPONT e H6_DTPROD
					_cUpdDtPr := "UPDATE " + RetSqlName("SD5") + " "
					_cUpdDtPr += "SET D5_DATA = '" + DtoS(_dDtApon) + "' "
					_cUpdDtPr += "WHERE D5_FILIAL = '" + FWxFilial('SD5') + "' AND D5_OP = '" + _cNumOP + "' "
					_cUpdDtPr += "AND D5_NUMSEQ = '" + _cNrSeq + "' "
					_cUpdDtPr += "AND " + RetSqlName("SD5") + ".D_E_L_E_T_ = '' AND D5_ESTORNO <> 'S'"

					// Será executado o UPDATE apenas se o apontamento por operação for efetuado com êxito no EXECAUTO - UPDATE na tabela SD5
					conout('Qry atualiza SD5: ' + _cUpdDtPr)
					if TCSQLExec(_cUpdDtPr) < 0
						conout("TCSQLError: " + TCSQLError())
						DisarmTransaction()			// Efetua um RollBack da transacao, desfaz as alteracoes (apontamento por operação)
					else
						conout("UPDATE SD5 executado com sucesso!!!")

						// 08/09/2021 - Melhoria referente ao apontamento Retroativo
						_dDatLot  := Posicione("SB8",3,FWxFilial('SB8') + _cProdut + _cLocPrd + _cLote, "B8_DATA")
						if (_dDatLot > _dDtApon) .OR. (Empty(_dDatLot))
							_cUpdDtPr := ""

							// Altera data do campo B8_DATA (caso a mesma seja MAIOR) para igual data do campo H6_DTAPONT e H6_DTPROD
							_cUpdDtPr := "UPDATE " + RetSqlName("SB8") + " "
							_cUpdDtPr += "SET B8_DATA = '" + DtoS(_dDtApon) + "', B8_DFABRIC = '" + DtoS(_dDtApon) + "' "
							_cUpdDtPr += "WHERE B8_FILIAL = '" + FWxFilial('SB8') + "' AND B8_PRODUTO = '" + _cProdut + "' "
							_cUpdDtPr += "AND B8_LOCAL = '" + _cLocPrd + "' AND B8_LOTECTL = '" + _cLote + "' AND " + RetSqlName("SB8") + ".D_E_L_E_T_ = '' "
							_cUpdDtPr += "AND B8_DATA = CONVERT(VARCHAR(8),GETDATE(),112)"

							// Executa o UPDATE na tabela SB8
							conout('Qry atualiza SB8: ' + _cUpdDtPr)
							if TCSQLExec(_cUpdDtPr) < 0
								conout("TCSQLError: " + TCSQLError())
								DisarmTransaction()			// Efetua um RollBack da transacao, desfaz as alteracoes (apontamento por operação)
							else
								conout("UPDATE SB8 executado com sucesso!!!")
							endif
						endif
					endif
				endif
			endif

			_cUpdDtPr := ""
			lRet := .T.
			cJSONRet := '{ "APONTADA COM SUCESSO!" }'
			::SetResponse( cJSONRet )

		endif
	end Transaction

Return(lRet)

User Function CONSALDO()

	Local aSavAre   := GetArea()
	Local lRet      := .T.          // Var. de Retorno, caso tenha efetuado o ajuste de empenho com SUCESSO retorna .T. = True, senão .F. = False

	dbSelectArea("SH6")
	dbSetOrder(1)

	Do While ! Eof() .And. ALLTRIM(SH6->H6_OP) + ALLTRIM(SH6->H6_PRODUTO) + ALLTRIM(SH6->H6_OPERAC) == ALLTRIM(_cNumOP) + ALLTRIM(_cProdut) + ALLTRIM(_cOper)
		If SH6->H6_PT == "T"
			lRet := .F.
		EndIf

		SH6->(dbSkip())
	EndDo

	RestArea(aSavAre)

Return(lRet)

//------------------------------------------------------------------------------------------------------------------------------------------//
// Método POST - Realiza o apontamento de Perda - Via ExecAuto: MATA682                                                                     //
//------------------------------------------------------------------------------------------------------------------------------------------//
WSMETHOD POST WSSERVICE IMPROD

	Local cJSON 		  	:= Self:GetContent() // Pega a string do JSON
	Local oParseJSON 		:= Nil
	Local cJsonRet 		    := " "
	Local lRet 			    := .F.      // Var. de Retorno, caso tenha efetuado o ajuste de empenho com SUCESSO retorna .T. = True, senão .F. = False
	Local i

	Private lMsErroAuto     := .F.
	Private lMsHelpAuto     := .F.
	Private _cNumOP         := " "
	Private _cOper          := " "
	Private _cProdut        := " "
	Private lAutoErrNoFile  := .T.

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')	// 20/01/2022 - Definição do padrão de Data (dd/mm/yyyy) - Colocado p/ resolver problema com a exibição de Data qdo utilizado o REST

	conout("Rotina: POST IMPROD - Apontamento de Perda - MATA682")

	oParseJSON := JSonObject():New()
	cErr  	   := oParseJSON:fromJson(cJSON)

	If !empty(cErr)
		conout('Erro: ' + cErr)
		SetRestFault(400, cErr)
		lRet := .F.
		Return(lRet)
	Endif

	For i := 1 to VAL(oParseJSON:GetJSonObject('QTD_PARADAS')) //(len(oParseJSON["PARADAS"]))
		conout("Gravando... " + oParseJSON:GetJSonObject('QTD_PARADAS') + " paradas!")
		iF !Empty(oParseJSON["PARADAS"])//NOVO
			RecLock("SH6", .T.)
			SH6->H6_FILIAL 	:= xFilial()
			SH6->H6_RECURSO := oParseJSON:GetJSonObject('RECURSO2')
			SH6->H6_TIPO    := "I"
			SH6->H6_TIPOTEM := 1
			SH6->H6_DTPROD  := CTOD(oParseJSON:GetJSonObject('DATAEMISSAO'))
			SH6->H6_MOTIVO  := oParseJSON["PARADAS"][i]["MOTIVO"]  //UPPER(AllTrim(oParseJSON:GetJSonObject('motivo')))
			SH6->H6_OBSERVA := "APP PROD - " + oParseJSON:GetJSonObject('OBSERVA')
			SH6->H6_OPERADO := oParseJSON:GetJSonObject('OPERADOR')
			SH6->H6_DATAINI := CTOD(oParseJSON:GetJSonObject('DATAEMISSAO'))
			SH6->H6_DATAFIN := CTOD(oParseJSON:GetJSonObject('DATAEMISSAO'))
			SH6->H6_DTAPONT := CTOD(oParseJSON:GetJSonObject('DATAEMISSAO'))
			SH6->H6_HORAINI := oParseJSON["PARADAS"][i]["HRINIC2"] 	//oParseJSON:GetJSonObject('hora_parada')
			SH6->H6_HORAFIN := oParseJSON["PARADAS"][i]["HRFINAL2"] 	//oParseJSON:GetJSonObject('hora_retorno')
			SH6->H6_TEMPO   := oParseJSON["PARADAS"][i]["tempo_parada"] 	//oParseJSON:GetJSonObject('tempo_parada')
			MsUnlock()
		EndIf
	Next i

	cJSONRet := '{ "APONTADA COM SUCESSO!" }'
	::SetResponse( cJSONRet )
	lRet := .T.

Return(lRet)

//----------------------------------------------------------------------------------------------------------//
// Método POST - Realiza o apontamento da agenda de paradas programadas - tabela customizada (ZZ5)   		//
//----------------------------------------------------------------------------------------------------------//

WSMETHOD POST WSSERVICE AGENDAPARADA

	Local cJSON 		  := Self:GetContent() // Pega a string do JSON
	Local oParseJSON 	:= Nil
	Local cJsonRet 		:= " "
	Local lRet 			  := .F.      // Var. de Retorno, caso tenha efetuado o ajuste de empenho com SUCESSO retorna .T. = True, senão .F. = False

	Private lMsErroAuto     := .F.
	Private lMsHelpAuto     := .F.
	Private _cNumOP         := " "
	Private _cOper          := " "
	Private _cProdut        := " "
	Private lAutoErrNoFile  := .T.

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')	// 20/01/2022 - Definição do padrão de Data (dd/mm/yyyy) - Colocado p/ resolver problema com a exibição de Data qdo utilizado o REST

	conout("Rotina: POST AGENDAPARADA - Agenda de Parada")

	oParseJSON := JSonObject():New()
	cErr  	   := oParseJSON:fromJson(cJSON)

	If !empty(cErr)
		conout('Erro: ' + cErr)
		SetRestFault(400, cErr)
		lRet := .F.
		Return(lRet)
	Endif

	_cMotivo  := UPPER(AllTrim(oParseJSON:GetJSonObject('motivo')))
	_cRecur   := oParseJSON:GetJSonObject('recurso')
	_dDtApon  := CTOD(oParseJSON:GetJSonObject('data_apontamento'))
	_dDtIni   := CTOD(oParseJSON:GetJSonObject('data_inicio'))
	_dDtFim   := CTOD(oParseJSON:GetJSonObject('data_fim'))
	_dDtTempo := oParseJSON:GetJSonObject('tempo_parada')
	_hHrIni   := oParseJSON:GetJSonObject('hora_inicio')
	_hHrFim   := oParseJSON:GetJSonObject('hora_fim')
	_cOperado := oParseJSON:GetJSonObject('OPERADOR')
	_cObserv  := oParseJSON:GetJSonObject('observacao')

	CONOUT(_cOperado)

	RecLock("ZZ5", .T.)
	ZZ5_FILIAL 	:= xFilial()
	ZZ5_MOTIVO := _cMotivo
	ZZ5_RECURS := _cRecur
	ZZ5_DTAPON := _dDtApon
	ZZ5_DTINI  := _dDtIni
	ZZ5_DTFIM  := _dDtFim
	ZZ5_HORAIN := _hHrIni
	ZZ5_HORAFI := _hHrFim
	ZZ5_OPERAD := _cOperado
	ZZ5_TEMPO  := _dDtTempo
	ZZ5_OBS    := _cObserv
	ZZ5_DTINPU  := ddatabase
	ZZ5_USER    := PswChave(RetCodUsr())

	MsUnlock()

	cJSONRet := '{ "APONTADA COM SUCESSO!" }'
	::SetResponse( cJSONRet )
	lRet := .T.

Return(lRet)

//----------------------------------------------------------------------------------------------------------//
// Método POST - Realiza o apontamento do controle de qualidade - tabela customizada (ZZ3)   				//
//----------------------------------------------------------------------------------------------------------//

WSMETHOD POST WSSERVICE CONQUALIDADE

	Local cJSON 		  := Self:GetContent() // Pega a string do JSON
	Local oParseJSON 	:= Nil
	Local cJsonRet 		:= " "
	Local lRet 			  := .F.      // Var. de Retorno, caso tenha efetuado o ajuste de empenho com SUCESSO retorna .T. = True, senão .F. = False

	Private lMsErroAuto     := .F.
	Private lMsHelpAuto     := .F.
	Private _cNumOP         := " "
	Private _cOper          := " "
	Private _cProdut        := " "
	Private lAutoErrNoFile  := .T.

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')	// 20/01/2022 - Definição do padrão de Data (dd/mm/yyyy) - Colocado p/ resolver problema com a exibição de Data qdo utilizado o REST

	conout("Rotina: POST CONQUALIDADE - Apontamento Controle de Qualidade")

	oParseJSON := JSonObject():New()
	cErr  	   := oParseJSON:fromJson(cJSON)

	If !empty(cErr)
		conout('Erro: ' + cErr)
		SetRestFault(400, cErr)
		lRet := .F.
		Return(lRet)
	Endif

	//===== CABECALHO ===========
	_cNumOP2  := oParseJSON:GetJSonObject('ordem')
	_cOperado := oParseJSON:GetJSonObject('operacao')
	_cProdut  := Posicione("SC2",1,FWxFilial('SC2') + _cNumOP2 , "C2_PRODUTO")
	_dDtApon  := oParseJSON:GetJSonObject('data')
	_cLider   := oParseJSON:GetJSonObject('lider')
	_cSetor   := oParseJSON:GetJSonObject('setor')

	//===== ITENS ===========

	_cTear     := oParseJSON:GetJSonObject('maquina')
	_nPeso     := oParseJSON:GetJSonObject('peso_encontrado')
	_nStaPeso  := oParseJSON:GetJSonObject('status_peso')

	_nLargura   := oParseJSON:GetJSonObject('largura_encontrada')
	_nStaLarg   := oParseJSON:GetJSonObject('status_largura')

	_nSombra   := oParseJSON:GetJSonObject('sombra_encontrada')
	_nStaSom   := oParseJSON:GetJSonObject('status_sombra')

	_nComp 	   := oParseJSON:GetJSonObject('comprimento_encontrado')
	_nStacomp  := oParseJSON:GetJSonObject('status_comprimento')

	_nQtdFardo  := oParseJSON:GetJSonObject('qtd_fardo')

	RecLock("ZZ3", .T.)
	ZZ3_FILIAL 	:= xFilial()
	ZZ3_OP      := _cNumOP2
	ZZ3_PRODUT  := _cProdut
	ZZ3_DATA    := ddatabase //_dDtIni
	ZZ3_SETOR   := _cSetor
	ZZ3_LIDER   := _cLider
	ZZ3_TEAR    := _cTear
	ZZ3_PESO    := _nPeso
	ZZ3_STATUS  := _nStaPeso
	ZZ3_COMPRE  := _nComp
	ZZ3_STATU4  := _nStacomp
	ZZ3_LARGUR	:= _nLargura
	ZZ3_STATU2  := _nStaLarg
	ZZ3_SOMBRA  := _nSombra
	ZZ3_STATU3  := _nStaSom
	ZZ3_QTDFAR  := 	_nQtdFardo
	ZZ3_DTINPU  := ddatabase
	ZZ3_USER    := PswChave(RetCodUsr())
	MsUnlock()

	cJSONRet := '{ "APONTADA COM SUCESSO!" }'
	::SetResponse( cJSONRet )
	lRet := .T.

Return(lRet)


//----------------------------------------------------------------------------------------------------------//
// Método POST - Realiza o apontamento das trocas dos turnos - tabela customizada (ZZ4)   					//
//----------------------------------------------------------------------------------------------------------//

WSMETHOD POST WSSERVICE TROCATURNO

	Local cJSON 		  := Self:GetContent() // Pega a string do JSON
	Local oParseJSON 	  := Nil
	Local cJsonRet 		  := " "
	Local lRet 			  := .F.      // Var. de Retorno, caso tenha efetuado o ajuste de empenho com SUCESSO retorna .T. = True, senão .F. = False
	Local i
	Local cQrydup		  := ""
	Local nCount	      := 0

	Private lMsErroAuto     := .F.
	Private lMsHelpAuto     := .F.
	Private _cNumOP         := " "
	Private _cOper          := " "
	Private _cProdut        := " "
	Private lAutoErrNoFile  := .T.

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')	// 20/01/2022 - Definição do padrão de Data (dd/mm/yyyy) - Colocado p/ resolver problema com a exibição de Data qdo utilizado o REST

	conout("Rotina: POST TROCATURNO - Apontamento Troca de Turno")
	conout(cJSON)

	oParseJSON := JSonObject():New()
	cErr  	   := oParseJSON:fromJson(cJSON)

	If !empty(cErr)
		conout('Erro: ' + cErr)
		SetRestFault(400, cErr)
		lRet := .F.
		Return(lRet)
	Endif

	//======= verificacao de duplicidade ==============

	If Select("QRYZZ4") > 0
		DbSelectArea("QRYZZ4")
		QRYZZ4->(DbCloseArea())
	EndIf

	cQrydup := "SELECT * "
	cQrydup += " FROM " + RetSqlName("ZZ4") + " AS ZZ4 "
	cQrydup += " WHERE ZZ4.ZZ4_FILIAL = '" + FWxFilial('ZZ4') + "' AND ZZ4. D_E_L_E_T_ = '' "
	cQrydup += " AND ZZ4_TURNO = '" + cValtoChar(oParseJSON:GetJSonObject('turno')) + "' "
	cQrydup += " AND ZZ4_SETOR = '" + oParseJSON:GetJSonObject('setor') + "' "
	cQrydup += " AND ZZ4_OPERAD = '" + oParseJSON:GetJSonObject('operador_lider') + "' "
	cQrydup += " AND ZZ4_DTINPU = '" + DTOS(CTOD(oParseJSON:GetJSonObject('data'))) + "' "

	conout("Query Reg. Duplicado na ZZ4: " + cQrydup)

	// Transpilando o código SQL para o Banco configurado e criando o ALIAS que será utilizado
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrydup),"QRYZZ4",.T.,.T.)
	Count to nCount

	If nCount > 0
		ALERT("JÁ EXISTE LANCAMENTO PARA ESSE TURNO/DATA!")
		cJSONRet := "error"
		::SetResponse( cJSONRet )
		lRet := .F.
		Return
	Else
		For i := 1 to (len(oParseJSON["list"]))

			iF !Empty(oParseJSON["list"])//NOVO
				IF !Empty(oParseJSON["list"][i]["maquina"])
					RecLock("ZZ4", .T.)
					ZZ4_FILIAL 	:= xFilial()
					ZZ4_TURNO   := cValtoChar(oParseJSON:GetJSonObject('turno'))
					ZZ4_DTINPU  := CTOD(oParseJSON:GetJSonObject('data'))
					ZZ4_EMISSA  := ddatabase
					ZZ4_HORARI  := time()
					ZZ4_SETOR	:= oParseJSON:GetJSonObject('setor')
					ZZ4_OPERAD  := oParseJSON:GetJSonObject('operador_lider')
					ZZ4_RECURS  := oParseJSON["list"][i]["maquina"]
					ZZ4_PRODUT  := oParseJSON["list"][i]["produtividade"]
					ZZ4_RPM     := oParseJSON["list"][i]["rpm"]

					IF oParseJSON["list"][i]["houve_parada"] == .t.
						ZZ4_PARADA  := "S"
					ELSE
						ZZ4_PARADA  := "N"
					ENDIF

					ZZ4_OBS		:= oParseJSON["list"][i]["observacao"]
					ZZ4_USER    := PswChave(RetCodUsr())
					ZZ4->(MsUnlock() )
				EndIf
			Endif
		Next i

		CONOUT("TROCA DE TURNO APONTADA COM SUCESSO!")
		cJSONRet := '{ "TROCA DE TURNO APONTADA COM SUCESSO!" }'
		::SetResponse( cJSONRet )
		lRet := .T.
	EndIf

Return(lRet)

//-----------------------------------------------------------------------------------------------------//
// Método POST - Realiza a abertura da OP - Via ExecAuto: MATA650                                      //
//-----------------------------------------------------------------------------------------------------//

WSMETHOD POST WSSERVICE ABEROP

	Local aMATA650      := {} //-Array com os campos
	LOCAL DDATABASE     := CTOD("08/11/2018")
	Local cJSON 		:= Self:GetContent() // Pega a string do JSON
	Local oParseJSON 	:= Nil
	Local cJsonRet 		:= " "
	Local nOpc          := 3 //3 - Inclusao
	Local lRet 			:= .F.        // Var. de Retorno, caso tenha efetuado o ajuste de empenho com SUCESSO retorna .T. = True, senão .F. = False
	Local aLog        	:= {}         // Array para receber erro log da rotina executada via MsExecAuto
	Local nCntLog     	:= 0          // Contador do laço de repetição para tratativa de possivel erro log

	Private lMsErroAuto := .F.

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')	// 20/01/2022 - Definição do padrão de Data (dd/mm/yyyy) - Colocado p/ resolver problema com a exibição de Data qdo utilizado o REST

	conout("Rotina: POST ABEROP - Abertura Ordem de Produção - MATA650")

	oParseJSON := JSonObject():New()
	cErr  	   := oParseJSON:fromJson(cJSON)

	IF !empty(cErr)
		conout('Erro: ' + cErr)
		SetRestFault(400, cErr)
		lRet := .F.
		Return(lRet)
	Endif

	/*
	_cNumOP   := oParseJSON:GetJSonObject('NUMOP')
	_cOper    := oParseJSON:GetJSonObject('OPERACAO')
	_cRecur   := oParseJSON:GetJSonObject('RECURSO')
	_cOperado := oParseJSON:GetJSonObject('OPERADOR')
	_hHrIni   := oParseJSON:GetJSonObject('HRINIC')
	_hHrFim   := oParseJSON:GetJSonObject('HRFINAL')
	_hHrTotal := oParseJSON:GetJSonObject('tempo_total')
	_dDtIni   := ddatabase //oParseJSON:GetJSonObject('DTINIC')
	_dDtFim   := ddatabase //oParseJSON:GetJSonObject('DTFINAL')
	_dDtApon  := ddatabase //oParseJSON:GetJSonObject('DTFINAL')
	_nQtdPro  := Val(StrTran(oParseJSON:GetJSonObject('QTDPROD'),",","."))

	Aadd(aMATA650, {"C2_FILIAL"   	, FWxFilial('SH6')			  , Nil })
	//Aadd(aMATA650, {"C2_NUM"   	    , FWxFilial('SH6')			  , Nil })
	//Aadd(aMATA650, {"C2_SEQUEN"   	, FWxFilial('SH6')			  , Nil })
	Aadd(aMATA650, {"C2_PRODUTO"   	, FWxFilial('SH6')			  , Nil })
	Aadd(aMATA650, {"C2_LOCAL"   	  , FWxFilial('SH6')			  , Nil })
	Aadd(aMATA650, {"C2_QUANT"   	  , FWxFilial('SH6')			  , Nil })
	Aadd(aMATA650, {"C2_DATPRI"   	, FWxFilial('SH6')			  , Nil })
	Aadd(aMATA650, {"C2_DATPRF"   	, FWxFilial('SH6')			  , Nil })
	Aadd(aMATA650, {"C2_ZZTEAR"   	, FWxFilial('SH6')			  , Nil })
	Aadd(aMATA650, {"C2_OBS"   	    , FWxFilial('SH6')			  , Nil })
	Aadd(aMATA650, {"C2_ROTEIRO"    , FWxFilial('SH6')			  , Nil })
	Aadd(aMATA650, {"C2_TPPR"       , FWxFilial('SH6')			  , Nil })
	Aadd(aMATA650, {"C2_OPTERCE"    , FWxFilial('SH6')			  , Nil })
	Aadd(aMATA650, {"AUTEXPLODE"   	, 'S'			                , Nil })

	msExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)

	If lMsErroAuto
		DisarmTransaction()			// Efetua um RollBack da transacao, desfaz as alteracoes (apontamento por operação)
		aLog  := GetAutoGRLog()

		for nCntLog := 1 To Len(aLog)
		if !Empty(cErro)
			cErro += CRLF
		endif
		cErro += aLog[nCntLog]
		next nCntLog

		conout(cErro)
		SetRestFault(400, cErro)
		lRet := .F.

		Else
		cJSONRet := '{ "OP ABERTA COM SUCESSO!" }'
		::SetResponse( cJSONRet )
		lRet := .T.
		EndIf

	ConOut("Fim : "+Time())
	*/
Return(lRet)

//---------------------------------------------------------------------------------------------------//
// Método GET - Retorna setor cadastrado.		                                                     //
//---------------------------------------------------------------------------------------------------//

WSMETHOD GET WSRECEIVE type WSSERVICE SETOR

	Local cJson		:= ""
	Local cQrySetor	:= ""
	Local lRet 		:= .T.
	Local cAlias	:= GetNextAlias()
	Local cTipo		:= IIF(!Empty(self:type),self:type,'')


	conout("Rotina: GET SETOR - Retorna setor cadastrado")
	::SetContentType("application/json")

	// Qry para retornar os dados Ordem de Produção em questão
	cQrySetor += "	SELECT " + CRLF
	cQrySetor += "		ZZ6_CODIGO " + CRLF
	cQrySetor += "		,ZZ6_DESC " + CRLF
	cQrySetor += "		,ZZ6_OBS " + CRLF
	cQrySetor += "		,ZZ6_TIPO " + CRLF
	cQrySetor += "	FROM " + CRLF
	cQrySetor += "		" + RetSqlTab("ZZ6") + CRLF
	cQrySetor += "	WHERE " + CRLF
	cQrySetor += "		1 = 1 " + CRLF
	cQrySetor += "		AND" + RetSqlFil("ZZ6") + CRLF
	cQrySetor += "		AND" + RetSqldEL("ZZ6") + CRLF
	If !Empty(cTipo)
		cQrySetor += "		AND ZZ6_TIPO = " + ValToSql(cTipo) + CRLF
	EndIf
	cQrySetor += "	ORDER BY " + CRLF
	cQrySetor += "		ZZ6_CODIGO " + CRLF

	conout("Qry de busca de setor: " + cQrySetor)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySetor), cAlias,.T.,.T.)

	If (cAlias)->(!EoF())
		cJson += '{'
		cJson += '	"setor": ['

		While (cAlias)->(!EoF())

			cJson += '{'
			cJson += '	"code": "' + Alltrim((cAlias)->ZZ6_CODIGO) + '",'
			cJson += '	"description": "' + Alltrim((cAlias)->ZZ6_DESC) + '",'
			cJson += '	"type": "' + Alltrim((cAlias)->ZZ6_TIPO) + '"'
			cJson += '}'

			(cAlias)->(dbSkip())

			If (cAlias)->(!EoF())
				cJson += ','
			EndIf
		EndDo

		cJson += '	]'
		cJson += '}'
	EndIf

	(cAlias)->(DbCloseArea())

	::SetResponse(cJson)

Return (lRet)

//---------------------------------------------------------------------------------------------------//
// Método GET - Retorna cor disponíveis para apontamento de bobina. 								 //
//---------------------------------------------------------------------------------------------------//
WSMETHOD GET WSSERVICE CORBOBINA
	Local cJson		:= ""
	Local cQryCorBobina	:= ""
	Local lRet 		:= .T.
	Local cAlias	:= GetNextAlias()


	conout("Rotina: GET CORBOBINA - Retorna cor disponíveis para apontamento de bobina.")
	::SetContentType("application/json")

	// Qry para retornar os dados Ordem de Produção em questão
	cQryCorBobina += "	SELECT " + CRLF
	cQryCorBobina += "		Z4_COR " + CRLF
	cQryCorBobina += "	FROM " + CRLF
	cQryCorBobina += "		" + RetSqlTab("SZ4") + CRLF
	cQryCorBobina += "	WHERE " + CRLF
	cQryCorBobina += "		1 = 1 " + CRLF
	cQryCorBobina += "		AND" + RetSqlFil("SZ4") + CRLF
	cQryCorBobina += "		AND" + RetSqldEL("SZ4") + CRLF

	conout("Qry de busca de cor de bobina: " + cQryCorBobina)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCorBobina), cAlias,.T.,.T.)

	If (cAlias)->(!EoF())
		cJson += '{'
		cJson += '	"dados": ['

		While (cAlias)->(!EoF())

			cJson += '{'
			cJson += '	"cor": "' + Alltrim((cAlias)->Z4_COR) + '"
			cJson += '}'

			(cAlias)->(dbSkip())

			If (cAlias)->(!EoF())
				cJson += ','
			EndIf
		EndDo

		cJson += '	]'
		cJson += '}'
	EndIf

	(cAlias)->(DbCloseArea())

	::SetResponse(EncodeUtf8(cJson))

Return (lRet)

//---------------------------------------------------------------------------------------------------//
// Método GET - Ordem de produção apta a cadastrar aparas                                            //
//---------------------------------------------------------------------------------------------------//

WSMETHOD GET WSRECEIVE type, resource WSSERVICE OPAPARA

	Local cJson			:= ""
	Local cQueryOrdem	:= ""
	Local lRet 			:= .T.
	Local cAlias		:= GetNextAlias()
	Local cTipoOP		:= IIF(!Empty(self:type),self:type,'')
	Local cRecurso		:= IIF(!Empty(self:resource),self:resource,'')

	conout("Rotina: GET OPAPARA - Retornar OP apta a cadastrar apara")
	::SetContentType("application/json")

	// Qry para retornar os dados Ordem de Produção em questão

	cQueryOrdem += "SELECT " + CRLF
	cQueryOrdem += "	* " + CRLF
	cQueryOrdem += "FROM ( " + CRLF
	cQueryOrdem += "	SELECT " + CRLF
	cQueryOrdem += "		(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) OP " + CRLF
	cQueryOrdem += "		,C2_PRODUTO " + CRLF
	cQueryOrdem += "		,H1_CTRAB AS TYPE " + CRLF
	cQueryOrdem += "		,C2_ZZTEAR " + CRLF
	cQueryOrdem += "	FROM " + CRLF
	cQueryOrdem += "		" + RetSqlTab("SC2") + CRLF

	cQueryOrdem += "		INNER JOIN " + RetSqlTab("SB1") + " ON 1 = 1 " + CRLF
	cQueryOrdem += "			AND " + RetSqlFil("SB1") + CRLF
	cQueryOrdem += "			AND B1_COD = C2_PRODUTO " + CRLF
	cQueryOrdem += "			AND" + RetSqlDel("SB1") + CRLF

	cQueryOrdem += "		LEFT JOIN " + RetSqlTab("SH1") + " ON 1 = 1 " + CRLF
	cQueryOrdem += "			AND H1_FILIAL = C2_FILIAL " + CRLF
	cQueryOrdem += "			AND H1_CODIGO = C2_ZZTEAR " + CRLF
	cQueryOrdem += "			AND" + RetSqlDel("SH1") + CRLF

	cQueryOrdem += "	WHERE " + CRLF
	cQueryOrdem += "		1 = 1 " + CRLF
	cQueryOrdem += "		AND C2_TPOP = 'F' " + CRLF
	cQueryOrdem += "		AND C2_DATRF = ' ' " + CRLF
	cQueryOrdem += "		AND CONCAT(H1_CTRAB, B1_GRUPO) NOT IN ('TEAR4010', 'EMB4010') " + CRLF
	cQueryOrdem += "		AND" + RetSqlDel("SC2") + CRLF

	cQueryOrdem += "	GROUP BY " + CRLF
	cQueryOrdem += "		C2_NUM " + CRLF
	cQueryOrdem += "		,C2_ITEM " + CRLF
	cQueryOrdem += "		,C2_SEQUEN " + CRLF
	cQueryOrdem += "		,C2_ITEMGRD " + CRLF
	cQueryOrdem += "		,C2_PRODUTO " + CRLF
	cQueryOrdem += "		,H1_CTRAB " + CRLF
	cQueryOrdem += "		,C2_ZZTEAR " + CRLF
	cQueryOrdem += "		,B1_TIPO " + CRLF
	cQueryOrdem += ") SUBQRY " + CRLF
	cQueryOrdem += "WHERE " + CRLF
	cQueryOrdem += "	1 = 1 " + CRLF
	If !Empty(cTipoOP)
		cQueryOrdem += "	AND TYPE = " + ValToSql(cTipoOP) + CRLF
	EndIf
	If !Empty(cRecurso)
		cQueryOrdem += "	AND C2_ZZTEAR = " + ValToSql(cRecurso) + CRLF
	EndIf

	conout("Qry de busca de OP: " + cQueryOrdem)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryOrdem), cAlias,.T.,.T.)

	If (cAlias)->(!EoF())
		cJson += '{'
		cJson += '	"ordem": ['

		While (cAlias)->(!EoF())

			cJson += '{'
			cJson += '	"code": "' + Alltrim((cAlias)->OP) + '",'
			cJson += '	"product": "' + Alltrim((cAlias)->C2_PRODUTO) + '",'
			cJson += '	"type": "' + Alltrim((cAlias)->TYPE) + '",'
			cJson += '	"resource": "' + Alltrim((cAlias)->C2_ZZTEAR) + '"'
			cJson += '}'

			(cAlias)->(dbSkip())

			If (cAlias)->(!EoF())
				cJson += ','
			EndIf
		EndDo

		cJson += '	]'
		cJson += '}'
		::SetResponse(cJson)
		self:setStatus(200)
	Else
		cJson += '{'
		cJson += '	"erro": "Nao existe OP cadastrada"'
		cJson += '}'
		::SetResponse(cJson)
		self:setStatus(400)
	EndIf

	(cAlias)->(DbCloseArea())

Return (lRet)

//---------------------------------------------------------------------------------------------------//
// Método GET - Retorna motivo de cadastro de apara		                                            //
//---------------------------------------------------------------------------------------------------//

WSMETHOD GET WSSERVICE MOTIVO

	Local cJson			:= ""
	Local nRecord		:= 0
	Local lRet 			:= .T.
	Local aSX543		:= {}

	conout("Rotina: GET MOTIVO - Retornar motivo de cadastro de apara")
	::SetContentType("application/json")

	aSX543 := FwGetSX5("43")

	If Len(aSX543) > 0
		cJson += '{'
		cJson += '	"motivo": ['

		For nRecord := 1 To Len(aSX543)
			cJson += '{'
			cJson += '	"code": "' + Alltrim(aSX543[nRecord, 3]) + '",'
			cJson += '	"description": "' + Alltrim(aSX543[nRecord, 4]) + '"'
			cJson += '}'

			If nRecord <> Len(aSX543)
				cJson += ','
			EndIf

		Next nRecord

		cJson += '	]'
		cJson += '}'

		::SetResponse(cJson)
		self:setStatus(200)
	Else
		cJson += '{'
		cJson += '	"erro": "Nao existe motivo cadastrado"'
		cJson += '}'
		::SetResponse(cJson)
		self:setStatus(400)
	EndIf

Return (lRet)

//---------------------------------------------------------------------------------------------------//
// Método GET - Retorna centro de trabalho cadastrado na SHB                                         //
//---------------------------------------------------------------------------------------------------//

WSMETHOD GET WSSERVICE CENTROTRABALHO

	Local cJson			:= ""
	Local lRet 			:= .T.
	Local cAlias		:= GetNextAlias()
	Local cQueryCTR		:= ""

	conout("Rotina: GET CENTRO TRABALHO - Retornar cadastro de centro de trabalho")
	::SetContentType("application/json")

	cQueryCTR += "	SELECT " + CRLF
	cQueryCTR += "		HB_COD " + CRLF
	cQueryCTR += "		,HB_NOME " + CRLF
	cQueryCTR += "	FROM " + CRLF
	cQueryCTR += "		" + RetSqlTab("SHB") + CRLF
	cQueryCTR += "	WHERE " + CRLF
	cQueryCTR += "		1 = 1 " + CRLF
	cQueryCTR += "		AND " + RetSqlDel("SHB") + CRLF

	conout("Qry de busca de centro trabalho: " + cQueryCTR)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCTR), cAlias,.T.,.T.)

	If (cAlias)->(!Eof())
		cJson += '{'
		cJson += '	"data": ['

		While (cAlias)->(!Eof())
			cJson += '{'
			cJson += '	"code": "' + Alltrim((cAlias)->HB_COD) + '",'
			cJson += '	"description": "' + Alltrim((cAlias)->HB_NOME) + '"'
			cJson += '}'

			(cAlias)->(dbskip())

			If (cAlias)->(!Eof())
				cJson += ','
			EndIf

		EndDo

		cJson += '	]'
		cJson += '}'

		::SetResponse(EncodeUTF8(cJson, "cp1252"))
		self:setStatus(200)
	Else
		cJson += '{'
		cJson += '	"erro": "Nao existe centro de trabalho cadastrado"'
		cJson += '}'
		::SetResponse(EncodeUTF8(cJson, "cp1252"))
		self:setStatus(400)
	EndIf

	(cAlias)->(DBCLOSEAREA())

Return (lRet)

//---------------------------------------------------------------------------------------------------//
// Método POST - Cadastra apara.				                                                     //
//---------------------------------------------------------------------------------------------------//

WSMETHOD POST WSSERVICE APARA
	Local lRet 		:= .T.

	Private oRet 	:= JsonObject():new()

	lRet := u_APICadApara(::GetContent())

	If lRet
		self:setStatus(200)
		oRet['status'] := "success"
	Else
		self:setStatus(400)
		oRet['status'] := "false"
	EndIf

	::SetResponse(oRet)

Return (lRet)


WSMETHOD POST WSSERVICE PRODUCAO2

	Local cJSON 		:= Self:GetContent() // Pega a string do JSON
	Local oParseJSON 	:= Nil
	Local cJsonRet 		:= " "
	Local cErro 		:= " "
	Local aLog        	:= {}         // Array para receber erro log da rotina executada via MsExecAuto
	Local nCntLog     	:= 0          // Contador do laço de repetição para tratativa de possivel erro log
	Local lRet 			:= .F.        // Var. de Retorno, caso tenha efetuado o ajuste de empenho com SUCESSO retorna .T. = True, senão .F. = False
	Local aCabec 		:= {}
	Local _nQtdFal    	:= 0          // Qtde Faltante para terminar OP (C2_QUANT - C2_QUJE - C2_PERDA) // 23/05/2021 - MAC
	Local _cLocPrd    	:= ''         // Local da Produção
	Local cTurno		:= ""

	Local _LARGBOBINA	:= 0
	Local _CORBOBINA	:= ""
	Local _MICRAS		:= ""
	Local _CORTE		:= 0
	Local _TRAMA		:= ""

	Private lMsErroAuto     := .F.
	Private lMsHelpAuto     := .F.
	Private _cNumOP         := " "
	Private _cOper          := " "
	Private _cProdut        := " "
	Private lAutoErrNoFile  := .T.
	Private lApp:=.T.

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')	// 20/01/2022 - Definição do padrão de Data (dd/mm/yyyy) - Colocado p/ resolver problema com a exibição de Data qdo utilizado o REST

	conout("Rotina: POST PRODUCAO - Apont. Prod. por Operação - MATA681")

	oParseJSON := JSonObject():New()
	cErr  	   := oParseJSON:fromJson(cJSON)

	if !empty(cErr)
		conout('Erro: ' + cErr)
		SetRestFault(400, cErr)
		lRet := .F.
		Return(lRet)
	endif

	_NUMOP      := oParseJSON:GetJSonObject('NUMOP')
	_PRODUTO    := oParseJSON:GetJSonObject('PRODUTO')
	_OPERACAO   := oParseJSON:GetJSonObject('OPERACAO')
	_RECURSO    := oParseJSON:GetJSonObject('RECURSO')
	_OPERADOR   := oParseJSON:GetJSonObject('OPERADOR')
	_CODOPERADOR:= oParseJSON:GetJSonObject('CODOPERADOR')
	_DTINICIAL  := oParseJSON:GetJSonObject('DTINICIAL')
	_HRINIC     := oParseJSON:GetJSonObject('HRINIC')
	_DTFINAL    := oParseJSON:GetJSonObject('DTFINAL')
	_HRFINAL    := oParseJSON:GetJSonObject('HRFINAL')
	_QTDMULT    := oParseJSON:GetJSonObject('QTDMULT')
	_QTDPROD    := oParseJSON:GetJSonObject('QTDPROD')
	_QTDPRODKG  := oParseJSON:GetJSonObject('QTDPRODKG')
	_ARMAZEM    := oParseJSON:GetJSonObject('ARMAZEM')
	_OBS        := oParseJSON:GetJSonObject('OBS')
	_USER       := oParseJSON:GetJSonObject('USERLOG')

	If oParseJSON:hasProperty('LARGBOBINA')
		_LARGBOBINA := oParseJSON:GetJSonObject('LARGBOBINA')
	EndIf
	If oParseJSON:hasProperty('CORBOBINA')
		_CORBOBINA  := oParseJSON:GetJSonObject('CORBOBINA')
	EndIf
	If oParseJSON:hasProperty('MICRAS')
		_MICRAS     := oParseJSON:GetJSonObject('MICRAS')
	EndIf
	If oParseJSON:hasProperty('CORTE')
		_CORTE      := oParseJSON:GetJSonObject('CORTE')
	EndIf
	If oParseJSON:hasProperty('TRAMA')
		_TRAMA      := oParseJSON:GetJSonObject('TRAMA')
	EndIf
	cTurno		:= u_getTurnoApontamento(_HRINIC)

	DbSelectArea("SC2")
	DbSetOrder(1)
	DbGoToP()

	if MsSeek( FWxFilial('SC2') + _NUMOP )
		_cProdut  := SC2->C2_PRODUTO
		_nQtdFal  := SC2->C2_QUANT
		_cLocPrd  := SC2->C2_LOCAL
	endif

	SC2->(DbCloseArea())

	_nPas:=0
	DbSelectArea("SH6")
	DbSetOrder(1)       // ORDEM 1: H6_FILIAL+H6_OP+H6_PRODUTO+H6_OPERAC+H6_SEQ+DTOS(H6_DATAINI)+H6_HORAINI+DTOS(H6_DATAFIN)+H6_HORAFIN
	DbGotop()

	conout("CHAVE: " + FWxFilial('SH6') + PADR(_cNumOP,14,' ') + _cProdut)

	Aadd(aCabec, {"H6_FILIAL"   , FWxFilial('SH6')			, Nil })
	Aadd(aCabec, {"H6_OP"		, _NUMOP	        	    , Nil })
	Aadd(aCabec, {"H6_OPERAC"	, _OPERACAO				   	, Nil })
	aAdd(aCabec, {"H6_RECURSO"	, _RECURSO 					, Nil })
	aAdd(aCabec, {"H6_PRODUTO"	, _cProdut     	    		, Nil })
	aAdd(aCabec, {"H6_OPERADO"	, _OPERADOR    	    		, Nil })
	aAdd(aCabec, {"H6_ZZOPER"	, _CODOPERADOR    	    	, Nil })
	Aadd(aCabec, {"H6_DATAINI"	, CTOD(_DTINICIAL)		, Nil })
	Aadd(aCabec, {"H6_HORAINI"	, _HRINIC					, Nil })
	Aadd(aCabec, {"H6_DATAFIN"	, CTOD(_DTFINAL)		, Nil })
	Aadd(aCabec, {"H6_HORAFIN"	, _HRFINAL					, Nil })
	Aadd(aCabec, {"H6_ZZMULTP"	, _QTDMULT				    , Nil })
	Aadd(aCabec, {"H6_QTDPROD"	, _QTDPROD 			        , Nil })
	aAdd(aCabec, {"H6_ZQTPRO2"	, _QTDPRODKG     				, Nil })
	aAdd(aCabec, {"H6_LOCAL  "	, _ARMAZEM  , Nil })
	aAdd(aCabec, {"H6_ZZOBS    ", _OBS  , Nil })
	aAdd(aCabec, {"H6_XUSER    ", _USER  , Nil })
	aAdd(aCabec, {"H6_ZZDTURN"  , cTurno , Nil })

	aAdd(aCabec, {"H6_ZZLARG"	, _LARGBOBINA	, Nil})
	aAdd(aCabec, {"H6_ZZCOR"	, _CORBOBINA	, Nil})
	aAdd(aCabec, {"H6_ZZMICRA"	, _MICRAS		, Nil})
	aAdd(aCabec, {"H6_ZQCORTE"	, _CORTE		, Nil})
	aAdd(aCabec, {"H6_ZTRAMA"	, _TRAMA		, Nil})

	FwVetByDic(aCabec, "SH6", .F.)
	_cSaldo := U_CONSALDO()


	if _cSaldo
		//SetFunName("MATA681")
		MsExecAuto({|x, y| MATA681(x, y)} , aCabec , 3 ) //Inclusao
	else

		conout("ORDEM DE PRODUCAO NAO TEM SALDO!")
		SetRestFault(400, "ORDEM DE PRODUCAO NAO TEM SALDO!")
		lRet := .F.
		Return(lRet)
	endif

	if lMsErroAuto
		// Efetua um RollBack da transacao, desfaz as alteracoes (apontamento por operação)
		aLog  := GetAutoGRLog()

		for nCntLog := 1 To Len(aLog)
			if !Empty(cErro)
				cErro += CRLF
			endif
			cErro += aLog[nCntLog]
		next nCntLog

		conout("Falha MATA681")
		conout(cErro)
		SetRestFault(400, cErro)
		lRet := .F.

	else
		lRet := .T.
		cJSONRet := '{ "mensagem": "APONTADA COM SUCESSO!", "identificador": "' + SH6->H6_OP + SH6->H6_IDENT + '"}'
		//reclock("SH6",.F.)
		//SH6->H6_DATAINI:=CTOD(_DTINICIAL), Nil })
		//SH6->H6_DATAFIN:=CTOD(_DTFINAL)
		//	SH6->(msunlock())
		::SetResponse( cJSONRet )

	endif


Return(lRet)




//---------------------------------------------------------------------------------------------------//
// Método GET - Retorna os dados especificos da Ordem de produção modelo 2.                                   //
//---------------------------------------------------------------------------------------------------//

WSMETHOD GET QUERYPARAM CNUMOP WSSERVICE OPSB52

	Local aFiltros      := Self:aQueryString
	Local aOpSB5        := {}
	Local aColunas      := {}
	Local nTotReg       := 0    // Quantidade de registros retornados da Query
	Local lRet 			    := .T.
	Local cJson:=""

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')	// 20/01/2022 - Definição do padrão de Data (dd/mm/yyyy) - Colocado p/ resolver problema com a exibição de Data qdo utilizado o REST

	conout("Rotina: GET OPSB5 - Retorna os dados da OP.")

	::SetContentType("application/json")

	if Len(aFiltros) > 0

		// Inicio tratativa para verificar o preenchimento da Operação no momento da caonsulta do Empenho - 24/11/2021
		if Select("cQrOpSB5") > 0
			DbSelectArea("cQrOpSB5")
			cQrOpSB5->(DbCloseArea())
		endif

		// Qry para retornar os dados Ordem de Produção em questão
		cQrOpSB5 := "SELECT * "
		cQrOpSB5 += " FROM " + RetSqlName("SC2") + " AS SC2, "  + RetSqlName("SB1") + " AS SB1 "
		cQrOpSB5 += " WHERE SC2.C2_FILIAL = '" + FWxFilial('SC2') + "' "
		cQrOpSB5 += " AND SB1.D_E_L_E_T_ = '' AND SC2.D_E_L_E_T_ = '' "
		cQrOpSB5 += " AND SB1.B1_COD = SC2.C2_PRODUTO "
		cQrOpSB5 += " AND SC2.C2_NUM = '" + SubStr(aFiltros[1][2],1,6) + "' "
		cQrOpSB5 += " AND SC2.C2_ITEM = '" + SubStr(aFiltros[1][2],7,2) + "' "
		cQrOpSB5 += " AND SC2.C2_SEQUEN = '" + SubStr(aFiltros[1][2],9,3) + "' "

		conout("Qry dados op: " + cQrOpSB5)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrOpSB5),"cQrOpSB5",.T.,.T.)

		dbSelectArea("cQrOpSB5")

		Count To nTotReg          // Quantidade de registros retornados pela query

		dbSelectArea("cQrOpSB5")
		dbgotop()

		While !EoF()
			aColunas := {}

			/*AAdd( aColunas, cQrOpSB5->C2_NUM )
      AAdd( aColunas, cQrOpSB5->C2_PRODUTO + " - " + ALLTRIM(Posicione("SB1",1,FWxFilial('SB1') + cQrOpSB5->C2_PRODUTO, "B1_DESC")))
      AAdd( aColunas, cQrOpSB5->B1_ZZMED)	//Medida Especificada
	  AAdd( aColunas, cQrOpSB5->B1_ZZSOMB)	//Sombra Especificada
	  AAdd( aColunas, cQrOpSB5->B1_ZZQTDFA)	//Qtdade Fardo
	  AAdd( aColunas, cQrOpSB5->B1_ZZLARG)	//Largura Especificada
	  AAdd( aColunas, cQrOpSB5->B1_ZZCOMP)	//Comprimento Especificado
      AAdd( aColunas, cQrOpSB5->B1_ZZPESA)	//Pesagem Especificada
      AAdd( aColunas, cQrOpSB5->C2_ZZTEAR)	//Tear utilizado OP
			AAdd( aColunas, cQrOpSB5->B1_PESO)	//Peso Liquido*/


			cJson:='{'
			cJson +=' "produto":"'+cQrOpSB5->C2_PRODUTO+' - ' + ALLTRIM(Posicione('SB1',1,FWxFilial('SB1') + cQrOpSB5->C2_PRODUTO, 'B1_DESC'))+'",
			cJson +=' "recurso":"'+IIF(Alltrim(cQrOpSB5->B1_TIPO) == "PI", ALLTRIM(cQrOpSB5->C2_ZRECORI), ALLTRIM(cQrOpSB5->C2_ZZTEAR))+'",'
			cJson +=' "armazem":"'+ALLTRIM(cQrOpSB5->C2_LOCAL)+'"'
			cJson +=' }'
			cQrOpSB5->(dbSkip())
			EXIT
		EndDo

		cQrOpSB5->(DbCloseArea())

		//cJson := FWJsonSerialize(aColunas, .T., .T.,,.F.)
		::SetResponse(EncodeUtf8(cJson))

		If Empty(cJson)
			self:setStatus(204)
		EndIf

	ENDIF
Return (lRet)

WSMETHOD GET QUERYPARAM CNUMOP,OPERACAO,RECURSO,TURNO WSSERVICE TOTEMP3

	Local aFiltros      := Self:aQueryString
	Local aEmpenho      := {}
	Local aColunas      := {}
	Local _nCnt         := 1
	Local _nOperAnt     := 0
	Local cAlias		:= getNextAlias()
	Local cDescTurno	:= ""
	Local cOrdem		:= ""
	Local cOperacao		:= ""
	Local cRecurso		:= ""
	Local cTurno		:= ""

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

	conout("Rotina: GET TOTEMP3 - Qtde apontadas Prod. por Operação detalhados")

	::SetContentType("application/json")

	If Len(aFiltros) > 0

		For nRecord := 1 To Len(aFiltros)
			If aFiltros[nRecord, 1] == "CNUMOP"
				cOrdem := aFiltros[nRecord, 2]
			ElseIf aFiltros[nRecord, 1] == "OPERACAO"
				cOperacao := Strzero(Val(aFiltros[nRecord, 2]),TamSx3("H6_OPERAC")[1])
			ElseIf aFiltros[nRecord, 1] == "RECURSO"
				cRecurso := aFiltros[nRecord, 2]
			ElseIf aFiltros[nRecord, 1] == "TURNO"
				cTurno := aFiltros[nRecord, 2]
			EndIf			
		Next nRecord

		If Empty(cOrdem)
			conout("Ordem de produção não informada")
			SetRestFault(400, "Ordem de produção não informada")
			Return(.F.)
		EndIf

		conout("Iniciando consulta da API TOTEMP3...")
		cQuery2 := "SELECT H6_OP, H6_PRODUTO, B1_DESC, C2_UM, H6_XUSER,B1_CODBAR,H6_IDENT, "
		cQuery2 += " SUBSTRING(H6_DATAINI,7,2) + '/' + SUBSTRING(H6_DATAINI,5,2) + '/' + SUBSTRING(H6_DATAINI,1,4) DATA_INI, "
		cQuery2 += " H6_HORAINI, "
		cQuery2 += " SUBSTRING(H6_DATAFIN,7,2) + '/' + SUBSTRING(H6_DATAFIN,5,2) + '/' + SUBSTRING(H6_DATAFIN,1,4) DATA_FIM, "
		cQuery2 += " H6_HORAFIN, "
		cQuery2 += " H6_OPERAC, G2_DESCRI, H6_OPERADO, H6_QTDPROD, H6_RECURSO,H6_ZZMULTP,H6_ZQTPRO2,H6_LOCAL,H6_ZZTURNO, H6_XOPERA,"
		cQuery2 += " CASE WHEN H6_ZZIDENT <> ' ' THEN H6_ZZIDENT ELSE H6_IDENT END H6_ZZIDENT "
		cQuery2 += " FROM " + RetSqlName("SH6") + " AS SH6, " + RetSqlName("SG2") + " AS SG2, " + RetSqlName("SC2") + " AS SC2, " + RetSqlName("SB1") + " AS SB1 "
		cQuery2 += " WHERE SH6.H6_FILIAL = '" + FWxFilial('SH6') + "' AND SH6. D_E_L_E_T_ = '' "
		cQuery2 += " AND SH6.H6_TIPO = 'P' "
		cQuery2 += " AND SG2.G2_FILIAL = '" + FWxFilial('SG2') + "' AND SG2.D_E_L_E_T_ = '' "
		cQuery2 += " AND SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' AND SB1.D_E_L_E_T_ = '' "
		cQuery2 += " AND SH6.H6_PRODUTO = SB1.B1_COD "
		cQuery2 += " AND SH6.H6_OPERAC = SG2.G2_OPERAC "
		cQuery2 += " AND SH6.H6_PRODUTO = SG2.G2_PRODUTO "
		cQuery2 += " AND SC2.C2_ROTEIRO = SG2.G2_CODIGO "
		cQuery2 += " AND SC2.C2_FILIAL = '" + FWxFilial('SC2') + "' AND SC2. D_E_L_E_T_ = '' "
		cQuery2 += " AND SUBSTRING(H6_OP,1,6) = C2_NUM "
		cQuery2 += " AND SUBSTRING(H6_OP,7,2) = C2_ITEM "
		cQuery2 += " AND SUBSTRING(H6_OP,9,3) = C2_SEQUEN "

		If !Empty(cOrdem)
			cQuery2 += " AND SH6.H6_OP = " + ValToSql(cOrdem)
		EndIf
		If !Empty(cOperacao)
			cQuery2 += " AND SH6.H6_OPERAC = " + ValToSql(cOperacao)
		EndIf
		If !Empty(cRecurso)
			cQuery2 += " AND SH6.H6_RECURSO = " + ValToSql(cRecurso)
		EndIf
		If !Empty(cTurno)
			cQuery2 += " AND SH6.H6_ZZTURNO = " + ValToSql(cTurno)
		EndIf
		cQuery2 += " ORDER BY DATA_INI"

		conout("Query Tot. Emp.: " + cQuery2)

		cAlias := MpsysOpenQuery(cQuery2)
		dbSelectArea(cAlias)
		(cAlias)->(dbGoTop())

		_nCnt     := 1                // Contador auxiliar para controle qtde produzida na Operação Anterior
		_nOperAnt := 0                // Qtde Produzida na Operação Anterior

		While !EoF()
			aColunas := {}
			AAdd( aColunas, (cAlias)->H6_XUSER )
			AAdd( aColunas, (cAlias)->H6_OP )
			AAdd( aColunas, (cAlias)->H6_PRODUTO )
			AAdd( aColunas, (cAlias)->H6_OPERAC )

			AAdd( aColunas, (cAlias)->H6_RECURSO )
			AAdd( aColunas, (cAlias)->DATA_INI )

			AAdd( aColunas, (cAlias)->H6_HORAINI )
			AAdd( aColunas, (cAlias)->DATA_FIM )

			AAdd( aColunas, (cAlias)->H6_HORAFIN )
			AAdd( aColunas, (cAlias)->H6_ZZMULTP )

			AAdd( aColunas, (cAlias)->H6_QTDPROD )
			AAdd( aColunas, (cAlias)->H6_ZQTPRO2 )

			AAdd( aColunas, (cAlias)->H6_LOCAL )
			AAdd( aColunas, (cAlias)->H6_OPERADO )

			cDescTurno := Posicione("ZZ7", 1, xFilial("ZZ7")+(cAlias)->H6_ZZTURNO, "ZZ7_DESC" )
			AAdd( aColunas, iif(EMPTY(cDescTurno),"SEM TURNO",cDescTurno) )
			AAdd( aColunas, (cAlias)->H6_OP+(cAlias)->H6_IDENT)
			AAdd( aColunas, (cAlias)->H6_ZZIDENT )
			AAdd( aColunas, (cAlias)->H6_XOPERA )

			AAdd( aEmpenho , aColunas )

			(cAlias)->(dbSkip())
			_nCnt++
		EndDo

		(cAlias)->(dbCloseArea())

		conout("Finalizando consulta da API TOTEMP3...")

		cJson := FWJsonSerialize(aEmpenho, .T., .T.,,.F.)

		::SetResponse(cJson)
	EndIf

Return .T.



WSMETHOD GET QUERYPARAM NUMOP WSSERVICE GETOPERACAO

	Local aFiltros      := Self:aQueryString
	Local aRecurso      := {}
	Local nTotReg       := 0    // Quantidade de registros retornados da Query
	Local lRet 			    := .T.

	conout("Rotina: GET OPERACAO.")

	::SetContentType("application/json")

	IF Len(aFiltros) > 0

		// Inicio tratativa para verificar o preenchimento da Operação no momento da caonsulta do Empenho - 24/11/2021
		if Select("getoper") > 0
			DbSelectArea("getoper")
			QrRecurso->(DbCloseArea())
		endif

		cQuery+="SELECT G2_OPERAC"
		cQuery+=" FROM "+RETSQLNAME("SG2")+" SG2"
		cQuery+=" INNER JOIN "+RETSQLNAME("SC2")+" SC2 ON SC2.C2_PRODUTO=SG2.G2_PRODUTO AND SG2.D_E_L_E_T_<>'*'"
		cQuery+=" WHERE"
		cQuery+=" AND SC2.C2_NUM = '" + SubStr(aFiltros[1][2],1,6) + "' "
		cQuery+=" AND SC2.C2_ITEM = '" + SubStr(aFiltros[1][2],7,2) + "' "
		cQuery+=" AND SC2.C2_SEQUEN = '" + SubStr(aFiltros[1][2],9,3) + "' "
		cQuery+=" SG2.D_E_L_E_T_<>'*'"

		conout("Qry dados Operação: " + cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"getoper",.T.,.T.)

		dbSelectArea("getoper")

		Count To nTotReg          // Quantidade de registros retornados pela query

		dbSelectArea("getoper")
		dbgotop()

		While !EoF()

			cJson:='{'
			cJson +=' "operacao":"'+getoper->C2_PRODUTO+'"'
			cJson +=' }'
			exit
		EndDo

		QrRecurso->(DbCloseArea())


		::SetResponse(cJson)
	ENDIF
Return (lRet)


WSMETHOD GET QUERYPARAM NUMOP,NTIME WSSERVICE GETOPERADOR

	Local aFiltros      := Self:aQueryString

	Local lRet 			    := .T.

	conout("Rotina: GET OPERADOR.")

	::SetContentType("application/json")

	IF Len(aFiltros) > 0


		dbselectarea("SC2")

		if MsSeek( FWxFilial('SC2') + aFiltros[1][2] )
			If Len(aFiltros) > 2
				u:=ALLTRIM(u_getOperadorTurno(aFiltros[2][2],aFiltros[3][2]))
			Else
				u:=ALLTRIM(u_getOperadorTurno(aFiltros[2][2],SC2->C2_ZZTEAR))
			EndIf

			While !EoF()

				cJson:='{'
				cJson +=' "operador":"'+u+'"'
				cJson +=' }'
				exit
			EndDo

		else
			cJson:='{'
			cJson +=' "operador":""'
			cJson +=' }'

		endif

		::SetResponse(cJson)
	ENDIF
Return (lRet)


WSMETHOD POST WSSERVICE ESTORNO

	Local cJSON 		:= Self:GetContent() // Pega a string do JSON
	Local oParseJSON 	:= Nil
	Local cJsonRet 		:= " "
	Local cErro 		:= " "
	Local cCodIdent 	:= " "
	Local aLog        	:= {}         // Array para receber erro log da rotina executada via MsExecAuto
	Local nCntLog     	:= 0          // Contador do laço de repetição para tratativa de possivel erro log
	Local lRet 			:= .F.        // Var. de Retorno, caso tenha efetuado o ajuste de empenho com SUCESSO retorna .T. = True, senão .F. = False
	Local aCabec 		:= {}
	Local _nQtdPro    	:= 0          // Qtde Produzida
	Local _nQtdPer    	:= 0          // Qtde de Perda
	Local _nQtdFal    	:= 0          // Qtde Faltante para terminar OP (C2_QUANT - C2_QUJE - C2_PERDA) // 23/05/2021 - MAC
	Local _cUpdDtPr   	:= ''         // Update no campo H6_DTPROD para ficar com a mesma data do H6_DTAPONT
	Local _cLocPrd    	:= ''         // Local da Produção
	Local _dDatLot    	:= StoD('')   // Data do Lote
	Local _cIdent     	:= ''         // Nro do campo D3_IDENT
	Local _cNrSeq     	:= ''         // Nro do campo D3_NUMSEQ
	Local _cQrInfMv   	:= ''         // Query para retornar os campos D3_IDENT e D3_NUMSEQ do movimento a ser modificado a data

	Private lMsErroAuto     := .F.
	Private lMsHelpAuto     := .F.
	Private _cNumOP         := " "
	Private _cOper          := " "
	Private _cProdut        := " "
	Private lAutoErrNoFile  := .T.

	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')	// 20/01/2022 - Definição do padrão de Data (dd/mm/yyyy) - Colocado p/ resolver problema com a exibição de Data qdo utilizado o REST

	conout("Rotina: POST PRODUCAO - Apont. Prod. por Operação - MATA681")

	oParseJSON := JSonObject():New()
	cErr  	   := oParseJSON:fromJson(cJSON)

	if !empty(cErr)
		conout('Erro: ' + cErr)
		SetRestFault(400, cErr)
		lRet := .F.
		Return(lRet)
	endif

	_NUMOP      := oParseJSON["OP"]
	_PRODUTO    := oParseJSON["produto"]
	_OPERACAO   := oParseJSON["operacao"]
	_RECURSO    := oParseJSON["recurso"]
	_DTINICIAL  := oParseJSON["dataini"]
	_HRINIC     := oParseJSON["horaini"]
	_DTFINAL    := oParseJSON["datafim"]
	_HRFINAL    := oParseJSON["horafim"]
	_QTDMULT    := oParseJSON["qtdmultiplo"]
	_QTDPROD    := oParseJSON["qtdproduzido"]
	_QTDPRODKG  := oParseJSON["qtdkg"]
	_ARMAZEM    := oParseJSON["armazem"]
	_OPERADOR   := oParseJSON["operador"]
	cCodIdent	:= oParseJSON["identificador"]



	DbSelectArea("SC2")
	DbSetOrder(1)
	DbGoToP()

	if MsSeek( FWxFilial('SC2') + _NUMOP )
		_cProdut  := SC2->C2_PRODUTO
		_nQtdFal  := SC2->C2_QUANT
		_cLocPrd  := SC2->C2_LOCAL
	endif

	SC2->(DbCloseArea())

	_nPas:=0
	if select ("getrecno")>0
		getrecno->(Dbclosearea())
	endif

	If !Empty(cCodIdent)
		cQuery:="SELECT R_E_C_N_O_ FROM "+retsqlname("SH6")+" WHERE D_E_L_E_T_<>'*' AND H6_OP+H6_IDENT = " + ValToSql(cCodIdent)
	Else
		cQuery:="SELECT R_E_C_N_O_ FROM "+retsqlname("SH6")+" WHERE D_E_L_E_T_<>'*' AND H6_OP='"+_NUMOP+"' AND H6_DATAINI='"+DTOS(ctod(_DTINICIAL))+"' AND H6_HORAINI='"+_HRINIC+"'"
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"getrecno",.T.,.T.)

	WHile getrecno->(!EOF())
		aCabec:={}
		Aadd(aCabec, {"H6_FILIAL"   , FWxFilial('SH6')			, Nil })
		Aadd(aCabec, {"H6_OP"		, _NUMOP	        	    , Nil })
		Aadd(aCabec, {"H6_OPERAC"	, _OPERACAO				   	, Nil })
		aAdd(aCabec, {"H6_RECURSO"	, _RECURSO 					, Nil })
		aAdd(aCabec, {"H6_PRODUTO"	, _cProdut     	    		, Nil })
		aAdd(aCabec, {"H6_OPERADO"	, _OPERADOR    	    		, Nil })
		Aadd(aCabec, {"H6_DATAINI"	, CTOD(_DTINICIAL)		, Nil })
		Aadd(aCabec, {"H6_HORAINI"	, _HRINIC					, Nil })
		Aadd(aCabec, {"H6_DATAFIN"	, CTOD(_DTFINAL)		, Nil })
		Aadd(aCabec, {"H6_HORAFIN"	, _HRFINAL					, Nil })
		Aadd(aCabec, {"H6_ZZMULTP"	, _QTDMULT				    , Nil })
		Aadd(aCabec, {"H6_QTDPROD"	, _QTDPROD 			        , Nil })
		aAdd(aCabec, {"H6_ZQTPRO2"	, _QTDPRODKG     				, Nil })
		aAdd(aCabec, {"H6_LOCAL  "	, _ARMAZEM  , Nil })
		aAdd(aCabec, {"AUTRECNO", getrecno->R_E_C_N_O_ , Nil})






		MsExecAuto({|x, y| MATA681(x, y)} , aCabec , 5 ) //estorno

		if lMsErroAuto
			// Efetua um RollBack da transacao, desfaz as alteracoes (apontamento por operação)
			aLog  := GetAutoGRLog()

			for nCntLog := 1 To Len(aLog)
				if !Empty(cErro)
					cErro += CRLF
				endif
				cErro += aLog[nCntLog]
			next nCntLog

			conout("Falha MATA681")
			conout(cErro)
			SetRestFault(400, cErro)
			lRet := .F.
			EXIT
		else
			lRet := .T.
			cJSONRet := '{ "ESTORNADO COM SUCESSO!" }'
			::SetResponse( cJSONRet )
			EXIT
		endif
		getrecno->(Dbskip())
	EndDo


Return(lRet)


//---------------------------------------------------------------------------------------------------//
// Método GET - Retorna os recursos cadastrados.                                                     //
//---------------------------------------------------------------------------------------------------//

WSMETHOD GET WSSERVICE impressoes

	Local aRecurso      := {}
	Local nTotReg       := 0    // Quantidade de registros retornados da Query
	Local lRet 			    := .T.

	conout("Rotina: GET RECURSO - Ret as filas de impressao.")

	::SetContentType("application/json")

	// Inicio tratativa para verificar o preenchimento da Operação no momento da caonsulta do Empenho - 24/11/2021
	if Select("impressao") > 0
		DbSelectArea("impressao")
		impressao->(DbCloseArea())
	endif

	// Qry para retornar os dados Ordem de Produção em questão
	cQrImpressao := "SELECT * "
	cQrImpressao += " FROM " + RetSqlName("CB5") + " AS CB5 "
	cQrImpressao += " WHERE CB5.CB5_FILIAL = '" + FWxFilial('CB5') + "' AND CB5.D_E_L_E_T_ = '' "

	conout("Qry dados op: " + cQrImpressao)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrImpressao),"impressao",.T.,.T.)

	dbSelectArea("impressao")

	Count To nTotReg          // Quantidade de registros retornados pela query

	dbSelectArea("impressao")
	dbgotop()

	While impressao->(!EoF())
		aColunas := {}
		AAdd( aColunas, impressao->CB5_CODIGO )
		AAdd( aColunas, EncodeUTF8(impressao->CB5_DESCRI, "cp1252") )
		AAdd( aRecurso , aColunas )
		impressao->(dbSkip())
	EndDo

	impressao->(DbCloseArea())

	cJson := FWJsonSerialize(aRecurso, .T., .T.,,.F.)
	::SetResponse(cJson)

Return (lRet)

WSMETHOD POST WSSERVICE IMPRIME

	Local cJSON 		:= Self:GetContent() // Pega a string do JSON
	Local oParseJSON 	:= Nil
	Local cJsonRet 		:= " "
	Local cErro 		:= " "
	Local lRet 			:= .F.        // Var. de Retorno, caso tenha efetuado o ajuste de empenho com SUCESSO retorna .T. = True, senão .F. = False
	Local lImprime      :=.F.
	Local aArea := GetArea()
	Local aAreaQPK := QPK->(GetArea())
	Local aAreaSB8	:= SB8->(GetArea())
	Local cCodIdent		:= ""
	Private _cNumOP         := " "
	Private _cOper          := " "
	Private _cProdut        := " "
	private IMPCAB 	:= .f.
	private QTNETI:= 0
	private CODIMPR := ""
	private cNomeUser := ""
	Private lApp:=.T.




	Set(_SET_DATEFORMAT, 'dd/mm/yyyy')	// 20/01/2022 - Definição do padrão de Data (dd/mm/yyyy) - Colocado p/ resolver problema com a exibição de Data qdo utilizado o REST

	conout("Rotina: POST  - Impressões de etiquetas.")

	oParseJSON := JSonObject():New()
	cErr  	   := oParseJSON:fromJson(cJSON)

	if !empty(cErr)
		conout('Erro: ' + cErr)
		SetRestFault(400, cErr)
		lRet := .F.
		Return(lRet)
	endif

	_NUMOP      := oParseJSON:NUMOP

	CODIMPR     := oParseJSON:LOCALIMP
	IMPCAB      := oParseJSON:IMPEMP
	QTNETI      := oParseJSON:QUANTIMP
	_DTINICIAL  := oParseJSON:DTINICIAL
	_HRINIC     := oParseJSON:HRINIC
	cCodIdent   := oParseJSON:IDENT
	cNomeUser	:= oParseJSON:USUARIO
	lReimpressao := oParseJSON:REIMPRESSAO

	if type("QTNETI")=="C"
		QTNETI:=VAL(QTNETI)
	endif

	Dbselectarea("QPK")
	dbselectarea("SB8")

	if select ("getrecno")>0
		getrecno->(Dbclosearea())
	endif

	If !Empty(cCodIdent)
		cQuery:="SELECT R_E_C_N_O_ FROM "+retsqlname("SH6")+" WHERE D_E_L_E_T_<>'*' AND H6_OP+H6_IDENT = " + ValToSql(cCodIdent)
	Else
		cQuery:="SELECT R_E_C_N_O_ FROM "+retsqlname("SH6")+" WHERE D_E_L_E_T_<>'*' AND H6_OP='"+_NUMOP+"' AND H6_DATAINI='"+DTOS(ctod(_DTINICIAL))+"' AND H6_HORAINI='"+_HRINIC+"'"
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"getrecno",.T.,.T.)

	WHile getrecno->(!EOF())
		lImprime:=.T.
		Dbselectarea("SH6")
		//Posiciona SH6
		SH6->(dbgoto(getrecno->R_E_C_N_O_))

		//dbseek(xfilial("SH6")+SH6->H6_OP+SH6->H6_PRODUTO,.F.)

		SB8->(DbSetOrder(5)) //B8_FILIAL+B8_PRODUTO+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
		If SB8->(DbSeek(xFilial("SB8") + SH6->H6_PRODUTO + SH6->H6_LOTECTL))
			RecLock("SB8",.F.)
			SB8->B8_ZZOBS := SH6->H6_ZZOBS
			SB8->(MsUnlock())
		EndIf

		//Impressão da Etiqueta
		If ExistBlock("valImpEt")
			u_impEtq(lReimpressao)
		EndIf


		getrecno->(Dbskip())
	EndDo

	If !lImprime
		lRet := .F.
		SetRestFault(400, cErro)
	else
		lRet := .T.
		cJSONRet := '{ "Imprimido com sucesso!" }'
		::SetResponse( cJSONRet )
	endif

	RestArea(aAreaSB8)
	RestArea(aAreaQPK)
	RestArea(aArea)

Return(lRet)


WSMETHOD GET QUERYPARAM NUMOP,NTIME WSSERVICE GETMULT

	Local aFiltros      := Self:aQueryString

	Local lRet 			    := .T.

	conout("Rotina: GET OPERADOR.")

	::SetContentType("application/json")

	IF Len(aFiltros) > 0


		dbselectarea("SC2")

		if MsSeek( FWxFilial('SC2') + aFiltros[1][2] )
			u:=POSICIONE("SB1",1,xfilial("SB1")+SC2->C2_PRODUTO,"B1_QE")



			cJson:='{'
			cJson +=' "valor":"'+cvaltochar(u)+'"'
			cJson +=' }'


		else
			cJson:='{'
			cJson +=' "valor":"0"'
			cJson +=' }'

		endif

		::SetResponse(cJson)
	ENDIF
Return (lRet)


WSMETHOD GET QUERYPARAM USUARIOLOG,FILA WSSERVICE LOCALIMPR



	Local lRet 			    := .T.

	conout("Rotina: GET LOCALIMPR.")

	::SetContentType("application/json")


	Dbselectarea("ZZZ")

	IF len(Self:aQueryString)<=1

		//VERIFICA SE JA EXISTE LOG PARA ROTINA
		if ZZZ->(MsSeek(xfilial("ZZZ")+"01"+padr(Self:aQueryString[1][2],tamsx3("ZZZ_USER")[1])))

			ZZZ->(Msunlock())

			// Inicio tratativa para verificar o preenchimento da Operação no momento da caonsulta do Empenho - 24/11/2021
			if Select("impressao") > 0
				DbSelectArea("impressao")
				impressao->(DbCloseArea())
			endif

			// Qry para retornar os dados Ordem de Produção em questão
			cQrImpressao := "SELECT * "
			cQrImpressao += " FROM " + RetSqlName("CB5") + " AS CB5 "
			cQrImpressao += " WHERE CB5.CB5_FILIAL = '" + FWxFilial('CB5') + "' AND CB5.D_E_L_E_T_ = '' AND CB5.CB5_CODIGO='"+ZZZ->ZZZ_FILA+"'"



			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrImpressao),"impressao",.T.,.T.)

			dbSelectArea("impressao")

			// Quantidade de registros retornados pela query
			aRecurso:={}
			While impressao->(!EoF())
				aColunas := {}
				AAdd( aColunas, impressao->CB5_CODIGO )
				AAdd( aColunas, EncodeUTF8(impressao->CB5_DESCRI, "cp1252") )
				AAdd( aRecurso , aColunas )
				impressao->(dbSkip())
			EndDo

			cJson := FWJsonSerialize(aRecurso, .T., .T.,,.F.)


		else


			cJson:='{'
			cJson +=' "PREFERENCIA":""'
			cJson +=' }'

		endif

		::SetResponse(cJson)
	ELSEIF LEN(Self:aQueryString)>1

		//Caso seja consumido fila, verifica se a fila ja foi setada, compara com a gravada e altera caso seja diferente

		if ZZZ->(MsSeek(xfilial("ZZZ")+"01"+padr(Self:aQueryString[2][2],tamsx3("ZZZ_USER")[1])))
			//
			if !(ALLTRIM(Self:aQueryString[1][2])==ALLTRIM(ZZZ->ZZZ_FILA))
				reclock("ZZZ",.F.)
				ZZZ->ZZZ_FILA:=	Self:aQueryString[1][2]
				ZZZ->(Msunlock())
			endif

			cJson:='{'
			cJson +=' "PREFERENCIA":""'
			cJson +=' }'
		else
			RECLOCK("ZZZ",.T.)
			ZZZ->ZZZ_ROTINA:="01"
			ZZZ->ZZZ_USER  :=ALLTRIM(Self:aQueryString[2][2])
			ZZZ->ZZZ_FILA  :=Self:aQueryString[1][2]
			ZZZ->(Msunlock())
		endif
		cJson:='{'
		cJson +=' "PREFERENCIA":""'
		cJson +=' }'
		::SetResponse(cJson)

	ENDIF
Return (lRet)


WSMETHOD GET WSSERVICE TURNOS

	Local aRecurso      := {}
	Local nTotReg       := 0    // Quantidade de registros retornados da Query
	Local lRet 			    := .T.

	conout("Rotina: Turnos - returna turnos cadastrados.")

	::SetContentType("application/json")

	// Inicio tratativa para verificar o preenchimento da Operação no momento da caonsulta do Empenho - 24/11/2021
	if Select("impressao") > 0
		DbSelectArea("impressao")
		impressao->(DbCloseArea())
	endif

	// Qry para retornar os dados Ordem de Produção em questão
	cQrImpressao := "SELECT * "
	cQrImpressao += " FROM " + RetSqlName("ZZ7") + " AS ZZ7 "
	cQrImpressao += " WHERE ZZ7.ZZ7_FILIAL = '" + FWxFilial('ZZ7') + "' AND ZZ7.D_E_L_E_T_ = '' AND ZZ7_MSBLQL = '2'  "

	conout("Qry dados op: " + cQrImpressao)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrImpressao),"impressao",.T.,.T.)

	dbSelectArea("impressao")

	Count To nTotReg          // Quantidade de registros retornados pela query

	dbSelectArea("impressao")
	dbgotop()

	While impressao->(!EoF())
		aColunas := {}
		AAdd( aColunas, impressao->ZZ7_HORAIN )
		AAdd( aColunas, impressao->ZZ7_HORAFI )
		AAdd( aColunas, EncodeUTF8(impressao->ZZ7_DESC, "cp1252") )
		AAdd( aRecurso , aColunas )
		impressao->(dbSkip())
	EndDo

	impressao->(DbCloseArea())

	cJson := FWJsonSerialize(aRecurso, .T., .T.,,.F.)
	::SetResponse(cJson)

Return (lRet)

WSMETHOD GET QUERYPARAM USUARIO WSSERVICE USUARIOLOGADO

	Local aFiltros      			:= Self:aQueryString
	Local cJson         			:= ""
	Local cQuery        			:= ""
	Local cAlias        			:= ""
	Local lRet          			:= .T.
	Local cUsuario      			:= ""
	Local cUsrVal   				:= ""
	Local lTrocLid  				:= .F.
	Local lCtrlPar 				:= .F.
	Local lCtrlQual 				:= .F.
	Local lApoFab 				:= .F.
	Local lSolMan 				:= .F.
	Local lApoApa 				:= .F.
	Local lEmpBob 				:= .F.
	Local lApoExp 				:= .F.
	Local lApoExt 				:= .F.

	conout("Rotina: GET USUARIOLOGADO - Busca acessos do usuario.")

	::SetContentType("application/json")

	IF Len(aFiltros) > 0

		cUsuario := AllTrim(aFiltros[1][2])

		// Fecha área se já estiver aberta
		If Select("QrZZ9") > 0
			DbSelectArea("QrZZ9")
			(QrZZ9)->(DbCloseArea())
		EndIf

		// Query para buscar os dados do usuário na tabela ZZ9
		cQuery := "SELECT * "
		cQuery += " FROM " + RetSqlName("ZZ9") + " AS ZZ9 "
		cQuery += " WHERE ZZ9.ZZ9_FILIAL = '" + FWxFilial('ZZ9') + "' "
		cQuery += " AND ZZ9.D_E_L_E_T_ = '' "
		cQuery += " AND ZZ9.ZZ9_USER = '" + cUsuario + "' "

		conout("Query ZZ9: " + cQuery)

		cAlias := MPSysOpenQuery(cQuery)

		(cAlias)->(dbGoTop())

		// Se encontrou registro, monta o JSON
		If !(cAlias)->(EoF())
			cUsrVal := AllTrim((cAlias)->ZZ9_USER)
			lTrocLid := ((cAlias)->ZZ9_TROLID == "S")
			lCtrlPar := ((cAlias)->ZZ9_CONPAR == "S")
			lCtrlQual := ((cAlias)->ZZ9_CONQUA == "S")
			lApoFab := ((cAlias)->ZZ9_APOFAB == "S")
			lSolMan := ((cAlias)->ZZ9_SOLMAN == "S")
			lApoApa := ((cAlias)->ZZ9_APOAPA == "S")
			lEmpBob := ((cAlias)->ZZ9_EMPBOB == "S")
			lApoExp := ((cAlias)->ZZ9_APOEXP == "S")
			lApoExt := ((cAlias)->ZZ9_APOEXT == "S")

			// Monta o JSON no formato solicitado
			cJson := '{'
			cJson += '"items": [{'
			cJson += '"usuario": "' + cUsrVal + '",'
			cJson += '"troca_lidere": ' + IIf(lTrocLid, "true", "false") + ','
			cJson += '"controle_parada": ' + IIf(lCtrlPar, "true", "false") + ','
			cJson += '"controle_qualidade": ' + IIf(lCtrlQual, "true", "false") + ','
			cJson += '"apontamento_fabrica": ' + IIf(lApoFab, "true", "false") + ','
			cJson += '"solicitacao_manutencao": ' + IIf(lSolMan, "true", "false") + ','
			cJson += '"apontamento_apara": ' + IIf(lApoApa, "true", "false") + ','
			cJson += '"empenho_bobina": ' + IIf(lEmpBob, "true", "false") + ','
			cJson += '"apontamento_expedicao": ' + IIf(lApoExp, "true", "false") + ','
			cJson += '"apontamento_extrusao": ' + IIf(lApoExt, "true", "false")
			cJson += '}],'
			cJson += '"hasNext": false,'
			cJson += '"remainingRecords": 0'
			cJson += '}'
		Else
			// Se não encontrou nenhum registro, retorna estrutura vazia
			cJson := '{'
			cJson += '"items": [],'
			cJson += '"hasNext": false,'
			cJson += '"remainingRecords": 0'
			cJson += '}'
		EndIf

		(cAlias)->(DbCloseArea())

		::SetResponse(cJson)

	Else
		// Retorna estrutura vazia se não houver parâmetro
		cJson := '{'
		cJson += '"items": [],'
		cJson += '"hasNext": false,'
		cJson += '"remainingRecords": 0'
		cJson += '}'

		::SetResponse(cJson)
	EndIf

Return (lRet)

//---------------------------------------------------------------------------------------------//
// Método GET - Retorna a lista do cadastro dos operadores com filtro de recurso e turno.      //
//---------------------------------------------------------------------------------------------//

WSMETHOD GET QUERYPARAM TURNO, RECURSO WSSERVICE CONSOPERADOR_RECURSO

	Local aFiltros      := Self:aQueryString
	Local aOperador     := {}
	Local aColunas      := {}
	Local _nCnt         := 1          // Contador auxiliar para controle qtde produzida na Operação Anterior
	Local _nOperAnt     := 0          // Qtde Produzida na Operação Anterior
	Local cTurno    	:= ""
	Local cRecurso    	:= ""
	Local cAlias    	:= ""
	Local cQuery        := ""


	conout("Rotina: GET CONSOPERADOR_RECURSO - Cadastro Operadores com filtro de recurso e turno")

	::SetContentType("application/json")

	If Len(aFiltros) > 0
		cTurno := AllTrim(aFiltros[1][2])
		cRecurso := AllTrim(aFiltros[2][2])

		cQuery := " SELECT " + CRLF
		cQuery += " 	TOP 1 ZZ_COD" + CRLF
		cQuery += " 	,ZZ_NOME " + CRLF
		cQuery += " FROM "
		cQuery += " 	" + RetSqlTab("SZ2") + CRLF
		cQuery += " 	INNER JOIN " + RetSqlTab("SZZ") + " ON 1 = 1 " + CRLF
		cQuery += " 		AND " + RetSqlFil("SZZ") + CRLF
		cQuery += " 		AND ZZ_COD = Z2_OPERADO " + CRLF
		cQuery += " 		AND " + RetSqlDel("SZZ") + CRLF
		cQuery += " WHERE " + CRLF
		cQuery += " 	1 = 1 " + CRLF
		cQuery += " 	AND " + RetSqlFil("SZ2") + CRLF
		cQuery += " 	AND Z2_TURNO = " + ValToSql(cTurno) + CRLF
		cQuery += " 	AND Z2_MAQUINA = " + ValToSql(cRecurso) + CRLF
		cQuery += " 	AND " + RetSqlDel("SZ2") + CRLF


		conout("Query Operador: " + cQuery)

		cAlias := MPSysOpenQuery(cQuery)

		(cAlias)->(dbGoTop())

		cJson := '{'
		If !(cAlias)->(EOF())
			cJson += '"items": ['
			Do While !(cAlias)->(EOF())
				cJson += '{'
				cJson += '"codigo": "' + AllTrim((cAlias)->ZZ_COD) + '",'
				cJson += '"nome": "' + AllTrim((cAlias)->ZZ_NOME) + '"'
				cJson += '}'

				(cAlias)->(dbSkip())

				If !(cAlias)->(EOF())
					cJson += ','
				EndIf
			EndDo
			cJson += ']'
		Else
			cJson += '"items": [],'
		EndIf
		cJson += '}'

		(cAlias)->(dbCloseArea())

		::SetResponse(cJson)
	ENDIF

Return .T.
