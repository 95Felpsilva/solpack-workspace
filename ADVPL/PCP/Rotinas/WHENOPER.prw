#include 'totvs.ch'
/*/{Protheus.doc} WhenOper
Funcao fhamada do modo de edição do campo H6_ZZOPER
@type function
@version 
@author Tiago Faria
@since 04/12/2020
@return logico, true campo liberado false campo bloqueado
/*/
user function WhenOper()
    local lRet := .t.

    lRet := POSICIONE("SH1",1,XFILIAL("SH1")+M->H6_RECURSO,"alltrim(H1_CTRAB)+'/'")$getNewPar("ZZ_CTLIB","REVISA/") .and. SH1->(!Eof())
    lRet := lRet .or. funname() == "MATA682"
return lRet
