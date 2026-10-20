#include 'totvs.ch'
/*/{Protheus.doc} WhenParcela
Funcao chamada no modo de edição do campo C5_ZZPAR1,C5_ZZPAR2
@type function
@version 12.1.33
@author Tiago Faria
@since 24/11/2021
@param cCondPag, character, Código da condicao de pagamento valor default C5_CONDPAG
@return logical, Se true o campo é editavel se false não é
/*/
user function WhenParcela(cCondPag)
return BolAntecip():isPVBoletoAntecipado(M->C5_FORPGT,M->C5_CONDPAG,.f./*lHelp*/)
