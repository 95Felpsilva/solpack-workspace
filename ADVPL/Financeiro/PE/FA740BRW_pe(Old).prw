#include 'totvs.ch'
/*/{Protheus.doc} FA740BRW
Adiciona opção no OUTRAS AÇÕES na rotina FINA750
@type function
@version 12.1.33
@author Tiago Faria
@since 06/12/2021
/*/
user function FA740BRW()
    local aRotina := {}
    aAdd( aRotina , { "#Boleto ITAU     ", "U_BOLITAU()", 0, 4, 0, NIL } ) 
    aAdd( aRotina , { "#Atu Dt. Baixa RA", "u_AtuDtBaixaRA()", 0, 4, 0, NIL } ) 
    
return aRotina


user function CNABITAU()
Public lCGC

IF SA1->A1_PESSOA=='F' 
lCGC:= "000"+ALLTRIM(SA1->A1_CGC)
else
lCGC:= SA1->A1_CGC  
endif
Return lCGC
 