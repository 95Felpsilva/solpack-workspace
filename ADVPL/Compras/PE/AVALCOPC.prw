#include "TOTVS.CH"        

/*
Ponto de entrada na após a gravação do pedido de compras gerado através
da rotina Mata160 (análise de cotação). 
Exibe o numero do pedido de compras gerado.
por : Sergio Braz
Data: 20/01/12
*/


User Function AVALCOPC
	MSGALERT("Pedido Gerado:"+SC7->C7_NUM)
Return