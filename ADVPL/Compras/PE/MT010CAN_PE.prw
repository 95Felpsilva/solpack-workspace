#Include "Protheus.ch"

/*/{Protheus.doc} MT010CAN
No final das funções citadas, após  atualizar ou não os dados do Produto; 
Pode ser utilizado para executar customizações conforme o tipo de retorno: 
Execução OK ou Execução Cancelada.

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			03/08/2015
@return 		nil
/*/
User Function MT010CAN()
	
	/*
	Inclusão / Alteração de produtos
	nOpc = 1 -> Função executada OK.
	nOpc = 3 -> Função Cancelada.	
	*/ 
	Local nOpc			:= PARAMIXB[01]
	
	If INCLUI
		If nOpc ==  1
			criaSB5()
		EndIf
	EndIf
	
Return

/*/{Protheus.doc} criaSB5
Programa que gera SB5

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			03/08/2015
@return 		lOk
/*/
Static Function criaSB5()
	
	Local aAreaSB1	:= SB1->(GetArea())
	Local aAreaSB5	:= SB5->(GetArea())
	Local aCab			:= {}
	
	Private lMsErroAuto	:= .F.
	
	SB5->(DbSetOrder(1)) //B5_FILIAL+B5_COD
	If !SB5->(DbSeek(xFilial("SB5") + SB1->B1_COD))	//Verifica se não existe SB5
		//Adiciona as informações no array
		aCab := {;
			{"B5_COD",			SB1->B1_COD,			nil},;
			{"B5_CEME",		SB1->B1_DESC,			nil},;
			{"B5_IMPETI",		"2",					nil}}
			
		//Chama a rotina automática
		MSExecAuto({|x,y| Mata180(x,y)},aCab,3)
			
		If lMsErroAuto
			MostraErro()
		EndIf
	EndIf
	
	RestArea(aAreaSB5)
	RestArea(aAreaSB1)
	
return
