#include "TOTVS.CH"
#include "topconn.ch"
#include "SOLFAT04.ch"

/*/{Protheus.doc} SOLFAT07
    Rotina para disparar verificação de cashback vencido e workflow (Utilizado em JOB)

    @author Gabriel Pereira Santos
    @since 26/04/2023
    @version P12
/*/ 
User Function SOLFAT07()
    
    If FindFunction("faturamento.MonitorCashback.u_searchCashbackVencido") .And. FindFunction("U_SOLFAT06")
        faturamento.MonitorCashback.u_searchCashbackVencido()
        U_SOLFAT06()
    EndIf    
    
Return
