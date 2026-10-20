#include 'totvs.ch'
#INCLUDE "FWMVCDEF.CH"  

user function CadPCPA104()
    private aRotina := FwLoadMenuDef("PCPA104")
    
    ADD OPTION aRotina Title "#Rel. Ficha Ténica" Action 'u_RelFichaTecnica()' OPERATION 9 ACCESS 0

    setFunName("PCPA104")

    PCPA104()
return
