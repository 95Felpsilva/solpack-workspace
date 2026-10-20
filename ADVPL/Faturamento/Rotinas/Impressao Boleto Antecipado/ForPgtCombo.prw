#include 'totvs.ch'
/*/{Protheus.doc} ForPgtCombo
Lista de opcoes chamada dos campos C5_FORPGT e E1_FORPGT
@type function
@version 12.1.33
@author Tiago Faria
@since 17/11/2021
@return character, Retorna a lista de opcoes do campo
/*/
user function ForPgtCombo()
return "BOL=Boleto;CHQ=Cheque;DEP=Deposito;DIH=Dinheiro;PAG=Pag Seguro;BND=Cartao BNDES;ANT=Antec Parcela;CAR=Carteira;OUT=Outros;PGA=Pgto Antecipado;MAR=Outros Martins;LER=Outros Leroy;ECO=Ecommerce Solpack; MAG=Ecommerce Magalu; CNB=Conecta Basf"
