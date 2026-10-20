#Include "Protheus.ch"

/*/{Protheus.doc}	M410AGRV
Este ponto de entrada pertence à rotina de pedidos de venda, MATA410(). 
Está localizado na rotina de gravação do pedido, A410GRAVA(). 
É executado antes da gravação das alterações.

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					27/07/2015
@return				nil
/*/
User Function M410AGRV()
	
	Local nOperacao		:= PARAMIXB[1]
	
	//Se for exclusão e existir o campo
	If nOperacao == 3 .AND. SC5->(FieldPos("C5_ZZUSRDE")) > 0
		RecLock("SC5",.F.)
		SC5->C5_ZZUSRDE := RetCodUsr()
		SC5->(MsUnLock())
	EndIf
	
Return
