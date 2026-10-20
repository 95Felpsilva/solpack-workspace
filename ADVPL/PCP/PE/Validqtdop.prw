#include 'protheus.ch'

User Function Validqtdop()
Local lRet      := .f.
Local nApont    := 0


If FunName() == "MATA685"
    nApont:= POSICIONE('SC2',1,XFILIAL('SC2')+M->BC_OP,'C2_QUJE')
 else 
    nApont:= POSICIONE('SC2',1,XFILIAL('SC2')+M->Z5_OP,'C2_QUJE')
Endif

If nApont <> 0
    lRet := .T.
else
    U_myhelp("OP não tem PRODUÇÃO APONTADA","Só é permitido apontar Apara ou Perda, quando a OP tem produção")
    lret := .F.
ENDIF

Return lRet