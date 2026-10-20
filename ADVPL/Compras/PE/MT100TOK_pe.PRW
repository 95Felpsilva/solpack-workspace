#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT100TOK
Ponto de entrada validação de linha documento de entrada.
@author Tiago Faria
@since 04/07/2018
@version undefined

@type function
/*/

User Function MT100TOK()
	Local lRet := .T.
	
	If (ExistBlock("MT100LOK"))
		lPE := ExecBlock("MT100LOK",.F.,.F.,{lRet})
		If ValType(lPE) = "L"
			If ! lPE
				lRet := .F. // Corrigido p/ nao alterar o lRet, se .F., novamente p/ .T.
			EndIf
		EndIf
	EndIf

Return lRet