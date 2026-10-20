#include 'totvs.ch'
/*/{Protheus.doc} LegStatusPIN
Legenda status PIN
@type function
@version 12.1.27
@author Tiago Faria
@since 14/10/2021
/*/
user function LegStatusPIN()
 Local aLegenda := {}
     
    //Monta as legendas (Cor, Legenda)
    aAdd(aLegenda,{"BR_AZUL",         "Sem SUFRAMA(PIN)"})
    aAdd(aLegenda,{"BR_VERDE",        "SUFRAMA(PIN) OK"})
    aAdd(aLegenda,{"BR_VERMELHO",     "Pendente Geração SUFRAMA(PIN)"})
     
    //Chama a função que monta a tela de legenda
    BrwLegenda("Legenda", "Status PIN", aLegenda)
return
