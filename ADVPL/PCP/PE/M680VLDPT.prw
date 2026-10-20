#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc}	M680VLDPT
O ponto de entrada que  inibe a validação existente para o preenchimento do 
campo "Parc./Total" (H6_PT), nos apontamentos de produção modelos 1 e 2. 
Pode ser utilizado também para customizar o algoritmo de validação.

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					06/07/2015
@return				lRet         

Alteração: Alterado para deixar PARCIAL em todos os casos, pois haverá Encerramento Mensal devido
a novo metodo de apontamento de Aparas, que ocorre após o encerramento da OP. 
@author			Joni Santos
@since			22/04/2019
 

/*/
User Function M680VLDPT()
	
	Local lRet			:= .T.
	
	if FunName() <> "MATA682"
		if empty(M->H6_ZZOPER)
			lRet := .f.
			u_myHelp("Campo " + alltrim(getSX3Cache("H6_ZZOPER","X3_TITULO")) + " obrigatório!")
		endif
	endif

	/*Removido, Joni Santos 22/04/2019
	//Inicio
	If isFirstOp()
		
		//Verifica se o apontamento foi total
		If M->H6_PT == "T"
			If !(MsgYesNo("Deseja encerrar a OP ?")) 
			M->H6_PT := "P"
			EndIf 
		EndIf
	EndIf
	//Fim do Trecho removido
	*/          
	
	M->H6_PT := "P"
	
Return (lRet)

/*/{Protheus.doc}	isFirstOp
Função que valida se a operação em que o usuário realizou o
apontamento é a primeira operação do produto, pois se a
primeira encerrar, as outras tem que seguir.

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					06/07/2015
@return				lRet
/*/
Static Function isFirstOp()
	
	Local lRet			:= .F.
	Local cQuery		:= ""
	Local cAlias		:= GetNextAlias()
	Local aAreaAtu	:= GetArea()
	
	cQuery += "SELECT " + CRLF
	cQuery += "	MIN(G2_OPERAC) AS OPERAC" + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + RetSqlName("SG2") + " AS SG2" + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "	G2_FILIAL = '" + xFilial("SG2") + "' AND" + CRLF
	cQuery += "	G2_PRODUTO = '" + M->H6_PRODUTO + "' AND" + CRLF
	cQuery += "	SG2.D_E_L_E_T_ = ' '" + CRLF
	
	TcQuery cQuery New Alias &cAlias
	
	If (cAlias)->(!Eof())
		(cAlias)->(DbGoTop())
		//Verifica para ver se foi encontrado registro
		If !Empty((cAlias)->OPERAC)
			If (cAlias)->OPERAC == M->H6_OPERAC
				lRet := .T.
			EndIf
		EndIf
	EndIf
	
	(cAlias)->(DbCloseArea())
	
	RestArea(aAreaAtu)
	
Return (lRet)
