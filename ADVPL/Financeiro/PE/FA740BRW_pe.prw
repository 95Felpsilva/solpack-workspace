#include 'totvs.ch'
#include "rwmake.ch"
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
 


User Function E1NUMBCO()

Local cNumBco := ""// Posiciona nos parametros do banco
Local cNumAtu := ""
SEE->( dbSetOrder( 1 ) )
SEE->( DbSeek( xFilial( "SEE" ) + "341" + "4920 " + "98793     " + "002" ) )// Banco / Agencia / Conta / Sub-conta
RecLock('SEE', .F.)
cNumbco := STRZERO(VAL(SEE->EE_FAXATU),8,0)
SEE->(MsUnlock())

// Posiciona no titulo em bordero
SE1->( dbSetOrder( 1 ) )
SE1->( DbSeek( xFilial( "SE1" ) + SEA->EA_PREFIXO + SEA->EA_NUM +SEA->EA_PARCELA +SEA->EA_TIPO ) )// Titulo em bordero

If !Empty( SE1->E1_NUMBOR ) // Atualiza numero do titulo no banco
   
   IF EMPTY(SE1->E1_NUMBCO)
    RecLock('SE1', .F.)
        SE1->E1_NUMBCO := cNumbco
    SE1->(MsUnlock())

   cNumAtu := strzero(val(cNumBco)+1,8,0)

   RecLock('SEE', .F.)
       SEE->EE_FAXATU := cNumAtu
   SEE->(MsUnlock())
   Else
   cNumbco := SE1->E1_NUMBCO
   ENDIF

//cNumBco := NossoNum()
//Aviso( "NOSSONUM", "Número do título no banco: " + cNumBco, { "Ok" }, 3 )
EndIf
Return(cNumbco)



