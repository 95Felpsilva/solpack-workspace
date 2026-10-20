#INCLUDE "Protheus.CH"

User Function MA030ROT   
    aRetorno := {}
    AAdd( aRetorno, { "Orçamento", "MATA415", 0 , 6,0,NIL})    
    AAdd( aRetorno, { "Impress Orçamento", "U_MSRORCGF()", 0 , 6,0,NIL})    
    AAdd( aRetorno, { "Pedido de Venda", "MATA410", 0 , 6,0,NIL})    
    AAdd( aRetorno, { "Impress Ped.Venda", "U_MSRFAT01()", 0 , 6,0,NIL})    
    if isInCallStack('CRMA290')
        U_SOLFAT02()
    endif
Return aRetorno 

