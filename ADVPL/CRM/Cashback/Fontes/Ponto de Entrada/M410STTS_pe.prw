#include "totvs.ch"

/*/{Protheus.doc} M410STTS

Ponto de Entrada na Liberação do Pedido de Venda após a transação

@type function	
@author	Gabriel Pereira Santos - CRM Services
@since 27/04/2023
@version P12
@database MSSQL

/*/
User Function M410STTS()    
    If ( FindFunction("U_SOLFAT05") )
		U_SOLFAT05(SC5->C5_FILIAL, SC5->C5_NUM, PARAMIXB[1])
	EndIf
Return
