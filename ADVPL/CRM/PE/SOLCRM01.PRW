#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} SOLCRM01
Esta função é utilizada no módulo CRM para retorno da Descrição da Entidade na rotina de Atividades (Cliente, Prospect ou Suspect).
Tabela AOF (Atividades) - Campo AOF_ZZDSCE (Descrição da Entidade) -> Utilizado no Inicializador Padrão e Inicializador Browse.
@author Cristiano Pedroni
@since 12/12/2017
@version 1.00
@type function
/*/

user function SOLCRM01()

	Local aArea  := GETAREA() 
	Local aSA1	 := SA1->(GETAREA())
	Local aSUS	 := SUS->(GETAREA())
	Local aACH	 := ACH->(GETAREA())
	Local cCli   := RETFIELD("SA1",1,XFILIAL("SA1")+SUBSTR(AOF_CHAVE,1,6)+SUBSTR(AOF_CHAVE,7,2),"A1_NOME")
	Local cPro   := RETFIELD("SUS",1,XFILIAL("SUS")+SUBSTR(AOF_CHAVE,1,6)+SUBSTR(AOF_CHAVE,7,2),"US_NOME")
    Local cSus   := RETFIELD("ACH",1,XFILIAL("ACH")+SUBSTR(AOF_CHAVE,1,6)+SUBSTR(AOF_CHAVE,7,2),"ACH_RAZAO")
    Local cTipo  := AOF->AOF_ENTIDA
	Local cNome  := ' '    

	IF cTipo == 'SA1'  
		cNome := cCli
	ELseIf cTipo == 'SUS'
		cNome := cPro
	ElseIf cTipo == "ACH"
		cNome := cSus
	EndIf			
		 
	SA1->(RestArea(aSA1))
	SUS->(RestArea(aSUS))   
	ACH->(RestArea(aACH))   
	RestArea(aArea)

return cNome
