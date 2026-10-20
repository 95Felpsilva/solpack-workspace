#include 'totvs.ch'
/*/{Protheus.doc} MA410MNU
PE para adicionar novas funcoes no menu da rotina de pedido de vendas
@type function
@version 12.1.33
@author Tiago Faria
@since 04/11/2021
/*/
user function MA410MNU()
    if isInCallStack('CRMA290')
        U_SOLFAT02()
    endif
        
    aadd(aRotina, {'#Gera Boleto Antecipado', 'FWMsgRun( ,{ || BolAntecip():gerar() } ,"BOLANTECIP", "Aguarde gerando boleto antecipado..."  )', 0, 4, 0, NIL})
    aadd(aRotina, {'#Re-Imprime Boleto', 'FWMsgRun( ,{ || BolAntecip():reImprimir() } ,"BOLANTECIP", "Aguarde re-imprimindo boleto antecipado..."  )', 0, 4, 0, NIL})
return
