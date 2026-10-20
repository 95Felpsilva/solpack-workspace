#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} updRevisao
Atualiza campo H6_ZZREVIS
@author Tiago Faria
@since 16/07/2019
@version 1.0
@return nil
@param lEnviaRevisao, logical, indicda se deve enviar para revisão ou retirar da revisao o apontamento
@type function
/*/
user function updRevisao(lEnviaRevisao)
	local lTiraRevisao := .t.
	default lEnviaRevisao := .t.
	
	recLock("SH6",.f.)
	SH6->H6_ZZREVIS := lEnviaRevisao
	SH6->(msUnlock())
	
	msgInfo("Apontamento " + if(lEnviaRevisao,"enviado","retirado") + " da revisão com sucesso!")
return