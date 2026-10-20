#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} myHelp
Exibe aviso ao usuario com a funcao help()
@author Tiago Faria
@since 28/08/2018
@version undefined
@param cMsg, characters, Mensagem com o problema
@param cSolucao, characters, Mensagem com a solucao para o problema
@param cID, characters, ID do help
@type function
/*/
user function  myHelp(cMsg,cSolucao,cID)
	default cMsg 	:= ""
	default cSolucao:= ""
	default cID 	:= procName(1)
	
	Help(NIL, NIL, cID, NIL, cMsg, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
return